
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
      14:	692080e7          	jalr	1682(ra) # 56a2 <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	680080e7          	jalr	1664(ra) # 56a2 <open>
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
      42:	f1a50513          	addi	a0,a0,-230 # 5f58 <malloc+0x4b6>
      46:	00006097          	auipc	ra,0x6
      4a:	99c080e7          	jalr	-1636(ra) # 59e2 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	612080e7          	jalr	1554(ra) # 5662 <exit>

0000000000000058 <bsstest>:
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
      58:	00009797          	auipc	a5,0x9
      5c:	3907c783          	lbu	a5,912(a5) # 93e8 <uninit>
      60:	e385                	bnez	a5,80 <bsstest+0x28>
      62:	00009797          	auipc	a5,0x9
      66:	38778793          	addi	a5,a5,903 # 93e9 <uninit+0x1>
      6a:	0000c697          	auipc	a3,0xc
      6e:	a8e68693          	addi	a3,a3,-1394 # baf8 <buf>
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
      8e:	eee50513          	addi	a0,a0,-274 # 5f78 <malloc+0x4d6>
      92:	00006097          	auipc	ra,0x6
      96:	950080e7          	jalr	-1712(ra) # 59e2 <printf>
      exit(1);
      9a:	4505                	li	a0,1
      9c:	00005097          	auipc	ra,0x5
      a0:	5c6080e7          	jalr	1478(ra) # 5662 <exit>

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
      b6:	ede50513          	addi	a0,a0,-290 # 5f90 <malloc+0x4ee>
      ba:	00005097          	auipc	ra,0x5
      be:	5e8080e7          	jalr	1512(ra) # 56a2 <open>
  if(fd < 0){
      c2:	02054663          	bltz	a0,ee <opentest+0x4a>
  close(fd);
      c6:	00005097          	auipc	ra,0x5
      ca:	5c4080e7          	jalr	1476(ra) # 568a <close>
  fd = open("doesnotexist", 0);
      ce:	4581                	li	a1,0
      d0:	00006517          	auipc	a0,0x6
      d4:	ee050513          	addi	a0,a0,-288 # 5fb0 <malloc+0x50e>
      d8:	00005097          	auipc	ra,0x5
      dc:	5ca080e7          	jalr	1482(ra) # 56a2 <open>
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
      f4:	ea850513          	addi	a0,a0,-344 # 5f98 <malloc+0x4f6>
      f8:	00006097          	auipc	ra,0x6
      fc:	8ea080e7          	jalr	-1814(ra) # 59e2 <printf>
    exit(1);
     100:	4505                	li	a0,1
     102:	00005097          	auipc	ra,0x5
     106:	560080e7          	jalr	1376(ra) # 5662 <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     10a:	85a6                	mv	a1,s1
     10c:	00006517          	auipc	a0,0x6
     110:	eb450513          	addi	a0,a0,-332 # 5fc0 <malloc+0x51e>
     114:	00006097          	auipc	ra,0x6
     118:	8ce080e7          	jalr	-1842(ra) # 59e2 <printf>
    exit(1);
     11c:	4505                	li	a0,1
     11e:	00005097          	auipc	ra,0x5
     122:	544080e7          	jalr	1348(ra) # 5662 <exit>

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
     13a:	eb250513          	addi	a0,a0,-334 # 5fe8 <malloc+0x546>
     13e:	00005097          	auipc	ra,0x5
     142:	574080e7          	jalr	1396(ra) # 56b2 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     146:	60100593          	li	a1,1537
     14a:	00006517          	auipc	a0,0x6
     14e:	e9e50513          	addi	a0,a0,-354 # 5fe8 <malloc+0x546>
     152:	00005097          	auipc	ra,0x5
     156:	550080e7          	jalr	1360(ra) # 56a2 <open>
     15a:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     15c:	4611                	li	a2,4
     15e:	00006597          	auipc	a1,0x6
     162:	e9a58593          	addi	a1,a1,-358 # 5ff8 <malloc+0x556>
     166:	00005097          	auipc	ra,0x5
     16a:	51c080e7          	jalr	1308(ra) # 5682 <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     16e:	40100593          	li	a1,1025
     172:	00006517          	auipc	a0,0x6
     176:	e7650513          	addi	a0,a0,-394 # 5fe8 <malloc+0x546>
     17a:	00005097          	auipc	ra,0x5
     17e:	528080e7          	jalr	1320(ra) # 56a2 <open>
     182:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     184:	4605                	li	a2,1
     186:	00006597          	auipc	a1,0x6
     18a:	e7a58593          	addi	a1,a1,-390 # 6000 <malloc+0x55e>
     18e:	8526                	mv	a0,s1
     190:	00005097          	auipc	ra,0x5
     194:	4f2080e7          	jalr	1266(ra) # 5682 <write>
  if(n != -1){
     198:	57fd                	li	a5,-1
     19a:	02f51b63          	bne	a0,a5,1d0 <truncate2+0xaa>
  unlink("truncfile");
     19e:	00006517          	auipc	a0,0x6
     1a2:	e4a50513          	addi	a0,a0,-438 # 5fe8 <malloc+0x546>
     1a6:	00005097          	auipc	ra,0x5
     1aa:	50c080e7          	jalr	1292(ra) # 56b2 <unlink>
  close(fd1);
     1ae:	8526                	mv	a0,s1
     1b0:	00005097          	auipc	ra,0x5
     1b4:	4da080e7          	jalr	1242(ra) # 568a <close>
  close(fd2);
     1b8:	854a                	mv	a0,s2
     1ba:	00005097          	auipc	ra,0x5
     1be:	4d0080e7          	jalr	1232(ra) # 568a <close>
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
     1d8:	e3450513          	addi	a0,a0,-460 # 6008 <malloc+0x566>
     1dc:	00006097          	auipc	ra,0x6
     1e0:	806080e7          	jalr	-2042(ra) # 59e2 <printf>
    exit(1);
     1e4:	4505                	li	a0,1
     1e6:	00005097          	auipc	ra,0x5
     1ea:	47c080e7          	jalr	1148(ra) # 5662 <exit>

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
     21e:	488080e7          	jalr	1160(ra) # 56a2 <open>
    close(fd);
     222:	00005097          	auipc	ra,0x5
     226:	468080e7          	jalr	1128(ra) # 568a <close>
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
     254:	462080e7          	jalr	1122(ra) # 56b2 <unlink>
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
     28a:	daa50513          	addi	a0,a0,-598 # 6030 <malloc+0x58e>
     28e:	00005097          	auipc	ra,0x5
     292:	424080e7          	jalr	1060(ra) # 56b2 <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     296:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     29a:	00006a17          	auipc	s4,0x6
     29e:	d96a0a13          	addi	s4,s4,-618 # 6030 <malloc+0x58e>
      int cc = write(fd, buf, sz);
     2a2:	0000c997          	auipc	s3,0xc
     2a6:	85698993          	addi	s3,s3,-1962 # baf8 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2aa:	6b0d                	lui	s6,0x3
     2ac:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x145>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2b0:	20200593          	li	a1,514
     2b4:	8552                	mv	a0,s4
     2b6:	00005097          	auipc	ra,0x5
     2ba:	3ec080e7          	jalr	1004(ra) # 56a2 <open>
     2be:	892a                	mv	s2,a0
    if(fd < 0){
     2c0:	04054d63          	bltz	a0,31a <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2c4:	8626                	mv	a2,s1
     2c6:	85ce                	mv	a1,s3
     2c8:	00005097          	auipc	ra,0x5
     2cc:	3ba080e7          	jalr	954(ra) # 5682 <write>
     2d0:	8aaa                	mv	s5,a0
      if(cc != sz){
     2d2:	06a49463          	bne	s1,a0,33a <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2d6:	8626                	mv	a2,s1
     2d8:	85ce                	mv	a1,s3
     2da:	854a                	mv	a0,s2
     2dc:	00005097          	auipc	ra,0x5
     2e0:	3a6080e7          	jalr	934(ra) # 5682 <write>
      if(cc != sz){
     2e4:	04951963          	bne	a0,s1,336 <bigwrite+0xc8>
    close(fd);
     2e8:	854a                	mv	a0,s2
     2ea:	00005097          	auipc	ra,0x5
     2ee:	3a0080e7          	jalr	928(ra) # 568a <close>
    unlink("bigwrite");
     2f2:	8552                	mv	a0,s4
     2f4:	00005097          	auipc	ra,0x5
     2f8:	3be080e7          	jalr	958(ra) # 56b2 <unlink>
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
     320:	d2450513          	addi	a0,a0,-732 # 6040 <malloc+0x59e>
     324:	00005097          	auipc	ra,0x5
     328:	6be080e7          	jalr	1726(ra) # 59e2 <printf>
      exit(1);
     32c:	4505                	li	a0,1
     32e:	00005097          	auipc	ra,0x5
     332:	334080e7          	jalr	820(ra) # 5662 <exit>
     336:	84d6                	mv	s1,s5
      int cc = write(fd, buf, sz);
     338:	8aaa                	mv	s5,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     33a:	86d6                	mv	a3,s5
     33c:	8626                	mv	a2,s1
     33e:	85de                	mv	a1,s7
     340:	00006517          	auipc	a0,0x6
     344:	d2050513          	addi	a0,a0,-736 # 6060 <malloc+0x5be>
     348:	00005097          	auipc	ra,0x5
     34c:	69a080e7          	jalr	1690(ra) # 59e2 <printf>
        exit(1);
     350:	4505                	li	a0,1
     352:	00005097          	auipc	ra,0x5
     356:	310080e7          	jalr	784(ra) # 5662 <exit>

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
     386:	cf6a0a13          	addi	s4,s4,-778 # 6078 <malloc+0x5d6>
    uint64 addr = addrs[ai];
     38a:	0004b903          	ld	s2,0(s1)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     38e:	20100593          	li	a1,513
     392:	8552                	mv	a0,s4
     394:	00005097          	auipc	ra,0x5
     398:	30e080e7          	jalr	782(ra) # 56a2 <open>
     39c:	89aa                	mv	s3,a0
    if(fd < 0){
     39e:	08054763          	bltz	a0,42c <copyin+0xd2>
    int n = write(fd, (void*)addr, 8192);
     3a2:	6609                	lui	a2,0x2
     3a4:	85ca                	mv	a1,s2
     3a6:	00005097          	auipc	ra,0x5
     3aa:	2dc080e7          	jalr	732(ra) # 5682 <write>
    if(n >= 0){
     3ae:	08055c63          	bgez	a0,446 <copyin+0xec>
    close(fd);
     3b2:	854e                	mv	a0,s3
     3b4:	00005097          	auipc	ra,0x5
     3b8:	2d6080e7          	jalr	726(ra) # 568a <close>
    unlink("copyin1");
     3bc:	8552                	mv	a0,s4
     3be:	00005097          	auipc	ra,0x5
     3c2:	2f4080e7          	jalr	756(ra) # 56b2 <unlink>
    n = write(1, (char*)addr, 8192);
     3c6:	6609                	lui	a2,0x2
     3c8:	85ca                	mv	a1,s2
     3ca:	4505                	li	a0,1
     3cc:	00005097          	auipc	ra,0x5
     3d0:	2b6080e7          	jalr	694(ra) # 5682 <write>
    if(n > 0){
     3d4:	08a04863          	bgtz	a0,464 <copyin+0x10a>
    if(pipe(fds) < 0){
     3d8:	fa840513          	addi	a0,s0,-88
     3dc:	00005097          	auipc	ra,0x5
     3e0:	296080e7          	jalr	662(ra) # 5672 <pipe>
     3e4:	08054f63          	bltz	a0,482 <copyin+0x128>
    n = write(fds[1], (char*)addr, 8192);
     3e8:	6609                	lui	a2,0x2
     3ea:	85ca                	mv	a1,s2
     3ec:	fac42503          	lw	a0,-84(s0)
     3f0:	00005097          	auipc	ra,0x5
     3f4:	292080e7          	jalr	658(ra) # 5682 <write>
    if(n > 0){
     3f8:	0aa04263          	bgtz	a0,49c <copyin+0x142>
    close(fds[0]);
     3fc:	fa842503          	lw	a0,-88(s0)
     400:	00005097          	auipc	ra,0x5
     404:	28a080e7          	jalr	650(ra) # 568a <close>
    close(fds[1]);
     408:	fac42503          	lw	a0,-84(s0)
     40c:	00005097          	auipc	ra,0x5
     410:	27e080e7          	jalr	638(ra) # 568a <close>
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
     430:	c5450513          	addi	a0,a0,-940 # 6080 <malloc+0x5de>
     434:	00005097          	auipc	ra,0x5
     438:	5ae080e7          	jalr	1454(ra) # 59e2 <printf>
      exit(1);
     43c:	4505                	li	a0,1
     43e:	00005097          	auipc	ra,0x5
     442:	224080e7          	jalr	548(ra) # 5662 <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     446:	862a                	mv	a2,a0
     448:	85ca                	mv	a1,s2
     44a:	00006517          	auipc	a0,0x6
     44e:	c4e50513          	addi	a0,a0,-946 # 6098 <malloc+0x5f6>
     452:	00005097          	auipc	ra,0x5
     456:	590080e7          	jalr	1424(ra) # 59e2 <printf>
      exit(1);
     45a:	4505                	li	a0,1
     45c:	00005097          	auipc	ra,0x5
     460:	206080e7          	jalr	518(ra) # 5662 <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     464:	862a                	mv	a2,a0
     466:	85ca                	mv	a1,s2
     468:	00006517          	auipc	a0,0x6
     46c:	c6050513          	addi	a0,a0,-928 # 60c8 <malloc+0x626>
     470:	00005097          	auipc	ra,0x5
     474:	572080e7          	jalr	1394(ra) # 59e2 <printf>
      exit(1);
     478:	4505                	li	a0,1
     47a:	00005097          	auipc	ra,0x5
     47e:	1e8080e7          	jalr	488(ra) # 5662 <exit>
      printf("pipe() failed\n");
     482:	00006517          	auipc	a0,0x6
     486:	c7650513          	addi	a0,a0,-906 # 60f8 <malloc+0x656>
     48a:	00005097          	auipc	ra,0x5
     48e:	558080e7          	jalr	1368(ra) # 59e2 <printf>
      exit(1);
     492:	4505                	li	a0,1
     494:	00005097          	auipc	ra,0x5
     498:	1ce080e7          	jalr	462(ra) # 5662 <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     49c:	862a                	mv	a2,a0
     49e:	85ca                	mv	a1,s2
     4a0:	00006517          	auipc	a0,0x6
     4a4:	c6850513          	addi	a0,a0,-920 # 6108 <malloc+0x666>
     4a8:	00005097          	auipc	ra,0x5
     4ac:	53a080e7          	jalr	1338(ra) # 59e2 <printf>
      exit(1);
     4b0:	4505                	li	a0,1
     4b2:	00005097          	auipc	ra,0x5
     4b6:	1b0080e7          	jalr	432(ra) # 5662 <exit>

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
     4e8:	c54a0a13          	addi	s4,s4,-940 # 6138 <malloc+0x696>
    n = write(fds[1], "x", 1);
     4ec:	00006a97          	auipc	s5,0x6
     4f0:	b14a8a93          	addi	s5,s5,-1260 # 6000 <malloc+0x55e>
    uint64 addr = addrs[ai];
     4f4:	0004b983          	ld	s3,0(s1)
    int fd = open("README", 0);
     4f8:	4581                	li	a1,0
     4fa:	8552                	mv	a0,s4
     4fc:	00005097          	auipc	ra,0x5
     500:	1a6080e7          	jalr	422(ra) # 56a2 <open>
     504:	892a                	mv	s2,a0
    if(fd < 0){
     506:	08054563          	bltz	a0,590 <copyout+0xd6>
    int n = read(fd, (void*)addr, 8192);
     50a:	6609                	lui	a2,0x2
     50c:	85ce                	mv	a1,s3
     50e:	00005097          	auipc	ra,0x5
     512:	16c080e7          	jalr	364(ra) # 567a <read>
    if(n > 0){
     516:	08a04a63          	bgtz	a0,5aa <copyout+0xf0>
    close(fd);
     51a:	854a                	mv	a0,s2
     51c:	00005097          	auipc	ra,0x5
     520:	16e080e7          	jalr	366(ra) # 568a <close>
    if(pipe(fds) < 0){
     524:	fa840513          	addi	a0,s0,-88
     528:	00005097          	auipc	ra,0x5
     52c:	14a080e7          	jalr	330(ra) # 5672 <pipe>
     530:	08054c63          	bltz	a0,5c8 <copyout+0x10e>
    n = write(fds[1], "x", 1);
     534:	4605                	li	a2,1
     536:	85d6                	mv	a1,s5
     538:	fac42503          	lw	a0,-84(s0)
     53c:	00005097          	auipc	ra,0x5
     540:	146080e7          	jalr	326(ra) # 5682 <write>
    if(n != 1){
     544:	4785                	li	a5,1
     546:	08f51e63          	bne	a0,a5,5e2 <copyout+0x128>
    n = read(fds[0], (void*)addr, 8192);
     54a:	6609                	lui	a2,0x2
     54c:	85ce                	mv	a1,s3
     54e:	fa842503          	lw	a0,-88(s0)
     552:	00005097          	auipc	ra,0x5
     556:	128080e7          	jalr	296(ra) # 567a <read>
    if(n > 0){
     55a:	0aa04163          	bgtz	a0,5fc <copyout+0x142>
    close(fds[0]);
     55e:	fa842503          	lw	a0,-88(s0)
     562:	00005097          	auipc	ra,0x5
     566:	128080e7          	jalr	296(ra) # 568a <close>
    close(fds[1]);
     56a:	fac42503          	lw	a0,-84(s0)
     56e:	00005097          	auipc	ra,0x5
     572:	11c080e7          	jalr	284(ra) # 568a <close>
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
     594:	bb050513          	addi	a0,a0,-1104 # 6140 <malloc+0x69e>
     598:	00005097          	auipc	ra,0x5
     59c:	44a080e7          	jalr	1098(ra) # 59e2 <printf>
      exit(1);
     5a0:	4505                	li	a0,1
     5a2:	00005097          	auipc	ra,0x5
     5a6:	0c0080e7          	jalr	192(ra) # 5662 <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5aa:	862a                	mv	a2,a0
     5ac:	85ce                	mv	a1,s3
     5ae:	00006517          	auipc	a0,0x6
     5b2:	baa50513          	addi	a0,a0,-1110 # 6158 <malloc+0x6b6>
     5b6:	00005097          	auipc	ra,0x5
     5ba:	42c080e7          	jalr	1068(ra) # 59e2 <printf>
      exit(1);
     5be:	4505                	li	a0,1
     5c0:	00005097          	auipc	ra,0x5
     5c4:	0a2080e7          	jalr	162(ra) # 5662 <exit>
      printf("pipe() failed\n");
     5c8:	00006517          	auipc	a0,0x6
     5cc:	b3050513          	addi	a0,a0,-1232 # 60f8 <malloc+0x656>
     5d0:	00005097          	auipc	ra,0x5
     5d4:	412080e7          	jalr	1042(ra) # 59e2 <printf>
      exit(1);
     5d8:	4505                	li	a0,1
     5da:	00005097          	auipc	ra,0x5
     5de:	088080e7          	jalr	136(ra) # 5662 <exit>
      printf("pipe write failed\n");
     5e2:	00006517          	auipc	a0,0x6
     5e6:	ba650513          	addi	a0,a0,-1114 # 6188 <malloc+0x6e6>
     5ea:	00005097          	auipc	ra,0x5
     5ee:	3f8080e7          	jalr	1016(ra) # 59e2 <printf>
      exit(1);
     5f2:	4505                	li	a0,1
     5f4:	00005097          	auipc	ra,0x5
     5f8:	06e080e7          	jalr	110(ra) # 5662 <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5fc:	862a                	mv	a2,a0
     5fe:	85ce                	mv	a1,s3
     600:	00006517          	auipc	a0,0x6
     604:	ba050513          	addi	a0,a0,-1120 # 61a0 <malloc+0x6fe>
     608:	00005097          	auipc	ra,0x5
     60c:	3da080e7          	jalr	986(ra) # 59e2 <printf>
      exit(1);
     610:	4505                	li	a0,1
     612:	00005097          	auipc	ra,0x5
     616:	050080e7          	jalr	80(ra) # 5662 <exit>

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
     632:	9ba50513          	addi	a0,a0,-1606 # 5fe8 <malloc+0x546>
     636:	00005097          	auipc	ra,0x5
     63a:	07c080e7          	jalr	124(ra) # 56b2 <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     63e:	60100593          	li	a1,1537
     642:	00006517          	auipc	a0,0x6
     646:	9a650513          	addi	a0,a0,-1626 # 5fe8 <malloc+0x546>
     64a:	00005097          	auipc	ra,0x5
     64e:	058080e7          	jalr	88(ra) # 56a2 <open>
     652:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     654:	4611                	li	a2,4
     656:	00006597          	auipc	a1,0x6
     65a:	9a258593          	addi	a1,a1,-1630 # 5ff8 <malloc+0x556>
     65e:	00005097          	auipc	ra,0x5
     662:	024080e7          	jalr	36(ra) # 5682 <write>
  close(fd1);
     666:	8526                	mv	a0,s1
     668:	00005097          	auipc	ra,0x5
     66c:	022080e7          	jalr	34(ra) # 568a <close>
  int fd2 = open("truncfile", O_RDONLY);
     670:	4581                	li	a1,0
     672:	00006517          	auipc	a0,0x6
     676:	97650513          	addi	a0,a0,-1674 # 5fe8 <malloc+0x546>
     67a:	00005097          	auipc	ra,0x5
     67e:	028080e7          	jalr	40(ra) # 56a2 <open>
     682:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     684:	02000613          	li	a2,32
     688:	fa040593          	addi	a1,s0,-96
     68c:	00005097          	auipc	ra,0x5
     690:	fee080e7          	jalr	-18(ra) # 567a <read>
  if(n != 4){
     694:	4791                	li	a5,4
     696:	0cf51e63          	bne	a0,a5,772 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     69a:	40100593          	li	a1,1025
     69e:	00006517          	auipc	a0,0x6
     6a2:	94a50513          	addi	a0,a0,-1718 # 5fe8 <malloc+0x546>
     6a6:	00005097          	auipc	ra,0x5
     6aa:	ffc080e7          	jalr	-4(ra) # 56a2 <open>
     6ae:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6b0:	4581                	li	a1,0
     6b2:	00006517          	auipc	a0,0x6
     6b6:	93650513          	addi	a0,a0,-1738 # 5fe8 <malloc+0x546>
     6ba:	00005097          	auipc	ra,0x5
     6be:	fe8080e7          	jalr	-24(ra) # 56a2 <open>
     6c2:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6c4:	02000613          	li	a2,32
     6c8:	fa040593          	addi	a1,s0,-96
     6cc:	00005097          	auipc	ra,0x5
     6d0:	fae080e7          	jalr	-82(ra) # 567a <read>
     6d4:	8a2a                	mv	s4,a0
  if(n != 0){
     6d6:	ed4d                	bnez	a0,790 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6d8:	02000613          	li	a2,32
     6dc:	fa040593          	addi	a1,s0,-96
     6e0:	8526                	mv	a0,s1
     6e2:	00005097          	auipc	ra,0x5
     6e6:	f98080e7          	jalr	-104(ra) # 567a <read>
     6ea:	8a2a                	mv	s4,a0
  if(n != 0){
     6ec:	e971                	bnez	a0,7c0 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     6ee:	4619                	li	a2,6
     6f0:	00006597          	auipc	a1,0x6
     6f4:	b4058593          	addi	a1,a1,-1216 # 6230 <malloc+0x78e>
     6f8:	854e                	mv	a0,s3
     6fa:	00005097          	auipc	ra,0x5
     6fe:	f88080e7          	jalr	-120(ra) # 5682 <write>
  n = read(fd3, buf, sizeof(buf));
     702:	02000613          	li	a2,32
     706:	fa040593          	addi	a1,s0,-96
     70a:	854a                	mv	a0,s2
     70c:	00005097          	auipc	ra,0x5
     710:	f6e080e7          	jalr	-146(ra) # 567a <read>
  if(n != 6){
     714:	4799                	li	a5,6
     716:	0cf51d63          	bne	a0,a5,7f0 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     71a:	02000613          	li	a2,32
     71e:	fa040593          	addi	a1,s0,-96
     722:	8526                	mv	a0,s1
     724:	00005097          	auipc	ra,0x5
     728:	f56080e7          	jalr	-170(ra) # 567a <read>
  if(n != 2){
     72c:	4789                	li	a5,2
     72e:	0ef51063          	bne	a0,a5,80e <truncate1+0x1f4>
  unlink("truncfile");
     732:	00006517          	auipc	a0,0x6
     736:	8b650513          	addi	a0,a0,-1866 # 5fe8 <malloc+0x546>
     73a:	00005097          	auipc	ra,0x5
     73e:	f78080e7          	jalr	-136(ra) # 56b2 <unlink>
  close(fd1);
     742:	854e                	mv	a0,s3
     744:	00005097          	auipc	ra,0x5
     748:	f46080e7          	jalr	-186(ra) # 568a <close>
  close(fd2);
     74c:	8526                	mv	a0,s1
     74e:	00005097          	auipc	ra,0x5
     752:	f3c080e7          	jalr	-196(ra) # 568a <close>
  close(fd3);
     756:	854a                	mv	a0,s2
     758:	00005097          	auipc	ra,0x5
     75c:	f32080e7          	jalr	-206(ra) # 568a <close>
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
     77a:	a5a50513          	addi	a0,a0,-1446 # 61d0 <malloc+0x72e>
     77e:	00005097          	auipc	ra,0x5
     782:	264080e7          	jalr	612(ra) # 59e2 <printf>
    exit(1);
     786:	4505                	li	a0,1
     788:	00005097          	auipc	ra,0x5
     78c:	eda080e7          	jalr	-294(ra) # 5662 <exit>
    printf("aaa fd3=%d\n", fd3);
     790:	85ca                	mv	a1,s2
     792:	00006517          	auipc	a0,0x6
     796:	a5e50513          	addi	a0,a0,-1442 # 61f0 <malloc+0x74e>
     79a:	00005097          	auipc	ra,0x5
     79e:	248080e7          	jalr	584(ra) # 59e2 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7a2:	8652                	mv	a2,s4
     7a4:	85d6                	mv	a1,s5
     7a6:	00006517          	auipc	a0,0x6
     7aa:	a5a50513          	addi	a0,a0,-1446 # 6200 <malloc+0x75e>
     7ae:	00005097          	auipc	ra,0x5
     7b2:	234080e7          	jalr	564(ra) # 59e2 <printf>
    exit(1);
     7b6:	4505                	li	a0,1
     7b8:	00005097          	auipc	ra,0x5
     7bc:	eaa080e7          	jalr	-342(ra) # 5662 <exit>
    printf("bbb fd2=%d\n", fd2);
     7c0:	85a6                	mv	a1,s1
     7c2:	00006517          	auipc	a0,0x6
     7c6:	a5e50513          	addi	a0,a0,-1442 # 6220 <malloc+0x77e>
     7ca:	00005097          	auipc	ra,0x5
     7ce:	218080e7          	jalr	536(ra) # 59e2 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7d2:	8652                	mv	a2,s4
     7d4:	85d6                	mv	a1,s5
     7d6:	00006517          	auipc	a0,0x6
     7da:	a2a50513          	addi	a0,a0,-1494 # 6200 <malloc+0x75e>
     7de:	00005097          	auipc	ra,0x5
     7e2:	204080e7          	jalr	516(ra) # 59e2 <printf>
    exit(1);
     7e6:	4505                	li	a0,1
     7e8:	00005097          	auipc	ra,0x5
     7ec:	e7a080e7          	jalr	-390(ra) # 5662 <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     7f0:	862a                	mv	a2,a0
     7f2:	85d6                	mv	a1,s5
     7f4:	00006517          	auipc	a0,0x6
     7f8:	a4450513          	addi	a0,a0,-1468 # 6238 <malloc+0x796>
     7fc:	00005097          	auipc	ra,0x5
     800:	1e6080e7          	jalr	486(ra) # 59e2 <printf>
    exit(1);
     804:	4505                	li	a0,1
     806:	00005097          	auipc	ra,0x5
     80a:	e5c080e7          	jalr	-420(ra) # 5662 <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     80e:	862a                	mv	a2,a0
     810:	85d6                	mv	a1,s5
     812:	00006517          	auipc	a0,0x6
     816:	a4650513          	addi	a0,a0,-1466 # 6258 <malloc+0x7b6>
     81a:	00005097          	auipc	ra,0x5
     81e:	1c8080e7          	jalr	456(ra) # 59e2 <printf>
    exit(1);
     822:	4505                	li	a0,1
     824:	00005097          	auipc	ra,0x5
     828:	e3e080e7          	jalr	-450(ra) # 5662 <exit>

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
     84a:	a3250513          	addi	a0,a0,-1486 # 6278 <malloc+0x7d6>
     84e:	00005097          	auipc	ra,0x5
     852:	e54080e7          	jalr	-428(ra) # 56a2 <open>
  if(fd < 0){
     856:	0a054d63          	bltz	a0,910 <writetest+0xe4>
     85a:	892a                	mv	s2,a0
     85c:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     85e:	00006997          	auipc	s3,0x6
     862:	a4298993          	addi	s3,s3,-1470 # 62a0 <malloc+0x7fe>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     866:	00006a97          	auipc	s5,0x6
     86a:	a72a8a93          	addi	s5,s5,-1422 # 62d8 <malloc+0x836>
  for(i = 0; i < N; i++){
     86e:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     872:	4629                	li	a2,10
     874:	85ce                	mv	a1,s3
     876:	854a                	mv	a0,s2
     878:	00005097          	auipc	ra,0x5
     87c:	e0a080e7          	jalr	-502(ra) # 5682 <write>
     880:	47a9                	li	a5,10
     882:	0af51563          	bne	a0,a5,92c <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     886:	4629                	li	a2,10
     888:	85d6                	mv	a1,s5
     88a:	854a                	mv	a0,s2
     88c:	00005097          	auipc	ra,0x5
     890:	df6080e7          	jalr	-522(ra) # 5682 <write>
     894:	47a9                	li	a5,10
     896:	0af51a63          	bne	a0,a5,94a <writetest+0x11e>
  for(i = 0; i < N; i++){
     89a:	2485                	addiw	s1,s1,1
     89c:	fd449be3          	bne	s1,s4,872 <writetest+0x46>
  close(fd);
     8a0:	854a                	mv	a0,s2
     8a2:	00005097          	auipc	ra,0x5
     8a6:	de8080e7          	jalr	-536(ra) # 568a <close>
  fd = open("small", O_RDONLY);
     8aa:	4581                	li	a1,0
     8ac:	00006517          	auipc	a0,0x6
     8b0:	9cc50513          	addi	a0,a0,-1588 # 6278 <malloc+0x7d6>
     8b4:	00005097          	auipc	ra,0x5
     8b8:	dee080e7          	jalr	-530(ra) # 56a2 <open>
     8bc:	84aa                	mv	s1,a0
  if(fd < 0){
     8be:	0a054563          	bltz	a0,968 <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8c2:	7d000613          	li	a2,2000
     8c6:	0000b597          	auipc	a1,0xb
     8ca:	23258593          	addi	a1,a1,562 # baf8 <buf>
     8ce:	00005097          	auipc	ra,0x5
     8d2:	dac080e7          	jalr	-596(ra) # 567a <read>
  if(i != N*SZ*2){
     8d6:	7d000793          	li	a5,2000
     8da:	0af51563          	bne	a0,a5,984 <writetest+0x158>
  close(fd);
     8de:	8526                	mv	a0,s1
     8e0:	00005097          	auipc	ra,0x5
     8e4:	daa080e7          	jalr	-598(ra) # 568a <close>
  if(unlink("small") < 0){
     8e8:	00006517          	auipc	a0,0x6
     8ec:	99050513          	addi	a0,a0,-1648 # 6278 <malloc+0x7d6>
     8f0:	00005097          	auipc	ra,0x5
     8f4:	dc2080e7          	jalr	-574(ra) # 56b2 <unlink>
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
     916:	96e50513          	addi	a0,a0,-1682 # 6280 <malloc+0x7de>
     91a:	00005097          	auipc	ra,0x5
     91e:	0c8080e7          	jalr	200(ra) # 59e2 <printf>
    exit(1);
     922:	4505                	li	a0,1
     924:	00005097          	auipc	ra,0x5
     928:	d3e080e7          	jalr	-706(ra) # 5662 <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     92c:	8626                	mv	a2,s1
     92e:	85da                	mv	a1,s6
     930:	00006517          	auipc	a0,0x6
     934:	98050513          	addi	a0,a0,-1664 # 62b0 <malloc+0x80e>
     938:	00005097          	auipc	ra,0x5
     93c:	0aa080e7          	jalr	170(ra) # 59e2 <printf>
      exit(1);
     940:	4505                	li	a0,1
     942:	00005097          	auipc	ra,0x5
     946:	d20080e7          	jalr	-736(ra) # 5662 <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     94a:	8626                	mv	a2,s1
     94c:	85da                	mv	a1,s6
     94e:	00006517          	auipc	a0,0x6
     952:	99a50513          	addi	a0,a0,-1638 # 62e8 <malloc+0x846>
     956:	00005097          	auipc	ra,0x5
     95a:	08c080e7          	jalr	140(ra) # 59e2 <printf>
      exit(1);
     95e:	4505                	li	a0,1
     960:	00005097          	auipc	ra,0x5
     964:	d02080e7          	jalr	-766(ra) # 5662 <exit>
    printf("%s: error: open small failed!\n", s);
     968:	85da                	mv	a1,s6
     96a:	00006517          	auipc	a0,0x6
     96e:	9a650513          	addi	a0,a0,-1626 # 6310 <malloc+0x86e>
     972:	00005097          	auipc	ra,0x5
     976:	070080e7          	jalr	112(ra) # 59e2 <printf>
    exit(1);
     97a:	4505                	li	a0,1
     97c:	00005097          	auipc	ra,0x5
     980:	ce6080e7          	jalr	-794(ra) # 5662 <exit>
    printf("%s: read failed\n", s);
     984:	85da                	mv	a1,s6
     986:	00006517          	auipc	a0,0x6
     98a:	9aa50513          	addi	a0,a0,-1622 # 6330 <malloc+0x88e>
     98e:	00005097          	auipc	ra,0x5
     992:	054080e7          	jalr	84(ra) # 59e2 <printf>
    exit(1);
     996:	4505                	li	a0,1
     998:	00005097          	auipc	ra,0x5
     99c:	cca080e7          	jalr	-822(ra) # 5662 <exit>
    printf("%s: unlink small failed\n", s);
     9a0:	85da                	mv	a1,s6
     9a2:	00006517          	auipc	a0,0x6
     9a6:	9a650513          	addi	a0,a0,-1626 # 6348 <malloc+0x8a6>
     9aa:	00005097          	auipc	ra,0x5
     9ae:	038080e7          	jalr	56(ra) # 59e2 <printf>
    exit(1);
     9b2:	4505                	li	a0,1
     9b4:	00005097          	auipc	ra,0x5
     9b8:	cae080e7          	jalr	-850(ra) # 5662 <exit>

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
     9d8:	99450513          	addi	a0,a0,-1644 # 6368 <malloc+0x8c6>
     9dc:	00005097          	auipc	ra,0x5
     9e0:	cc6080e7          	jalr	-826(ra) # 56a2 <open>
  if(fd < 0){
     9e4:	08054563          	bltz	a0,a6e <writebig+0xb2>
     9e8:	89aa                	mv	s3,a0
     9ea:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9ec:	0000b917          	auipc	s2,0xb
     9f0:	10c90913          	addi	s2,s2,268 # baf8 <buf>
  for(i = 0; i < MAXFILE; i++){
     9f4:	6a41                	lui	s4,0x10
     9f6:	10ba0a13          	addi	s4,s4,267 # 1010b <_end+0x1603>
    ((int*)buf)[0] = i;
     9fa:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     9fe:	40000613          	li	a2,1024
     a02:	85ca                	mv	a1,s2
     a04:	854e                	mv	a0,s3
     a06:	00005097          	auipc	ra,0x5
     a0a:	c7c080e7          	jalr	-900(ra) # 5682 <write>
     a0e:	40000793          	li	a5,1024
     a12:	06f51c63          	bne	a0,a5,a8a <writebig+0xce>
  for(i = 0; i < MAXFILE; i++){
     a16:	2485                	addiw	s1,s1,1
     a18:	ff4491e3          	bne	s1,s4,9fa <writebig+0x3e>
  close(fd);
     a1c:	854e                	mv	a0,s3
     a1e:	00005097          	auipc	ra,0x5
     a22:	c6c080e7          	jalr	-916(ra) # 568a <close>
  fd = open("big", O_RDONLY);
     a26:	4581                	li	a1,0
     a28:	00006517          	auipc	a0,0x6
     a2c:	94050513          	addi	a0,a0,-1728 # 6368 <malloc+0x8c6>
     a30:	00005097          	auipc	ra,0x5
     a34:	c72080e7          	jalr	-910(ra) # 56a2 <open>
     a38:	89aa                	mv	s3,a0
  n = 0;
     a3a:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a3c:	0000b917          	auipc	s2,0xb
     a40:	0bc90913          	addi	s2,s2,188 # baf8 <buf>
  if(fd < 0){
     a44:	06054263          	bltz	a0,aa8 <writebig+0xec>
    i = read(fd, buf, BSIZE);
     a48:	40000613          	li	a2,1024
     a4c:	85ca                	mv	a1,s2
     a4e:	854e                	mv	a0,s3
     a50:	00005097          	auipc	ra,0x5
     a54:	c2a080e7          	jalr	-982(ra) # 567a <read>
    if(i == 0){
     a58:	c535                	beqz	a0,ac4 <writebig+0x108>
    } else if(i != BSIZE){
     a5a:	40000793          	li	a5,1024
     a5e:	0af51f63          	bne	a0,a5,b1c <writebig+0x160>
    if(((int*)buf)[0] != n){
     a62:	00092683          	lw	a3,0(s2)
     a66:	0c969a63          	bne	a3,s1,b3a <writebig+0x17e>
    n++;
     a6a:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a6c:	bff1                	j	a48 <writebig+0x8c>
    printf("%s: error: creat big failed!\n", s);
     a6e:	85d6                	mv	a1,s5
     a70:	00006517          	auipc	a0,0x6
     a74:	90050513          	addi	a0,a0,-1792 # 6370 <malloc+0x8ce>
     a78:	00005097          	auipc	ra,0x5
     a7c:	f6a080e7          	jalr	-150(ra) # 59e2 <printf>
    exit(1);
     a80:	4505                	li	a0,1
     a82:	00005097          	auipc	ra,0x5
     a86:	be0080e7          	jalr	-1056(ra) # 5662 <exit>
      printf("%s: error: write big file failed\n", s, i);
     a8a:	8626                	mv	a2,s1
     a8c:	85d6                	mv	a1,s5
     a8e:	00006517          	auipc	a0,0x6
     a92:	90250513          	addi	a0,a0,-1790 # 6390 <malloc+0x8ee>
     a96:	00005097          	auipc	ra,0x5
     a9a:	f4c080e7          	jalr	-180(ra) # 59e2 <printf>
      exit(1);
     a9e:	4505                	li	a0,1
     aa0:	00005097          	auipc	ra,0x5
     aa4:	bc2080e7          	jalr	-1086(ra) # 5662 <exit>
    printf("%s: error: open big failed!\n", s);
     aa8:	85d6                	mv	a1,s5
     aaa:	00006517          	auipc	a0,0x6
     aae:	90e50513          	addi	a0,a0,-1778 # 63b8 <malloc+0x916>
     ab2:	00005097          	auipc	ra,0x5
     ab6:	f30080e7          	jalr	-208(ra) # 59e2 <printf>
    exit(1);
     aba:	4505                	li	a0,1
     abc:	00005097          	auipc	ra,0x5
     ac0:	ba6080e7          	jalr	-1114(ra) # 5662 <exit>
      if(n == MAXFILE - 1){
     ac4:	67c1                	lui	a5,0x10
     ac6:	10a78793          	addi	a5,a5,266 # 1010a <_end+0x1602>
     aca:	02f48a63          	beq	s1,a5,afe <writebig+0x142>
  close(fd);
     ace:	854e                	mv	a0,s3
     ad0:	00005097          	auipc	ra,0x5
     ad4:	bba080e7          	jalr	-1094(ra) # 568a <close>
  if(unlink("big") < 0){
     ad8:	00006517          	auipc	a0,0x6
     adc:	89050513          	addi	a0,a0,-1904 # 6368 <malloc+0x8c6>
     ae0:	00005097          	auipc	ra,0x5
     ae4:	bd2080e7          	jalr	-1070(ra) # 56b2 <unlink>
     ae8:	06054863          	bltz	a0,b58 <writebig+0x19c>
}
     aec:	70e2                	ld	ra,56(sp)
     aee:	7442                	ld	s0,48(sp)
     af0:	74a2                	ld	s1,40(sp)
     af2:	7902                	ld	s2,32(sp)
     af4:	69e2                	ld	s3,24(sp)
     af6:	6a42                	ld	s4,16(sp)
     af8:	6aa2                	ld	s5,8(sp)
     afa:	6121                	addi	sp,sp,64
     afc:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     afe:	863e                	mv	a2,a5
     b00:	85d6                	mv	a1,s5
     b02:	00006517          	auipc	a0,0x6
     b06:	8d650513          	addi	a0,a0,-1834 # 63d8 <malloc+0x936>
     b0a:	00005097          	auipc	ra,0x5
     b0e:	ed8080e7          	jalr	-296(ra) # 59e2 <printf>
        exit(1);
     b12:	4505                	li	a0,1
     b14:	00005097          	auipc	ra,0x5
     b18:	b4e080e7          	jalr	-1202(ra) # 5662 <exit>
      printf("%s: read failed %d\n", s, i);
     b1c:	862a                	mv	a2,a0
     b1e:	85d6                	mv	a1,s5
     b20:	00006517          	auipc	a0,0x6
     b24:	8e050513          	addi	a0,a0,-1824 # 6400 <malloc+0x95e>
     b28:	00005097          	auipc	ra,0x5
     b2c:	eba080e7          	jalr	-326(ra) # 59e2 <printf>
      exit(1);
     b30:	4505                	li	a0,1
     b32:	00005097          	auipc	ra,0x5
     b36:	b30080e7          	jalr	-1232(ra) # 5662 <exit>
      printf("%s: read content of block %d is %d\n", s,
     b3a:	8626                	mv	a2,s1
     b3c:	85d6                	mv	a1,s5
     b3e:	00006517          	auipc	a0,0x6
     b42:	8da50513          	addi	a0,a0,-1830 # 6418 <malloc+0x976>
     b46:	00005097          	auipc	ra,0x5
     b4a:	e9c080e7          	jalr	-356(ra) # 59e2 <printf>
      exit(1);
     b4e:	4505                	li	a0,1
     b50:	00005097          	auipc	ra,0x5
     b54:	b12080e7          	jalr	-1262(ra) # 5662 <exit>
    printf("%s: unlink big failed\n", s);
     b58:	85d6                	mv	a1,s5
     b5a:	00006517          	auipc	a0,0x6
     b5e:	8e650513          	addi	a0,a0,-1818 # 6440 <malloc+0x99e>
     b62:	00005097          	auipc	ra,0x5
     b66:	e80080e7          	jalr	-384(ra) # 59e2 <printf>
    exit(1);
     b6a:	4505                	li	a0,1
     b6c:	00005097          	auipc	ra,0x5
     b70:	af6080e7          	jalr	-1290(ra) # 5662 <exit>

0000000000000b74 <unlinkread>:
{
     b74:	7179                	addi	sp,sp,-48
     b76:	f406                	sd	ra,40(sp)
     b78:	f022                	sd	s0,32(sp)
     b7a:	ec26                	sd	s1,24(sp)
     b7c:	e84a                	sd	s2,16(sp)
     b7e:	e44e                	sd	s3,8(sp)
     b80:	1800                	addi	s0,sp,48
     b82:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b84:	20200593          	li	a1,514
     b88:	00006517          	auipc	a0,0x6
     b8c:	8d050513          	addi	a0,a0,-1840 # 6458 <malloc+0x9b6>
     b90:	00005097          	auipc	ra,0x5
     b94:	b12080e7          	jalr	-1262(ra) # 56a2 <open>
  if(fd < 0){
     b98:	0e054563          	bltz	a0,c82 <unlinkread+0x10e>
     b9c:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     b9e:	4615                	li	a2,5
     ba0:	00006597          	auipc	a1,0x6
     ba4:	8e858593          	addi	a1,a1,-1816 # 6488 <malloc+0x9e6>
     ba8:	00005097          	auipc	ra,0x5
     bac:	ada080e7          	jalr	-1318(ra) # 5682 <write>
  close(fd);
     bb0:	8526                	mv	a0,s1
     bb2:	00005097          	auipc	ra,0x5
     bb6:	ad8080e7          	jalr	-1320(ra) # 568a <close>
  fd = open("unlinkread", O_RDWR);
     bba:	4589                	li	a1,2
     bbc:	00006517          	auipc	a0,0x6
     bc0:	89c50513          	addi	a0,a0,-1892 # 6458 <malloc+0x9b6>
     bc4:	00005097          	auipc	ra,0x5
     bc8:	ade080e7          	jalr	-1314(ra) # 56a2 <open>
     bcc:	84aa                	mv	s1,a0
  if(fd < 0){
     bce:	0c054863          	bltz	a0,c9e <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bd2:	00006517          	auipc	a0,0x6
     bd6:	88650513          	addi	a0,a0,-1914 # 6458 <malloc+0x9b6>
     bda:	00005097          	auipc	ra,0x5
     bde:	ad8080e7          	jalr	-1320(ra) # 56b2 <unlink>
     be2:	ed61                	bnez	a0,cba <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     be4:	20200593          	li	a1,514
     be8:	00006517          	auipc	a0,0x6
     bec:	87050513          	addi	a0,a0,-1936 # 6458 <malloc+0x9b6>
     bf0:	00005097          	auipc	ra,0x5
     bf4:	ab2080e7          	jalr	-1358(ra) # 56a2 <open>
     bf8:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     bfa:	460d                	li	a2,3
     bfc:	00006597          	auipc	a1,0x6
     c00:	8d458593          	addi	a1,a1,-1836 # 64d0 <malloc+0xa2e>
     c04:	00005097          	auipc	ra,0x5
     c08:	a7e080e7          	jalr	-1410(ra) # 5682 <write>
  close(fd1);
     c0c:	854a                	mv	a0,s2
     c0e:	00005097          	auipc	ra,0x5
     c12:	a7c080e7          	jalr	-1412(ra) # 568a <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c16:	660d                	lui	a2,0x3
     c18:	0000b597          	auipc	a1,0xb
     c1c:	ee058593          	addi	a1,a1,-288 # baf8 <buf>
     c20:	8526                	mv	a0,s1
     c22:	00005097          	auipc	ra,0x5
     c26:	a58080e7          	jalr	-1448(ra) # 567a <read>
     c2a:	4795                	li	a5,5
     c2c:	0af51563          	bne	a0,a5,cd6 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c30:	0000b717          	auipc	a4,0xb
     c34:	ec874703          	lbu	a4,-312(a4) # baf8 <buf>
     c38:	06800793          	li	a5,104
     c3c:	0af71b63          	bne	a4,a5,cf2 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c40:	4629                	li	a2,10
     c42:	0000b597          	auipc	a1,0xb
     c46:	eb658593          	addi	a1,a1,-330 # baf8 <buf>
     c4a:	8526                	mv	a0,s1
     c4c:	00005097          	auipc	ra,0x5
     c50:	a36080e7          	jalr	-1482(ra) # 5682 <write>
     c54:	47a9                	li	a5,10
     c56:	0af51c63          	bne	a0,a5,d0e <unlinkread+0x19a>
  close(fd);
     c5a:	8526                	mv	a0,s1
     c5c:	00005097          	auipc	ra,0x5
     c60:	a2e080e7          	jalr	-1490(ra) # 568a <close>
  unlink("unlinkread");
     c64:	00005517          	auipc	a0,0x5
     c68:	7f450513          	addi	a0,a0,2036 # 6458 <malloc+0x9b6>
     c6c:	00005097          	auipc	ra,0x5
     c70:	a46080e7          	jalr	-1466(ra) # 56b2 <unlink>
}
     c74:	70a2                	ld	ra,40(sp)
     c76:	7402                	ld	s0,32(sp)
     c78:	64e2                	ld	s1,24(sp)
     c7a:	6942                	ld	s2,16(sp)
     c7c:	69a2                	ld	s3,8(sp)
     c7e:	6145                	addi	sp,sp,48
     c80:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c82:	85ce                	mv	a1,s3
     c84:	00005517          	auipc	a0,0x5
     c88:	7e450513          	addi	a0,a0,2020 # 6468 <malloc+0x9c6>
     c8c:	00005097          	auipc	ra,0x5
     c90:	d56080e7          	jalr	-682(ra) # 59e2 <printf>
    exit(1);
     c94:	4505                	li	a0,1
     c96:	00005097          	auipc	ra,0x5
     c9a:	9cc080e7          	jalr	-1588(ra) # 5662 <exit>
    printf("%s: open unlinkread failed\n", s);
     c9e:	85ce                	mv	a1,s3
     ca0:	00005517          	auipc	a0,0x5
     ca4:	7f050513          	addi	a0,a0,2032 # 6490 <malloc+0x9ee>
     ca8:	00005097          	auipc	ra,0x5
     cac:	d3a080e7          	jalr	-710(ra) # 59e2 <printf>
    exit(1);
     cb0:	4505                	li	a0,1
     cb2:	00005097          	auipc	ra,0x5
     cb6:	9b0080e7          	jalr	-1616(ra) # 5662 <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cba:	85ce                	mv	a1,s3
     cbc:	00005517          	auipc	a0,0x5
     cc0:	7f450513          	addi	a0,a0,2036 # 64b0 <malloc+0xa0e>
     cc4:	00005097          	auipc	ra,0x5
     cc8:	d1e080e7          	jalr	-738(ra) # 59e2 <printf>
    exit(1);
     ccc:	4505                	li	a0,1
     cce:	00005097          	auipc	ra,0x5
     cd2:	994080e7          	jalr	-1644(ra) # 5662 <exit>
    printf("%s: unlinkread read failed", s);
     cd6:	85ce                	mv	a1,s3
     cd8:	00006517          	auipc	a0,0x6
     cdc:	80050513          	addi	a0,a0,-2048 # 64d8 <malloc+0xa36>
     ce0:	00005097          	auipc	ra,0x5
     ce4:	d02080e7          	jalr	-766(ra) # 59e2 <printf>
    exit(1);
     ce8:	4505                	li	a0,1
     cea:	00005097          	auipc	ra,0x5
     cee:	978080e7          	jalr	-1672(ra) # 5662 <exit>
    printf("%s: unlinkread wrong data\n", s);
     cf2:	85ce                	mv	a1,s3
     cf4:	00006517          	auipc	a0,0x6
     cf8:	80450513          	addi	a0,a0,-2044 # 64f8 <malloc+0xa56>
     cfc:	00005097          	auipc	ra,0x5
     d00:	ce6080e7          	jalr	-794(ra) # 59e2 <printf>
    exit(1);
     d04:	4505                	li	a0,1
     d06:	00005097          	auipc	ra,0x5
     d0a:	95c080e7          	jalr	-1700(ra) # 5662 <exit>
    printf("%s: unlinkread write failed\n", s);
     d0e:	85ce                	mv	a1,s3
     d10:	00006517          	auipc	a0,0x6
     d14:	80850513          	addi	a0,a0,-2040 # 6518 <malloc+0xa76>
     d18:	00005097          	auipc	ra,0x5
     d1c:	cca080e7          	jalr	-822(ra) # 59e2 <printf>
    exit(1);
     d20:	4505                	li	a0,1
     d22:	00005097          	auipc	ra,0x5
     d26:	940080e7          	jalr	-1728(ra) # 5662 <exit>

0000000000000d2a <linktest>:
{
     d2a:	1101                	addi	sp,sp,-32
     d2c:	ec06                	sd	ra,24(sp)
     d2e:	e822                	sd	s0,16(sp)
     d30:	e426                	sd	s1,8(sp)
     d32:	e04a                	sd	s2,0(sp)
     d34:	1000                	addi	s0,sp,32
     d36:	892a                	mv	s2,a0
  unlink("lf1");
     d38:	00006517          	auipc	a0,0x6
     d3c:	80050513          	addi	a0,a0,-2048 # 6538 <malloc+0xa96>
     d40:	00005097          	auipc	ra,0x5
     d44:	972080e7          	jalr	-1678(ra) # 56b2 <unlink>
  unlink("lf2");
     d48:	00005517          	auipc	a0,0x5
     d4c:	7f850513          	addi	a0,a0,2040 # 6540 <malloc+0xa9e>
     d50:	00005097          	auipc	ra,0x5
     d54:	962080e7          	jalr	-1694(ra) # 56b2 <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d58:	20200593          	li	a1,514
     d5c:	00005517          	auipc	a0,0x5
     d60:	7dc50513          	addi	a0,a0,2012 # 6538 <malloc+0xa96>
     d64:	00005097          	auipc	ra,0x5
     d68:	93e080e7          	jalr	-1730(ra) # 56a2 <open>
  if(fd < 0){
     d6c:	10054763          	bltz	a0,e7a <linktest+0x150>
     d70:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d72:	4615                	li	a2,5
     d74:	00005597          	auipc	a1,0x5
     d78:	71458593          	addi	a1,a1,1812 # 6488 <malloc+0x9e6>
     d7c:	00005097          	auipc	ra,0x5
     d80:	906080e7          	jalr	-1786(ra) # 5682 <write>
     d84:	4795                	li	a5,5
     d86:	10f51863          	bne	a0,a5,e96 <linktest+0x16c>
  close(fd);
     d8a:	8526                	mv	a0,s1
     d8c:	00005097          	auipc	ra,0x5
     d90:	8fe080e7          	jalr	-1794(ra) # 568a <close>
  if(link("lf1", "lf2") < 0){
     d94:	00005597          	auipc	a1,0x5
     d98:	7ac58593          	addi	a1,a1,1964 # 6540 <malloc+0xa9e>
     d9c:	00005517          	auipc	a0,0x5
     da0:	79c50513          	addi	a0,a0,1948 # 6538 <malloc+0xa96>
     da4:	00005097          	auipc	ra,0x5
     da8:	91e080e7          	jalr	-1762(ra) # 56c2 <link>
     dac:	10054363          	bltz	a0,eb2 <linktest+0x188>
  unlink("lf1");
     db0:	00005517          	auipc	a0,0x5
     db4:	78850513          	addi	a0,a0,1928 # 6538 <malloc+0xa96>
     db8:	00005097          	auipc	ra,0x5
     dbc:	8fa080e7          	jalr	-1798(ra) # 56b2 <unlink>
  if(open("lf1", 0) >= 0){
     dc0:	4581                	li	a1,0
     dc2:	00005517          	auipc	a0,0x5
     dc6:	77650513          	addi	a0,a0,1910 # 6538 <malloc+0xa96>
     dca:	00005097          	auipc	ra,0x5
     dce:	8d8080e7          	jalr	-1832(ra) # 56a2 <open>
     dd2:	0e055e63          	bgez	a0,ece <linktest+0x1a4>
  fd = open("lf2", 0);
     dd6:	4581                	li	a1,0
     dd8:	00005517          	auipc	a0,0x5
     ddc:	76850513          	addi	a0,a0,1896 # 6540 <malloc+0xa9e>
     de0:	00005097          	auipc	ra,0x5
     de4:	8c2080e7          	jalr	-1854(ra) # 56a2 <open>
     de8:	84aa                	mv	s1,a0
  if(fd < 0){
     dea:	10054063          	bltz	a0,eea <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     dee:	660d                	lui	a2,0x3
     df0:	0000b597          	auipc	a1,0xb
     df4:	d0858593          	addi	a1,a1,-760 # baf8 <buf>
     df8:	00005097          	auipc	ra,0x5
     dfc:	882080e7          	jalr	-1918(ra) # 567a <read>
     e00:	4795                	li	a5,5
     e02:	10f51263          	bne	a0,a5,f06 <linktest+0x1dc>
  close(fd);
     e06:	8526                	mv	a0,s1
     e08:	00005097          	auipc	ra,0x5
     e0c:	882080e7          	jalr	-1918(ra) # 568a <close>
  if(link("lf2", "lf2") >= 0){
     e10:	00005597          	auipc	a1,0x5
     e14:	73058593          	addi	a1,a1,1840 # 6540 <malloc+0xa9e>
     e18:	852e                	mv	a0,a1
     e1a:	00005097          	auipc	ra,0x5
     e1e:	8a8080e7          	jalr	-1880(ra) # 56c2 <link>
     e22:	10055063          	bgez	a0,f22 <linktest+0x1f8>
  unlink("lf2");
     e26:	00005517          	auipc	a0,0x5
     e2a:	71a50513          	addi	a0,a0,1818 # 6540 <malloc+0xa9e>
     e2e:	00005097          	auipc	ra,0x5
     e32:	884080e7          	jalr	-1916(ra) # 56b2 <unlink>
  if(link("lf2", "lf1") >= 0){
     e36:	00005597          	auipc	a1,0x5
     e3a:	70258593          	addi	a1,a1,1794 # 6538 <malloc+0xa96>
     e3e:	00005517          	auipc	a0,0x5
     e42:	70250513          	addi	a0,a0,1794 # 6540 <malloc+0xa9e>
     e46:	00005097          	auipc	ra,0x5
     e4a:	87c080e7          	jalr	-1924(ra) # 56c2 <link>
     e4e:	0e055863          	bgez	a0,f3e <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e52:	00005597          	auipc	a1,0x5
     e56:	6e658593          	addi	a1,a1,1766 # 6538 <malloc+0xa96>
     e5a:	00005517          	auipc	a0,0x5
     e5e:	7ee50513          	addi	a0,a0,2030 # 6648 <malloc+0xba6>
     e62:	00005097          	auipc	ra,0x5
     e66:	860080e7          	jalr	-1952(ra) # 56c2 <link>
     e6a:	0e055863          	bgez	a0,f5a <linktest+0x230>
}
     e6e:	60e2                	ld	ra,24(sp)
     e70:	6442                	ld	s0,16(sp)
     e72:	64a2                	ld	s1,8(sp)
     e74:	6902                	ld	s2,0(sp)
     e76:	6105                	addi	sp,sp,32
     e78:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e7a:	85ca                	mv	a1,s2
     e7c:	00005517          	auipc	a0,0x5
     e80:	6cc50513          	addi	a0,a0,1740 # 6548 <malloc+0xaa6>
     e84:	00005097          	auipc	ra,0x5
     e88:	b5e080e7          	jalr	-1186(ra) # 59e2 <printf>
    exit(1);
     e8c:	4505                	li	a0,1
     e8e:	00004097          	auipc	ra,0x4
     e92:	7d4080e7          	jalr	2004(ra) # 5662 <exit>
    printf("%s: write lf1 failed\n", s);
     e96:	85ca                	mv	a1,s2
     e98:	00005517          	auipc	a0,0x5
     e9c:	6c850513          	addi	a0,a0,1736 # 6560 <malloc+0xabe>
     ea0:	00005097          	auipc	ra,0x5
     ea4:	b42080e7          	jalr	-1214(ra) # 59e2 <printf>
    exit(1);
     ea8:	4505                	li	a0,1
     eaa:	00004097          	auipc	ra,0x4
     eae:	7b8080e7          	jalr	1976(ra) # 5662 <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     eb2:	85ca                	mv	a1,s2
     eb4:	00005517          	auipc	a0,0x5
     eb8:	6c450513          	addi	a0,a0,1732 # 6578 <malloc+0xad6>
     ebc:	00005097          	auipc	ra,0x5
     ec0:	b26080e7          	jalr	-1242(ra) # 59e2 <printf>
    exit(1);
     ec4:	4505                	li	a0,1
     ec6:	00004097          	auipc	ra,0x4
     eca:	79c080e7          	jalr	1948(ra) # 5662 <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ece:	85ca                	mv	a1,s2
     ed0:	00005517          	auipc	a0,0x5
     ed4:	6c850513          	addi	a0,a0,1736 # 6598 <malloc+0xaf6>
     ed8:	00005097          	auipc	ra,0x5
     edc:	b0a080e7          	jalr	-1270(ra) # 59e2 <printf>
    exit(1);
     ee0:	4505                	li	a0,1
     ee2:	00004097          	auipc	ra,0x4
     ee6:	780080e7          	jalr	1920(ra) # 5662 <exit>
    printf("%s: open lf2 failed\n", s);
     eea:	85ca                	mv	a1,s2
     eec:	00005517          	auipc	a0,0x5
     ef0:	6dc50513          	addi	a0,a0,1756 # 65c8 <malloc+0xb26>
     ef4:	00005097          	auipc	ra,0x5
     ef8:	aee080e7          	jalr	-1298(ra) # 59e2 <printf>
    exit(1);
     efc:	4505                	li	a0,1
     efe:	00004097          	auipc	ra,0x4
     f02:	764080e7          	jalr	1892(ra) # 5662 <exit>
    printf("%s: read lf2 failed\n", s);
     f06:	85ca                	mv	a1,s2
     f08:	00005517          	auipc	a0,0x5
     f0c:	6d850513          	addi	a0,a0,1752 # 65e0 <malloc+0xb3e>
     f10:	00005097          	auipc	ra,0x5
     f14:	ad2080e7          	jalr	-1326(ra) # 59e2 <printf>
    exit(1);
     f18:	4505                	li	a0,1
     f1a:	00004097          	auipc	ra,0x4
     f1e:	748080e7          	jalr	1864(ra) # 5662 <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f22:	85ca                	mv	a1,s2
     f24:	00005517          	auipc	a0,0x5
     f28:	6d450513          	addi	a0,a0,1748 # 65f8 <malloc+0xb56>
     f2c:	00005097          	auipc	ra,0x5
     f30:	ab6080e7          	jalr	-1354(ra) # 59e2 <printf>
    exit(1);
     f34:	4505                	li	a0,1
     f36:	00004097          	auipc	ra,0x4
     f3a:	72c080e7          	jalr	1836(ra) # 5662 <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f3e:	85ca                	mv	a1,s2
     f40:	00005517          	auipc	a0,0x5
     f44:	6e050513          	addi	a0,a0,1760 # 6620 <malloc+0xb7e>
     f48:	00005097          	auipc	ra,0x5
     f4c:	a9a080e7          	jalr	-1382(ra) # 59e2 <printf>
    exit(1);
     f50:	4505                	li	a0,1
     f52:	00004097          	auipc	ra,0x4
     f56:	710080e7          	jalr	1808(ra) # 5662 <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f5a:	85ca                	mv	a1,s2
     f5c:	00005517          	auipc	a0,0x5
     f60:	6f450513          	addi	a0,a0,1780 # 6650 <malloc+0xbae>
     f64:	00005097          	auipc	ra,0x5
     f68:	a7e080e7          	jalr	-1410(ra) # 59e2 <printf>
    exit(1);
     f6c:	4505                	li	a0,1
     f6e:	00004097          	auipc	ra,0x4
     f72:	6f4080e7          	jalr	1780(ra) # 5662 <exit>

0000000000000f76 <bigdir>:
{
     f76:	715d                	addi	sp,sp,-80
     f78:	e486                	sd	ra,72(sp)
     f7a:	e0a2                	sd	s0,64(sp)
     f7c:	fc26                	sd	s1,56(sp)
     f7e:	f84a                	sd	s2,48(sp)
     f80:	f44e                	sd	s3,40(sp)
     f82:	f052                	sd	s4,32(sp)
     f84:	ec56                	sd	s5,24(sp)
     f86:	e85a                	sd	s6,16(sp)
     f88:	0880                	addi	s0,sp,80
     f8a:	89aa                	mv	s3,a0
  unlink("bd");
     f8c:	00005517          	auipc	a0,0x5
     f90:	6e450513          	addi	a0,a0,1764 # 6670 <malloc+0xbce>
     f94:	00004097          	auipc	ra,0x4
     f98:	71e080e7          	jalr	1822(ra) # 56b2 <unlink>
  fd = open("bd", O_CREATE);
     f9c:	20000593          	li	a1,512
     fa0:	00005517          	auipc	a0,0x5
     fa4:	6d050513          	addi	a0,a0,1744 # 6670 <malloc+0xbce>
     fa8:	00004097          	auipc	ra,0x4
     fac:	6fa080e7          	jalr	1786(ra) # 56a2 <open>
  if(fd < 0){
     fb0:	0c054963          	bltz	a0,1082 <bigdir+0x10c>
  close(fd);
     fb4:	00004097          	auipc	ra,0x4
     fb8:	6d6080e7          	jalr	1750(ra) # 568a <close>
  for(i = 0; i < N; i++){
     fbc:	4901                	li	s2,0
    name[0] = 'x';
     fbe:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fc2:	00005a17          	auipc	s4,0x5
     fc6:	6aea0a13          	addi	s4,s4,1710 # 6670 <malloc+0xbce>
  for(i = 0; i < N; i++){
     fca:	1f400b13          	li	s6,500
    name[0] = 'x';
     fce:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fd2:	41f9579b          	sraiw	a5,s2,0x1f
     fd6:	01a7d71b          	srliw	a4,a5,0x1a
     fda:	012707bb          	addw	a5,a4,s2
     fde:	4067d69b          	sraiw	a3,a5,0x6
     fe2:	0306869b          	addiw	a3,a3,48
     fe6:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     fea:	03f7f793          	andi	a5,a5,63
     fee:	9f99                	subw	a5,a5,a4
     ff0:	0307879b          	addiw	a5,a5,48
     ff4:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     ff8:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
     ffc:	fb040593          	addi	a1,s0,-80
    1000:	8552                	mv	a0,s4
    1002:	00004097          	auipc	ra,0x4
    1006:	6c0080e7          	jalr	1728(ra) # 56c2 <link>
    100a:	84aa                	mv	s1,a0
    100c:	e949                	bnez	a0,109e <bigdir+0x128>
  for(i = 0; i < N; i++){
    100e:	2905                	addiw	s2,s2,1
    1010:	fb691fe3          	bne	s2,s6,fce <bigdir+0x58>
  unlink("bd");
    1014:	00005517          	auipc	a0,0x5
    1018:	65c50513          	addi	a0,a0,1628 # 6670 <malloc+0xbce>
    101c:	00004097          	auipc	ra,0x4
    1020:	696080e7          	jalr	1686(ra) # 56b2 <unlink>
    name[0] = 'x';
    1024:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    1028:	1f400a13          	li	s4,500
    name[0] = 'x';
    102c:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1030:	41f4d79b          	sraiw	a5,s1,0x1f
    1034:	01a7d71b          	srliw	a4,a5,0x1a
    1038:	009707bb          	addw	a5,a4,s1
    103c:	4067d69b          	sraiw	a3,a5,0x6
    1040:	0306869b          	addiw	a3,a3,48
    1044:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    1048:	03f7f793          	andi	a5,a5,63
    104c:	9f99                	subw	a5,a5,a4
    104e:	0307879b          	addiw	a5,a5,48
    1052:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1056:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    105a:	fb040513          	addi	a0,s0,-80
    105e:	00004097          	auipc	ra,0x4
    1062:	654080e7          	jalr	1620(ra) # 56b2 <unlink>
    1066:	ed21                	bnez	a0,10be <bigdir+0x148>
  for(i = 0; i < N; i++){
    1068:	2485                	addiw	s1,s1,1
    106a:	fd4491e3          	bne	s1,s4,102c <bigdir+0xb6>
}
    106e:	60a6                	ld	ra,72(sp)
    1070:	6406                	ld	s0,64(sp)
    1072:	74e2                	ld	s1,56(sp)
    1074:	7942                	ld	s2,48(sp)
    1076:	79a2                	ld	s3,40(sp)
    1078:	7a02                	ld	s4,32(sp)
    107a:	6ae2                	ld	s5,24(sp)
    107c:	6b42                	ld	s6,16(sp)
    107e:	6161                	addi	sp,sp,80
    1080:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1082:	85ce                	mv	a1,s3
    1084:	00005517          	auipc	a0,0x5
    1088:	5f450513          	addi	a0,a0,1524 # 6678 <malloc+0xbd6>
    108c:	00005097          	auipc	ra,0x5
    1090:	956080e7          	jalr	-1706(ra) # 59e2 <printf>
    exit(1);
    1094:	4505                	li	a0,1
    1096:	00004097          	auipc	ra,0x4
    109a:	5cc080e7          	jalr	1484(ra) # 5662 <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    109e:	fb040613          	addi	a2,s0,-80
    10a2:	85ce                	mv	a1,s3
    10a4:	00005517          	auipc	a0,0x5
    10a8:	5f450513          	addi	a0,a0,1524 # 6698 <malloc+0xbf6>
    10ac:	00005097          	auipc	ra,0x5
    10b0:	936080e7          	jalr	-1738(ra) # 59e2 <printf>
      exit(1);
    10b4:	4505                	li	a0,1
    10b6:	00004097          	auipc	ra,0x4
    10ba:	5ac080e7          	jalr	1452(ra) # 5662 <exit>
      printf("%s: bigdir unlink failed", s);
    10be:	85ce                	mv	a1,s3
    10c0:	00005517          	auipc	a0,0x5
    10c4:	5f850513          	addi	a0,a0,1528 # 66b8 <malloc+0xc16>
    10c8:	00005097          	auipc	ra,0x5
    10cc:	91a080e7          	jalr	-1766(ra) # 59e2 <printf>
      exit(1);
    10d0:	4505                	li	a0,1
    10d2:	00004097          	auipc	ra,0x4
    10d6:	590080e7          	jalr	1424(ra) # 5662 <exit>

00000000000010da <validatetest>:
{
    10da:	7139                	addi	sp,sp,-64
    10dc:	fc06                	sd	ra,56(sp)
    10de:	f822                	sd	s0,48(sp)
    10e0:	f426                	sd	s1,40(sp)
    10e2:	f04a                	sd	s2,32(sp)
    10e4:	ec4e                	sd	s3,24(sp)
    10e6:	e852                	sd	s4,16(sp)
    10e8:	e456                	sd	s5,8(sp)
    10ea:	e05a                	sd	s6,0(sp)
    10ec:	0080                	addi	s0,sp,64
    10ee:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f0:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10f2:	00005997          	auipc	s3,0x5
    10f6:	5e698993          	addi	s3,s3,1510 # 66d8 <malloc+0xc36>
    10fa:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10fc:	6a85                	lui	s5,0x1
    10fe:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1102:	85a6                	mv	a1,s1
    1104:	854e                	mv	a0,s3
    1106:	00004097          	auipc	ra,0x4
    110a:	5bc080e7          	jalr	1468(ra) # 56c2 <link>
    110e:	01251f63          	bne	a0,s2,112c <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1112:	94d6                	add	s1,s1,s5
    1114:	ff4497e3          	bne	s1,s4,1102 <validatetest+0x28>
}
    1118:	70e2                	ld	ra,56(sp)
    111a:	7442                	ld	s0,48(sp)
    111c:	74a2                	ld	s1,40(sp)
    111e:	7902                	ld	s2,32(sp)
    1120:	69e2                	ld	s3,24(sp)
    1122:	6a42                	ld	s4,16(sp)
    1124:	6aa2                	ld	s5,8(sp)
    1126:	6b02                	ld	s6,0(sp)
    1128:	6121                	addi	sp,sp,64
    112a:	8082                	ret
      printf("%s: link should not succeed\n", s);
    112c:	85da                	mv	a1,s6
    112e:	00005517          	auipc	a0,0x5
    1132:	5ba50513          	addi	a0,a0,1466 # 66e8 <malloc+0xc46>
    1136:	00005097          	auipc	ra,0x5
    113a:	8ac080e7          	jalr	-1876(ra) # 59e2 <printf>
      exit(1);
    113e:	4505                	li	a0,1
    1140:	00004097          	auipc	ra,0x4
    1144:	522080e7          	jalr	1314(ra) # 5662 <exit>

0000000000001148 <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    1148:	7179                	addi	sp,sp,-48
    114a:	f406                	sd	ra,40(sp)
    114c:	f022                	sd	s0,32(sp)
    114e:	ec26                	sd	s1,24(sp)
    1150:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1152:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1156:	00007797          	auipc	a5,0x7
    115a:	17278793          	addi	a5,a5,370 # 82c8 <digits+0x20>
    115e:	6384                	ld	s1,0(a5)
    1160:	fd840593          	addi	a1,s0,-40
    1164:	8526                	mv	a0,s1
    1166:	00004097          	auipc	ra,0x4
    116a:	534080e7          	jalr	1332(ra) # 569a <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    116e:	8526                	mv	a0,s1
    1170:	00004097          	auipc	ra,0x4
    1174:	502080e7          	jalr	1282(ra) # 5672 <pipe>

  exit(0);
    1178:	4501                	li	a0,0
    117a:	00004097          	auipc	ra,0x4
    117e:	4e8080e7          	jalr	1256(ra) # 5662 <exit>

0000000000001182 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1182:	7139                	addi	sp,sp,-64
    1184:	fc06                	sd	ra,56(sp)
    1186:	f822                	sd	s0,48(sp)
    1188:	f426                	sd	s1,40(sp)
    118a:	f04a                	sd	s2,32(sp)
    118c:	ec4e                	sd	s3,24(sp)
    118e:	0080                	addi	s0,sp,64
    1190:	64b1                	lui	s1,0xc
    1192:	35048493          	addi	s1,s1,848 # c350 <buf+0x858>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    1196:	597d                	li	s2,-1
    1198:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    119c:	00005997          	auipc	s3,0x5
    11a0:	df498993          	addi	s3,s3,-524 # 5f90 <malloc+0x4ee>
    argv[0] = (char*)0xffffffff;
    11a4:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11a8:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11ac:	fc040593          	addi	a1,s0,-64
    11b0:	854e                	mv	a0,s3
    11b2:	00004097          	auipc	ra,0x4
    11b6:	4e8080e7          	jalr	1256(ra) # 569a <exec>
  for(int i = 0; i < 50000; i++){
    11ba:	34fd                	addiw	s1,s1,-1
    11bc:	f4e5                	bnez	s1,11a4 <badarg+0x22>
  }
  
  exit(0);
    11be:	4501                	li	a0,0
    11c0:	00004097          	auipc	ra,0x4
    11c4:	4a2080e7          	jalr	1186(ra) # 5662 <exit>

00000000000011c8 <copyinstr2>:
{
    11c8:	7155                	addi	sp,sp,-208
    11ca:	e586                	sd	ra,200(sp)
    11cc:	e1a2                	sd	s0,192(sp)
    11ce:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11d0:	f6840793          	addi	a5,s0,-152
    11d4:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11d8:	07800713          	li	a4,120
    11dc:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11e0:	0785                	addi	a5,a5,1
    11e2:	fed79de3          	bne	a5,a3,11dc <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11e6:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11ea:	f6840513          	addi	a0,s0,-152
    11ee:	00004097          	auipc	ra,0x4
    11f2:	4c4080e7          	jalr	1220(ra) # 56b2 <unlink>
  if(ret != -1){
    11f6:	57fd                	li	a5,-1
    11f8:	0ef51063          	bne	a0,a5,12d8 <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    11fc:	20100593          	li	a1,513
    1200:	f6840513          	addi	a0,s0,-152
    1204:	00004097          	auipc	ra,0x4
    1208:	49e080e7          	jalr	1182(ra) # 56a2 <open>
  if(fd != -1){
    120c:	57fd                	li	a5,-1
    120e:	0ef51563          	bne	a0,a5,12f8 <copyinstr2+0x130>
  ret = link(b, b);
    1212:	f6840593          	addi	a1,s0,-152
    1216:	852e                	mv	a0,a1
    1218:	00004097          	auipc	ra,0x4
    121c:	4aa080e7          	jalr	1194(ra) # 56c2 <link>
  if(ret != -1){
    1220:	57fd                	li	a5,-1
    1222:	0ef51b63          	bne	a0,a5,1318 <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1226:	00006797          	auipc	a5,0x6
    122a:	6a278793          	addi	a5,a5,1698 # 78c8 <malloc+0x1e26>
    122e:	f4f43c23          	sd	a5,-168(s0)
    1232:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1236:	f5840593          	addi	a1,s0,-168
    123a:	f6840513          	addi	a0,s0,-152
    123e:	00004097          	auipc	ra,0x4
    1242:	45c080e7          	jalr	1116(ra) # 569a <exec>
  if(ret != -1){
    1246:	57fd                	li	a5,-1
    1248:	0ef51963          	bne	a0,a5,133a <copyinstr2+0x172>
  int pid = fork();
    124c:	00004097          	auipc	ra,0x4
    1250:	40e080e7          	jalr	1038(ra) # 565a <fork>
  if(pid < 0){
    1254:	10054363          	bltz	a0,135a <copyinstr2+0x192>
  if(pid == 0){
    1258:	12051463          	bnez	a0,1380 <copyinstr2+0x1b8>
    125c:	00007797          	auipc	a5,0x7
    1260:	18478793          	addi	a5,a5,388 # 83e0 <big.1287>
    1264:	00008697          	auipc	a3,0x8
    1268:	17c68693          	addi	a3,a3,380 # 93e0 <__global_pointer$+0x918>
      big[i] = 'x';
    126c:	07800713          	li	a4,120
    1270:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1274:	0785                	addi	a5,a5,1
    1276:	fed79de3          	bne	a5,a3,1270 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    127a:	00008797          	auipc	a5,0x8
    127e:	16078323          	sb	zero,358(a5) # 93e0 <__global_pointer$+0x918>
    char *args2[] = { big, big, big, 0 };
    1282:	00005797          	auipc	a5,0x5
    1286:	90678793          	addi	a5,a5,-1786 # 5b88 <malloc+0xe6>
    128a:	6390                	ld	a2,0(a5)
    128c:	6794                	ld	a3,8(a5)
    128e:	6b98                	ld	a4,16(a5)
    1290:	6f9c                	ld	a5,24(a5)
    1292:	f2c43823          	sd	a2,-208(s0)
    1296:	f2d43c23          	sd	a3,-200(s0)
    129a:	f4e43023          	sd	a4,-192(s0)
    129e:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12a2:	f3040593          	addi	a1,s0,-208
    12a6:	00005517          	auipc	a0,0x5
    12aa:	cea50513          	addi	a0,a0,-790 # 5f90 <malloc+0x4ee>
    12ae:	00004097          	auipc	ra,0x4
    12b2:	3ec080e7          	jalr	1004(ra) # 569a <exec>
    if(ret != -1){
    12b6:	57fd                	li	a5,-1
    12b8:	0af50e63          	beq	a0,a5,1374 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12bc:	55fd                	li	a1,-1
    12be:	00005517          	auipc	a0,0x5
    12c2:	4d250513          	addi	a0,a0,1234 # 6790 <malloc+0xcee>
    12c6:	00004097          	auipc	ra,0x4
    12ca:	71c080e7          	jalr	1820(ra) # 59e2 <printf>
      exit(1);
    12ce:	4505                	li	a0,1
    12d0:	00004097          	auipc	ra,0x4
    12d4:	392080e7          	jalr	914(ra) # 5662 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12d8:	862a                	mv	a2,a0
    12da:	f6840593          	addi	a1,s0,-152
    12de:	00005517          	auipc	a0,0x5
    12e2:	42a50513          	addi	a0,a0,1066 # 6708 <malloc+0xc66>
    12e6:	00004097          	auipc	ra,0x4
    12ea:	6fc080e7          	jalr	1788(ra) # 59e2 <printf>
    exit(1);
    12ee:	4505                	li	a0,1
    12f0:	00004097          	auipc	ra,0x4
    12f4:	372080e7          	jalr	882(ra) # 5662 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12f8:	862a                	mv	a2,a0
    12fa:	f6840593          	addi	a1,s0,-152
    12fe:	00005517          	auipc	a0,0x5
    1302:	42a50513          	addi	a0,a0,1066 # 6728 <malloc+0xc86>
    1306:	00004097          	auipc	ra,0x4
    130a:	6dc080e7          	jalr	1756(ra) # 59e2 <printf>
    exit(1);
    130e:	4505                	li	a0,1
    1310:	00004097          	auipc	ra,0x4
    1314:	352080e7          	jalr	850(ra) # 5662 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    1318:	86aa                	mv	a3,a0
    131a:	f6840613          	addi	a2,s0,-152
    131e:	85b2                	mv	a1,a2
    1320:	00005517          	auipc	a0,0x5
    1324:	42850513          	addi	a0,a0,1064 # 6748 <malloc+0xca6>
    1328:	00004097          	auipc	ra,0x4
    132c:	6ba080e7          	jalr	1722(ra) # 59e2 <printf>
    exit(1);
    1330:	4505                	li	a0,1
    1332:	00004097          	auipc	ra,0x4
    1336:	330080e7          	jalr	816(ra) # 5662 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    133a:	567d                	li	a2,-1
    133c:	f6840593          	addi	a1,s0,-152
    1340:	00005517          	auipc	a0,0x5
    1344:	43050513          	addi	a0,a0,1072 # 6770 <malloc+0xcce>
    1348:	00004097          	auipc	ra,0x4
    134c:	69a080e7          	jalr	1690(ra) # 59e2 <printf>
    exit(1);
    1350:	4505                	li	a0,1
    1352:	00004097          	auipc	ra,0x4
    1356:	310080e7          	jalr	784(ra) # 5662 <exit>
    printf("fork failed\n");
    135a:	00006517          	auipc	a0,0x6
    135e:	89650513          	addi	a0,a0,-1898 # 6bf0 <malloc+0x114e>
    1362:	00004097          	auipc	ra,0x4
    1366:	680080e7          	jalr	1664(ra) # 59e2 <printf>
    exit(1);
    136a:	4505                	li	a0,1
    136c:	00004097          	auipc	ra,0x4
    1370:	2f6080e7          	jalr	758(ra) # 5662 <exit>
    exit(747); // OK
    1374:	2eb00513          	li	a0,747
    1378:	00004097          	auipc	ra,0x4
    137c:	2ea080e7          	jalr	746(ra) # 5662 <exit>
  int st = 0;
    1380:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1384:	f5440513          	addi	a0,s0,-172
    1388:	00004097          	auipc	ra,0x4
    138c:	2e2080e7          	jalr	738(ra) # 566a <wait>
  if(st != 747){
    1390:	f5442703          	lw	a4,-172(s0)
    1394:	2eb00793          	li	a5,747
    1398:	00f71663          	bne	a4,a5,13a4 <copyinstr2+0x1dc>
}
    139c:	60ae                	ld	ra,200(sp)
    139e:	640e                	ld	s0,192(sp)
    13a0:	6169                	addi	sp,sp,208
    13a2:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13a4:	00005517          	auipc	a0,0x5
    13a8:	41450513          	addi	a0,a0,1044 # 67b8 <malloc+0xd16>
    13ac:	00004097          	auipc	ra,0x4
    13b0:	636080e7          	jalr	1590(ra) # 59e2 <printf>
    exit(1);
    13b4:	4505                	li	a0,1
    13b6:	00004097          	auipc	ra,0x4
    13ba:	2ac080e7          	jalr	684(ra) # 5662 <exit>

00000000000013be <truncate3>:
{
    13be:	7159                	addi	sp,sp,-112
    13c0:	f486                	sd	ra,104(sp)
    13c2:	f0a2                	sd	s0,96(sp)
    13c4:	eca6                	sd	s1,88(sp)
    13c6:	e8ca                	sd	s2,80(sp)
    13c8:	e4ce                	sd	s3,72(sp)
    13ca:	e0d2                	sd	s4,64(sp)
    13cc:	fc56                	sd	s5,56(sp)
    13ce:	1880                	addi	s0,sp,112
    13d0:	8a2a                	mv	s4,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13d2:	60100593          	li	a1,1537
    13d6:	00005517          	auipc	a0,0x5
    13da:	c1250513          	addi	a0,a0,-1006 # 5fe8 <malloc+0x546>
    13de:	00004097          	auipc	ra,0x4
    13e2:	2c4080e7          	jalr	708(ra) # 56a2 <open>
    13e6:	00004097          	auipc	ra,0x4
    13ea:	2a4080e7          	jalr	676(ra) # 568a <close>
  pid = fork();
    13ee:	00004097          	auipc	ra,0x4
    13f2:	26c080e7          	jalr	620(ra) # 565a <fork>
  if(pid < 0){
    13f6:	08054063          	bltz	a0,1476 <truncate3+0xb8>
  if(pid == 0){
    13fa:	e969                	bnez	a0,14cc <truncate3+0x10e>
    13fc:	06400913          	li	s2,100
      int fd = open("truncfile", O_WRONLY);
    1400:	00005997          	auipc	s3,0x5
    1404:	be898993          	addi	s3,s3,-1048 # 5fe8 <malloc+0x546>
      int n = write(fd, "1234567890", 10);
    1408:	00005a97          	auipc	s5,0x5
    140c:	410a8a93          	addi	s5,s5,1040 # 6818 <malloc+0xd76>
      int fd = open("truncfile", O_WRONLY);
    1410:	4585                	li	a1,1
    1412:	854e                	mv	a0,s3
    1414:	00004097          	auipc	ra,0x4
    1418:	28e080e7          	jalr	654(ra) # 56a2 <open>
    141c:	84aa                	mv	s1,a0
      if(fd < 0){
    141e:	06054a63          	bltz	a0,1492 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1422:	4629                	li	a2,10
    1424:	85d6                	mv	a1,s5
    1426:	00004097          	auipc	ra,0x4
    142a:	25c080e7          	jalr	604(ra) # 5682 <write>
      if(n != 10){
    142e:	47a9                	li	a5,10
    1430:	06f51f63          	bne	a0,a5,14ae <truncate3+0xf0>
      close(fd);
    1434:	8526                	mv	a0,s1
    1436:	00004097          	auipc	ra,0x4
    143a:	254080e7          	jalr	596(ra) # 568a <close>
      fd = open("truncfile", O_RDONLY);
    143e:	4581                	li	a1,0
    1440:	854e                	mv	a0,s3
    1442:	00004097          	auipc	ra,0x4
    1446:	260080e7          	jalr	608(ra) # 56a2 <open>
    144a:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    144c:	02000613          	li	a2,32
    1450:	f9840593          	addi	a1,s0,-104
    1454:	00004097          	auipc	ra,0x4
    1458:	226080e7          	jalr	550(ra) # 567a <read>
      close(fd);
    145c:	8526                	mv	a0,s1
    145e:	00004097          	auipc	ra,0x4
    1462:	22c080e7          	jalr	556(ra) # 568a <close>
    for(int i = 0; i < 100; i++){
    1466:	397d                	addiw	s2,s2,-1
    1468:	fa0914e3          	bnez	s2,1410 <truncate3+0x52>
    exit(0);
    146c:	4501                	li	a0,0
    146e:	00004097          	auipc	ra,0x4
    1472:	1f4080e7          	jalr	500(ra) # 5662 <exit>
    printf("%s: fork failed\n", s);
    1476:	85d2                	mv	a1,s4
    1478:	00005517          	auipc	a0,0x5
    147c:	37050513          	addi	a0,a0,880 # 67e8 <malloc+0xd46>
    1480:	00004097          	auipc	ra,0x4
    1484:	562080e7          	jalr	1378(ra) # 59e2 <printf>
    exit(1);
    1488:	4505                	li	a0,1
    148a:	00004097          	auipc	ra,0x4
    148e:	1d8080e7          	jalr	472(ra) # 5662 <exit>
        printf("%s: open failed\n", s);
    1492:	85d2                	mv	a1,s4
    1494:	00005517          	auipc	a0,0x5
    1498:	36c50513          	addi	a0,a0,876 # 6800 <malloc+0xd5e>
    149c:	00004097          	auipc	ra,0x4
    14a0:	546080e7          	jalr	1350(ra) # 59e2 <printf>
        exit(1);
    14a4:	4505                	li	a0,1
    14a6:	00004097          	auipc	ra,0x4
    14aa:	1bc080e7          	jalr	444(ra) # 5662 <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14ae:	862a                	mv	a2,a0
    14b0:	85d2                	mv	a1,s4
    14b2:	00005517          	auipc	a0,0x5
    14b6:	37650513          	addi	a0,a0,886 # 6828 <malloc+0xd86>
    14ba:	00004097          	auipc	ra,0x4
    14be:	528080e7          	jalr	1320(ra) # 59e2 <printf>
        exit(1);
    14c2:	4505                	li	a0,1
    14c4:	00004097          	auipc	ra,0x4
    14c8:	19e080e7          	jalr	414(ra) # 5662 <exit>
    14cc:	09600913          	li	s2,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14d0:	00005997          	auipc	s3,0x5
    14d4:	b1898993          	addi	s3,s3,-1256 # 5fe8 <malloc+0x546>
    int n = write(fd, "xxx", 3);
    14d8:	00005a97          	auipc	s5,0x5
    14dc:	370a8a93          	addi	s5,s5,880 # 6848 <malloc+0xda6>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14e0:	60100593          	li	a1,1537
    14e4:	854e                	mv	a0,s3
    14e6:	00004097          	auipc	ra,0x4
    14ea:	1bc080e7          	jalr	444(ra) # 56a2 <open>
    14ee:	84aa                	mv	s1,a0
    if(fd < 0){
    14f0:	04054763          	bltz	a0,153e <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14f4:	460d                	li	a2,3
    14f6:	85d6                	mv	a1,s5
    14f8:	00004097          	auipc	ra,0x4
    14fc:	18a080e7          	jalr	394(ra) # 5682 <write>
    if(n != 3){
    1500:	478d                	li	a5,3
    1502:	04f51c63          	bne	a0,a5,155a <truncate3+0x19c>
    close(fd);
    1506:	8526                	mv	a0,s1
    1508:	00004097          	auipc	ra,0x4
    150c:	182080e7          	jalr	386(ra) # 568a <close>
  for(int i = 0; i < 150; i++){
    1510:	397d                	addiw	s2,s2,-1
    1512:	fc0917e3          	bnez	s2,14e0 <truncate3+0x122>
  wait(&xstatus);
    1516:	fbc40513          	addi	a0,s0,-68
    151a:	00004097          	auipc	ra,0x4
    151e:	150080e7          	jalr	336(ra) # 566a <wait>
  unlink("truncfile");
    1522:	00005517          	auipc	a0,0x5
    1526:	ac650513          	addi	a0,a0,-1338 # 5fe8 <malloc+0x546>
    152a:	00004097          	auipc	ra,0x4
    152e:	188080e7          	jalr	392(ra) # 56b2 <unlink>
  exit(xstatus);
    1532:	fbc42503          	lw	a0,-68(s0)
    1536:	00004097          	auipc	ra,0x4
    153a:	12c080e7          	jalr	300(ra) # 5662 <exit>
      printf("%s: open failed\n", s);
    153e:	85d2                	mv	a1,s4
    1540:	00005517          	auipc	a0,0x5
    1544:	2c050513          	addi	a0,a0,704 # 6800 <malloc+0xd5e>
    1548:	00004097          	auipc	ra,0x4
    154c:	49a080e7          	jalr	1178(ra) # 59e2 <printf>
      exit(1);
    1550:	4505                	li	a0,1
    1552:	00004097          	auipc	ra,0x4
    1556:	110080e7          	jalr	272(ra) # 5662 <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    155a:	862a                	mv	a2,a0
    155c:	85d2                	mv	a1,s4
    155e:	00005517          	auipc	a0,0x5
    1562:	2f250513          	addi	a0,a0,754 # 6850 <malloc+0xdae>
    1566:	00004097          	auipc	ra,0x4
    156a:	47c080e7          	jalr	1148(ra) # 59e2 <printf>
      exit(1);
    156e:	4505                	li	a0,1
    1570:	00004097          	auipc	ra,0x4
    1574:	0f2080e7          	jalr	242(ra) # 5662 <exit>

0000000000001578 <exectest>:
{
    1578:	715d                	addi	sp,sp,-80
    157a:	e486                	sd	ra,72(sp)
    157c:	e0a2                	sd	s0,64(sp)
    157e:	fc26                	sd	s1,56(sp)
    1580:	f84a                	sd	s2,48(sp)
    1582:	0880                	addi	s0,sp,80
    1584:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1586:	00005797          	auipc	a5,0x5
    158a:	a0a78793          	addi	a5,a5,-1526 # 5f90 <malloc+0x4ee>
    158e:	fcf43023          	sd	a5,-64(s0)
    1592:	00005797          	auipc	a5,0x5
    1596:	2de78793          	addi	a5,a5,734 # 6870 <malloc+0xdce>
    159a:	fcf43423          	sd	a5,-56(s0)
    159e:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15a2:	00005517          	auipc	a0,0x5
    15a6:	2d650513          	addi	a0,a0,726 # 6878 <malloc+0xdd6>
    15aa:	00004097          	auipc	ra,0x4
    15ae:	108080e7          	jalr	264(ra) # 56b2 <unlink>
  pid = fork();
    15b2:	00004097          	auipc	ra,0x4
    15b6:	0a8080e7          	jalr	168(ra) # 565a <fork>
  if(pid < 0) {
    15ba:	04054663          	bltz	a0,1606 <exectest+0x8e>
    15be:	84aa                	mv	s1,a0
  if(pid == 0) {
    15c0:	e959                	bnez	a0,1656 <exectest+0xde>
    close(1);
    15c2:	4505                	li	a0,1
    15c4:	00004097          	auipc	ra,0x4
    15c8:	0c6080e7          	jalr	198(ra) # 568a <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15cc:	20100593          	li	a1,513
    15d0:	00005517          	auipc	a0,0x5
    15d4:	2a850513          	addi	a0,a0,680 # 6878 <malloc+0xdd6>
    15d8:	00004097          	auipc	ra,0x4
    15dc:	0ca080e7          	jalr	202(ra) # 56a2 <open>
    if(fd < 0) {
    15e0:	04054163          	bltz	a0,1622 <exectest+0xaa>
    if(fd != 1) {
    15e4:	4785                	li	a5,1
    15e6:	04f50c63          	beq	a0,a5,163e <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15ea:	85ca                	mv	a1,s2
    15ec:	00005517          	auipc	a0,0x5
    15f0:	2ac50513          	addi	a0,a0,684 # 6898 <malloc+0xdf6>
    15f4:	00004097          	auipc	ra,0x4
    15f8:	3ee080e7          	jalr	1006(ra) # 59e2 <printf>
      exit(1);
    15fc:	4505                	li	a0,1
    15fe:	00004097          	auipc	ra,0x4
    1602:	064080e7          	jalr	100(ra) # 5662 <exit>
     printf("%s: fork failed\n", s);
    1606:	85ca                	mv	a1,s2
    1608:	00005517          	auipc	a0,0x5
    160c:	1e050513          	addi	a0,a0,480 # 67e8 <malloc+0xd46>
    1610:	00004097          	auipc	ra,0x4
    1614:	3d2080e7          	jalr	978(ra) # 59e2 <printf>
     exit(1);
    1618:	4505                	li	a0,1
    161a:	00004097          	auipc	ra,0x4
    161e:	048080e7          	jalr	72(ra) # 5662 <exit>
      printf("%s: create failed\n", s);
    1622:	85ca                	mv	a1,s2
    1624:	00005517          	auipc	a0,0x5
    1628:	25c50513          	addi	a0,a0,604 # 6880 <malloc+0xdde>
    162c:	00004097          	auipc	ra,0x4
    1630:	3b6080e7          	jalr	950(ra) # 59e2 <printf>
      exit(1);
    1634:	4505                	li	a0,1
    1636:	00004097          	auipc	ra,0x4
    163a:	02c080e7          	jalr	44(ra) # 5662 <exit>
    if(exec("echo", echoargv) < 0){
    163e:	fc040593          	addi	a1,s0,-64
    1642:	00005517          	auipc	a0,0x5
    1646:	94e50513          	addi	a0,a0,-1714 # 5f90 <malloc+0x4ee>
    164a:	00004097          	auipc	ra,0x4
    164e:	050080e7          	jalr	80(ra) # 569a <exec>
    1652:	02054163          	bltz	a0,1674 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1656:	fdc40513          	addi	a0,s0,-36
    165a:	00004097          	auipc	ra,0x4
    165e:	010080e7          	jalr	16(ra) # 566a <wait>
    1662:	02951763          	bne	a0,s1,1690 <exectest+0x118>
  if(xstatus != 0)
    1666:	fdc42503          	lw	a0,-36(s0)
    166a:	cd0d                	beqz	a0,16a4 <exectest+0x12c>
    exit(xstatus);
    166c:	00004097          	auipc	ra,0x4
    1670:	ff6080e7          	jalr	-10(ra) # 5662 <exit>
      printf("%s: exec echo failed\n", s);
    1674:	85ca                	mv	a1,s2
    1676:	00005517          	auipc	a0,0x5
    167a:	23250513          	addi	a0,a0,562 # 68a8 <malloc+0xe06>
    167e:	00004097          	auipc	ra,0x4
    1682:	364080e7          	jalr	868(ra) # 59e2 <printf>
      exit(1);
    1686:	4505                	li	a0,1
    1688:	00004097          	auipc	ra,0x4
    168c:	fda080e7          	jalr	-38(ra) # 5662 <exit>
    printf("%s: wait failed!\n", s);
    1690:	85ca                	mv	a1,s2
    1692:	00005517          	auipc	a0,0x5
    1696:	22e50513          	addi	a0,a0,558 # 68c0 <malloc+0xe1e>
    169a:	00004097          	auipc	ra,0x4
    169e:	348080e7          	jalr	840(ra) # 59e2 <printf>
    16a2:	b7d1                	j	1666 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16a4:	4581                	li	a1,0
    16a6:	00005517          	auipc	a0,0x5
    16aa:	1d250513          	addi	a0,a0,466 # 6878 <malloc+0xdd6>
    16ae:	00004097          	auipc	ra,0x4
    16b2:	ff4080e7          	jalr	-12(ra) # 56a2 <open>
  if(fd < 0) {
    16b6:	02054a63          	bltz	a0,16ea <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16ba:	4609                	li	a2,2
    16bc:	fb840593          	addi	a1,s0,-72
    16c0:	00004097          	auipc	ra,0x4
    16c4:	fba080e7          	jalr	-70(ra) # 567a <read>
    16c8:	4789                	li	a5,2
    16ca:	02f50e63          	beq	a0,a5,1706 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16ce:	85ca                	mv	a1,s2
    16d0:	00005517          	auipc	a0,0x5
    16d4:	c6050513          	addi	a0,a0,-928 # 6330 <malloc+0x88e>
    16d8:	00004097          	auipc	ra,0x4
    16dc:	30a080e7          	jalr	778(ra) # 59e2 <printf>
    exit(1);
    16e0:	4505                	li	a0,1
    16e2:	00004097          	auipc	ra,0x4
    16e6:	f80080e7          	jalr	-128(ra) # 5662 <exit>
    printf("%s: open failed\n", s);
    16ea:	85ca                	mv	a1,s2
    16ec:	00005517          	auipc	a0,0x5
    16f0:	11450513          	addi	a0,a0,276 # 6800 <malloc+0xd5e>
    16f4:	00004097          	auipc	ra,0x4
    16f8:	2ee080e7          	jalr	750(ra) # 59e2 <printf>
    exit(1);
    16fc:	4505                	li	a0,1
    16fe:	00004097          	auipc	ra,0x4
    1702:	f64080e7          	jalr	-156(ra) # 5662 <exit>
  unlink("echo-ok");
    1706:	00005517          	auipc	a0,0x5
    170a:	17250513          	addi	a0,a0,370 # 6878 <malloc+0xdd6>
    170e:	00004097          	auipc	ra,0x4
    1712:	fa4080e7          	jalr	-92(ra) # 56b2 <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1716:	fb844703          	lbu	a4,-72(s0)
    171a:	04f00793          	li	a5,79
    171e:	00f71863          	bne	a4,a5,172e <exectest+0x1b6>
    1722:	fb944703          	lbu	a4,-71(s0)
    1726:	04b00793          	li	a5,75
    172a:	02f70063          	beq	a4,a5,174a <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    172e:	85ca                	mv	a1,s2
    1730:	00005517          	auipc	a0,0x5
    1734:	1a850513          	addi	a0,a0,424 # 68d8 <malloc+0xe36>
    1738:	00004097          	auipc	ra,0x4
    173c:	2aa080e7          	jalr	682(ra) # 59e2 <printf>
    exit(1);
    1740:	4505                	li	a0,1
    1742:	00004097          	auipc	ra,0x4
    1746:	f20080e7          	jalr	-224(ra) # 5662 <exit>
    exit(0);
    174a:	4501                	li	a0,0
    174c:	00004097          	auipc	ra,0x4
    1750:	f16080e7          	jalr	-234(ra) # 5662 <exit>

0000000000001754 <pipe1>:
{
    1754:	715d                	addi	sp,sp,-80
    1756:	e486                	sd	ra,72(sp)
    1758:	e0a2                	sd	s0,64(sp)
    175a:	fc26                	sd	s1,56(sp)
    175c:	f84a                	sd	s2,48(sp)
    175e:	f44e                	sd	s3,40(sp)
    1760:	f052                	sd	s4,32(sp)
    1762:	ec56                	sd	s5,24(sp)
    1764:	e85a                	sd	s6,16(sp)
    1766:	0880                	addi	s0,sp,80
    1768:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    176a:	fb840513          	addi	a0,s0,-72
    176e:	00004097          	auipc	ra,0x4
    1772:	f04080e7          	jalr	-252(ra) # 5672 <pipe>
    1776:	e935                	bnez	a0,17ea <pipe1+0x96>
    1778:	84aa                	mv	s1,a0
  pid = fork();
    177a:	00004097          	auipc	ra,0x4
    177e:	ee0080e7          	jalr	-288(ra) # 565a <fork>
  if(pid == 0){
    1782:	c151                	beqz	a0,1806 <pipe1+0xb2>
  } else if(pid > 0){
    1784:	18a05963          	blez	a0,1916 <pipe1+0x1c2>
    close(fds[1]);
    1788:	fbc42503          	lw	a0,-68(s0)
    178c:	00004097          	auipc	ra,0x4
    1790:	efe080e7          	jalr	-258(ra) # 568a <close>
    total = 0;
    1794:	8aa6                	mv	s5,s1
    cc = 1;
    1796:	4a05                	li	s4,1
    while((n = read(fds[0], buf, cc)) > 0){
    1798:	0000a917          	auipc	s2,0xa
    179c:	36090913          	addi	s2,s2,864 # baf8 <buf>
      if(cc > sizeof(buf))
    17a0:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17a2:	8652                	mv	a2,s4
    17a4:	85ca                	mv	a1,s2
    17a6:	fb842503          	lw	a0,-72(s0)
    17aa:	00004097          	auipc	ra,0x4
    17ae:	ed0080e7          	jalr	-304(ra) # 567a <read>
    17b2:	10a05d63          	blez	a0,18cc <pipe1+0x178>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17b6:	0014879b          	addiw	a5,s1,1
    17ba:	00094683          	lbu	a3,0(s2)
    17be:	0ff4f713          	andi	a4,s1,255
    17c2:	0ce69863          	bne	a3,a4,1892 <pipe1+0x13e>
    17c6:	0000a717          	auipc	a4,0xa
    17ca:	33370713          	addi	a4,a4,819 # baf9 <buf+0x1>
    17ce:	9ca9                	addw	s1,s1,a0
      for(i = 0; i < n; i++){
    17d0:	0e978463          	beq	a5,s1,18b8 <pipe1+0x164>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17d4:	00074683          	lbu	a3,0(a4)
    17d8:	0017861b          	addiw	a2,a5,1
    17dc:	0705                	addi	a4,a4,1
    17de:	0ff7f793          	andi	a5,a5,255
    17e2:	0af69863          	bne	a3,a5,1892 <pipe1+0x13e>
    17e6:	87b2                	mv	a5,a2
    17e8:	b7e5                	j	17d0 <pipe1+0x7c>
    printf("%s: pipe() failed\n", s);
    17ea:	85ce                	mv	a1,s3
    17ec:	00005517          	auipc	a0,0x5
    17f0:	10450513          	addi	a0,a0,260 # 68f0 <malloc+0xe4e>
    17f4:	00004097          	auipc	ra,0x4
    17f8:	1ee080e7          	jalr	494(ra) # 59e2 <printf>
    exit(1);
    17fc:	4505                	li	a0,1
    17fe:	00004097          	auipc	ra,0x4
    1802:	e64080e7          	jalr	-412(ra) # 5662 <exit>
    close(fds[0]);
    1806:	fb842503          	lw	a0,-72(s0)
    180a:	00004097          	auipc	ra,0x4
    180e:	e80080e7          	jalr	-384(ra) # 568a <close>
    for(n = 0; n < N; n++){
    1812:	0000aa97          	auipc	s5,0xa
    1816:	2e6a8a93          	addi	s5,s5,742 # baf8 <buf>
    181a:	0ffaf793          	andi	a5,s5,255
    181e:	40f004b3          	neg	s1,a5
    1822:	0ff4f493          	andi	s1,s1,255
    1826:	02d00a13          	li	s4,45
    182a:	40fa0a3b          	subw	s4,s4,a5
    182e:	0ffa7a13          	andi	s4,s4,255
    1832:	409a8913          	addi	s2,s5,1033
      if(write(fds[1], buf, SZ) != SZ){
    1836:	8b56                	mv	s6,s5
{
    1838:	87d6                	mv	a5,s5
        buf[i] = seq++;
    183a:	0097873b          	addw	a4,a5,s1
    183e:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1842:	0785                	addi	a5,a5,1
    1844:	fef91be3          	bne	s2,a5,183a <pipe1+0xe6>
      if(write(fds[1], buf, SZ) != SZ){
    1848:	40900613          	li	a2,1033
    184c:	85da                	mv	a1,s6
    184e:	fbc42503          	lw	a0,-68(s0)
    1852:	00004097          	auipc	ra,0x4
    1856:	e30080e7          	jalr	-464(ra) # 5682 <write>
    185a:	40900793          	li	a5,1033
    185e:	00f51c63          	bne	a0,a5,1876 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1862:	24a5                	addiw	s1,s1,9
    1864:	0ff4f493          	andi	s1,s1,255
    1868:	fd4498e3          	bne	s1,s4,1838 <pipe1+0xe4>
    exit(0);
    186c:	4501                	li	a0,0
    186e:	00004097          	auipc	ra,0x4
    1872:	df4080e7          	jalr	-524(ra) # 5662 <exit>
        printf("%s: pipe1 oops 1\n", s);
    1876:	85ce                	mv	a1,s3
    1878:	00005517          	auipc	a0,0x5
    187c:	09050513          	addi	a0,a0,144 # 6908 <malloc+0xe66>
    1880:	00004097          	auipc	ra,0x4
    1884:	162080e7          	jalr	354(ra) # 59e2 <printf>
        exit(1);
    1888:	4505                	li	a0,1
    188a:	00004097          	auipc	ra,0x4
    188e:	dd8080e7          	jalr	-552(ra) # 5662 <exit>
          printf("%s: pipe1 oops 2\n", s);
    1892:	85ce                	mv	a1,s3
    1894:	00005517          	auipc	a0,0x5
    1898:	08c50513          	addi	a0,a0,140 # 6920 <malloc+0xe7e>
    189c:	00004097          	auipc	ra,0x4
    18a0:	146080e7          	jalr	326(ra) # 59e2 <printf>
}
    18a4:	60a6                	ld	ra,72(sp)
    18a6:	6406                	ld	s0,64(sp)
    18a8:	74e2                	ld	s1,56(sp)
    18aa:	7942                	ld	s2,48(sp)
    18ac:	79a2                	ld	s3,40(sp)
    18ae:	7a02                	ld	s4,32(sp)
    18b0:	6ae2                	ld	s5,24(sp)
    18b2:	6b42                	ld	s6,16(sp)
    18b4:	6161                	addi	sp,sp,80
    18b6:	8082                	ret
      total += n;
    18b8:	00aa8abb          	addw	s5,s5,a0
      cc = cc * 2;
    18bc:	001a179b          	slliw	a5,s4,0x1
    18c0:	00078a1b          	sext.w	s4,a5
      if(cc > sizeof(buf))
    18c4:	ed4b7fe3          	bleu	s4,s6,17a2 <pipe1+0x4e>
        cc = sizeof(buf);
    18c8:	8a5a                	mv	s4,s6
    18ca:	bde1                	j	17a2 <pipe1+0x4e>
    if(total != N * SZ){
    18cc:	6785                	lui	a5,0x1
    18ce:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x6f>
    18d2:	02fa8063          	beq	s5,a5,18f2 <pipe1+0x19e>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18d6:	85d6                	mv	a1,s5
    18d8:	00005517          	auipc	a0,0x5
    18dc:	06050513          	addi	a0,a0,96 # 6938 <malloc+0xe96>
    18e0:	00004097          	auipc	ra,0x4
    18e4:	102080e7          	jalr	258(ra) # 59e2 <printf>
      exit(1);
    18e8:	4505                	li	a0,1
    18ea:	00004097          	auipc	ra,0x4
    18ee:	d78080e7          	jalr	-648(ra) # 5662 <exit>
    close(fds[0]);
    18f2:	fb842503          	lw	a0,-72(s0)
    18f6:	00004097          	auipc	ra,0x4
    18fa:	d94080e7          	jalr	-620(ra) # 568a <close>
    wait(&xstatus);
    18fe:	fb440513          	addi	a0,s0,-76
    1902:	00004097          	auipc	ra,0x4
    1906:	d68080e7          	jalr	-664(ra) # 566a <wait>
    exit(xstatus);
    190a:	fb442503          	lw	a0,-76(s0)
    190e:	00004097          	auipc	ra,0x4
    1912:	d54080e7          	jalr	-684(ra) # 5662 <exit>
    printf("%s: fork() failed\n", s);
    1916:	85ce                	mv	a1,s3
    1918:	00005517          	auipc	a0,0x5
    191c:	04050513          	addi	a0,a0,64 # 6958 <malloc+0xeb6>
    1920:	00004097          	auipc	ra,0x4
    1924:	0c2080e7          	jalr	194(ra) # 59e2 <printf>
    exit(1);
    1928:	4505                	li	a0,1
    192a:	00004097          	auipc	ra,0x4
    192e:	d38080e7          	jalr	-712(ra) # 5662 <exit>

0000000000001932 <exitwait>:
{
    1932:	7139                	addi	sp,sp,-64
    1934:	fc06                	sd	ra,56(sp)
    1936:	f822                	sd	s0,48(sp)
    1938:	f426                	sd	s1,40(sp)
    193a:	f04a                	sd	s2,32(sp)
    193c:	ec4e                	sd	s3,24(sp)
    193e:	e852                	sd	s4,16(sp)
    1940:	0080                	addi	s0,sp,64
    1942:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1944:	4481                	li	s1,0
    1946:	06400993          	li	s3,100
    pid = fork();
    194a:	00004097          	auipc	ra,0x4
    194e:	d10080e7          	jalr	-752(ra) # 565a <fork>
    1952:	892a                	mv	s2,a0
    if(pid < 0){
    1954:	02054a63          	bltz	a0,1988 <exitwait+0x56>
    if(pid){
    1958:	c151                	beqz	a0,19dc <exitwait+0xaa>
      if(wait(&xstate) != pid){
    195a:	fcc40513          	addi	a0,s0,-52
    195e:	00004097          	auipc	ra,0x4
    1962:	d0c080e7          	jalr	-756(ra) # 566a <wait>
    1966:	03251f63          	bne	a0,s2,19a4 <exitwait+0x72>
      if(i != xstate) {
    196a:	fcc42783          	lw	a5,-52(s0)
    196e:	04979963          	bne	a5,s1,19c0 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1972:	2485                	addiw	s1,s1,1
    1974:	fd349be3          	bne	s1,s3,194a <exitwait+0x18>
}
    1978:	70e2                	ld	ra,56(sp)
    197a:	7442                	ld	s0,48(sp)
    197c:	74a2                	ld	s1,40(sp)
    197e:	7902                	ld	s2,32(sp)
    1980:	69e2                	ld	s3,24(sp)
    1982:	6a42                	ld	s4,16(sp)
    1984:	6121                	addi	sp,sp,64
    1986:	8082                	ret
      printf("%s: fork failed\n", s);
    1988:	85d2                	mv	a1,s4
    198a:	00005517          	auipc	a0,0x5
    198e:	e5e50513          	addi	a0,a0,-418 # 67e8 <malloc+0xd46>
    1992:	00004097          	auipc	ra,0x4
    1996:	050080e7          	jalr	80(ra) # 59e2 <printf>
      exit(1);
    199a:	4505                	li	a0,1
    199c:	00004097          	auipc	ra,0x4
    19a0:	cc6080e7          	jalr	-826(ra) # 5662 <exit>
        printf("%s: wait wrong pid\n", s);
    19a4:	85d2                	mv	a1,s4
    19a6:	00005517          	auipc	a0,0x5
    19aa:	fca50513          	addi	a0,a0,-54 # 6970 <malloc+0xece>
    19ae:	00004097          	auipc	ra,0x4
    19b2:	034080e7          	jalr	52(ra) # 59e2 <printf>
        exit(1);
    19b6:	4505                	li	a0,1
    19b8:	00004097          	auipc	ra,0x4
    19bc:	caa080e7          	jalr	-854(ra) # 5662 <exit>
        printf("%s: wait wrong exit status\n", s);
    19c0:	85d2                	mv	a1,s4
    19c2:	00005517          	auipc	a0,0x5
    19c6:	fc650513          	addi	a0,a0,-58 # 6988 <malloc+0xee6>
    19ca:	00004097          	auipc	ra,0x4
    19ce:	018080e7          	jalr	24(ra) # 59e2 <printf>
        exit(1);
    19d2:	4505                	li	a0,1
    19d4:	00004097          	auipc	ra,0x4
    19d8:	c8e080e7          	jalr	-882(ra) # 5662 <exit>
      exit(i);
    19dc:	8526                	mv	a0,s1
    19de:	00004097          	auipc	ra,0x4
    19e2:	c84080e7          	jalr	-892(ra) # 5662 <exit>

00000000000019e6 <twochildren>:
{
    19e6:	1101                	addi	sp,sp,-32
    19e8:	ec06                	sd	ra,24(sp)
    19ea:	e822                	sd	s0,16(sp)
    19ec:	e426                	sd	s1,8(sp)
    19ee:	e04a                	sd	s2,0(sp)
    19f0:	1000                	addi	s0,sp,32
    19f2:	892a                	mv	s2,a0
    19f4:	3e800493          	li	s1,1000
    int pid1 = fork();
    19f8:	00004097          	auipc	ra,0x4
    19fc:	c62080e7          	jalr	-926(ra) # 565a <fork>
    if(pid1 < 0){
    1a00:	02054c63          	bltz	a0,1a38 <twochildren+0x52>
    if(pid1 == 0){
    1a04:	c921                	beqz	a0,1a54 <twochildren+0x6e>
      int pid2 = fork();
    1a06:	00004097          	auipc	ra,0x4
    1a0a:	c54080e7          	jalr	-940(ra) # 565a <fork>
      if(pid2 < 0){
    1a0e:	04054763          	bltz	a0,1a5c <twochildren+0x76>
      if(pid2 == 0){
    1a12:	c13d                	beqz	a0,1a78 <twochildren+0x92>
        wait(0);
    1a14:	4501                	li	a0,0
    1a16:	00004097          	auipc	ra,0x4
    1a1a:	c54080e7          	jalr	-940(ra) # 566a <wait>
        wait(0);
    1a1e:	4501                	li	a0,0
    1a20:	00004097          	auipc	ra,0x4
    1a24:	c4a080e7          	jalr	-950(ra) # 566a <wait>
  for(int i = 0; i < 1000; i++){
    1a28:	34fd                	addiw	s1,s1,-1
    1a2a:	f4f9                	bnez	s1,19f8 <twochildren+0x12>
}
    1a2c:	60e2                	ld	ra,24(sp)
    1a2e:	6442                	ld	s0,16(sp)
    1a30:	64a2                	ld	s1,8(sp)
    1a32:	6902                	ld	s2,0(sp)
    1a34:	6105                	addi	sp,sp,32
    1a36:	8082                	ret
      printf("%s: fork failed\n", s);
    1a38:	85ca                	mv	a1,s2
    1a3a:	00005517          	auipc	a0,0x5
    1a3e:	dae50513          	addi	a0,a0,-594 # 67e8 <malloc+0xd46>
    1a42:	00004097          	auipc	ra,0x4
    1a46:	fa0080e7          	jalr	-96(ra) # 59e2 <printf>
      exit(1);
    1a4a:	4505                	li	a0,1
    1a4c:	00004097          	auipc	ra,0x4
    1a50:	c16080e7          	jalr	-1002(ra) # 5662 <exit>
      exit(0);
    1a54:	00004097          	auipc	ra,0x4
    1a58:	c0e080e7          	jalr	-1010(ra) # 5662 <exit>
        printf("%s: fork failed\n", s);
    1a5c:	85ca                	mv	a1,s2
    1a5e:	00005517          	auipc	a0,0x5
    1a62:	d8a50513          	addi	a0,a0,-630 # 67e8 <malloc+0xd46>
    1a66:	00004097          	auipc	ra,0x4
    1a6a:	f7c080e7          	jalr	-132(ra) # 59e2 <printf>
        exit(1);
    1a6e:	4505                	li	a0,1
    1a70:	00004097          	auipc	ra,0x4
    1a74:	bf2080e7          	jalr	-1038(ra) # 5662 <exit>
        exit(0);
    1a78:	00004097          	auipc	ra,0x4
    1a7c:	bea080e7          	jalr	-1046(ra) # 5662 <exit>

0000000000001a80 <forkfork>:
{
    1a80:	7179                	addi	sp,sp,-48
    1a82:	f406                	sd	ra,40(sp)
    1a84:	f022                	sd	s0,32(sp)
    1a86:	ec26                	sd	s1,24(sp)
    1a88:	1800                	addi	s0,sp,48
    1a8a:	84aa                	mv	s1,a0
    int pid = fork();
    1a8c:	00004097          	auipc	ra,0x4
    1a90:	bce080e7          	jalr	-1074(ra) # 565a <fork>
    if(pid < 0){
    1a94:	04054163          	bltz	a0,1ad6 <forkfork+0x56>
    if(pid == 0){
    1a98:	cd29                	beqz	a0,1af2 <forkfork+0x72>
    int pid = fork();
    1a9a:	00004097          	auipc	ra,0x4
    1a9e:	bc0080e7          	jalr	-1088(ra) # 565a <fork>
    if(pid < 0){
    1aa2:	02054a63          	bltz	a0,1ad6 <forkfork+0x56>
    if(pid == 0){
    1aa6:	c531                	beqz	a0,1af2 <forkfork+0x72>
    wait(&xstatus);
    1aa8:	fdc40513          	addi	a0,s0,-36
    1aac:	00004097          	auipc	ra,0x4
    1ab0:	bbe080e7          	jalr	-1090(ra) # 566a <wait>
    if(xstatus != 0) {
    1ab4:	fdc42783          	lw	a5,-36(s0)
    1ab8:	ebbd                	bnez	a5,1b2e <forkfork+0xae>
    wait(&xstatus);
    1aba:	fdc40513          	addi	a0,s0,-36
    1abe:	00004097          	auipc	ra,0x4
    1ac2:	bac080e7          	jalr	-1108(ra) # 566a <wait>
    if(xstatus != 0) {
    1ac6:	fdc42783          	lw	a5,-36(s0)
    1aca:	e3b5                	bnez	a5,1b2e <forkfork+0xae>
}
    1acc:	70a2                	ld	ra,40(sp)
    1ace:	7402                	ld	s0,32(sp)
    1ad0:	64e2                	ld	s1,24(sp)
    1ad2:	6145                	addi	sp,sp,48
    1ad4:	8082                	ret
      printf("%s: fork failed", s);
    1ad6:	85a6                	mv	a1,s1
    1ad8:	00005517          	auipc	a0,0x5
    1adc:	ed050513          	addi	a0,a0,-304 # 69a8 <malloc+0xf06>
    1ae0:	00004097          	auipc	ra,0x4
    1ae4:	f02080e7          	jalr	-254(ra) # 59e2 <printf>
      exit(1);
    1ae8:	4505                	li	a0,1
    1aea:	00004097          	auipc	ra,0x4
    1aee:	b78080e7          	jalr	-1160(ra) # 5662 <exit>
{
    1af2:	0c800493          	li	s1,200
        int pid1 = fork();
    1af6:	00004097          	auipc	ra,0x4
    1afa:	b64080e7          	jalr	-1180(ra) # 565a <fork>
        if(pid1 < 0){
    1afe:	00054f63          	bltz	a0,1b1c <forkfork+0x9c>
        if(pid1 == 0){
    1b02:	c115                	beqz	a0,1b26 <forkfork+0xa6>
        wait(0);
    1b04:	4501                	li	a0,0
    1b06:	00004097          	auipc	ra,0x4
    1b0a:	b64080e7          	jalr	-1180(ra) # 566a <wait>
      for(int j = 0; j < 200; j++){
    1b0e:	34fd                	addiw	s1,s1,-1
    1b10:	f0fd                	bnez	s1,1af6 <forkfork+0x76>
      exit(0);
    1b12:	4501                	li	a0,0
    1b14:	00004097          	auipc	ra,0x4
    1b18:	b4e080e7          	jalr	-1202(ra) # 5662 <exit>
          exit(1);
    1b1c:	4505                	li	a0,1
    1b1e:	00004097          	auipc	ra,0x4
    1b22:	b44080e7          	jalr	-1212(ra) # 5662 <exit>
          exit(0);
    1b26:	00004097          	auipc	ra,0x4
    1b2a:	b3c080e7          	jalr	-1220(ra) # 5662 <exit>
      printf("%s: fork in child failed", s);
    1b2e:	85a6                	mv	a1,s1
    1b30:	00005517          	auipc	a0,0x5
    1b34:	e8850513          	addi	a0,a0,-376 # 69b8 <malloc+0xf16>
    1b38:	00004097          	auipc	ra,0x4
    1b3c:	eaa080e7          	jalr	-342(ra) # 59e2 <printf>
      exit(1);
    1b40:	4505                	li	a0,1
    1b42:	00004097          	auipc	ra,0x4
    1b46:	b20080e7          	jalr	-1248(ra) # 5662 <exit>

0000000000001b4a <reparent2>:
{
    1b4a:	1101                	addi	sp,sp,-32
    1b4c:	ec06                	sd	ra,24(sp)
    1b4e:	e822                	sd	s0,16(sp)
    1b50:	e426                	sd	s1,8(sp)
    1b52:	1000                	addi	s0,sp,32
    1b54:	32000493          	li	s1,800
    int pid1 = fork();
    1b58:	00004097          	auipc	ra,0x4
    1b5c:	b02080e7          	jalr	-1278(ra) # 565a <fork>
    if(pid1 < 0){
    1b60:	00054f63          	bltz	a0,1b7e <reparent2+0x34>
    if(pid1 == 0){
    1b64:	c915                	beqz	a0,1b98 <reparent2+0x4e>
    wait(0);
    1b66:	4501                	li	a0,0
    1b68:	00004097          	auipc	ra,0x4
    1b6c:	b02080e7          	jalr	-1278(ra) # 566a <wait>
  for(int i = 0; i < 800; i++){
    1b70:	34fd                	addiw	s1,s1,-1
    1b72:	f0fd                	bnez	s1,1b58 <reparent2+0xe>
  exit(0);
    1b74:	4501                	li	a0,0
    1b76:	00004097          	auipc	ra,0x4
    1b7a:	aec080e7          	jalr	-1300(ra) # 5662 <exit>
      printf("fork failed\n");
    1b7e:	00005517          	auipc	a0,0x5
    1b82:	07250513          	addi	a0,a0,114 # 6bf0 <malloc+0x114e>
    1b86:	00004097          	auipc	ra,0x4
    1b8a:	e5c080e7          	jalr	-420(ra) # 59e2 <printf>
      exit(1);
    1b8e:	4505                	li	a0,1
    1b90:	00004097          	auipc	ra,0x4
    1b94:	ad2080e7          	jalr	-1326(ra) # 5662 <exit>
      fork();
    1b98:	00004097          	auipc	ra,0x4
    1b9c:	ac2080e7          	jalr	-1342(ra) # 565a <fork>
      fork();
    1ba0:	00004097          	auipc	ra,0x4
    1ba4:	aba080e7          	jalr	-1350(ra) # 565a <fork>
      exit(0);
    1ba8:	4501                	li	a0,0
    1baa:	00004097          	auipc	ra,0x4
    1bae:	ab8080e7          	jalr	-1352(ra) # 5662 <exit>

0000000000001bb2 <createdelete>:
{
    1bb2:	7175                	addi	sp,sp,-144
    1bb4:	e506                	sd	ra,136(sp)
    1bb6:	e122                	sd	s0,128(sp)
    1bb8:	fca6                	sd	s1,120(sp)
    1bba:	f8ca                	sd	s2,112(sp)
    1bbc:	f4ce                	sd	s3,104(sp)
    1bbe:	f0d2                	sd	s4,96(sp)
    1bc0:	ecd6                	sd	s5,88(sp)
    1bc2:	e8da                	sd	s6,80(sp)
    1bc4:	e4de                	sd	s7,72(sp)
    1bc6:	e0e2                	sd	s8,64(sp)
    1bc8:	fc66                	sd	s9,56(sp)
    1bca:	0900                	addi	s0,sp,144
    1bcc:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bce:	4901                	li	s2,0
    1bd0:	4991                	li	s3,4
    pid = fork();
    1bd2:	00004097          	auipc	ra,0x4
    1bd6:	a88080e7          	jalr	-1400(ra) # 565a <fork>
    1bda:	84aa                	mv	s1,a0
    if(pid < 0){
    1bdc:	02054f63          	bltz	a0,1c1a <createdelete+0x68>
    if(pid == 0){
    1be0:	c939                	beqz	a0,1c36 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1be2:	2905                	addiw	s2,s2,1
    1be4:	ff3917e3          	bne	s2,s3,1bd2 <createdelete+0x20>
    1be8:	4491                	li	s1,4
    wait(&xstatus);
    1bea:	f7c40513          	addi	a0,s0,-132
    1bee:	00004097          	auipc	ra,0x4
    1bf2:	a7c080e7          	jalr	-1412(ra) # 566a <wait>
    if(xstatus != 0)
    1bf6:	f7c42903          	lw	s2,-132(s0)
    1bfa:	0e091263          	bnez	s2,1cde <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1bfe:	34fd                	addiw	s1,s1,-1
    1c00:	f4ed                	bnez	s1,1bea <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1c02:	f8040123          	sb	zero,-126(s0)
    1c06:	03000993          	li	s3,48
    1c0a:	5a7d                	li	s4,-1
    1c0c:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1c10:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1c12:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1c14:	07400a93          	li	s5,116
    1c18:	a29d                	j	1d7e <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c1a:	85e6                	mv	a1,s9
    1c1c:	00005517          	auipc	a0,0x5
    1c20:	fd450513          	addi	a0,a0,-44 # 6bf0 <malloc+0x114e>
    1c24:	00004097          	auipc	ra,0x4
    1c28:	dbe080e7          	jalr	-578(ra) # 59e2 <printf>
      exit(1);
    1c2c:	4505                	li	a0,1
    1c2e:	00004097          	auipc	ra,0x4
    1c32:	a34080e7          	jalr	-1484(ra) # 5662 <exit>
      name[0] = 'p' + pi;
    1c36:	0709091b          	addiw	s2,s2,112
    1c3a:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c3e:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c42:	4951                	li	s2,20
    1c44:	a015                	j	1c68 <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c46:	85e6                	mv	a1,s9
    1c48:	00005517          	auipc	a0,0x5
    1c4c:	c3850513          	addi	a0,a0,-968 # 6880 <malloc+0xdde>
    1c50:	00004097          	auipc	ra,0x4
    1c54:	d92080e7          	jalr	-622(ra) # 59e2 <printf>
          exit(1);
    1c58:	4505                	li	a0,1
    1c5a:	00004097          	auipc	ra,0x4
    1c5e:	a08080e7          	jalr	-1528(ra) # 5662 <exit>
      for(i = 0; i < N; i++){
    1c62:	2485                	addiw	s1,s1,1
    1c64:	07248863          	beq	s1,s2,1cd4 <createdelete+0x122>
        name[1] = '0' + i;
    1c68:	0304879b          	addiw	a5,s1,48
    1c6c:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c70:	20200593          	li	a1,514
    1c74:	f8040513          	addi	a0,s0,-128
    1c78:	00004097          	auipc	ra,0x4
    1c7c:	a2a080e7          	jalr	-1494(ra) # 56a2 <open>
        if(fd < 0){
    1c80:	fc0543e3          	bltz	a0,1c46 <createdelete+0x94>
        close(fd);
    1c84:	00004097          	auipc	ra,0x4
    1c88:	a06080e7          	jalr	-1530(ra) # 568a <close>
        if(i > 0 && (i % 2 ) == 0){
    1c8c:	fc905be3          	blez	s1,1c62 <createdelete+0xb0>
    1c90:	0014f793          	andi	a5,s1,1
    1c94:	f7f9                	bnez	a5,1c62 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c96:	01f4d79b          	srliw	a5,s1,0x1f
    1c9a:	9fa5                	addw	a5,a5,s1
    1c9c:	4017d79b          	sraiw	a5,a5,0x1
    1ca0:	0307879b          	addiw	a5,a5,48
    1ca4:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1ca8:	f8040513          	addi	a0,s0,-128
    1cac:	00004097          	auipc	ra,0x4
    1cb0:	a06080e7          	jalr	-1530(ra) # 56b2 <unlink>
    1cb4:	fa0557e3          	bgez	a0,1c62 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1cb8:	85e6                	mv	a1,s9
    1cba:	00005517          	auipc	a0,0x5
    1cbe:	d1e50513          	addi	a0,a0,-738 # 69d8 <malloc+0xf36>
    1cc2:	00004097          	auipc	ra,0x4
    1cc6:	d20080e7          	jalr	-736(ra) # 59e2 <printf>
            exit(1);
    1cca:	4505                	li	a0,1
    1ccc:	00004097          	auipc	ra,0x4
    1cd0:	996080e7          	jalr	-1642(ra) # 5662 <exit>
      exit(0);
    1cd4:	4501                	li	a0,0
    1cd6:	00004097          	auipc	ra,0x4
    1cda:	98c080e7          	jalr	-1652(ra) # 5662 <exit>
      exit(1);
    1cde:	4505                	li	a0,1
    1ce0:	00004097          	auipc	ra,0x4
    1ce4:	982080e7          	jalr	-1662(ra) # 5662 <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1ce8:	f8040613          	addi	a2,s0,-128
    1cec:	85e6                	mv	a1,s9
    1cee:	00005517          	auipc	a0,0x5
    1cf2:	d0250513          	addi	a0,a0,-766 # 69f0 <malloc+0xf4e>
    1cf6:	00004097          	auipc	ra,0x4
    1cfa:	cec080e7          	jalr	-788(ra) # 59e2 <printf>
        exit(1);
    1cfe:	4505                	li	a0,1
    1d00:	00004097          	auipc	ra,0x4
    1d04:	962080e7          	jalr	-1694(ra) # 5662 <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d08:	054b7163          	bleu	s4,s6,1d4a <createdelete+0x198>
      if(fd >= 0)
    1d0c:	02055a63          	bgez	a0,1d40 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1d10:	2485                	addiw	s1,s1,1
    1d12:	0ff4f493          	andi	s1,s1,255
    1d16:	05548c63          	beq	s1,s5,1d6e <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d1a:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d1e:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d22:	4581                	li	a1,0
    1d24:	f8040513          	addi	a0,s0,-128
    1d28:	00004097          	auipc	ra,0x4
    1d2c:	97a080e7          	jalr	-1670(ra) # 56a2 <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d30:	00090463          	beqz	s2,1d38 <createdelete+0x186>
    1d34:	fd2bdae3          	ble	s2,s7,1d08 <createdelete+0x156>
    1d38:	fa0548e3          	bltz	a0,1ce8 <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d3c:	014b7963          	bleu	s4,s6,1d4e <createdelete+0x19c>
        close(fd);
    1d40:	00004097          	auipc	ra,0x4
    1d44:	94a080e7          	jalr	-1718(ra) # 568a <close>
    1d48:	b7e1                	j	1d10 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d4a:	fc0543e3          	bltz	a0,1d10 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d4e:	f8040613          	addi	a2,s0,-128
    1d52:	85e6                	mv	a1,s9
    1d54:	00005517          	auipc	a0,0x5
    1d58:	cc450513          	addi	a0,a0,-828 # 6a18 <malloc+0xf76>
    1d5c:	00004097          	auipc	ra,0x4
    1d60:	c86080e7          	jalr	-890(ra) # 59e2 <printf>
        exit(1);
    1d64:	4505                	li	a0,1
    1d66:	00004097          	auipc	ra,0x4
    1d6a:	8fc080e7          	jalr	-1796(ra) # 5662 <exit>
  for(i = 0; i < N; i++){
    1d6e:	2905                	addiw	s2,s2,1
    1d70:	2a05                	addiw	s4,s4,1
    1d72:	2985                	addiw	s3,s3,1
    1d74:	0ff9f993          	andi	s3,s3,255
    1d78:	47d1                	li	a5,20
    1d7a:	02f90a63          	beq	s2,a5,1dae <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d7e:	84e2                	mv	s1,s8
    1d80:	bf69                	j	1d1a <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d82:	2905                	addiw	s2,s2,1
    1d84:	0ff97913          	andi	s2,s2,255
    1d88:	2985                	addiw	s3,s3,1
    1d8a:	0ff9f993          	andi	s3,s3,255
    1d8e:	03490863          	beq	s2,s4,1dbe <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d92:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d94:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d98:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1d9c:	f8040513          	addi	a0,s0,-128
    1da0:	00004097          	auipc	ra,0x4
    1da4:	912080e7          	jalr	-1774(ra) # 56b2 <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1da8:	34fd                	addiw	s1,s1,-1
    1daa:	f4ed                	bnez	s1,1d94 <createdelete+0x1e2>
    1dac:	bfd9                	j	1d82 <createdelete+0x1d0>
    1dae:	03000993          	li	s3,48
    1db2:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1db6:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1db8:	08400a13          	li	s4,132
    1dbc:	bfd9                	j	1d92 <createdelete+0x1e0>
}
    1dbe:	60aa                	ld	ra,136(sp)
    1dc0:	640a                	ld	s0,128(sp)
    1dc2:	74e6                	ld	s1,120(sp)
    1dc4:	7946                	ld	s2,112(sp)
    1dc6:	79a6                	ld	s3,104(sp)
    1dc8:	7a06                	ld	s4,96(sp)
    1dca:	6ae6                	ld	s5,88(sp)
    1dcc:	6b46                	ld	s6,80(sp)
    1dce:	6ba6                	ld	s7,72(sp)
    1dd0:	6c06                	ld	s8,64(sp)
    1dd2:	7ce2                	ld	s9,56(sp)
    1dd4:	6149                	addi	sp,sp,144
    1dd6:	8082                	ret

0000000000001dd8 <linkunlink>:
{
    1dd8:	711d                	addi	sp,sp,-96
    1dda:	ec86                	sd	ra,88(sp)
    1ddc:	e8a2                	sd	s0,80(sp)
    1dde:	e4a6                	sd	s1,72(sp)
    1de0:	e0ca                	sd	s2,64(sp)
    1de2:	fc4e                	sd	s3,56(sp)
    1de4:	f852                	sd	s4,48(sp)
    1de6:	f456                	sd	s5,40(sp)
    1de8:	f05a                	sd	s6,32(sp)
    1dea:	ec5e                	sd	s7,24(sp)
    1dec:	e862                	sd	s8,16(sp)
    1dee:	e466                	sd	s9,8(sp)
    1df0:	1080                	addi	s0,sp,96
    1df2:	84aa                	mv	s1,a0
  unlink("x");
    1df4:	00004517          	auipc	a0,0x4
    1df8:	20c50513          	addi	a0,a0,524 # 6000 <malloc+0x55e>
    1dfc:	00004097          	auipc	ra,0x4
    1e00:	8b6080e7          	jalr	-1866(ra) # 56b2 <unlink>
  pid = fork();
    1e04:	00004097          	auipc	ra,0x4
    1e08:	856080e7          	jalr	-1962(ra) # 565a <fork>
  if(pid < 0){
    1e0c:	02054b63          	bltz	a0,1e42 <linkunlink+0x6a>
    1e10:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1e12:	4c85                	li	s9,1
    1e14:	e119                	bnez	a0,1e1a <linkunlink+0x42>
    1e16:	06100c93          	li	s9,97
    1e1a:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e1e:	41c659b7          	lui	s3,0x41c65
    1e22:	e6d9899b          	addiw	s3,s3,-403
    1e26:	690d                	lui	s2,0x3
    1e28:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e2c:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e2e:	4b05                	li	s6,1
      unlink("x");
    1e30:	00004a97          	auipc	s5,0x4
    1e34:	1d0a8a93          	addi	s5,s5,464 # 6000 <malloc+0x55e>
      link("cat", "x");
    1e38:	00005b97          	auipc	s7,0x5
    1e3c:	c08b8b93          	addi	s7,s7,-1016 # 6a40 <malloc+0xf9e>
    1e40:	a091                	j	1e84 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e42:	85a6                	mv	a1,s1
    1e44:	00005517          	auipc	a0,0x5
    1e48:	9a450513          	addi	a0,a0,-1628 # 67e8 <malloc+0xd46>
    1e4c:	00004097          	auipc	ra,0x4
    1e50:	b96080e7          	jalr	-1130(ra) # 59e2 <printf>
    exit(1);
    1e54:	4505                	li	a0,1
    1e56:	00004097          	auipc	ra,0x4
    1e5a:	80c080e7          	jalr	-2036(ra) # 5662 <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e5e:	20200593          	li	a1,514
    1e62:	8556                	mv	a0,s5
    1e64:	00004097          	auipc	ra,0x4
    1e68:	83e080e7          	jalr	-1986(ra) # 56a2 <open>
    1e6c:	00004097          	auipc	ra,0x4
    1e70:	81e080e7          	jalr	-2018(ra) # 568a <close>
    1e74:	a031                	j	1e80 <linkunlink+0xa8>
      unlink("x");
    1e76:	8556                	mv	a0,s5
    1e78:	00004097          	auipc	ra,0x4
    1e7c:	83a080e7          	jalr	-1990(ra) # 56b2 <unlink>
  for(i = 0; i < 100; i++){
    1e80:	34fd                	addiw	s1,s1,-1
    1e82:	c09d                	beqz	s1,1ea8 <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e84:	033c87bb          	mulw	a5,s9,s3
    1e88:	012787bb          	addw	a5,a5,s2
    1e8c:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e90:	0347f7bb          	remuw	a5,a5,s4
    1e94:	d7e9                	beqz	a5,1e5e <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e96:	ff6790e3          	bne	a5,s6,1e76 <linkunlink+0x9e>
      link("cat", "x");
    1e9a:	85d6                	mv	a1,s5
    1e9c:	855e                	mv	a0,s7
    1e9e:	00004097          	auipc	ra,0x4
    1ea2:	824080e7          	jalr	-2012(ra) # 56c2 <link>
    1ea6:	bfe9                	j	1e80 <linkunlink+0xa8>
  if(pid)
    1ea8:	020c0463          	beqz	s8,1ed0 <linkunlink+0xf8>
    wait(0);
    1eac:	4501                	li	a0,0
    1eae:	00003097          	auipc	ra,0x3
    1eb2:	7bc080e7          	jalr	1980(ra) # 566a <wait>
}
    1eb6:	60e6                	ld	ra,88(sp)
    1eb8:	6446                	ld	s0,80(sp)
    1eba:	64a6                	ld	s1,72(sp)
    1ebc:	6906                	ld	s2,64(sp)
    1ebe:	79e2                	ld	s3,56(sp)
    1ec0:	7a42                	ld	s4,48(sp)
    1ec2:	7aa2                	ld	s5,40(sp)
    1ec4:	7b02                	ld	s6,32(sp)
    1ec6:	6be2                	ld	s7,24(sp)
    1ec8:	6c42                	ld	s8,16(sp)
    1eca:	6ca2                	ld	s9,8(sp)
    1ecc:	6125                	addi	sp,sp,96
    1ece:	8082                	ret
    exit(0);
    1ed0:	4501                	li	a0,0
    1ed2:	00003097          	auipc	ra,0x3
    1ed6:	790080e7          	jalr	1936(ra) # 5662 <exit>

0000000000001eda <manywrites>:
{
    1eda:	711d                	addi	sp,sp,-96
    1edc:	ec86                	sd	ra,88(sp)
    1ede:	e8a2                	sd	s0,80(sp)
    1ee0:	e4a6                	sd	s1,72(sp)
    1ee2:	e0ca                	sd	s2,64(sp)
    1ee4:	fc4e                	sd	s3,56(sp)
    1ee6:	f852                	sd	s4,48(sp)
    1ee8:	f456                	sd	s5,40(sp)
    1eea:	f05a                	sd	s6,32(sp)
    1eec:	ec5e                	sd	s7,24(sp)
    1eee:	1080                	addi	s0,sp,96
    1ef0:	8b2a                	mv	s6,a0
  for(int ci = 0; ci < nchildren; ci++){
    1ef2:	4481                	li	s1,0
    1ef4:	4991                	li	s3,4
    int pid = fork();
    1ef6:	00003097          	auipc	ra,0x3
    1efa:	764080e7          	jalr	1892(ra) # 565a <fork>
    1efe:	892a                	mv	s2,a0
    if(pid < 0){
    1f00:	02054963          	bltz	a0,1f32 <manywrites+0x58>
    if(pid == 0){
    1f04:	c521                	beqz	a0,1f4c <manywrites+0x72>
  for(int ci = 0; ci < nchildren; ci++){
    1f06:	2485                	addiw	s1,s1,1
    1f08:	ff3497e3          	bne	s1,s3,1ef6 <manywrites+0x1c>
    1f0c:	4491                	li	s1,4
    int st = 0;
    1f0e:	fa042423          	sw	zero,-88(s0)
    wait(&st);
    1f12:	fa840513          	addi	a0,s0,-88
    1f16:	00003097          	auipc	ra,0x3
    1f1a:	754080e7          	jalr	1876(ra) # 566a <wait>
    if(st != 0)
    1f1e:	fa842503          	lw	a0,-88(s0)
    1f22:	ed6d                	bnez	a0,201c <manywrites+0x142>
  for(int ci = 0; ci < nchildren; ci++){
    1f24:	34fd                	addiw	s1,s1,-1
    1f26:	f4e5                	bnez	s1,1f0e <manywrites+0x34>
  exit(0);
    1f28:	4501                	li	a0,0
    1f2a:	00003097          	auipc	ra,0x3
    1f2e:	738080e7          	jalr	1848(ra) # 5662 <exit>
      printf("fork failed\n");
    1f32:	00005517          	auipc	a0,0x5
    1f36:	cbe50513          	addi	a0,a0,-834 # 6bf0 <malloc+0x114e>
    1f3a:	00004097          	auipc	ra,0x4
    1f3e:	aa8080e7          	jalr	-1368(ra) # 59e2 <printf>
      exit(1);
    1f42:	4505                	li	a0,1
    1f44:	00003097          	auipc	ra,0x3
    1f48:	71e080e7          	jalr	1822(ra) # 5662 <exit>
      name[0] = 'b';
    1f4c:	06200793          	li	a5,98
    1f50:	faf40423          	sb	a5,-88(s0)
      name[1] = 'a' + ci;
    1f54:	0614879b          	addiw	a5,s1,97
    1f58:	faf404a3          	sb	a5,-87(s0)
      name[2] = '\0';
    1f5c:	fa040523          	sb	zero,-86(s0)
      unlink(name);
    1f60:	fa840513          	addi	a0,s0,-88
    1f64:	00003097          	auipc	ra,0x3
    1f68:	74e080e7          	jalr	1870(ra) # 56b2 <unlink>
    1f6c:	4bf9                	li	s7,30
          int cc = write(fd, buf, sz);
    1f6e:	0000aa97          	auipc	s5,0xa
    1f72:	b8aa8a93          	addi	s5,s5,-1142 # baf8 <buf>
        for(int i = 0; i < ci+1; i++){
    1f76:	8a4a                	mv	s4,s2
    1f78:	0204ce63          	bltz	s1,1fb4 <manywrites+0xda>
          int fd = open(name, O_CREATE | O_RDWR);
    1f7c:	20200593          	li	a1,514
    1f80:	fa840513          	addi	a0,s0,-88
    1f84:	00003097          	auipc	ra,0x3
    1f88:	71e080e7          	jalr	1822(ra) # 56a2 <open>
    1f8c:	89aa                	mv	s3,a0
          if(fd < 0){
    1f8e:	04054763          	bltz	a0,1fdc <manywrites+0x102>
          int cc = write(fd, buf, sz);
    1f92:	660d                	lui	a2,0x3
    1f94:	85d6                	mv	a1,s5
    1f96:	00003097          	auipc	ra,0x3
    1f9a:	6ec080e7          	jalr	1772(ra) # 5682 <write>
          if(cc != sz){
    1f9e:	678d                	lui	a5,0x3
    1fa0:	04f51e63          	bne	a0,a5,1ffc <manywrites+0x122>
          close(fd);
    1fa4:	854e                	mv	a0,s3
    1fa6:	00003097          	auipc	ra,0x3
    1faa:	6e4080e7          	jalr	1764(ra) # 568a <close>
        for(int i = 0; i < ci+1; i++){
    1fae:	2a05                	addiw	s4,s4,1
    1fb0:	fd44d6e3          	ble	s4,s1,1f7c <manywrites+0xa2>
        unlink(name);
    1fb4:	fa840513          	addi	a0,s0,-88
    1fb8:	00003097          	auipc	ra,0x3
    1fbc:	6fa080e7          	jalr	1786(ra) # 56b2 <unlink>
      for(int iters = 0; iters < howmany; iters++){
    1fc0:	3bfd                	addiw	s7,s7,-1
    1fc2:	fa0b9ae3          	bnez	s7,1f76 <manywrites+0x9c>
      unlink(name);
    1fc6:	fa840513          	addi	a0,s0,-88
    1fca:	00003097          	auipc	ra,0x3
    1fce:	6e8080e7          	jalr	1768(ra) # 56b2 <unlink>
      exit(0);
    1fd2:	4501                	li	a0,0
    1fd4:	00003097          	auipc	ra,0x3
    1fd8:	68e080e7          	jalr	1678(ra) # 5662 <exit>
            printf("%s: cannot create %s\n", s, name);
    1fdc:	fa840613          	addi	a2,s0,-88
    1fe0:	85da                	mv	a1,s6
    1fe2:	00005517          	auipc	a0,0x5
    1fe6:	a6650513          	addi	a0,a0,-1434 # 6a48 <malloc+0xfa6>
    1fea:	00004097          	auipc	ra,0x4
    1fee:	9f8080e7          	jalr	-1544(ra) # 59e2 <printf>
            exit(1);
    1ff2:	4505                	li	a0,1
    1ff4:	00003097          	auipc	ra,0x3
    1ff8:	66e080e7          	jalr	1646(ra) # 5662 <exit>
            printf("%s: write(%d) ret %d\n", s, sz, cc);
    1ffc:	86aa                	mv	a3,a0
    1ffe:	660d                	lui	a2,0x3
    2000:	85da                	mv	a1,s6
    2002:	00004517          	auipc	a0,0x4
    2006:	05e50513          	addi	a0,a0,94 # 6060 <malloc+0x5be>
    200a:	00004097          	auipc	ra,0x4
    200e:	9d8080e7          	jalr	-1576(ra) # 59e2 <printf>
            exit(1);
    2012:	4505                	li	a0,1
    2014:	00003097          	auipc	ra,0x3
    2018:	64e080e7          	jalr	1614(ra) # 5662 <exit>
      exit(st);
    201c:	00003097          	auipc	ra,0x3
    2020:	646080e7          	jalr	1606(ra) # 5662 <exit>

0000000000002024 <forktest>:
{
    2024:	7179                	addi	sp,sp,-48
    2026:	f406                	sd	ra,40(sp)
    2028:	f022                	sd	s0,32(sp)
    202a:	ec26                	sd	s1,24(sp)
    202c:	e84a                	sd	s2,16(sp)
    202e:	e44e                	sd	s3,8(sp)
    2030:	1800                	addi	s0,sp,48
    2032:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    2034:	4481                	li	s1,0
    2036:	3e800913          	li	s2,1000
    pid = fork();
    203a:	00003097          	auipc	ra,0x3
    203e:	620080e7          	jalr	1568(ra) # 565a <fork>
    if(pid < 0)
    2042:	02054863          	bltz	a0,2072 <forktest+0x4e>
    if(pid == 0)
    2046:	c115                	beqz	a0,206a <forktest+0x46>
  for(n=0; n<N; n++){
    2048:	2485                	addiw	s1,s1,1
    204a:	ff2498e3          	bne	s1,s2,203a <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    204e:	85ce                	mv	a1,s3
    2050:	00005517          	auipc	a0,0x5
    2054:	a2850513          	addi	a0,a0,-1496 # 6a78 <malloc+0xfd6>
    2058:	00004097          	auipc	ra,0x4
    205c:	98a080e7          	jalr	-1654(ra) # 59e2 <printf>
    exit(1);
    2060:	4505                	li	a0,1
    2062:	00003097          	auipc	ra,0x3
    2066:	600080e7          	jalr	1536(ra) # 5662 <exit>
      exit(0);
    206a:	00003097          	auipc	ra,0x3
    206e:	5f8080e7          	jalr	1528(ra) # 5662 <exit>
  if (n == 0) {
    2072:	cc9d                	beqz	s1,20b0 <forktest+0x8c>
  if(n == N){
    2074:	3e800793          	li	a5,1000
    2078:	fcf48be3          	beq	s1,a5,204e <forktest+0x2a>
  for(; n > 0; n--){
    207c:	00905b63          	blez	s1,2092 <forktest+0x6e>
    if(wait(0) < 0){
    2080:	4501                	li	a0,0
    2082:	00003097          	auipc	ra,0x3
    2086:	5e8080e7          	jalr	1512(ra) # 566a <wait>
    208a:	04054163          	bltz	a0,20cc <forktest+0xa8>
  for(; n > 0; n--){
    208e:	34fd                	addiw	s1,s1,-1
    2090:	f8e5                	bnez	s1,2080 <forktest+0x5c>
  if(wait(0) != -1){
    2092:	4501                	li	a0,0
    2094:	00003097          	auipc	ra,0x3
    2098:	5d6080e7          	jalr	1494(ra) # 566a <wait>
    209c:	57fd                	li	a5,-1
    209e:	04f51563          	bne	a0,a5,20e8 <forktest+0xc4>
}
    20a2:	70a2                	ld	ra,40(sp)
    20a4:	7402                	ld	s0,32(sp)
    20a6:	64e2                	ld	s1,24(sp)
    20a8:	6942                	ld	s2,16(sp)
    20aa:	69a2                	ld	s3,8(sp)
    20ac:	6145                	addi	sp,sp,48
    20ae:	8082                	ret
    printf("%s: no fork at all!\n", s);
    20b0:	85ce                	mv	a1,s3
    20b2:	00005517          	auipc	a0,0x5
    20b6:	9ae50513          	addi	a0,a0,-1618 # 6a60 <malloc+0xfbe>
    20ba:	00004097          	auipc	ra,0x4
    20be:	928080e7          	jalr	-1752(ra) # 59e2 <printf>
    exit(1);
    20c2:	4505                	li	a0,1
    20c4:	00003097          	auipc	ra,0x3
    20c8:	59e080e7          	jalr	1438(ra) # 5662 <exit>
      printf("%s: wait stopped early\n", s);
    20cc:	85ce                	mv	a1,s3
    20ce:	00005517          	auipc	a0,0x5
    20d2:	9d250513          	addi	a0,a0,-1582 # 6aa0 <malloc+0xffe>
    20d6:	00004097          	auipc	ra,0x4
    20da:	90c080e7          	jalr	-1780(ra) # 59e2 <printf>
      exit(1);
    20de:	4505                	li	a0,1
    20e0:	00003097          	auipc	ra,0x3
    20e4:	582080e7          	jalr	1410(ra) # 5662 <exit>
    printf("%s: wait got too many\n", s);
    20e8:	85ce                	mv	a1,s3
    20ea:	00005517          	auipc	a0,0x5
    20ee:	9ce50513          	addi	a0,a0,-1586 # 6ab8 <malloc+0x1016>
    20f2:	00004097          	auipc	ra,0x4
    20f6:	8f0080e7          	jalr	-1808(ra) # 59e2 <printf>
    exit(1);
    20fa:	4505                	li	a0,1
    20fc:	00003097          	auipc	ra,0x3
    2100:	566080e7          	jalr	1382(ra) # 5662 <exit>

0000000000002104 <kernmem>:
{
    2104:	715d                	addi	sp,sp,-80
    2106:	e486                	sd	ra,72(sp)
    2108:	e0a2                	sd	s0,64(sp)
    210a:	fc26                	sd	s1,56(sp)
    210c:	f84a                	sd	s2,48(sp)
    210e:	f44e                	sd	s3,40(sp)
    2110:	f052                	sd	s4,32(sp)
    2112:	ec56                	sd	s5,24(sp)
    2114:	0880                	addi	s0,sp,80
    2116:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2118:	4485                	li	s1,1
    211a:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    211c:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    211e:	69b1                	lui	s3,0xc
    2120:	35098993          	addi	s3,s3,848 # c350 <buf+0x858>
    2124:	1003d937          	lui	s2,0x1003d
    2128:	090e                	slli	s2,s2,0x3
    212a:	48090913          	addi	s2,s2,1152 # 1003d480 <_end+0x1002e978>
    pid = fork();
    212e:	00003097          	auipc	ra,0x3
    2132:	52c080e7          	jalr	1324(ra) # 565a <fork>
    if(pid < 0){
    2136:	02054963          	bltz	a0,2168 <kernmem+0x64>
    if(pid == 0){
    213a:	c529                	beqz	a0,2184 <kernmem+0x80>
    wait(&xstatus);
    213c:	fbc40513          	addi	a0,s0,-68
    2140:	00003097          	auipc	ra,0x3
    2144:	52a080e7          	jalr	1322(ra) # 566a <wait>
    if(xstatus != -1)  // did kernel kill child?
    2148:	fbc42783          	lw	a5,-68(s0)
    214c:	05479d63          	bne	a5,s4,21a6 <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2150:	94ce                	add	s1,s1,s3
    2152:	fd249ee3          	bne	s1,s2,212e <kernmem+0x2a>
}
    2156:	60a6                	ld	ra,72(sp)
    2158:	6406                	ld	s0,64(sp)
    215a:	74e2                	ld	s1,56(sp)
    215c:	7942                	ld	s2,48(sp)
    215e:	79a2                	ld	s3,40(sp)
    2160:	7a02                	ld	s4,32(sp)
    2162:	6ae2                	ld	s5,24(sp)
    2164:	6161                	addi	sp,sp,80
    2166:	8082                	ret
      printf("%s: fork failed\n", s);
    2168:	85d6                	mv	a1,s5
    216a:	00004517          	auipc	a0,0x4
    216e:	67e50513          	addi	a0,a0,1662 # 67e8 <malloc+0xd46>
    2172:	00004097          	auipc	ra,0x4
    2176:	870080e7          	jalr	-1936(ra) # 59e2 <printf>
      exit(1);
    217a:	4505                	li	a0,1
    217c:	00003097          	auipc	ra,0x3
    2180:	4e6080e7          	jalr	1254(ra) # 5662 <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    2184:	0004c683          	lbu	a3,0(s1)
    2188:	8626                	mv	a2,s1
    218a:	85d6                	mv	a1,s5
    218c:	00005517          	auipc	a0,0x5
    2190:	94450513          	addi	a0,a0,-1724 # 6ad0 <malloc+0x102e>
    2194:	00004097          	auipc	ra,0x4
    2198:	84e080e7          	jalr	-1970(ra) # 59e2 <printf>
      exit(1);
    219c:	4505                	li	a0,1
    219e:	00003097          	auipc	ra,0x3
    21a2:	4c4080e7          	jalr	1220(ra) # 5662 <exit>
      exit(1);
    21a6:	4505                	li	a0,1
    21a8:	00003097          	auipc	ra,0x3
    21ac:	4ba080e7          	jalr	1210(ra) # 5662 <exit>

00000000000021b0 <bigargtest>:
{
    21b0:	7179                	addi	sp,sp,-48
    21b2:	f406                	sd	ra,40(sp)
    21b4:	f022                	sd	s0,32(sp)
    21b6:	ec26                	sd	s1,24(sp)
    21b8:	1800                	addi	s0,sp,48
    21ba:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    21bc:	00005517          	auipc	a0,0x5
    21c0:	93450513          	addi	a0,a0,-1740 # 6af0 <malloc+0x104e>
    21c4:	00003097          	auipc	ra,0x3
    21c8:	4ee080e7          	jalr	1262(ra) # 56b2 <unlink>
  pid = fork();
    21cc:	00003097          	auipc	ra,0x3
    21d0:	48e080e7          	jalr	1166(ra) # 565a <fork>
  if(pid == 0){
    21d4:	c121                	beqz	a0,2214 <bigargtest+0x64>
  } else if(pid < 0){
    21d6:	0a054063          	bltz	a0,2276 <bigargtest+0xc6>
  wait(&xstatus);
    21da:	fdc40513          	addi	a0,s0,-36
    21de:	00003097          	auipc	ra,0x3
    21e2:	48c080e7          	jalr	1164(ra) # 566a <wait>
  if(xstatus != 0)
    21e6:	fdc42503          	lw	a0,-36(s0)
    21ea:	e545                	bnez	a0,2292 <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    21ec:	4581                	li	a1,0
    21ee:	00005517          	auipc	a0,0x5
    21f2:	90250513          	addi	a0,a0,-1790 # 6af0 <malloc+0x104e>
    21f6:	00003097          	auipc	ra,0x3
    21fa:	4ac080e7          	jalr	1196(ra) # 56a2 <open>
  if(fd < 0){
    21fe:	08054e63          	bltz	a0,229a <bigargtest+0xea>
  close(fd);
    2202:	00003097          	auipc	ra,0x3
    2206:	488080e7          	jalr	1160(ra) # 568a <close>
}
    220a:	70a2                	ld	ra,40(sp)
    220c:	7402                	ld	s0,32(sp)
    220e:	64e2                	ld	s1,24(sp)
    2210:	6145                	addi	sp,sp,48
    2212:	8082                	ret
    2214:	00006797          	auipc	a5,0x6
    2218:	0cc78793          	addi	a5,a5,204 # 82e0 <args.1857>
    221c:	00006697          	auipc	a3,0x6
    2220:	1bc68693          	addi	a3,a3,444 # 83d8 <args.1857+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    2224:	00005717          	auipc	a4,0x5
    2228:	8dc70713          	addi	a4,a4,-1828 # 6b00 <malloc+0x105e>
    222c:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    222e:	07a1                	addi	a5,a5,8
    2230:	fed79ee3          	bne	a5,a3,222c <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    2234:	00006597          	auipc	a1,0x6
    2238:	0ac58593          	addi	a1,a1,172 # 82e0 <args.1857>
    223c:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2240:	00004517          	auipc	a0,0x4
    2244:	d5050513          	addi	a0,a0,-688 # 5f90 <malloc+0x4ee>
    2248:	00003097          	auipc	ra,0x3
    224c:	452080e7          	jalr	1106(ra) # 569a <exec>
    fd = open("bigarg-ok", O_CREATE);
    2250:	20000593          	li	a1,512
    2254:	00005517          	auipc	a0,0x5
    2258:	89c50513          	addi	a0,a0,-1892 # 6af0 <malloc+0x104e>
    225c:	00003097          	auipc	ra,0x3
    2260:	446080e7          	jalr	1094(ra) # 56a2 <open>
    close(fd);
    2264:	00003097          	auipc	ra,0x3
    2268:	426080e7          	jalr	1062(ra) # 568a <close>
    exit(0);
    226c:	4501                	li	a0,0
    226e:	00003097          	auipc	ra,0x3
    2272:	3f4080e7          	jalr	1012(ra) # 5662 <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2276:	85a6                	mv	a1,s1
    2278:	00005517          	auipc	a0,0x5
    227c:	96850513          	addi	a0,a0,-1688 # 6be0 <malloc+0x113e>
    2280:	00003097          	auipc	ra,0x3
    2284:	762080e7          	jalr	1890(ra) # 59e2 <printf>
    exit(1);
    2288:	4505                	li	a0,1
    228a:	00003097          	auipc	ra,0x3
    228e:	3d8080e7          	jalr	984(ra) # 5662 <exit>
    exit(xstatus);
    2292:	00003097          	auipc	ra,0x3
    2296:	3d0080e7          	jalr	976(ra) # 5662 <exit>
    printf("%s: bigarg test failed!\n", s);
    229a:	85a6                	mv	a1,s1
    229c:	00005517          	auipc	a0,0x5
    22a0:	96450513          	addi	a0,a0,-1692 # 6c00 <malloc+0x115e>
    22a4:	00003097          	auipc	ra,0x3
    22a8:	73e080e7          	jalr	1854(ra) # 59e2 <printf>
    exit(1);
    22ac:	4505                	li	a0,1
    22ae:	00003097          	auipc	ra,0x3
    22b2:	3b4080e7          	jalr	948(ra) # 5662 <exit>

00000000000022b6 <stacktest>:
{
    22b6:	7179                	addi	sp,sp,-48
    22b8:	f406                	sd	ra,40(sp)
    22ba:	f022                	sd	s0,32(sp)
    22bc:	ec26                	sd	s1,24(sp)
    22be:	1800                	addi	s0,sp,48
    22c0:	84aa                	mv	s1,a0
  pid = fork();
    22c2:	00003097          	auipc	ra,0x3
    22c6:	398080e7          	jalr	920(ra) # 565a <fork>
  if(pid == 0) {
    22ca:	c115                	beqz	a0,22ee <stacktest+0x38>
  } else if(pid < 0){
    22cc:	04054463          	bltz	a0,2314 <stacktest+0x5e>
  wait(&xstatus);
    22d0:	fdc40513          	addi	a0,s0,-36
    22d4:	00003097          	auipc	ra,0x3
    22d8:	396080e7          	jalr	918(ra) # 566a <wait>
  if(xstatus == -1)  // kernel killed child?
    22dc:	fdc42503          	lw	a0,-36(s0)
    22e0:	57fd                	li	a5,-1
    22e2:	04f50763          	beq	a0,a5,2330 <stacktest+0x7a>
    exit(xstatus);
    22e6:	00003097          	auipc	ra,0x3
    22ea:	37c080e7          	jalr	892(ra) # 5662 <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    22ee:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    22f0:	77fd                	lui	a5,0xfffff
    22f2:	97ba                	add	a5,a5,a4
    22f4:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <_end+0xffffffffffff04f8>
    22f8:	85a6                	mv	a1,s1
    22fa:	00005517          	auipc	a0,0x5
    22fe:	92650513          	addi	a0,a0,-1754 # 6c20 <malloc+0x117e>
    2302:	00003097          	auipc	ra,0x3
    2306:	6e0080e7          	jalr	1760(ra) # 59e2 <printf>
    exit(1);
    230a:	4505                	li	a0,1
    230c:	00003097          	auipc	ra,0x3
    2310:	356080e7          	jalr	854(ra) # 5662 <exit>
    printf("%s: fork failed\n", s);
    2314:	85a6                	mv	a1,s1
    2316:	00004517          	auipc	a0,0x4
    231a:	4d250513          	addi	a0,a0,1234 # 67e8 <malloc+0xd46>
    231e:	00003097          	auipc	ra,0x3
    2322:	6c4080e7          	jalr	1732(ra) # 59e2 <printf>
    exit(1);
    2326:	4505                	li	a0,1
    2328:	00003097          	auipc	ra,0x3
    232c:	33a080e7          	jalr	826(ra) # 5662 <exit>
    exit(0);
    2330:	4501                	li	a0,0
    2332:	00003097          	auipc	ra,0x3
    2336:	330080e7          	jalr	816(ra) # 5662 <exit>

000000000000233a <copyinstr3>:
{
    233a:	7179                	addi	sp,sp,-48
    233c:	f406                	sd	ra,40(sp)
    233e:	f022                	sd	s0,32(sp)
    2340:	ec26                	sd	s1,24(sp)
    2342:	1800                	addi	s0,sp,48
  sbrk(8192);
    2344:	6509                	lui	a0,0x2
    2346:	00003097          	auipc	ra,0x3
    234a:	3a4080e7          	jalr	932(ra) # 56ea <sbrk>
  uint64 top = (uint64) sbrk(0);
    234e:	4501                	li	a0,0
    2350:	00003097          	auipc	ra,0x3
    2354:	39a080e7          	jalr	922(ra) # 56ea <sbrk>
  if((top % PGSIZE) != 0){
    2358:	6785                	lui	a5,0x1
    235a:	17fd                	addi	a5,a5,-1
    235c:	8fe9                	and	a5,a5,a0
    235e:	e3d1                	bnez	a5,23e2 <copyinstr3+0xa8>
  top = (uint64) sbrk(0);
    2360:	4501                	li	a0,0
    2362:	00003097          	auipc	ra,0x3
    2366:	388080e7          	jalr	904(ra) # 56ea <sbrk>
  if(top % PGSIZE){
    236a:	6785                	lui	a5,0x1
    236c:	17fd                	addi	a5,a5,-1
    236e:	8fe9                	and	a5,a5,a0
    2370:	e7c1                	bnez	a5,23f8 <copyinstr3+0xbe>
  char *b = (char *) (top - 1);
    2372:	fff50493          	addi	s1,a0,-1 # 1fff <manywrites+0x125>
  *b = 'x';
    2376:	07800793          	li	a5,120
    237a:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    237e:	8526                	mv	a0,s1
    2380:	00003097          	auipc	ra,0x3
    2384:	332080e7          	jalr	818(ra) # 56b2 <unlink>
  if(ret != -1){
    2388:	57fd                	li	a5,-1
    238a:	08f51463          	bne	a0,a5,2412 <copyinstr3+0xd8>
  int fd = open(b, O_CREATE | O_WRONLY);
    238e:	20100593          	li	a1,513
    2392:	8526                	mv	a0,s1
    2394:	00003097          	auipc	ra,0x3
    2398:	30e080e7          	jalr	782(ra) # 56a2 <open>
  if(fd != -1){
    239c:	57fd                	li	a5,-1
    239e:	08f51963          	bne	a0,a5,2430 <copyinstr3+0xf6>
  ret = link(b, b);
    23a2:	85a6                	mv	a1,s1
    23a4:	8526                	mv	a0,s1
    23a6:	00003097          	auipc	ra,0x3
    23aa:	31c080e7          	jalr	796(ra) # 56c2 <link>
  if(ret != -1){
    23ae:	57fd                	li	a5,-1
    23b0:	08f51f63          	bne	a0,a5,244e <copyinstr3+0x114>
  char *args[] = { "xx", 0 };
    23b4:	00005797          	auipc	a5,0x5
    23b8:	51478793          	addi	a5,a5,1300 # 78c8 <malloc+0x1e26>
    23bc:	fcf43823          	sd	a5,-48(s0)
    23c0:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    23c4:	fd040593          	addi	a1,s0,-48
    23c8:	8526                	mv	a0,s1
    23ca:	00003097          	auipc	ra,0x3
    23ce:	2d0080e7          	jalr	720(ra) # 569a <exec>
  if(ret != -1){
    23d2:	57fd                	li	a5,-1
    23d4:	08f51d63          	bne	a0,a5,246e <copyinstr3+0x134>
}
    23d8:	70a2                	ld	ra,40(sp)
    23da:	7402                	ld	s0,32(sp)
    23dc:	64e2                	ld	s1,24(sp)
    23de:	6145                	addi	sp,sp,48
    23e0:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    23e2:	6785                	lui	a5,0x1
    23e4:	17fd                	addi	a5,a5,-1
    23e6:	8d7d                	and	a0,a0,a5
    23e8:	6785                	lui	a5,0x1
    23ea:	40a7853b          	subw	a0,a5,a0
    23ee:	00003097          	auipc	ra,0x3
    23f2:	2fc080e7          	jalr	764(ra) # 56ea <sbrk>
    23f6:	b7ad                	j	2360 <copyinstr3+0x26>
    printf("oops\n");
    23f8:	00005517          	auipc	a0,0x5
    23fc:	85050513          	addi	a0,a0,-1968 # 6c48 <malloc+0x11a6>
    2400:	00003097          	auipc	ra,0x3
    2404:	5e2080e7          	jalr	1506(ra) # 59e2 <printf>
    exit(1);
    2408:	4505                	li	a0,1
    240a:	00003097          	auipc	ra,0x3
    240e:	258080e7          	jalr	600(ra) # 5662 <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    2412:	862a                	mv	a2,a0
    2414:	85a6                	mv	a1,s1
    2416:	00004517          	auipc	a0,0x4
    241a:	2f250513          	addi	a0,a0,754 # 6708 <malloc+0xc66>
    241e:	00003097          	auipc	ra,0x3
    2422:	5c4080e7          	jalr	1476(ra) # 59e2 <printf>
    exit(1);
    2426:	4505                	li	a0,1
    2428:	00003097          	auipc	ra,0x3
    242c:	23a080e7          	jalr	570(ra) # 5662 <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    2430:	862a                	mv	a2,a0
    2432:	85a6                	mv	a1,s1
    2434:	00004517          	auipc	a0,0x4
    2438:	2f450513          	addi	a0,a0,756 # 6728 <malloc+0xc86>
    243c:	00003097          	auipc	ra,0x3
    2440:	5a6080e7          	jalr	1446(ra) # 59e2 <printf>
    exit(1);
    2444:	4505                	li	a0,1
    2446:	00003097          	auipc	ra,0x3
    244a:	21c080e7          	jalr	540(ra) # 5662 <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    244e:	86aa                	mv	a3,a0
    2450:	8626                	mv	a2,s1
    2452:	85a6                	mv	a1,s1
    2454:	00004517          	auipc	a0,0x4
    2458:	2f450513          	addi	a0,a0,756 # 6748 <malloc+0xca6>
    245c:	00003097          	auipc	ra,0x3
    2460:	586080e7          	jalr	1414(ra) # 59e2 <printf>
    exit(1);
    2464:	4505                	li	a0,1
    2466:	00003097          	auipc	ra,0x3
    246a:	1fc080e7          	jalr	508(ra) # 5662 <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    246e:	567d                	li	a2,-1
    2470:	85a6                	mv	a1,s1
    2472:	00004517          	auipc	a0,0x4
    2476:	2fe50513          	addi	a0,a0,766 # 6770 <malloc+0xcce>
    247a:	00003097          	auipc	ra,0x3
    247e:	568080e7          	jalr	1384(ra) # 59e2 <printf>
    exit(1);
    2482:	4505                	li	a0,1
    2484:	00003097          	auipc	ra,0x3
    2488:	1de080e7          	jalr	478(ra) # 5662 <exit>

000000000000248c <rwsbrk>:
{
    248c:	1101                	addi	sp,sp,-32
    248e:	ec06                	sd	ra,24(sp)
    2490:	e822                	sd	s0,16(sp)
    2492:	e426                	sd	s1,8(sp)
    2494:	e04a                	sd	s2,0(sp)
    2496:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2498:	6509                	lui	a0,0x2
    249a:	00003097          	auipc	ra,0x3
    249e:	250080e7          	jalr	592(ra) # 56ea <sbrk>
  if(a == 0xffffffffffffffffLL) {
    24a2:	57fd                	li	a5,-1
    24a4:	06f50263          	beq	a0,a5,2508 <rwsbrk+0x7c>
    24a8:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    24aa:	7579                	lui	a0,0xffffe
    24ac:	00003097          	auipc	ra,0x3
    24b0:	23e080e7          	jalr	574(ra) # 56ea <sbrk>
    24b4:	57fd                	li	a5,-1
    24b6:	06f50663          	beq	a0,a5,2522 <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    24ba:	20100593          	li	a1,513
    24be:	00004517          	auipc	a0,0x4
    24c2:	7ca50513          	addi	a0,a0,1994 # 6c88 <malloc+0x11e6>
    24c6:	00003097          	auipc	ra,0x3
    24ca:	1dc080e7          	jalr	476(ra) # 56a2 <open>
    24ce:	892a                	mv	s2,a0
  if(fd < 0){
    24d0:	06054663          	bltz	a0,253c <rwsbrk+0xb0>
  n = write(fd, (void*)(a+4096), 1024);
    24d4:	6785                	lui	a5,0x1
    24d6:	94be                	add	s1,s1,a5
    24d8:	40000613          	li	a2,1024
    24dc:	85a6                	mv	a1,s1
    24de:	00003097          	auipc	ra,0x3
    24e2:	1a4080e7          	jalr	420(ra) # 5682 <write>
  if(n >= 0){
    24e6:	06054863          	bltz	a0,2556 <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    24ea:	862a                	mv	a2,a0
    24ec:	85a6                	mv	a1,s1
    24ee:	00004517          	auipc	a0,0x4
    24f2:	7ba50513          	addi	a0,a0,1978 # 6ca8 <malloc+0x1206>
    24f6:	00003097          	auipc	ra,0x3
    24fa:	4ec080e7          	jalr	1260(ra) # 59e2 <printf>
    exit(1);
    24fe:	4505                	li	a0,1
    2500:	00003097          	auipc	ra,0x3
    2504:	162080e7          	jalr	354(ra) # 5662 <exit>
    printf("sbrk(rwsbrk) failed\n");
    2508:	00004517          	auipc	a0,0x4
    250c:	74850513          	addi	a0,a0,1864 # 6c50 <malloc+0x11ae>
    2510:	00003097          	auipc	ra,0x3
    2514:	4d2080e7          	jalr	1234(ra) # 59e2 <printf>
    exit(1);
    2518:	4505                	li	a0,1
    251a:	00003097          	auipc	ra,0x3
    251e:	148080e7          	jalr	328(ra) # 5662 <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    2522:	00004517          	auipc	a0,0x4
    2526:	74650513          	addi	a0,a0,1862 # 6c68 <malloc+0x11c6>
    252a:	00003097          	auipc	ra,0x3
    252e:	4b8080e7          	jalr	1208(ra) # 59e2 <printf>
    exit(1);
    2532:	4505                	li	a0,1
    2534:	00003097          	auipc	ra,0x3
    2538:	12e080e7          	jalr	302(ra) # 5662 <exit>
    printf("open(rwsbrk) failed\n");
    253c:	00004517          	auipc	a0,0x4
    2540:	75450513          	addi	a0,a0,1876 # 6c90 <malloc+0x11ee>
    2544:	00003097          	auipc	ra,0x3
    2548:	49e080e7          	jalr	1182(ra) # 59e2 <printf>
    exit(1);
    254c:	4505                	li	a0,1
    254e:	00003097          	auipc	ra,0x3
    2552:	114080e7          	jalr	276(ra) # 5662 <exit>
  close(fd);
    2556:	854a                	mv	a0,s2
    2558:	00003097          	auipc	ra,0x3
    255c:	132080e7          	jalr	306(ra) # 568a <close>
  unlink("rwsbrk");
    2560:	00004517          	auipc	a0,0x4
    2564:	72850513          	addi	a0,a0,1832 # 6c88 <malloc+0x11e6>
    2568:	00003097          	auipc	ra,0x3
    256c:	14a080e7          	jalr	330(ra) # 56b2 <unlink>
  fd = open("README", O_RDONLY);
    2570:	4581                	li	a1,0
    2572:	00004517          	auipc	a0,0x4
    2576:	bc650513          	addi	a0,a0,-1082 # 6138 <malloc+0x696>
    257a:	00003097          	auipc	ra,0x3
    257e:	128080e7          	jalr	296(ra) # 56a2 <open>
    2582:	892a                	mv	s2,a0
  if(fd < 0){
    2584:	02054963          	bltz	a0,25b6 <rwsbrk+0x12a>
  n = read(fd, (void*)(a+4096), 10);
    2588:	4629                	li	a2,10
    258a:	85a6                	mv	a1,s1
    258c:	00003097          	auipc	ra,0x3
    2590:	0ee080e7          	jalr	238(ra) # 567a <read>
  if(n >= 0){
    2594:	02054e63          	bltz	a0,25d0 <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2598:	862a                	mv	a2,a0
    259a:	85a6                	mv	a1,s1
    259c:	00004517          	auipc	a0,0x4
    25a0:	73c50513          	addi	a0,a0,1852 # 6cd8 <malloc+0x1236>
    25a4:	00003097          	auipc	ra,0x3
    25a8:	43e080e7          	jalr	1086(ra) # 59e2 <printf>
    exit(1);
    25ac:	4505                	li	a0,1
    25ae:	00003097          	auipc	ra,0x3
    25b2:	0b4080e7          	jalr	180(ra) # 5662 <exit>
    printf("open(rwsbrk) failed\n");
    25b6:	00004517          	auipc	a0,0x4
    25ba:	6da50513          	addi	a0,a0,1754 # 6c90 <malloc+0x11ee>
    25be:	00003097          	auipc	ra,0x3
    25c2:	424080e7          	jalr	1060(ra) # 59e2 <printf>
    exit(1);
    25c6:	4505                	li	a0,1
    25c8:	00003097          	auipc	ra,0x3
    25cc:	09a080e7          	jalr	154(ra) # 5662 <exit>
  close(fd);
    25d0:	854a                	mv	a0,s2
    25d2:	00003097          	auipc	ra,0x3
    25d6:	0b8080e7          	jalr	184(ra) # 568a <close>
  exit(0);
    25da:	4501                	li	a0,0
    25dc:	00003097          	auipc	ra,0x3
    25e0:	086080e7          	jalr	134(ra) # 5662 <exit>

00000000000025e4 <sbrkbasic>:
{
    25e4:	715d                	addi	sp,sp,-80
    25e6:	e486                	sd	ra,72(sp)
    25e8:	e0a2                	sd	s0,64(sp)
    25ea:	fc26                	sd	s1,56(sp)
    25ec:	f84a                	sd	s2,48(sp)
    25ee:	f44e                	sd	s3,40(sp)
    25f0:	f052                	sd	s4,32(sp)
    25f2:	ec56                	sd	s5,24(sp)
    25f4:	0880                	addi	s0,sp,80
    25f6:	8aaa                	mv	s5,a0
  pid = fork();
    25f8:	00003097          	auipc	ra,0x3
    25fc:	062080e7          	jalr	98(ra) # 565a <fork>
  if(pid < 0){
    2600:	02054c63          	bltz	a0,2638 <sbrkbasic+0x54>
  if(pid == 0){
    2604:	ed21                	bnez	a0,265c <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    2606:	40000537          	lui	a0,0x40000
    260a:	00003097          	auipc	ra,0x3
    260e:	0e0080e7          	jalr	224(ra) # 56ea <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    2612:	57fd                	li	a5,-1
    2614:	02f50f63          	beq	a0,a5,2652 <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2618:	400007b7          	lui	a5,0x40000
    261c:	97aa                	add	a5,a5,a0
      *b = 99;
    261e:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    2622:	6705                	lui	a4,0x1
      *b = 99;
    2624:	00d50023          	sb	a3,0(a0) # 40000000 <_end+0x3fff14f8>
    for(b = a; b < a+TOOMUCH; b += 4096){
    2628:	953a                	add	a0,a0,a4
    262a:	fef51de3          	bne	a0,a5,2624 <sbrkbasic+0x40>
    exit(1);
    262e:	4505                	li	a0,1
    2630:	00003097          	auipc	ra,0x3
    2634:	032080e7          	jalr	50(ra) # 5662 <exit>
    printf("fork failed in sbrkbasic\n");
    2638:	00004517          	auipc	a0,0x4
    263c:	6c850513          	addi	a0,a0,1736 # 6d00 <malloc+0x125e>
    2640:	00003097          	auipc	ra,0x3
    2644:	3a2080e7          	jalr	930(ra) # 59e2 <printf>
    exit(1);
    2648:	4505                	li	a0,1
    264a:	00003097          	auipc	ra,0x3
    264e:	018080e7          	jalr	24(ra) # 5662 <exit>
      exit(0);
    2652:	4501                	li	a0,0
    2654:	00003097          	auipc	ra,0x3
    2658:	00e080e7          	jalr	14(ra) # 5662 <exit>
  wait(&xstatus);
    265c:	fbc40513          	addi	a0,s0,-68
    2660:	00003097          	auipc	ra,0x3
    2664:	00a080e7          	jalr	10(ra) # 566a <wait>
  if(xstatus == 1){
    2668:	fbc42703          	lw	a4,-68(s0)
    266c:	4785                	li	a5,1
    266e:	00f70e63          	beq	a4,a5,268a <sbrkbasic+0xa6>
  a = sbrk(0);
    2672:	4501                	li	a0,0
    2674:	00003097          	auipc	ra,0x3
    2678:	076080e7          	jalr	118(ra) # 56ea <sbrk>
    267c:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    267e:	4901                	li	s2,0
    *b = 1;
    2680:	4a05                	li	s4,1
  for(i = 0; i < 5000; i++){
    2682:	6985                	lui	s3,0x1
    2684:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1c0>
    2688:	a005                	j	26a8 <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    268a:	85d6                	mv	a1,s5
    268c:	00004517          	auipc	a0,0x4
    2690:	69450513          	addi	a0,a0,1684 # 6d20 <malloc+0x127e>
    2694:	00003097          	auipc	ra,0x3
    2698:	34e080e7          	jalr	846(ra) # 59e2 <printf>
    exit(1);
    269c:	4505                	li	a0,1
    269e:	00003097          	auipc	ra,0x3
    26a2:	fc4080e7          	jalr	-60(ra) # 5662 <exit>
    a = b + 1;
    26a6:	84be                	mv	s1,a5
    b = sbrk(1);
    26a8:	4505                	li	a0,1
    26aa:	00003097          	auipc	ra,0x3
    26ae:	040080e7          	jalr	64(ra) # 56ea <sbrk>
    if(b != a){
    26b2:	04951b63          	bne	a0,s1,2708 <sbrkbasic+0x124>
    *b = 1;
    26b6:	01448023          	sb	s4,0(s1)
    a = b + 1;
    26ba:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    26be:	2905                	addiw	s2,s2,1
    26c0:	ff3913e3          	bne	s2,s3,26a6 <sbrkbasic+0xc2>
  pid = fork();
    26c4:	00003097          	auipc	ra,0x3
    26c8:	f96080e7          	jalr	-106(ra) # 565a <fork>
    26cc:	892a                	mv	s2,a0
  if(pid < 0){
    26ce:	04054d63          	bltz	a0,2728 <sbrkbasic+0x144>
  c = sbrk(1);
    26d2:	4505                	li	a0,1
    26d4:	00003097          	auipc	ra,0x3
    26d8:	016080e7          	jalr	22(ra) # 56ea <sbrk>
  c = sbrk(1);
    26dc:	4505                	li	a0,1
    26de:	00003097          	auipc	ra,0x3
    26e2:	00c080e7          	jalr	12(ra) # 56ea <sbrk>
  if(c != a + 1){
    26e6:	0489                	addi	s1,s1,2
    26e8:	04a48e63          	beq	s1,a0,2744 <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    26ec:	85d6                	mv	a1,s5
    26ee:	00004517          	auipc	a0,0x4
    26f2:	69250513          	addi	a0,a0,1682 # 6d80 <malloc+0x12de>
    26f6:	00003097          	auipc	ra,0x3
    26fa:	2ec080e7          	jalr	748(ra) # 59e2 <printf>
    exit(1);
    26fe:	4505                	li	a0,1
    2700:	00003097          	auipc	ra,0x3
    2704:	f62080e7          	jalr	-158(ra) # 5662 <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    2708:	86aa                	mv	a3,a0
    270a:	8626                	mv	a2,s1
    270c:	85ca                	mv	a1,s2
    270e:	00004517          	auipc	a0,0x4
    2712:	63250513          	addi	a0,a0,1586 # 6d40 <malloc+0x129e>
    2716:	00003097          	auipc	ra,0x3
    271a:	2cc080e7          	jalr	716(ra) # 59e2 <printf>
      exit(1);
    271e:	4505                	li	a0,1
    2720:	00003097          	auipc	ra,0x3
    2724:	f42080e7          	jalr	-190(ra) # 5662 <exit>
    printf("%s: sbrk test fork failed\n", s);
    2728:	85d6                	mv	a1,s5
    272a:	00004517          	auipc	a0,0x4
    272e:	63650513          	addi	a0,a0,1590 # 6d60 <malloc+0x12be>
    2732:	00003097          	auipc	ra,0x3
    2736:	2b0080e7          	jalr	688(ra) # 59e2 <printf>
    exit(1);
    273a:	4505                	li	a0,1
    273c:	00003097          	auipc	ra,0x3
    2740:	f26080e7          	jalr	-218(ra) # 5662 <exit>
  if(pid == 0)
    2744:	00091763          	bnez	s2,2752 <sbrkbasic+0x16e>
    exit(0);
    2748:	4501                	li	a0,0
    274a:	00003097          	auipc	ra,0x3
    274e:	f18080e7          	jalr	-232(ra) # 5662 <exit>
  wait(&xstatus);
    2752:	fbc40513          	addi	a0,s0,-68
    2756:	00003097          	auipc	ra,0x3
    275a:	f14080e7          	jalr	-236(ra) # 566a <wait>
  exit(xstatus);
    275e:	fbc42503          	lw	a0,-68(s0)
    2762:	00003097          	auipc	ra,0x3
    2766:	f00080e7          	jalr	-256(ra) # 5662 <exit>

000000000000276a <sbrkmuch>:
{
    276a:	7179                	addi	sp,sp,-48
    276c:	f406                	sd	ra,40(sp)
    276e:	f022                	sd	s0,32(sp)
    2770:	ec26                	sd	s1,24(sp)
    2772:	e84a                	sd	s2,16(sp)
    2774:	e44e                	sd	s3,8(sp)
    2776:	e052                	sd	s4,0(sp)
    2778:	1800                	addi	s0,sp,48
    277a:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    277c:	4501                	li	a0,0
    277e:	00003097          	auipc	ra,0x3
    2782:	f6c080e7          	jalr	-148(ra) # 56ea <sbrk>
    2786:	892a                	mv	s2,a0
  a = sbrk(0);
    2788:	4501                	li	a0,0
    278a:	00003097          	auipc	ra,0x3
    278e:	f60080e7          	jalr	-160(ra) # 56ea <sbrk>
    2792:	84aa                	mv	s1,a0
  p = sbrk(amt);
    2794:	06400537          	lui	a0,0x6400
    2798:	9d05                	subw	a0,a0,s1
    279a:	00003097          	auipc	ra,0x3
    279e:	f50080e7          	jalr	-176(ra) # 56ea <sbrk>
  if (p != a) {
    27a2:	0ca49763          	bne	s1,a0,2870 <sbrkmuch+0x106>
  char *eee = sbrk(0);
    27a6:	4501                	li	a0,0
    27a8:	00003097          	auipc	ra,0x3
    27ac:	f42080e7          	jalr	-190(ra) # 56ea <sbrk>
  for(char *pp = a; pp < eee; pp += 4096)
    27b0:	00a4f963          	bleu	a0,s1,27c2 <sbrkmuch+0x58>
    *pp = 1;
    27b4:	4705                	li	a4,1
  for(char *pp = a; pp < eee; pp += 4096)
    27b6:	6785                	lui	a5,0x1
    *pp = 1;
    27b8:	00e48023          	sb	a4,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    27bc:	94be                	add	s1,s1,a5
    27be:	fea4ede3          	bltu	s1,a0,27b8 <sbrkmuch+0x4e>
  *lastaddr = 99;
    27c2:	064007b7          	lui	a5,0x6400
    27c6:	06300713          	li	a4,99
    27ca:	fee78fa3          	sb	a4,-1(a5) # 63fffff <_end+0x63f14f7>
  a = sbrk(0);
    27ce:	4501                	li	a0,0
    27d0:	00003097          	auipc	ra,0x3
    27d4:	f1a080e7          	jalr	-230(ra) # 56ea <sbrk>
    27d8:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    27da:	757d                	lui	a0,0xfffff
    27dc:	00003097          	auipc	ra,0x3
    27e0:	f0e080e7          	jalr	-242(ra) # 56ea <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    27e4:	57fd                	li	a5,-1
    27e6:	0af50363          	beq	a0,a5,288c <sbrkmuch+0x122>
  c = sbrk(0);
    27ea:	4501                	li	a0,0
    27ec:	00003097          	auipc	ra,0x3
    27f0:	efe080e7          	jalr	-258(ra) # 56ea <sbrk>
  if(c != a - PGSIZE){
    27f4:	77fd                	lui	a5,0xfffff
    27f6:	97a6                	add	a5,a5,s1
    27f8:	0af51863          	bne	a0,a5,28a8 <sbrkmuch+0x13e>
  a = sbrk(0);
    27fc:	4501                	li	a0,0
    27fe:	00003097          	auipc	ra,0x3
    2802:	eec080e7          	jalr	-276(ra) # 56ea <sbrk>
    2806:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    2808:	6505                	lui	a0,0x1
    280a:	00003097          	auipc	ra,0x3
    280e:	ee0080e7          	jalr	-288(ra) # 56ea <sbrk>
    2812:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    2814:	0aa49a63          	bne	s1,a0,28c8 <sbrkmuch+0x15e>
    2818:	4501                	li	a0,0
    281a:	00003097          	auipc	ra,0x3
    281e:	ed0080e7          	jalr	-304(ra) # 56ea <sbrk>
    2822:	6785                	lui	a5,0x1
    2824:	97a6                	add	a5,a5,s1
    2826:	0af51163          	bne	a0,a5,28c8 <sbrkmuch+0x15e>
  if(*lastaddr == 99){
    282a:	064007b7          	lui	a5,0x6400
    282e:	fff7c703          	lbu	a4,-1(a5) # 63fffff <_end+0x63f14f7>
    2832:	06300793          	li	a5,99
    2836:	0af70963          	beq	a4,a5,28e8 <sbrkmuch+0x17e>
  a = sbrk(0);
    283a:	4501                	li	a0,0
    283c:	00003097          	auipc	ra,0x3
    2840:	eae080e7          	jalr	-338(ra) # 56ea <sbrk>
    2844:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    2846:	4501                	li	a0,0
    2848:	00003097          	auipc	ra,0x3
    284c:	ea2080e7          	jalr	-350(ra) # 56ea <sbrk>
    2850:	40a9053b          	subw	a0,s2,a0
    2854:	00003097          	auipc	ra,0x3
    2858:	e96080e7          	jalr	-362(ra) # 56ea <sbrk>
  if(c != a){
    285c:	0aa49463          	bne	s1,a0,2904 <sbrkmuch+0x19a>
}
    2860:	70a2                	ld	ra,40(sp)
    2862:	7402                	ld	s0,32(sp)
    2864:	64e2                	ld	s1,24(sp)
    2866:	6942                	ld	s2,16(sp)
    2868:	69a2                	ld	s3,8(sp)
    286a:	6a02                	ld	s4,0(sp)
    286c:	6145                	addi	sp,sp,48
    286e:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2870:	85ce                	mv	a1,s3
    2872:	00004517          	auipc	a0,0x4
    2876:	52e50513          	addi	a0,a0,1326 # 6da0 <malloc+0x12fe>
    287a:	00003097          	auipc	ra,0x3
    287e:	168080e7          	jalr	360(ra) # 59e2 <printf>
    exit(1);
    2882:	4505                	li	a0,1
    2884:	00003097          	auipc	ra,0x3
    2888:	dde080e7          	jalr	-546(ra) # 5662 <exit>
    printf("%s: sbrk could not deallocate\n", s);
    288c:	85ce                	mv	a1,s3
    288e:	00004517          	auipc	a0,0x4
    2892:	55a50513          	addi	a0,a0,1370 # 6de8 <malloc+0x1346>
    2896:	00003097          	auipc	ra,0x3
    289a:	14c080e7          	jalr	332(ra) # 59e2 <printf>
    exit(1);
    289e:	4505                	li	a0,1
    28a0:	00003097          	auipc	ra,0x3
    28a4:	dc2080e7          	jalr	-574(ra) # 5662 <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    28a8:	86aa                	mv	a3,a0
    28aa:	8626                	mv	a2,s1
    28ac:	85ce                	mv	a1,s3
    28ae:	00004517          	auipc	a0,0x4
    28b2:	55a50513          	addi	a0,a0,1370 # 6e08 <malloc+0x1366>
    28b6:	00003097          	auipc	ra,0x3
    28ba:	12c080e7          	jalr	300(ra) # 59e2 <printf>
    exit(1);
    28be:	4505                	li	a0,1
    28c0:	00003097          	auipc	ra,0x3
    28c4:	da2080e7          	jalr	-606(ra) # 5662 <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    28c8:	86d2                	mv	a3,s4
    28ca:	8626                	mv	a2,s1
    28cc:	85ce                	mv	a1,s3
    28ce:	00004517          	auipc	a0,0x4
    28d2:	57a50513          	addi	a0,a0,1402 # 6e48 <malloc+0x13a6>
    28d6:	00003097          	auipc	ra,0x3
    28da:	10c080e7          	jalr	268(ra) # 59e2 <printf>
    exit(1);
    28de:	4505                	li	a0,1
    28e0:	00003097          	auipc	ra,0x3
    28e4:	d82080e7          	jalr	-638(ra) # 5662 <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    28e8:	85ce                	mv	a1,s3
    28ea:	00004517          	auipc	a0,0x4
    28ee:	58e50513          	addi	a0,a0,1422 # 6e78 <malloc+0x13d6>
    28f2:	00003097          	auipc	ra,0x3
    28f6:	0f0080e7          	jalr	240(ra) # 59e2 <printf>
    exit(1);
    28fa:	4505                	li	a0,1
    28fc:	00003097          	auipc	ra,0x3
    2900:	d66080e7          	jalr	-666(ra) # 5662 <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    2904:	86aa                	mv	a3,a0
    2906:	8626                	mv	a2,s1
    2908:	85ce                	mv	a1,s3
    290a:	00004517          	auipc	a0,0x4
    290e:	5a650513          	addi	a0,a0,1446 # 6eb0 <malloc+0x140e>
    2912:	00003097          	auipc	ra,0x3
    2916:	0d0080e7          	jalr	208(ra) # 59e2 <printf>
    exit(1);
    291a:	4505                	li	a0,1
    291c:	00003097          	auipc	ra,0x3
    2920:	d46080e7          	jalr	-698(ra) # 5662 <exit>

0000000000002924 <sbrkarg>:
{
    2924:	7179                	addi	sp,sp,-48
    2926:	f406                	sd	ra,40(sp)
    2928:	f022                	sd	s0,32(sp)
    292a:	ec26                	sd	s1,24(sp)
    292c:	e84a                	sd	s2,16(sp)
    292e:	e44e                	sd	s3,8(sp)
    2930:	1800                	addi	s0,sp,48
    2932:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    2934:	6505                	lui	a0,0x1
    2936:	00003097          	auipc	ra,0x3
    293a:	db4080e7          	jalr	-588(ra) # 56ea <sbrk>
    293e:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2940:	20100593          	li	a1,513
    2944:	00004517          	auipc	a0,0x4
    2948:	59450513          	addi	a0,a0,1428 # 6ed8 <malloc+0x1436>
    294c:	00003097          	auipc	ra,0x3
    2950:	d56080e7          	jalr	-682(ra) # 56a2 <open>
    2954:	84aa                	mv	s1,a0
  unlink("sbrk");
    2956:	00004517          	auipc	a0,0x4
    295a:	58250513          	addi	a0,a0,1410 # 6ed8 <malloc+0x1436>
    295e:	00003097          	auipc	ra,0x3
    2962:	d54080e7          	jalr	-684(ra) # 56b2 <unlink>
  if(fd < 0)  {
    2966:	0404c163          	bltz	s1,29a8 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    296a:	6605                	lui	a2,0x1
    296c:	85ca                	mv	a1,s2
    296e:	8526                	mv	a0,s1
    2970:	00003097          	auipc	ra,0x3
    2974:	d12080e7          	jalr	-750(ra) # 5682 <write>
    2978:	04054663          	bltz	a0,29c4 <sbrkarg+0xa0>
  close(fd);
    297c:	8526                	mv	a0,s1
    297e:	00003097          	auipc	ra,0x3
    2982:	d0c080e7          	jalr	-756(ra) # 568a <close>
  a = sbrk(PGSIZE);
    2986:	6505                	lui	a0,0x1
    2988:	00003097          	auipc	ra,0x3
    298c:	d62080e7          	jalr	-670(ra) # 56ea <sbrk>
  if(pipe((int *) a) != 0){
    2990:	00003097          	auipc	ra,0x3
    2994:	ce2080e7          	jalr	-798(ra) # 5672 <pipe>
    2998:	e521                	bnez	a0,29e0 <sbrkarg+0xbc>
}
    299a:	70a2                	ld	ra,40(sp)
    299c:	7402                	ld	s0,32(sp)
    299e:	64e2                	ld	s1,24(sp)
    29a0:	6942                	ld	s2,16(sp)
    29a2:	69a2                	ld	s3,8(sp)
    29a4:	6145                	addi	sp,sp,48
    29a6:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    29a8:	85ce                	mv	a1,s3
    29aa:	00004517          	auipc	a0,0x4
    29ae:	53650513          	addi	a0,a0,1334 # 6ee0 <malloc+0x143e>
    29b2:	00003097          	auipc	ra,0x3
    29b6:	030080e7          	jalr	48(ra) # 59e2 <printf>
    exit(1);
    29ba:	4505                	li	a0,1
    29bc:	00003097          	auipc	ra,0x3
    29c0:	ca6080e7          	jalr	-858(ra) # 5662 <exit>
    printf("%s: write sbrk failed\n", s);
    29c4:	85ce                	mv	a1,s3
    29c6:	00004517          	auipc	a0,0x4
    29ca:	53250513          	addi	a0,a0,1330 # 6ef8 <malloc+0x1456>
    29ce:	00003097          	auipc	ra,0x3
    29d2:	014080e7          	jalr	20(ra) # 59e2 <printf>
    exit(1);
    29d6:	4505                	li	a0,1
    29d8:	00003097          	auipc	ra,0x3
    29dc:	c8a080e7          	jalr	-886(ra) # 5662 <exit>
    printf("%s: pipe() failed\n", s);
    29e0:	85ce                	mv	a1,s3
    29e2:	00004517          	auipc	a0,0x4
    29e6:	f0e50513          	addi	a0,a0,-242 # 68f0 <malloc+0xe4e>
    29ea:	00003097          	auipc	ra,0x3
    29ee:	ff8080e7          	jalr	-8(ra) # 59e2 <printf>
    exit(1);
    29f2:	4505                	li	a0,1
    29f4:	00003097          	auipc	ra,0x3
    29f8:	c6e080e7          	jalr	-914(ra) # 5662 <exit>

00000000000029fc <argptest>:
{
    29fc:	1101                	addi	sp,sp,-32
    29fe:	ec06                	sd	ra,24(sp)
    2a00:	e822                	sd	s0,16(sp)
    2a02:	e426                	sd	s1,8(sp)
    2a04:	e04a                	sd	s2,0(sp)
    2a06:	1000                	addi	s0,sp,32
    2a08:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    2a0a:	4581                	li	a1,0
    2a0c:	00004517          	auipc	a0,0x4
    2a10:	50450513          	addi	a0,a0,1284 # 6f10 <malloc+0x146e>
    2a14:	00003097          	auipc	ra,0x3
    2a18:	c8e080e7          	jalr	-882(ra) # 56a2 <open>
  if (fd < 0) {
    2a1c:	02054b63          	bltz	a0,2a52 <argptest+0x56>
    2a20:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    2a22:	4501                	li	a0,0
    2a24:	00003097          	auipc	ra,0x3
    2a28:	cc6080e7          	jalr	-826(ra) # 56ea <sbrk>
    2a2c:	567d                	li	a2,-1
    2a2e:	fff50593          	addi	a1,a0,-1
    2a32:	8526                	mv	a0,s1
    2a34:	00003097          	auipc	ra,0x3
    2a38:	c46080e7          	jalr	-954(ra) # 567a <read>
  close(fd);
    2a3c:	8526                	mv	a0,s1
    2a3e:	00003097          	auipc	ra,0x3
    2a42:	c4c080e7          	jalr	-948(ra) # 568a <close>
}
    2a46:	60e2                	ld	ra,24(sp)
    2a48:	6442                	ld	s0,16(sp)
    2a4a:	64a2                	ld	s1,8(sp)
    2a4c:	6902                	ld	s2,0(sp)
    2a4e:	6105                	addi	sp,sp,32
    2a50:	8082                	ret
    printf("%s: open failed\n", s);
    2a52:	85ca                	mv	a1,s2
    2a54:	00004517          	auipc	a0,0x4
    2a58:	dac50513          	addi	a0,a0,-596 # 6800 <malloc+0xd5e>
    2a5c:	00003097          	auipc	ra,0x3
    2a60:	f86080e7          	jalr	-122(ra) # 59e2 <printf>
    exit(1);
    2a64:	4505                	li	a0,1
    2a66:	00003097          	auipc	ra,0x3
    2a6a:	bfc080e7          	jalr	-1028(ra) # 5662 <exit>

0000000000002a6e <sbrkbugs>:
{
    2a6e:	1141                	addi	sp,sp,-16
    2a70:	e406                	sd	ra,8(sp)
    2a72:	e022                	sd	s0,0(sp)
    2a74:	0800                	addi	s0,sp,16
  int pid = fork();
    2a76:	00003097          	auipc	ra,0x3
    2a7a:	be4080e7          	jalr	-1052(ra) # 565a <fork>
  if(pid < 0){
    2a7e:	02054363          	bltz	a0,2aa4 <sbrkbugs+0x36>
  if(pid == 0){
    2a82:	ed15                	bnez	a0,2abe <sbrkbugs+0x50>
    int sz = (uint64) sbrk(0);
    2a84:	00003097          	auipc	ra,0x3
    2a88:	c66080e7          	jalr	-922(ra) # 56ea <sbrk>
    sbrk(-sz);
    2a8c:	40a0053b          	negw	a0,a0
    2a90:	2501                	sext.w	a0,a0
    2a92:	00003097          	auipc	ra,0x3
    2a96:	c58080e7          	jalr	-936(ra) # 56ea <sbrk>
    exit(0);
    2a9a:	4501                	li	a0,0
    2a9c:	00003097          	auipc	ra,0x3
    2aa0:	bc6080e7          	jalr	-1082(ra) # 5662 <exit>
    printf("fork failed\n");
    2aa4:	00004517          	auipc	a0,0x4
    2aa8:	14c50513          	addi	a0,a0,332 # 6bf0 <malloc+0x114e>
    2aac:	00003097          	auipc	ra,0x3
    2ab0:	f36080e7          	jalr	-202(ra) # 59e2 <printf>
    exit(1);
    2ab4:	4505                	li	a0,1
    2ab6:	00003097          	auipc	ra,0x3
    2aba:	bac080e7          	jalr	-1108(ra) # 5662 <exit>
  wait(0);
    2abe:	4501                	li	a0,0
    2ac0:	00003097          	auipc	ra,0x3
    2ac4:	baa080e7          	jalr	-1110(ra) # 566a <wait>
  pid = fork();
    2ac8:	00003097          	auipc	ra,0x3
    2acc:	b92080e7          	jalr	-1134(ra) # 565a <fork>
  if(pid < 0){
    2ad0:	02054563          	bltz	a0,2afa <sbrkbugs+0x8c>
  if(pid == 0){
    2ad4:	e121                	bnez	a0,2b14 <sbrkbugs+0xa6>
    int sz = (uint64) sbrk(0);
    2ad6:	00003097          	auipc	ra,0x3
    2ada:	c14080e7          	jalr	-1004(ra) # 56ea <sbrk>
    sbrk(-(sz - 3500));
    2ade:	6785                	lui	a5,0x1
    2ae0:	dac7879b          	addiw	a5,a5,-596
    2ae4:	40a7853b          	subw	a0,a5,a0
    2ae8:	00003097          	auipc	ra,0x3
    2aec:	c02080e7          	jalr	-1022(ra) # 56ea <sbrk>
    exit(0);
    2af0:	4501                	li	a0,0
    2af2:	00003097          	auipc	ra,0x3
    2af6:	b70080e7          	jalr	-1168(ra) # 5662 <exit>
    printf("fork failed\n");
    2afa:	00004517          	auipc	a0,0x4
    2afe:	0f650513          	addi	a0,a0,246 # 6bf0 <malloc+0x114e>
    2b02:	00003097          	auipc	ra,0x3
    2b06:	ee0080e7          	jalr	-288(ra) # 59e2 <printf>
    exit(1);
    2b0a:	4505                	li	a0,1
    2b0c:	00003097          	auipc	ra,0x3
    2b10:	b56080e7          	jalr	-1194(ra) # 5662 <exit>
  wait(0);
    2b14:	4501                	li	a0,0
    2b16:	00003097          	auipc	ra,0x3
    2b1a:	b54080e7          	jalr	-1196(ra) # 566a <wait>
  pid = fork();
    2b1e:	00003097          	auipc	ra,0x3
    2b22:	b3c080e7          	jalr	-1220(ra) # 565a <fork>
  if(pid < 0){
    2b26:	02054a63          	bltz	a0,2b5a <sbrkbugs+0xec>
  if(pid == 0){
    2b2a:	e529                	bnez	a0,2b74 <sbrkbugs+0x106>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    2b2c:	00003097          	auipc	ra,0x3
    2b30:	bbe080e7          	jalr	-1090(ra) # 56ea <sbrk>
    2b34:	67ad                	lui	a5,0xb
    2b36:	8007879b          	addiw	a5,a5,-2048
    2b3a:	40a7853b          	subw	a0,a5,a0
    2b3e:	00003097          	auipc	ra,0x3
    2b42:	bac080e7          	jalr	-1108(ra) # 56ea <sbrk>
    sbrk(-10);
    2b46:	5559                	li	a0,-10
    2b48:	00003097          	auipc	ra,0x3
    2b4c:	ba2080e7          	jalr	-1118(ra) # 56ea <sbrk>
    exit(0);
    2b50:	4501                	li	a0,0
    2b52:	00003097          	auipc	ra,0x3
    2b56:	b10080e7          	jalr	-1264(ra) # 5662 <exit>
    printf("fork failed\n");
    2b5a:	00004517          	auipc	a0,0x4
    2b5e:	09650513          	addi	a0,a0,150 # 6bf0 <malloc+0x114e>
    2b62:	00003097          	auipc	ra,0x3
    2b66:	e80080e7          	jalr	-384(ra) # 59e2 <printf>
    exit(1);
    2b6a:	4505                	li	a0,1
    2b6c:	00003097          	auipc	ra,0x3
    2b70:	af6080e7          	jalr	-1290(ra) # 5662 <exit>
  wait(0);
    2b74:	4501                	li	a0,0
    2b76:	00003097          	auipc	ra,0x3
    2b7a:	af4080e7          	jalr	-1292(ra) # 566a <wait>
  exit(0);
    2b7e:	4501                	li	a0,0
    2b80:	00003097          	auipc	ra,0x3
    2b84:	ae2080e7          	jalr	-1310(ra) # 5662 <exit>

0000000000002b88 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2b88:	715d                	addi	sp,sp,-80
    2b8a:	e486                	sd	ra,72(sp)
    2b8c:	e0a2                	sd	s0,64(sp)
    2b8e:	fc26                	sd	s1,56(sp)
    2b90:	f84a                	sd	s2,48(sp)
    2b92:	f44e                	sd	s3,40(sp)
    2b94:	f052                	sd	s4,32(sp)
    2b96:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2b98:	4901                	li	s2,0
    2b9a:	49bd                	li	s3,15
    int pid = fork();
    2b9c:	00003097          	auipc	ra,0x3
    2ba0:	abe080e7          	jalr	-1346(ra) # 565a <fork>
    2ba4:	84aa                	mv	s1,a0
    if(pid < 0){
    2ba6:	02054063          	bltz	a0,2bc6 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2baa:	c91d                	beqz	a0,2be0 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2bac:	4501                	li	a0,0
    2bae:	00003097          	auipc	ra,0x3
    2bb2:	abc080e7          	jalr	-1348(ra) # 566a <wait>
  for(int avail = 0; avail < 15; avail++){
    2bb6:	2905                	addiw	s2,s2,1
    2bb8:	ff3912e3          	bne	s2,s3,2b9c <execout+0x14>
    }
  }

  exit(0);
    2bbc:	4501                	li	a0,0
    2bbe:	00003097          	auipc	ra,0x3
    2bc2:	aa4080e7          	jalr	-1372(ra) # 5662 <exit>
      printf("fork failed\n");
    2bc6:	00004517          	auipc	a0,0x4
    2bca:	02a50513          	addi	a0,a0,42 # 6bf0 <malloc+0x114e>
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	e14080e7          	jalr	-492(ra) # 59e2 <printf>
      exit(1);
    2bd6:	4505                	li	a0,1
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	a8a080e7          	jalr	-1398(ra) # 5662 <exit>
        if(a == 0xffffffffffffffffLL)
    2be0:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2be2:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2be4:	6505                	lui	a0,0x1
    2be6:	00003097          	auipc	ra,0x3
    2bea:	b04080e7          	jalr	-1276(ra) # 56ea <sbrk>
        if(a == 0xffffffffffffffffLL)
    2bee:	01350763          	beq	a0,s3,2bfc <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2bf2:	6785                	lui	a5,0x1
    2bf4:	97aa                	add	a5,a5,a0
    2bf6:	ff478fa3          	sb	s4,-1(a5) # fff <bigdir+0x89>
      while(1){
    2bfa:	b7ed                	j	2be4 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2bfc:	01205a63          	blez	s2,2c10 <execout+0x88>
        sbrk(-4096);
    2c00:	757d                	lui	a0,0xfffff
    2c02:	00003097          	auipc	ra,0x3
    2c06:	ae8080e7          	jalr	-1304(ra) # 56ea <sbrk>
      for(int i = 0; i < avail; i++)
    2c0a:	2485                	addiw	s1,s1,1
    2c0c:	ff249ae3          	bne	s1,s2,2c00 <execout+0x78>
      close(1);
    2c10:	4505                	li	a0,1
    2c12:	00003097          	auipc	ra,0x3
    2c16:	a78080e7          	jalr	-1416(ra) # 568a <close>
      char *args[] = { "echo", "x", 0 };
    2c1a:	00003517          	auipc	a0,0x3
    2c1e:	37650513          	addi	a0,a0,886 # 5f90 <malloc+0x4ee>
    2c22:	faa43c23          	sd	a0,-72(s0)
    2c26:	00003797          	auipc	a5,0x3
    2c2a:	3da78793          	addi	a5,a5,986 # 6000 <malloc+0x55e>
    2c2e:	fcf43023          	sd	a5,-64(s0)
    2c32:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2c36:	fb840593          	addi	a1,s0,-72
    2c3a:	00003097          	auipc	ra,0x3
    2c3e:	a60080e7          	jalr	-1440(ra) # 569a <exec>
      exit(0);
    2c42:	4501                	li	a0,0
    2c44:	00003097          	auipc	ra,0x3
    2c48:	a1e080e7          	jalr	-1506(ra) # 5662 <exit>

0000000000002c4c <fourteen>:
{
    2c4c:	1101                	addi	sp,sp,-32
    2c4e:	ec06                	sd	ra,24(sp)
    2c50:	e822                	sd	s0,16(sp)
    2c52:	e426                	sd	s1,8(sp)
    2c54:	1000                	addi	s0,sp,32
    2c56:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2c58:	00004517          	auipc	a0,0x4
    2c5c:	49050513          	addi	a0,a0,1168 # 70e8 <malloc+0x1646>
    2c60:	00003097          	auipc	ra,0x3
    2c64:	a6a080e7          	jalr	-1430(ra) # 56ca <mkdir>
    2c68:	e165                	bnez	a0,2d48 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2c6a:	00004517          	auipc	a0,0x4
    2c6e:	2d650513          	addi	a0,a0,726 # 6f40 <malloc+0x149e>
    2c72:	00003097          	auipc	ra,0x3
    2c76:	a58080e7          	jalr	-1448(ra) # 56ca <mkdir>
    2c7a:	e56d                	bnez	a0,2d64 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2c7c:	20000593          	li	a1,512
    2c80:	00004517          	auipc	a0,0x4
    2c84:	31850513          	addi	a0,a0,792 # 6f98 <malloc+0x14f6>
    2c88:	00003097          	auipc	ra,0x3
    2c8c:	a1a080e7          	jalr	-1510(ra) # 56a2 <open>
  if(fd < 0){
    2c90:	0e054863          	bltz	a0,2d80 <fourteen+0x134>
  close(fd);
    2c94:	00003097          	auipc	ra,0x3
    2c98:	9f6080e7          	jalr	-1546(ra) # 568a <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2c9c:	4581                	li	a1,0
    2c9e:	00004517          	auipc	a0,0x4
    2ca2:	37250513          	addi	a0,a0,882 # 7010 <malloc+0x156e>
    2ca6:	00003097          	auipc	ra,0x3
    2caa:	9fc080e7          	jalr	-1540(ra) # 56a2 <open>
  if(fd < 0){
    2cae:	0e054763          	bltz	a0,2d9c <fourteen+0x150>
  close(fd);
    2cb2:	00003097          	auipc	ra,0x3
    2cb6:	9d8080e7          	jalr	-1576(ra) # 568a <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2cba:	00004517          	auipc	a0,0x4
    2cbe:	3c650513          	addi	a0,a0,966 # 7080 <malloc+0x15de>
    2cc2:	00003097          	auipc	ra,0x3
    2cc6:	a08080e7          	jalr	-1528(ra) # 56ca <mkdir>
    2cca:	c57d                	beqz	a0,2db8 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2ccc:	00004517          	auipc	a0,0x4
    2cd0:	40c50513          	addi	a0,a0,1036 # 70d8 <malloc+0x1636>
    2cd4:	00003097          	auipc	ra,0x3
    2cd8:	9f6080e7          	jalr	-1546(ra) # 56ca <mkdir>
    2cdc:	cd65                	beqz	a0,2dd4 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2cde:	00004517          	auipc	a0,0x4
    2ce2:	3fa50513          	addi	a0,a0,1018 # 70d8 <malloc+0x1636>
    2ce6:	00003097          	auipc	ra,0x3
    2cea:	9cc080e7          	jalr	-1588(ra) # 56b2 <unlink>
  unlink("12345678901234/12345678901234");
    2cee:	00004517          	auipc	a0,0x4
    2cf2:	39250513          	addi	a0,a0,914 # 7080 <malloc+0x15de>
    2cf6:	00003097          	auipc	ra,0x3
    2cfa:	9bc080e7          	jalr	-1604(ra) # 56b2 <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2cfe:	00004517          	auipc	a0,0x4
    2d02:	31250513          	addi	a0,a0,786 # 7010 <malloc+0x156e>
    2d06:	00003097          	auipc	ra,0x3
    2d0a:	9ac080e7          	jalr	-1620(ra) # 56b2 <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2d0e:	00004517          	auipc	a0,0x4
    2d12:	28a50513          	addi	a0,a0,650 # 6f98 <malloc+0x14f6>
    2d16:	00003097          	auipc	ra,0x3
    2d1a:	99c080e7          	jalr	-1636(ra) # 56b2 <unlink>
  unlink("12345678901234/123456789012345");
    2d1e:	00004517          	auipc	a0,0x4
    2d22:	22250513          	addi	a0,a0,546 # 6f40 <malloc+0x149e>
    2d26:	00003097          	auipc	ra,0x3
    2d2a:	98c080e7          	jalr	-1652(ra) # 56b2 <unlink>
  unlink("12345678901234");
    2d2e:	00004517          	auipc	a0,0x4
    2d32:	3ba50513          	addi	a0,a0,954 # 70e8 <malloc+0x1646>
    2d36:	00003097          	auipc	ra,0x3
    2d3a:	97c080e7          	jalr	-1668(ra) # 56b2 <unlink>
}
    2d3e:	60e2                	ld	ra,24(sp)
    2d40:	6442                	ld	s0,16(sp)
    2d42:	64a2                	ld	s1,8(sp)
    2d44:	6105                	addi	sp,sp,32
    2d46:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2d48:	85a6                	mv	a1,s1
    2d4a:	00004517          	auipc	a0,0x4
    2d4e:	1ce50513          	addi	a0,a0,462 # 6f18 <malloc+0x1476>
    2d52:	00003097          	auipc	ra,0x3
    2d56:	c90080e7          	jalr	-880(ra) # 59e2 <printf>
    exit(1);
    2d5a:	4505                	li	a0,1
    2d5c:	00003097          	auipc	ra,0x3
    2d60:	906080e7          	jalr	-1786(ra) # 5662 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2d64:	85a6                	mv	a1,s1
    2d66:	00004517          	auipc	a0,0x4
    2d6a:	1fa50513          	addi	a0,a0,506 # 6f60 <malloc+0x14be>
    2d6e:	00003097          	auipc	ra,0x3
    2d72:	c74080e7          	jalr	-908(ra) # 59e2 <printf>
    exit(1);
    2d76:	4505                	li	a0,1
    2d78:	00003097          	auipc	ra,0x3
    2d7c:	8ea080e7          	jalr	-1814(ra) # 5662 <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2d80:	85a6                	mv	a1,s1
    2d82:	00004517          	auipc	a0,0x4
    2d86:	24650513          	addi	a0,a0,582 # 6fc8 <malloc+0x1526>
    2d8a:	00003097          	auipc	ra,0x3
    2d8e:	c58080e7          	jalr	-936(ra) # 59e2 <printf>
    exit(1);
    2d92:	4505                	li	a0,1
    2d94:	00003097          	auipc	ra,0x3
    2d98:	8ce080e7          	jalr	-1842(ra) # 5662 <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2d9c:	85a6                	mv	a1,s1
    2d9e:	00004517          	auipc	a0,0x4
    2da2:	2a250513          	addi	a0,a0,674 # 7040 <malloc+0x159e>
    2da6:	00003097          	auipc	ra,0x3
    2daa:	c3c080e7          	jalr	-964(ra) # 59e2 <printf>
    exit(1);
    2dae:	4505                	li	a0,1
    2db0:	00003097          	auipc	ra,0x3
    2db4:	8b2080e7          	jalr	-1870(ra) # 5662 <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2db8:	85a6                	mv	a1,s1
    2dba:	00004517          	auipc	a0,0x4
    2dbe:	2e650513          	addi	a0,a0,742 # 70a0 <malloc+0x15fe>
    2dc2:	00003097          	auipc	ra,0x3
    2dc6:	c20080e7          	jalr	-992(ra) # 59e2 <printf>
    exit(1);
    2dca:	4505                	li	a0,1
    2dcc:	00003097          	auipc	ra,0x3
    2dd0:	896080e7          	jalr	-1898(ra) # 5662 <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2dd4:	85a6                	mv	a1,s1
    2dd6:	00004517          	auipc	a0,0x4
    2dda:	32250513          	addi	a0,a0,802 # 70f8 <malloc+0x1656>
    2dde:	00003097          	auipc	ra,0x3
    2de2:	c04080e7          	jalr	-1020(ra) # 59e2 <printf>
    exit(1);
    2de6:	4505                	li	a0,1
    2de8:	00003097          	auipc	ra,0x3
    2dec:	87a080e7          	jalr	-1926(ra) # 5662 <exit>

0000000000002df0 <iputtest>:
{
    2df0:	1101                	addi	sp,sp,-32
    2df2:	ec06                	sd	ra,24(sp)
    2df4:	e822                	sd	s0,16(sp)
    2df6:	e426                	sd	s1,8(sp)
    2df8:	1000                	addi	s0,sp,32
    2dfa:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2dfc:	00004517          	auipc	a0,0x4
    2e00:	33450513          	addi	a0,a0,820 # 7130 <malloc+0x168e>
    2e04:	00003097          	auipc	ra,0x3
    2e08:	8c6080e7          	jalr	-1850(ra) # 56ca <mkdir>
    2e0c:	04054563          	bltz	a0,2e56 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2e10:	00004517          	auipc	a0,0x4
    2e14:	32050513          	addi	a0,a0,800 # 7130 <malloc+0x168e>
    2e18:	00003097          	auipc	ra,0x3
    2e1c:	8ba080e7          	jalr	-1862(ra) # 56d2 <chdir>
    2e20:	04054963          	bltz	a0,2e72 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2e24:	00004517          	auipc	a0,0x4
    2e28:	34c50513          	addi	a0,a0,844 # 7170 <malloc+0x16ce>
    2e2c:	00003097          	auipc	ra,0x3
    2e30:	886080e7          	jalr	-1914(ra) # 56b2 <unlink>
    2e34:	04054d63          	bltz	a0,2e8e <iputtest+0x9e>
  if(chdir("/") < 0){
    2e38:	00004517          	auipc	a0,0x4
    2e3c:	36850513          	addi	a0,a0,872 # 71a0 <malloc+0x16fe>
    2e40:	00003097          	auipc	ra,0x3
    2e44:	892080e7          	jalr	-1902(ra) # 56d2 <chdir>
    2e48:	06054163          	bltz	a0,2eaa <iputtest+0xba>
}
    2e4c:	60e2                	ld	ra,24(sp)
    2e4e:	6442                	ld	s0,16(sp)
    2e50:	64a2                	ld	s1,8(sp)
    2e52:	6105                	addi	sp,sp,32
    2e54:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2e56:	85a6                	mv	a1,s1
    2e58:	00004517          	auipc	a0,0x4
    2e5c:	2e050513          	addi	a0,a0,736 # 7138 <malloc+0x1696>
    2e60:	00003097          	auipc	ra,0x3
    2e64:	b82080e7          	jalr	-1150(ra) # 59e2 <printf>
    exit(1);
    2e68:	4505                	li	a0,1
    2e6a:	00002097          	auipc	ra,0x2
    2e6e:	7f8080e7          	jalr	2040(ra) # 5662 <exit>
    printf("%s: chdir iputdir failed\n", s);
    2e72:	85a6                	mv	a1,s1
    2e74:	00004517          	auipc	a0,0x4
    2e78:	2dc50513          	addi	a0,a0,732 # 7150 <malloc+0x16ae>
    2e7c:	00003097          	auipc	ra,0x3
    2e80:	b66080e7          	jalr	-1178(ra) # 59e2 <printf>
    exit(1);
    2e84:	4505                	li	a0,1
    2e86:	00002097          	auipc	ra,0x2
    2e8a:	7dc080e7          	jalr	2012(ra) # 5662 <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2e8e:	85a6                	mv	a1,s1
    2e90:	00004517          	auipc	a0,0x4
    2e94:	2f050513          	addi	a0,a0,752 # 7180 <malloc+0x16de>
    2e98:	00003097          	auipc	ra,0x3
    2e9c:	b4a080e7          	jalr	-1206(ra) # 59e2 <printf>
    exit(1);
    2ea0:	4505                	li	a0,1
    2ea2:	00002097          	auipc	ra,0x2
    2ea6:	7c0080e7          	jalr	1984(ra) # 5662 <exit>
    printf("%s: chdir / failed\n", s);
    2eaa:	85a6                	mv	a1,s1
    2eac:	00004517          	auipc	a0,0x4
    2eb0:	2fc50513          	addi	a0,a0,764 # 71a8 <malloc+0x1706>
    2eb4:	00003097          	auipc	ra,0x3
    2eb8:	b2e080e7          	jalr	-1234(ra) # 59e2 <printf>
    exit(1);
    2ebc:	4505                	li	a0,1
    2ebe:	00002097          	auipc	ra,0x2
    2ec2:	7a4080e7          	jalr	1956(ra) # 5662 <exit>

0000000000002ec6 <exitiputtest>:
{
    2ec6:	7179                	addi	sp,sp,-48
    2ec8:	f406                	sd	ra,40(sp)
    2eca:	f022                	sd	s0,32(sp)
    2ecc:	ec26                	sd	s1,24(sp)
    2ece:	1800                	addi	s0,sp,48
    2ed0:	84aa                	mv	s1,a0
  pid = fork();
    2ed2:	00002097          	auipc	ra,0x2
    2ed6:	788080e7          	jalr	1928(ra) # 565a <fork>
  if(pid < 0){
    2eda:	04054663          	bltz	a0,2f26 <exitiputtest+0x60>
  if(pid == 0){
    2ede:	ed45                	bnez	a0,2f96 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2ee0:	00004517          	auipc	a0,0x4
    2ee4:	25050513          	addi	a0,a0,592 # 7130 <malloc+0x168e>
    2ee8:	00002097          	auipc	ra,0x2
    2eec:	7e2080e7          	jalr	2018(ra) # 56ca <mkdir>
    2ef0:	04054963          	bltz	a0,2f42 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2ef4:	00004517          	auipc	a0,0x4
    2ef8:	23c50513          	addi	a0,a0,572 # 7130 <malloc+0x168e>
    2efc:	00002097          	auipc	ra,0x2
    2f00:	7d6080e7          	jalr	2006(ra) # 56d2 <chdir>
    2f04:	04054d63          	bltz	a0,2f5e <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2f08:	00004517          	auipc	a0,0x4
    2f0c:	26850513          	addi	a0,a0,616 # 7170 <malloc+0x16ce>
    2f10:	00002097          	auipc	ra,0x2
    2f14:	7a2080e7          	jalr	1954(ra) # 56b2 <unlink>
    2f18:	06054163          	bltz	a0,2f7a <exitiputtest+0xb4>
    exit(0);
    2f1c:	4501                	li	a0,0
    2f1e:	00002097          	auipc	ra,0x2
    2f22:	744080e7          	jalr	1860(ra) # 5662 <exit>
    printf("%s: fork failed\n", s);
    2f26:	85a6                	mv	a1,s1
    2f28:	00004517          	auipc	a0,0x4
    2f2c:	8c050513          	addi	a0,a0,-1856 # 67e8 <malloc+0xd46>
    2f30:	00003097          	auipc	ra,0x3
    2f34:	ab2080e7          	jalr	-1358(ra) # 59e2 <printf>
    exit(1);
    2f38:	4505                	li	a0,1
    2f3a:	00002097          	auipc	ra,0x2
    2f3e:	728080e7          	jalr	1832(ra) # 5662 <exit>
      printf("%s: mkdir failed\n", s);
    2f42:	85a6                	mv	a1,s1
    2f44:	00004517          	auipc	a0,0x4
    2f48:	1f450513          	addi	a0,a0,500 # 7138 <malloc+0x1696>
    2f4c:	00003097          	auipc	ra,0x3
    2f50:	a96080e7          	jalr	-1386(ra) # 59e2 <printf>
      exit(1);
    2f54:	4505                	li	a0,1
    2f56:	00002097          	auipc	ra,0x2
    2f5a:	70c080e7          	jalr	1804(ra) # 5662 <exit>
      printf("%s: child chdir failed\n", s);
    2f5e:	85a6                	mv	a1,s1
    2f60:	00004517          	auipc	a0,0x4
    2f64:	26050513          	addi	a0,a0,608 # 71c0 <malloc+0x171e>
    2f68:	00003097          	auipc	ra,0x3
    2f6c:	a7a080e7          	jalr	-1414(ra) # 59e2 <printf>
      exit(1);
    2f70:	4505                	li	a0,1
    2f72:	00002097          	auipc	ra,0x2
    2f76:	6f0080e7          	jalr	1776(ra) # 5662 <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2f7a:	85a6                	mv	a1,s1
    2f7c:	00004517          	auipc	a0,0x4
    2f80:	20450513          	addi	a0,a0,516 # 7180 <malloc+0x16de>
    2f84:	00003097          	auipc	ra,0x3
    2f88:	a5e080e7          	jalr	-1442(ra) # 59e2 <printf>
      exit(1);
    2f8c:	4505                	li	a0,1
    2f8e:	00002097          	auipc	ra,0x2
    2f92:	6d4080e7          	jalr	1748(ra) # 5662 <exit>
  wait(&xstatus);
    2f96:	fdc40513          	addi	a0,s0,-36
    2f9a:	00002097          	auipc	ra,0x2
    2f9e:	6d0080e7          	jalr	1744(ra) # 566a <wait>
  exit(xstatus);
    2fa2:	fdc42503          	lw	a0,-36(s0)
    2fa6:	00002097          	auipc	ra,0x2
    2faa:	6bc080e7          	jalr	1724(ra) # 5662 <exit>

0000000000002fae <dirtest>:
{
    2fae:	1101                	addi	sp,sp,-32
    2fb0:	ec06                	sd	ra,24(sp)
    2fb2:	e822                	sd	s0,16(sp)
    2fb4:	e426                	sd	s1,8(sp)
    2fb6:	1000                	addi	s0,sp,32
    2fb8:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2fba:	00004517          	auipc	a0,0x4
    2fbe:	21e50513          	addi	a0,a0,542 # 71d8 <malloc+0x1736>
    2fc2:	00002097          	auipc	ra,0x2
    2fc6:	708080e7          	jalr	1800(ra) # 56ca <mkdir>
    2fca:	04054563          	bltz	a0,3014 <dirtest+0x66>
  if(chdir("dir0") < 0){
    2fce:	00004517          	auipc	a0,0x4
    2fd2:	20a50513          	addi	a0,a0,522 # 71d8 <malloc+0x1736>
    2fd6:	00002097          	auipc	ra,0x2
    2fda:	6fc080e7          	jalr	1788(ra) # 56d2 <chdir>
    2fde:	04054963          	bltz	a0,3030 <dirtest+0x82>
  if(chdir("..") < 0){
    2fe2:	00004517          	auipc	a0,0x4
    2fe6:	21650513          	addi	a0,a0,534 # 71f8 <malloc+0x1756>
    2fea:	00002097          	auipc	ra,0x2
    2fee:	6e8080e7          	jalr	1768(ra) # 56d2 <chdir>
    2ff2:	04054d63          	bltz	a0,304c <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2ff6:	00004517          	auipc	a0,0x4
    2ffa:	1e250513          	addi	a0,a0,482 # 71d8 <malloc+0x1736>
    2ffe:	00002097          	auipc	ra,0x2
    3002:	6b4080e7          	jalr	1716(ra) # 56b2 <unlink>
    3006:	06054163          	bltz	a0,3068 <dirtest+0xba>
}
    300a:	60e2                	ld	ra,24(sp)
    300c:	6442                	ld	s0,16(sp)
    300e:	64a2                	ld	s1,8(sp)
    3010:	6105                	addi	sp,sp,32
    3012:	8082                	ret
    printf("%s: mkdir failed\n", s);
    3014:	85a6                	mv	a1,s1
    3016:	00004517          	auipc	a0,0x4
    301a:	12250513          	addi	a0,a0,290 # 7138 <malloc+0x1696>
    301e:	00003097          	auipc	ra,0x3
    3022:	9c4080e7          	jalr	-1596(ra) # 59e2 <printf>
    exit(1);
    3026:	4505                	li	a0,1
    3028:	00002097          	auipc	ra,0x2
    302c:	63a080e7          	jalr	1594(ra) # 5662 <exit>
    printf("%s: chdir dir0 failed\n", s);
    3030:	85a6                	mv	a1,s1
    3032:	00004517          	auipc	a0,0x4
    3036:	1ae50513          	addi	a0,a0,430 # 71e0 <malloc+0x173e>
    303a:	00003097          	auipc	ra,0x3
    303e:	9a8080e7          	jalr	-1624(ra) # 59e2 <printf>
    exit(1);
    3042:	4505                	li	a0,1
    3044:	00002097          	auipc	ra,0x2
    3048:	61e080e7          	jalr	1566(ra) # 5662 <exit>
    printf("%s: chdir .. failed\n", s);
    304c:	85a6                	mv	a1,s1
    304e:	00004517          	auipc	a0,0x4
    3052:	1b250513          	addi	a0,a0,434 # 7200 <malloc+0x175e>
    3056:	00003097          	auipc	ra,0x3
    305a:	98c080e7          	jalr	-1652(ra) # 59e2 <printf>
    exit(1);
    305e:	4505                	li	a0,1
    3060:	00002097          	auipc	ra,0x2
    3064:	602080e7          	jalr	1538(ra) # 5662 <exit>
    printf("%s: unlink dir0 failed\n", s);
    3068:	85a6                	mv	a1,s1
    306a:	00004517          	auipc	a0,0x4
    306e:	1ae50513          	addi	a0,a0,430 # 7218 <malloc+0x1776>
    3072:	00003097          	auipc	ra,0x3
    3076:	970080e7          	jalr	-1680(ra) # 59e2 <printf>
    exit(1);
    307a:	4505                	li	a0,1
    307c:	00002097          	auipc	ra,0x2
    3080:	5e6080e7          	jalr	1510(ra) # 5662 <exit>

0000000000003084 <subdir>:
{
    3084:	1101                	addi	sp,sp,-32
    3086:	ec06                	sd	ra,24(sp)
    3088:	e822                	sd	s0,16(sp)
    308a:	e426                	sd	s1,8(sp)
    308c:	e04a                	sd	s2,0(sp)
    308e:	1000                	addi	s0,sp,32
    3090:	892a                	mv	s2,a0
  unlink("ff");
    3092:	00004517          	auipc	a0,0x4
    3096:	2ce50513          	addi	a0,a0,718 # 7360 <malloc+0x18be>
    309a:	00002097          	auipc	ra,0x2
    309e:	618080e7          	jalr	1560(ra) # 56b2 <unlink>
  if(mkdir("dd") != 0){
    30a2:	00004517          	auipc	a0,0x4
    30a6:	18e50513          	addi	a0,a0,398 # 7230 <malloc+0x178e>
    30aa:	00002097          	auipc	ra,0x2
    30ae:	620080e7          	jalr	1568(ra) # 56ca <mkdir>
    30b2:	38051663          	bnez	a0,343e <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    30b6:	20200593          	li	a1,514
    30ba:	00004517          	auipc	a0,0x4
    30be:	19650513          	addi	a0,a0,406 # 7250 <malloc+0x17ae>
    30c2:	00002097          	auipc	ra,0x2
    30c6:	5e0080e7          	jalr	1504(ra) # 56a2 <open>
    30ca:	84aa                	mv	s1,a0
  if(fd < 0){
    30cc:	38054763          	bltz	a0,345a <subdir+0x3d6>
  write(fd, "ff", 2);
    30d0:	4609                	li	a2,2
    30d2:	00004597          	auipc	a1,0x4
    30d6:	28e58593          	addi	a1,a1,654 # 7360 <malloc+0x18be>
    30da:	00002097          	auipc	ra,0x2
    30de:	5a8080e7          	jalr	1448(ra) # 5682 <write>
  close(fd);
    30e2:	8526                	mv	a0,s1
    30e4:	00002097          	auipc	ra,0x2
    30e8:	5a6080e7          	jalr	1446(ra) # 568a <close>
  if(unlink("dd") >= 0){
    30ec:	00004517          	auipc	a0,0x4
    30f0:	14450513          	addi	a0,a0,324 # 7230 <malloc+0x178e>
    30f4:	00002097          	auipc	ra,0x2
    30f8:	5be080e7          	jalr	1470(ra) # 56b2 <unlink>
    30fc:	36055d63          	bgez	a0,3476 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    3100:	00004517          	auipc	a0,0x4
    3104:	1a850513          	addi	a0,a0,424 # 72a8 <malloc+0x1806>
    3108:	00002097          	auipc	ra,0x2
    310c:	5c2080e7          	jalr	1474(ra) # 56ca <mkdir>
    3110:	38051163          	bnez	a0,3492 <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    3114:	20200593          	li	a1,514
    3118:	00004517          	auipc	a0,0x4
    311c:	1b850513          	addi	a0,a0,440 # 72d0 <malloc+0x182e>
    3120:	00002097          	auipc	ra,0x2
    3124:	582080e7          	jalr	1410(ra) # 56a2 <open>
    3128:	84aa                	mv	s1,a0
  if(fd < 0){
    312a:	38054263          	bltz	a0,34ae <subdir+0x42a>
  write(fd, "FF", 2);
    312e:	4609                	li	a2,2
    3130:	00004597          	auipc	a1,0x4
    3134:	1d058593          	addi	a1,a1,464 # 7300 <malloc+0x185e>
    3138:	00002097          	auipc	ra,0x2
    313c:	54a080e7          	jalr	1354(ra) # 5682 <write>
  close(fd);
    3140:	8526                	mv	a0,s1
    3142:	00002097          	auipc	ra,0x2
    3146:	548080e7          	jalr	1352(ra) # 568a <close>
  fd = open("dd/dd/../ff", 0);
    314a:	4581                	li	a1,0
    314c:	00004517          	auipc	a0,0x4
    3150:	1bc50513          	addi	a0,a0,444 # 7308 <malloc+0x1866>
    3154:	00002097          	auipc	ra,0x2
    3158:	54e080e7          	jalr	1358(ra) # 56a2 <open>
    315c:	84aa                	mv	s1,a0
  if(fd < 0){
    315e:	36054663          	bltz	a0,34ca <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    3162:	660d                	lui	a2,0x3
    3164:	00009597          	auipc	a1,0x9
    3168:	99458593          	addi	a1,a1,-1644 # baf8 <buf>
    316c:	00002097          	auipc	ra,0x2
    3170:	50e080e7          	jalr	1294(ra) # 567a <read>
  if(cc != 2 || buf[0] != 'f'){
    3174:	4789                	li	a5,2
    3176:	36f51863          	bne	a0,a5,34e6 <subdir+0x462>
    317a:	00009717          	auipc	a4,0x9
    317e:	97e74703          	lbu	a4,-1666(a4) # baf8 <buf>
    3182:	06600793          	li	a5,102
    3186:	36f71063          	bne	a4,a5,34e6 <subdir+0x462>
  close(fd);
    318a:	8526                	mv	a0,s1
    318c:	00002097          	auipc	ra,0x2
    3190:	4fe080e7          	jalr	1278(ra) # 568a <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    3194:	00004597          	auipc	a1,0x4
    3198:	1c458593          	addi	a1,a1,452 # 7358 <malloc+0x18b6>
    319c:	00004517          	auipc	a0,0x4
    31a0:	13450513          	addi	a0,a0,308 # 72d0 <malloc+0x182e>
    31a4:	00002097          	auipc	ra,0x2
    31a8:	51e080e7          	jalr	1310(ra) # 56c2 <link>
    31ac:	34051b63          	bnez	a0,3502 <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    31b0:	00004517          	auipc	a0,0x4
    31b4:	12050513          	addi	a0,a0,288 # 72d0 <malloc+0x182e>
    31b8:	00002097          	auipc	ra,0x2
    31bc:	4fa080e7          	jalr	1274(ra) # 56b2 <unlink>
    31c0:	34051f63          	bnez	a0,351e <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    31c4:	4581                	li	a1,0
    31c6:	00004517          	auipc	a0,0x4
    31ca:	10a50513          	addi	a0,a0,266 # 72d0 <malloc+0x182e>
    31ce:	00002097          	auipc	ra,0x2
    31d2:	4d4080e7          	jalr	1236(ra) # 56a2 <open>
    31d6:	36055263          	bgez	a0,353a <subdir+0x4b6>
  if(chdir("dd") != 0){
    31da:	00004517          	auipc	a0,0x4
    31de:	05650513          	addi	a0,a0,86 # 7230 <malloc+0x178e>
    31e2:	00002097          	auipc	ra,0x2
    31e6:	4f0080e7          	jalr	1264(ra) # 56d2 <chdir>
    31ea:	36051663          	bnez	a0,3556 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    31ee:	00004517          	auipc	a0,0x4
    31f2:	20250513          	addi	a0,a0,514 # 73f0 <malloc+0x194e>
    31f6:	00002097          	auipc	ra,0x2
    31fa:	4dc080e7          	jalr	1244(ra) # 56d2 <chdir>
    31fe:	36051a63          	bnez	a0,3572 <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    3202:	00004517          	auipc	a0,0x4
    3206:	21e50513          	addi	a0,a0,542 # 7420 <malloc+0x197e>
    320a:	00002097          	auipc	ra,0x2
    320e:	4c8080e7          	jalr	1224(ra) # 56d2 <chdir>
    3212:	36051e63          	bnez	a0,358e <subdir+0x50a>
  if(chdir("./..") != 0){
    3216:	00004517          	auipc	a0,0x4
    321a:	23a50513          	addi	a0,a0,570 # 7450 <malloc+0x19ae>
    321e:	00002097          	auipc	ra,0x2
    3222:	4b4080e7          	jalr	1204(ra) # 56d2 <chdir>
    3226:	38051263          	bnez	a0,35aa <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    322a:	4581                	li	a1,0
    322c:	00004517          	auipc	a0,0x4
    3230:	12c50513          	addi	a0,a0,300 # 7358 <malloc+0x18b6>
    3234:	00002097          	auipc	ra,0x2
    3238:	46e080e7          	jalr	1134(ra) # 56a2 <open>
    323c:	84aa                	mv	s1,a0
  if(fd < 0){
    323e:	38054463          	bltz	a0,35c6 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    3242:	660d                	lui	a2,0x3
    3244:	00009597          	auipc	a1,0x9
    3248:	8b458593          	addi	a1,a1,-1868 # baf8 <buf>
    324c:	00002097          	auipc	ra,0x2
    3250:	42e080e7          	jalr	1070(ra) # 567a <read>
    3254:	4789                	li	a5,2
    3256:	38f51663          	bne	a0,a5,35e2 <subdir+0x55e>
  close(fd);
    325a:	8526                	mv	a0,s1
    325c:	00002097          	auipc	ra,0x2
    3260:	42e080e7          	jalr	1070(ra) # 568a <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3264:	4581                	li	a1,0
    3266:	00004517          	auipc	a0,0x4
    326a:	06a50513          	addi	a0,a0,106 # 72d0 <malloc+0x182e>
    326e:	00002097          	auipc	ra,0x2
    3272:	434080e7          	jalr	1076(ra) # 56a2 <open>
    3276:	38055463          	bgez	a0,35fe <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    327a:	20200593          	li	a1,514
    327e:	00004517          	auipc	a0,0x4
    3282:	26250513          	addi	a0,a0,610 # 74e0 <malloc+0x1a3e>
    3286:	00002097          	auipc	ra,0x2
    328a:	41c080e7          	jalr	1052(ra) # 56a2 <open>
    328e:	38055663          	bgez	a0,361a <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    3292:	20200593          	li	a1,514
    3296:	00004517          	auipc	a0,0x4
    329a:	27a50513          	addi	a0,a0,634 # 7510 <malloc+0x1a6e>
    329e:	00002097          	auipc	ra,0x2
    32a2:	404080e7          	jalr	1028(ra) # 56a2 <open>
    32a6:	38055863          	bgez	a0,3636 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    32aa:	20000593          	li	a1,512
    32ae:	00004517          	auipc	a0,0x4
    32b2:	f8250513          	addi	a0,a0,-126 # 7230 <malloc+0x178e>
    32b6:	00002097          	auipc	ra,0x2
    32ba:	3ec080e7          	jalr	1004(ra) # 56a2 <open>
    32be:	38055a63          	bgez	a0,3652 <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    32c2:	4589                	li	a1,2
    32c4:	00004517          	auipc	a0,0x4
    32c8:	f6c50513          	addi	a0,a0,-148 # 7230 <malloc+0x178e>
    32cc:	00002097          	auipc	ra,0x2
    32d0:	3d6080e7          	jalr	982(ra) # 56a2 <open>
    32d4:	38055d63          	bgez	a0,366e <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    32d8:	4585                	li	a1,1
    32da:	00004517          	auipc	a0,0x4
    32de:	f5650513          	addi	a0,a0,-170 # 7230 <malloc+0x178e>
    32e2:	00002097          	auipc	ra,0x2
    32e6:	3c0080e7          	jalr	960(ra) # 56a2 <open>
    32ea:	3a055063          	bgez	a0,368a <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    32ee:	00004597          	auipc	a1,0x4
    32f2:	2b258593          	addi	a1,a1,690 # 75a0 <malloc+0x1afe>
    32f6:	00004517          	auipc	a0,0x4
    32fa:	1ea50513          	addi	a0,a0,490 # 74e0 <malloc+0x1a3e>
    32fe:	00002097          	auipc	ra,0x2
    3302:	3c4080e7          	jalr	964(ra) # 56c2 <link>
    3306:	3a050063          	beqz	a0,36a6 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    330a:	00004597          	auipc	a1,0x4
    330e:	29658593          	addi	a1,a1,662 # 75a0 <malloc+0x1afe>
    3312:	00004517          	auipc	a0,0x4
    3316:	1fe50513          	addi	a0,a0,510 # 7510 <malloc+0x1a6e>
    331a:	00002097          	auipc	ra,0x2
    331e:	3a8080e7          	jalr	936(ra) # 56c2 <link>
    3322:	3a050063          	beqz	a0,36c2 <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3326:	00004597          	auipc	a1,0x4
    332a:	03258593          	addi	a1,a1,50 # 7358 <malloc+0x18b6>
    332e:	00004517          	auipc	a0,0x4
    3332:	f2250513          	addi	a0,a0,-222 # 7250 <malloc+0x17ae>
    3336:	00002097          	auipc	ra,0x2
    333a:	38c080e7          	jalr	908(ra) # 56c2 <link>
    333e:	3a050063          	beqz	a0,36de <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    3342:	00004517          	auipc	a0,0x4
    3346:	19e50513          	addi	a0,a0,414 # 74e0 <malloc+0x1a3e>
    334a:	00002097          	auipc	ra,0x2
    334e:	380080e7          	jalr	896(ra) # 56ca <mkdir>
    3352:	3a050463          	beqz	a0,36fa <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3356:	00004517          	auipc	a0,0x4
    335a:	1ba50513          	addi	a0,a0,442 # 7510 <malloc+0x1a6e>
    335e:	00002097          	auipc	ra,0x2
    3362:	36c080e7          	jalr	876(ra) # 56ca <mkdir>
    3366:	3a050863          	beqz	a0,3716 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    336a:	00004517          	auipc	a0,0x4
    336e:	fee50513          	addi	a0,a0,-18 # 7358 <malloc+0x18b6>
    3372:	00002097          	auipc	ra,0x2
    3376:	358080e7          	jalr	856(ra) # 56ca <mkdir>
    337a:	3a050c63          	beqz	a0,3732 <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    337e:	00004517          	auipc	a0,0x4
    3382:	19250513          	addi	a0,a0,402 # 7510 <malloc+0x1a6e>
    3386:	00002097          	auipc	ra,0x2
    338a:	32c080e7          	jalr	812(ra) # 56b2 <unlink>
    338e:	3c050063          	beqz	a0,374e <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    3392:	00004517          	auipc	a0,0x4
    3396:	14e50513          	addi	a0,a0,334 # 74e0 <malloc+0x1a3e>
    339a:	00002097          	auipc	ra,0x2
    339e:	318080e7          	jalr	792(ra) # 56b2 <unlink>
    33a2:	3c050463          	beqz	a0,376a <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    33a6:	00004517          	auipc	a0,0x4
    33aa:	eaa50513          	addi	a0,a0,-342 # 7250 <malloc+0x17ae>
    33ae:	00002097          	auipc	ra,0x2
    33b2:	324080e7          	jalr	804(ra) # 56d2 <chdir>
    33b6:	3c050863          	beqz	a0,3786 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    33ba:	00004517          	auipc	a0,0x4
    33be:	33650513          	addi	a0,a0,822 # 76f0 <malloc+0x1c4e>
    33c2:	00002097          	auipc	ra,0x2
    33c6:	310080e7          	jalr	784(ra) # 56d2 <chdir>
    33ca:	3c050c63          	beqz	a0,37a2 <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    33ce:	00004517          	auipc	a0,0x4
    33d2:	f8a50513          	addi	a0,a0,-118 # 7358 <malloc+0x18b6>
    33d6:	00002097          	auipc	ra,0x2
    33da:	2dc080e7          	jalr	732(ra) # 56b2 <unlink>
    33de:	3e051063          	bnez	a0,37be <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    33e2:	00004517          	auipc	a0,0x4
    33e6:	e6e50513          	addi	a0,a0,-402 # 7250 <malloc+0x17ae>
    33ea:	00002097          	auipc	ra,0x2
    33ee:	2c8080e7          	jalr	712(ra) # 56b2 <unlink>
    33f2:	3e051463          	bnez	a0,37da <subdir+0x756>
  if(unlink("dd") == 0){
    33f6:	00004517          	auipc	a0,0x4
    33fa:	e3a50513          	addi	a0,a0,-454 # 7230 <malloc+0x178e>
    33fe:	00002097          	auipc	ra,0x2
    3402:	2b4080e7          	jalr	692(ra) # 56b2 <unlink>
    3406:	3e050863          	beqz	a0,37f6 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    340a:	00004517          	auipc	a0,0x4
    340e:	35650513          	addi	a0,a0,854 # 7760 <malloc+0x1cbe>
    3412:	00002097          	auipc	ra,0x2
    3416:	2a0080e7          	jalr	672(ra) # 56b2 <unlink>
    341a:	3e054c63          	bltz	a0,3812 <subdir+0x78e>
  if(unlink("dd") < 0){
    341e:	00004517          	auipc	a0,0x4
    3422:	e1250513          	addi	a0,a0,-494 # 7230 <malloc+0x178e>
    3426:	00002097          	auipc	ra,0x2
    342a:	28c080e7          	jalr	652(ra) # 56b2 <unlink>
    342e:	40054063          	bltz	a0,382e <subdir+0x7aa>
}
    3432:	60e2                	ld	ra,24(sp)
    3434:	6442                	ld	s0,16(sp)
    3436:	64a2                	ld	s1,8(sp)
    3438:	6902                	ld	s2,0(sp)
    343a:	6105                	addi	sp,sp,32
    343c:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    343e:	85ca                	mv	a1,s2
    3440:	00004517          	auipc	a0,0x4
    3444:	df850513          	addi	a0,a0,-520 # 7238 <malloc+0x1796>
    3448:	00002097          	auipc	ra,0x2
    344c:	59a080e7          	jalr	1434(ra) # 59e2 <printf>
    exit(1);
    3450:	4505                	li	a0,1
    3452:	00002097          	auipc	ra,0x2
    3456:	210080e7          	jalr	528(ra) # 5662 <exit>
    printf("%s: create dd/ff failed\n", s);
    345a:	85ca                	mv	a1,s2
    345c:	00004517          	auipc	a0,0x4
    3460:	dfc50513          	addi	a0,a0,-516 # 7258 <malloc+0x17b6>
    3464:	00002097          	auipc	ra,0x2
    3468:	57e080e7          	jalr	1406(ra) # 59e2 <printf>
    exit(1);
    346c:	4505                	li	a0,1
    346e:	00002097          	auipc	ra,0x2
    3472:	1f4080e7          	jalr	500(ra) # 5662 <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3476:	85ca                	mv	a1,s2
    3478:	00004517          	auipc	a0,0x4
    347c:	e0050513          	addi	a0,a0,-512 # 7278 <malloc+0x17d6>
    3480:	00002097          	auipc	ra,0x2
    3484:	562080e7          	jalr	1378(ra) # 59e2 <printf>
    exit(1);
    3488:	4505                	li	a0,1
    348a:	00002097          	auipc	ra,0x2
    348e:	1d8080e7          	jalr	472(ra) # 5662 <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    3492:	85ca                	mv	a1,s2
    3494:	00004517          	auipc	a0,0x4
    3498:	e1c50513          	addi	a0,a0,-484 # 72b0 <malloc+0x180e>
    349c:	00002097          	auipc	ra,0x2
    34a0:	546080e7          	jalr	1350(ra) # 59e2 <printf>
    exit(1);
    34a4:	4505                	li	a0,1
    34a6:	00002097          	auipc	ra,0x2
    34aa:	1bc080e7          	jalr	444(ra) # 5662 <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    34ae:	85ca                	mv	a1,s2
    34b0:	00004517          	auipc	a0,0x4
    34b4:	e3050513          	addi	a0,a0,-464 # 72e0 <malloc+0x183e>
    34b8:	00002097          	auipc	ra,0x2
    34bc:	52a080e7          	jalr	1322(ra) # 59e2 <printf>
    exit(1);
    34c0:	4505                	li	a0,1
    34c2:	00002097          	auipc	ra,0x2
    34c6:	1a0080e7          	jalr	416(ra) # 5662 <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    34ca:	85ca                	mv	a1,s2
    34cc:	00004517          	auipc	a0,0x4
    34d0:	e4c50513          	addi	a0,a0,-436 # 7318 <malloc+0x1876>
    34d4:	00002097          	auipc	ra,0x2
    34d8:	50e080e7          	jalr	1294(ra) # 59e2 <printf>
    exit(1);
    34dc:	4505                	li	a0,1
    34de:	00002097          	auipc	ra,0x2
    34e2:	184080e7          	jalr	388(ra) # 5662 <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    34e6:	85ca                	mv	a1,s2
    34e8:	00004517          	auipc	a0,0x4
    34ec:	e5050513          	addi	a0,a0,-432 # 7338 <malloc+0x1896>
    34f0:	00002097          	auipc	ra,0x2
    34f4:	4f2080e7          	jalr	1266(ra) # 59e2 <printf>
    exit(1);
    34f8:	4505                	li	a0,1
    34fa:	00002097          	auipc	ra,0x2
    34fe:	168080e7          	jalr	360(ra) # 5662 <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    3502:	85ca                	mv	a1,s2
    3504:	00004517          	auipc	a0,0x4
    3508:	e6450513          	addi	a0,a0,-412 # 7368 <malloc+0x18c6>
    350c:	00002097          	auipc	ra,0x2
    3510:	4d6080e7          	jalr	1238(ra) # 59e2 <printf>
    exit(1);
    3514:	4505                	li	a0,1
    3516:	00002097          	auipc	ra,0x2
    351a:	14c080e7          	jalr	332(ra) # 5662 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    351e:	85ca                	mv	a1,s2
    3520:	00004517          	auipc	a0,0x4
    3524:	e7050513          	addi	a0,a0,-400 # 7390 <malloc+0x18ee>
    3528:	00002097          	auipc	ra,0x2
    352c:	4ba080e7          	jalr	1210(ra) # 59e2 <printf>
    exit(1);
    3530:	4505                	li	a0,1
    3532:	00002097          	auipc	ra,0x2
    3536:	130080e7          	jalr	304(ra) # 5662 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    353a:	85ca                	mv	a1,s2
    353c:	00004517          	auipc	a0,0x4
    3540:	e7450513          	addi	a0,a0,-396 # 73b0 <malloc+0x190e>
    3544:	00002097          	auipc	ra,0x2
    3548:	49e080e7          	jalr	1182(ra) # 59e2 <printf>
    exit(1);
    354c:	4505                	li	a0,1
    354e:	00002097          	auipc	ra,0x2
    3552:	114080e7          	jalr	276(ra) # 5662 <exit>
    printf("%s: chdir dd failed\n", s);
    3556:	85ca                	mv	a1,s2
    3558:	00004517          	auipc	a0,0x4
    355c:	e8050513          	addi	a0,a0,-384 # 73d8 <malloc+0x1936>
    3560:	00002097          	auipc	ra,0x2
    3564:	482080e7          	jalr	1154(ra) # 59e2 <printf>
    exit(1);
    3568:	4505                	li	a0,1
    356a:	00002097          	auipc	ra,0x2
    356e:	0f8080e7          	jalr	248(ra) # 5662 <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    3572:	85ca                	mv	a1,s2
    3574:	00004517          	auipc	a0,0x4
    3578:	e8c50513          	addi	a0,a0,-372 # 7400 <malloc+0x195e>
    357c:	00002097          	auipc	ra,0x2
    3580:	466080e7          	jalr	1126(ra) # 59e2 <printf>
    exit(1);
    3584:	4505                	li	a0,1
    3586:	00002097          	auipc	ra,0x2
    358a:	0dc080e7          	jalr	220(ra) # 5662 <exit>
    printf("chdir dd/../../dd failed\n", s);
    358e:	85ca                	mv	a1,s2
    3590:	00004517          	auipc	a0,0x4
    3594:	ea050513          	addi	a0,a0,-352 # 7430 <malloc+0x198e>
    3598:	00002097          	auipc	ra,0x2
    359c:	44a080e7          	jalr	1098(ra) # 59e2 <printf>
    exit(1);
    35a0:	4505                	li	a0,1
    35a2:	00002097          	auipc	ra,0x2
    35a6:	0c0080e7          	jalr	192(ra) # 5662 <exit>
    printf("%s: chdir ./.. failed\n", s);
    35aa:	85ca                	mv	a1,s2
    35ac:	00004517          	auipc	a0,0x4
    35b0:	eac50513          	addi	a0,a0,-340 # 7458 <malloc+0x19b6>
    35b4:	00002097          	auipc	ra,0x2
    35b8:	42e080e7          	jalr	1070(ra) # 59e2 <printf>
    exit(1);
    35bc:	4505                	li	a0,1
    35be:	00002097          	auipc	ra,0x2
    35c2:	0a4080e7          	jalr	164(ra) # 5662 <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    35c6:	85ca                	mv	a1,s2
    35c8:	00004517          	auipc	a0,0x4
    35cc:	ea850513          	addi	a0,a0,-344 # 7470 <malloc+0x19ce>
    35d0:	00002097          	auipc	ra,0x2
    35d4:	412080e7          	jalr	1042(ra) # 59e2 <printf>
    exit(1);
    35d8:	4505                	li	a0,1
    35da:	00002097          	auipc	ra,0x2
    35de:	088080e7          	jalr	136(ra) # 5662 <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    35e2:	85ca                	mv	a1,s2
    35e4:	00004517          	auipc	a0,0x4
    35e8:	eac50513          	addi	a0,a0,-340 # 7490 <malloc+0x19ee>
    35ec:	00002097          	auipc	ra,0x2
    35f0:	3f6080e7          	jalr	1014(ra) # 59e2 <printf>
    exit(1);
    35f4:	4505                	li	a0,1
    35f6:	00002097          	auipc	ra,0x2
    35fa:	06c080e7          	jalr	108(ra) # 5662 <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    35fe:	85ca                	mv	a1,s2
    3600:	00004517          	auipc	a0,0x4
    3604:	eb050513          	addi	a0,a0,-336 # 74b0 <malloc+0x1a0e>
    3608:	00002097          	auipc	ra,0x2
    360c:	3da080e7          	jalr	986(ra) # 59e2 <printf>
    exit(1);
    3610:	4505                	li	a0,1
    3612:	00002097          	auipc	ra,0x2
    3616:	050080e7          	jalr	80(ra) # 5662 <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    361a:	85ca                	mv	a1,s2
    361c:	00004517          	auipc	a0,0x4
    3620:	ed450513          	addi	a0,a0,-300 # 74f0 <malloc+0x1a4e>
    3624:	00002097          	auipc	ra,0x2
    3628:	3be080e7          	jalr	958(ra) # 59e2 <printf>
    exit(1);
    362c:	4505                	li	a0,1
    362e:	00002097          	auipc	ra,0x2
    3632:	034080e7          	jalr	52(ra) # 5662 <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3636:	85ca                	mv	a1,s2
    3638:	00004517          	auipc	a0,0x4
    363c:	ee850513          	addi	a0,a0,-280 # 7520 <malloc+0x1a7e>
    3640:	00002097          	auipc	ra,0x2
    3644:	3a2080e7          	jalr	930(ra) # 59e2 <printf>
    exit(1);
    3648:	4505                	li	a0,1
    364a:	00002097          	auipc	ra,0x2
    364e:	018080e7          	jalr	24(ra) # 5662 <exit>
    printf("%s: create dd succeeded!\n", s);
    3652:	85ca                	mv	a1,s2
    3654:	00004517          	auipc	a0,0x4
    3658:	eec50513          	addi	a0,a0,-276 # 7540 <malloc+0x1a9e>
    365c:	00002097          	auipc	ra,0x2
    3660:	386080e7          	jalr	902(ra) # 59e2 <printf>
    exit(1);
    3664:	4505                	li	a0,1
    3666:	00002097          	auipc	ra,0x2
    366a:	ffc080e7          	jalr	-4(ra) # 5662 <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    366e:	85ca                	mv	a1,s2
    3670:	00004517          	auipc	a0,0x4
    3674:	ef050513          	addi	a0,a0,-272 # 7560 <malloc+0x1abe>
    3678:	00002097          	auipc	ra,0x2
    367c:	36a080e7          	jalr	874(ra) # 59e2 <printf>
    exit(1);
    3680:	4505                	li	a0,1
    3682:	00002097          	auipc	ra,0x2
    3686:	fe0080e7          	jalr	-32(ra) # 5662 <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    368a:	85ca                	mv	a1,s2
    368c:	00004517          	auipc	a0,0x4
    3690:	ef450513          	addi	a0,a0,-268 # 7580 <malloc+0x1ade>
    3694:	00002097          	auipc	ra,0x2
    3698:	34e080e7          	jalr	846(ra) # 59e2 <printf>
    exit(1);
    369c:	4505                	li	a0,1
    369e:	00002097          	auipc	ra,0x2
    36a2:	fc4080e7          	jalr	-60(ra) # 5662 <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    36a6:	85ca                	mv	a1,s2
    36a8:	00004517          	auipc	a0,0x4
    36ac:	f0850513          	addi	a0,a0,-248 # 75b0 <malloc+0x1b0e>
    36b0:	00002097          	auipc	ra,0x2
    36b4:	332080e7          	jalr	818(ra) # 59e2 <printf>
    exit(1);
    36b8:	4505                	li	a0,1
    36ba:	00002097          	auipc	ra,0x2
    36be:	fa8080e7          	jalr	-88(ra) # 5662 <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    36c2:	85ca                	mv	a1,s2
    36c4:	00004517          	auipc	a0,0x4
    36c8:	f1450513          	addi	a0,a0,-236 # 75d8 <malloc+0x1b36>
    36cc:	00002097          	auipc	ra,0x2
    36d0:	316080e7          	jalr	790(ra) # 59e2 <printf>
    exit(1);
    36d4:	4505                	li	a0,1
    36d6:	00002097          	auipc	ra,0x2
    36da:	f8c080e7          	jalr	-116(ra) # 5662 <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    36de:	85ca                	mv	a1,s2
    36e0:	00004517          	auipc	a0,0x4
    36e4:	f2050513          	addi	a0,a0,-224 # 7600 <malloc+0x1b5e>
    36e8:	00002097          	auipc	ra,0x2
    36ec:	2fa080e7          	jalr	762(ra) # 59e2 <printf>
    exit(1);
    36f0:	4505                	li	a0,1
    36f2:	00002097          	auipc	ra,0x2
    36f6:	f70080e7          	jalr	-144(ra) # 5662 <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    36fa:	85ca                	mv	a1,s2
    36fc:	00004517          	auipc	a0,0x4
    3700:	f2c50513          	addi	a0,a0,-212 # 7628 <malloc+0x1b86>
    3704:	00002097          	auipc	ra,0x2
    3708:	2de080e7          	jalr	734(ra) # 59e2 <printf>
    exit(1);
    370c:	4505                	li	a0,1
    370e:	00002097          	auipc	ra,0x2
    3712:	f54080e7          	jalr	-172(ra) # 5662 <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    3716:	85ca                	mv	a1,s2
    3718:	00004517          	auipc	a0,0x4
    371c:	f3050513          	addi	a0,a0,-208 # 7648 <malloc+0x1ba6>
    3720:	00002097          	auipc	ra,0x2
    3724:	2c2080e7          	jalr	706(ra) # 59e2 <printf>
    exit(1);
    3728:	4505                	li	a0,1
    372a:	00002097          	auipc	ra,0x2
    372e:	f38080e7          	jalr	-200(ra) # 5662 <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    3732:	85ca                	mv	a1,s2
    3734:	00004517          	auipc	a0,0x4
    3738:	f3450513          	addi	a0,a0,-204 # 7668 <malloc+0x1bc6>
    373c:	00002097          	auipc	ra,0x2
    3740:	2a6080e7          	jalr	678(ra) # 59e2 <printf>
    exit(1);
    3744:	4505                	li	a0,1
    3746:	00002097          	auipc	ra,0x2
    374a:	f1c080e7          	jalr	-228(ra) # 5662 <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    374e:	85ca                	mv	a1,s2
    3750:	00004517          	auipc	a0,0x4
    3754:	f4050513          	addi	a0,a0,-192 # 7690 <malloc+0x1bee>
    3758:	00002097          	auipc	ra,0x2
    375c:	28a080e7          	jalr	650(ra) # 59e2 <printf>
    exit(1);
    3760:	4505                	li	a0,1
    3762:	00002097          	auipc	ra,0x2
    3766:	f00080e7          	jalr	-256(ra) # 5662 <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    376a:	85ca                	mv	a1,s2
    376c:	00004517          	auipc	a0,0x4
    3770:	f4450513          	addi	a0,a0,-188 # 76b0 <malloc+0x1c0e>
    3774:	00002097          	auipc	ra,0x2
    3778:	26e080e7          	jalr	622(ra) # 59e2 <printf>
    exit(1);
    377c:	4505                	li	a0,1
    377e:	00002097          	auipc	ra,0x2
    3782:	ee4080e7          	jalr	-284(ra) # 5662 <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3786:	85ca                	mv	a1,s2
    3788:	00004517          	auipc	a0,0x4
    378c:	f4850513          	addi	a0,a0,-184 # 76d0 <malloc+0x1c2e>
    3790:	00002097          	auipc	ra,0x2
    3794:	252080e7          	jalr	594(ra) # 59e2 <printf>
    exit(1);
    3798:	4505                	li	a0,1
    379a:	00002097          	auipc	ra,0x2
    379e:	ec8080e7          	jalr	-312(ra) # 5662 <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    37a2:	85ca                	mv	a1,s2
    37a4:	00004517          	auipc	a0,0x4
    37a8:	f5450513          	addi	a0,a0,-172 # 76f8 <malloc+0x1c56>
    37ac:	00002097          	auipc	ra,0x2
    37b0:	236080e7          	jalr	566(ra) # 59e2 <printf>
    exit(1);
    37b4:	4505                	li	a0,1
    37b6:	00002097          	auipc	ra,0x2
    37ba:	eac080e7          	jalr	-340(ra) # 5662 <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    37be:	85ca                	mv	a1,s2
    37c0:	00004517          	auipc	a0,0x4
    37c4:	bd050513          	addi	a0,a0,-1072 # 7390 <malloc+0x18ee>
    37c8:	00002097          	auipc	ra,0x2
    37cc:	21a080e7          	jalr	538(ra) # 59e2 <printf>
    exit(1);
    37d0:	4505                	li	a0,1
    37d2:	00002097          	auipc	ra,0x2
    37d6:	e90080e7          	jalr	-368(ra) # 5662 <exit>
    printf("%s: unlink dd/ff failed\n", s);
    37da:	85ca                	mv	a1,s2
    37dc:	00004517          	auipc	a0,0x4
    37e0:	f3c50513          	addi	a0,a0,-196 # 7718 <malloc+0x1c76>
    37e4:	00002097          	auipc	ra,0x2
    37e8:	1fe080e7          	jalr	510(ra) # 59e2 <printf>
    exit(1);
    37ec:	4505                	li	a0,1
    37ee:	00002097          	auipc	ra,0x2
    37f2:	e74080e7          	jalr	-396(ra) # 5662 <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    37f6:	85ca                	mv	a1,s2
    37f8:	00004517          	auipc	a0,0x4
    37fc:	f4050513          	addi	a0,a0,-192 # 7738 <malloc+0x1c96>
    3800:	00002097          	auipc	ra,0x2
    3804:	1e2080e7          	jalr	482(ra) # 59e2 <printf>
    exit(1);
    3808:	4505                	li	a0,1
    380a:	00002097          	auipc	ra,0x2
    380e:	e58080e7          	jalr	-424(ra) # 5662 <exit>
    printf("%s: unlink dd/dd failed\n", s);
    3812:	85ca                	mv	a1,s2
    3814:	00004517          	auipc	a0,0x4
    3818:	f5450513          	addi	a0,a0,-172 # 7768 <malloc+0x1cc6>
    381c:	00002097          	auipc	ra,0x2
    3820:	1c6080e7          	jalr	454(ra) # 59e2 <printf>
    exit(1);
    3824:	4505                	li	a0,1
    3826:	00002097          	auipc	ra,0x2
    382a:	e3c080e7          	jalr	-452(ra) # 5662 <exit>
    printf("%s: unlink dd failed\n", s);
    382e:	85ca                	mv	a1,s2
    3830:	00004517          	auipc	a0,0x4
    3834:	f5850513          	addi	a0,a0,-168 # 7788 <malloc+0x1ce6>
    3838:	00002097          	auipc	ra,0x2
    383c:	1aa080e7          	jalr	426(ra) # 59e2 <printf>
    exit(1);
    3840:	4505                	li	a0,1
    3842:	00002097          	auipc	ra,0x2
    3846:	e20080e7          	jalr	-480(ra) # 5662 <exit>

000000000000384a <rmdot>:
{
    384a:	1101                	addi	sp,sp,-32
    384c:	ec06                	sd	ra,24(sp)
    384e:	e822                	sd	s0,16(sp)
    3850:	e426                	sd	s1,8(sp)
    3852:	1000                	addi	s0,sp,32
    3854:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3856:	00004517          	auipc	a0,0x4
    385a:	f4a50513          	addi	a0,a0,-182 # 77a0 <malloc+0x1cfe>
    385e:	00002097          	auipc	ra,0x2
    3862:	e6c080e7          	jalr	-404(ra) # 56ca <mkdir>
    3866:	e549                	bnez	a0,38f0 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3868:	00004517          	auipc	a0,0x4
    386c:	f3850513          	addi	a0,a0,-200 # 77a0 <malloc+0x1cfe>
    3870:	00002097          	auipc	ra,0x2
    3874:	e62080e7          	jalr	-414(ra) # 56d2 <chdir>
    3878:	e951                	bnez	a0,390c <rmdot+0xc2>
  if(unlink(".") == 0){
    387a:	00003517          	auipc	a0,0x3
    387e:	dce50513          	addi	a0,a0,-562 # 6648 <malloc+0xba6>
    3882:	00002097          	auipc	ra,0x2
    3886:	e30080e7          	jalr	-464(ra) # 56b2 <unlink>
    388a:	cd59                	beqz	a0,3928 <rmdot+0xde>
  if(unlink("..") == 0){
    388c:	00004517          	auipc	a0,0x4
    3890:	96c50513          	addi	a0,a0,-1684 # 71f8 <malloc+0x1756>
    3894:	00002097          	auipc	ra,0x2
    3898:	e1e080e7          	jalr	-482(ra) # 56b2 <unlink>
    389c:	c545                	beqz	a0,3944 <rmdot+0xfa>
  if(chdir("/") != 0){
    389e:	00004517          	auipc	a0,0x4
    38a2:	90250513          	addi	a0,a0,-1790 # 71a0 <malloc+0x16fe>
    38a6:	00002097          	auipc	ra,0x2
    38aa:	e2c080e7          	jalr	-468(ra) # 56d2 <chdir>
    38ae:	e94d                	bnez	a0,3960 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    38b0:	00004517          	auipc	a0,0x4
    38b4:	f5850513          	addi	a0,a0,-168 # 7808 <malloc+0x1d66>
    38b8:	00002097          	auipc	ra,0x2
    38bc:	dfa080e7          	jalr	-518(ra) # 56b2 <unlink>
    38c0:	cd55                	beqz	a0,397c <rmdot+0x132>
  if(unlink("dots/..") == 0){
    38c2:	00004517          	auipc	a0,0x4
    38c6:	f6e50513          	addi	a0,a0,-146 # 7830 <malloc+0x1d8e>
    38ca:	00002097          	auipc	ra,0x2
    38ce:	de8080e7          	jalr	-536(ra) # 56b2 <unlink>
    38d2:	c179                	beqz	a0,3998 <rmdot+0x14e>
  if(unlink("dots") != 0){
    38d4:	00004517          	auipc	a0,0x4
    38d8:	ecc50513          	addi	a0,a0,-308 # 77a0 <malloc+0x1cfe>
    38dc:	00002097          	auipc	ra,0x2
    38e0:	dd6080e7          	jalr	-554(ra) # 56b2 <unlink>
    38e4:	e961                	bnez	a0,39b4 <rmdot+0x16a>
}
    38e6:	60e2                	ld	ra,24(sp)
    38e8:	6442                	ld	s0,16(sp)
    38ea:	64a2                	ld	s1,8(sp)
    38ec:	6105                	addi	sp,sp,32
    38ee:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    38f0:	85a6                	mv	a1,s1
    38f2:	00004517          	auipc	a0,0x4
    38f6:	eb650513          	addi	a0,a0,-330 # 77a8 <malloc+0x1d06>
    38fa:	00002097          	auipc	ra,0x2
    38fe:	0e8080e7          	jalr	232(ra) # 59e2 <printf>
    exit(1);
    3902:	4505                	li	a0,1
    3904:	00002097          	auipc	ra,0x2
    3908:	d5e080e7          	jalr	-674(ra) # 5662 <exit>
    printf("%s: chdir dots failed\n", s);
    390c:	85a6                	mv	a1,s1
    390e:	00004517          	auipc	a0,0x4
    3912:	eb250513          	addi	a0,a0,-334 # 77c0 <malloc+0x1d1e>
    3916:	00002097          	auipc	ra,0x2
    391a:	0cc080e7          	jalr	204(ra) # 59e2 <printf>
    exit(1);
    391e:	4505                	li	a0,1
    3920:	00002097          	auipc	ra,0x2
    3924:	d42080e7          	jalr	-702(ra) # 5662 <exit>
    printf("%s: rm . worked!\n", s);
    3928:	85a6                	mv	a1,s1
    392a:	00004517          	auipc	a0,0x4
    392e:	eae50513          	addi	a0,a0,-338 # 77d8 <malloc+0x1d36>
    3932:	00002097          	auipc	ra,0x2
    3936:	0b0080e7          	jalr	176(ra) # 59e2 <printf>
    exit(1);
    393a:	4505                	li	a0,1
    393c:	00002097          	auipc	ra,0x2
    3940:	d26080e7          	jalr	-730(ra) # 5662 <exit>
    printf("%s: rm .. worked!\n", s);
    3944:	85a6                	mv	a1,s1
    3946:	00004517          	auipc	a0,0x4
    394a:	eaa50513          	addi	a0,a0,-342 # 77f0 <malloc+0x1d4e>
    394e:	00002097          	auipc	ra,0x2
    3952:	094080e7          	jalr	148(ra) # 59e2 <printf>
    exit(1);
    3956:	4505                	li	a0,1
    3958:	00002097          	auipc	ra,0x2
    395c:	d0a080e7          	jalr	-758(ra) # 5662 <exit>
    printf("%s: chdir / failed\n", s);
    3960:	85a6                	mv	a1,s1
    3962:	00004517          	auipc	a0,0x4
    3966:	84650513          	addi	a0,a0,-1978 # 71a8 <malloc+0x1706>
    396a:	00002097          	auipc	ra,0x2
    396e:	078080e7          	jalr	120(ra) # 59e2 <printf>
    exit(1);
    3972:	4505                	li	a0,1
    3974:	00002097          	auipc	ra,0x2
    3978:	cee080e7          	jalr	-786(ra) # 5662 <exit>
    printf("%s: unlink dots/. worked!\n", s);
    397c:	85a6                	mv	a1,s1
    397e:	00004517          	auipc	a0,0x4
    3982:	e9250513          	addi	a0,a0,-366 # 7810 <malloc+0x1d6e>
    3986:	00002097          	auipc	ra,0x2
    398a:	05c080e7          	jalr	92(ra) # 59e2 <printf>
    exit(1);
    398e:	4505                	li	a0,1
    3990:	00002097          	auipc	ra,0x2
    3994:	cd2080e7          	jalr	-814(ra) # 5662 <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3998:	85a6                	mv	a1,s1
    399a:	00004517          	auipc	a0,0x4
    399e:	e9e50513          	addi	a0,a0,-354 # 7838 <malloc+0x1d96>
    39a2:	00002097          	auipc	ra,0x2
    39a6:	040080e7          	jalr	64(ra) # 59e2 <printf>
    exit(1);
    39aa:	4505                	li	a0,1
    39ac:	00002097          	auipc	ra,0x2
    39b0:	cb6080e7          	jalr	-842(ra) # 5662 <exit>
    printf("%s: unlink dots failed!\n", s);
    39b4:	85a6                	mv	a1,s1
    39b6:	00004517          	auipc	a0,0x4
    39ba:	ea250513          	addi	a0,a0,-350 # 7858 <malloc+0x1db6>
    39be:	00002097          	auipc	ra,0x2
    39c2:	024080e7          	jalr	36(ra) # 59e2 <printf>
    exit(1);
    39c6:	4505                	li	a0,1
    39c8:	00002097          	auipc	ra,0x2
    39cc:	c9a080e7          	jalr	-870(ra) # 5662 <exit>

00000000000039d0 <dirfile>:
{
    39d0:	1101                	addi	sp,sp,-32
    39d2:	ec06                	sd	ra,24(sp)
    39d4:	e822                	sd	s0,16(sp)
    39d6:	e426                	sd	s1,8(sp)
    39d8:	e04a                	sd	s2,0(sp)
    39da:	1000                	addi	s0,sp,32
    39dc:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    39de:	20000593          	li	a1,512
    39e2:	00004517          	auipc	a0,0x4
    39e6:	e9650513          	addi	a0,a0,-362 # 7878 <malloc+0x1dd6>
    39ea:	00002097          	auipc	ra,0x2
    39ee:	cb8080e7          	jalr	-840(ra) # 56a2 <open>
  if(fd < 0){
    39f2:	0e054d63          	bltz	a0,3aec <dirfile+0x11c>
  close(fd);
    39f6:	00002097          	auipc	ra,0x2
    39fa:	c94080e7          	jalr	-876(ra) # 568a <close>
  if(chdir("dirfile") == 0){
    39fe:	00004517          	auipc	a0,0x4
    3a02:	e7a50513          	addi	a0,a0,-390 # 7878 <malloc+0x1dd6>
    3a06:	00002097          	auipc	ra,0x2
    3a0a:	ccc080e7          	jalr	-820(ra) # 56d2 <chdir>
    3a0e:	cd6d                	beqz	a0,3b08 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    3a10:	4581                	li	a1,0
    3a12:	00004517          	auipc	a0,0x4
    3a16:	eae50513          	addi	a0,a0,-338 # 78c0 <malloc+0x1e1e>
    3a1a:	00002097          	auipc	ra,0x2
    3a1e:	c88080e7          	jalr	-888(ra) # 56a2 <open>
  if(fd >= 0){
    3a22:	10055163          	bgez	a0,3b24 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3a26:	20000593          	li	a1,512
    3a2a:	00004517          	auipc	a0,0x4
    3a2e:	e9650513          	addi	a0,a0,-362 # 78c0 <malloc+0x1e1e>
    3a32:	00002097          	auipc	ra,0x2
    3a36:	c70080e7          	jalr	-912(ra) # 56a2 <open>
  if(fd >= 0){
    3a3a:	10055363          	bgez	a0,3b40 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3a3e:	00004517          	auipc	a0,0x4
    3a42:	e8250513          	addi	a0,a0,-382 # 78c0 <malloc+0x1e1e>
    3a46:	00002097          	auipc	ra,0x2
    3a4a:	c84080e7          	jalr	-892(ra) # 56ca <mkdir>
    3a4e:	10050763          	beqz	a0,3b5c <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    3a52:	00004517          	auipc	a0,0x4
    3a56:	e6e50513          	addi	a0,a0,-402 # 78c0 <malloc+0x1e1e>
    3a5a:	00002097          	auipc	ra,0x2
    3a5e:	c58080e7          	jalr	-936(ra) # 56b2 <unlink>
    3a62:	10050b63          	beqz	a0,3b78 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3a66:	00004597          	auipc	a1,0x4
    3a6a:	e5a58593          	addi	a1,a1,-422 # 78c0 <malloc+0x1e1e>
    3a6e:	00002517          	auipc	a0,0x2
    3a72:	6ca50513          	addi	a0,a0,1738 # 6138 <malloc+0x696>
    3a76:	00002097          	auipc	ra,0x2
    3a7a:	c4c080e7          	jalr	-948(ra) # 56c2 <link>
    3a7e:	10050b63          	beqz	a0,3b94 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    3a82:	00004517          	auipc	a0,0x4
    3a86:	df650513          	addi	a0,a0,-522 # 7878 <malloc+0x1dd6>
    3a8a:	00002097          	auipc	ra,0x2
    3a8e:	c28080e7          	jalr	-984(ra) # 56b2 <unlink>
    3a92:	10051f63          	bnez	a0,3bb0 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3a96:	4589                	li	a1,2
    3a98:	00003517          	auipc	a0,0x3
    3a9c:	bb050513          	addi	a0,a0,-1104 # 6648 <malloc+0xba6>
    3aa0:	00002097          	auipc	ra,0x2
    3aa4:	c02080e7          	jalr	-1022(ra) # 56a2 <open>
  if(fd >= 0){
    3aa8:	12055263          	bgez	a0,3bcc <dirfile+0x1fc>
  fd = open(".", 0);
    3aac:	4581                	li	a1,0
    3aae:	00003517          	auipc	a0,0x3
    3ab2:	b9a50513          	addi	a0,a0,-1126 # 6648 <malloc+0xba6>
    3ab6:	00002097          	auipc	ra,0x2
    3aba:	bec080e7          	jalr	-1044(ra) # 56a2 <open>
    3abe:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3ac0:	4605                	li	a2,1
    3ac2:	00002597          	auipc	a1,0x2
    3ac6:	53e58593          	addi	a1,a1,1342 # 6000 <malloc+0x55e>
    3aca:	00002097          	auipc	ra,0x2
    3ace:	bb8080e7          	jalr	-1096(ra) # 5682 <write>
    3ad2:	10a04b63          	bgtz	a0,3be8 <dirfile+0x218>
  close(fd);
    3ad6:	8526                	mv	a0,s1
    3ad8:	00002097          	auipc	ra,0x2
    3adc:	bb2080e7          	jalr	-1102(ra) # 568a <close>
}
    3ae0:	60e2                	ld	ra,24(sp)
    3ae2:	6442                	ld	s0,16(sp)
    3ae4:	64a2                	ld	s1,8(sp)
    3ae6:	6902                	ld	s2,0(sp)
    3ae8:	6105                	addi	sp,sp,32
    3aea:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    3aec:	85ca                	mv	a1,s2
    3aee:	00004517          	auipc	a0,0x4
    3af2:	d9250513          	addi	a0,a0,-622 # 7880 <malloc+0x1dde>
    3af6:	00002097          	auipc	ra,0x2
    3afa:	eec080e7          	jalr	-276(ra) # 59e2 <printf>
    exit(1);
    3afe:	4505                	li	a0,1
    3b00:	00002097          	auipc	ra,0x2
    3b04:	b62080e7          	jalr	-1182(ra) # 5662 <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    3b08:	85ca                	mv	a1,s2
    3b0a:	00004517          	auipc	a0,0x4
    3b0e:	d9650513          	addi	a0,a0,-618 # 78a0 <malloc+0x1dfe>
    3b12:	00002097          	auipc	ra,0x2
    3b16:	ed0080e7          	jalr	-304(ra) # 59e2 <printf>
    exit(1);
    3b1a:	4505                	li	a0,1
    3b1c:	00002097          	auipc	ra,0x2
    3b20:	b46080e7          	jalr	-1210(ra) # 5662 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b24:	85ca                	mv	a1,s2
    3b26:	00004517          	auipc	a0,0x4
    3b2a:	daa50513          	addi	a0,a0,-598 # 78d0 <malloc+0x1e2e>
    3b2e:	00002097          	auipc	ra,0x2
    3b32:	eb4080e7          	jalr	-332(ra) # 59e2 <printf>
    exit(1);
    3b36:	4505                	li	a0,1
    3b38:	00002097          	auipc	ra,0x2
    3b3c:	b2a080e7          	jalr	-1238(ra) # 5662 <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3b40:	85ca                	mv	a1,s2
    3b42:	00004517          	auipc	a0,0x4
    3b46:	d8e50513          	addi	a0,a0,-626 # 78d0 <malloc+0x1e2e>
    3b4a:	00002097          	auipc	ra,0x2
    3b4e:	e98080e7          	jalr	-360(ra) # 59e2 <printf>
    exit(1);
    3b52:	4505                	li	a0,1
    3b54:	00002097          	auipc	ra,0x2
    3b58:	b0e080e7          	jalr	-1266(ra) # 5662 <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3b5c:	85ca                	mv	a1,s2
    3b5e:	00004517          	auipc	a0,0x4
    3b62:	d9a50513          	addi	a0,a0,-614 # 78f8 <malloc+0x1e56>
    3b66:	00002097          	auipc	ra,0x2
    3b6a:	e7c080e7          	jalr	-388(ra) # 59e2 <printf>
    exit(1);
    3b6e:	4505                	li	a0,1
    3b70:	00002097          	auipc	ra,0x2
    3b74:	af2080e7          	jalr	-1294(ra) # 5662 <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3b78:	85ca                	mv	a1,s2
    3b7a:	00004517          	auipc	a0,0x4
    3b7e:	da650513          	addi	a0,a0,-602 # 7920 <malloc+0x1e7e>
    3b82:	00002097          	auipc	ra,0x2
    3b86:	e60080e7          	jalr	-416(ra) # 59e2 <printf>
    exit(1);
    3b8a:	4505                	li	a0,1
    3b8c:	00002097          	auipc	ra,0x2
    3b90:	ad6080e7          	jalr	-1322(ra) # 5662 <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3b94:	85ca                	mv	a1,s2
    3b96:	00004517          	auipc	a0,0x4
    3b9a:	db250513          	addi	a0,a0,-590 # 7948 <malloc+0x1ea6>
    3b9e:	00002097          	auipc	ra,0x2
    3ba2:	e44080e7          	jalr	-444(ra) # 59e2 <printf>
    exit(1);
    3ba6:	4505                	li	a0,1
    3ba8:	00002097          	auipc	ra,0x2
    3bac:	aba080e7          	jalr	-1350(ra) # 5662 <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3bb0:	85ca                	mv	a1,s2
    3bb2:	00004517          	auipc	a0,0x4
    3bb6:	dbe50513          	addi	a0,a0,-578 # 7970 <malloc+0x1ece>
    3bba:	00002097          	auipc	ra,0x2
    3bbe:	e28080e7          	jalr	-472(ra) # 59e2 <printf>
    exit(1);
    3bc2:	4505                	li	a0,1
    3bc4:	00002097          	auipc	ra,0x2
    3bc8:	a9e080e7          	jalr	-1378(ra) # 5662 <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3bcc:	85ca                	mv	a1,s2
    3bce:	00004517          	auipc	a0,0x4
    3bd2:	dc250513          	addi	a0,a0,-574 # 7990 <malloc+0x1eee>
    3bd6:	00002097          	auipc	ra,0x2
    3bda:	e0c080e7          	jalr	-500(ra) # 59e2 <printf>
    exit(1);
    3bde:	4505                	li	a0,1
    3be0:	00002097          	auipc	ra,0x2
    3be4:	a82080e7          	jalr	-1406(ra) # 5662 <exit>
    printf("%s: write . succeeded!\n", s);
    3be8:	85ca                	mv	a1,s2
    3bea:	00004517          	auipc	a0,0x4
    3bee:	dce50513          	addi	a0,a0,-562 # 79b8 <malloc+0x1f16>
    3bf2:	00002097          	auipc	ra,0x2
    3bf6:	df0080e7          	jalr	-528(ra) # 59e2 <printf>
    exit(1);
    3bfa:	4505                	li	a0,1
    3bfc:	00002097          	auipc	ra,0x2
    3c00:	a66080e7          	jalr	-1434(ra) # 5662 <exit>

0000000000003c04 <iref>:
{
    3c04:	7139                	addi	sp,sp,-64
    3c06:	fc06                	sd	ra,56(sp)
    3c08:	f822                	sd	s0,48(sp)
    3c0a:	f426                	sd	s1,40(sp)
    3c0c:	f04a                	sd	s2,32(sp)
    3c0e:	ec4e                	sd	s3,24(sp)
    3c10:	e852                	sd	s4,16(sp)
    3c12:	e456                	sd	s5,8(sp)
    3c14:	e05a                	sd	s6,0(sp)
    3c16:	0080                	addi	s0,sp,64
    3c18:	8b2a                	mv	s6,a0
    3c1a:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3c1e:	00004a17          	auipc	s4,0x4
    3c22:	db2a0a13          	addi	s4,s4,-590 # 79d0 <malloc+0x1f2e>
    mkdir("");
    3c26:	00004497          	auipc	s1,0x4
    3c2a:	8b248493          	addi	s1,s1,-1870 # 74d8 <malloc+0x1a36>
    link("README", "");
    3c2e:	00002a97          	auipc	s5,0x2
    3c32:	50aa8a93          	addi	s5,s5,1290 # 6138 <malloc+0x696>
    fd = open("xx", O_CREATE);
    3c36:	00004997          	auipc	s3,0x4
    3c3a:	c9298993          	addi	s3,s3,-878 # 78c8 <malloc+0x1e26>
    3c3e:	a891                	j	3c92 <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3c40:	85da                	mv	a1,s6
    3c42:	00004517          	auipc	a0,0x4
    3c46:	d9650513          	addi	a0,a0,-618 # 79d8 <malloc+0x1f36>
    3c4a:	00002097          	auipc	ra,0x2
    3c4e:	d98080e7          	jalr	-616(ra) # 59e2 <printf>
      exit(1);
    3c52:	4505                	li	a0,1
    3c54:	00002097          	auipc	ra,0x2
    3c58:	a0e080e7          	jalr	-1522(ra) # 5662 <exit>
      printf("%s: chdir irefd failed\n", s);
    3c5c:	85da                	mv	a1,s6
    3c5e:	00004517          	auipc	a0,0x4
    3c62:	d9250513          	addi	a0,a0,-622 # 79f0 <malloc+0x1f4e>
    3c66:	00002097          	auipc	ra,0x2
    3c6a:	d7c080e7          	jalr	-644(ra) # 59e2 <printf>
      exit(1);
    3c6e:	4505                	li	a0,1
    3c70:	00002097          	auipc	ra,0x2
    3c74:	9f2080e7          	jalr	-1550(ra) # 5662 <exit>
      close(fd);
    3c78:	00002097          	auipc	ra,0x2
    3c7c:	a12080e7          	jalr	-1518(ra) # 568a <close>
    3c80:	a889                	j	3cd2 <iref+0xce>
    unlink("xx");
    3c82:	854e                	mv	a0,s3
    3c84:	00002097          	auipc	ra,0x2
    3c88:	a2e080e7          	jalr	-1490(ra) # 56b2 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3c8c:	397d                	addiw	s2,s2,-1
    3c8e:	06090063          	beqz	s2,3cee <iref+0xea>
    if(mkdir("irefd") != 0){
    3c92:	8552                	mv	a0,s4
    3c94:	00002097          	auipc	ra,0x2
    3c98:	a36080e7          	jalr	-1482(ra) # 56ca <mkdir>
    3c9c:	f155                	bnez	a0,3c40 <iref+0x3c>
    if(chdir("irefd") != 0){
    3c9e:	8552                	mv	a0,s4
    3ca0:	00002097          	auipc	ra,0x2
    3ca4:	a32080e7          	jalr	-1486(ra) # 56d2 <chdir>
    3ca8:	f955                	bnez	a0,3c5c <iref+0x58>
    mkdir("");
    3caa:	8526                	mv	a0,s1
    3cac:	00002097          	auipc	ra,0x2
    3cb0:	a1e080e7          	jalr	-1506(ra) # 56ca <mkdir>
    link("README", "");
    3cb4:	85a6                	mv	a1,s1
    3cb6:	8556                	mv	a0,s5
    3cb8:	00002097          	auipc	ra,0x2
    3cbc:	a0a080e7          	jalr	-1526(ra) # 56c2 <link>
    fd = open("", O_CREATE);
    3cc0:	20000593          	li	a1,512
    3cc4:	8526                	mv	a0,s1
    3cc6:	00002097          	auipc	ra,0x2
    3cca:	9dc080e7          	jalr	-1572(ra) # 56a2 <open>
    if(fd >= 0)
    3cce:	fa0555e3          	bgez	a0,3c78 <iref+0x74>
    fd = open("xx", O_CREATE);
    3cd2:	20000593          	li	a1,512
    3cd6:	854e                	mv	a0,s3
    3cd8:	00002097          	auipc	ra,0x2
    3cdc:	9ca080e7          	jalr	-1590(ra) # 56a2 <open>
    if(fd >= 0)
    3ce0:	fa0541e3          	bltz	a0,3c82 <iref+0x7e>
      close(fd);
    3ce4:	00002097          	auipc	ra,0x2
    3ce8:	9a6080e7          	jalr	-1626(ra) # 568a <close>
    3cec:	bf59                	j	3c82 <iref+0x7e>
    3cee:	03300493          	li	s1,51
    chdir("..");
    3cf2:	00003997          	auipc	s3,0x3
    3cf6:	50698993          	addi	s3,s3,1286 # 71f8 <malloc+0x1756>
    unlink("irefd");
    3cfa:	00004917          	auipc	s2,0x4
    3cfe:	cd690913          	addi	s2,s2,-810 # 79d0 <malloc+0x1f2e>
    chdir("..");
    3d02:	854e                	mv	a0,s3
    3d04:	00002097          	auipc	ra,0x2
    3d08:	9ce080e7          	jalr	-1586(ra) # 56d2 <chdir>
    unlink("irefd");
    3d0c:	854a                	mv	a0,s2
    3d0e:	00002097          	auipc	ra,0x2
    3d12:	9a4080e7          	jalr	-1628(ra) # 56b2 <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3d16:	34fd                	addiw	s1,s1,-1
    3d18:	f4ed                	bnez	s1,3d02 <iref+0xfe>
  chdir("/");
    3d1a:	00003517          	auipc	a0,0x3
    3d1e:	48650513          	addi	a0,a0,1158 # 71a0 <malloc+0x16fe>
    3d22:	00002097          	auipc	ra,0x2
    3d26:	9b0080e7          	jalr	-1616(ra) # 56d2 <chdir>
}
    3d2a:	70e2                	ld	ra,56(sp)
    3d2c:	7442                	ld	s0,48(sp)
    3d2e:	74a2                	ld	s1,40(sp)
    3d30:	7902                	ld	s2,32(sp)
    3d32:	69e2                	ld	s3,24(sp)
    3d34:	6a42                	ld	s4,16(sp)
    3d36:	6aa2                	ld	s5,8(sp)
    3d38:	6b02                	ld	s6,0(sp)
    3d3a:	6121                	addi	sp,sp,64
    3d3c:	8082                	ret

0000000000003d3e <openiputtest>:
{
    3d3e:	7179                	addi	sp,sp,-48
    3d40:	f406                	sd	ra,40(sp)
    3d42:	f022                	sd	s0,32(sp)
    3d44:	ec26                	sd	s1,24(sp)
    3d46:	1800                	addi	s0,sp,48
    3d48:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3d4a:	00004517          	auipc	a0,0x4
    3d4e:	cbe50513          	addi	a0,a0,-834 # 7a08 <malloc+0x1f66>
    3d52:	00002097          	auipc	ra,0x2
    3d56:	978080e7          	jalr	-1672(ra) # 56ca <mkdir>
    3d5a:	04054263          	bltz	a0,3d9e <openiputtest+0x60>
  pid = fork();
    3d5e:	00002097          	auipc	ra,0x2
    3d62:	8fc080e7          	jalr	-1796(ra) # 565a <fork>
  if(pid < 0){
    3d66:	04054a63          	bltz	a0,3dba <openiputtest+0x7c>
  if(pid == 0){
    3d6a:	e93d                	bnez	a0,3de0 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3d6c:	4589                	li	a1,2
    3d6e:	00004517          	auipc	a0,0x4
    3d72:	c9a50513          	addi	a0,a0,-870 # 7a08 <malloc+0x1f66>
    3d76:	00002097          	auipc	ra,0x2
    3d7a:	92c080e7          	jalr	-1748(ra) # 56a2 <open>
    if(fd >= 0){
    3d7e:	04054c63          	bltz	a0,3dd6 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3d82:	85a6                	mv	a1,s1
    3d84:	00004517          	auipc	a0,0x4
    3d88:	ca450513          	addi	a0,a0,-860 # 7a28 <malloc+0x1f86>
    3d8c:	00002097          	auipc	ra,0x2
    3d90:	c56080e7          	jalr	-938(ra) # 59e2 <printf>
      exit(1);
    3d94:	4505                	li	a0,1
    3d96:	00002097          	auipc	ra,0x2
    3d9a:	8cc080e7          	jalr	-1844(ra) # 5662 <exit>
    printf("%s: mkdir oidir failed\n", s);
    3d9e:	85a6                	mv	a1,s1
    3da0:	00004517          	auipc	a0,0x4
    3da4:	c7050513          	addi	a0,a0,-912 # 7a10 <malloc+0x1f6e>
    3da8:	00002097          	auipc	ra,0x2
    3dac:	c3a080e7          	jalr	-966(ra) # 59e2 <printf>
    exit(1);
    3db0:	4505                	li	a0,1
    3db2:	00002097          	auipc	ra,0x2
    3db6:	8b0080e7          	jalr	-1872(ra) # 5662 <exit>
    printf("%s: fork failed\n", s);
    3dba:	85a6                	mv	a1,s1
    3dbc:	00003517          	auipc	a0,0x3
    3dc0:	a2c50513          	addi	a0,a0,-1492 # 67e8 <malloc+0xd46>
    3dc4:	00002097          	auipc	ra,0x2
    3dc8:	c1e080e7          	jalr	-994(ra) # 59e2 <printf>
    exit(1);
    3dcc:	4505                	li	a0,1
    3dce:	00002097          	auipc	ra,0x2
    3dd2:	894080e7          	jalr	-1900(ra) # 5662 <exit>
    exit(0);
    3dd6:	4501                	li	a0,0
    3dd8:	00002097          	auipc	ra,0x2
    3ddc:	88a080e7          	jalr	-1910(ra) # 5662 <exit>
  sleep(1);
    3de0:	4505                	li	a0,1
    3de2:	00002097          	auipc	ra,0x2
    3de6:	910080e7          	jalr	-1776(ra) # 56f2 <sleep>
  if(unlink("oidir") != 0){
    3dea:	00004517          	auipc	a0,0x4
    3dee:	c1e50513          	addi	a0,a0,-994 # 7a08 <malloc+0x1f66>
    3df2:	00002097          	auipc	ra,0x2
    3df6:	8c0080e7          	jalr	-1856(ra) # 56b2 <unlink>
    3dfa:	cd19                	beqz	a0,3e18 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3dfc:	85a6                	mv	a1,s1
    3dfe:	00003517          	auipc	a0,0x3
    3e02:	bda50513          	addi	a0,a0,-1062 # 69d8 <malloc+0xf36>
    3e06:	00002097          	auipc	ra,0x2
    3e0a:	bdc080e7          	jalr	-1060(ra) # 59e2 <printf>
    exit(1);
    3e0e:	4505                	li	a0,1
    3e10:	00002097          	auipc	ra,0x2
    3e14:	852080e7          	jalr	-1966(ra) # 5662 <exit>
  wait(&xstatus);
    3e18:	fdc40513          	addi	a0,s0,-36
    3e1c:	00002097          	auipc	ra,0x2
    3e20:	84e080e7          	jalr	-1970(ra) # 566a <wait>
  exit(xstatus);
    3e24:	fdc42503          	lw	a0,-36(s0)
    3e28:	00002097          	auipc	ra,0x2
    3e2c:	83a080e7          	jalr	-1990(ra) # 5662 <exit>

0000000000003e30 <forkforkfork>:
{
    3e30:	1101                	addi	sp,sp,-32
    3e32:	ec06                	sd	ra,24(sp)
    3e34:	e822                	sd	s0,16(sp)
    3e36:	e426                	sd	s1,8(sp)
    3e38:	1000                	addi	s0,sp,32
    3e3a:	84aa                	mv	s1,a0
  unlink("stopforking");
    3e3c:	00004517          	auipc	a0,0x4
    3e40:	c1450513          	addi	a0,a0,-1004 # 7a50 <malloc+0x1fae>
    3e44:	00002097          	auipc	ra,0x2
    3e48:	86e080e7          	jalr	-1938(ra) # 56b2 <unlink>
  int pid = fork();
    3e4c:	00002097          	auipc	ra,0x2
    3e50:	80e080e7          	jalr	-2034(ra) # 565a <fork>
  if(pid < 0){
    3e54:	04054563          	bltz	a0,3e9e <forkforkfork+0x6e>
  if(pid == 0){
    3e58:	c12d                	beqz	a0,3eba <forkforkfork+0x8a>
  sleep(20); // two seconds
    3e5a:	4551                	li	a0,20
    3e5c:	00002097          	auipc	ra,0x2
    3e60:	896080e7          	jalr	-1898(ra) # 56f2 <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3e64:	20200593          	li	a1,514
    3e68:	00004517          	auipc	a0,0x4
    3e6c:	be850513          	addi	a0,a0,-1048 # 7a50 <malloc+0x1fae>
    3e70:	00002097          	auipc	ra,0x2
    3e74:	832080e7          	jalr	-1998(ra) # 56a2 <open>
    3e78:	00002097          	auipc	ra,0x2
    3e7c:	812080e7          	jalr	-2030(ra) # 568a <close>
  wait(0);
    3e80:	4501                	li	a0,0
    3e82:	00001097          	auipc	ra,0x1
    3e86:	7e8080e7          	jalr	2024(ra) # 566a <wait>
  sleep(10); // one second
    3e8a:	4529                	li	a0,10
    3e8c:	00002097          	auipc	ra,0x2
    3e90:	866080e7          	jalr	-1946(ra) # 56f2 <sleep>
}
    3e94:	60e2                	ld	ra,24(sp)
    3e96:	6442                	ld	s0,16(sp)
    3e98:	64a2                	ld	s1,8(sp)
    3e9a:	6105                	addi	sp,sp,32
    3e9c:	8082                	ret
    printf("%s: fork failed", s);
    3e9e:	85a6                	mv	a1,s1
    3ea0:	00003517          	auipc	a0,0x3
    3ea4:	b0850513          	addi	a0,a0,-1272 # 69a8 <malloc+0xf06>
    3ea8:	00002097          	auipc	ra,0x2
    3eac:	b3a080e7          	jalr	-1222(ra) # 59e2 <printf>
    exit(1);
    3eb0:	4505                	li	a0,1
    3eb2:	00001097          	auipc	ra,0x1
    3eb6:	7b0080e7          	jalr	1968(ra) # 5662 <exit>
      int fd = open("stopforking", 0);
    3eba:	00004497          	auipc	s1,0x4
    3ebe:	b9648493          	addi	s1,s1,-1130 # 7a50 <malloc+0x1fae>
    3ec2:	4581                	li	a1,0
    3ec4:	8526                	mv	a0,s1
    3ec6:	00001097          	auipc	ra,0x1
    3eca:	7dc080e7          	jalr	2012(ra) # 56a2 <open>
      if(fd >= 0){
    3ece:	02055463          	bgez	a0,3ef6 <forkforkfork+0xc6>
      if(fork() < 0){
    3ed2:	00001097          	auipc	ra,0x1
    3ed6:	788080e7          	jalr	1928(ra) # 565a <fork>
    3eda:	fe0554e3          	bgez	a0,3ec2 <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3ede:	20200593          	li	a1,514
    3ee2:	8526                	mv	a0,s1
    3ee4:	00001097          	auipc	ra,0x1
    3ee8:	7be080e7          	jalr	1982(ra) # 56a2 <open>
    3eec:	00001097          	auipc	ra,0x1
    3ef0:	79e080e7          	jalr	1950(ra) # 568a <close>
    3ef4:	b7f9                	j	3ec2 <forkforkfork+0x92>
        exit(0);
    3ef6:	4501                	li	a0,0
    3ef8:	00001097          	auipc	ra,0x1
    3efc:	76a080e7          	jalr	1898(ra) # 5662 <exit>

0000000000003f00 <preempt>:
{
    3f00:	7139                	addi	sp,sp,-64
    3f02:	fc06                	sd	ra,56(sp)
    3f04:	f822                	sd	s0,48(sp)
    3f06:	f426                	sd	s1,40(sp)
    3f08:	f04a                	sd	s2,32(sp)
    3f0a:	ec4e                	sd	s3,24(sp)
    3f0c:	e852                	sd	s4,16(sp)
    3f0e:	0080                	addi	s0,sp,64
    3f10:	8a2a                	mv	s4,a0
  pid1 = fork();
    3f12:	00001097          	auipc	ra,0x1
    3f16:	748080e7          	jalr	1864(ra) # 565a <fork>
  if(pid1 < 0) {
    3f1a:	00054563          	bltz	a0,3f24 <preempt+0x24>
    3f1e:	89aa                	mv	s3,a0
  if(pid1 == 0)
    3f20:	e105                	bnez	a0,3f40 <preempt+0x40>
    for(;;)
    3f22:	a001                	j	3f22 <preempt+0x22>
    printf("%s: fork failed", s);
    3f24:	85d2                	mv	a1,s4
    3f26:	00003517          	auipc	a0,0x3
    3f2a:	a8250513          	addi	a0,a0,-1406 # 69a8 <malloc+0xf06>
    3f2e:	00002097          	auipc	ra,0x2
    3f32:	ab4080e7          	jalr	-1356(ra) # 59e2 <printf>
    exit(1);
    3f36:	4505                	li	a0,1
    3f38:	00001097          	auipc	ra,0x1
    3f3c:	72a080e7          	jalr	1834(ra) # 5662 <exit>
  pid2 = fork();
    3f40:	00001097          	auipc	ra,0x1
    3f44:	71a080e7          	jalr	1818(ra) # 565a <fork>
    3f48:	892a                	mv	s2,a0
  if(pid2 < 0) {
    3f4a:	00054463          	bltz	a0,3f52 <preempt+0x52>
  if(pid2 == 0)
    3f4e:	e105                	bnez	a0,3f6e <preempt+0x6e>
    for(;;)
    3f50:	a001                	j	3f50 <preempt+0x50>
    printf("%s: fork failed\n", s);
    3f52:	85d2                	mv	a1,s4
    3f54:	00003517          	auipc	a0,0x3
    3f58:	89450513          	addi	a0,a0,-1900 # 67e8 <malloc+0xd46>
    3f5c:	00002097          	auipc	ra,0x2
    3f60:	a86080e7          	jalr	-1402(ra) # 59e2 <printf>
    exit(1);
    3f64:	4505                	li	a0,1
    3f66:	00001097          	auipc	ra,0x1
    3f6a:	6fc080e7          	jalr	1788(ra) # 5662 <exit>
  pipe(pfds);
    3f6e:	fc840513          	addi	a0,s0,-56
    3f72:	00001097          	auipc	ra,0x1
    3f76:	700080e7          	jalr	1792(ra) # 5672 <pipe>
  pid3 = fork();
    3f7a:	00001097          	auipc	ra,0x1
    3f7e:	6e0080e7          	jalr	1760(ra) # 565a <fork>
    3f82:	84aa                	mv	s1,a0
  if(pid3 < 0) {
    3f84:	02054e63          	bltz	a0,3fc0 <preempt+0xc0>
  if(pid3 == 0){
    3f88:	e525                	bnez	a0,3ff0 <preempt+0xf0>
    close(pfds[0]);
    3f8a:	fc842503          	lw	a0,-56(s0)
    3f8e:	00001097          	auipc	ra,0x1
    3f92:	6fc080e7          	jalr	1788(ra) # 568a <close>
    if(write(pfds[1], "x", 1) != 1)
    3f96:	4605                	li	a2,1
    3f98:	00002597          	auipc	a1,0x2
    3f9c:	06858593          	addi	a1,a1,104 # 6000 <malloc+0x55e>
    3fa0:	fcc42503          	lw	a0,-52(s0)
    3fa4:	00001097          	auipc	ra,0x1
    3fa8:	6de080e7          	jalr	1758(ra) # 5682 <write>
    3fac:	4785                	li	a5,1
    3fae:	02f51763          	bne	a0,a5,3fdc <preempt+0xdc>
    close(pfds[1]);
    3fb2:	fcc42503          	lw	a0,-52(s0)
    3fb6:	00001097          	auipc	ra,0x1
    3fba:	6d4080e7          	jalr	1748(ra) # 568a <close>
    for(;;)
    3fbe:	a001                	j	3fbe <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3fc0:	85d2                	mv	a1,s4
    3fc2:	00003517          	auipc	a0,0x3
    3fc6:	82650513          	addi	a0,a0,-2010 # 67e8 <malloc+0xd46>
    3fca:	00002097          	auipc	ra,0x2
    3fce:	a18080e7          	jalr	-1512(ra) # 59e2 <printf>
     exit(1);
    3fd2:	4505                	li	a0,1
    3fd4:	00001097          	auipc	ra,0x1
    3fd8:	68e080e7          	jalr	1678(ra) # 5662 <exit>
      printf("%s: preempt write error", s);
    3fdc:	85d2                	mv	a1,s4
    3fde:	00004517          	auipc	a0,0x4
    3fe2:	a8250513          	addi	a0,a0,-1406 # 7a60 <malloc+0x1fbe>
    3fe6:	00002097          	auipc	ra,0x2
    3fea:	9fc080e7          	jalr	-1540(ra) # 59e2 <printf>
    3fee:	b7d1                	j	3fb2 <preempt+0xb2>
  close(pfds[1]);
    3ff0:	fcc42503          	lw	a0,-52(s0)
    3ff4:	00001097          	auipc	ra,0x1
    3ff8:	696080e7          	jalr	1686(ra) # 568a <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3ffc:	660d                	lui	a2,0x3
    3ffe:	00008597          	auipc	a1,0x8
    4002:	afa58593          	addi	a1,a1,-1286 # baf8 <buf>
    4006:	fc842503          	lw	a0,-56(s0)
    400a:	00001097          	auipc	ra,0x1
    400e:	670080e7          	jalr	1648(ra) # 567a <read>
    4012:	4785                	li	a5,1
    4014:	02f50363          	beq	a0,a5,403a <preempt+0x13a>
    printf("%s: preempt read error", s);
    4018:	85d2                	mv	a1,s4
    401a:	00004517          	auipc	a0,0x4
    401e:	a5e50513          	addi	a0,a0,-1442 # 7a78 <malloc+0x1fd6>
    4022:	00002097          	auipc	ra,0x2
    4026:	9c0080e7          	jalr	-1600(ra) # 59e2 <printf>
}
    402a:	70e2                	ld	ra,56(sp)
    402c:	7442                	ld	s0,48(sp)
    402e:	74a2                	ld	s1,40(sp)
    4030:	7902                	ld	s2,32(sp)
    4032:	69e2                	ld	s3,24(sp)
    4034:	6a42                	ld	s4,16(sp)
    4036:	6121                	addi	sp,sp,64
    4038:	8082                	ret
  close(pfds[0]);
    403a:	fc842503          	lw	a0,-56(s0)
    403e:	00001097          	auipc	ra,0x1
    4042:	64c080e7          	jalr	1612(ra) # 568a <close>
  printf("kill... ");
    4046:	00004517          	auipc	a0,0x4
    404a:	a4a50513          	addi	a0,a0,-1462 # 7a90 <malloc+0x1fee>
    404e:	00002097          	auipc	ra,0x2
    4052:	994080e7          	jalr	-1644(ra) # 59e2 <printf>
  kill(pid1);
    4056:	854e                	mv	a0,s3
    4058:	00001097          	auipc	ra,0x1
    405c:	63a080e7          	jalr	1594(ra) # 5692 <kill>
  kill(pid2);
    4060:	854a                	mv	a0,s2
    4062:	00001097          	auipc	ra,0x1
    4066:	630080e7          	jalr	1584(ra) # 5692 <kill>
  kill(pid3);
    406a:	8526                	mv	a0,s1
    406c:	00001097          	auipc	ra,0x1
    4070:	626080e7          	jalr	1574(ra) # 5692 <kill>
  printf("wait... ");
    4074:	00004517          	auipc	a0,0x4
    4078:	a2c50513          	addi	a0,a0,-1492 # 7aa0 <malloc+0x1ffe>
    407c:	00002097          	auipc	ra,0x2
    4080:	966080e7          	jalr	-1690(ra) # 59e2 <printf>
  wait(0);
    4084:	4501                	li	a0,0
    4086:	00001097          	auipc	ra,0x1
    408a:	5e4080e7          	jalr	1508(ra) # 566a <wait>
  wait(0);
    408e:	4501                	li	a0,0
    4090:	00001097          	auipc	ra,0x1
    4094:	5da080e7          	jalr	1498(ra) # 566a <wait>
  wait(0);
    4098:	4501                	li	a0,0
    409a:	00001097          	auipc	ra,0x1
    409e:	5d0080e7          	jalr	1488(ra) # 566a <wait>
    40a2:	b761                	j	402a <preempt+0x12a>

00000000000040a4 <sbrkfail>:
{
    40a4:	7119                	addi	sp,sp,-128
    40a6:	fc86                	sd	ra,120(sp)
    40a8:	f8a2                	sd	s0,112(sp)
    40aa:	f4a6                	sd	s1,104(sp)
    40ac:	f0ca                	sd	s2,96(sp)
    40ae:	ecce                	sd	s3,88(sp)
    40b0:	e8d2                	sd	s4,80(sp)
    40b2:	e4d6                	sd	s5,72(sp)
    40b4:	0100                	addi	s0,sp,128
    40b6:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    40b8:	fb040513          	addi	a0,s0,-80
    40bc:	00001097          	auipc	ra,0x1
    40c0:	5b6080e7          	jalr	1462(ra) # 5672 <pipe>
    40c4:	e901                	bnez	a0,40d4 <sbrkfail+0x30>
    40c6:	f8040493          	addi	s1,s0,-128
    40ca:	fa840993          	addi	s3,s0,-88
    40ce:	8926                	mv	s2,s1
    if(pids[i] != -1)
    40d0:	5a7d                	li	s4,-1
    40d2:	a085                	j	4132 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    40d4:	85d6                	mv	a1,s5
    40d6:	00003517          	auipc	a0,0x3
    40da:	81a50513          	addi	a0,a0,-2022 # 68f0 <malloc+0xe4e>
    40de:	00002097          	auipc	ra,0x2
    40e2:	904080e7          	jalr	-1788(ra) # 59e2 <printf>
    exit(1);
    40e6:	4505                	li	a0,1
    40e8:	00001097          	auipc	ra,0x1
    40ec:	57a080e7          	jalr	1402(ra) # 5662 <exit>
      sbrk(BIG - (uint64)sbrk(0));
    40f0:	00001097          	auipc	ra,0x1
    40f4:	5fa080e7          	jalr	1530(ra) # 56ea <sbrk>
    40f8:	064007b7          	lui	a5,0x6400
    40fc:	40a7853b          	subw	a0,a5,a0
    4100:	00001097          	auipc	ra,0x1
    4104:	5ea080e7          	jalr	1514(ra) # 56ea <sbrk>
      write(fds[1], "x", 1);
    4108:	4605                	li	a2,1
    410a:	00002597          	auipc	a1,0x2
    410e:	ef658593          	addi	a1,a1,-266 # 6000 <malloc+0x55e>
    4112:	fb442503          	lw	a0,-76(s0)
    4116:	00001097          	auipc	ra,0x1
    411a:	56c080e7          	jalr	1388(ra) # 5682 <write>
      for(;;) sleep(1000);
    411e:	3e800513          	li	a0,1000
    4122:	00001097          	auipc	ra,0x1
    4126:	5d0080e7          	jalr	1488(ra) # 56f2 <sleep>
    412a:	bfd5                	j	411e <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    412c:	0911                	addi	s2,s2,4
    412e:	03390563          	beq	s2,s3,4158 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    4132:	00001097          	auipc	ra,0x1
    4136:	528080e7          	jalr	1320(ra) # 565a <fork>
    413a:	00a92023          	sw	a0,0(s2)
    413e:	d94d                	beqz	a0,40f0 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4140:	ff4506e3          	beq	a0,s4,412c <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    4144:	4605                	li	a2,1
    4146:	faf40593          	addi	a1,s0,-81
    414a:	fb042503          	lw	a0,-80(s0)
    414e:	00001097          	auipc	ra,0x1
    4152:	52c080e7          	jalr	1324(ra) # 567a <read>
    4156:	bfd9                	j	412c <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4158:	6505                	lui	a0,0x1
    415a:	00001097          	auipc	ra,0x1
    415e:	590080e7          	jalr	1424(ra) # 56ea <sbrk>
    4162:	892a                	mv	s2,a0
    if(pids[i] == -1)
    4164:	5a7d                	li	s4,-1
    4166:	a021                	j	416e <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4168:	0491                	addi	s1,s1,4
    416a:	01348f63          	beq	s1,s3,4188 <sbrkfail+0xe4>
    if(pids[i] == -1)
    416e:	4088                	lw	a0,0(s1)
    4170:	ff450ce3          	beq	a0,s4,4168 <sbrkfail+0xc4>
    kill(pids[i]);
    4174:	00001097          	auipc	ra,0x1
    4178:	51e080e7          	jalr	1310(ra) # 5692 <kill>
    wait(0);
    417c:	4501                	li	a0,0
    417e:	00001097          	auipc	ra,0x1
    4182:	4ec080e7          	jalr	1260(ra) # 566a <wait>
    4186:	b7cd                	j	4168 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4188:	57fd                	li	a5,-1
    418a:	04f90163          	beq	s2,a5,41cc <sbrkfail+0x128>
  pid = fork();
    418e:	00001097          	auipc	ra,0x1
    4192:	4cc080e7          	jalr	1228(ra) # 565a <fork>
    4196:	84aa                	mv	s1,a0
  if(pid < 0){
    4198:	04054863          	bltz	a0,41e8 <sbrkfail+0x144>
  if(pid == 0){
    419c:	c525                	beqz	a0,4204 <sbrkfail+0x160>
  wait(&xstatus);
    419e:	fbc40513          	addi	a0,s0,-68
    41a2:	00001097          	auipc	ra,0x1
    41a6:	4c8080e7          	jalr	1224(ra) # 566a <wait>
  if(xstatus != -1 && xstatus != 2)
    41aa:	fbc42783          	lw	a5,-68(s0)
    41ae:	577d                	li	a4,-1
    41b0:	00e78563          	beq	a5,a4,41ba <sbrkfail+0x116>
    41b4:	4709                	li	a4,2
    41b6:	08e79d63          	bne	a5,a4,4250 <sbrkfail+0x1ac>
}
    41ba:	70e6                	ld	ra,120(sp)
    41bc:	7446                	ld	s0,112(sp)
    41be:	74a6                	ld	s1,104(sp)
    41c0:	7906                	ld	s2,96(sp)
    41c2:	69e6                	ld	s3,88(sp)
    41c4:	6a46                	ld	s4,80(sp)
    41c6:	6aa6                	ld	s5,72(sp)
    41c8:	6109                	addi	sp,sp,128
    41ca:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    41cc:	85d6                	mv	a1,s5
    41ce:	00004517          	auipc	a0,0x4
    41d2:	8e250513          	addi	a0,a0,-1822 # 7ab0 <malloc+0x200e>
    41d6:	00002097          	auipc	ra,0x2
    41da:	80c080e7          	jalr	-2036(ra) # 59e2 <printf>
    exit(1);
    41de:	4505                	li	a0,1
    41e0:	00001097          	auipc	ra,0x1
    41e4:	482080e7          	jalr	1154(ra) # 5662 <exit>
    printf("%s: fork failed\n", s);
    41e8:	85d6                	mv	a1,s5
    41ea:	00002517          	auipc	a0,0x2
    41ee:	5fe50513          	addi	a0,a0,1534 # 67e8 <malloc+0xd46>
    41f2:	00001097          	auipc	ra,0x1
    41f6:	7f0080e7          	jalr	2032(ra) # 59e2 <printf>
    exit(1);
    41fa:	4505                	li	a0,1
    41fc:	00001097          	auipc	ra,0x1
    4200:	466080e7          	jalr	1126(ra) # 5662 <exit>
    a = sbrk(0);
    4204:	4501                	li	a0,0
    4206:	00001097          	auipc	ra,0x1
    420a:	4e4080e7          	jalr	1252(ra) # 56ea <sbrk>
    420e:	892a                	mv	s2,a0
    sbrk(10*BIG);
    4210:	3e800537          	lui	a0,0x3e800
    4214:	00001097          	auipc	ra,0x1
    4218:	4d6080e7          	jalr	1238(ra) # 56ea <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    421c:	874a                	mv	a4,s2
    421e:	3e8007b7          	lui	a5,0x3e800
    4222:	97ca                	add	a5,a5,s2
    4224:	6685                	lui	a3,0x1
      n += *(a+i);
    4226:	00074603          	lbu	a2,0(a4)
    422a:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    422c:	9736                	add	a4,a4,a3
    422e:	fee79ce3          	bne	a5,a4,4226 <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    4232:	8626                	mv	a2,s1
    4234:	85d6                	mv	a1,s5
    4236:	00004517          	auipc	a0,0x4
    423a:	89a50513          	addi	a0,a0,-1894 # 7ad0 <malloc+0x202e>
    423e:	00001097          	auipc	ra,0x1
    4242:	7a4080e7          	jalr	1956(ra) # 59e2 <printf>
    exit(1);
    4246:	4505                	li	a0,1
    4248:	00001097          	auipc	ra,0x1
    424c:	41a080e7          	jalr	1050(ra) # 5662 <exit>
    exit(1);
    4250:	4505                	li	a0,1
    4252:	00001097          	auipc	ra,0x1
    4256:	410080e7          	jalr	1040(ra) # 5662 <exit>

000000000000425a <reparent>:
{
    425a:	7179                	addi	sp,sp,-48
    425c:	f406                	sd	ra,40(sp)
    425e:	f022                	sd	s0,32(sp)
    4260:	ec26                	sd	s1,24(sp)
    4262:	e84a                	sd	s2,16(sp)
    4264:	e44e                	sd	s3,8(sp)
    4266:	e052                	sd	s4,0(sp)
    4268:	1800                	addi	s0,sp,48
    426a:	89aa                	mv	s3,a0
  int master_pid = getpid();
    426c:	00001097          	auipc	ra,0x1
    4270:	476080e7          	jalr	1142(ra) # 56e2 <getpid>
    4274:	8a2a                	mv	s4,a0
    4276:	0c800913          	li	s2,200
    int pid = fork();
    427a:	00001097          	auipc	ra,0x1
    427e:	3e0080e7          	jalr	992(ra) # 565a <fork>
    4282:	84aa                	mv	s1,a0
    if(pid < 0){
    4284:	02054263          	bltz	a0,42a8 <reparent+0x4e>
    if(pid){
    4288:	cd21                	beqz	a0,42e0 <reparent+0x86>
      if(wait(0) != pid){
    428a:	4501                	li	a0,0
    428c:	00001097          	auipc	ra,0x1
    4290:	3de080e7          	jalr	990(ra) # 566a <wait>
    4294:	02951863          	bne	a0,s1,42c4 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4298:	397d                	addiw	s2,s2,-1
    429a:	fe0910e3          	bnez	s2,427a <reparent+0x20>
  exit(0);
    429e:	4501                	li	a0,0
    42a0:	00001097          	auipc	ra,0x1
    42a4:	3c2080e7          	jalr	962(ra) # 5662 <exit>
      printf("%s: fork failed\n", s);
    42a8:	85ce                	mv	a1,s3
    42aa:	00002517          	auipc	a0,0x2
    42ae:	53e50513          	addi	a0,a0,1342 # 67e8 <malloc+0xd46>
    42b2:	00001097          	auipc	ra,0x1
    42b6:	730080e7          	jalr	1840(ra) # 59e2 <printf>
      exit(1);
    42ba:	4505                	li	a0,1
    42bc:	00001097          	auipc	ra,0x1
    42c0:	3a6080e7          	jalr	934(ra) # 5662 <exit>
        printf("%s: wait wrong pid\n", s);
    42c4:	85ce                	mv	a1,s3
    42c6:	00002517          	auipc	a0,0x2
    42ca:	6aa50513          	addi	a0,a0,1706 # 6970 <malloc+0xece>
    42ce:	00001097          	auipc	ra,0x1
    42d2:	714080e7          	jalr	1812(ra) # 59e2 <printf>
        exit(1);
    42d6:	4505                	li	a0,1
    42d8:	00001097          	auipc	ra,0x1
    42dc:	38a080e7          	jalr	906(ra) # 5662 <exit>
      int pid2 = fork();
    42e0:	00001097          	auipc	ra,0x1
    42e4:	37a080e7          	jalr	890(ra) # 565a <fork>
      if(pid2 < 0){
    42e8:	00054763          	bltz	a0,42f6 <reparent+0x9c>
      exit(0);
    42ec:	4501                	li	a0,0
    42ee:	00001097          	auipc	ra,0x1
    42f2:	374080e7          	jalr	884(ra) # 5662 <exit>
        kill(master_pid);
    42f6:	8552                	mv	a0,s4
    42f8:	00001097          	auipc	ra,0x1
    42fc:	39a080e7          	jalr	922(ra) # 5692 <kill>
        exit(1);
    4300:	4505                	li	a0,1
    4302:	00001097          	auipc	ra,0x1
    4306:	360080e7          	jalr	864(ra) # 5662 <exit>

000000000000430a <mem>:
{
    430a:	7139                	addi	sp,sp,-64
    430c:	fc06                	sd	ra,56(sp)
    430e:	f822                	sd	s0,48(sp)
    4310:	f426                	sd	s1,40(sp)
    4312:	f04a                	sd	s2,32(sp)
    4314:	ec4e                	sd	s3,24(sp)
    4316:	0080                	addi	s0,sp,64
    4318:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    431a:	00001097          	auipc	ra,0x1
    431e:	340080e7          	jalr	832(ra) # 565a <fork>
    m1 = 0;
    4322:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    4324:	6909                	lui	s2,0x2
    4326:	71190913          	addi	s2,s2,1809 # 2711 <sbrkbasic+0x12d>
  if((pid = fork()) == 0){
    432a:	e135                	bnez	a0,438e <mem+0x84>
    while((m2 = malloc(10001)) != 0){
    432c:	854a                	mv	a0,s2
    432e:	00001097          	auipc	ra,0x1
    4332:	774080e7          	jalr	1908(ra) # 5aa2 <malloc>
    4336:	c501                	beqz	a0,433e <mem+0x34>
      *(char**)m2 = m1;
    4338:	e104                	sd	s1,0(a0)
      m1 = m2;
    433a:	84aa                	mv	s1,a0
    433c:	bfc5                	j	432c <mem+0x22>
    while(m1){
    433e:	c899                	beqz	s1,4354 <mem+0x4a>
      m2 = *(char**)m1;
    4340:	0004b903          	ld	s2,0(s1)
      free(m1);
    4344:	8526                	mv	a0,s1
    4346:	00001097          	auipc	ra,0x1
    434a:	6d2080e7          	jalr	1746(ra) # 5a18 <free>
      m1 = m2;
    434e:	84ca                	mv	s1,s2
    while(m1){
    4350:	fe0918e3          	bnez	s2,4340 <mem+0x36>
    m1 = malloc(1024*20);
    4354:	6515                	lui	a0,0x5
    4356:	00001097          	auipc	ra,0x1
    435a:	74c080e7          	jalr	1868(ra) # 5aa2 <malloc>
    if(m1 == 0){
    435e:	c911                	beqz	a0,4372 <mem+0x68>
    free(m1);
    4360:	00001097          	auipc	ra,0x1
    4364:	6b8080e7          	jalr	1720(ra) # 5a18 <free>
    exit(0);
    4368:	4501                	li	a0,0
    436a:	00001097          	auipc	ra,0x1
    436e:	2f8080e7          	jalr	760(ra) # 5662 <exit>
      printf("couldn't allocate mem?!!\n", s);
    4372:	85ce                	mv	a1,s3
    4374:	00003517          	auipc	a0,0x3
    4378:	78c50513          	addi	a0,a0,1932 # 7b00 <malloc+0x205e>
    437c:	00001097          	auipc	ra,0x1
    4380:	666080e7          	jalr	1638(ra) # 59e2 <printf>
      exit(1);
    4384:	4505                	li	a0,1
    4386:	00001097          	auipc	ra,0x1
    438a:	2dc080e7          	jalr	732(ra) # 5662 <exit>
    wait(&xstatus);
    438e:	fcc40513          	addi	a0,s0,-52
    4392:	00001097          	auipc	ra,0x1
    4396:	2d8080e7          	jalr	728(ra) # 566a <wait>
    if(xstatus == -1){
    439a:	fcc42503          	lw	a0,-52(s0)
    439e:	57fd                	li	a5,-1
    43a0:	00f50663          	beq	a0,a5,43ac <mem+0xa2>
    exit(xstatus);
    43a4:	00001097          	auipc	ra,0x1
    43a8:	2be080e7          	jalr	702(ra) # 5662 <exit>
      exit(0);
    43ac:	4501                	li	a0,0
    43ae:	00001097          	auipc	ra,0x1
    43b2:	2b4080e7          	jalr	692(ra) # 5662 <exit>

00000000000043b6 <sharedfd>:
{
    43b6:	7159                	addi	sp,sp,-112
    43b8:	f486                	sd	ra,104(sp)
    43ba:	f0a2                	sd	s0,96(sp)
    43bc:	eca6                	sd	s1,88(sp)
    43be:	e8ca                	sd	s2,80(sp)
    43c0:	e4ce                	sd	s3,72(sp)
    43c2:	e0d2                	sd	s4,64(sp)
    43c4:	fc56                	sd	s5,56(sp)
    43c6:	f85a                	sd	s6,48(sp)
    43c8:	f45e                	sd	s7,40(sp)
    43ca:	1880                	addi	s0,sp,112
    43cc:	89aa                	mv	s3,a0
  unlink("sharedfd");
    43ce:	00003517          	auipc	a0,0x3
    43d2:	75250513          	addi	a0,a0,1874 # 7b20 <malloc+0x207e>
    43d6:	00001097          	auipc	ra,0x1
    43da:	2dc080e7          	jalr	732(ra) # 56b2 <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    43de:	20200593          	li	a1,514
    43e2:	00003517          	auipc	a0,0x3
    43e6:	73e50513          	addi	a0,a0,1854 # 7b20 <malloc+0x207e>
    43ea:	00001097          	auipc	ra,0x1
    43ee:	2b8080e7          	jalr	696(ra) # 56a2 <open>
  if(fd < 0){
    43f2:	04054a63          	bltz	a0,4446 <sharedfd+0x90>
    43f6:	892a                	mv	s2,a0
  pid = fork();
    43f8:	00001097          	auipc	ra,0x1
    43fc:	262080e7          	jalr	610(ra) # 565a <fork>
    4400:	8a2a                	mv	s4,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    4402:	06300593          	li	a1,99
    4406:	c119                	beqz	a0,440c <sharedfd+0x56>
    4408:	07000593          	li	a1,112
    440c:	4629                	li	a2,10
    440e:	fa040513          	addi	a0,s0,-96
    4412:	00001097          	auipc	ra,0x1
    4416:	03a080e7          	jalr	58(ra) # 544c <memset>
    441a:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    441e:	4629                	li	a2,10
    4420:	fa040593          	addi	a1,s0,-96
    4424:	854a                	mv	a0,s2
    4426:	00001097          	auipc	ra,0x1
    442a:	25c080e7          	jalr	604(ra) # 5682 <write>
    442e:	47a9                	li	a5,10
    4430:	02f51963          	bne	a0,a5,4462 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4434:	34fd                	addiw	s1,s1,-1
    4436:	f4e5                	bnez	s1,441e <sharedfd+0x68>
  if(pid == 0) {
    4438:	040a1363          	bnez	s4,447e <sharedfd+0xc8>
    exit(0);
    443c:	4501                	li	a0,0
    443e:	00001097          	auipc	ra,0x1
    4442:	224080e7          	jalr	548(ra) # 5662 <exit>
    printf("%s: cannot open sharedfd for writing", s);
    4446:	85ce                	mv	a1,s3
    4448:	00003517          	auipc	a0,0x3
    444c:	6e850513          	addi	a0,a0,1768 # 7b30 <malloc+0x208e>
    4450:	00001097          	auipc	ra,0x1
    4454:	592080e7          	jalr	1426(ra) # 59e2 <printf>
    exit(1);
    4458:	4505                	li	a0,1
    445a:	00001097          	auipc	ra,0x1
    445e:	208080e7          	jalr	520(ra) # 5662 <exit>
      printf("%s: write sharedfd failed\n", s);
    4462:	85ce                	mv	a1,s3
    4464:	00003517          	auipc	a0,0x3
    4468:	6f450513          	addi	a0,a0,1780 # 7b58 <malloc+0x20b6>
    446c:	00001097          	auipc	ra,0x1
    4470:	576080e7          	jalr	1398(ra) # 59e2 <printf>
      exit(1);
    4474:	4505                	li	a0,1
    4476:	00001097          	auipc	ra,0x1
    447a:	1ec080e7          	jalr	492(ra) # 5662 <exit>
    wait(&xstatus);
    447e:	f9c40513          	addi	a0,s0,-100
    4482:	00001097          	auipc	ra,0x1
    4486:	1e8080e7          	jalr	488(ra) # 566a <wait>
    if(xstatus != 0)
    448a:	f9c42a03          	lw	s4,-100(s0)
    448e:	000a0763          	beqz	s4,449c <sharedfd+0xe6>
      exit(xstatus);
    4492:	8552                	mv	a0,s4
    4494:	00001097          	auipc	ra,0x1
    4498:	1ce080e7          	jalr	462(ra) # 5662 <exit>
  close(fd);
    449c:	854a                	mv	a0,s2
    449e:	00001097          	auipc	ra,0x1
    44a2:	1ec080e7          	jalr	492(ra) # 568a <close>
  fd = open("sharedfd", 0);
    44a6:	4581                	li	a1,0
    44a8:	00003517          	auipc	a0,0x3
    44ac:	67850513          	addi	a0,a0,1656 # 7b20 <malloc+0x207e>
    44b0:	00001097          	auipc	ra,0x1
    44b4:	1f2080e7          	jalr	498(ra) # 56a2 <open>
    44b8:	8baa                	mv	s7,a0
  nc = np = 0;
    44ba:	8ad2                	mv	s5,s4
  if(fd < 0){
    44bc:	02054563          	bltz	a0,44e6 <sharedfd+0x130>
    44c0:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    44c4:	06300493          	li	s1,99
      if(buf[i] == 'p')
    44c8:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    44cc:	4629                	li	a2,10
    44ce:	fa040593          	addi	a1,s0,-96
    44d2:	855e                	mv	a0,s7
    44d4:	00001097          	auipc	ra,0x1
    44d8:	1a6080e7          	jalr	422(ra) # 567a <read>
    44dc:	02a05f63          	blez	a0,451a <sharedfd+0x164>
    44e0:	fa040793          	addi	a5,s0,-96
    44e4:	a01d                	j	450a <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    44e6:	85ce                	mv	a1,s3
    44e8:	00003517          	auipc	a0,0x3
    44ec:	69050513          	addi	a0,a0,1680 # 7b78 <malloc+0x20d6>
    44f0:	00001097          	auipc	ra,0x1
    44f4:	4f2080e7          	jalr	1266(ra) # 59e2 <printf>
    exit(1);
    44f8:	4505                	li	a0,1
    44fa:	00001097          	auipc	ra,0x1
    44fe:	168080e7          	jalr	360(ra) # 5662 <exit>
        nc++;
    4502:	2a05                	addiw	s4,s4,1
    for(i = 0; i < sizeof(buf); i++){
    4504:	0785                	addi	a5,a5,1
    4506:	fd2783e3          	beq	a5,s2,44cc <sharedfd+0x116>
      if(buf[i] == 'c')
    450a:	0007c703          	lbu	a4,0(a5) # 3e800000 <_end+0x3e7f14f8>
    450e:	fe970ae3          	beq	a4,s1,4502 <sharedfd+0x14c>
      if(buf[i] == 'p')
    4512:	ff6719e3          	bne	a4,s6,4504 <sharedfd+0x14e>
        np++;
    4516:	2a85                	addiw	s5,s5,1
    4518:	b7f5                	j	4504 <sharedfd+0x14e>
  close(fd);
    451a:	855e                	mv	a0,s7
    451c:	00001097          	auipc	ra,0x1
    4520:	16e080e7          	jalr	366(ra) # 568a <close>
  unlink("sharedfd");
    4524:	00003517          	auipc	a0,0x3
    4528:	5fc50513          	addi	a0,a0,1532 # 7b20 <malloc+0x207e>
    452c:	00001097          	auipc	ra,0x1
    4530:	186080e7          	jalr	390(ra) # 56b2 <unlink>
  if(nc == N*SZ && np == N*SZ){
    4534:	6789                	lui	a5,0x2
    4536:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x12c>
    453a:	00fa1763          	bne	s4,a5,4548 <sharedfd+0x192>
    453e:	6789                	lui	a5,0x2
    4540:	71078793          	addi	a5,a5,1808 # 2710 <sbrkbasic+0x12c>
    4544:	02fa8063          	beq	s5,a5,4564 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4548:	85ce                	mv	a1,s3
    454a:	00003517          	auipc	a0,0x3
    454e:	65650513          	addi	a0,a0,1622 # 7ba0 <malloc+0x20fe>
    4552:	00001097          	auipc	ra,0x1
    4556:	490080e7          	jalr	1168(ra) # 59e2 <printf>
    exit(1);
    455a:	4505                	li	a0,1
    455c:	00001097          	auipc	ra,0x1
    4560:	106080e7          	jalr	262(ra) # 5662 <exit>
    exit(0);
    4564:	4501                	li	a0,0
    4566:	00001097          	auipc	ra,0x1
    456a:	0fc080e7          	jalr	252(ra) # 5662 <exit>

000000000000456e <fourfiles>:
{
    456e:	7135                	addi	sp,sp,-160
    4570:	ed06                	sd	ra,152(sp)
    4572:	e922                	sd	s0,144(sp)
    4574:	e526                	sd	s1,136(sp)
    4576:	e14a                	sd	s2,128(sp)
    4578:	fcce                	sd	s3,120(sp)
    457a:	f8d2                	sd	s4,112(sp)
    457c:	f4d6                	sd	s5,104(sp)
    457e:	f0da                	sd	s6,96(sp)
    4580:	ecde                	sd	s7,88(sp)
    4582:	e8e2                	sd	s8,80(sp)
    4584:	e4e6                	sd	s9,72(sp)
    4586:	e0ea                	sd	s10,64(sp)
    4588:	fc6e                	sd	s11,56(sp)
    458a:	1100                	addi	s0,sp,160
    458c:	8d2a                	mv	s10,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    458e:	00003797          	auipc	a5,0x3
    4592:	62a78793          	addi	a5,a5,1578 # 7bb8 <malloc+0x2116>
    4596:	f6f43823          	sd	a5,-144(s0)
    459a:	00003797          	auipc	a5,0x3
    459e:	62678793          	addi	a5,a5,1574 # 7bc0 <malloc+0x211e>
    45a2:	f6f43c23          	sd	a5,-136(s0)
    45a6:	00003797          	auipc	a5,0x3
    45aa:	62278793          	addi	a5,a5,1570 # 7bc8 <malloc+0x2126>
    45ae:	f8f43023          	sd	a5,-128(s0)
    45b2:	00003797          	auipc	a5,0x3
    45b6:	61e78793          	addi	a5,a5,1566 # 7bd0 <malloc+0x212e>
    45ba:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    45be:	f7040b13          	addi	s6,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    45c2:	895a                	mv	s2,s6
  for(pi = 0; pi < NCHILD; pi++){
    45c4:	4481                	li	s1,0
    45c6:	4a11                	li	s4,4
    fname = names[pi];
    45c8:	00093983          	ld	s3,0(s2)
    unlink(fname);
    45cc:	854e                	mv	a0,s3
    45ce:	00001097          	auipc	ra,0x1
    45d2:	0e4080e7          	jalr	228(ra) # 56b2 <unlink>
    pid = fork();
    45d6:	00001097          	auipc	ra,0x1
    45da:	084080e7          	jalr	132(ra) # 565a <fork>
    if(pid < 0){
    45de:	04054063          	bltz	a0,461e <fourfiles+0xb0>
    if(pid == 0){
    45e2:	cd21                	beqz	a0,463a <fourfiles+0xcc>
  for(pi = 0; pi < NCHILD; pi++){
    45e4:	2485                	addiw	s1,s1,1
    45e6:	0921                	addi	s2,s2,8
    45e8:	ff4490e3          	bne	s1,s4,45c8 <fourfiles+0x5a>
    45ec:	4491                	li	s1,4
    wait(&xstatus);
    45ee:	f6c40513          	addi	a0,s0,-148
    45f2:	00001097          	auipc	ra,0x1
    45f6:	078080e7          	jalr	120(ra) # 566a <wait>
    if(xstatus != 0)
    45fa:	f6c42503          	lw	a0,-148(s0)
    45fe:	e961                	bnez	a0,46ce <fourfiles+0x160>
  for(pi = 0; pi < NCHILD; pi++){
    4600:	34fd                	addiw	s1,s1,-1
    4602:	f4f5                	bnez	s1,45ee <fourfiles+0x80>
    4604:	03000a93          	li	s5,48
    total = 0;
    4608:	8daa                	mv	s11,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    460a:	00007997          	auipc	s3,0x7
    460e:	4ee98993          	addi	s3,s3,1262 # baf8 <buf>
    if(total != N*SZ){
    4612:	6c05                	lui	s8,0x1
    4614:	770c0c13          	addi	s8,s8,1904 # 1770 <pipe1+0x1c>
  for(i = 0; i < NCHILD; i++){
    4618:	03400c93          	li	s9,52
    461c:	aa15                	j	4750 <fourfiles+0x1e2>
      printf("fork failed\n", s);
    461e:	85ea                	mv	a1,s10
    4620:	00002517          	auipc	a0,0x2
    4624:	5d050513          	addi	a0,a0,1488 # 6bf0 <malloc+0x114e>
    4628:	00001097          	auipc	ra,0x1
    462c:	3ba080e7          	jalr	954(ra) # 59e2 <printf>
      exit(1);
    4630:	4505                	li	a0,1
    4632:	00001097          	auipc	ra,0x1
    4636:	030080e7          	jalr	48(ra) # 5662 <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    463a:	20200593          	li	a1,514
    463e:	854e                	mv	a0,s3
    4640:	00001097          	auipc	ra,0x1
    4644:	062080e7          	jalr	98(ra) # 56a2 <open>
    4648:	892a                	mv	s2,a0
      if(fd < 0){
    464a:	04054663          	bltz	a0,4696 <fourfiles+0x128>
      memset(buf, '0'+pi, SZ);
    464e:	1f400613          	li	a2,500
    4652:	0304859b          	addiw	a1,s1,48
    4656:	00007517          	auipc	a0,0x7
    465a:	4a250513          	addi	a0,a0,1186 # baf8 <buf>
    465e:	00001097          	auipc	ra,0x1
    4662:	dee080e7          	jalr	-530(ra) # 544c <memset>
    4666:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4668:	00007997          	auipc	s3,0x7
    466c:	49098993          	addi	s3,s3,1168 # baf8 <buf>
    4670:	1f400613          	li	a2,500
    4674:	85ce                	mv	a1,s3
    4676:	854a                	mv	a0,s2
    4678:	00001097          	auipc	ra,0x1
    467c:	00a080e7          	jalr	10(ra) # 5682 <write>
    4680:	1f400793          	li	a5,500
    4684:	02f51763          	bne	a0,a5,46b2 <fourfiles+0x144>
      for(i = 0; i < N; i++){
    4688:	34fd                	addiw	s1,s1,-1
    468a:	f0fd                	bnez	s1,4670 <fourfiles+0x102>
      exit(0);
    468c:	4501                	li	a0,0
    468e:	00001097          	auipc	ra,0x1
    4692:	fd4080e7          	jalr	-44(ra) # 5662 <exit>
        printf("create failed\n", s);
    4696:	85ea                	mv	a1,s10
    4698:	00003517          	auipc	a0,0x3
    469c:	54050513          	addi	a0,a0,1344 # 7bd8 <malloc+0x2136>
    46a0:	00001097          	auipc	ra,0x1
    46a4:	342080e7          	jalr	834(ra) # 59e2 <printf>
        exit(1);
    46a8:	4505                	li	a0,1
    46aa:	00001097          	auipc	ra,0x1
    46ae:	fb8080e7          	jalr	-72(ra) # 5662 <exit>
          printf("write failed %d\n", n);
    46b2:	85aa                	mv	a1,a0
    46b4:	00003517          	auipc	a0,0x3
    46b8:	53450513          	addi	a0,a0,1332 # 7be8 <malloc+0x2146>
    46bc:	00001097          	auipc	ra,0x1
    46c0:	326080e7          	jalr	806(ra) # 59e2 <printf>
          exit(1);
    46c4:	4505                	li	a0,1
    46c6:	00001097          	auipc	ra,0x1
    46ca:	f9c080e7          	jalr	-100(ra) # 5662 <exit>
      exit(xstatus);
    46ce:	00001097          	auipc	ra,0x1
    46d2:	f94080e7          	jalr	-108(ra) # 5662 <exit>
      total += n;
    46d6:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    46da:	660d                	lui	a2,0x3
    46dc:	85ce                	mv	a1,s3
    46de:	8552                	mv	a0,s4
    46e0:	00001097          	auipc	ra,0x1
    46e4:	f9a080e7          	jalr	-102(ra) # 567a <read>
    46e8:	04a05463          	blez	a0,4730 <fourfiles+0x1c2>
        if(buf[j] != '0'+i){
    46ec:	0009c783          	lbu	a5,0(s3)
    46f0:	02979263          	bne	a5,s1,4714 <fourfiles+0x1a6>
    46f4:	00007797          	auipc	a5,0x7
    46f8:	40578793          	addi	a5,a5,1029 # baf9 <buf+0x1>
    46fc:	fff5069b          	addiw	a3,a0,-1
    4700:	1682                	slli	a3,a3,0x20
    4702:	9281                	srli	a3,a3,0x20
    4704:	96be                	add	a3,a3,a5
      for(j = 0; j < n; j++){
    4706:	fcd788e3          	beq	a5,a3,46d6 <fourfiles+0x168>
        if(buf[j] != '0'+i){
    470a:	0007c703          	lbu	a4,0(a5)
    470e:	0785                	addi	a5,a5,1
    4710:	fe970be3          	beq	a4,s1,4706 <fourfiles+0x198>
          printf("wrong char\n", s);
    4714:	85ea                	mv	a1,s10
    4716:	00003517          	auipc	a0,0x3
    471a:	4ea50513          	addi	a0,a0,1258 # 7c00 <malloc+0x215e>
    471e:	00001097          	auipc	ra,0x1
    4722:	2c4080e7          	jalr	708(ra) # 59e2 <printf>
          exit(1);
    4726:	4505                	li	a0,1
    4728:	00001097          	auipc	ra,0x1
    472c:	f3a080e7          	jalr	-198(ra) # 5662 <exit>
    close(fd);
    4730:	8552                	mv	a0,s4
    4732:	00001097          	auipc	ra,0x1
    4736:	f58080e7          	jalr	-168(ra) # 568a <close>
    if(total != N*SZ){
    473a:	03891863          	bne	s2,s8,476a <fourfiles+0x1fc>
    unlink(fname);
    473e:	855e                	mv	a0,s7
    4740:	00001097          	auipc	ra,0x1
    4744:	f72080e7          	jalr	-142(ra) # 56b2 <unlink>
  for(i = 0; i < NCHILD; i++){
    4748:	0b21                	addi	s6,s6,8
    474a:	2a85                	addiw	s5,s5,1
    474c:	039a8d63          	beq	s5,s9,4786 <fourfiles+0x218>
    fname = names[i];
    4750:	000b3b83          	ld	s7,0(s6) # 3000 <dirtest+0x52>
    fd = open(fname, 0);
    4754:	4581                	li	a1,0
    4756:	855e                	mv	a0,s7
    4758:	00001097          	auipc	ra,0x1
    475c:	f4a080e7          	jalr	-182(ra) # 56a2 <open>
    4760:	8a2a                	mv	s4,a0
    total = 0;
    4762:	896e                	mv	s2,s11
    4764:	000a849b          	sext.w	s1,s5
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4768:	bf8d                	j	46da <fourfiles+0x16c>
      printf("wrong length %d\n", total);
    476a:	85ca                	mv	a1,s2
    476c:	00003517          	auipc	a0,0x3
    4770:	4a450513          	addi	a0,a0,1188 # 7c10 <malloc+0x216e>
    4774:	00001097          	auipc	ra,0x1
    4778:	26e080e7          	jalr	622(ra) # 59e2 <printf>
      exit(1);
    477c:	4505                	li	a0,1
    477e:	00001097          	auipc	ra,0x1
    4782:	ee4080e7          	jalr	-284(ra) # 5662 <exit>
}
    4786:	60ea                	ld	ra,152(sp)
    4788:	644a                	ld	s0,144(sp)
    478a:	64aa                	ld	s1,136(sp)
    478c:	690a                	ld	s2,128(sp)
    478e:	79e6                	ld	s3,120(sp)
    4790:	7a46                	ld	s4,112(sp)
    4792:	7aa6                	ld	s5,104(sp)
    4794:	7b06                	ld	s6,96(sp)
    4796:	6be6                	ld	s7,88(sp)
    4798:	6c46                	ld	s8,80(sp)
    479a:	6ca6                	ld	s9,72(sp)
    479c:	6d06                	ld	s10,64(sp)
    479e:	7de2                	ld	s11,56(sp)
    47a0:	610d                	addi	sp,sp,160
    47a2:	8082                	ret

00000000000047a4 <concreate>:
{
    47a4:	7135                	addi	sp,sp,-160
    47a6:	ed06                	sd	ra,152(sp)
    47a8:	e922                	sd	s0,144(sp)
    47aa:	e526                	sd	s1,136(sp)
    47ac:	e14a                	sd	s2,128(sp)
    47ae:	fcce                	sd	s3,120(sp)
    47b0:	f8d2                	sd	s4,112(sp)
    47b2:	f4d6                	sd	s5,104(sp)
    47b4:	f0da                	sd	s6,96(sp)
    47b6:	ecde                	sd	s7,88(sp)
    47b8:	1100                	addi	s0,sp,160
    47ba:	89aa                	mv	s3,a0
  file[0] = 'C';
    47bc:	04300793          	li	a5,67
    47c0:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    47c4:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    47c8:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    47ca:	4b0d                	li	s6,3
    47cc:	4a85                	li	s5,1
      link("C0", file);
    47ce:	00003b97          	auipc	s7,0x3
    47d2:	45ab8b93          	addi	s7,s7,1114 # 7c28 <malloc+0x2186>
  for(i = 0; i < N; i++){
    47d6:	02800a13          	li	s4,40
    47da:	acc1                	j	4aaa <concreate+0x306>
      link("C0", file);
    47dc:	fa840593          	addi	a1,s0,-88
    47e0:	855e                	mv	a0,s7
    47e2:	00001097          	auipc	ra,0x1
    47e6:	ee0080e7          	jalr	-288(ra) # 56c2 <link>
    if(pid == 0) {
    47ea:	a45d                	j	4a90 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    47ec:	4795                	li	a5,5
    47ee:	02f9693b          	remw	s2,s2,a5
    47f2:	4785                	li	a5,1
    47f4:	02f90b63          	beq	s2,a5,482a <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    47f8:	20200593          	li	a1,514
    47fc:	fa840513          	addi	a0,s0,-88
    4800:	00001097          	auipc	ra,0x1
    4804:	ea2080e7          	jalr	-350(ra) # 56a2 <open>
      if(fd < 0){
    4808:	26055b63          	bgez	a0,4a7e <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    480c:	fa840593          	addi	a1,s0,-88
    4810:	00003517          	auipc	a0,0x3
    4814:	42050513          	addi	a0,a0,1056 # 7c30 <malloc+0x218e>
    4818:	00001097          	auipc	ra,0x1
    481c:	1ca080e7          	jalr	458(ra) # 59e2 <printf>
        exit(1);
    4820:	4505                	li	a0,1
    4822:	00001097          	auipc	ra,0x1
    4826:	e40080e7          	jalr	-448(ra) # 5662 <exit>
      link("C0", file);
    482a:	fa840593          	addi	a1,s0,-88
    482e:	00003517          	auipc	a0,0x3
    4832:	3fa50513          	addi	a0,a0,1018 # 7c28 <malloc+0x2186>
    4836:	00001097          	auipc	ra,0x1
    483a:	e8c080e7          	jalr	-372(ra) # 56c2 <link>
      exit(0);
    483e:	4501                	li	a0,0
    4840:	00001097          	auipc	ra,0x1
    4844:	e22080e7          	jalr	-478(ra) # 5662 <exit>
        exit(1);
    4848:	4505                	li	a0,1
    484a:	00001097          	auipc	ra,0x1
    484e:	e18080e7          	jalr	-488(ra) # 5662 <exit>
  memset(fa, 0, sizeof(fa));
    4852:	02800613          	li	a2,40
    4856:	4581                	li	a1,0
    4858:	f8040513          	addi	a0,s0,-128
    485c:	00001097          	auipc	ra,0x1
    4860:	bf0080e7          	jalr	-1040(ra) # 544c <memset>
  fd = open(".", 0);
    4864:	4581                	li	a1,0
    4866:	00002517          	auipc	a0,0x2
    486a:	de250513          	addi	a0,a0,-542 # 6648 <malloc+0xba6>
    486e:	00001097          	auipc	ra,0x1
    4872:	e34080e7          	jalr	-460(ra) # 56a2 <open>
    4876:	892a                	mv	s2,a0
  n = 0;
    4878:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    487a:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    487e:	02700b13          	li	s6,39
      fa[i] = 1;
    4882:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4884:	4641                	li	a2,16
    4886:	f7040593          	addi	a1,s0,-144
    488a:	854a                	mv	a0,s2
    488c:	00001097          	auipc	ra,0x1
    4890:	dee080e7          	jalr	-530(ra) # 567a <read>
    4894:	08a05163          	blez	a0,4916 <concreate+0x172>
    if(de.inum == 0)
    4898:	f7045783          	lhu	a5,-144(s0)
    489c:	d7e5                	beqz	a5,4884 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    489e:	f7244783          	lbu	a5,-142(s0)
    48a2:	ff4791e3          	bne	a5,s4,4884 <concreate+0xe0>
    48a6:	f7444783          	lbu	a5,-140(s0)
    48aa:	ffe9                	bnez	a5,4884 <concreate+0xe0>
      i = de.name[1] - '0';
    48ac:	f7344783          	lbu	a5,-141(s0)
    48b0:	fd07879b          	addiw	a5,a5,-48
    48b4:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    48b8:	00eb6f63          	bltu	s6,a4,48d6 <concreate+0x132>
      if(fa[i]){
    48bc:	fb040793          	addi	a5,s0,-80
    48c0:	97ba                	add	a5,a5,a4
    48c2:	fd07c783          	lbu	a5,-48(a5)
    48c6:	eb85                	bnez	a5,48f6 <concreate+0x152>
      fa[i] = 1;
    48c8:	fb040793          	addi	a5,s0,-80
    48cc:	973e                	add	a4,a4,a5
    48ce:	fd770823          	sb	s7,-48(a4)
      n++;
    48d2:	2a85                	addiw	s5,s5,1
    48d4:	bf45                	j	4884 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    48d6:	f7240613          	addi	a2,s0,-142
    48da:	85ce                	mv	a1,s3
    48dc:	00003517          	auipc	a0,0x3
    48e0:	37450513          	addi	a0,a0,884 # 7c50 <malloc+0x21ae>
    48e4:	00001097          	auipc	ra,0x1
    48e8:	0fe080e7          	jalr	254(ra) # 59e2 <printf>
        exit(1);
    48ec:	4505                	li	a0,1
    48ee:	00001097          	auipc	ra,0x1
    48f2:	d74080e7          	jalr	-652(ra) # 5662 <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    48f6:	f7240613          	addi	a2,s0,-142
    48fa:	85ce                	mv	a1,s3
    48fc:	00003517          	auipc	a0,0x3
    4900:	37450513          	addi	a0,a0,884 # 7c70 <malloc+0x21ce>
    4904:	00001097          	auipc	ra,0x1
    4908:	0de080e7          	jalr	222(ra) # 59e2 <printf>
        exit(1);
    490c:	4505                	li	a0,1
    490e:	00001097          	auipc	ra,0x1
    4912:	d54080e7          	jalr	-684(ra) # 5662 <exit>
  close(fd);
    4916:	854a                	mv	a0,s2
    4918:	00001097          	auipc	ra,0x1
    491c:	d72080e7          	jalr	-654(ra) # 568a <close>
  if(n != N){
    4920:	02800793          	li	a5,40
    4924:	00fa9763          	bne	s5,a5,4932 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    4928:	4a8d                	li	s5,3
    492a:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    492c:	02800a13          	li	s4,40
    4930:	a8c9                	j	4a02 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4932:	85ce                	mv	a1,s3
    4934:	00003517          	auipc	a0,0x3
    4938:	36450513          	addi	a0,a0,868 # 7c98 <malloc+0x21f6>
    493c:	00001097          	auipc	ra,0x1
    4940:	0a6080e7          	jalr	166(ra) # 59e2 <printf>
    exit(1);
    4944:	4505                	li	a0,1
    4946:	00001097          	auipc	ra,0x1
    494a:	d1c080e7          	jalr	-740(ra) # 5662 <exit>
      printf("%s: fork failed\n", s);
    494e:	85ce                	mv	a1,s3
    4950:	00002517          	auipc	a0,0x2
    4954:	e9850513          	addi	a0,a0,-360 # 67e8 <malloc+0xd46>
    4958:	00001097          	auipc	ra,0x1
    495c:	08a080e7          	jalr	138(ra) # 59e2 <printf>
      exit(1);
    4960:	4505                	li	a0,1
    4962:	00001097          	auipc	ra,0x1
    4966:	d00080e7          	jalr	-768(ra) # 5662 <exit>
      close(open(file, 0));
    496a:	4581                	li	a1,0
    496c:	fa840513          	addi	a0,s0,-88
    4970:	00001097          	auipc	ra,0x1
    4974:	d32080e7          	jalr	-718(ra) # 56a2 <open>
    4978:	00001097          	auipc	ra,0x1
    497c:	d12080e7          	jalr	-750(ra) # 568a <close>
      close(open(file, 0));
    4980:	4581                	li	a1,0
    4982:	fa840513          	addi	a0,s0,-88
    4986:	00001097          	auipc	ra,0x1
    498a:	d1c080e7          	jalr	-740(ra) # 56a2 <open>
    498e:	00001097          	auipc	ra,0x1
    4992:	cfc080e7          	jalr	-772(ra) # 568a <close>
      close(open(file, 0));
    4996:	4581                	li	a1,0
    4998:	fa840513          	addi	a0,s0,-88
    499c:	00001097          	auipc	ra,0x1
    49a0:	d06080e7          	jalr	-762(ra) # 56a2 <open>
    49a4:	00001097          	auipc	ra,0x1
    49a8:	ce6080e7          	jalr	-794(ra) # 568a <close>
      close(open(file, 0));
    49ac:	4581                	li	a1,0
    49ae:	fa840513          	addi	a0,s0,-88
    49b2:	00001097          	auipc	ra,0x1
    49b6:	cf0080e7          	jalr	-784(ra) # 56a2 <open>
    49ba:	00001097          	auipc	ra,0x1
    49be:	cd0080e7          	jalr	-816(ra) # 568a <close>
      close(open(file, 0));
    49c2:	4581                	li	a1,0
    49c4:	fa840513          	addi	a0,s0,-88
    49c8:	00001097          	auipc	ra,0x1
    49cc:	cda080e7          	jalr	-806(ra) # 56a2 <open>
    49d0:	00001097          	auipc	ra,0x1
    49d4:	cba080e7          	jalr	-838(ra) # 568a <close>
      close(open(file, 0));
    49d8:	4581                	li	a1,0
    49da:	fa840513          	addi	a0,s0,-88
    49de:	00001097          	auipc	ra,0x1
    49e2:	cc4080e7          	jalr	-828(ra) # 56a2 <open>
    49e6:	00001097          	auipc	ra,0x1
    49ea:	ca4080e7          	jalr	-860(ra) # 568a <close>
    if(pid == 0)
    49ee:	08090363          	beqz	s2,4a74 <concreate+0x2d0>
      wait(0);
    49f2:	4501                	li	a0,0
    49f4:	00001097          	auipc	ra,0x1
    49f8:	c76080e7          	jalr	-906(ra) # 566a <wait>
  for(i = 0; i < N; i++){
    49fc:	2485                	addiw	s1,s1,1
    49fe:	0f448563          	beq	s1,s4,4ae8 <concreate+0x344>
    file[1] = '0' + i;
    4a02:	0304879b          	addiw	a5,s1,48
    4a06:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    4a0a:	00001097          	auipc	ra,0x1
    4a0e:	c50080e7          	jalr	-944(ra) # 565a <fork>
    4a12:	892a                	mv	s2,a0
    if(pid < 0){
    4a14:	f2054de3          	bltz	a0,494e <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    4a18:	0354e73b          	remw	a4,s1,s5
    4a1c:	00a767b3          	or	a5,a4,a0
    4a20:	2781                	sext.w	a5,a5
    4a22:	d7a1                	beqz	a5,496a <concreate+0x1c6>
    4a24:	01671363          	bne	a4,s6,4a2a <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    4a28:	f129                	bnez	a0,496a <concreate+0x1c6>
      unlink(file);
    4a2a:	fa840513          	addi	a0,s0,-88
    4a2e:	00001097          	auipc	ra,0x1
    4a32:	c84080e7          	jalr	-892(ra) # 56b2 <unlink>
      unlink(file);
    4a36:	fa840513          	addi	a0,s0,-88
    4a3a:	00001097          	auipc	ra,0x1
    4a3e:	c78080e7          	jalr	-904(ra) # 56b2 <unlink>
      unlink(file);
    4a42:	fa840513          	addi	a0,s0,-88
    4a46:	00001097          	auipc	ra,0x1
    4a4a:	c6c080e7          	jalr	-916(ra) # 56b2 <unlink>
      unlink(file);
    4a4e:	fa840513          	addi	a0,s0,-88
    4a52:	00001097          	auipc	ra,0x1
    4a56:	c60080e7          	jalr	-928(ra) # 56b2 <unlink>
      unlink(file);
    4a5a:	fa840513          	addi	a0,s0,-88
    4a5e:	00001097          	auipc	ra,0x1
    4a62:	c54080e7          	jalr	-940(ra) # 56b2 <unlink>
      unlink(file);
    4a66:	fa840513          	addi	a0,s0,-88
    4a6a:	00001097          	auipc	ra,0x1
    4a6e:	c48080e7          	jalr	-952(ra) # 56b2 <unlink>
    4a72:	bfb5                	j	49ee <concreate+0x24a>
      exit(0);
    4a74:	4501                	li	a0,0
    4a76:	00001097          	auipc	ra,0x1
    4a7a:	bec080e7          	jalr	-1044(ra) # 5662 <exit>
      close(fd);
    4a7e:	00001097          	auipc	ra,0x1
    4a82:	c0c080e7          	jalr	-1012(ra) # 568a <close>
    if(pid == 0) {
    4a86:	bb65                	j	483e <concreate+0x9a>
      close(fd);
    4a88:	00001097          	auipc	ra,0x1
    4a8c:	c02080e7          	jalr	-1022(ra) # 568a <close>
      wait(&xstatus);
    4a90:	f6c40513          	addi	a0,s0,-148
    4a94:	00001097          	auipc	ra,0x1
    4a98:	bd6080e7          	jalr	-1066(ra) # 566a <wait>
      if(xstatus != 0)
    4a9c:	f6c42483          	lw	s1,-148(s0)
    4aa0:	da0494e3          	bnez	s1,4848 <concreate+0xa4>
  for(i = 0; i < N; i++){
    4aa4:	2905                	addiw	s2,s2,1
    4aa6:	db4906e3          	beq	s2,s4,4852 <concreate+0xae>
    file[1] = '0' + i;
    4aaa:	0309079b          	addiw	a5,s2,48
    4aae:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4ab2:	fa840513          	addi	a0,s0,-88
    4ab6:	00001097          	auipc	ra,0x1
    4aba:	bfc080e7          	jalr	-1028(ra) # 56b2 <unlink>
    pid = fork();
    4abe:	00001097          	auipc	ra,0x1
    4ac2:	b9c080e7          	jalr	-1124(ra) # 565a <fork>
    if(pid && (i % 3) == 1){
    4ac6:	d20503e3          	beqz	a0,47ec <concreate+0x48>
    4aca:	036967bb          	remw	a5,s2,s6
    4ace:	d15787e3          	beq	a5,s5,47dc <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    4ad2:	20200593          	li	a1,514
    4ad6:	fa840513          	addi	a0,s0,-88
    4ada:	00001097          	auipc	ra,0x1
    4ade:	bc8080e7          	jalr	-1080(ra) # 56a2 <open>
      if(fd < 0){
    4ae2:	fa0553e3          	bgez	a0,4a88 <concreate+0x2e4>
    4ae6:	b31d                	j	480c <concreate+0x68>
}
    4ae8:	60ea                	ld	ra,152(sp)
    4aea:	644a                	ld	s0,144(sp)
    4aec:	64aa                	ld	s1,136(sp)
    4aee:	690a                	ld	s2,128(sp)
    4af0:	79e6                	ld	s3,120(sp)
    4af2:	7a46                	ld	s4,112(sp)
    4af4:	7aa6                	ld	s5,104(sp)
    4af6:	7b06                	ld	s6,96(sp)
    4af8:	6be6                	ld	s7,88(sp)
    4afa:	610d                	addi	sp,sp,160
    4afc:	8082                	ret

0000000000004afe <bigfile>:
{
    4afe:	7139                	addi	sp,sp,-64
    4b00:	fc06                	sd	ra,56(sp)
    4b02:	f822                	sd	s0,48(sp)
    4b04:	f426                	sd	s1,40(sp)
    4b06:	f04a                	sd	s2,32(sp)
    4b08:	ec4e                	sd	s3,24(sp)
    4b0a:	e852                	sd	s4,16(sp)
    4b0c:	e456                	sd	s5,8(sp)
    4b0e:	0080                	addi	s0,sp,64
    4b10:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    4b12:	00003517          	auipc	a0,0x3
    4b16:	1be50513          	addi	a0,a0,446 # 7cd0 <malloc+0x222e>
    4b1a:	00001097          	auipc	ra,0x1
    4b1e:	b98080e7          	jalr	-1128(ra) # 56b2 <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    4b22:	20200593          	li	a1,514
    4b26:	00003517          	auipc	a0,0x3
    4b2a:	1aa50513          	addi	a0,a0,426 # 7cd0 <malloc+0x222e>
    4b2e:	00001097          	auipc	ra,0x1
    4b32:	b74080e7          	jalr	-1164(ra) # 56a2 <open>
    4b36:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4b38:	4481                	li	s1,0
    memset(buf, i, SZ);
    4b3a:	00007917          	auipc	s2,0x7
    4b3e:	fbe90913          	addi	s2,s2,-66 # baf8 <buf>
  for(i = 0; i < N; i++){
    4b42:	4a51                	li	s4,20
  if(fd < 0){
    4b44:	0a054063          	bltz	a0,4be4 <bigfile+0xe6>
    memset(buf, i, SZ);
    4b48:	25800613          	li	a2,600
    4b4c:	85a6                	mv	a1,s1
    4b4e:	854a                	mv	a0,s2
    4b50:	00001097          	auipc	ra,0x1
    4b54:	8fc080e7          	jalr	-1796(ra) # 544c <memset>
    if(write(fd, buf, SZ) != SZ){
    4b58:	25800613          	li	a2,600
    4b5c:	85ca                	mv	a1,s2
    4b5e:	854e                	mv	a0,s3
    4b60:	00001097          	auipc	ra,0x1
    4b64:	b22080e7          	jalr	-1246(ra) # 5682 <write>
    4b68:	25800793          	li	a5,600
    4b6c:	08f51a63          	bne	a0,a5,4c00 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4b70:	2485                	addiw	s1,s1,1
    4b72:	fd449be3          	bne	s1,s4,4b48 <bigfile+0x4a>
  close(fd);
    4b76:	854e                	mv	a0,s3
    4b78:	00001097          	auipc	ra,0x1
    4b7c:	b12080e7          	jalr	-1262(ra) # 568a <close>
  fd = open("bigfile.dat", 0);
    4b80:	4581                	li	a1,0
    4b82:	00003517          	auipc	a0,0x3
    4b86:	14e50513          	addi	a0,a0,334 # 7cd0 <malloc+0x222e>
    4b8a:	00001097          	auipc	ra,0x1
    4b8e:	b18080e7          	jalr	-1256(ra) # 56a2 <open>
    4b92:	8a2a                	mv	s4,a0
  total = 0;
    4b94:	4981                	li	s3,0
  for(i = 0; ; i++){
    4b96:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4b98:	00007917          	auipc	s2,0x7
    4b9c:	f6090913          	addi	s2,s2,-160 # baf8 <buf>
  if(fd < 0){
    4ba0:	06054e63          	bltz	a0,4c1c <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4ba4:	12c00613          	li	a2,300
    4ba8:	85ca                	mv	a1,s2
    4baa:	8552                	mv	a0,s4
    4bac:	00001097          	auipc	ra,0x1
    4bb0:	ace080e7          	jalr	-1330(ra) # 567a <read>
    if(cc < 0){
    4bb4:	08054263          	bltz	a0,4c38 <bigfile+0x13a>
    if(cc == 0)
    4bb8:	c971                	beqz	a0,4c8c <bigfile+0x18e>
    if(cc != SZ/2){
    4bba:	12c00793          	li	a5,300
    4bbe:	08f51b63          	bne	a0,a5,4c54 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4bc2:	01f4d79b          	srliw	a5,s1,0x1f
    4bc6:	9fa5                	addw	a5,a5,s1
    4bc8:	4017d79b          	sraiw	a5,a5,0x1
    4bcc:	00094703          	lbu	a4,0(s2)
    4bd0:	0af71063          	bne	a4,a5,4c70 <bigfile+0x172>
    4bd4:	12b94703          	lbu	a4,299(s2)
    4bd8:	08f71c63          	bne	a4,a5,4c70 <bigfile+0x172>
    total += cc;
    4bdc:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4be0:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4be2:	b7c9                	j	4ba4 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4be4:	85d6                	mv	a1,s5
    4be6:	00003517          	auipc	a0,0x3
    4bea:	0fa50513          	addi	a0,a0,250 # 7ce0 <malloc+0x223e>
    4bee:	00001097          	auipc	ra,0x1
    4bf2:	df4080e7          	jalr	-524(ra) # 59e2 <printf>
    exit(1);
    4bf6:	4505                	li	a0,1
    4bf8:	00001097          	auipc	ra,0x1
    4bfc:	a6a080e7          	jalr	-1430(ra) # 5662 <exit>
      printf("%s: write bigfile failed\n", s);
    4c00:	85d6                	mv	a1,s5
    4c02:	00003517          	auipc	a0,0x3
    4c06:	0fe50513          	addi	a0,a0,254 # 7d00 <malloc+0x225e>
    4c0a:	00001097          	auipc	ra,0x1
    4c0e:	dd8080e7          	jalr	-552(ra) # 59e2 <printf>
      exit(1);
    4c12:	4505                	li	a0,1
    4c14:	00001097          	auipc	ra,0x1
    4c18:	a4e080e7          	jalr	-1458(ra) # 5662 <exit>
    printf("%s: cannot open bigfile\n", s);
    4c1c:	85d6                	mv	a1,s5
    4c1e:	00003517          	auipc	a0,0x3
    4c22:	10250513          	addi	a0,a0,258 # 7d20 <malloc+0x227e>
    4c26:	00001097          	auipc	ra,0x1
    4c2a:	dbc080e7          	jalr	-580(ra) # 59e2 <printf>
    exit(1);
    4c2e:	4505                	li	a0,1
    4c30:	00001097          	auipc	ra,0x1
    4c34:	a32080e7          	jalr	-1486(ra) # 5662 <exit>
      printf("%s: read bigfile failed\n", s);
    4c38:	85d6                	mv	a1,s5
    4c3a:	00003517          	auipc	a0,0x3
    4c3e:	10650513          	addi	a0,a0,262 # 7d40 <malloc+0x229e>
    4c42:	00001097          	auipc	ra,0x1
    4c46:	da0080e7          	jalr	-608(ra) # 59e2 <printf>
      exit(1);
    4c4a:	4505                	li	a0,1
    4c4c:	00001097          	auipc	ra,0x1
    4c50:	a16080e7          	jalr	-1514(ra) # 5662 <exit>
      printf("%s: short read bigfile\n", s);
    4c54:	85d6                	mv	a1,s5
    4c56:	00003517          	auipc	a0,0x3
    4c5a:	10a50513          	addi	a0,a0,266 # 7d60 <malloc+0x22be>
    4c5e:	00001097          	auipc	ra,0x1
    4c62:	d84080e7          	jalr	-636(ra) # 59e2 <printf>
      exit(1);
    4c66:	4505                	li	a0,1
    4c68:	00001097          	auipc	ra,0x1
    4c6c:	9fa080e7          	jalr	-1542(ra) # 5662 <exit>
      printf("%s: read bigfile wrong data\n", s);
    4c70:	85d6                	mv	a1,s5
    4c72:	00003517          	auipc	a0,0x3
    4c76:	10650513          	addi	a0,a0,262 # 7d78 <malloc+0x22d6>
    4c7a:	00001097          	auipc	ra,0x1
    4c7e:	d68080e7          	jalr	-664(ra) # 59e2 <printf>
      exit(1);
    4c82:	4505                	li	a0,1
    4c84:	00001097          	auipc	ra,0x1
    4c88:	9de080e7          	jalr	-1570(ra) # 5662 <exit>
  close(fd);
    4c8c:	8552                	mv	a0,s4
    4c8e:	00001097          	auipc	ra,0x1
    4c92:	9fc080e7          	jalr	-1540(ra) # 568a <close>
  if(total != N*SZ){
    4c96:	678d                	lui	a5,0x3
    4c98:	ee078793          	addi	a5,a5,-288 # 2ee0 <exitiputtest+0x1a>
    4c9c:	02f99363          	bne	s3,a5,4cc2 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4ca0:	00003517          	auipc	a0,0x3
    4ca4:	03050513          	addi	a0,a0,48 # 7cd0 <malloc+0x222e>
    4ca8:	00001097          	auipc	ra,0x1
    4cac:	a0a080e7          	jalr	-1526(ra) # 56b2 <unlink>
}
    4cb0:	70e2                	ld	ra,56(sp)
    4cb2:	7442                	ld	s0,48(sp)
    4cb4:	74a2                	ld	s1,40(sp)
    4cb6:	7902                	ld	s2,32(sp)
    4cb8:	69e2                	ld	s3,24(sp)
    4cba:	6a42                	ld	s4,16(sp)
    4cbc:	6aa2                	ld	s5,8(sp)
    4cbe:	6121                	addi	sp,sp,64
    4cc0:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4cc2:	85d6                	mv	a1,s5
    4cc4:	00003517          	auipc	a0,0x3
    4cc8:	0d450513          	addi	a0,a0,212 # 7d98 <malloc+0x22f6>
    4ccc:	00001097          	auipc	ra,0x1
    4cd0:	d16080e7          	jalr	-746(ra) # 59e2 <printf>
    exit(1);
    4cd4:	4505                	li	a0,1
    4cd6:	00001097          	auipc	ra,0x1
    4cda:	98c080e7          	jalr	-1652(ra) # 5662 <exit>

0000000000004cde <fsfull>:
{
    4cde:	7171                	addi	sp,sp,-176
    4ce0:	f506                	sd	ra,168(sp)
    4ce2:	f122                	sd	s0,160(sp)
    4ce4:	ed26                	sd	s1,152(sp)
    4ce6:	e94a                	sd	s2,144(sp)
    4ce8:	e54e                	sd	s3,136(sp)
    4cea:	e152                	sd	s4,128(sp)
    4cec:	fcd6                	sd	s5,120(sp)
    4cee:	f8da                	sd	s6,112(sp)
    4cf0:	f4de                	sd	s7,104(sp)
    4cf2:	f0e2                	sd	s8,96(sp)
    4cf4:	ece6                	sd	s9,88(sp)
    4cf6:	e8ea                	sd	s10,80(sp)
    4cf8:	e4ee                	sd	s11,72(sp)
    4cfa:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4cfc:	00003517          	auipc	a0,0x3
    4d00:	0bc50513          	addi	a0,a0,188 # 7db8 <malloc+0x2316>
    4d04:	00001097          	auipc	ra,0x1
    4d08:	cde080e7          	jalr	-802(ra) # 59e2 <printf>
  for(nfiles = 0; ; nfiles++){
    4d0c:	4481                	li	s1,0
    name[0] = 'f';
    4d0e:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4d12:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4d16:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4d1a:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4d1c:	00003c97          	auipc	s9,0x3
    4d20:	0acc8c93          	addi	s9,s9,172 # 7dc8 <malloc+0x2326>
    int total = 0;
    4d24:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4d26:	00007a17          	auipc	s4,0x7
    4d2a:	dd2a0a13          	addi	s4,s4,-558 # baf8 <buf>
    name[0] = 'f';
    4d2e:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4d32:	0384c7bb          	divw	a5,s1,s8
    4d36:	0307879b          	addiw	a5,a5,48
    4d3a:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4d3e:	0384e7bb          	remw	a5,s1,s8
    4d42:	0377c7bb          	divw	a5,a5,s7
    4d46:	0307879b          	addiw	a5,a5,48
    4d4a:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4d4e:	0374e7bb          	remw	a5,s1,s7
    4d52:	0367c7bb          	divw	a5,a5,s6
    4d56:	0307879b          	addiw	a5,a5,48
    4d5a:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4d5e:	0364e7bb          	remw	a5,s1,s6
    4d62:	0307879b          	addiw	a5,a5,48
    4d66:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4d6a:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4d6e:	f5040593          	addi	a1,s0,-176
    4d72:	8566                	mv	a0,s9
    4d74:	00001097          	auipc	ra,0x1
    4d78:	c6e080e7          	jalr	-914(ra) # 59e2 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4d7c:	20200593          	li	a1,514
    4d80:	f5040513          	addi	a0,s0,-176
    4d84:	00001097          	auipc	ra,0x1
    4d88:	91e080e7          	jalr	-1762(ra) # 56a2 <open>
    4d8c:	89aa                	mv	s3,a0
    if(fd < 0){
    4d8e:	0a055663          	bgez	a0,4e3a <fsfull+0x15c>
      printf("open %s failed\n", name);
    4d92:	f5040593          	addi	a1,s0,-176
    4d96:	00003517          	auipc	a0,0x3
    4d9a:	04250513          	addi	a0,a0,66 # 7dd8 <malloc+0x2336>
    4d9e:	00001097          	auipc	ra,0x1
    4da2:	c44080e7          	jalr	-956(ra) # 59e2 <printf>
  while(nfiles >= 0){
    4da6:	0604c363          	bltz	s1,4e0c <fsfull+0x12e>
    name[0] = 'f';
    4daa:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4dae:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4db2:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4db6:	4929                	li	s2,10
  while(nfiles >= 0){
    4db8:	5afd                	li	s5,-1
    name[0] = 'f';
    4dba:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4dbe:	0344c7bb          	divw	a5,s1,s4
    4dc2:	0307879b          	addiw	a5,a5,48
    4dc6:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4dca:	0344e7bb          	remw	a5,s1,s4
    4dce:	0337c7bb          	divw	a5,a5,s3
    4dd2:	0307879b          	addiw	a5,a5,48
    4dd6:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4dda:	0334e7bb          	remw	a5,s1,s3
    4dde:	0327c7bb          	divw	a5,a5,s2
    4de2:	0307879b          	addiw	a5,a5,48
    4de6:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4dea:	0324e7bb          	remw	a5,s1,s2
    4dee:	0307879b          	addiw	a5,a5,48
    4df2:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4df6:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4dfa:	f5040513          	addi	a0,s0,-176
    4dfe:	00001097          	auipc	ra,0x1
    4e02:	8b4080e7          	jalr	-1868(ra) # 56b2 <unlink>
    nfiles--;
    4e06:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4e08:	fb5499e3          	bne	s1,s5,4dba <fsfull+0xdc>
  printf("fsfull test finished\n");
    4e0c:	00003517          	auipc	a0,0x3
    4e10:	fec50513          	addi	a0,a0,-20 # 7df8 <malloc+0x2356>
    4e14:	00001097          	auipc	ra,0x1
    4e18:	bce080e7          	jalr	-1074(ra) # 59e2 <printf>
}
    4e1c:	70aa                	ld	ra,168(sp)
    4e1e:	740a                	ld	s0,160(sp)
    4e20:	64ea                	ld	s1,152(sp)
    4e22:	694a                	ld	s2,144(sp)
    4e24:	69aa                	ld	s3,136(sp)
    4e26:	6a0a                	ld	s4,128(sp)
    4e28:	7ae6                	ld	s5,120(sp)
    4e2a:	7b46                	ld	s6,112(sp)
    4e2c:	7ba6                	ld	s7,104(sp)
    4e2e:	7c06                	ld	s8,96(sp)
    4e30:	6ce6                	ld	s9,88(sp)
    4e32:	6d46                	ld	s10,80(sp)
    4e34:	6da6                	ld	s11,72(sp)
    4e36:	614d                	addi	sp,sp,176
    4e38:	8082                	ret
    int total = 0;
    4e3a:	896e                	mv	s2,s11
      if(cc < BSIZE)
    4e3c:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4e40:	40000613          	li	a2,1024
    4e44:	85d2                	mv	a1,s4
    4e46:	854e                	mv	a0,s3
    4e48:	00001097          	auipc	ra,0x1
    4e4c:	83a080e7          	jalr	-1990(ra) # 5682 <write>
      if(cc < BSIZE)
    4e50:	00aad563          	ble	a0,s5,4e5a <fsfull+0x17c>
      total += cc;
    4e54:	00a9093b          	addw	s2,s2,a0
    while(1){
    4e58:	b7e5                	j	4e40 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4e5a:	85ca                	mv	a1,s2
    4e5c:	00003517          	auipc	a0,0x3
    4e60:	f8c50513          	addi	a0,a0,-116 # 7de8 <malloc+0x2346>
    4e64:	00001097          	auipc	ra,0x1
    4e68:	b7e080e7          	jalr	-1154(ra) # 59e2 <printf>
    close(fd);
    4e6c:	854e                	mv	a0,s3
    4e6e:	00001097          	auipc	ra,0x1
    4e72:	81c080e7          	jalr	-2020(ra) # 568a <close>
    if(total == 0)
    4e76:	f20908e3          	beqz	s2,4da6 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4e7a:	2485                	addiw	s1,s1,1
    4e7c:	bd4d                	j	4d2e <fsfull+0x50>

0000000000004e7e <rand>:
{
    4e7e:	1141                	addi	sp,sp,-16
    4e80:	e422                	sd	s0,8(sp)
    4e82:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4e84:	00003717          	auipc	a4,0x3
    4e88:	44c70713          	addi	a4,a4,1100 # 82d0 <randstate>
    4e8c:	6308                	ld	a0,0(a4)
    4e8e:	001967b7          	lui	a5,0x196
    4e92:	60d78793          	addi	a5,a5,1549 # 19660d <_end+0x187b05>
    4e96:	02f50533          	mul	a0,a0,a5
    4e9a:	3c6ef7b7          	lui	a5,0x3c6ef
    4e9e:	35f78793          	addi	a5,a5,863 # 3c6ef35f <_end+0x3c6e0857>
    4ea2:	953e                	add	a0,a0,a5
    4ea4:	e308                	sd	a0,0(a4)
}
    4ea6:	2501                	sext.w	a0,a0
    4ea8:	6422                	ld	s0,8(sp)
    4eaa:	0141                	addi	sp,sp,16
    4eac:	8082                	ret

0000000000004eae <badwrite>:
{
    4eae:	7179                	addi	sp,sp,-48
    4eb0:	f406                	sd	ra,40(sp)
    4eb2:	f022                	sd	s0,32(sp)
    4eb4:	ec26                	sd	s1,24(sp)
    4eb6:	e84a                	sd	s2,16(sp)
    4eb8:	e44e                	sd	s3,8(sp)
    4eba:	e052                	sd	s4,0(sp)
    4ebc:	1800                	addi	s0,sp,48
  unlink("junk");
    4ebe:	00003517          	auipc	a0,0x3
    4ec2:	f5250513          	addi	a0,a0,-174 # 7e10 <malloc+0x236e>
    4ec6:	00000097          	auipc	ra,0x0
    4eca:	7ec080e7          	jalr	2028(ra) # 56b2 <unlink>
    4ece:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4ed2:	00003997          	auipc	s3,0x3
    4ed6:	f3e98993          	addi	s3,s3,-194 # 7e10 <malloc+0x236e>
    write(fd, (char*)0xffffffffffL, 1);
    4eda:	5a7d                	li	s4,-1
    4edc:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4ee0:	20100593          	li	a1,513
    4ee4:	854e                	mv	a0,s3
    4ee6:	00000097          	auipc	ra,0x0
    4eea:	7bc080e7          	jalr	1980(ra) # 56a2 <open>
    4eee:	84aa                	mv	s1,a0
    if(fd < 0){
    4ef0:	06054b63          	bltz	a0,4f66 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4ef4:	4605                	li	a2,1
    4ef6:	85d2                	mv	a1,s4
    4ef8:	00000097          	auipc	ra,0x0
    4efc:	78a080e7          	jalr	1930(ra) # 5682 <write>
    close(fd);
    4f00:	8526                	mv	a0,s1
    4f02:	00000097          	auipc	ra,0x0
    4f06:	788080e7          	jalr	1928(ra) # 568a <close>
    unlink("junk");
    4f0a:	854e                	mv	a0,s3
    4f0c:	00000097          	auipc	ra,0x0
    4f10:	7a6080e7          	jalr	1958(ra) # 56b2 <unlink>
  for(int i = 0; i < assumed_free; i++){
    4f14:	397d                	addiw	s2,s2,-1
    4f16:	fc0915e3          	bnez	s2,4ee0 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4f1a:	20100593          	li	a1,513
    4f1e:	00003517          	auipc	a0,0x3
    4f22:	ef250513          	addi	a0,a0,-270 # 7e10 <malloc+0x236e>
    4f26:	00000097          	auipc	ra,0x0
    4f2a:	77c080e7          	jalr	1916(ra) # 56a2 <open>
    4f2e:	84aa                	mv	s1,a0
  if(fd < 0){
    4f30:	04054863          	bltz	a0,4f80 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4f34:	4605                	li	a2,1
    4f36:	00001597          	auipc	a1,0x1
    4f3a:	0ca58593          	addi	a1,a1,202 # 6000 <malloc+0x55e>
    4f3e:	00000097          	auipc	ra,0x0
    4f42:	744080e7          	jalr	1860(ra) # 5682 <write>
    4f46:	4785                	li	a5,1
    4f48:	04f50963          	beq	a0,a5,4f9a <badwrite+0xec>
    printf("write failed\n");
    4f4c:	00003517          	auipc	a0,0x3
    4f50:	ee450513          	addi	a0,a0,-284 # 7e30 <malloc+0x238e>
    4f54:	00001097          	auipc	ra,0x1
    4f58:	a8e080e7          	jalr	-1394(ra) # 59e2 <printf>
    exit(1);
    4f5c:	4505                	li	a0,1
    4f5e:	00000097          	auipc	ra,0x0
    4f62:	704080e7          	jalr	1796(ra) # 5662 <exit>
      printf("open junk failed\n");
    4f66:	00003517          	auipc	a0,0x3
    4f6a:	eb250513          	addi	a0,a0,-334 # 7e18 <malloc+0x2376>
    4f6e:	00001097          	auipc	ra,0x1
    4f72:	a74080e7          	jalr	-1420(ra) # 59e2 <printf>
      exit(1);
    4f76:	4505                	li	a0,1
    4f78:	00000097          	auipc	ra,0x0
    4f7c:	6ea080e7          	jalr	1770(ra) # 5662 <exit>
    printf("open junk failed\n");
    4f80:	00003517          	auipc	a0,0x3
    4f84:	e9850513          	addi	a0,a0,-360 # 7e18 <malloc+0x2376>
    4f88:	00001097          	auipc	ra,0x1
    4f8c:	a5a080e7          	jalr	-1446(ra) # 59e2 <printf>
    exit(1);
    4f90:	4505                	li	a0,1
    4f92:	00000097          	auipc	ra,0x0
    4f96:	6d0080e7          	jalr	1744(ra) # 5662 <exit>
  close(fd);
    4f9a:	8526                	mv	a0,s1
    4f9c:	00000097          	auipc	ra,0x0
    4fa0:	6ee080e7          	jalr	1774(ra) # 568a <close>
  unlink("junk");
    4fa4:	00003517          	auipc	a0,0x3
    4fa8:	e6c50513          	addi	a0,a0,-404 # 7e10 <malloc+0x236e>
    4fac:	00000097          	auipc	ra,0x0
    4fb0:	706080e7          	jalr	1798(ra) # 56b2 <unlink>
  exit(0);
    4fb4:	4501                	li	a0,0
    4fb6:	00000097          	auipc	ra,0x0
    4fba:	6ac080e7          	jalr	1708(ra) # 5662 <exit>

0000000000004fbe <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4fbe:	7139                	addi	sp,sp,-64
    4fc0:	fc06                	sd	ra,56(sp)
    4fc2:	f822                	sd	s0,48(sp)
    4fc4:	f426                	sd	s1,40(sp)
    4fc6:	f04a                	sd	s2,32(sp)
    4fc8:	ec4e                	sd	s3,24(sp)
    4fca:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4fcc:	fc840513          	addi	a0,s0,-56
    4fd0:	00000097          	auipc	ra,0x0
    4fd4:	6a2080e7          	jalr	1698(ra) # 5672 <pipe>
    4fd8:	06054863          	bltz	a0,5048 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4fdc:	00000097          	auipc	ra,0x0
    4fe0:	67e080e7          	jalr	1662(ra) # 565a <fork>

  if(pid < 0){
    4fe4:	06054f63          	bltz	a0,5062 <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4fe8:	ed59                	bnez	a0,5086 <countfree+0xc8>
    close(fds[0]);
    4fea:	fc842503          	lw	a0,-56(s0)
    4fee:	00000097          	auipc	ra,0x0
    4ff2:	69c080e7          	jalr	1692(ra) # 568a <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4ff6:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4ff8:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4ffa:	00001917          	auipc	s2,0x1
    4ffe:	00690913          	addi	s2,s2,6 # 6000 <malloc+0x55e>
      uint64 a = (uint64) sbrk(4096);
    5002:	6505                	lui	a0,0x1
    5004:	00000097          	auipc	ra,0x0
    5008:	6e6080e7          	jalr	1766(ra) # 56ea <sbrk>
      if(a == 0xffffffffffffffff){
    500c:	06950863          	beq	a0,s1,507c <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    5010:	6785                	lui	a5,0x1
    5012:	97aa                	add	a5,a5,a0
    5014:	ff378fa3          	sb	s3,-1(a5) # fff <bigdir+0x89>
      if(write(fds[1], "x", 1) != 1){
    5018:	4605                	li	a2,1
    501a:	85ca                	mv	a1,s2
    501c:	fcc42503          	lw	a0,-52(s0)
    5020:	00000097          	auipc	ra,0x0
    5024:	662080e7          	jalr	1634(ra) # 5682 <write>
    5028:	4785                	li	a5,1
    502a:	fcf50ce3          	beq	a0,a5,5002 <countfree+0x44>
        printf("write() failed in countfree()\n");
    502e:	00003517          	auipc	a0,0x3
    5032:	e5250513          	addi	a0,a0,-430 # 7e80 <malloc+0x23de>
    5036:	00001097          	auipc	ra,0x1
    503a:	9ac080e7          	jalr	-1620(ra) # 59e2 <printf>
        exit(1);
    503e:	4505                	li	a0,1
    5040:	00000097          	auipc	ra,0x0
    5044:	622080e7          	jalr	1570(ra) # 5662 <exit>
    printf("pipe() failed in countfree()\n");
    5048:	00003517          	auipc	a0,0x3
    504c:	df850513          	addi	a0,a0,-520 # 7e40 <malloc+0x239e>
    5050:	00001097          	auipc	ra,0x1
    5054:	992080e7          	jalr	-1646(ra) # 59e2 <printf>
    exit(1);
    5058:	4505                	li	a0,1
    505a:	00000097          	auipc	ra,0x0
    505e:	608080e7          	jalr	1544(ra) # 5662 <exit>
    printf("fork failed in countfree()\n");
    5062:	00003517          	auipc	a0,0x3
    5066:	dfe50513          	addi	a0,a0,-514 # 7e60 <malloc+0x23be>
    506a:	00001097          	auipc	ra,0x1
    506e:	978080e7          	jalr	-1672(ra) # 59e2 <printf>
    exit(1);
    5072:	4505                	li	a0,1
    5074:	00000097          	auipc	ra,0x0
    5078:	5ee080e7          	jalr	1518(ra) # 5662 <exit>
      }
    }

    exit(0);
    507c:	4501                	li	a0,0
    507e:	00000097          	auipc	ra,0x0
    5082:	5e4080e7          	jalr	1508(ra) # 5662 <exit>
  }

  close(fds[1]);
    5086:	fcc42503          	lw	a0,-52(s0)
    508a:	00000097          	auipc	ra,0x0
    508e:	600080e7          	jalr	1536(ra) # 568a <close>

  int n = 0;
    5092:	4481                	li	s1,0
    5094:	a839                	j	50b2 <countfree+0xf4>
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    if(cc < 0){
      printf("read() failed in countfree()\n");
    5096:	00003517          	auipc	a0,0x3
    509a:	e0a50513          	addi	a0,a0,-502 # 7ea0 <malloc+0x23fe>
    509e:	00001097          	auipc	ra,0x1
    50a2:	944080e7          	jalr	-1724(ra) # 59e2 <printf>
      exit(1);
    50a6:	4505                	li	a0,1
    50a8:	00000097          	auipc	ra,0x0
    50ac:	5ba080e7          	jalr	1466(ra) # 5662 <exit>
    }
    if(cc == 0)
      break;
    n += 1;
    50b0:	2485                	addiw	s1,s1,1
    int cc = read(fds[0], &c, 1);
    50b2:	4605                	li	a2,1
    50b4:	fc740593          	addi	a1,s0,-57
    50b8:	fc842503          	lw	a0,-56(s0)
    50bc:	00000097          	auipc	ra,0x0
    50c0:	5be080e7          	jalr	1470(ra) # 567a <read>
    if(cc < 0){
    50c4:	fc0549e3          	bltz	a0,5096 <countfree+0xd8>
    if(cc == 0)
    50c8:	f565                	bnez	a0,50b0 <countfree+0xf2>
  }

  close(fds[0]);
    50ca:	fc842503          	lw	a0,-56(s0)
    50ce:	00000097          	auipc	ra,0x0
    50d2:	5bc080e7          	jalr	1468(ra) # 568a <close>
  wait((int*)0);
    50d6:	4501                	li	a0,0
    50d8:	00000097          	auipc	ra,0x0
    50dc:	592080e7          	jalr	1426(ra) # 566a <wait>
  
  return n;
}
    50e0:	8526                	mv	a0,s1
    50e2:	70e2                	ld	ra,56(sp)
    50e4:	7442                	ld	s0,48(sp)
    50e6:	74a2                	ld	s1,40(sp)
    50e8:	7902                	ld	s2,32(sp)
    50ea:	69e2                	ld	s3,24(sp)
    50ec:	6121                	addi	sp,sp,64
    50ee:	8082                	ret

00000000000050f0 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    50f0:	7179                	addi	sp,sp,-48
    50f2:	f406                	sd	ra,40(sp)
    50f4:	f022                	sd	s0,32(sp)
    50f6:	ec26                	sd	s1,24(sp)
    50f8:	e84a                	sd	s2,16(sp)
    50fa:	1800                	addi	s0,sp,48
    50fc:	84aa                	mv	s1,a0
    50fe:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    5100:	00003517          	auipc	a0,0x3
    5104:	dc050513          	addi	a0,a0,-576 # 7ec0 <malloc+0x241e>
    5108:	00001097          	auipc	ra,0x1
    510c:	8da080e7          	jalr	-1830(ra) # 59e2 <printf>
  if((pid = fork()) < 0) {
    5110:	00000097          	auipc	ra,0x0
    5114:	54a080e7          	jalr	1354(ra) # 565a <fork>
    5118:	02054e63          	bltz	a0,5154 <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    511c:	c929                	beqz	a0,516e <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    511e:	fdc40513          	addi	a0,s0,-36
    5122:	00000097          	auipc	ra,0x0
    5126:	548080e7          	jalr	1352(ra) # 566a <wait>
    if(xstatus != 0) 
    512a:	fdc42783          	lw	a5,-36(s0)
    512e:	c7b9                	beqz	a5,517c <run+0x8c>
      printf("FAILED\n");
    5130:	00003517          	auipc	a0,0x3
    5134:	db850513          	addi	a0,a0,-584 # 7ee8 <malloc+0x2446>
    5138:	00001097          	auipc	ra,0x1
    513c:	8aa080e7          	jalr	-1878(ra) # 59e2 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5140:	fdc42503          	lw	a0,-36(s0)
  }
}
    5144:	00153513          	seqz	a0,a0
    5148:	70a2                	ld	ra,40(sp)
    514a:	7402                	ld	s0,32(sp)
    514c:	64e2                	ld	s1,24(sp)
    514e:	6942                	ld	s2,16(sp)
    5150:	6145                	addi	sp,sp,48
    5152:	8082                	ret
    printf("runtest: fork error\n");
    5154:	00003517          	auipc	a0,0x3
    5158:	d7c50513          	addi	a0,a0,-644 # 7ed0 <malloc+0x242e>
    515c:	00001097          	auipc	ra,0x1
    5160:	886080e7          	jalr	-1914(ra) # 59e2 <printf>
    exit(1);
    5164:	4505                	li	a0,1
    5166:	00000097          	auipc	ra,0x0
    516a:	4fc080e7          	jalr	1276(ra) # 5662 <exit>
    f(s);
    516e:	854a                	mv	a0,s2
    5170:	9482                	jalr	s1
    exit(0);
    5172:	4501                	li	a0,0
    5174:	00000097          	auipc	ra,0x0
    5178:	4ee080e7          	jalr	1262(ra) # 5662 <exit>
      printf("OK\n");
    517c:	00003517          	auipc	a0,0x3
    5180:	d7450513          	addi	a0,a0,-652 # 7ef0 <malloc+0x244e>
    5184:	00001097          	auipc	ra,0x1
    5188:	85e080e7          	jalr	-1954(ra) # 59e2 <printf>
    518c:	bf55                	j	5140 <run+0x50>

000000000000518e <main>:

int
main(int argc, char *argv[])
{
    518e:	c1010113          	addi	sp,sp,-1008
    5192:	3e113423          	sd	ra,1000(sp)
    5196:	3e813023          	sd	s0,992(sp)
    519a:	3c913c23          	sd	s1,984(sp)
    519e:	3d213823          	sd	s2,976(sp)
    51a2:	3d313423          	sd	s3,968(sp)
    51a6:	3d413023          	sd	s4,960(sp)
    51aa:	3b513c23          	sd	s5,952(sp)
    51ae:	3b613823          	sd	s6,944(sp)
    51b2:	1f80                	addi	s0,sp,1008
    51b4:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    51b6:	4789                	li	a5,2
    51b8:	08f50c63          	beq	a0,a5,5250 <main+0xc2>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    51bc:	4785                	li	a5,1
    51be:	0ca7c763          	blt	a5,a0,528c <main+0xfe>
  char *justone = 0;
    51c2:	4981                	li	s3,0
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    51c4:	00001797          	auipc	a5,0x1
    51c8:	9e478793          	addi	a5,a5,-1564 # 5ba8 <malloc+0x106>
    51cc:	c1040713          	addi	a4,s0,-1008
    51d0:	00001817          	auipc	a6,0x1
    51d4:	d7880813          	addi	a6,a6,-648 # 5f48 <malloc+0x4a6>
    51d8:	6388                	ld	a0,0(a5)
    51da:	678c                	ld	a1,8(a5)
    51dc:	6b90                	ld	a2,16(a5)
    51de:	6f94                	ld	a3,24(a5)
    51e0:	e308                	sd	a0,0(a4)
    51e2:	e70c                	sd	a1,8(a4)
    51e4:	eb10                	sd	a2,16(a4)
    51e6:	ef14                	sd	a3,24(a4)
    51e8:	02078793          	addi	a5,a5,32
    51ec:	02070713          	addi	a4,a4,32
    51f0:	ff0794e3          	bne	a5,a6,51d8 <main+0x4a>
    51f4:	6394                	ld	a3,0(a5)
    51f6:	679c                	ld	a5,8(a5)
    51f8:	e314                	sd	a3,0(a4)
    51fa:	e71c                	sd	a5,8(a4)
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    51fc:	00003517          	auipc	a0,0x3
    5200:	dac50513          	addi	a0,a0,-596 # 7fa8 <malloc+0x2506>
    5204:	00000097          	auipc	ra,0x0
    5208:	7de080e7          	jalr	2014(ra) # 59e2 <printf>
  int free0 = countfree();
    520c:	00000097          	auipc	ra,0x0
    5210:	db2080e7          	jalr	-590(ra) # 4fbe <countfree>
    5214:	8b2a                	mv	s6,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    5216:	c1843903          	ld	s2,-1000(s0)
    521a:	c1040493          	addi	s1,s0,-1008
  int fail = 0;
    521e:	4a01                	li	s4,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    5220:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    5222:	0a091a63          	bnez	s2,52d6 <main+0x148>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    5226:	00000097          	auipc	ra,0x0
    522a:	d98080e7          	jalr	-616(ra) # 4fbe <countfree>
    522e:	85aa                	mv	a1,a0
    5230:	0f655463          	ble	s6,a0,5318 <main+0x18a>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5234:	865a                	mv	a2,s6
    5236:	00003517          	auipc	a0,0x3
    523a:	d2a50513          	addi	a0,a0,-726 # 7f60 <malloc+0x24be>
    523e:	00000097          	auipc	ra,0x0
    5242:	7a4080e7          	jalr	1956(ra) # 59e2 <printf>
    exit(1);
    5246:	4505                	li	a0,1
    5248:	00000097          	auipc	ra,0x0
    524c:	41a080e7          	jalr	1050(ra) # 5662 <exit>
    5250:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5252:	00003597          	auipc	a1,0x3
    5256:	ca658593          	addi	a1,a1,-858 # 7ef8 <malloc+0x2456>
    525a:	6488                	ld	a0,8(s1)
    525c:	00000097          	auipc	ra,0x0
    5260:	192080e7          	jalr	402(ra) # 53ee <strcmp>
    5264:	10050863          	beqz	a0,5374 <main+0x1e6>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5268:	00003597          	auipc	a1,0x3
    526c:	d7858593          	addi	a1,a1,-648 # 7fe0 <malloc+0x253e>
    5270:	6488                	ld	a0,8(s1)
    5272:	00000097          	auipc	ra,0x0
    5276:	17c080e7          	jalr	380(ra) # 53ee <strcmp>
    527a:	cd75                	beqz	a0,5376 <main+0x1e8>
  } else if(argc == 2 && argv[1][0] != '-'){
    527c:	0084b983          	ld	s3,8(s1)
    5280:	0009c703          	lbu	a4,0(s3)
    5284:	02d00793          	li	a5,45
    5288:	f2f71ee3          	bne	a4,a5,51c4 <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    528c:	00003517          	auipc	a0,0x3
    5290:	c7450513          	addi	a0,a0,-908 # 7f00 <malloc+0x245e>
    5294:	00000097          	auipc	ra,0x0
    5298:	74e080e7          	jalr	1870(ra) # 59e2 <printf>
    exit(1);
    529c:	4505                	li	a0,1
    529e:	00000097          	auipc	ra,0x0
    52a2:	3c4080e7          	jalr	964(ra) # 5662 <exit>
          exit(1);
    52a6:	4505                	li	a0,1
    52a8:	00000097          	auipc	ra,0x0
    52ac:	3ba080e7          	jalr	954(ra) # 5662 <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    52b0:	40a905bb          	subw	a1,s2,a0
    52b4:	855a                	mv	a0,s6
    52b6:	00000097          	auipc	ra,0x0
    52ba:	72c080e7          	jalr	1836(ra) # 59e2 <printf>
        if(continuous != 2)
    52be:	09498763          	beq	s3,s4,534c <main+0x1be>
          exit(1);
    52c2:	4505                	li	a0,1
    52c4:	00000097          	auipc	ra,0x0
    52c8:	39e080e7          	jalr	926(ra) # 5662 <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    52cc:	04c1                	addi	s1,s1,16
    52ce:	0084b903          	ld	s2,8(s1)
    52d2:	02090463          	beqz	s2,52fa <main+0x16c>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    52d6:	00098963          	beqz	s3,52e8 <main+0x15a>
    52da:	85ce                	mv	a1,s3
    52dc:	854a                	mv	a0,s2
    52de:	00000097          	auipc	ra,0x0
    52e2:	110080e7          	jalr	272(ra) # 53ee <strcmp>
    52e6:	f17d                	bnez	a0,52cc <main+0x13e>
      if(!run(t->f, t->s))
    52e8:	85ca                	mv	a1,s2
    52ea:	6088                	ld	a0,0(s1)
    52ec:	00000097          	auipc	ra,0x0
    52f0:	e04080e7          	jalr	-508(ra) # 50f0 <run>
    52f4:	fd61                	bnez	a0,52cc <main+0x13e>
        fail = 1;
    52f6:	8a56                	mv	s4,s5
    52f8:	bfd1                	j	52cc <main+0x13e>
  if(fail){
    52fa:	f20a06e3          	beqz	s4,5226 <main+0x98>
    printf("SOME TESTS FAILED\n");
    52fe:	00003517          	auipc	a0,0x3
    5302:	c4a50513          	addi	a0,a0,-950 # 7f48 <malloc+0x24a6>
    5306:	00000097          	auipc	ra,0x0
    530a:	6dc080e7          	jalr	1756(ra) # 59e2 <printf>
    exit(1);
    530e:	4505                	li	a0,1
    5310:	00000097          	auipc	ra,0x0
    5314:	352080e7          	jalr	850(ra) # 5662 <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    5318:	00003517          	auipc	a0,0x3
    531c:	c7850513          	addi	a0,a0,-904 # 7f90 <malloc+0x24ee>
    5320:	00000097          	auipc	ra,0x0
    5324:	6c2080e7          	jalr	1730(ra) # 59e2 <printf>
    exit(0);
    5328:	4501                	li	a0,0
    532a:	00000097          	auipc	ra,0x0
    532e:	338080e7          	jalr	824(ra) # 5662 <exit>
        printf("SOME TESTS FAILED\n");
    5332:	8556                	mv	a0,s5
    5334:	00000097          	auipc	ra,0x0
    5338:	6ae080e7          	jalr	1710(ra) # 59e2 <printf>
        if(continuous != 2)
    533c:	f74995e3          	bne	s3,s4,52a6 <main+0x118>
      int free1 = countfree();
    5340:	00000097          	auipc	ra,0x0
    5344:	c7e080e7          	jalr	-898(ra) # 4fbe <countfree>
      if(free1 < free0){
    5348:	f72544e3          	blt	a0,s2,52b0 <main+0x122>
      int free0 = countfree();
    534c:	00000097          	auipc	ra,0x0
    5350:	c72080e7          	jalr	-910(ra) # 4fbe <countfree>
    5354:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5356:	c1843583          	ld	a1,-1000(s0)
    535a:	d1fd                	beqz	a1,5340 <main+0x1b2>
    535c:	c1040493          	addi	s1,s0,-1008
        if(!run(t->f, t->s)){
    5360:	6088                	ld	a0,0(s1)
    5362:	00000097          	auipc	ra,0x0
    5366:	d8e080e7          	jalr	-626(ra) # 50f0 <run>
    536a:	d561                	beqz	a0,5332 <main+0x1a4>
      for (struct test *t = tests; t->s != 0; t++) {
    536c:	04c1                	addi	s1,s1,16
    536e:	648c                	ld	a1,8(s1)
    5370:	f9e5                	bnez	a1,5360 <main+0x1d2>
    5372:	b7f9                	j	5340 <main+0x1b2>
    continuous = 1;
    5374:	4985                	li	s3,1
  } tests[] = {
    5376:	00001797          	auipc	a5,0x1
    537a:	83278793          	addi	a5,a5,-1998 # 5ba8 <malloc+0x106>
    537e:	c1040713          	addi	a4,s0,-1008
    5382:	00001817          	auipc	a6,0x1
    5386:	bc680813          	addi	a6,a6,-1082 # 5f48 <malloc+0x4a6>
    538a:	6388                	ld	a0,0(a5)
    538c:	678c                	ld	a1,8(a5)
    538e:	6b90                	ld	a2,16(a5)
    5390:	6f94                	ld	a3,24(a5)
    5392:	e308                	sd	a0,0(a4)
    5394:	e70c                	sd	a1,8(a4)
    5396:	eb10                	sd	a2,16(a4)
    5398:	ef14                	sd	a3,24(a4)
    539a:	02078793          	addi	a5,a5,32
    539e:	02070713          	addi	a4,a4,32
    53a2:	ff0794e3          	bne	a5,a6,538a <main+0x1fc>
    53a6:	6394                	ld	a3,0(a5)
    53a8:	679c                	ld	a5,8(a5)
    53aa:	e314                	sd	a3,0(a4)
    53ac:	e71c                	sd	a5,8(a4)
    printf("continuous usertests starting\n");
    53ae:	00003517          	auipc	a0,0x3
    53b2:	c1250513          	addi	a0,a0,-1006 # 7fc0 <malloc+0x251e>
    53b6:	00000097          	auipc	ra,0x0
    53ba:	62c080e7          	jalr	1580(ra) # 59e2 <printf>
        printf("SOME TESTS FAILED\n");
    53be:	00003a97          	auipc	s5,0x3
    53c2:	b8aa8a93          	addi	s5,s5,-1142 # 7f48 <malloc+0x24a6>
        if(continuous != 2)
    53c6:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    53c8:	00003b17          	auipc	s6,0x3
    53cc:	b60b0b13          	addi	s6,s6,-1184 # 7f28 <malloc+0x2486>
    53d0:	bfb5                	j	534c <main+0x1be>

00000000000053d2 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    53d2:	1141                	addi	sp,sp,-16
    53d4:	e422                	sd	s0,8(sp)
    53d6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    53d8:	87aa                	mv	a5,a0
    53da:	0585                	addi	a1,a1,1
    53dc:	0785                	addi	a5,a5,1
    53de:	fff5c703          	lbu	a4,-1(a1)
    53e2:	fee78fa3          	sb	a4,-1(a5)
    53e6:	fb75                	bnez	a4,53da <strcpy+0x8>
    ;
  return os;
}
    53e8:	6422                	ld	s0,8(sp)
    53ea:	0141                	addi	sp,sp,16
    53ec:	8082                	ret

00000000000053ee <strcmp>:

int
strcmp(const char *p, const char *q)
{
    53ee:	1141                	addi	sp,sp,-16
    53f0:	e422                	sd	s0,8(sp)
    53f2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    53f4:	00054783          	lbu	a5,0(a0)
    53f8:	cf91                	beqz	a5,5414 <strcmp+0x26>
    53fa:	0005c703          	lbu	a4,0(a1)
    53fe:	00f71b63          	bne	a4,a5,5414 <strcmp+0x26>
    p++, q++;
    5402:	0505                	addi	a0,a0,1
    5404:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    5406:	00054783          	lbu	a5,0(a0)
    540a:	c789                	beqz	a5,5414 <strcmp+0x26>
    540c:	0005c703          	lbu	a4,0(a1)
    5410:	fef709e3          	beq	a4,a5,5402 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
    5414:	0005c503          	lbu	a0,0(a1)
}
    5418:	40a7853b          	subw	a0,a5,a0
    541c:	6422                	ld	s0,8(sp)
    541e:	0141                	addi	sp,sp,16
    5420:	8082                	ret

0000000000005422 <strlen>:

uint
strlen(const char *s)
{
    5422:	1141                	addi	sp,sp,-16
    5424:	e422                	sd	s0,8(sp)
    5426:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5428:	00054783          	lbu	a5,0(a0)
    542c:	cf91                	beqz	a5,5448 <strlen+0x26>
    542e:	0505                	addi	a0,a0,1
    5430:	87aa                	mv	a5,a0
    5432:	4685                	li	a3,1
    5434:	9e89                	subw	a3,a3,a0
    5436:	00f6853b          	addw	a0,a3,a5
    543a:	0785                	addi	a5,a5,1
    543c:	fff7c703          	lbu	a4,-1(a5)
    5440:	fb7d                	bnez	a4,5436 <strlen+0x14>
    ;
  return n;
}
    5442:	6422                	ld	s0,8(sp)
    5444:	0141                	addi	sp,sp,16
    5446:	8082                	ret
  for(n = 0; s[n]; n++)
    5448:	4501                	li	a0,0
    544a:	bfe5                	j	5442 <strlen+0x20>

000000000000544c <memset>:

void*
memset(void *dst, int c, uint n)
{
    544c:	1141                	addi	sp,sp,-16
    544e:	e422                	sd	s0,8(sp)
    5450:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    5452:	ce09                	beqz	a2,546c <memset+0x20>
    5454:	87aa                	mv	a5,a0
    5456:	fff6071b          	addiw	a4,a2,-1
    545a:	1702                	slli	a4,a4,0x20
    545c:	9301                	srli	a4,a4,0x20
    545e:	0705                	addi	a4,a4,1
    5460:	972a                	add	a4,a4,a0
    cdst[i] = c;
    5462:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5466:	0785                	addi	a5,a5,1
    5468:	fee79de3          	bne	a5,a4,5462 <memset+0x16>
  }
  return dst;
}
    546c:	6422                	ld	s0,8(sp)
    546e:	0141                	addi	sp,sp,16
    5470:	8082                	ret

0000000000005472 <strchr>:

char*
strchr(const char *s, char c)
{
    5472:	1141                	addi	sp,sp,-16
    5474:	e422                	sd	s0,8(sp)
    5476:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5478:	00054783          	lbu	a5,0(a0)
    547c:	cf91                	beqz	a5,5498 <strchr+0x26>
    if(*s == c)
    547e:	00f58a63          	beq	a1,a5,5492 <strchr+0x20>
  for(; *s; s++)
    5482:	0505                	addi	a0,a0,1
    5484:	00054783          	lbu	a5,0(a0)
    5488:	c781                	beqz	a5,5490 <strchr+0x1e>
    if(*s == c)
    548a:	feb79ce3          	bne	a5,a1,5482 <strchr+0x10>
    548e:	a011                	j	5492 <strchr+0x20>
      return (char*)s;
  return 0;
    5490:	4501                	li	a0,0
}
    5492:	6422                	ld	s0,8(sp)
    5494:	0141                	addi	sp,sp,16
    5496:	8082                	ret
  return 0;
    5498:	4501                	li	a0,0
    549a:	bfe5                	j	5492 <strchr+0x20>

000000000000549c <gets>:

char*
gets(char *buf, int max)
{
    549c:	711d                	addi	sp,sp,-96
    549e:	ec86                	sd	ra,88(sp)
    54a0:	e8a2                	sd	s0,80(sp)
    54a2:	e4a6                	sd	s1,72(sp)
    54a4:	e0ca                	sd	s2,64(sp)
    54a6:	fc4e                	sd	s3,56(sp)
    54a8:	f852                	sd	s4,48(sp)
    54aa:	f456                	sd	s5,40(sp)
    54ac:	f05a                	sd	s6,32(sp)
    54ae:	ec5e                	sd	s7,24(sp)
    54b0:	1080                	addi	s0,sp,96
    54b2:	8baa                	mv	s7,a0
    54b4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    54b6:	892a                	mv	s2,a0
    54b8:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    54ba:	4aa9                	li	s5,10
    54bc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    54be:	0019849b          	addiw	s1,s3,1
    54c2:	0344d863          	ble	s4,s1,54f2 <gets+0x56>
    cc = read(0, &c, 1);
    54c6:	4605                	li	a2,1
    54c8:	faf40593          	addi	a1,s0,-81
    54cc:	4501                	li	a0,0
    54ce:	00000097          	auipc	ra,0x0
    54d2:	1ac080e7          	jalr	428(ra) # 567a <read>
    if(cc < 1)
    54d6:	00a05e63          	blez	a0,54f2 <gets+0x56>
    buf[i++] = c;
    54da:	faf44783          	lbu	a5,-81(s0)
    54de:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    54e2:	01578763          	beq	a5,s5,54f0 <gets+0x54>
    54e6:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
    54e8:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
    54ea:	fd679ae3          	bne	a5,s6,54be <gets+0x22>
    54ee:	a011                	j	54f2 <gets+0x56>
  for(i=0; i+1 < max; ){
    54f0:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    54f2:	99de                	add	s3,s3,s7
    54f4:	00098023          	sb	zero,0(s3)
  return buf;
}
    54f8:	855e                	mv	a0,s7
    54fa:	60e6                	ld	ra,88(sp)
    54fc:	6446                	ld	s0,80(sp)
    54fe:	64a6                	ld	s1,72(sp)
    5500:	6906                	ld	s2,64(sp)
    5502:	79e2                	ld	s3,56(sp)
    5504:	7a42                	ld	s4,48(sp)
    5506:	7aa2                	ld	s5,40(sp)
    5508:	7b02                	ld	s6,32(sp)
    550a:	6be2                	ld	s7,24(sp)
    550c:	6125                	addi	sp,sp,96
    550e:	8082                	ret

0000000000005510 <stat>:

int
stat(const char *n, struct stat *st)
{
    5510:	1101                	addi	sp,sp,-32
    5512:	ec06                	sd	ra,24(sp)
    5514:	e822                	sd	s0,16(sp)
    5516:	e426                	sd	s1,8(sp)
    5518:	e04a                	sd	s2,0(sp)
    551a:	1000                	addi	s0,sp,32
    551c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    551e:	4581                	li	a1,0
    5520:	00000097          	auipc	ra,0x0
    5524:	182080e7          	jalr	386(ra) # 56a2 <open>
  if(fd < 0)
    5528:	02054563          	bltz	a0,5552 <stat+0x42>
    552c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    552e:	85ca                	mv	a1,s2
    5530:	00000097          	auipc	ra,0x0
    5534:	18a080e7          	jalr	394(ra) # 56ba <fstat>
    5538:	892a                	mv	s2,a0
  close(fd);
    553a:	8526                	mv	a0,s1
    553c:	00000097          	auipc	ra,0x0
    5540:	14e080e7          	jalr	334(ra) # 568a <close>
  return r;
}
    5544:	854a                	mv	a0,s2
    5546:	60e2                	ld	ra,24(sp)
    5548:	6442                	ld	s0,16(sp)
    554a:	64a2                	ld	s1,8(sp)
    554c:	6902                	ld	s2,0(sp)
    554e:	6105                	addi	sp,sp,32
    5550:	8082                	ret
    return -1;
    5552:	597d                	li	s2,-1
    5554:	bfc5                	j	5544 <stat+0x34>

0000000000005556 <atoi>:

int
atoi(const char *s)
{
    5556:	1141                	addi	sp,sp,-16
    5558:	e422                	sd	s0,8(sp)
    555a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    555c:	00054683          	lbu	a3,0(a0)
    5560:	fd06879b          	addiw	a5,a3,-48
    5564:	0ff7f793          	andi	a5,a5,255
    5568:	4725                	li	a4,9
    556a:	02f76963          	bltu	a4,a5,559c <atoi+0x46>
    556e:	862a                	mv	a2,a0
  n = 0;
    5570:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    5572:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    5574:	0605                	addi	a2,a2,1
    5576:	0025179b          	slliw	a5,a0,0x2
    557a:	9fa9                	addw	a5,a5,a0
    557c:	0017979b          	slliw	a5,a5,0x1
    5580:	9fb5                	addw	a5,a5,a3
    5582:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5586:	00064683          	lbu	a3,0(a2) # 3000 <dirtest+0x52>
    558a:	fd06871b          	addiw	a4,a3,-48
    558e:	0ff77713          	andi	a4,a4,255
    5592:	fee5f1e3          	bleu	a4,a1,5574 <atoi+0x1e>
  return n;
}
    5596:	6422                	ld	s0,8(sp)
    5598:	0141                	addi	sp,sp,16
    559a:	8082                	ret
  n = 0;
    559c:	4501                	li	a0,0
    559e:	bfe5                	j	5596 <atoi+0x40>

00000000000055a0 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    55a0:	1141                	addi	sp,sp,-16
    55a2:	e422                	sd	s0,8(sp)
    55a4:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    55a6:	02b57663          	bleu	a1,a0,55d2 <memmove+0x32>
    while(n-- > 0)
    55aa:	02c05163          	blez	a2,55cc <memmove+0x2c>
    55ae:	fff6079b          	addiw	a5,a2,-1
    55b2:	1782                	slli	a5,a5,0x20
    55b4:	9381                	srli	a5,a5,0x20
    55b6:	0785                	addi	a5,a5,1
    55b8:	97aa                	add	a5,a5,a0
  dst = vdst;
    55ba:	872a                	mv	a4,a0
      *dst++ = *src++;
    55bc:	0585                	addi	a1,a1,1
    55be:	0705                	addi	a4,a4,1
    55c0:	fff5c683          	lbu	a3,-1(a1)
    55c4:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    55c8:	fee79ae3          	bne	a5,a4,55bc <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    55cc:	6422                	ld	s0,8(sp)
    55ce:	0141                	addi	sp,sp,16
    55d0:	8082                	ret
    dst += n;
    55d2:	00c50733          	add	a4,a0,a2
    src += n;
    55d6:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    55d8:	fec05ae3          	blez	a2,55cc <memmove+0x2c>
    55dc:	fff6079b          	addiw	a5,a2,-1
    55e0:	1782                	slli	a5,a5,0x20
    55e2:	9381                	srli	a5,a5,0x20
    55e4:	fff7c793          	not	a5,a5
    55e8:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    55ea:	15fd                	addi	a1,a1,-1
    55ec:	177d                	addi	a4,a4,-1
    55ee:	0005c683          	lbu	a3,0(a1)
    55f2:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    55f6:	fef71ae3          	bne	a4,a5,55ea <memmove+0x4a>
    55fa:	bfc9                	j	55cc <memmove+0x2c>

00000000000055fc <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    55fc:	1141                	addi	sp,sp,-16
    55fe:	e422                	sd	s0,8(sp)
    5600:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    5602:	ce15                	beqz	a2,563e <memcmp+0x42>
    5604:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
    5608:	00054783          	lbu	a5,0(a0)
    560c:	0005c703          	lbu	a4,0(a1)
    5610:	02e79063          	bne	a5,a4,5630 <memcmp+0x34>
    5614:	1682                	slli	a3,a3,0x20
    5616:	9281                	srli	a3,a3,0x20
    5618:	0685                	addi	a3,a3,1
    561a:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
    561c:	0505                	addi	a0,a0,1
    p2++;
    561e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    5620:	00d50d63          	beq	a0,a3,563a <memcmp+0x3e>
    if (*p1 != *p2) {
    5624:	00054783          	lbu	a5,0(a0)
    5628:	0005c703          	lbu	a4,0(a1)
    562c:	fee788e3          	beq	a5,a4,561c <memcmp+0x20>
      return *p1 - *p2;
    5630:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
    5634:	6422                	ld	s0,8(sp)
    5636:	0141                	addi	sp,sp,16
    5638:	8082                	ret
  return 0;
    563a:	4501                	li	a0,0
    563c:	bfe5                	j	5634 <memcmp+0x38>
    563e:	4501                	li	a0,0
    5640:	bfd5                	j	5634 <memcmp+0x38>

0000000000005642 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    5642:	1141                	addi	sp,sp,-16
    5644:	e406                	sd	ra,8(sp)
    5646:	e022                	sd	s0,0(sp)
    5648:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    564a:	00000097          	auipc	ra,0x0
    564e:	f56080e7          	jalr	-170(ra) # 55a0 <memmove>
}
    5652:	60a2                	ld	ra,8(sp)
    5654:	6402                	ld	s0,0(sp)
    5656:	0141                	addi	sp,sp,16
    5658:	8082                	ret

000000000000565a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    565a:	4885                	li	a7,1
 ecall
    565c:	00000073          	ecall
 ret
    5660:	8082                	ret

0000000000005662 <exit>:
.global exit
exit:
 li a7, SYS_exit
    5662:	4889                	li	a7,2
 ecall
    5664:	00000073          	ecall
 ret
    5668:	8082                	ret

000000000000566a <wait>:
.global wait
wait:
 li a7, SYS_wait
    566a:	488d                	li	a7,3
 ecall
    566c:	00000073          	ecall
 ret
    5670:	8082                	ret

0000000000005672 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    5672:	4891                	li	a7,4
 ecall
    5674:	00000073          	ecall
 ret
    5678:	8082                	ret

000000000000567a <read>:
.global read
read:
 li a7, SYS_read
    567a:	4895                	li	a7,5
 ecall
    567c:	00000073          	ecall
 ret
    5680:	8082                	ret

0000000000005682 <write>:
.global write
write:
 li a7, SYS_write
    5682:	48c1                	li	a7,16
 ecall
    5684:	00000073          	ecall
 ret
    5688:	8082                	ret

000000000000568a <close>:
.global close
close:
 li a7, SYS_close
    568a:	48d5                	li	a7,21
 ecall
    568c:	00000073          	ecall
 ret
    5690:	8082                	ret

0000000000005692 <kill>:
.global kill
kill:
 li a7, SYS_kill
    5692:	4899                	li	a7,6
 ecall
    5694:	00000073          	ecall
 ret
    5698:	8082                	ret

000000000000569a <exec>:
.global exec
exec:
 li a7, SYS_exec
    569a:	489d                	li	a7,7
 ecall
    569c:	00000073          	ecall
 ret
    56a0:	8082                	ret

00000000000056a2 <open>:
.global open
open:
 li a7, SYS_open
    56a2:	48bd                	li	a7,15
 ecall
    56a4:	00000073          	ecall
 ret
    56a8:	8082                	ret

00000000000056aa <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    56aa:	48c5                	li	a7,17
 ecall
    56ac:	00000073          	ecall
 ret
    56b0:	8082                	ret

00000000000056b2 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    56b2:	48c9                	li	a7,18
 ecall
    56b4:	00000073          	ecall
 ret
    56b8:	8082                	ret

00000000000056ba <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    56ba:	48a1                	li	a7,8
 ecall
    56bc:	00000073          	ecall
 ret
    56c0:	8082                	ret

00000000000056c2 <link>:
.global link
link:
 li a7, SYS_link
    56c2:	48cd                	li	a7,19
 ecall
    56c4:	00000073          	ecall
 ret
    56c8:	8082                	ret

00000000000056ca <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    56ca:	48d1                	li	a7,20
 ecall
    56cc:	00000073          	ecall
 ret
    56d0:	8082                	ret

00000000000056d2 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    56d2:	48a5                	li	a7,9
 ecall
    56d4:	00000073          	ecall
 ret
    56d8:	8082                	ret

00000000000056da <dup>:
.global dup
dup:
 li a7, SYS_dup
    56da:	48a9                	li	a7,10
 ecall
    56dc:	00000073          	ecall
 ret
    56e0:	8082                	ret

00000000000056e2 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    56e2:	48ad                	li	a7,11
 ecall
    56e4:	00000073          	ecall
 ret
    56e8:	8082                	ret

00000000000056ea <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    56ea:	48b1                	li	a7,12
 ecall
    56ec:	00000073          	ecall
 ret
    56f0:	8082                	ret

00000000000056f2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    56f2:	48b5                	li	a7,13
 ecall
    56f4:	00000073          	ecall
 ret
    56f8:	8082                	ret

00000000000056fa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    56fa:	48b9                	li	a7,14
 ecall
    56fc:	00000073          	ecall
 ret
    5700:	8082                	ret

0000000000005702 <symlink>:
.global symlink
symlink:
 li a7, SYS_symlink
    5702:	48d9                	li	a7,22
 ecall
    5704:	00000073          	ecall
 ret
    5708:	8082                	ret

000000000000570a <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    570a:	1101                	addi	sp,sp,-32
    570c:	ec06                	sd	ra,24(sp)
    570e:	e822                	sd	s0,16(sp)
    5710:	1000                	addi	s0,sp,32
    5712:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    5716:	4605                	li	a2,1
    5718:	fef40593          	addi	a1,s0,-17
    571c:	00000097          	auipc	ra,0x0
    5720:	f66080e7          	jalr	-154(ra) # 5682 <write>
}
    5724:	60e2                	ld	ra,24(sp)
    5726:	6442                	ld	s0,16(sp)
    5728:	6105                	addi	sp,sp,32
    572a:	8082                	ret

000000000000572c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    572c:	7139                	addi	sp,sp,-64
    572e:	fc06                	sd	ra,56(sp)
    5730:	f822                	sd	s0,48(sp)
    5732:	f426                	sd	s1,40(sp)
    5734:	f04a                	sd	s2,32(sp)
    5736:	ec4e                	sd	s3,24(sp)
    5738:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    573a:	c299                	beqz	a3,5740 <printint+0x14>
    573c:	0005cd63          	bltz	a1,5756 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5740:	2581                	sext.w	a1,a1
  neg = 0;
    5742:	4301                	li	t1,0
    5744:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
    5748:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
    574a:	2601                	sext.w	a2,a2
    574c:	00003897          	auipc	a7,0x3
    5750:	b5c88893          	addi	a7,a7,-1188 # 82a8 <digits>
    5754:	a801                	j	5764 <printint+0x38>
    x = -xx;
    5756:	40b005bb          	negw	a1,a1
    575a:	2581                	sext.w	a1,a1
    neg = 1;
    575c:	4305                	li	t1,1
    x = -xx;
    575e:	b7dd                	j	5744 <printint+0x18>
  }while((x /= base) != 0);
    5760:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
    5762:	8836                	mv	a6,a3
    5764:	0018069b          	addiw	a3,a6,1
    5768:	02c5f7bb          	remuw	a5,a1,a2
    576c:	1782                	slli	a5,a5,0x20
    576e:	9381                	srli	a5,a5,0x20
    5770:	97c6                	add	a5,a5,a7
    5772:	0007c783          	lbu	a5,0(a5)
    5776:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
    577a:	0705                	addi	a4,a4,1
    577c:	02c5d7bb          	divuw	a5,a1,a2
    5780:	fec5f0e3          	bleu	a2,a1,5760 <printint+0x34>
  if(neg)
    5784:	00030b63          	beqz	t1,579a <printint+0x6e>
    buf[i++] = '-';
    5788:	fd040793          	addi	a5,s0,-48
    578c:	96be                	add	a3,a3,a5
    578e:	02d00793          	li	a5,45
    5792:	fef68823          	sb	a5,-16(a3) # ff0 <bigdir+0x7a>
    5796:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
    579a:	02d05963          	blez	a3,57cc <printint+0xa0>
    579e:	89aa                	mv	s3,a0
    57a0:	fc040793          	addi	a5,s0,-64
    57a4:	00d784b3          	add	s1,a5,a3
    57a8:	fff78913          	addi	s2,a5,-1
    57ac:	9936                	add	s2,s2,a3
    57ae:	36fd                	addiw	a3,a3,-1
    57b0:	1682                	slli	a3,a3,0x20
    57b2:	9281                	srli	a3,a3,0x20
    57b4:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
    57b8:	fff4c583          	lbu	a1,-1(s1)
    57bc:	854e                	mv	a0,s3
    57be:	00000097          	auipc	ra,0x0
    57c2:	f4c080e7          	jalr	-180(ra) # 570a <putc>
  while(--i >= 0)
    57c6:	14fd                	addi	s1,s1,-1
    57c8:	ff2498e3          	bne	s1,s2,57b8 <printint+0x8c>
}
    57cc:	70e2                	ld	ra,56(sp)
    57ce:	7442                	ld	s0,48(sp)
    57d0:	74a2                	ld	s1,40(sp)
    57d2:	7902                	ld	s2,32(sp)
    57d4:	69e2                	ld	s3,24(sp)
    57d6:	6121                	addi	sp,sp,64
    57d8:	8082                	ret

00000000000057da <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    57da:	7119                	addi	sp,sp,-128
    57dc:	fc86                	sd	ra,120(sp)
    57de:	f8a2                	sd	s0,112(sp)
    57e0:	f4a6                	sd	s1,104(sp)
    57e2:	f0ca                	sd	s2,96(sp)
    57e4:	ecce                	sd	s3,88(sp)
    57e6:	e8d2                	sd	s4,80(sp)
    57e8:	e4d6                	sd	s5,72(sp)
    57ea:	e0da                	sd	s6,64(sp)
    57ec:	fc5e                	sd	s7,56(sp)
    57ee:	f862                	sd	s8,48(sp)
    57f0:	f466                	sd	s9,40(sp)
    57f2:	f06a                	sd	s10,32(sp)
    57f4:	ec6e                	sd	s11,24(sp)
    57f6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    57f8:	0005c483          	lbu	s1,0(a1)
    57fc:	18048d63          	beqz	s1,5996 <vprintf+0x1bc>
    5800:	8aaa                	mv	s5,a0
    5802:	8b32                	mv	s6,a2
    5804:	00158913          	addi	s2,a1,1
  state = 0;
    5808:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    580a:	02500a13          	li	s4,37
      if(c == 'd'){
    580e:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    5812:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    5816:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    581a:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    581e:	00003b97          	auipc	s7,0x3
    5822:	a8ab8b93          	addi	s7,s7,-1398 # 82a8 <digits>
    5826:	a839                	j	5844 <vprintf+0x6a>
        putc(fd, c);
    5828:	85a6                	mv	a1,s1
    582a:	8556                	mv	a0,s5
    582c:	00000097          	auipc	ra,0x0
    5830:	ede080e7          	jalr	-290(ra) # 570a <putc>
    5834:	a019                	j	583a <vprintf+0x60>
    } else if(state == '%'){
    5836:	01498f63          	beq	s3,s4,5854 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    583a:	0905                	addi	s2,s2,1
    583c:	fff94483          	lbu	s1,-1(s2)
    5840:	14048b63          	beqz	s1,5996 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
    5844:	0004879b          	sext.w	a5,s1
    if(state == 0){
    5848:	fe0997e3          	bnez	s3,5836 <vprintf+0x5c>
      if(c == '%'){
    584c:	fd479ee3          	bne	a5,s4,5828 <vprintf+0x4e>
        state = '%';
    5850:	89be                	mv	s3,a5
    5852:	b7e5                	j	583a <vprintf+0x60>
      if(c == 'd'){
    5854:	05878063          	beq	a5,s8,5894 <vprintf+0xba>
      } else if(c == 'l') {
    5858:	05978c63          	beq	a5,s9,58b0 <vprintf+0xd6>
      } else if(c == 'x') {
    585c:	07a78863          	beq	a5,s10,58cc <vprintf+0xf2>
      } else if(c == 'p') {
    5860:	09b78463          	beq	a5,s11,58e8 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5864:	07300713          	li	a4,115
    5868:	0ce78563          	beq	a5,a4,5932 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    586c:	06300713          	li	a4,99
    5870:	0ee78c63          	beq	a5,a4,5968 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5874:	11478663          	beq	a5,s4,5980 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5878:	85d2                	mv	a1,s4
    587a:	8556                	mv	a0,s5
    587c:	00000097          	auipc	ra,0x0
    5880:	e8e080e7          	jalr	-370(ra) # 570a <putc>
        putc(fd, c);
    5884:	85a6                	mv	a1,s1
    5886:	8556                	mv	a0,s5
    5888:	00000097          	auipc	ra,0x0
    588c:	e82080e7          	jalr	-382(ra) # 570a <putc>
      }
      state = 0;
    5890:	4981                	li	s3,0
    5892:	b765                	j	583a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5894:	008b0493          	addi	s1,s6,8
    5898:	4685                	li	a3,1
    589a:	4629                	li	a2,10
    589c:	000b2583          	lw	a1,0(s6)
    58a0:	8556                	mv	a0,s5
    58a2:	00000097          	auipc	ra,0x0
    58a6:	e8a080e7          	jalr	-374(ra) # 572c <printint>
    58aa:	8b26                	mv	s6,s1
      state = 0;
    58ac:	4981                	li	s3,0
    58ae:	b771                	j	583a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    58b0:	008b0493          	addi	s1,s6,8
    58b4:	4681                	li	a3,0
    58b6:	4629                	li	a2,10
    58b8:	000b2583          	lw	a1,0(s6)
    58bc:	8556                	mv	a0,s5
    58be:	00000097          	auipc	ra,0x0
    58c2:	e6e080e7          	jalr	-402(ra) # 572c <printint>
    58c6:	8b26                	mv	s6,s1
      state = 0;
    58c8:	4981                	li	s3,0
    58ca:	bf85                	j	583a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    58cc:	008b0493          	addi	s1,s6,8
    58d0:	4681                	li	a3,0
    58d2:	4641                	li	a2,16
    58d4:	000b2583          	lw	a1,0(s6)
    58d8:	8556                	mv	a0,s5
    58da:	00000097          	auipc	ra,0x0
    58de:	e52080e7          	jalr	-430(ra) # 572c <printint>
    58e2:	8b26                	mv	s6,s1
      state = 0;
    58e4:	4981                	li	s3,0
    58e6:	bf91                	j	583a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    58e8:	008b0793          	addi	a5,s6,8
    58ec:	f8f43423          	sd	a5,-120(s0)
    58f0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    58f4:	03000593          	li	a1,48
    58f8:	8556                	mv	a0,s5
    58fa:	00000097          	auipc	ra,0x0
    58fe:	e10080e7          	jalr	-496(ra) # 570a <putc>
  putc(fd, 'x');
    5902:	85ea                	mv	a1,s10
    5904:	8556                	mv	a0,s5
    5906:	00000097          	auipc	ra,0x0
    590a:	e04080e7          	jalr	-508(ra) # 570a <putc>
    590e:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    5910:	03c9d793          	srli	a5,s3,0x3c
    5914:	97de                	add	a5,a5,s7
    5916:	0007c583          	lbu	a1,0(a5)
    591a:	8556                	mv	a0,s5
    591c:	00000097          	auipc	ra,0x0
    5920:	dee080e7          	jalr	-530(ra) # 570a <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    5924:	0992                	slli	s3,s3,0x4
    5926:	34fd                	addiw	s1,s1,-1
    5928:	f4e5                	bnez	s1,5910 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    592a:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    592e:	4981                	li	s3,0
    5930:	b729                	j	583a <vprintf+0x60>
        s = va_arg(ap, char*);
    5932:	008b0993          	addi	s3,s6,8
    5936:	000b3483          	ld	s1,0(s6)
        if(s == 0)
    593a:	c085                	beqz	s1,595a <vprintf+0x180>
        while(*s != 0){
    593c:	0004c583          	lbu	a1,0(s1)
    5940:	c9a1                	beqz	a1,5990 <vprintf+0x1b6>
          putc(fd, *s);
    5942:	8556                	mv	a0,s5
    5944:	00000097          	auipc	ra,0x0
    5948:	dc6080e7          	jalr	-570(ra) # 570a <putc>
          s++;
    594c:	0485                	addi	s1,s1,1
        while(*s != 0){
    594e:	0004c583          	lbu	a1,0(s1)
    5952:	f9e5                	bnez	a1,5942 <vprintf+0x168>
        s = va_arg(ap, char*);
    5954:	8b4e                	mv	s6,s3
      state = 0;
    5956:	4981                	li	s3,0
    5958:	b5cd                	j	583a <vprintf+0x60>
          s = "(null)";
    595a:	00003497          	auipc	s1,0x3
    595e:	96648493          	addi	s1,s1,-1690 # 82c0 <digits+0x18>
        while(*s != 0){
    5962:	02800593          	li	a1,40
    5966:	bff1                	j	5942 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
    5968:	008b0493          	addi	s1,s6,8
    596c:	000b4583          	lbu	a1,0(s6)
    5970:	8556                	mv	a0,s5
    5972:	00000097          	auipc	ra,0x0
    5976:	d98080e7          	jalr	-616(ra) # 570a <putc>
    597a:	8b26                	mv	s6,s1
      state = 0;
    597c:	4981                	li	s3,0
    597e:	bd75                	j	583a <vprintf+0x60>
        putc(fd, c);
    5980:	85d2                	mv	a1,s4
    5982:	8556                	mv	a0,s5
    5984:	00000097          	auipc	ra,0x0
    5988:	d86080e7          	jalr	-634(ra) # 570a <putc>
      state = 0;
    598c:	4981                	li	s3,0
    598e:	b575                	j	583a <vprintf+0x60>
        s = va_arg(ap, char*);
    5990:	8b4e                	mv	s6,s3
      state = 0;
    5992:	4981                	li	s3,0
    5994:	b55d                	j	583a <vprintf+0x60>
    }
  }
}
    5996:	70e6                	ld	ra,120(sp)
    5998:	7446                	ld	s0,112(sp)
    599a:	74a6                	ld	s1,104(sp)
    599c:	7906                	ld	s2,96(sp)
    599e:	69e6                	ld	s3,88(sp)
    59a0:	6a46                	ld	s4,80(sp)
    59a2:	6aa6                	ld	s5,72(sp)
    59a4:	6b06                	ld	s6,64(sp)
    59a6:	7be2                	ld	s7,56(sp)
    59a8:	7c42                	ld	s8,48(sp)
    59aa:	7ca2                	ld	s9,40(sp)
    59ac:	7d02                	ld	s10,32(sp)
    59ae:	6de2                	ld	s11,24(sp)
    59b0:	6109                	addi	sp,sp,128
    59b2:	8082                	ret

00000000000059b4 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    59b4:	715d                	addi	sp,sp,-80
    59b6:	ec06                	sd	ra,24(sp)
    59b8:	e822                	sd	s0,16(sp)
    59ba:	1000                	addi	s0,sp,32
    59bc:	e010                	sd	a2,0(s0)
    59be:	e414                	sd	a3,8(s0)
    59c0:	e818                	sd	a4,16(s0)
    59c2:	ec1c                	sd	a5,24(s0)
    59c4:	03043023          	sd	a6,32(s0)
    59c8:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    59cc:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    59d0:	8622                	mv	a2,s0
    59d2:	00000097          	auipc	ra,0x0
    59d6:	e08080e7          	jalr	-504(ra) # 57da <vprintf>
}
    59da:	60e2                	ld	ra,24(sp)
    59dc:	6442                	ld	s0,16(sp)
    59de:	6161                	addi	sp,sp,80
    59e0:	8082                	ret

00000000000059e2 <printf>:

void
printf(const char *fmt, ...)
{
    59e2:	711d                	addi	sp,sp,-96
    59e4:	ec06                	sd	ra,24(sp)
    59e6:	e822                	sd	s0,16(sp)
    59e8:	1000                	addi	s0,sp,32
    59ea:	e40c                	sd	a1,8(s0)
    59ec:	e810                	sd	a2,16(s0)
    59ee:	ec14                	sd	a3,24(s0)
    59f0:	f018                	sd	a4,32(s0)
    59f2:	f41c                	sd	a5,40(s0)
    59f4:	03043823          	sd	a6,48(s0)
    59f8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    59fc:	00840613          	addi	a2,s0,8
    5a00:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    5a04:	85aa                	mv	a1,a0
    5a06:	4505                	li	a0,1
    5a08:	00000097          	auipc	ra,0x0
    5a0c:	dd2080e7          	jalr	-558(ra) # 57da <vprintf>
}
    5a10:	60e2                	ld	ra,24(sp)
    5a12:	6442                	ld	s0,16(sp)
    5a14:	6125                	addi	sp,sp,96
    5a16:	8082                	ret

0000000000005a18 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    5a18:	1141                	addi	sp,sp,-16
    5a1a:	e422                	sd	s0,8(sp)
    5a1c:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    5a1e:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a22:	00003797          	auipc	a5,0x3
    5a26:	8b678793          	addi	a5,a5,-1866 # 82d8 <_edata>
    5a2a:	639c                	ld	a5,0(a5)
    5a2c:	a805                	j	5a5c <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5a2e:	4618                	lw	a4,8(a2)
    5a30:	9db9                	addw	a1,a1,a4
    5a32:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5a36:	6398                	ld	a4,0(a5)
    5a38:	6318                	ld	a4,0(a4)
    5a3a:	fee53823          	sd	a4,-16(a0)
    5a3e:	a091                	j	5a82 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5a40:	ff852703          	lw	a4,-8(a0)
    5a44:	9e39                	addw	a2,a2,a4
    5a46:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    5a48:	ff053703          	ld	a4,-16(a0)
    5a4c:	e398                	sd	a4,0(a5)
    5a4e:	a099                	j	5a94 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a50:	6398                	ld	a4,0(a5)
    5a52:	00e7e463          	bltu	a5,a4,5a5a <free+0x42>
    5a56:	00e6ea63          	bltu	a3,a4,5a6a <free+0x52>
{
    5a5a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    5a5c:	fed7fae3          	bleu	a3,a5,5a50 <free+0x38>
    5a60:	6398                	ld	a4,0(a5)
    5a62:	00e6e463          	bltu	a3,a4,5a6a <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5a66:	fee7eae3          	bltu	a5,a4,5a5a <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
    5a6a:	ff852583          	lw	a1,-8(a0)
    5a6e:	6390                	ld	a2,0(a5)
    5a70:	02059713          	slli	a4,a1,0x20
    5a74:	9301                	srli	a4,a4,0x20
    5a76:	0712                	slli	a4,a4,0x4
    5a78:	9736                	add	a4,a4,a3
    5a7a:	fae60ae3          	beq	a2,a4,5a2e <free+0x16>
    bp->s.ptr = p->s.ptr;
    5a7e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5a82:	4790                	lw	a2,8(a5)
    5a84:	02061713          	slli	a4,a2,0x20
    5a88:	9301                	srli	a4,a4,0x20
    5a8a:	0712                	slli	a4,a4,0x4
    5a8c:	973e                	add	a4,a4,a5
    5a8e:	fae689e3          	beq	a3,a4,5a40 <free+0x28>
  } else
    p->s.ptr = bp;
    5a92:	e394                	sd	a3,0(a5)
  freep = p;
    5a94:	00003717          	auipc	a4,0x3
    5a98:	84f73223          	sd	a5,-1980(a4) # 82d8 <_edata>
}
    5a9c:	6422                	ld	s0,8(sp)
    5a9e:	0141                	addi	sp,sp,16
    5aa0:	8082                	ret

0000000000005aa2 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5aa2:	7139                	addi	sp,sp,-64
    5aa4:	fc06                	sd	ra,56(sp)
    5aa6:	f822                	sd	s0,48(sp)
    5aa8:	f426                	sd	s1,40(sp)
    5aaa:	f04a                	sd	s2,32(sp)
    5aac:	ec4e                	sd	s3,24(sp)
    5aae:	e852                	sd	s4,16(sp)
    5ab0:	e456                	sd	s5,8(sp)
    5ab2:	e05a                	sd	s6,0(sp)
    5ab4:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5ab6:	02051993          	slli	s3,a0,0x20
    5aba:	0209d993          	srli	s3,s3,0x20
    5abe:	09bd                	addi	s3,s3,15
    5ac0:	0049d993          	srli	s3,s3,0x4
    5ac4:	2985                	addiw	s3,s3,1
    5ac6:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
    5aca:	00003797          	auipc	a5,0x3
    5ace:	80e78793          	addi	a5,a5,-2034 # 82d8 <_edata>
    5ad2:	6388                	ld	a0,0(a5)
    5ad4:	c515                	beqz	a0,5b00 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5ad6:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5ad8:	4798                	lw	a4,8(a5)
    5ada:	03277f63          	bleu	s2,a4,5b18 <malloc+0x76>
    5ade:	8a4e                	mv	s4,s3
    5ae0:	0009871b          	sext.w	a4,s3
    5ae4:	6685                	lui	a3,0x1
    5ae6:	00d77363          	bleu	a3,a4,5aec <malloc+0x4a>
    5aea:	6a05                	lui	s4,0x1
    5aec:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
    5af0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    5af4:	00002497          	auipc	s1,0x2
    5af8:	7e448493          	addi	s1,s1,2020 # 82d8 <_edata>
  if(p == (char*)-1)
    5afc:	5b7d                	li	s6,-1
    5afe:	a885                	j	5b6e <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
    5b00:	00009797          	auipc	a5,0x9
    5b04:	ff878793          	addi	a5,a5,-8 # eaf8 <base>
    5b08:	00002717          	auipc	a4,0x2
    5b0c:	7cf73823          	sd	a5,2000(a4) # 82d8 <_edata>
    5b10:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    5b12:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    5b16:	b7e1                	j	5ade <malloc+0x3c>
      if(p->s.size == nunits)
    5b18:	02e90b63          	beq	s2,a4,5b4e <malloc+0xac>
        p->s.size -= nunits;
    5b1c:	4137073b          	subw	a4,a4,s3
    5b20:	c798                	sw	a4,8(a5)
        p += p->s.size;
    5b22:	1702                	slli	a4,a4,0x20
    5b24:	9301                	srli	a4,a4,0x20
    5b26:	0712                	slli	a4,a4,0x4
    5b28:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    5b2a:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5b2e:	00002717          	auipc	a4,0x2
    5b32:	7aa73523          	sd	a0,1962(a4) # 82d8 <_edata>
      return (void*)(p + 1);
    5b36:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5b3a:	70e2                	ld	ra,56(sp)
    5b3c:	7442                	ld	s0,48(sp)
    5b3e:	74a2                	ld	s1,40(sp)
    5b40:	7902                	ld	s2,32(sp)
    5b42:	69e2                	ld	s3,24(sp)
    5b44:	6a42                	ld	s4,16(sp)
    5b46:	6aa2                	ld	s5,8(sp)
    5b48:	6b02                	ld	s6,0(sp)
    5b4a:	6121                	addi	sp,sp,64
    5b4c:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5b4e:	6398                	ld	a4,0(a5)
    5b50:	e118                	sd	a4,0(a0)
    5b52:	bff1                	j	5b2e <malloc+0x8c>
  hp->s.size = nu;
    5b54:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
    5b58:	0541                	addi	a0,a0,16
    5b5a:	00000097          	auipc	ra,0x0
    5b5e:	ebe080e7          	jalr	-322(ra) # 5a18 <free>
  return freep;
    5b62:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    5b64:	d979                	beqz	a0,5b3a <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5b66:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5b68:	4798                	lw	a4,8(a5)
    5b6a:	fb2777e3          	bleu	s2,a4,5b18 <malloc+0x76>
    if(p == freep)
    5b6e:	6098                	ld	a4,0(s1)
    5b70:	853e                	mv	a0,a5
    5b72:	fef71ae3          	bne	a4,a5,5b66 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
    5b76:	8552                	mv	a0,s4
    5b78:	00000097          	auipc	ra,0x0
    5b7c:	b72080e7          	jalr	-1166(ra) # 56ea <sbrk>
  if(p == (char*)-1)
    5b80:	fd651ae3          	bne	a0,s6,5b54 <malloc+0xb2>
        return 0;
    5b84:	4501                	li	a0,0
    5b86:	bf55                	j	5b3a <malloc+0x98>
