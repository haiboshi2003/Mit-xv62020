
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
      14:	56c080e7          	jalr	1388(ra) # 557c <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	55a080e7          	jalr	1370(ra) # 557c <open>
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
      42:	dd250513          	addi	a0,a0,-558 # 5e10 <malloc+0x49c>
      46:	00006097          	auipc	ra,0x6
      4a:	86e080e7          	jalr	-1938(ra) # 58b4 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	4ec080e7          	jalr	1260(ra) # 553c <exit>

0000000000000058 <bsstest>:
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
      58:	00009797          	auipc	a5,0x9
      5c:	2587c783          	lbu	a5,600(a5) # 92b0 <uninit>
      60:	e385                	bnez	a5,80 <bsstest+0x28>
      62:	00009797          	auipc	a5,0x9
      66:	24f78793          	addi	a5,a5,591 # 92b1 <uninit+0x1>
      6a:	0000c697          	auipc	a3,0xc
      6e:	95668693          	addi	a3,a3,-1706 # b9c0 <buf>
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
      8e:	da650513          	addi	a0,a0,-602 # 5e30 <malloc+0x4bc>
      92:	00006097          	auipc	ra,0x6
      96:	822080e7          	jalr	-2014(ra) # 58b4 <printf>
      exit(1);
      9a:	4505                	li	a0,1
      9c:	00005097          	auipc	ra,0x5
      a0:	4a0080e7          	jalr	1184(ra) # 553c <exit>

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
      b6:	d9650513          	addi	a0,a0,-618 # 5e48 <malloc+0x4d4>
      ba:	00005097          	auipc	ra,0x5
      be:	4c2080e7          	jalr	1218(ra) # 557c <open>
  if(fd < 0){
      c2:	02054663          	bltz	a0,ee <opentest+0x4a>
  close(fd);
      c6:	00005097          	auipc	ra,0x5
      ca:	49e080e7          	jalr	1182(ra) # 5564 <close>
  fd = open("doesnotexist", 0);
      ce:	4581                	li	a1,0
      d0:	00006517          	auipc	a0,0x6
      d4:	d9850513          	addi	a0,a0,-616 # 5e68 <malloc+0x4f4>
      d8:	00005097          	auipc	ra,0x5
      dc:	4a4080e7          	jalr	1188(ra) # 557c <open>
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
      f4:	d6050513          	addi	a0,a0,-672 # 5e50 <malloc+0x4dc>
      f8:	00005097          	auipc	ra,0x5
      fc:	7bc080e7          	jalr	1980(ra) # 58b4 <printf>
    exit(1);
     100:	4505                	li	a0,1
     102:	00005097          	auipc	ra,0x5
     106:	43a080e7          	jalr	1082(ra) # 553c <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     10a:	85a6                	mv	a1,s1
     10c:	00006517          	auipc	a0,0x6
     110:	d6c50513          	addi	a0,a0,-660 # 5e78 <malloc+0x504>
     114:	00005097          	auipc	ra,0x5
     118:	7a0080e7          	jalr	1952(ra) # 58b4 <printf>
    exit(1);
     11c:	4505                	li	a0,1
     11e:	00005097          	auipc	ra,0x5
     122:	41e080e7          	jalr	1054(ra) # 553c <exit>

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
     13a:	d6a50513          	addi	a0,a0,-662 # 5ea0 <malloc+0x52c>
     13e:	00005097          	auipc	ra,0x5
     142:	44e080e7          	jalr	1102(ra) # 558c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     146:	60100593          	li	a1,1537
     14a:	00006517          	auipc	a0,0x6
     14e:	d5650513          	addi	a0,a0,-682 # 5ea0 <malloc+0x52c>
     152:	00005097          	auipc	ra,0x5
     156:	42a080e7          	jalr	1066(ra) # 557c <open>
     15a:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     15c:	4611                	li	a2,4
     15e:	00006597          	auipc	a1,0x6
     162:	d5258593          	addi	a1,a1,-686 # 5eb0 <malloc+0x53c>
     166:	00005097          	auipc	ra,0x5
     16a:	3f6080e7          	jalr	1014(ra) # 555c <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     16e:	40100593          	li	a1,1025
     172:	00006517          	auipc	a0,0x6
     176:	d2e50513          	addi	a0,a0,-722 # 5ea0 <malloc+0x52c>
     17a:	00005097          	auipc	ra,0x5
     17e:	402080e7          	jalr	1026(ra) # 557c <open>
     182:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     184:	4605                	li	a2,1
     186:	00006597          	auipc	a1,0x6
     18a:	d3258593          	addi	a1,a1,-718 # 5eb8 <malloc+0x544>
     18e:	8526                	mv	a0,s1
     190:	00005097          	auipc	ra,0x5
     194:	3cc080e7          	jalr	972(ra) # 555c <write>
  if(n != -1){
     198:	57fd                	li	a5,-1
     19a:	02f51b63          	bne	a0,a5,1d0 <truncate2+0xaa>
  unlink("truncfile");
     19e:	00006517          	auipc	a0,0x6
     1a2:	d0250513          	addi	a0,a0,-766 # 5ea0 <malloc+0x52c>
     1a6:	00005097          	auipc	ra,0x5
     1aa:	3e6080e7          	jalr	998(ra) # 558c <unlink>
  close(fd1);
     1ae:	8526                	mv	a0,s1
     1b0:	00005097          	auipc	ra,0x5
     1b4:	3b4080e7          	jalr	948(ra) # 5564 <close>
  close(fd2);
     1b8:	854a                	mv	a0,s2
     1ba:	00005097          	auipc	ra,0x5
     1be:	3aa080e7          	jalr	938(ra) # 5564 <close>
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
     1d8:	cec50513          	addi	a0,a0,-788 # 5ec0 <malloc+0x54c>
     1dc:	00005097          	auipc	ra,0x5
     1e0:	6d8080e7          	jalr	1752(ra) # 58b4 <printf>
    exit(1);
     1e4:	4505                	li	a0,1
     1e6:	00005097          	auipc	ra,0x5
     1ea:	356080e7          	jalr	854(ra) # 553c <exit>

00000000000001ee <createtest>:
{
     1ee:	7179                	addi	sp,sp,-48
     1f0:	f406                	sd	ra,40(sp)
     1f2:	f022                	sd	s0,32(sp)
     1f4:	ec26                	sd	s1,24(sp)
     1f6:	e84a                	sd	s2,16(sp)
     1f8:	e44e                	sd	s3,8(sp)
     1fa:	1800                	addi	s0,sp,48
  name[0] = 'a';
     1fc:	00008797          	auipc	a5,0x8
     200:	f9c78793          	addi	a5,a5,-100 # 8198 <_edata>
     204:	06100713          	li	a4,97
     208:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     20c:	00078123          	sb	zero,2(a5)
     210:	03000493          	li	s1,48
    name[1] = '0' + i;
     214:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     216:	06400993          	li	s3,100
    name[1] = '0' + i;
     21a:	009900a3          	sb	s1,1(s2)
    fd = open(name, O_CREATE|O_RDWR);
     21e:	20200593          	li	a1,514
     222:	854a                	mv	a0,s2
     224:	00005097          	auipc	ra,0x5
     228:	358080e7          	jalr	856(ra) # 557c <open>
    close(fd);
     22c:	00005097          	auipc	ra,0x5
     230:	338080e7          	jalr	824(ra) # 5564 <close>
  for(i = 0; i < N; i++){
     234:	2485                	addiw	s1,s1,1
     236:	0ff4f493          	andi	s1,s1,255
     23a:	ff3490e3          	bne	s1,s3,21a <createtest+0x2c>
  name[0] = 'a';
     23e:	00008797          	auipc	a5,0x8
     242:	f5a78793          	addi	a5,a5,-166 # 8198 <_edata>
     246:	06100713          	li	a4,97
     24a:	00e78023          	sb	a4,0(a5)
  name[2] = '\0';
     24e:	00078123          	sb	zero,2(a5)
     252:	03000493          	li	s1,48
    name[1] = '0' + i;
     256:	893e                	mv	s2,a5
  for(i = 0; i < N; i++){
     258:	06400993          	li	s3,100
    name[1] = '0' + i;
     25c:	009900a3          	sb	s1,1(s2)
    unlink(name);
     260:	854a                	mv	a0,s2
     262:	00005097          	auipc	ra,0x5
     266:	32a080e7          	jalr	810(ra) # 558c <unlink>
  for(i = 0; i < N; i++){
     26a:	2485                	addiw	s1,s1,1
     26c:	0ff4f493          	andi	s1,s1,255
     270:	ff3496e3          	bne	s1,s3,25c <createtest+0x6e>
}
     274:	70a2                	ld	ra,40(sp)
     276:	7402                	ld	s0,32(sp)
     278:	64e2                	ld	s1,24(sp)
     27a:	6942                	ld	s2,16(sp)
     27c:	69a2                	ld	s3,8(sp)
     27e:	6145                	addi	sp,sp,48
     280:	8082                	ret

0000000000000282 <bigwrite>:
{
     282:	715d                	addi	sp,sp,-80
     284:	e486                	sd	ra,72(sp)
     286:	e0a2                	sd	s0,64(sp)
     288:	fc26                	sd	s1,56(sp)
     28a:	f84a                	sd	s2,48(sp)
     28c:	f44e                	sd	s3,40(sp)
     28e:	f052                	sd	s4,32(sp)
     290:	ec56                	sd	s5,24(sp)
     292:	e85a                	sd	s6,16(sp)
     294:	e45e                	sd	s7,8(sp)
     296:	0880                	addi	s0,sp,80
     298:	8baa                	mv	s7,a0
  unlink("bigwrite");
     29a:	00006517          	auipc	a0,0x6
     29e:	c4e50513          	addi	a0,a0,-946 # 5ee8 <malloc+0x574>
     2a2:	00005097          	auipc	ra,0x5
     2a6:	2ea080e7          	jalr	746(ra) # 558c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2aa:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ae:	00006a17          	auipc	s4,0x6
     2b2:	c3aa0a13          	addi	s4,s4,-966 # 5ee8 <malloc+0x574>
      int cc = write(fd, buf, sz);
     2b6:	0000b997          	auipc	s3,0xb
     2ba:	70a98993          	addi	s3,s3,1802 # b9c0 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2be:	6b0d                	lui	s6,0x3
     2c0:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x369>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2c4:	20200593          	li	a1,514
     2c8:	8552                	mv	a0,s4
     2ca:	00005097          	auipc	ra,0x5
     2ce:	2b2080e7          	jalr	690(ra) # 557c <open>
     2d2:	892a                	mv	s2,a0
    if(fd < 0){
     2d4:	04054d63          	bltz	a0,32e <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2d8:	8626                	mv	a2,s1
     2da:	85ce                	mv	a1,s3
     2dc:	00005097          	auipc	ra,0x5
     2e0:	280080e7          	jalr	640(ra) # 555c <write>
     2e4:	8aaa                	mv	s5,a0
      if(cc != sz){
     2e6:	06a49463          	bne	s1,a0,34e <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2ea:	8626                	mv	a2,s1
     2ec:	85ce                	mv	a1,s3
     2ee:	854a                	mv	a0,s2
     2f0:	00005097          	auipc	ra,0x5
     2f4:	26c080e7          	jalr	620(ra) # 555c <write>
      if(cc != sz){
     2f8:	04951963          	bne	a0,s1,34a <bigwrite+0xc8>
    close(fd);
     2fc:	854a                	mv	a0,s2
     2fe:	00005097          	auipc	ra,0x5
     302:	266080e7          	jalr	614(ra) # 5564 <close>
    unlink("bigwrite");
     306:	8552                	mv	a0,s4
     308:	00005097          	auipc	ra,0x5
     30c:	284080e7          	jalr	644(ra) # 558c <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     310:	1d74849b          	addiw	s1,s1,471
     314:	fb6498e3          	bne	s1,s6,2c4 <bigwrite+0x42>
}
     318:	60a6                	ld	ra,72(sp)
     31a:	6406                	ld	s0,64(sp)
     31c:	74e2                	ld	s1,56(sp)
     31e:	7942                	ld	s2,48(sp)
     320:	79a2                	ld	s3,40(sp)
     322:	7a02                	ld	s4,32(sp)
     324:	6ae2                	ld	s5,24(sp)
     326:	6b42                	ld	s6,16(sp)
     328:	6ba2                	ld	s7,8(sp)
     32a:	6161                	addi	sp,sp,80
     32c:	8082                	ret
      printf("%s: cannot create bigwrite\n", s);
     32e:	85de                	mv	a1,s7
     330:	00006517          	auipc	a0,0x6
     334:	bc850513          	addi	a0,a0,-1080 # 5ef8 <malloc+0x584>
     338:	00005097          	auipc	ra,0x5
     33c:	57c080e7          	jalr	1404(ra) # 58b4 <printf>
      exit(1);
     340:	4505                	li	a0,1
     342:	00005097          	auipc	ra,0x5
     346:	1fa080e7          	jalr	506(ra) # 553c <exit>
     34a:	84d6                	mv	s1,s5
      int cc = write(fd, buf, sz);
     34c:	8aaa                	mv	s5,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     34e:	86d6                	mv	a3,s5
     350:	8626                	mv	a2,s1
     352:	85de                	mv	a1,s7
     354:	00006517          	auipc	a0,0x6
     358:	bc450513          	addi	a0,a0,-1084 # 5f18 <malloc+0x5a4>
     35c:	00005097          	auipc	ra,0x5
     360:	558080e7          	jalr	1368(ra) # 58b4 <printf>
        exit(1);
     364:	4505                	li	a0,1
     366:	00005097          	auipc	ra,0x5
     36a:	1d6080e7          	jalr	470(ra) # 553c <exit>

000000000000036e <copyin>:
{
     36e:	711d                	addi	sp,sp,-96
     370:	ec86                	sd	ra,88(sp)
     372:	e8a2                	sd	s0,80(sp)
     374:	e4a6                	sd	s1,72(sp)
     376:	e0ca                	sd	s2,64(sp)
     378:	fc4e                	sd	s3,56(sp)
     37a:	f852                	sd	s4,48(sp)
     37c:	f456                	sd	s5,40(sp)
     37e:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     380:	4785                	li	a5,1
     382:	07fe                	slli	a5,a5,0x1f
     384:	faf43823          	sd	a5,-80(s0)
     388:	57fd                	li	a5,-1
     38a:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     38e:	fb040493          	addi	s1,s0,-80
     392:	fc040a93          	addi	s5,s0,-64
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     396:	00006a17          	auipc	s4,0x6
     39a:	b9aa0a13          	addi	s4,s4,-1126 # 5f30 <malloc+0x5bc>
    uint64 addr = addrs[ai];
     39e:	0004b903          	ld	s2,0(s1)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     3a2:	20100593          	li	a1,513
     3a6:	8552                	mv	a0,s4
     3a8:	00005097          	auipc	ra,0x5
     3ac:	1d4080e7          	jalr	468(ra) # 557c <open>
     3b0:	89aa                	mv	s3,a0
    if(fd < 0){
     3b2:	08054763          	bltz	a0,440 <copyin+0xd2>
    int n = write(fd, (void*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ca                	mv	a1,s2
     3ba:	00005097          	auipc	ra,0x5
     3be:	1a2080e7          	jalr	418(ra) # 555c <write>
    if(n >= 0){
     3c2:	08055c63          	bgez	a0,45a <copyin+0xec>
    close(fd);
     3c6:	854e                	mv	a0,s3
     3c8:	00005097          	auipc	ra,0x5
     3cc:	19c080e7          	jalr	412(ra) # 5564 <close>
    unlink("copyin1");
     3d0:	8552                	mv	a0,s4
     3d2:	00005097          	auipc	ra,0x5
     3d6:	1ba080e7          	jalr	442(ra) # 558c <unlink>
    n = write(1, (char*)addr, 8192);
     3da:	6609                	lui	a2,0x2
     3dc:	85ca                	mv	a1,s2
     3de:	4505                	li	a0,1
     3e0:	00005097          	auipc	ra,0x5
     3e4:	17c080e7          	jalr	380(ra) # 555c <write>
    if(n > 0){
     3e8:	08a04863          	bgtz	a0,478 <copyin+0x10a>
    if(pipe(fds) < 0){
     3ec:	fa840513          	addi	a0,s0,-88
     3f0:	00005097          	auipc	ra,0x5
     3f4:	15c080e7          	jalr	348(ra) # 554c <pipe>
     3f8:	08054f63          	bltz	a0,496 <copyin+0x128>
    n = write(fds[1], (char*)addr, 8192);
     3fc:	6609                	lui	a2,0x2
     3fe:	85ca                	mv	a1,s2
     400:	fac42503          	lw	a0,-84(s0)
     404:	00005097          	auipc	ra,0x5
     408:	158080e7          	jalr	344(ra) # 555c <write>
    if(n > 0){
     40c:	0aa04263          	bgtz	a0,4b0 <copyin+0x142>
    close(fds[0]);
     410:	fa842503          	lw	a0,-88(s0)
     414:	00005097          	auipc	ra,0x5
     418:	150080e7          	jalr	336(ra) # 5564 <close>
    close(fds[1]);
     41c:	fac42503          	lw	a0,-84(s0)
     420:	00005097          	auipc	ra,0x5
     424:	144080e7          	jalr	324(ra) # 5564 <close>
  for(int ai = 0; ai < 2; ai++){
     428:	04a1                	addi	s1,s1,8
     42a:	f7549ae3          	bne	s1,s5,39e <copyin+0x30>
}
     42e:	60e6                	ld	ra,88(sp)
     430:	6446                	ld	s0,80(sp)
     432:	64a6                	ld	s1,72(sp)
     434:	6906                	ld	s2,64(sp)
     436:	79e2                	ld	s3,56(sp)
     438:	7a42                	ld	s4,48(sp)
     43a:	7aa2                	ld	s5,40(sp)
     43c:	6125                	addi	sp,sp,96
     43e:	8082                	ret
      printf("open(copyin1) failed\n");
     440:	00006517          	auipc	a0,0x6
     444:	af850513          	addi	a0,a0,-1288 # 5f38 <malloc+0x5c4>
     448:	00005097          	auipc	ra,0x5
     44c:	46c080e7          	jalr	1132(ra) # 58b4 <printf>
      exit(1);
     450:	4505                	li	a0,1
     452:	00005097          	auipc	ra,0x5
     456:	0ea080e7          	jalr	234(ra) # 553c <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     45a:	862a                	mv	a2,a0
     45c:	85ca                	mv	a1,s2
     45e:	00006517          	auipc	a0,0x6
     462:	af250513          	addi	a0,a0,-1294 # 5f50 <malloc+0x5dc>
     466:	00005097          	auipc	ra,0x5
     46a:	44e080e7          	jalr	1102(ra) # 58b4 <printf>
      exit(1);
     46e:	4505                	li	a0,1
     470:	00005097          	auipc	ra,0x5
     474:	0cc080e7          	jalr	204(ra) # 553c <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     478:	862a                	mv	a2,a0
     47a:	85ca                	mv	a1,s2
     47c:	00006517          	auipc	a0,0x6
     480:	b0450513          	addi	a0,a0,-1276 # 5f80 <malloc+0x60c>
     484:	00005097          	auipc	ra,0x5
     488:	430080e7          	jalr	1072(ra) # 58b4 <printf>
      exit(1);
     48c:	4505                	li	a0,1
     48e:	00005097          	auipc	ra,0x5
     492:	0ae080e7          	jalr	174(ra) # 553c <exit>
      printf("pipe() failed\n");
     496:	00006517          	auipc	a0,0x6
     49a:	b1a50513          	addi	a0,a0,-1254 # 5fb0 <malloc+0x63c>
     49e:	00005097          	auipc	ra,0x5
     4a2:	416080e7          	jalr	1046(ra) # 58b4 <printf>
      exit(1);
     4a6:	4505                	li	a0,1
     4a8:	00005097          	auipc	ra,0x5
     4ac:	094080e7          	jalr	148(ra) # 553c <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     4b0:	862a                	mv	a2,a0
     4b2:	85ca                	mv	a1,s2
     4b4:	00006517          	auipc	a0,0x6
     4b8:	b0c50513          	addi	a0,a0,-1268 # 5fc0 <malloc+0x64c>
     4bc:	00005097          	auipc	ra,0x5
     4c0:	3f8080e7          	jalr	1016(ra) # 58b4 <printf>
      exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00005097          	auipc	ra,0x5
     4ca:	076080e7          	jalr	118(ra) # 553c <exit>

00000000000004ce <copyout>:
{
     4ce:	711d                	addi	sp,sp,-96
     4d0:	ec86                	sd	ra,88(sp)
     4d2:	e8a2                	sd	s0,80(sp)
     4d4:	e4a6                	sd	s1,72(sp)
     4d6:	e0ca                	sd	s2,64(sp)
     4d8:	fc4e                	sd	s3,56(sp)
     4da:	f852                	sd	s4,48(sp)
     4dc:	f456                	sd	s5,40(sp)
     4de:	f05a                	sd	s6,32(sp)
     4e0:	1080                	addi	s0,sp,96
  uint64 addrs[] = { 0x80000000LL, 0xffffffffffffffff };
     4e2:	4785                	li	a5,1
     4e4:	07fe                	slli	a5,a5,0x1f
     4e6:	faf43823          	sd	a5,-80(s0)
     4ea:	57fd                	li	a5,-1
     4ec:	faf43c23          	sd	a5,-72(s0)
  for(int ai = 0; ai < 2; ai++){
     4f0:	fb040493          	addi	s1,s0,-80
     4f4:	fc040b13          	addi	s6,s0,-64
    int fd = open("README", 0);
     4f8:	00006a17          	auipc	s4,0x6
     4fc:	af8a0a13          	addi	s4,s4,-1288 # 5ff0 <malloc+0x67c>
    n = write(fds[1], "x", 1);
     500:	00006a97          	auipc	s5,0x6
     504:	9b8a8a93          	addi	s5,s5,-1608 # 5eb8 <malloc+0x544>
    uint64 addr = addrs[ai];
     508:	0004b983          	ld	s3,0(s1)
    int fd = open("README", 0);
     50c:	4581                	li	a1,0
     50e:	8552                	mv	a0,s4
     510:	00005097          	auipc	ra,0x5
     514:	06c080e7          	jalr	108(ra) # 557c <open>
     518:	892a                	mv	s2,a0
    if(fd < 0){
     51a:	08054563          	bltz	a0,5a4 <copyout+0xd6>
    int n = read(fd, (void*)addr, 8192);
     51e:	6609                	lui	a2,0x2
     520:	85ce                	mv	a1,s3
     522:	00005097          	auipc	ra,0x5
     526:	032080e7          	jalr	50(ra) # 5554 <read>
    if(n > 0){
     52a:	08a04a63          	bgtz	a0,5be <copyout+0xf0>
    close(fd);
     52e:	854a                	mv	a0,s2
     530:	00005097          	auipc	ra,0x5
     534:	034080e7          	jalr	52(ra) # 5564 <close>
    if(pipe(fds) < 0){
     538:	fa840513          	addi	a0,s0,-88
     53c:	00005097          	auipc	ra,0x5
     540:	010080e7          	jalr	16(ra) # 554c <pipe>
     544:	08054c63          	bltz	a0,5dc <copyout+0x10e>
    n = write(fds[1], "x", 1);
     548:	4605                	li	a2,1
     54a:	85d6                	mv	a1,s5
     54c:	fac42503          	lw	a0,-84(s0)
     550:	00005097          	auipc	ra,0x5
     554:	00c080e7          	jalr	12(ra) # 555c <write>
    if(n != 1){
     558:	4785                	li	a5,1
     55a:	08f51e63          	bne	a0,a5,5f6 <copyout+0x128>
    n = read(fds[0], (void*)addr, 8192);
     55e:	6609                	lui	a2,0x2
     560:	85ce                	mv	a1,s3
     562:	fa842503          	lw	a0,-88(s0)
     566:	00005097          	auipc	ra,0x5
     56a:	fee080e7          	jalr	-18(ra) # 5554 <read>
    if(n > 0){
     56e:	0aa04163          	bgtz	a0,610 <copyout+0x142>
    close(fds[0]);
     572:	fa842503          	lw	a0,-88(s0)
     576:	00005097          	auipc	ra,0x5
     57a:	fee080e7          	jalr	-18(ra) # 5564 <close>
    close(fds[1]);
     57e:	fac42503          	lw	a0,-84(s0)
     582:	00005097          	auipc	ra,0x5
     586:	fe2080e7          	jalr	-30(ra) # 5564 <close>
  for(int ai = 0; ai < 2; ai++){
     58a:	04a1                	addi	s1,s1,8
     58c:	f7649ee3          	bne	s1,s6,508 <copyout+0x3a>
}
     590:	60e6                	ld	ra,88(sp)
     592:	6446                	ld	s0,80(sp)
     594:	64a6                	ld	s1,72(sp)
     596:	6906                	ld	s2,64(sp)
     598:	79e2                	ld	s3,56(sp)
     59a:	7a42                	ld	s4,48(sp)
     59c:	7aa2                	ld	s5,40(sp)
     59e:	7b02                	ld	s6,32(sp)
     5a0:	6125                	addi	sp,sp,96
     5a2:	8082                	ret
      printf("open(README) failed\n");
     5a4:	00006517          	auipc	a0,0x6
     5a8:	a5450513          	addi	a0,a0,-1452 # 5ff8 <malloc+0x684>
     5ac:	00005097          	auipc	ra,0x5
     5b0:	308080e7          	jalr	776(ra) # 58b4 <printf>
      exit(1);
     5b4:	4505                	li	a0,1
     5b6:	00005097          	auipc	ra,0x5
     5ba:	f86080e7          	jalr	-122(ra) # 553c <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5be:	862a                	mv	a2,a0
     5c0:	85ce                	mv	a1,s3
     5c2:	00006517          	auipc	a0,0x6
     5c6:	a4e50513          	addi	a0,a0,-1458 # 6010 <malloc+0x69c>
     5ca:	00005097          	auipc	ra,0x5
     5ce:	2ea080e7          	jalr	746(ra) # 58b4 <printf>
      exit(1);
     5d2:	4505                	li	a0,1
     5d4:	00005097          	auipc	ra,0x5
     5d8:	f68080e7          	jalr	-152(ra) # 553c <exit>
      printf("pipe() failed\n");
     5dc:	00006517          	auipc	a0,0x6
     5e0:	9d450513          	addi	a0,a0,-1580 # 5fb0 <malloc+0x63c>
     5e4:	00005097          	auipc	ra,0x5
     5e8:	2d0080e7          	jalr	720(ra) # 58b4 <printf>
      exit(1);
     5ec:	4505                	li	a0,1
     5ee:	00005097          	auipc	ra,0x5
     5f2:	f4e080e7          	jalr	-178(ra) # 553c <exit>
      printf("pipe write failed\n");
     5f6:	00006517          	auipc	a0,0x6
     5fa:	a4a50513          	addi	a0,a0,-1462 # 6040 <malloc+0x6cc>
     5fe:	00005097          	auipc	ra,0x5
     602:	2b6080e7          	jalr	694(ra) # 58b4 <printf>
      exit(1);
     606:	4505                	li	a0,1
     608:	00005097          	auipc	ra,0x5
     60c:	f34080e7          	jalr	-204(ra) # 553c <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     610:	862a                	mv	a2,a0
     612:	85ce                	mv	a1,s3
     614:	00006517          	auipc	a0,0x6
     618:	a4450513          	addi	a0,a0,-1468 # 6058 <malloc+0x6e4>
     61c:	00005097          	auipc	ra,0x5
     620:	298080e7          	jalr	664(ra) # 58b4 <printf>
      exit(1);
     624:	4505                	li	a0,1
     626:	00005097          	auipc	ra,0x5
     62a:	f16080e7          	jalr	-234(ra) # 553c <exit>

000000000000062e <truncate1>:
{
     62e:	711d                	addi	sp,sp,-96
     630:	ec86                	sd	ra,88(sp)
     632:	e8a2                	sd	s0,80(sp)
     634:	e4a6                	sd	s1,72(sp)
     636:	e0ca                	sd	s2,64(sp)
     638:	fc4e                	sd	s3,56(sp)
     63a:	f852                	sd	s4,48(sp)
     63c:	f456                	sd	s5,40(sp)
     63e:	1080                	addi	s0,sp,96
     640:	8aaa                	mv	s5,a0
  unlink("truncfile");
     642:	00006517          	auipc	a0,0x6
     646:	85e50513          	addi	a0,a0,-1954 # 5ea0 <malloc+0x52c>
     64a:	00005097          	auipc	ra,0x5
     64e:	f42080e7          	jalr	-190(ra) # 558c <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     652:	60100593          	li	a1,1537
     656:	00006517          	auipc	a0,0x6
     65a:	84a50513          	addi	a0,a0,-1974 # 5ea0 <malloc+0x52c>
     65e:	00005097          	auipc	ra,0x5
     662:	f1e080e7          	jalr	-226(ra) # 557c <open>
     666:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     668:	4611                	li	a2,4
     66a:	00006597          	auipc	a1,0x6
     66e:	84658593          	addi	a1,a1,-1978 # 5eb0 <malloc+0x53c>
     672:	00005097          	auipc	ra,0x5
     676:	eea080e7          	jalr	-278(ra) # 555c <write>
  close(fd1);
     67a:	8526                	mv	a0,s1
     67c:	00005097          	auipc	ra,0x5
     680:	ee8080e7          	jalr	-280(ra) # 5564 <close>
  int fd2 = open("truncfile", O_RDONLY);
     684:	4581                	li	a1,0
     686:	00006517          	auipc	a0,0x6
     68a:	81a50513          	addi	a0,a0,-2022 # 5ea0 <malloc+0x52c>
     68e:	00005097          	auipc	ra,0x5
     692:	eee080e7          	jalr	-274(ra) # 557c <open>
     696:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     698:	02000613          	li	a2,32
     69c:	fa040593          	addi	a1,s0,-96
     6a0:	00005097          	auipc	ra,0x5
     6a4:	eb4080e7          	jalr	-332(ra) # 5554 <read>
  if(n != 4){
     6a8:	4791                	li	a5,4
     6aa:	0cf51e63          	bne	a0,a5,786 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     6ae:	40100593          	li	a1,1025
     6b2:	00005517          	auipc	a0,0x5
     6b6:	7ee50513          	addi	a0,a0,2030 # 5ea0 <malloc+0x52c>
     6ba:	00005097          	auipc	ra,0x5
     6be:	ec2080e7          	jalr	-318(ra) # 557c <open>
     6c2:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6c4:	4581                	li	a1,0
     6c6:	00005517          	auipc	a0,0x5
     6ca:	7da50513          	addi	a0,a0,2010 # 5ea0 <malloc+0x52c>
     6ce:	00005097          	auipc	ra,0x5
     6d2:	eae080e7          	jalr	-338(ra) # 557c <open>
     6d6:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6d8:	02000613          	li	a2,32
     6dc:	fa040593          	addi	a1,s0,-96
     6e0:	00005097          	auipc	ra,0x5
     6e4:	e74080e7          	jalr	-396(ra) # 5554 <read>
     6e8:	8a2a                	mv	s4,a0
  if(n != 0){
     6ea:	ed4d                	bnez	a0,7a4 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6ec:	02000613          	li	a2,32
     6f0:	fa040593          	addi	a1,s0,-96
     6f4:	8526                	mv	a0,s1
     6f6:	00005097          	auipc	ra,0x5
     6fa:	e5e080e7          	jalr	-418(ra) # 5554 <read>
     6fe:	8a2a                	mv	s4,a0
  if(n != 0){
     700:	e971                	bnez	a0,7d4 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     702:	4619                	li	a2,6
     704:	00006597          	auipc	a1,0x6
     708:	9e458593          	addi	a1,a1,-1564 # 60e8 <malloc+0x774>
     70c:	854e                	mv	a0,s3
     70e:	00005097          	auipc	ra,0x5
     712:	e4e080e7          	jalr	-434(ra) # 555c <write>
  n = read(fd3, buf, sizeof(buf));
     716:	02000613          	li	a2,32
     71a:	fa040593          	addi	a1,s0,-96
     71e:	854a                	mv	a0,s2
     720:	00005097          	auipc	ra,0x5
     724:	e34080e7          	jalr	-460(ra) # 5554 <read>
  if(n != 6){
     728:	4799                	li	a5,6
     72a:	0cf51d63          	bne	a0,a5,804 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     72e:	02000613          	li	a2,32
     732:	fa040593          	addi	a1,s0,-96
     736:	8526                	mv	a0,s1
     738:	00005097          	auipc	ra,0x5
     73c:	e1c080e7          	jalr	-484(ra) # 5554 <read>
  if(n != 2){
     740:	4789                	li	a5,2
     742:	0ef51063          	bne	a0,a5,822 <truncate1+0x1f4>
  unlink("truncfile");
     746:	00005517          	auipc	a0,0x5
     74a:	75a50513          	addi	a0,a0,1882 # 5ea0 <malloc+0x52c>
     74e:	00005097          	auipc	ra,0x5
     752:	e3e080e7          	jalr	-450(ra) # 558c <unlink>
  close(fd1);
     756:	854e                	mv	a0,s3
     758:	00005097          	auipc	ra,0x5
     75c:	e0c080e7          	jalr	-500(ra) # 5564 <close>
  close(fd2);
     760:	8526                	mv	a0,s1
     762:	00005097          	auipc	ra,0x5
     766:	e02080e7          	jalr	-510(ra) # 5564 <close>
  close(fd3);
     76a:	854a                	mv	a0,s2
     76c:	00005097          	auipc	ra,0x5
     770:	df8080e7          	jalr	-520(ra) # 5564 <close>
}
     774:	60e6                	ld	ra,88(sp)
     776:	6446                	ld	s0,80(sp)
     778:	64a6                	ld	s1,72(sp)
     77a:	6906                	ld	s2,64(sp)
     77c:	79e2                	ld	s3,56(sp)
     77e:	7a42                	ld	s4,48(sp)
     780:	7aa2                	ld	s5,40(sp)
     782:	6125                	addi	sp,sp,96
     784:	8082                	ret
    printf("%s: read %d bytes, wanted 4\n", s, n);
     786:	862a                	mv	a2,a0
     788:	85d6                	mv	a1,s5
     78a:	00006517          	auipc	a0,0x6
     78e:	8fe50513          	addi	a0,a0,-1794 # 6088 <malloc+0x714>
     792:	00005097          	auipc	ra,0x5
     796:	122080e7          	jalr	290(ra) # 58b4 <printf>
    exit(1);
     79a:	4505                	li	a0,1
     79c:	00005097          	auipc	ra,0x5
     7a0:	da0080e7          	jalr	-608(ra) # 553c <exit>
    printf("aaa fd3=%d\n", fd3);
     7a4:	85ca                	mv	a1,s2
     7a6:	00006517          	auipc	a0,0x6
     7aa:	90250513          	addi	a0,a0,-1790 # 60a8 <malloc+0x734>
     7ae:	00005097          	auipc	ra,0x5
     7b2:	106080e7          	jalr	262(ra) # 58b4 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7b6:	8652                	mv	a2,s4
     7b8:	85d6                	mv	a1,s5
     7ba:	00006517          	auipc	a0,0x6
     7be:	8fe50513          	addi	a0,a0,-1794 # 60b8 <malloc+0x744>
     7c2:	00005097          	auipc	ra,0x5
     7c6:	0f2080e7          	jalr	242(ra) # 58b4 <printf>
    exit(1);
     7ca:	4505                	li	a0,1
     7cc:	00005097          	auipc	ra,0x5
     7d0:	d70080e7          	jalr	-656(ra) # 553c <exit>
    printf("bbb fd2=%d\n", fd2);
     7d4:	85a6                	mv	a1,s1
     7d6:	00006517          	auipc	a0,0x6
     7da:	90250513          	addi	a0,a0,-1790 # 60d8 <malloc+0x764>
     7de:	00005097          	auipc	ra,0x5
     7e2:	0d6080e7          	jalr	214(ra) # 58b4 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7e6:	8652                	mv	a2,s4
     7e8:	85d6                	mv	a1,s5
     7ea:	00006517          	auipc	a0,0x6
     7ee:	8ce50513          	addi	a0,a0,-1842 # 60b8 <malloc+0x744>
     7f2:	00005097          	auipc	ra,0x5
     7f6:	0c2080e7          	jalr	194(ra) # 58b4 <printf>
    exit(1);
     7fa:	4505                	li	a0,1
     7fc:	00005097          	auipc	ra,0x5
     800:	d40080e7          	jalr	-704(ra) # 553c <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     804:	862a                	mv	a2,a0
     806:	85d6                	mv	a1,s5
     808:	00006517          	auipc	a0,0x6
     80c:	8e850513          	addi	a0,a0,-1816 # 60f0 <malloc+0x77c>
     810:	00005097          	auipc	ra,0x5
     814:	0a4080e7          	jalr	164(ra) # 58b4 <printf>
    exit(1);
     818:	4505                	li	a0,1
     81a:	00005097          	auipc	ra,0x5
     81e:	d22080e7          	jalr	-734(ra) # 553c <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     822:	862a                	mv	a2,a0
     824:	85d6                	mv	a1,s5
     826:	00006517          	auipc	a0,0x6
     82a:	8ea50513          	addi	a0,a0,-1814 # 6110 <malloc+0x79c>
     82e:	00005097          	auipc	ra,0x5
     832:	086080e7          	jalr	134(ra) # 58b4 <printf>
    exit(1);
     836:	4505                	li	a0,1
     838:	00005097          	auipc	ra,0x5
     83c:	d04080e7          	jalr	-764(ra) # 553c <exit>

0000000000000840 <writetest>:
{
     840:	7139                	addi	sp,sp,-64
     842:	fc06                	sd	ra,56(sp)
     844:	f822                	sd	s0,48(sp)
     846:	f426                	sd	s1,40(sp)
     848:	f04a                	sd	s2,32(sp)
     84a:	ec4e                	sd	s3,24(sp)
     84c:	e852                	sd	s4,16(sp)
     84e:	e456                	sd	s5,8(sp)
     850:	e05a                	sd	s6,0(sp)
     852:	0080                	addi	s0,sp,64
     854:	8b2a                	mv	s6,a0
  fd = open("small", O_CREATE|O_RDWR);
     856:	20200593          	li	a1,514
     85a:	00006517          	auipc	a0,0x6
     85e:	8d650513          	addi	a0,a0,-1834 # 6130 <malloc+0x7bc>
     862:	00005097          	auipc	ra,0x5
     866:	d1a080e7          	jalr	-742(ra) # 557c <open>
  if(fd < 0){
     86a:	0a054d63          	bltz	a0,924 <writetest+0xe4>
     86e:	892a                	mv	s2,a0
     870:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     872:	00006997          	auipc	s3,0x6
     876:	8e698993          	addi	s3,s3,-1818 # 6158 <malloc+0x7e4>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     87a:	00006a97          	auipc	s5,0x6
     87e:	916a8a93          	addi	s5,s5,-1770 # 6190 <malloc+0x81c>
  for(i = 0; i < N; i++){
     882:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     886:	4629                	li	a2,10
     888:	85ce                	mv	a1,s3
     88a:	854a                	mv	a0,s2
     88c:	00005097          	auipc	ra,0x5
     890:	cd0080e7          	jalr	-816(ra) # 555c <write>
     894:	47a9                	li	a5,10
     896:	0af51563          	bne	a0,a5,940 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     89a:	4629                	li	a2,10
     89c:	85d6                	mv	a1,s5
     89e:	854a                	mv	a0,s2
     8a0:	00005097          	auipc	ra,0x5
     8a4:	cbc080e7          	jalr	-836(ra) # 555c <write>
     8a8:	47a9                	li	a5,10
     8aa:	0af51963          	bne	a0,a5,95c <writetest+0x11c>
  for(i = 0; i < N; i++){
     8ae:	2485                	addiw	s1,s1,1
     8b0:	fd449be3          	bne	s1,s4,886 <writetest+0x46>
  close(fd);
     8b4:	854a                	mv	a0,s2
     8b6:	00005097          	auipc	ra,0x5
     8ba:	cae080e7          	jalr	-850(ra) # 5564 <close>
  fd = open("small", O_RDONLY);
     8be:	4581                	li	a1,0
     8c0:	00006517          	auipc	a0,0x6
     8c4:	87050513          	addi	a0,a0,-1936 # 6130 <malloc+0x7bc>
     8c8:	00005097          	auipc	ra,0x5
     8cc:	cb4080e7          	jalr	-844(ra) # 557c <open>
     8d0:	84aa                	mv	s1,a0
  if(fd < 0){
     8d2:	0a054363          	bltz	a0,978 <writetest+0x138>
  i = read(fd, buf, N*SZ*2);
     8d6:	7d000613          	li	a2,2000
     8da:	0000b597          	auipc	a1,0xb
     8de:	0e658593          	addi	a1,a1,230 # b9c0 <buf>
     8e2:	00005097          	auipc	ra,0x5
     8e6:	c72080e7          	jalr	-910(ra) # 5554 <read>
  if(i != N*SZ*2){
     8ea:	7d000793          	li	a5,2000
     8ee:	0af51363          	bne	a0,a5,994 <writetest+0x154>
  close(fd);
     8f2:	8526                	mv	a0,s1
     8f4:	00005097          	auipc	ra,0x5
     8f8:	c70080e7          	jalr	-912(ra) # 5564 <close>
  if(unlink("small") < 0){
     8fc:	00006517          	auipc	a0,0x6
     900:	83450513          	addi	a0,a0,-1996 # 6130 <malloc+0x7bc>
     904:	00005097          	auipc	ra,0x5
     908:	c88080e7          	jalr	-888(ra) # 558c <unlink>
     90c:	0a054263          	bltz	a0,9b0 <writetest+0x170>
}
     910:	70e2                	ld	ra,56(sp)
     912:	7442                	ld	s0,48(sp)
     914:	74a2                	ld	s1,40(sp)
     916:	7902                	ld	s2,32(sp)
     918:	69e2                	ld	s3,24(sp)
     91a:	6a42                	ld	s4,16(sp)
     91c:	6aa2                	ld	s5,8(sp)
     91e:	6b02                	ld	s6,0(sp)
     920:	6121                	addi	sp,sp,64
     922:	8082                	ret
    printf("%s: error: creat small failed!\n", s);
     924:	85da                	mv	a1,s6
     926:	00006517          	auipc	a0,0x6
     92a:	81250513          	addi	a0,a0,-2030 # 6138 <malloc+0x7c4>
     92e:	00005097          	auipc	ra,0x5
     932:	f86080e7          	jalr	-122(ra) # 58b4 <printf>
    exit(1);
     936:	4505                	li	a0,1
     938:	00005097          	auipc	ra,0x5
     93c:	c04080e7          	jalr	-1020(ra) # 553c <exit>
      printf("%s: error: write aa %d new file failed\n", i);
     940:	85a6                	mv	a1,s1
     942:	00006517          	auipc	a0,0x6
     946:	82650513          	addi	a0,a0,-2010 # 6168 <malloc+0x7f4>
     94a:	00005097          	auipc	ra,0x5
     94e:	f6a080e7          	jalr	-150(ra) # 58b4 <printf>
      exit(1);
     952:	4505                	li	a0,1
     954:	00005097          	auipc	ra,0x5
     958:	be8080e7          	jalr	-1048(ra) # 553c <exit>
      printf("%s: error: write bb %d new file failed\n", i);
     95c:	85a6                	mv	a1,s1
     95e:	00006517          	auipc	a0,0x6
     962:	84250513          	addi	a0,a0,-1982 # 61a0 <malloc+0x82c>
     966:	00005097          	auipc	ra,0x5
     96a:	f4e080e7          	jalr	-178(ra) # 58b4 <printf>
      exit(1);
     96e:	4505                	li	a0,1
     970:	00005097          	auipc	ra,0x5
     974:	bcc080e7          	jalr	-1076(ra) # 553c <exit>
    printf("%s: error: open small failed!\n", s);
     978:	85da                	mv	a1,s6
     97a:	00006517          	auipc	a0,0x6
     97e:	84e50513          	addi	a0,a0,-1970 # 61c8 <malloc+0x854>
     982:	00005097          	auipc	ra,0x5
     986:	f32080e7          	jalr	-206(ra) # 58b4 <printf>
    exit(1);
     98a:	4505                	li	a0,1
     98c:	00005097          	auipc	ra,0x5
     990:	bb0080e7          	jalr	-1104(ra) # 553c <exit>
    printf("%s: read failed\n", s);
     994:	85da                	mv	a1,s6
     996:	00006517          	auipc	a0,0x6
     99a:	85250513          	addi	a0,a0,-1966 # 61e8 <malloc+0x874>
     99e:	00005097          	auipc	ra,0x5
     9a2:	f16080e7          	jalr	-234(ra) # 58b4 <printf>
    exit(1);
     9a6:	4505                	li	a0,1
     9a8:	00005097          	auipc	ra,0x5
     9ac:	b94080e7          	jalr	-1132(ra) # 553c <exit>
    printf("%s: unlink small failed\n", s);
     9b0:	85da                	mv	a1,s6
     9b2:	00006517          	auipc	a0,0x6
     9b6:	84e50513          	addi	a0,a0,-1970 # 6200 <malloc+0x88c>
     9ba:	00005097          	auipc	ra,0x5
     9be:	efa080e7          	jalr	-262(ra) # 58b4 <printf>
    exit(1);
     9c2:	4505                	li	a0,1
     9c4:	00005097          	auipc	ra,0x5
     9c8:	b78080e7          	jalr	-1160(ra) # 553c <exit>

00000000000009cc <writebig>:
{
     9cc:	7139                	addi	sp,sp,-64
     9ce:	fc06                	sd	ra,56(sp)
     9d0:	f822                	sd	s0,48(sp)
     9d2:	f426                	sd	s1,40(sp)
     9d4:	f04a                	sd	s2,32(sp)
     9d6:	ec4e                	sd	s3,24(sp)
     9d8:	e852                	sd	s4,16(sp)
     9da:	e456                	sd	s5,8(sp)
     9dc:	0080                	addi	s0,sp,64
     9de:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9e0:	20200593          	li	a1,514
     9e4:	00006517          	auipc	a0,0x6
     9e8:	83c50513          	addi	a0,a0,-1988 # 6220 <malloc+0x8ac>
     9ec:	00005097          	auipc	ra,0x5
     9f0:	b90080e7          	jalr	-1136(ra) # 557c <open>
     9f4:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9f6:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9f8:	0000b917          	auipc	s2,0xb
     9fc:	fc890913          	addi	s2,s2,-56 # b9c0 <buf>
  for(i = 0; i < MAXFILE; i++){
     a00:	10c00a13          	li	s4,268
  if(fd < 0){
     a04:	06054c63          	bltz	a0,a7c <writebig+0xb0>
    ((int*)buf)[0] = i;
     a08:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     a0c:	40000613          	li	a2,1024
     a10:	85ca                	mv	a1,s2
     a12:	854e                	mv	a0,s3
     a14:	00005097          	auipc	ra,0x5
     a18:	b48080e7          	jalr	-1208(ra) # 555c <write>
     a1c:	40000793          	li	a5,1024
     a20:	06f51c63          	bne	a0,a5,a98 <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a24:	2485                	addiw	s1,s1,1
     a26:	ff4491e3          	bne	s1,s4,a08 <writebig+0x3c>
  close(fd);
     a2a:	854e                	mv	a0,s3
     a2c:	00005097          	auipc	ra,0x5
     a30:	b38080e7          	jalr	-1224(ra) # 5564 <close>
  fd = open("big", O_RDONLY);
     a34:	4581                	li	a1,0
     a36:	00005517          	auipc	a0,0x5
     a3a:	7ea50513          	addi	a0,a0,2026 # 6220 <malloc+0x8ac>
     a3e:	00005097          	auipc	ra,0x5
     a42:	b3e080e7          	jalr	-1218(ra) # 557c <open>
     a46:	89aa                	mv	s3,a0
  n = 0;
     a48:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a4a:	0000b917          	auipc	s2,0xb
     a4e:	f7690913          	addi	s2,s2,-138 # b9c0 <buf>
  if(fd < 0){
     a52:	06054163          	bltz	a0,ab4 <writebig+0xe8>
    i = read(fd, buf, BSIZE);
     a56:	40000613          	li	a2,1024
     a5a:	85ca                	mv	a1,s2
     a5c:	854e                	mv	a0,s3
     a5e:	00005097          	auipc	ra,0x5
     a62:	af6080e7          	jalr	-1290(ra) # 5554 <read>
    if(i == 0){
     a66:	c52d                	beqz	a0,ad0 <writebig+0x104>
    } else if(i != BSIZE){
     a68:	40000793          	li	a5,1024
     a6c:	0af51d63          	bne	a0,a5,b26 <writebig+0x15a>
    if(((int*)buf)[0] != n){
     a70:	00092603          	lw	a2,0(s2)
     a74:	0c961763          	bne	a2,s1,b42 <writebig+0x176>
    n++;
     a78:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a7a:	bff1                	j	a56 <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a7c:	85d6                	mv	a1,s5
     a7e:	00005517          	auipc	a0,0x5
     a82:	7aa50513          	addi	a0,a0,1962 # 6228 <malloc+0x8b4>
     a86:	00005097          	auipc	ra,0x5
     a8a:	e2e080e7          	jalr	-466(ra) # 58b4 <printf>
    exit(1);
     a8e:	4505                	li	a0,1
     a90:	00005097          	auipc	ra,0x5
     a94:	aac080e7          	jalr	-1364(ra) # 553c <exit>
      printf("%s: error: write big file failed\n", i);
     a98:	85a6                	mv	a1,s1
     a9a:	00005517          	auipc	a0,0x5
     a9e:	7ae50513          	addi	a0,a0,1966 # 6248 <malloc+0x8d4>
     aa2:	00005097          	auipc	ra,0x5
     aa6:	e12080e7          	jalr	-494(ra) # 58b4 <printf>
      exit(1);
     aaa:	4505                	li	a0,1
     aac:	00005097          	auipc	ra,0x5
     ab0:	a90080e7          	jalr	-1392(ra) # 553c <exit>
    printf("%s: error: open big failed!\n", s);
     ab4:	85d6                	mv	a1,s5
     ab6:	00005517          	auipc	a0,0x5
     aba:	7ba50513          	addi	a0,a0,1978 # 6270 <malloc+0x8fc>
     abe:	00005097          	auipc	ra,0x5
     ac2:	df6080e7          	jalr	-522(ra) # 58b4 <printf>
    exit(1);
     ac6:	4505                	li	a0,1
     ac8:	00005097          	auipc	ra,0x5
     acc:	a74080e7          	jalr	-1420(ra) # 553c <exit>
      if(n == MAXFILE - 1){
     ad0:	10b00793          	li	a5,267
     ad4:	02f48a63          	beq	s1,a5,b08 <writebig+0x13c>
  close(fd);
     ad8:	854e                	mv	a0,s3
     ada:	00005097          	auipc	ra,0x5
     ade:	a8a080e7          	jalr	-1398(ra) # 5564 <close>
  if(unlink("big") < 0){
     ae2:	00005517          	auipc	a0,0x5
     ae6:	73e50513          	addi	a0,a0,1854 # 6220 <malloc+0x8ac>
     aea:	00005097          	auipc	ra,0x5
     aee:	aa2080e7          	jalr	-1374(ra) # 558c <unlink>
     af2:	06054663          	bltz	a0,b5e <writebig+0x192>
}
     af6:	70e2                	ld	ra,56(sp)
     af8:	7442                	ld	s0,48(sp)
     afa:	74a2                	ld	s1,40(sp)
     afc:	7902                	ld	s2,32(sp)
     afe:	69e2                	ld	s3,24(sp)
     b00:	6a42                	ld	s4,16(sp)
     b02:	6aa2                	ld	s5,8(sp)
     b04:	6121                	addi	sp,sp,64
     b06:	8082                	ret
        printf("%s: read only %d blocks from big", n);
     b08:	10b00593          	li	a1,267
     b0c:	00005517          	auipc	a0,0x5
     b10:	78450513          	addi	a0,a0,1924 # 6290 <malloc+0x91c>
     b14:	00005097          	auipc	ra,0x5
     b18:	da0080e7          	jalr	-608(ra) # 58b4 <printf>
        exit(1);
     b1c:	4505                	li	a0,1
     b1e:	00005097          	auipc	ra,0x5
     b22:	a1e080e7          	jalr	-1506(ra) # 553c <exit>
      printf("%s: read failed %d\n", i);
     b26:	85aa                	mv	a1,a0
     b28:	00005517          	auipc	a0,0x5
     b2c:	79050513          	addi	a0,a0,1936 # 62b8 <malloc+0x944>
     b30:	00005097          	auipc	ra,0x5
     b34:	d84080e7          	jalr	-636(ra) # 58b4 <printf>
      exit(1);
     b38:	4505                	li	a0,1
     b3a:	00005097          	auipc	ra,0x5
     b3e:	a02080e7          	jalr	-1534(ra) # 553c <exit>
      printf("%s: read content of block %d is %d\n",
     b42:	85a6                	mv	a1,s1
     b44:	00005517          	auipc	a0,0x5
     b48:	78c50513          	addi	a0,a0,1932 # 62d0 <malloc+0x95c>
     b4c:	00005097          	auipc	ra,0x5
     b50:	d68080e7          	jalr	-664(ra) # 58b4 <printf>
      exit(1);
     b54:	4505                	li	a0,1
     b56:	00005097          	auipc	ra,0x5
     b5a:	9e6080e7          	jalr	-1562(ra) # 553c <exit>
    printf("%s: unlink big failed\n", s);
     b5e:	85d6                	mv	a1,s5
     b60:	00005517          	auipc	a0,0x5
     b64:	79850513          	addi	a0,a0,1944 # 62f8 <malloc+0x984>
     b68:	00005097          	auipc	ra,0x5
     b6c:	d4c080e7          	jalr	-692(ra) # 58b4 <printf>
    exit(1);
     b70:	4505                	li	a0,1
     b72:	00005097          	auipc	ra,0x5
     b76:	9ca080e7          	jalr	-1590(ra) # 553c <exit>

0000000000000b7a <unlinkread>:
{
     b7a:	7179                	addi	sp,sp,-48
     b7c:	f406                	sd	ra,40(sp)
     b7e:	f022                	sd	s0,32(sp)
     b80:	ec26                	sd	s1,24(sp)
     b82:	e84a                	sd	s2,16(sp)
     b84:	e44e                	sd	s3,8(sp)
     b86:	1800                	addi	s0,sp,48
     b88:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b8a:	20200593          	li	a1,514
     b8e:	00005517          	auipc	a0,0x5
     b92:	78250513          	addi	a0,a0,1922 # 6310 <malloc+0x99c>
     b96:	00005097          	auipc	ra,0x5
     b9a:	9e6080e7          	jalr	-1562(ra) # 557c <open>
  if(fd < 0){
     b9e:	0e054563          	bltz	a0,c88 <unlinkread+0x10e>
     ba2:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     ba4:	4615                	li	a2,5
     ba6:	00005597          	auipc	a1,0x5
     baa:	79a58593          	addi	a1,a1,1946 # 6340 <malloc+0x9cc>
     bae:	00005097          	auipc	ra,0x5
     bb2:	9ae080e7          	jalr	-1618(ra) # 555c <write>
  close(fd);
     bb6:	8526                	mv	a0,s1
     bb8:	00005097          	auipc	ra,0x5
     bbc:	9ac080e7          	jalr	-1620(ra) # 5564 <close>
  fd = open("unlinkread", O_RDWR);
     bc0:	4589                	li	a1,2
     bc2:	00005517          	auipc	a0,0x5
     bc6:	74e50513          	addi	a0,a0,1870 # 6310 <malloc+0x99c>
     bca:	00005097          	auipc	ra,0x5
     bce:	9b2080e7          	jalr	-1614(ra) # 557c <open>
     bd2:	84aa                	mv	s1,a0
  if(fd < 0){
     bd4:	0c054863          	bltz	a0,ca4 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     bd8:	00005517          	auipc	a0,0x5
     bdc:	73850513          	addi	a0,a0,1848 # 6310 <malloc+0x99c>
     be0:	00005097          	auipc	ra,0x5
     be4:	9ac080e7          	jalr	-1620(ra) # 558c <unlink>
     be8:	ed61                	bnez	a0,cc0 <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bea:	20200593          	li	a1,514
     bee:	00005517          	auipc	a0,0x5
     bf2:	72250513          	addi	a0,a0,1826 # 6310 <malloc+0x99c>
     bf6:	00005097          	auipc	ra,0x5
     bfa:	986080e7          	jalr	-1658(ra) # 557c <open>
     bfe:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     c00:	460d                	li	a2,3
     c02:	00005597          	auipc	a1,0x5
     c06:	78658593          	addi	a1,a1,1926 # 6388 <malloc+0xa14>
     c0a:	00005097          	auipc	ra,0x5
     c0e:	952080e7          	jalr	-1710(ra) # 555c <write>
  close(fd1);
     c12:	854a                	mv	a0,s2
     c14:	00005097          	auipc	ra,0x5
     c18:	950080e7          	jalr	-1712(ra) # 5564 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c1c:	660d                	lui	a2,0x3
     c1e:	0000b597          	auipc	a1,0xb
     c22:	da258593          	addi	a1,a1,-606 # b9c0 <buf>
     c26:	8526                	mv	a0,s1
     c28:	00005097          	auipc	ra,0x5
     c2c:	92c080e7          	jalr	-1748(ra) # 5554 <read>
     c30:	4795                	li	a5,5
     c32:	0af51563          	bne	a0,a5,cdc <unlinkread+0x162>
  if(buf[0] != 'h'){
     c36:	0000b717          	auipc	a4,0xb
     c3a:	d8a74703          	lbu	a4,-630(a4) # b9c0 <buf>
     c3e:	06800793          	li	a5,104
     c42:	0af71b63          	bne	a4,a5,cf8 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c46:	4629                	li	a2,10
     c48:	0000b597          	auipc	a1,0xb
     c4c:	d7858593          	addi	a1,a1,-648 # b9c0 <buf>
     c50:	8526                	mv	a0,s1
     c52:	00005097          	auipc	ra,0x5
     c56:	90a080e7          	jalr	-1782(ra) # 555c <write>
     c5a:	47a9                	li	a5,10
     c5c:	0af51c63          	bne	a0,a5,d14 <unlinkread+0x19a>
  close(fd);
     c60:	8526                	mv	a0,s1
     c62:	00005097          	auipc	ra,0x5
     c66:	902080e7          	jalr	-1790(ra) # 5564 <close>
  unlink("unlinkread");
     c6a:	00005517          	auipc	a0,0x5
     c6e:	6a650513          	addi	a0,a0,1702 # 6310 <malloc+0x99c>
     c72:	00005097          	auipc	ra,0x5
     c76:	91a080e7          	jalr	-1766(ra) # 558c <unlink>
}
     c7a:	70a2                	ld	ra,40(sp)
     c7c:	7402                	ld	s0,32(sp)
     c7e:	64e2                	ld	s1,24(sp)
     c80:	6942                	ld	s2,16(sp)
     c82:	69a2                	ld	s3,8(sp)
     c84:	6145                	addi	sp,sp,48
     c86:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c88:	85ce                	mv	a1,s3
     c8a:	00005517          	auipc	a0,0x5
     c8e:	69650513          	addi	a0,a0,1686 # 6320 <malloc+0x9ac>
     c92:	00005097          	auipc	ra,0x5
     c96:	c22080e7          	jalr	-990(ra) # 58b4 <printf>
    exit(1);
     c9a:	4505                	li	a0,1
     c9c:	00005097          	auipc	ra,0x5
     ca0:	8a0080e7          	jalr	-1888(ra) # 553c <exit>
    printf("%s: open unlinkread failed\n", s);
     ca4:	85ce                	mv	a1,s3
     ca6:	00005517          	auipc	a0,0x5
     caa:	6a250513          	addi	a0,a0,1698 # 6348 <malloc+0x9d4>
     cae:	00005097          	auipc	ra,0x5
     cb2:	c06080e7          	jalr	-1018(ra) # 58b4 <printf>
    exit(1);
     cb6:	4505                	li	a0,1
     cb8:	00005097          	auipc	ra,0x5
     cbc:	884080e7          	jalr	-1916(ra) # 553c <exit>
    printf("%s: unlink unlinkread failed\n", s);
     cc0:	85ce                	mv	a1,s3
     cc2:	00005517          	auipc	a0,0x5
     cc6:	6a650513          	addi	a0,a0,1702 # 6368 <malloc+0x9f4>
     cca:	00005097          	auipc	ra,0x5
     cce:	bea080e7          	jalr	-1046(ra) # 58b4 <printf>
    exit(1);
     cd2:	4505                	li	a0,1
     cd4:	00005097          	auipc	ra,0x5
     cd8:	868080e7          	jalr	-1944(ra) # 553c <exit>
    printf("%s: unlinkread read failed", s);
     cdc:	85ce                	mv	a1,s3
     cde:	00005517          	auipc	a0,0x5
     ce2:	6b250513          	addi	a0,a0,1714 # 6390 <malloc+0xa1c>
     ce6:	00005097          	auipc	ra,0x5
     cea:	bce080e7          	jalr	-1074(ra) # 58b4 <printf>
    exit(1);
     cee:	4505                	li	a0,1
     cf0:	00005097          	auipc	ra,0x5
     cf4:	84c080e7          	jalr	-1972(ra) # 553c <exit>
    printf("%s: unlinkread wrong data\n", s);
     cf8:	85ce                	mv	a1,s3
     cfa:	00005517          	auipc	a0,0x5
     cfe:	6b650513          	addi	a0,a0,1718 # 63b0 <malloc+0xa3c>
     d02:	00005097          	auipc	ra,0x5
     d06:	bb2080e7          	jalr	-1102(ra) # 58b4 <printf>
    exit(1);
     d0a:	4505                	li	a0,1
     d0c:	00005097          	auipc	ra,0x5
     d10:	830080e7          	jalr	-2000(ra) # 553c <exit>
    printf("%s: unlinkread write failed\n", s);
     d14:	85ce                	mv	a1,s3
     d16:	00005517          	auipc	a0,0x5
     d1a:	6ba50513          	addi	a0,a0,1722 # 63d0 <malloc+0xa5c>
     d1e:	00005097          	auipc	ra,0x5
     d22:	b96080e7          	jalr	-1130(ra) # 58b4 <printf>
    exit(1);
     d26:	4505                	li	a0,1
     d28:	00005097          	auipc	ra,0x5
     d2c:	814080e7          	jalr	-2028(ra) # 553c <exit>

0000000000000d30 <linktest>:
{
     d30:	1101                	addi	sp,sp,-32
     d32:	ec06                	sd	ra,24(sp)
     d34:	e822                	sd	s0,16(sp)
     d36:	e426                	sd	s1,8(sp)
     d38:	e04a                	sd	s2,0(sp)
     d3a:	1000                	addi	s0,sp,32
     d3c:	892a                	mv	s2,a0
  unlink("lf1");
     d3e:	00005517          	auipc	a0,0x5
     d42:	6b250513          	addi	a0,a0,1714 # 63f0 <malloc+0xa7c>
     d46:	00005097          	auipc	ra,0x5
     d4a:	846080e7          	jalr	-1978(ra) # 558c <unlink>
  unlink("lf2");
     d4e:	00005517          	auipc	a0,0x5
     d52:	6aa50513          	addi	a0,a0,1706 # 63f8 <malloc+0xa84>
     d56:	00005097          	auipc	ra,0x5
     d5a:	836080e7          	jalr	-1994(ra) # 558c <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d5e:	20200593          	li	a1,514
     d62:	00005517          	auipc	a0,0x5
     d66:	68e50513          	addi	a0,a0,1678 # 63f0 <malloc+0xa7c>
     d6a:	00005097          	auipc	ra,0x5
     d6e:	812080e7          	jalr	-2030(ra) # 557c <open>
  if(fd < 0){
     d72:	10054763          	bltz	a0,e80 <linktest+0x150>
     d76:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d78:	4615                	li	a2,5
     d7a:	00005597          	auipc	a1,0x5
     d7e:	5c658593          	addi	a1,a1,1478 # 6340 <malloc+0x9cc>
     d82:	00004097          	auipc	ra,0x4
     d86:	7da080e7          	jalr	2010(ra) # 555c <write>
     d8a:	4795                	li	a5,5
     d8c:	10f51863          	bne	a0,a5,e9c <linktest+0x16c>
  close(fd);
     d90:	8526                	mv	a0,s1
     d92:	00004097          	auipc	ra,0x4
     d96:	7d2080e7          	jalr	2002(ra) # 5564 <close>
  if(link("lf1", "lf2") < 0){
     d9a:	00005597          	auipc	a1,0x5
     d9e:	65e58593          	addi	a1,a1,1630 # 63f8 <malloc+0xa84>
     da2:	00005517          	auipc	a0,0x5
     da6:	64e50513          	addi	a0,a0,1614 # 63f0 <malloc+0xa7c>
     daa:	00004097          	auipc	ra,0x4
     dae:	7f2080e7          	jalr	2034(ra) # 559c <link>
     db2:	10054363          	bltz	a0,eb8 <linktest+0x188>
  unlink("lf1");
     db6:	00005517          	auipc	a0,0x5
     dba:	63a50513          	addi	a0,a0,1594 # 63f0 <malloc+0xa7c>
     dbe:	00004097          	auipc	ra,0x4
     dc2:	7ce080e7          	jalr	1998(ra) # 558c <unlink>
  if(open("lf1", 0) >= 0){
     dc6:	4581                	li	a1,0
     dc8:	00005517          	auipc	a0,0x5
     dcc:	62850513          	addi	a0,a0,1576 # 63f0 <malloc+0xa7c>
     dd0:	00004097          	auipc	ra,0x4
     dd4:	7ac080e7          	jalr	1964(ra) # 557c <open>
     dd8:	0e055e63          	bgez	a0,ed4 <linktest+0x1a4>
  fd = open("lf2", 0);
     ddc:	4581                	li	a1,0
     dde:	00005517          	auipc	a0,0x5
     de2:	61a50513          	addi	a0,a0,1562 # 63f8 <malloc+0xa84>
     de6:	00004097          	auipc	ra,0x4
     dea:	796080e7          	jalr	1942(ra) # 557c <open>
     dee:	84aa                	mv	s1,a0
  if(fd < 0){
     df0:	10054063          	bltz	a0,ef0 <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     df4:	660d                	lui	a2,0x3
     df6:	0000b597          	auipc	a1,0xb
     dfa:	bca58593          	addi	a1,a1,-1078 # b9c0 <buf>
     dfe:	00004097          	auipc	ra,0x4
     e02:	756080e7          	jalr	1878(ra) # 5554 <read>
     e06:	4795                	li	a5,5
     e08:	10f51263          	bne	a0,a5,f0c <linktest+0x1dc>
  close(fd);
     e0c:	8526                	mv	a0,s1
     e0e:	00004097          	auipc	ra,0x4
     e12:	756080e7          	jalr	1878(ra) # 5564 <close>
  if(link("lf2", "lf2") >= 0){
     e16:	00005597          	auipc	a1,0x5
     e1a:	5e258593          	addi	a1,a1,1506 # 63f8 <malloc+0xa84>
     e1e:	852e                	mv	a0,a1
     e20:	00004097          	auipc	ra,0x4
     e24:	77c080e7          	jalr	1916(ra) # 559c <link>
     e28:	10055063          	bgez	a0,f28 <linktest+0x1f8>
  unlink("lf2");
     e2c:	00005517          	auipc	a0,0x5
     e30:	5cc50513          	addi	a0,a0,1484 # 63f8 <malloc+0xa84>
     e34:	00004097          	auipc	ra,0x4
     e38:	758080e7          	jalr	1880(ra) # 558c <unlink>
  if(link("lf2", "lf1") >= 0){
     e3c:	00005597          	auipc	a1,0x5
     e40:	5b458593          	addi	a1,a1,1460 # 63f0 <malloc+0xa7c>
     e44:	00005517          	auipc	a0,0x5
     e48:	5b450513          	addi	a0,a0,1460 # 63f8 <malloc+0xa84>
     e4c:	00004097          	auipc	ra,0x4
     e50:	750080e7          	jalr	1872(ra) # 559c <link>
     e54:	0e055863          	bgez	a0,f44 <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e58:	00005597          	auipc	a1,0x5
     e5c:	59858593          	addi	a1,a1,1432 # 63f0 <malloc+0xa7c>
     e60:	00005517          	auipc	a0,0x5
     e64:	6a050513          	addi	a0,a0,1696 # 6500 <malloc+0xb8c>
     e68:	00004097          	auipc	ra,0x4
     e6c:	734080e7          	jalr	1844(ra) # 559c <link>
     e70:	0e055863          	bgez	a0,f60 <linktest+0x230>
}
     e74:	60e2                	ld	ra,24(sp)
     e76:	6442                	ld	s0,16(sp)
     e78:	64a2                	ld	s1,8(sp)
     e7a:	6902                	ld	s2,0(sp)
     e7c:	6105                	addi	sp,sp,32
     e7e:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e80:	85ca                	mv	a1,s2
     e82:	00005517          	auipc	a0,0x5
     e86:	57e50513          	addi	a0,a0,1406 # 6400 <malloc+0xa8c>
     e8a:	00005097          	auipc	ra,0x5
     e8e:	a2a080e7          	jalr	-1494(ra) # 58b4 <printf>
    exit(1);
     e92:	4505                	li	a0,1
     e94:	00004097          	auipc	ra,0x4
     e98:	6a8080e7          	jalr	1704(ra) # 553c <exit>
    printf("%s: write lf1 failed\n", s);
     e9c:	85ca                	mv	a1,s2
     e9e:	00005517          	auipc	a0,0x5
     ea2:	57a50513          	addi	a0,a0,1402 # 6418 <malloc+0xaa4>
     ea6:	00005097          	auipc	ra,0x5
     eaa:	a0e080e7          	jalr	-1522(ra) # 58b4 <printf>
    exit(1);
     eae:	4505                	li	a0,1
     eb0:	00004097          	auipc	ra,0x4
     eb4:	68c080e7          	jalr	1676(ra) # 553c <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     eb8:	85ca                	mv	a1,s2
     eba:	00005517          	auipc	a0,0x5
     ebe:	57650513          	addi	a0,a0,1398 # 6430 <malloc+0xabc>
     ec2:	00005097          	auipc	ra,0x5
     ec6:	9f2080e7          	jalr	-1550(ra) # 58b4 <printf>
    exit(1);
     eca:	4505                	li	a0,1
     ecc:	00004097          	auipc	ra,0x4
     ed0:	670080e7          	jalr	1648(ra) # 553c <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ed4:	85ca                	mv	a1,s2
     ed6:	00005517          	auipc	a0,0x5
     eda:	57a50513          	addi	a0,a0,1402 # 6450 <malloc+0xadc>
     ede:	00005097          	auipc	ra,0x5
     ee2:	9d6080e7          	jalr	-1578(ra) # 58b4 <printf>
    exit(1);
     ee6:	4505                	li	a0,1
     ee8:	00004097          	auipc	ra,0x4
     eec:	654080e7          	jalr	1620(ra) # 553c <exit>
    printf("%s: open lf2 failed\n", s);
     ef0:	85ca                	mv	a1,s2
     ef2:	00005517          	auipc	a0,0x5
     ef6:	58e50513          	addi	a0,a0,1422 # 6480 <malloc+0xb0c>
     efa:	00005097          	auipc	ra,0x5
     efe:	9ba080e7          	jalr	-1606(ra) # 58b4 <printf>
    exit(1);
     f02:	4505                	li	a0,1
     f04:	00004097          	auipc	ra,0x4
     f08:	638080e7          	jalr	1592(ra) # 553c <exit>
    printf("%s: read lf2 failed\n", s);
     f0c:	85ca                	mv	a1,s2
     f0e:	00005517          	auipc	a0,0x5
     f12:	58a50513          	addi	a0,a0,1418 # 6498 <malloc+0xb24>
     f16:	00005097          	auipc	ra,0x5
     f1a:	99e080e7          	jalr	-1634(ra) # 58b4 <printf>
    exit(1);
     f1e:	4505                	li	a0,1
     f20:	00004097          	auipc	ra,0x4
     f24:	61c080e7          	jalr	1564(ra) # 553c <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f28:	85ca                	mv	a1,s2
     f2a:	00005517          	auipc	a0,0x5
     f2e:	58650513          	addi	a0,a0,1414 # 64b0 <malloc+0xb3c>
     f32:	00005097          	auipc	ra,0x5
     f36:	982080e7          	jalr	-1662(ra) # 58b4 <printf>
    exit(1);
     f3a:	4505                	li	a0,1
     f3c:	00004097          	auipc	ra,0x4
     f40:	600080e7          	jalr	1536(ra) # 553c <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f44:	85ca                	mv	a1,s2
     f46:	00005517          	auipc	a0,0x5
     f4a:	59250513          	addi	a0,a0,1426 # 64d8 <malloc+0xb64>
     f4e:	00005097          	auipc	ra,0x5
     f52:	966080e7          	jalr	-1690(ra) # 58b4 <printf>
    exit(1);
     f56:	4505                	li	a0,1
     f58:	00004097          	auipc	ra,0x4
     f5c:	5e4080e7          	jalr	1508(ra) # 553c <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f60:	85ca                	mv	a1,s2
     f62:	00005517          	auipc	a0,0x5
     f66:	5a650513          	addi	a0,a0,1446 # 6508 <malloc+0xb94>
     f6a:	00005097          	auipc	ra,0x5
     f6e:	94a080e7          	jalr	-1718(ra) # 58b4 <printf>
    exit(1);
     f72:	4505                	li	a0,1
     f74:	00004097          	auipc	ra,0x4
     f78:	5c8080e7          	jalr	1480(ra) # 553c <exit>

0000000000000f7c <bigdir>:
{
     f7c:	715d                	addi	sp,sp,-80
     f7e:	e486                	sd	ra,72(sp)
     f80:	e0a2                	sd	s0,64(sp)
     f82:	fc26                	sd	s1,56(sp)
     f84:	f84a                	sd	s2,48(sp)
     f86:	f44e                	sd	s3,40(sp)
     f88:	f052                	sd	s4,32(sp)
     f8a:	ec56                	sd	s5,24(sp)
     f8c:	e85a                	sd	s6,16(sp)
     f8e:	0880                	addi	s0,sp,80
     f90:	89aa                	mv	s3,a0
  unlink("bd");
     f92:	00005517          	auipc	a0,0x5
     f96:	59650513          	addi	a0,a0,1430 # 6528 <malloc+0xbb4>
     f9a:	00004097          	auipc	ra,0x4
     f9e:	5f2080e7          	jalr	1522(ra) # 558c <unlink>
  fd = open("bd", O_CREATE);
     fa2:	20000593          	li	a1,512
     fa6:	00005517          	auipc	a0,0x5
     faa:	58250513          	addi	a0,a0,1410 # 6528 <malloc+0xbb4>
     fae:	00004097          	auipc	ra,0x4
     fb2:	5ce080e7          	jalr	1486(ra) # 557c <open>
  if(fd < 0){
     fb6:	0c054963          	bltz	a0,1088 <bigdir+0x10c>
  close(fd);
     fba:	00004097          	auipc	ra,0x4
     fbe:	5aa080e7          	jalr	1450(ra) # 5564 <close>
  for(i = 0; i < N; i++){
     fc2:	4901                	li	s2,0
    name[0] = 'x';
     fc4:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fc8:	00005a17          	auipc	s4,0x5
     fcc:	560a0a13          	addi	s4,s4,1376 # 6528 <malloc+0xbb4>
  for(i = 0; i < N; i++){
     fd0:	1f400b13          	li	s6,500
    name[0] = 'x';
     fd4:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fd8:	41f9579b          	sraiw	a5,s2,0x1f
     fdc:	01a7d71b          	srliw	a4,a5,0x1a
     fe0:	012707bb          	addw	a5,a4,s2
     fe4:	4067d69b          	sraiw	a3,a5,0x6
     fe8:	0306869b          	addiw	a3,a3,48
     fec:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     ff0:	03f7f793          	andi	a5,a5,63
     ff4:	9f99                	subw	a5,a5,a4
     ff6:	0307879b          	addiw	a5,a5,48
     ffa:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
     ffe:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    1002:	fb040593          	addi	a1,s0,-80
    1006:	8552                	mv	a0,s4
    1008:	00004097          	auipc	ra,0x4
    100c:	594080e7          	jalr	1428(ra) # 559c <link>
    1010:	84aa                	mv	s1,a0
    1012:	e949                	bnez	a0,10a4 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1014:	2905                	addiw	s2,s2,1
    1016:	fb691fe3          	bne	s2,s6,fd4 <bigdir+0x58>
  unlink("bd");
    101a:	00005517          	auipc	a0,0x5
    101e:	50e50513          	addi	a0,a0,1294 # 6528 <malloc+0xbb4>
    1022:	00004097          	auipc	ra,0x4
    1026:	56a080e7          	jalr	1386(ra) # 558c <unlink>
    name[0] = 'x';
    102a:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    102e:	1f400a13          	li	s4,500
    name[0] = 'x';
    1032:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1036:	41f4d79b          	sraiw	a5,s1,0x1f
    103a:	01a7d71b          	srliw	a4,a5,0x1a
    103e:	009707bb          	addw	a5,a4,s1
    1042:	4067d69b          	sraiw	a3,a5,0x6
    1046:	0306869b          	addiw	a3,a3,48
    104a:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    104e:	03f7f793          	andi	a5,a5,63
    1052:	9f99                	subw	a5,a5,a4
    1054:	0307879b          	addiw	a5,a5,48
    1058:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    105c:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    1060:	fb040513          	addi	a0,s0,-80
    1064:	00004097          	auipc	ra,0x4
    1068:	528080e7          	jalr	1320(ra) # 558c <unlink>
    106c:	ed21                	bnez	a0,10c4 <bigdir+0x148>
  for(i = 0; i < N; i++){
    106e:	2485                	addiw	s1,s1,1
    1070:	fd4491e3          	bne	s1,s4,1032 <bigdir+0xb6>
}
    1074:	60a6                	ld	ra,72(sp)
    1076:	6406                	ld	s0,64(sp)
    1078:	74e2                	ld	s1,56(sp)
    107a:	7942                	ld	s2,48(sp)
    107c:	79a2                	ld	s3,40(sp)
    107e:	7a02                	ld	s4,32(sp)
    1080:	6ae2                	ld	s5,24(sp)
    1082:	6b42                	ld	s6,16(sp)
    1084:	6161                	addi	sp,sp,80
    1086:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1088:	85ce                	mv	a1,s3
    108a:	00005517          	auipc	a0,0x5
    108e:	4a650513          	addi	a0,a0,1190 # 6530 <malloc+0xbbc>
    1092:	00005097          	auipc	ra,0x5
    1096:	822080e7          	jalr	-2014(ra) # 58b4 <printf>
    exit(1);
    109a:	4505                	li	a0,1
    109c:	00004097          	auipc	ra,0x4
    10a0:	4a0080e7          	jalr	1184(ra) # 553c <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    10a4:	fb040613          	addi	a2,s0,-80
    10a8:	85ce                	mv	a1,s3
    10aa:	00005517          	auipc	a0,0x5
    10ae:	4a650513          	addi	a0,a0,1190 # 6550 <malloc+0xbdc>
    10b2:	00005097          	auipc	ra,0x5
    10b6:	802080e7          	jalr	-2046(ra) # 58b4 <printf>
      exit(1);
    10ba:	4505                	li	a0,1
    10bc:	00004097          	auipc	ra,0x4
    10c0:	480080e7          	jalr	1152(ra) # 553c <exit>
      printf("%s: bigdir unlink failed", s);
    10c4:	85ce                	mv	a1,s3
    10c6:	00005517          	auipc	a0,0x5
    10ca:	4aa50513          	addi	a0,a0,1194 # 6570 <malloc+0xbfc>
    10ce:	00004097          	auipc	ra,0x4
    10d2:	7e6080e7          	jalr	2022(ra) # 58b4 <printf>
      exit(1);
    10d6:	4505                	li	a0,1
    10d8:	00004097          	auipc	ra,0x4
    10dc:	464080e7          	jalr	1124(ra) # 553c <exit>

00000000000010e0 <validatetest>:
{
    10e0:	7139                	addi	sp,sp,-64
    10e2:	fc06                	sd	ra,56(sp)
    10e4:	f822                	sd	s0,48(sp)
    10e6:	f426                	sd	s1,40(sp)
    10e8:	f04a                	sd	s2,32(sp)
    10ea:	ec4e                	sd	s3,24(sp)
    10ec:	e852                	sd	s4,16(sp)
    10ee:	e456                	sd	s5,8(sp)
    10f0:	e05a                	sd	s6,0(sp)
    10f2:	0080                	addi	s0,sp,64
    10f4:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    10f6:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    10f8:	00005997          	auipc	s3,0x5
    10fc:	49898993          	addi	s3,s3,1176 # 6590 <malloc+0xc1c>
    1100:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1102:	6a85                	lui	s5,0x1
    1104:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1108:	85a6                	mv	a1,s1
    110a:	854e                	mv	a0,s3
    110c:	00004097          	auipc	ra,0x4
    1110:	490080e7          	jalr	1168(ra) # 559c <link>
    1114:	01251f63          	bne	a0,s2,1132 <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1118:	94d6                	add	s1,s1,s5
    111a:	ff4497e3          	bne	s1,s4,1108 <validatetest+0x28>
}
    111e:	70e2                	ld	ra,56(sp)
    1120:	7442                	ld	s0,48(sp)
    1122:	74a2                	ld	s1,40(sp)
    1124:	7902                	ld	s2,32(sp)
    1126:	69e2                	ld	s3,24(sp)
    1128:	6a42                	ld	s4,16(sp)
    112a:	6aa2                	ld	s5,8(sp)
    112c:	6b02                	ld	s6,0(sp)
    112e:	6121                	addi	sp,sp,64
    1130:	8082                	ret
      printf("%s: link should not succeed\n", s);
    1132:	85da                	mv	a1,s6
    1134:	00005517          	auipc	a0,0x5
    1138:	46c50513          	addi	a0,a0,1132 # 65a0 <malloc+0xc2c>
    113c:	00004097          	auipc	ra,0x4
    1140:	778080e7          	jalr	1912(ra) # 58b4 <printf>
      exit(1);
    1144:	4505                	li	a0,1
    1146:	00004097          	auipc	ra,0x4
    114a:	3f6080e7          	jalr	1014(ra) # 553c <exit>

000000000000114e <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    114e:	7179                	addi	sp,sp,-48
    1150:	f406                	sd	ra,40(sp)
    1152:	f022                	sd	s0,32(sp)
    1154:	ec26                	sd	s1,24(sp)
    1156:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1158:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    115c:	00007797          	auipc	a5,0x7
    1160:	02c78793          	addi	a5,a5,44 # 8188 <digits+0x20>
    1164:	6384                	ld	s1,0(a5)
    1166:	fd840593          	addi	a1,s0,-40
    116a:	8526                	mv	a0,s1
    116c:	00004097          	auipc	ra,0x4
    1170:	408080e7          	jalr	1032(ra) # 5574 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1174:	8526                	mv	a0,s1
    1176:	00004097          	auipc	ra,0x4
    117a:	3d6080e7          	jalr	982(ra) # 554c <pipe>

  exit(0);
    117e:	4501                	li	a0,0
    1180:	00004097          	auipc	ra,0x4
    1184:	3bc080e7          	jalr	956(ra) # 553c <exit>

0000000000001188 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1188:	7139                	addi	sp,sp,-64
    118a:	fc06                	sd	ra,56(sp)
    118c:	f822                	sd	s0,48(sp)
    118e:	f426                	sd	s1,40(sp)
    1190:	f04a                	sd	s2,32(sp)
    1192:	ec4e                	sd	s3,24(sp)
    1194:	0080                	addi	s0,sp,64
    1196:	64b1                	lui	s1,0xc
    1198:	35048493          	addi	s1,s1,848 # c350 <buf+0x990>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    119c:	597d                	li	s2,-1
    119e:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    11a2:	00005997          	auipc	s3,0x5
    11a6:	ca698993          	addi	s3,s3,-858 # 5e48 <malloc+0x4d4>
    argv[0] = (char*)0xffffffff;
    11aa:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11ae:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11b2:	fc040593          	addi	a1,s0,-64
    11b6:	854e                	mv	a0,s3
    11b8:	00004097          	auipc	ra,0x4
    11bc:	3bc080e7          	jalr	956(ra) # 5574 <exec>
  for(int i = 0; i < 50000; i++){
    11c0:	34fd                	addiw	s1,s1,-1
    11c2:	f4e5                	bnez	s1,11aa <badarg+0x22>
  }
  
  exit(0);
    11c4:	4501                	li	a0,0
    11c6:	00004097          	auipc	ra,0x4
    11ca:	376080e7          	jalr	886(ra) # 553c <exit>

00000000000011ce <copyinstr2>:
{
    11ce:	7155                	addi	sp,sp,-208
    11d0:	e586                	sd	ra,200(sp)
    11d2:	e1a2                	sd	s0,192(sp)
    11d4:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11d6:	f6840793          	addi	a5,s0,-152
    11da:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11de:	07800713          	li	a4,120
    11e2:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11e6:	0785                	addi	a5,a5,1
    11e8:	fed79de3          	bne	a5,a3,11e2 <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11ec:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11f0:	f6840513          	addi	a0,s0,-152
    11f4:	00004097          	auipc	ra,0x4
    11f8:	398080e7          	jalr	920(ra) # 558c <unlink>
  if(ret != -1){
    11fc:	57fd                	li	a5,-1
    11fe:	0ef51063          	bne	a0,a5,12de <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    1202:	20100593          	li	a1,513
    1206:	f6840513          	addi	a0,s0,-152
    120a:	00004097          	auipc	ra,0x4
    120e:	372080e7          	jalr	882(ra) # 557c <open>
  if(fd != -1){
    1212:	57fd                	li	a5,-1
    1214:	0ef51563          	bne	a0,a5,12fe <copyinstr2+0x130>
  ret = link(b, b);
    1218:	f6840593          	addi	a1,s0,-152
    121c:	852e                	mv	a0,a1
    121e:	00004097          	auipc	ra,0x4
    1222:	37e080e7          	jalr	894(ra) # 559c <link>
  if(ret != -1){
    1226:	57fd                	li	a5,-1
    1228:	0ef51b63          	bne	a0,a5,131e <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    122c:	00006797          	auipc	a5,0x6
    1230:	4ec78793          	addi	a5,a5,1260 # 7718 <malloc+0x1da4>
    1234:	f4f43c23          	sd	a5,-168(s0)
    1238:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    123c:	f5840593          	addi	a1,s0,-168
    1240:	f6840513          	addi	a0,s0,-152
    1244:	00004097          	auipc	ra,0x4
    1248:	330080e7          	jalr	816(ra) # 5574 <exec>
  if(ret != -1){
    124c:	57fd                	li	a5,-1
    124e:	0ef51963          	bne	a0,a5,1340 <copyinstr2+0x172>
  int pid = fork();
    1252:	00004097          	auipc	ra,0x4
    1256:	2e2080e7          	jalr	738(ra) # 5534 <fork>
  if(pid < 0){
    125a:	10054363          	bltz	a0,1360 <copyinstr2+0x192>
  if(pid == 0){
    125e:	12051463          	bnez	a0,1386 <copyinstr2+0x1b8>
    1262:	00007797          	auipc	a5,0x7
    1266:	04678793          	addi	a5,a5,70 # 82a8 <big.1285>
    126a:	00008697          	auipc	a3,0x8
    126e:	03e68693          	addi	a3,a3,62 # 92a8 <__global_pointer$+0x920>
      big[i] = 'x';
    1272:	07800713          	li	a4,120
    1276:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    127a:	0785                	addi	a5,a5,1
    127c:	fed79de3          	bne	a5,a3,1276 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    1280:	00008797          	auipc	a5,0x8
    1284:	02078423          	sb	zero,40(a5) # 92a8 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1288:	00004797          	auipc	a5,0x4
    128c:	7d878793          	addi	a5,a5,2008 # 5a60 <malloc+0xec>
    1290:	6390                	ld	a2,0(a5)
    1292:	6794                	ld	a3,8(a5)
    1294:	6b98                	ld	a4,16(a5)
    1296:	6f9c                	ld	a5,24(a5)
    1298:	f2c43823          	sd	a2,-208(s0)
    129c:	f2d43c23          	sd	a3,-200(s0)
    12a0:	f4e43023          	sd	a4,-192(s0)
    12a4:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12a8:	f3040593          	addi	a1,s0,-208
    12ac:	00005517          	auipc	a0,0x5
    12b0:	b9c50513          	addi	a0,a0,-1124 # 5e48 <malloc+0x4d4>
    12b4:	00004097          	auipc	ra,0x4
    12b8:	2c0080e7          	jalr	704(ra) # 5574 <exec>
    if(ret != -1){
    12bc:	57fd                	li	a5,-1
    12be:	0af50e63          	beq	a0,a5,137a <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12c2:	55fd                	li	a1,-1
    12c4:	00005517          	auipc	a0,0x5
    12c8:	38450513          	addi	a0,a0,900 # 6648 <malloc+0xcd4>
    12cc:	00004097          	auipc	ra,0x4
    12d0:	5e8080e7          	jalr	1512(ra) # 58b4 <printf>
      exit(1);
    12d4:	4505                	li	a0,1
    12d6:	00004097          	auipc	ra,0x4
    12da:	266080e7          	jalr	614(ra) # 553c <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12de:	862a                	mv	a2,a0
    12e0:	f6840593          	addi	a1,s0,-152
    12e4:	00005517          	auipc	a0,0x5
    12e8:	2dc50513          	addi	a0,a0,732 # 65c0 <malloc+0xc4c>
    12ec:	00004097          	auipc	ra,0x4
    12f0:	5c8080e7          	jalr	1480(ra) # 58b4 <printf>
    exit(1);
    12f4:	4505                	li	a0,1
    12f6:	00004097          	auipc	ra,0x4
    12fa:	246080e7          	jalr	582(ra) # 553c <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    12fe:	862a                	mv	a2,a0
    1300:	f6840593          	addi	a1,s0,-152
    1304:	00005517          	auipc	a0,0x5
    1308:	2dc50513          	addi	a0,a0,732 # 65e0 <malloc+0xc6c>
    130c:	00004097          	auipc	ra,0x4
    1310:	5a8080e7          	jalr	1448(ra) # 58b4 <printf>
    exit(1);
    1314:	4505                	li	a0,1
    1316:	00004097          	auipc	ra,0x4
    131a:	226080e7          	jalr	550(ra) # 553c <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    131e:	86aa                	mv	a3,a0
    1320:	f6840613          	addi	a2,s0,-152
    1324:	85b2                	mv	a1,a2
    1326:	00005517          	auipc	a0,0x5
    132a:	2da50513          	addi	a0,a0,730 # 6600 <malloc+0xc8c>
    132e:	00004097          	auipc	ra,0x4
    1332:	586080e7          	jalr	1414(ra) # 58b4 <printf>
    exit(1);
    1336:	4505                	li	a0,1
    1338:	00004097          	auipc	ra,0x4
    133c:	204080e7          	jalr	516(ra) # 553c <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    1340:	567d                	li	a2,-1
    1342:	f6840593          	addi	a1,s0,-152
    1346:	00005517          	auipc	a0,0x5
    134a:	2e250513          	addi	a0,a0,738 # 6628 <malloc+0xcb4>
    134e:	00004097          	auipc	ra,0x4
    1352:	566080e7          	jalr	1382(ra) # 58b4 <printf>
    exit(1);
    1356:	4505                	li	a0,1
    1358:	00004097          	auipc	ra,0x4
    135c:	1e4080e7          	jalr	484(ra) # 553c <exit>
    printf("fork failed\n");
    1360:	00005517          	auipc	a0,0x5
    1364:	73050513          	addi	a0,a0,1840 # 6a90 <malloc+0x111c>
    1368:	00004097          	auipc	ra,0x4
    136c:	54c080e7          	jalr	1356(ra) # 58b4 <printf>
    exit(1);
    1370:	4505                	li	a0,1
    1372:	00004097          	auipc	ra,0x4
    1376:	1ca080e7          	jalr	458(ra) # 553c <exit>
    exit(747); // OK
    137a:	2eb00513          	li	a0,747
    137e:	00004097          	auipc	ra,0x4
    1382:	1be080e7          	jalr	446(ra) # 553c <exit>
  int st = 0;
    1386:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    138a:	f5440513          	addi	a0,s0,-172
    138e:	00004097          	auipc	ra,0x4
    1392:	1b6080e7          	jalr	438(ra) # 5544 <wait>
  if(st != 747){
    1396:	f5442703          	lw	a4,-172(s0)
    139a:	2eb00793          	li	a5,747
    139e:	00f71663          	bne	a4,a5,13aa <copyinstr2+0x1dc>
}
    13a2:	60ae                	ld	ra,200(sp)
    13a4:	640e                	ld	s0,192(sp)
    13a6:	6169                	addi	sp,sp,208
    13a8:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13aa:	00005517          	auipc	a0,0x5
    13ae:	2c650513          	addi	a0,a0,710 # 6670 <malloc+0xcfc>
    13b2:	00004097          	auipc	ra,0x4
    13b6:	502080e7          	jalr	1282(ra) # 58b4 <printf>
    exit(1);
    13ba:	4505                	li	a0,1
    13bc:	00004097          	auipc	ra,0x4
    13c0:	180080e7          	jalr	384(ra) # 553c <exit>

00000000000013c4 <truncate3>:
{
    13c4:	7159                	addi	sp,sp,-112
    13c6:	f486                	sd	ra,104(sp)
    13c8:	f0a2                	sd	s0,96(sp)
    13ca:	eca6                	sd	s1,88(sp)
    13cc:	e8ca                	sd	s2,80(sp)
    13ce:	e4ce                	sd	s3,72(sp)
    13d0:	e0d2                	sd	s4,64(sp)
    13d2:	fc56                	sd	s5,56(sp)
    13d4:	1880                	addi	s0,sp,112
    13d6:	8a2a                	mv	s4,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13d8:	60100593          	li	a1,1537
    13dc:	00005517          	auipc	a0,0x5
    13e0:	ac450513          	addi	a0,a0,-1340 # 5ea0 <malloc+0x52c>
    13e4:	00004097          	auipc	ra,0x4
    13e8:	198080e7          	jalr	408(ra) # 557c <open>
    13ec:	00004097          	auipc	ra,0x4
    13f0:	178080e7          	jalr	376(ra) # 5564 <close>
  pid = fork();
    13f4:	00004097          	auipc	ra,0x4
    13f8:	140080e7          	jalr	320(ra) # 5534 <fork>
  if(pid < 0){
    13fc:	08054063          	bltz	a0,147c <truncate3+0xb8>
  if(pid == 0){
    1400:	e969                	bnez	a0,14d2 <truncate3+0x10e>
    1402:	06400913          	li	s2,100
      int fd = open("truncfile", O_WRONLY);
    1406:	00005997          	auipc	s3,0x5
    140a:	a9a98993          	addi	s3,s3,-1382 # 5ea0 <malloc+0x52c>
      int n = write(fd, "1234567890", 10);
    140e:	00005a97          	auipc	s5,0x5
    1412:	2c2a8a93          	addi	s5,s5,706 # 66d0 <malloc+0xd5c>
      int fd = open("truncfile", O_WRONLY);
    1416:	4585                	li	a1,1
    1418:	854e                	mv	a0,s3
    141a:	00004097          	auipc	ra,0x4
    141e:	162080e7          	jalr	354(ra) # 557c <open>
    1422:	84aa                	mv	s1,a0
      if(fd < 0){
    1424:	06054a63          	bltz	a0,1498 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1428:	4629                	li	a2,10
    142a:	85d6                	mv	a1,s5
    142c:	00004097          	auipc	ra,0x4
    1430:	130080e7          	jalr	304(ra) # 555c <write>
      if(n != 10){
    1434:	47a9                	li	a5,10
    1436:	06f51f63          	bne	a0,a5,14b4 <truncate3+0xf0>
      close(fd);
    143a:	8526                	mv	a0,s1
    143c:	00004097          	auipc	ra,0x4
    1440:	128080e7          	jalr	296(ra) # 5564 <close>
      fd = open("truncfile", O_RDONLY);
    1444:	4581                	li	a1,0
    1446:	854e                	mv	a0,s3
    1448:	00004097          	auipc	ra,0x4
    144c:	134080e7          	jalr	308(ra) # 557c <open>
    1450:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    1452:	02000613          	li	a2,32
    1456:	f9840593          	addi	a1,s0,-104
    145a:	00004097          	auipc	ra,0x4
    145e:	0fa080e7          	jalr	250(ra) # 5554 <read>
      close(fd);
    1462:	8526                	mv	a0,s1
    1464:	00004097          	auipc	ra,0x4
    1468:	100080e7          	jalr	256(ra) # 5564 <close>
    for(int i = 0; i < 100; i++){
    146c:	397d                	addiw	s2,s2,-1
    146e:	fa0914e3          	bnez	s2,1416 <truncate3+0x52>
    exit(0);
    1472:	4501                	li	a0,0
    1474:	00004097          	auipc	ra,0x4
    1478:	0c8080e7          	jalr	200(ra) # 553c <exit>
    printf("%s: fork failed\n", s);
    147c:	85d2                	mv	a1,s4
    147e:	00005517          	auipc	a0,0x5
    1482:	22250513          	addi	a0,a0,546 # 66a0 <malloc+0xd2c>
    1486:	00004097          	auipc	ra,0x4
    148a:	42e080e7          	jalr	1070(ra) # 58b4 <printf>
    exit(1);
    148e:	4505                	li	a0,1
    1490:	00004097          	auipc	ra,0x4
    1494:	0ac080e7          	jalr	172(ra) # 553c <exit>
        printf("%s: open failed\n", s);
    1498:	85d2                	mv	a1,s4
    149a:	00005517          	auipc	a0,0x5
    149e:	21e50513          	addi	a0,a0,542 # 66b8 <malloc+0xd44>
    14a2:	00004097          	auipc	ra,0x4
    14a6:	412080e7          	jalr	1042(ra) # 58b4 <printf>
        exit(1);
    14aa:	4505                	li	a0,1
    14ac:	00004097          	auipc	ra,0x4
    14b0:	090080e7          	jalr	144(ra) # 553c <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14b4:	862a                	mv	a2,a0
    14b6:	85d2                	mv	a1,s4
    14b8:	00005517          	auipc	a0,0x5
    14bc:	22850513          	addi	a0,a0,552 # 66e0 <malloc+0xd6c>
    14c0:	00004097          	auipc	ra,0x4
    14c4:	3f4080e7          	jalr	1012(ra) # 58b4 <printf>
        exit(1);
    14c8:	4505                	li	a0,1
    14ca:	00004097          	auipc	ra,0x4
    14ce:	072080e7          	jalr	114(ra) # 553c <exit>
    14d2:	09600913          	li	s2,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14d6:	00005997          	auipc	s3,0x5
    14da:	9ca98993          	addi	s3,s3,-1590 # 5ea0 <malloc+0x52c>
    int n = write(fd, "xxx", 3);
    14de:	00005a97          	auipc	s5,0x5
    14e2:	222a8a93          	addi	s5,s5,546 # 6700 <malloc+0xd8c>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14e6:	60100593          	li	a1,1537
    14ea:	854e                	mv	a0,s3
    14ec:	00004097          	auipc	ra,0x4
    14f0:	090080e7          	jalr	144(ra) # 557c <open>
    14f4:	84aa                	mv	s1,a0
    if(fd < 0){
    14f6:	04054763          	bltz	a0,1544 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    14fa:	460d                	li	a2,3
    14fc:	85d6                	mv	a1,s5
    14fe:	00004097          	auipc	ra,0x4
    1502:	05e080e7          	jalr	94(ra) # 555c <write>
    if(n != 3){
    1506:	478d                	li	a5,3
    1508:	04f51c63          	bne	a0,a5,1560 <truncate3+0x19c>
    close(fd);
    150c:	8526                	mv	a0,s1
    150e:	00004097          	auipc	ra,0x4
    1512:	056080e7          	jalr	86(ra) # 5564 <close>
  for(int i = 0; i < 150; i++){
    1516:	397d                	addiw	s2,s2,-1
    1518:	fc0917e3          	bnez	s2,14e6 <truncate3+0x122>
  wait(&xstatus);
    151c:	fbc40513          	addi	a0,s0,-68
    1520:	00004097          	auipc	ra,0x4
    1524:	024080e7          	jalr	36(ra) # 5544 <wait>
  unlink("truncfile");
    1528:	00005517          	auipc	a0,0x5
    152c:	97850513          	addi	a0,a0,-1672 # 5ea0 <malloc+0x52c>
    1530:	00004097          	auipc	ra,0x4
    1534:	05c080e7          	jalr	92(ra) # 558c <unlink>
  exit(xstatus);
    1538:	fbc42503          	lw	a0,-68(s0)
    153c:	00004097          	auipc	ra,0x4
    1540:	000080e7          	jalr	ra # 553c <exit>
      printf("%s: open failed\n", s);
    1544:	85d2                	mv	a1,s4
    1546:	00005517          	auipc	a0,0x5
    154a:	17250513          	addi	a0,a0,370 # 66b8 <malloc+0xd44>
    154e:	00004097          	auipc	ra,0x4
    1552:	366080e7          	jalr	870(ra) # 58b4 <printf>
      exit(1);
    1556:	4505                	li	a0,1
    1558:	00004097          	auipc	ra,0x4
    155c:	fe4080e7          	jalr	-28(ra) # 553c <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    1560:	862a                	mv	a2,a0
    1562:	85d2                	mv	a1,s4
    1564:	00005517          	auipc	a0,0x5
    1568:	1a450513          	addi	a0,a0,420 # 6708 <malloc+0xd94>
    156c:	00004097          	auipc	ra,0x4
    1570:	348080e7          	jalr	840(ra) # 58b4 <printf>
      exit(1);
    1574:	4505                	li	a0,1
    1576:	00004097          	auipc	ra,0x4
    157a:	fc6080e7          	jalr	-58(ra) # 553c <exit>

000000000000157e <exectest>:
{
    157e:	715d                	addi	sp,sp,-80
    1580:	e486                	sd	ra,72(sp)
    1582:	e0a2                	sd	s0,64(sp)
    1584:	fc26                	sd	s1,56(sp)
    1586:	f84a                	sd	s2,48(sp)
    1588:	0880                	addi	s0,sp,80
    158a:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    158c:	00005797          	auipc	a5,0x5
    1590:	8bc78793          	addi	a5,a5,-1860 # 5e48 <malloc+0x4d4>
    1594:	fcf43023          	sd	a5,-64(s0)
    1598:	00005797          	auipc	a5,0x5
    159c:	19078793          	addi	a5,a5,400 # 6728 <malloc+0xdb4>
    15a0:	fcf43423          	sd	a5,-56(s0)
    15a4:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15a8:	00005517          	auipc	a0,0x5
    15ac:	18850513          	addi	a0,a0,392 # 6730 <malloc+0xdbc>
    15b0:	00004097          	auipc	ra,0x4
    15b4:	fdc080e7          	jalr	-36(ra) # 558c <unlink>
  pid = fork();
    15b8:	00004097          	auipc	ra,0x4
    15bc:	f7c080e7          	jalr	-132(ra) # 5534 <fork>
  if(pid < 0) {
    15c0:	04054663          	bltz	a0,160c <exectest+0x8e>
    15c4:	84aa                	mv	s1,a0
  if(pid == 0) {
    15c6:	e959                	bnez	a0,165c <exectest+0xde>
    close(1);
    15c8:	4505                	li	a0,1
    15ca:	00004097          	auipc	ra,0x4
    15ce:	f9a080e7          	jalr	-102(ra) # 5564 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15d2:	20100593          	li	a1,513
    15d6:	00005517          	auipc	a0,0x5
    15da:	15a50513          	addi	a0,a0,346 # 6730 <malloc+0xdbc>
    15de:	00004097          	auipc	ra,0x4
    15e2:	f9e080e7          	jalr	-98(ra) # 557c <open>
    if(fd < 0) {
    15e6:	04054163          	bltz	a0,1628 <exectest+0xaa>
    if(fd != 1) {
    15ea:	4785                	li	a5,1
    15ec:	04f50c63          	beq	a0,a5,1644 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15f0:	85ca                	mv	a1,s2
    15f2:	00005517          	auipc	a0,0x5
    15f6:	15e50513          	addi	a0,a0,350 # 6750 <malloc+0xddc>
    15fa:	00004097          	auipc	ra,0x4
    15fe:	2ba080e7          	jalr	698(ra) # 58b4 <printf>
      exit(1);
    1602:	4505                	li	a0,1
    1604:	00004097          	auipc	ra,0x4
    1608:	f38080e7          	jalr	-200(ra) # 553c <exit>
     printf("%s: fork failed\n", s);
    160c:	85ca                	mv	a1,s2
    160e:	00005517          	auipc	a0,0x5
    1612:	09250513          	addi	a0,a0,146 # 66a0 <malloc+0xd2c>
    1616:	00004097          	auipc	ra,0x4
    161a:	29e080e7          	jalr	670(ra) # 58b4 <printf>
     exit(1);
    161e:	4505                	li	a0,1
    1620:	00004097          	auipc	ra,0x4
    1624:	f1c080e7          	jalr	-228(ra) # 553c <exit>
      printf("%s: create failed\n", s);
    1628:	85ca                	mv	a1,s2
    162a:	00005517          	auipc	a0,0x5
    162e:	10e50513          	addi	a0,a0,270 # 6738 <malloc+0xdc4>
    1632:	00004097          	auipc	ra,0x4
    1636:	282080e7          	jalr	642(ra) # 58b4 <printf>
      exit(1);
    163a:	4505                	li	a0,1
    163c:	00004097          	auipc	ra,0x4
    1640:	f00080e7          	jalr	-256(ra) # 553c <exit>
    if(exec("echo", echoargv) < 0){
    1644:	fc040593          	addi	a1,s0,-64
    1648:	00005517          	auipc	a0,0x5
    164c:	80050513          	addi	a0,a0,-2048 # 5e48 <malloc+0x4d4>
    1650:	00004097          	auipc	ra,0x4
    1654:	f24080e7          	jalr	-220(ra) # 5574 <exec>
    1658:	02054163          	bltz	a0,167a <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    165c:	fdc40513          	addi	a0,s0,-36
    1660:	00004097          	auipc	ra,0x4
    1664:	ee4080e7          	jalr	-284(ra) # 5544 <wait>
    1668:	02951763          	bne	a0,s1,1696 <exectest+0x118>
  if(xstatus != 0)
    166c:	fdc42503          	lw	a0,-36(s0)
    1670:	cd0d                	beqz	a0,16aa <exectest+0x12c>
    exit(xstatus);
    1672:	00004097          	auipc	ra,0x4
    1676:	eca080e7          	jalr	-310(ra) # 553c <exit>
      printf("%s: exec echo failed\n", s);
    167a:	85ca                	mv	a1,s2
    167c:	00005517          	auipc	a0,0x5
    1680:	0e450513          	addi	a0,a0,228 # 6760 <malloc+0xdec>
    1684:	00004097          	auipc	ra,0x4
    1688:	230080e7          	jalr	560(ra) # 58b4 <printf>
      exit(1);
    168c:	4505                	li	a0,1
    168e:	00004097          	auipc	ra,0x4
    1692:	eae080e7          	jalr	-338(ra) # 553c <exit>
    printf("%s: wait failed!\n", s);
    1696:	85ca                	mv	a1,s2
    1698:	00005517          	auipc	a0,0x5
    169c:	0e050513          	addi	a0,a0,224 # 6778 <malloc+0xe04>
    16a0:	00004097          	auipc	ra,0x4
    16a4:	214080e7          	jalr	532(ra) # 58b4 <printf>
    16a8:	b7d1                	j	166c <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16aa:	4581                	li	a1,0
    16ac:	00005517          	auipc	a0,0x5
    16b0:	08450513          	addi	a0,a0,132 # 6730 <malloc+0xdbc>
    16b4:	00004097          	auipc	ra,0x4
    16b8:	ec8080e7          	jalr	-312(ra) # 557c <open>
  if(fd < 0) {
    16bc:	02054a63          	bltz	a0,16f0 <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16c0:	4609                	li	a2,2
    16c2:	fb840593          	addi	a1,s0,-72
    16c6:	00004097          	auipc	ra,0x4
    16ca:	e8e080e7          	jalr	-370(ra) # 5554 <read>
    16ce:	4789                	li	a5,2
    16d0:	02f50e63          	beq	a0,a5,170c <exectest+0x18e>
    printf("%s: read failed\n", s);
    16d4:	85ca                	mv	a1,s2
    16d6:	00005517          	auipc	a0,0x5
    16da:	b1250513          	addi	a0,a0,-1262 # 61e8 <malloc+0x874>
    16de:	00004097          	auipc	ra,0x4
    16e2:	1d6080e7          	jalr	470(ra) # 58b4 <printf>
    exit(1);
    16e6:	4505                	li	a0,1
    16e8:	00004097          	auipc	ra,0x4
    16ec:	e54080e7          	jalr	-428(ra) # 553c <exit>
    printf("%s: open failed\n", s);
    16f0:	85ca                	mv	a1,s2
    16f2:	00005517          	auipc	a0,0x5
    16f6:	fc650513          	addi	a0,a0,-58 # 66b8 <malloc+0xd44>
    16fa:	00004097          	auipc	ra,0x4
    16fe:	1ba080e7          	jalr	442(ra) # 58b4 <printf>
    exit(1);
    1702:	4505                	li	a0,1
    1704:	00004097          	auipc	ra,0x4
    1708:	e38080e7          	jalr	-456(ra) # 553c <exit>
  unlink("echo-ok");
    170c:	00005517          	auipc	a0,0x5
    1710:	02450513          	addi	a0,a0,36 # 6730 <malloc+0xdbc>
    1714:	00004097          	auipc	ra,0x4
    1718:	e78080e7          	jalr	-392(ra) # 558c <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    171c:	fb844703          	lbu	a4,-72(s0)
    1720:	04f00793          	li	a5,79
    1724:	00f71863          	bne	a4,a5,1734 <exectest+0x1b6>
    1728:	fb944703          	lbu	a4,-71(s0)
    172c:	04b00793          	li	a5,75
    1730:	02f70063          	beq	a4,a5,1750 <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1734:	85ca                	mv	a1,s2
    1736:	00005517          	auipc	a0,0x5
    173a:	05a50513          	addi	a0,a0,90 # 6790 <malloc+0xe1c>
    173e:	00004097          	auipc	ra,0x4
    1742:	176080e7          	jalr	374(ra) # 58b4 <printf>
    exit(1);
    1746:	4505                	li	a0,1
    1748:	00004097          	auipc	ra,0x4
    174c:	df4080e7          	jalr	-524(ra) # 553c <exit>
    exit(0);
    1750:	4501                	li	a0,0
    1752:	00004097          	auipc	ra,0x4
    1756:	dea080e7          	jalr	-534(ra) # 553c <exit>

000000000000175a <pipe1>:
{
    175a:	715d                	addi	sp,sp,-80
    175c:	e486                	sd	ra,72(sp)
    175e:	e0a2                	sd	s0,64(sp)
    1760:	fc26                	sd	s1,56(sp)
    1762:	f84a                	sd	s2,48(sp)
    1764:	f44e                	sd	s3,40(sp)
    1766:	f052                	sd	s4,32(sp)
    1768:	ec56                	sd	s5,24(sp)
    176a:	e85a                	sd	s6,16(sp)
    176c:	0880                	addi	s0,sp,80
    176e:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    1770:	fb840513          	addi	a0,s0,-72
    1774:	00004097          	auipc	ra,0x4
    1778:	dd8080e7          	jalr	-552(ra) # 554c <pipe>
    177c:	e935                	bnez	a0,17f0 <pipe1+0x96>
    177e:	84aa                	mv	s1,a0
  pid = fork();
    1780:	00004097          	auipc	ra,0x4
    1784:	db4080e7          	jalr	-588(ra) # 5534 <fork>
  if(pid == 0){
    1788:	c151                	beqz	a0,180c <pipe1+0xb2>
  } else if(pid > 0){
    178a:	18a05963          	blez	a0,191c <pipe1+0x1c2>
    close(fds[1]);
    178e:	fbc42503          	lw	a0,-68(s0)
    1792:	00004097          	auipc	ra,0x4
    1796:	dd2080e7          	jalr	-558(ra) # 5564 <close>
    total = 0;
    179a:	8aa6                	mv	s5,s1
    cc = 1;
    179c:	4a05                	li	s4,1
    while((n = read(fds[0], buf, cc)) > 0){
    179e:	0000a917          	auipc	s2,0xa
    17a2:	22290913          	addi	s2,s2,546 # b9c0 <buf>
      if(cc > sizeof(buf))
    17a6:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17a8:	8652                	mv	a2,s4
    17aa:	85ca                	mv	a1,s2
    17ac:	fb842503          	lw	a0,-72(s0)
    17b0:	00004097          	auipc	ra,0x4
    17b4:	da4080e7          	jalr	-604(ra) # 5554 <read>
    17b8:	10a05d63          	blez	a0,18d2 <pipe1+0x178>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17bc:	0014879b          	addiw	a5,s1,1
    17c0:	00094683          	lbu	a3,0(s2)
    17c4:	0ff4f713          	andi	a4,s1,255
    17c8:	0ce69863          	bne	a3,a4,1898 <pipe1+0x13e>
    17cc:	0000a717          	auipc	a4,0xa
    17d0:	1f570713          	addi	a4,a4,501 # b9c1 <buf+0x1>
    17d4:	9ca9                	addw	s1,s1,a0
      for(i = 0; i < n; i++){
    17d6:	0e978463          	beq	a5,s1,18be <pipe1+0x164>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17da:	00074683          	lbu	a3,0(a4)
    17de:	0017861b          	addiw	a2,a5,1
    17e2:	0705                	addi	a4,a4,1
    17e4:	0ff7f793          	andi	a5,a5,255
    17e8:	0af69863          	bne	a3,a5,1898 <pipe1+0x13e>
    17ec:	87b2                	mv	a5,a2
    17ee:	b7e5                	j	17d6 <pipe1+0x7c>
    printf("%s: pipe() failed\n", s);
    17f0:	85ce                	mv	a1,s3
    17f2:	00005517          	auipc	a0,0x5
    17f6:	fb650513          	addi	a0,a0,-74 # 67a8 <malloc+0xe34>
    17fa:	00004097          	auipc	ra,0x4
    17fe:	0ba080e7          	jalr	186(ra) # 58b4 <printf>
    exit(1);
    1802:	4505                	li	a0,1
    1804:	00004097          	auipc	ra,0x4
    1808:	d38080e7          	jalr	-712(ra) # 553c <exit>
    close(fds[0]);
    180c:	fb842503          	lw	a0,-72(s0)
    1810:	00004097          	auipc	ra,0x4
    1814:	d54080e7          	jalr	-684(ra) # 5564 <close>
    for(n = 0; n < N; n++){
    1818:	0000aa97          	auipc	s5,0xa
    181c:	1a8a8a93          	addi	s5,s5,424 # b9c0 <buf>
    1820:	0ffaf793          	andi	a5,s5,255
    1824:	40f004b3          	neg	s1,a5
    1828:	0ff4f493          	andi	s1,s1,255
    182c:	02d00a13          	li	s4,45
    1830:	40fa0a3b          	subw	s4,s4,a5
    1834:	0ffa7a13          	andi	s4,s4,255
    1838:	409a8913          	addi	s2,s5,1033
      if(write(fds[1], buf, SZ) != SZ){
    183c:	8b56                	mv	s6,s5
{
    183e:	87d6                	mv	a5,s5
        buf[i] = seq++;
    1840:	0097873b          	addw	a4,a5,s1
    1844:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1848:	0785                	addi	a5,a5,1
    184a:	fef91be3          	bne	s2,a5,1840 <pipe1+0xe6>
      if(write(fds[1], buf, SZ) != SZ){
    184e:	40900613          	li	a2,1033
    1852:	85da                	mv	a1,s6
    1854:	fbc42503          	lw	a0,-68(s0)
    1858:	00004097          	auipc	ra,0x4
    185c:	d04080e7          	jalr	-764(ra) # 555c <write>
    1860:	40900793          	li	a5,1033
    1864:	00f51c63          	bne	a0,a5,187c <pipe1+0x122>
    for(n = 0; n < N; n++){
    1868:	24a5                	addiw	s1,s1,9
    186a:	0ff4f493          	andi	s1,s1,255
    186e:	fd4498e3          	bne	s1,s4,183e <pipe1+0xe4>
    exit(0);
    1872:	4501                	li	a0,0
    1874:	00004097          	auipc	ra,0x4
    1878:	cc8080e7          	jalr	-824(ra) # 553c <exit>
        printf("%s: pipe1 oops 1\n", s);
    187c:	85ce                	mv	a1,s3
    187e:	00005517          	auipc	a0,0x5
    1882:	f4250513          	addi	a0,a0,-190 # 67c0 <malloc+0xe4c>
    1886:	00004097          	auipc	ra,0x4
    188a:	02e080e7          	jalr	46(ra) # 58b4 <printf>
        exit(1);
    188e:	4505                	li	a0,1
    1890:	00004097          	auipc	ra,0x4
    1894:	cac080e7          	jalr	-852(ra) # 553c <exit>
          printf("%s: pipe1 oops 2\n", s);
    1898:	85ce                	mv	a1,s3
    189a:	00005517          	auipc	a0,0x5
    189e:	f3e50513          	addi	a0,a0,-194 # 67d8 <malloc+0xe64>
    18a2:	00004097          	auipc	ra,0x4
    18a6:	012080e7          	jalr	18(ra) # 58b4 <printf>
}
    18aa:	60a6                	ld	ra,72(sp)
    18ac:	6406                	ld	s0,64(sp)
    18ae:	74e2                	ld	s1,56(sp)
    18b0:	7942                	ld	s2,48(sp)
    18b2:	79a2                	ld	s3,40(sp)
    18b4:	7a02                	ld	s4,32(sp)
    18b6:	6ae2                	ld	s5,24(sp)
    18b8:	6b42                	ld	s6,16(sp)
    18ba:	6161                	addi	sp,sp,80
    18bc:	8082                	ret
      total += n;
    18be:	00aa8abb          	addw	s5,s5,a0
      cc = cc * 2;
    18c2:	001a179b          	slliw	a5,s4,0x1
    18c6:	00078a1b          	sext.w	s4,a5
      if(cc > sizeof(buf))
    18ca:	ed4b7fe3          	bleu	s4,s6,17a8 <pipe1+0x4e>
        cc = sizeof(buf);
    18ce:	8a5a                	mv	s4,s6
    18d0:	bde1                	j	17a8 <pipe1+0x4e>
    if(total != N * SZ){
    18d2:	6785                	lui	a5,0x1
    18d4:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x69>
    18d8:	02fa8063          	beq	s5,a5,18f8 <pipe1+0x19e>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18dc:	85d6                	mv	a1,s5
    18de:	00005517          	auipc	a0,0x5
    18e2:	f1250513          	addi	a0,a0,-238 # 67f0 <malloc+0xe7c>
    18e6:	00004097          	auipc	ra,0x4
    18ea:	fce080e7          	jalr	-50(ra) # 58b4 <printf>
      exit(1);
    18ee:	4505                	li	a0,1
    18f0:	00004097          	auipc	ra,0x4
    18f4:	c4c080e7          	jalr	-948(ra) # 553c <exit>
    close(fds[0]);
    18f8:	fb842503          	lw	a0,-72(s0)
    18fc:	00004097          	auipc	ra,0x4
    1900:	c68080e7          	jalr	-920(ra) # 5564 <close>
    wait(&xstatus);
    1904:	fb440513          	addi	a0,s0,-76
    1908:	00004097          	auipc	ra,0x4
    190c:	c3c080e7          	jalr	-964(ra) # 5544 <wait>
    exit(xstatus);
    1910:	fb442503          	lw	a0,-76(s0)
    1914:	00004097          	auipc	ra,0x4
    1918:	c28080e7          	jalr	-984(ra) # 553c <exit>
    printf("%s: fork() failed\n", s);
    191c:	85ce                	mv	a1,s3
    191e:	00005517          	auipc	a0,0x5
    1922:	ef250513          	addi	a0,a0,-270 # 6810 <malloc+0xe9c>
    1926:	00004097          	auipc	ra,0x4
    192a:	f8e080e7          	jalr	-114(ra) # 58b4 <printf>
    exit(1);
    192e:	4505                	li	a0,1
    1930:	00004097          	auipc	ra,0x4
    1934:	c0c080e7          	jalr	-1012(ra) # 553c <exit>

0000000000001938 <exitwait>:
{
    1938:	7139                	addi	sp,sp,-64
    193a:	fc06                	sd	ra,56(sp)
    193c:	f822                	sd	s0,48(sp)
    193e:	f426                	sd	s1,40(sp)
    1940:	f04a                	sd	s2,32(sp)
    1942:	ec4e                	sd	s3,24(sp)
    1944:	e852                	sd	s4,16(sp)
    1946:	0080                	addi	s0,sp,64
    1948:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    194a:	4481                	li	s1,0
    194c:	06400993          	li	s3,100
    pid = fork();
    1950:	00004097          	auipc	ra,0x4
    1954:	be4080e7          	jalr	-1052(ra) # 5534 <fork>
    1958:	892a                	mv	s2,a0
    if(pid < 0){
    195a:	02054a63          	bltz	a0,198e <exitwait+0x56>
    if(pid){
    195e:	c151                	beqz	a0,19e2 <exitwait+0xaa>
      if(wait(&xstate) != pid){
    1960:	fcc40513          	addi	a0,s0,-52
    1964:	00004097          	auipc	ra,0x4
    1968:	be0080e7          	jalr	-1056(ra) # 5544 <wait>
    196c:	03251f63          	bne	a0,s2,19aa <exitwait+0x72>
      if(i != xstate) {
    1970:	fcc42783          	lw	a5,-52(s0)
    1974:	04979963          	bne	a5,s1,19c6 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1978:	2485                	addiw	s1,s1,1
    197a:	fd349be3          	bne	s1,s3,1950 <exitwait+0x18>
}
    197e:	70e2                	ld	ra,56(sp)
    1980:	7442                	ld	s0,48(sp)
    1982:	74a2                	ld	s1,40(sp)
    1984:	7902                	ld	s2,32(sp)
    1986:	69e2                	ld	s3,24(sp)
    1988:	6a42                	ld	s4,16(sp)
    198a:	6121                	addi	sp,sp,64
    198c:	8082                	ret
      printf("%s: fork failed\n", s);
    198e:	85d2                	mv	a1,s4
    1990:	00005517          	auipc	a0,0x5
    1994:	d1050513          	addi	a0,a0,-752 # 66a0 <malloc+0xd2c>
    1998:	00004097          	auipc	ra,0x4
    199c:	f1c080e7          	jalr	-228(ra) # 58b4 <printf>
      exit(1);
    19a0:	4505                	li	a0,1
    19a2:	00004097          	auipc	ra,0x4
    19a6:	b9a080e7          	jalr	-1126(ra) # 553c <exit>
        printf("%s: wait wrong pid\n", s);
    19aa:	85d2                	mv	a1,s4
    19ac:	00005517          	auipc	a0,0x5
    19b0:	e7c50513          	addi	a0,a0,-388 # 6828 <malloc+0xeb4>
    19b4:	00004097          	auipc	ra,0x4
    19b8:	f00080e7          	jalr	-256(ra) # 58b4 <printf>
        exit(1);
    19bc:	4505                	li	a0,1
    19be:	00004097          	auipc	ra,0x4
    19c2:	b7e080e7          	jalr	-1154(ra) # 553c <exit>
        printf("%s: wait wrong exit status\n", s);
    19c6:	85d2                	mv	a1,s4
    19c8:	00005517          	auipc	a0,0x5
    19cc:	e7850513          	addi	a0,a0,-392 # 6840 <malloc+0xecc>
    19d0:	00004097          	auipc	ra,0x4
    19d4:	ee4080e7          	jalr	-284(ra) # 58b4 <printf>
        exit(1);
    19d8:	4505                	li	a0,1
    19da:	00004097          	auipc	ra,0x4
    19de:	b62080e7          	jalr	-1182(ra) # 553c <exit>
      exit(i);
    19e2:	8526                	mv	a0,s1
    19e4:	00004097          	auipc	ra,0x4
    19e8:	b58080e7          	jalr	-1192(ra) # 553c <exit>

00000000000019ec <twochildren>:
{
    19ec:	1101                	addi	sp,sp,-32
    19ee:	ec06                	sd	ra,24(sp)
    19f0:	e822                	sd	s0,16(sp)
    19f2:	e426                	sd	s1,8(sp)
    19f4:	e04a                	sd	s2,0(sp)
    19f6:	1000                	addi	s0,sp,32
    19f8:	892a                	mv	s2,a0
    19fa:	3e800493          	li	s1,1000
    int pid1 = fork();
    19fe:	00004097          	auipc	ra,0x4
    1a02:	b36080e7          	jalr	-1226(ra) # 5534 <fork>
    if(pid1 < 0){
    1a06:	02054c63          	bltz	a0,1a3e <twochildren+0x52>
    if(pid1 == 0){
    1a0a:	c921                	beqz	a0,1a5a <twochildren+0x6e>
      int pid2 = fork();
    1a0c:	00004097          	auipc	ra,0x4
    1a10:	b28080e7          	jalr	-1240(ra) # 5534 <fork>
      if(pid2 < 0){
    1a14:	04054763          	bltz	a0,1a62 <twochildren+0x76>
      if(pid2 == 0){
    1a18:	c13d                	beqz	a0,1a7e <twochildren+0x92>
        wait(0);
    1a1a:	4501                	li	a0,0
    1a1c:	00004097          	auipc	ra,0x4
    1a20:	b28080e7          	jalr	-1240(ra) # 5544 <wait>
        wait(0);
    1a24:	4501                	li	a0,0
    1a26:	00004097          	auipc	ra,0x4
    1a2a:	b1e080e7          	jalr	-1250(ra) # 5544 <wait>
  for(int i = 0; i < 1000; i++){
    1a2e:	34fd                	addiw	s1,s1,-1
    1a30:	f4f9                	bnez	s1,19fe <twochildren+0x12>
}
    1a32:	60e2                	ld	ra,24(sp)
    1a34:	6442                	ld	s0,16(sp)
    1a36:	64a2                	ld	s1,8(sp)
    1a38:	6902                	ld	s2,0(sp)
    1a3a:	6105                	addi	sp,sp,32
    1a3c:	8082                	ret
      printf("%s: fork failed\n", s);
    1a3e:	85ca                	mv	a1,s2
    1a40:	00005517          	auipc	a0,0x5
    1a44:	c6050513          	addi	a0,a0,-928 # 66a0 <malloc+0xd2c>
    1a48:	00004097          	auipc	ra,0x4
    1a4c:	e6c080e7          	jalr	-404(ra) # 58b4 <printf>
      exit(1);
    1a50:	4505                	li	a0,1
    1a52:	00004097          	auipc	ra,0x4
    1a56:	aea080e7          	jalr	-1302(ra) # 553c <exit>
      exit(0);
    1a5a:	00004097          	auipc	ra,0x4
    1a5e:	ae2080e7          	jalr	-1310(ra) # 553c <exit>
        printf("%s: fork failed\n", s);
    1a62:	85ca                	mv	a1,s2
    1a64:	00005517          	auipc	a0,0x5
    1a68:	c3c50513          	addi	a0,a0,-964 # 66a0 <malloc+0xd2c>
    1a6c:	00004097          	auipc	ra,0x4
    1a70:	e48080e7          	jalr	-440(ra) # 58b4 <printf>
        exit(1);
    1a74:	4505                	li	a0,1
    1a76:	00004097          	auipc	ra,0x4
    1a7a:	ac6080e7          	jalr	-1338(ra) # 553c <exit>
        exit(0);
    1a7e:	00004097          	auipc	ra,0x4
    1a82:	abe080e7          	jalr	-1346(ra) # 553c <exit>

0000000000001a86 <forkfork>:
{
    1a86:	7179                	addi	sp,sp,-48
    1a88:	f406                	sd	ra,40(sp)
    1a8a:	f022                	sd	s0,32(sp)
    1a8c:	ec26                	sd	s1,24(sp)
    1a8e:	1800                	addi	s0,sp,48
    1a90:	84aa                	mv	s1,a0
    int pid = fork();
    1a92:	00004097          	auipc	ra,0x4
    1a96:	aa2080e7          	jalr	-1374(ra) # 5534 <fork>
    if(pid < 0){
    1a9a:	04054163          	bltz	a0,1adc <forkfork+0x56>
    if(pid == 0){
    1a9e:	cd29                	beqz	a0,1af8 <forkfork+0x72>
    int pid = fork();
    1aa0:	00004097          	auipc	ra,0x4
    1aa4:	a94080e7          	jalr	-1388(ra) # 5534 <fork>
    if(pid < 0){
    1aa8:	02054a63          	bltz	a0,1adc <forkfork+0x56>
    if(pid == 0){
    1aac:	c531                	beqz	a0,1af8 <forkfork+0x72>
    wait(&xstatus);
    1aae:	fdc40513          	addi	a0,s0,-36
    1ab2:	00004097          	auipc	ra,0x4
    1ab6:	a92080e7          	jalr	-1390(ra) # 5544 <wait>
    if(xstatus != 0) {
    1aba:	fdc42783          	lw	a5,-36(s0)
    1abe:	ebbd                	bnez	a5,1b34 <forkfork+0xae>
    wait(&xstatus);
    1ac0:	fdc40513          	addi	a0,s0,-36
    1ac4:	00004097          	auipc	ra,0x4
    1ac8:	a80080e7          	jalr	-1408(ra) # 5544 <wait>
    if(xstatus != 0) {
    1acc:	fdc42783          	lw	a5,-36(s0)
    1ad0:	e3b5                	bnez	a5,1b34 <forkfork+0xae>
}
    1ad2:	70a2                	ld	ra,40(sp)
    1ad4:	7402                	ld	s0,32(sp)
    1ad6:	64e2                	ld	s1,24(sp)
    1ad8:	6145                	addi	sp,sp,48
    1ada:	8082                	ret
      printf("%s: fork failed", s);
    1adc:	85a6                	mv	a1,s1
    1ade:	00005517          	auipc	a0,0x5
    1ae2:	d8250513          	addi	a0,a0,-638 # 6860 <malloc+0xeec>
    1ae6:	00004097          	auipc	ra,0x4
    1aea:	dce080e7          	jalr	-562(ra) # 58b4 <printf>
      exit(1);
    1aee:	4505                	li	a0,1
    1af0:	00004097          	auipc	ra,0x4
    1af4:	a4c080e7          	jalr	-1460(ra) # 553c <exit>
{
    1af8:	0c800493          	li	s1,200
        int pid1 = fork();
    1afc:	00004097          	auipc	ra,0x4
    1b00:	a38080e7          	jalr	-1480(ra) # 5534 <fork>
        if(pid1 < 0){
    1b04:	00054f63          	bltz	a0,1b22 <forkfork+0x9c>
        if(pid1 == 0){
    1b08:	c115                	beqz	a0,1b2c <forkfork+0xa6>
        wait(0);
    1b0a:	4501                	li	a0,0
    1b0c:	00004097          	auipc	ra,0x4
    1b10:	a38080e7          	jalr	-1480(ra) # 5544 <wait>
      for(int j = 0; j < 200; j++){
    1b14:	34fd                	addiw	s1,s1,-1
    1b16:	f0fd                	bnez	s1,1afc <forkfork+0x76>
      exit(0);
    1b18:	4501                	li	a0,0
    1b1a:	00004097          	auipc	ra,0x4
    1b1e:	a22080e7          	jalr	-1502(ra) # 553c <exit>
          exit(1);
    1b22:	4505                	li	a0,1
    1b24:	00004097          	auipc	ra,0x4
    1b28:	a18080e7          	jalr	-1512(ra) # 553c <exit>
          exit(0);
    1b2c:	00004097          	auipc	ra,0x4
    1b30:	a10080e7          	jalr	-1520(ra) # 553c <exit>
      printf("%s: fork in child failed", s);
    1b34:	85a6                	mv	a1,s1
    1b36:	00005517          	auipc	a0,0x5
    1b3a:	d3a50513          	addi	a0,a0,-710 # 6870 <malloc+0xefc>
    1b3e:	00004097          	auipc	ra,0x4
    1b42:	d76080e7          	jalr	-650(ra) # 58b4 <printf>
      exit(1);
    1b46:	4505                	li	a0,1
    1b48:	00004097          	auipc	ra,0x4
    1b4c:	9f4080e7          	jalr	-1548(ra) # 553c <exit>

0000000000001b50 <reparent2>:
{
    1b50:	1101                	addi	sp,sp,-32
    1b52:	ec06                	sd	ra,24(sp)
    1b54:	e822                	sd	s0,16(sp)
    1b56:	e426                	sd	s1,8(sp)
    1b58:	1000                	addi	s0,sp,32
    1b5a:	32000493          	li	s1,800
    int pid1 = fork();
    1b5e:	00004097          	auipc	ra,0x4
    1b62:	9d6080e7          	jalr	-1578(ra) # 5534 <fork>
    if(pid1 < 0){
    1b66:	00054f63          	bltz	a0,1b84 <reparent2+0x34>
    if(pid1 == 0){
    1b6a:	c915                	beqz	a0,1b9e <reparent2+0x4e>
    wait(0);
    1b6c:	4501                	li	a0,0
    1b6e:	00004097          	auipc	ra,0x4
    1b72:	9d6080e7          	jalr	-1578(ra) # 5544 <wait>
  for(int i = 0; i < 800; i++){
    1b76:	34fd                	addiw	s1,s1,-1
    1b78:	f0fd                	bnez	s1,1b5e <reparent2+0xe>
  exit(0);
    1b7a:	4501                	li	a0,0
    1b7c:	00004097          	auipc	ra,0x4
    1b80:	9c0080e7          	jalr	-1600(ra) # 553c <exit>
      printf("fork failed\n");
    1b84:	00005517          	auipc	a0,0x5
    1b88:	f0c50513          	addi	a0,a0,-244 # 6a90 <malloc+0x111c>
    1b8c:	00004097          	auipc	ra,0x4
    1b90:	d28080e7          	jalr	-728(ra) # 58b4 <printf>
      exit(1);
    1b94:	4505                	li	a0,1
    1b96:	00004097          	auipc	ra,0x4
    1b9a:	9a6080e7          	jalr	-1626(ra) # 553c <exit>
      fork();
    1b9e:	00004097          	auipc	ra,0x4
    1ba2:	996080e7          	jalr	-1642(ra) # 5534 <fork>
      fork();
    1ba6:	00004097          	auipc	ra,0x4
    1baa:	98e080e7          	jalr	-1650(ra) # 5534 <fork>
      exit(0);
    1bae:	4501                	li	a0,0
    1bb0:	00004097          	auipc	ra,0x4
    1bb4:	98c080e7          	jalr	-1652(ra) # 553c <exit>

0000000000001bb8 <createdelete>:
{
    1bb8:	7175                	addi	sp,sp,-144
    1bba:	e506                	sd	ra,136(sp)
    1bbc:	e122                	sd	s0,128(sp)
    1bbe:	fca6                	sd	s1,120(sp)
    1bc0:	f8ca                	sd	s2,112(sp)
    1bc2:	f4ce                	sd	s3,104(sp)
    1bc4:	f0d2                	sd	s4,96(sp)
    1bc6:	ecd6                	sd	s5,88(sp)
    1bc8:	e8da                	sd	s6,80(sp)
    1bca:	e4de                	sd	s7,72(sp)
    1bcc:	e0e2                	sd	s8,64(sp)
    1bce:	fc66                	sd	s9,56(sp)
    1bd0:	0900                	addi	s0,sp,144
    1bd2:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1bd4:	4901                	li	s2,0
    1bd6:	4991                	li	s3,4
    pid = fork();
    1bd8:	00004097          	auipc	ra,0x4
    1bdc:	95c080e7          	jalr	-1700(ra) # 5534 <fork>
    1be0:	84aa                	mv	s1,a0
    if(pid < 0){
    1be2:	02054f63          	bltz	a0,1c20 <createdelete+0x68>
    if(pid == 0){
    1be6:	c939                	beqz	a0,1c3c <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1be8:	2905                	addiw	s2,s2,1
    1bea:	ff3917e3          	bne	s2,s3,1bd8 <createdelete+0x20>
    1bee:	4491                	li	s1,4
    wait(&xstatus);
    1bf0:	f7c40513          	addi	a0,s0,-132
    1bf4:	00004097          	auipc	ra,0x4
    1bf8:	950080e7          	jalr	-1712(ra) # 5544 <wait>
    if(xstatus != 0)
    1bfc:	f7c42903          	lw	s2,-132(s0)
    1c00:	0e091263          	bnez	s2,1ce4 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1c04:	34fd                	addiw	s1,s1,-1
    1c06:	f4ed                	bnez	s1,1bf0 <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1c08:	f8040123          	sb	zero,-126(s0)
    1c0c:	03000993          	li	s3,48
    1c10:	5a7d                	li	s4,-1
    1c12:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1c16:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1c18:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1c1a:	07400a93          	li	s5,116
    1c1e:	a29d                	j	1d84 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c20:	85e6                	mv	a1,s9
    1c22:	00005517          	auipc	a0,0x5
    1c26:	e6e50513          	addi	a0,a0,-402 # 6a90 <malloc+0x111c>
    1c2a:	00004097          	auipc	ra,0x4
    1c2e:	c8a080e7          	jalr	-886(ra) # 58b4 <printf>
      exit(1);
    1c32:	4505                	li	a0,1
    1c34:	00004097          	auipc	ra,0x4
    1c38:	908080e7          	jalr	-1784(ra) # 553c <exit>
      name[0] = 'p' + pi;
    1c3c:	0709091b          	addiw	s2,s2,112
    1c40:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c44:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c48:	4951                	li	s2,20
    1c4a:	a015                	j	1c6e <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c4c:	85e6                	mv	a1,s9
    1c4e:	00005517          	auipc	a0,0x5
    1c52:	aea50513          	addi	a0,a0,-1302 # 6738 <malloc+0xdc4>
    1c56:	00004097          	auipc	ra,0x4
    1c5a:	c5e080e7          	jalr	-930(ra) # 58b4 <printf>
          exit(1);
    1c5e:	4505                	li	a0,1
    1c60:	00004097          	auipc	ra,0x4
    1c64:	8dc080e7          	jalr	-1828(ra) # 553c <exit>
      for(i = 0; i < N; i++){
    1c68:	2485                	addiw	s1,s1,1
    1c6a:	07248863          	beq	s1,s2,1cda <createdelete+0x122>
        name[1] = '0' + i;
    1c6e:	0304879b          	addiw	a5,s1,48
    1c72:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c76:	20200593          	li	a1,514
    1c7a:	f8040513          	addi	a0,s0,-128
    1c7e:	00004097          	auipc	ra,0x4
    1c82:	8fe080e7          	jalr	-1794(ra) # 557c <open>
        if(fd < 0){
    1c86:	fc0543e3          	bltz	a0,1c4c <createdelete+0x94>
        close(fd);
    1c8a:	00004097          	auipc	ra,0x4
    1c8e:	8da080e7          	jalr	-1830(ra) # 5564 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c92:	fc905be3          	blez	s1,1c68 <createdelete+0xb0>
    1c96:	0014f793          	andi	a5,s1,1
    1c9a:	f7f9                	bnez	a5,1c68 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1c9c:	01f4d79b          	srliw	a5,s1,0x1f
    1ca0:	9fa5                	addw	a5,a5,s1
    1ca2:	4017d79b          	sraiw	a5,a5,0x1
    1ca6:	0307879b          	addiw	a5,a5,48
    1caa:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1cae:	f8040513          	addi	a0,s0,-128
    1cb2:	00004097          	auipc	ra,0x4
    1cb6:	8da080e7          	jalr	-1830(ra) # 558c <unlink>
    1cba:	fa0557e3          	bgez	a0,1c68 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1cbe:	85e6                	mv	a1,s9
    1cc0:	00005517          	auipc	a0,0x5
    1cc4:	bd050513          	addi	a0,a0,-1072 # 6890 <malloc+0xf1c>
    1cc8:	00004097          	auipc	ra,0x4
    1ccc:	bec080e7          	jalr	-1044(ra) # 58b4 <printf>
            exit(1);
    1cd0:	4505                	li	a0,1
    1cd2:	00004097          	auipc	ra,0x4
    1cd6:	86a080e7          	jalr	-1942(ra) # 553c <exit>
      exit(0);
    1cda:	4501                	li	a0,0
    1cdc:	00004097          	auipc	ra,0x4
    1ce0:	860080e7          	jalr	-1952(ra) # 553c <exit>
      exit(1);
    1ce4:	4505                	li	a0,1
    1ce6:	00004097          	auipc	ra,0x4
    1cea:	856080e7          	jalr	-1962(ra) # 553c <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cee:	f8040613          	addi	a2,s0,-128
    1cf2:	85e6                	mv	a1,s9
    1cf4:	00005517          	auipc	a0,0x5
    1cf8:	bb450513          	addi	a0,a0,-1100 # 68a8 <malloc+0xf34>
    1cfc:	00004097          	auipc	ra,0x4
    1d00:	bb8080e7          	jalr	-1096(ra) # 58b4 <printf>
        exit(1);
    1d04:	4505                	li	a0,1
    1d06:	00004097          	auipc	ra,0x4
    1d0a:	836080e7          	jalr	-1994(ra) # 553c <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d0e:	054b7163          	bleu	s4,s6,1d50 <createdelete+0x198>
      if(fd >= 0)
    1d12:	02055a63          	bgez	a0,1d46 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1d16:	2485                	addiw	s1,s1,1
    1d18:	0ff4f493          	andi	s1,s1,255
    1d1c:	05548c63          	beq	s1,s5,1d74 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d20:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d24:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d28:	4581                	li	a1,0
    1d2a:	f8040513          	addi	a0,s0,-128
    1d2e:	00004097          	auipc	ra,0x4
    1d32:	84e080e7          	jalr	-1970(ra) # 557c <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d36:	00090463          	beqz	s2,1d3e <createdelete+0x186>
    1d3a:	fd2bdae3          	ble	s2,s7,1d0e <createdelete+0x156>
    1d3e:	fa0548e3          	bltz	a0,1cee <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d42:	014b7963          	bleu	s4,s6,1d54 <createdelete+0x19c>
        close(fd);
    1d46:	00004097          	auipc	ra,0x4
    1d4a:	81e080e7          	jalr	-2018(ra) # 5564 <close>
    1d4e:	b7e1                	j	1d16 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d50:	fc0543e3          	bltz	a0,1d16 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d54:	f8040613          	addi	a2,s0,-128
    1d58:	85e6                	mv	a1,s9
    1d5a:	00005517          	auipc	a0,0x5
    1d5e:	b7650513          	addi	a0,a0,-1162 # 68d0 <malloc+0xf5c>
    1d62:	00004097          	auipc	ra,0x4
    1d66:	b52080e7          	jalr	-1198(ra) # 58b4 <printf>
        exit(1);
    1d6a:	4505                	li	a0,1
    1d6c:	00003097          	auipc	ra,0x3
    1d70:	7d0080e7          	jalr	2000(ra) # 553c <exit>
  for(i = 0; i < N; i++){
    1d74:	2905                	addiw	s2,s2,1
    1d76:	2a05                	addiw	s4,s4,1
    1d78:	2985                	addiw	s3,s3,1
    1d7a:	0ff9f993          	andi	s3,s3,255
    1d7e:	47d1                	li	a5,20
    1d80:	02f90a63          	beq	s2,a5,1db4 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d84:	84e2                	mv	s1,s8
    1d86:	bf69                	j	1d20 <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d88:	2905                	addiw	s2,s2,1
    1d8a:	0ff97913          	andi	s2,s2,255
    1d8e:	2985                	addiw	s3,s3,1
    1d90:	0ff9f993          	andi	s3,s3,255
    1d94:	03490863          	beq	s2,s4,1dc4 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1d98:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1d9a:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1d9e:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1da2:	f8040513          	addi	a0,s0,-128
    1da6:	00003097          	auipc	ra,0x3
    1daa:	7e6080e7          	jalr	2022(ra) # 558c <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1dae:	34fd                	addiw	s1,s1,-1
    1db0:	f4ed                	bnez	s1,1d9a <createdelete+0x1e2>
    1db2:	bfd9                	j	1d88 <createdelete+0x1d0>
    1db4:	03000993          	li	s3,48
    1db8:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1dbc:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1dbe:	08400a13          	li	s4,132
    1dc2:	bfd9                	j	1d98 <createdelete+0x1e0>
}
    1dc4:	60aa                	ld	ra,136(sp)
    1dc6:	640a                	ld	s0,128(sp)
    1dc8:	74e6                	ld	s1,120(sp)
    1dca:	7946                	ld	s2,112(sp)
    1dcc:	79a6                	ld	s3,104(sp)
    1dce:	7a06                	ld	s4,96(sp)
    1dd0:	6ae6                	ld	s5,88(sp)
    1dd2:	6b46                	ld	s6,80(sp)
    1dd4:	6ba6                	ld	s7,72(sp)
    1dd6:	6c06                	ld	s8,64(sp)
    1dd8:	7ce2                	ld	s9,56(sp)
    1dda:	6149                	addi	sp,sp,144
    1ddc:	8082                	ret

0000000000001dde <linkunlink>:
{
    1dde:	711d                	addi	sp,sp,-96
    1de0:	ec86                	sd	ra,88(sp)
    1de2:	e8a2                	sd	s0,80(sp)
    1de4:	e4a6                	sd	s1,72(sp)
    1de6:	e0ca                	sd	s2,64(sp)
    1de8:	fc4e                	sd	s3,56(sp)
    1dea:	f852                	sd	s4,48(sp)
    1dec:	f456                	sd	s5,40(sp)
    1dee:	f05a                	sd	s6,32(sp)
    1df0:	ec5e                	sd	s7,24(sp)
    1df2:	e862                	sd	s8,16(sp)
    1df4:	e466                	sd	s9,8(sp)
    1df6:	1080                	addi	s0,sp,96
    1df8:	84aa                	mv	s1,a0
  unlink("x");
    1dfa:	00004517          	auipc	a0,0x4
    1dfe:	0be50513          	addi	a0,a0,190 # 5eb8 <malloc+0x544>
    1e02:	00003097          	auipc	ra,0x3
    1e06:	78a080e7          	jalr	1930(ra) # 558c <unlink>
  pid = fork();
    1e0a:	00003097          	auipc	ra,0x3
    1e0e:	72a080e7          	jalr	1834(ra) # 5534 <fork>
  if(pid < 0){
    1e12:	02054b63          	bltz	a0,1e48 <linkunlink+0x6a>
    1e16:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1e18:	4c85                	li	s9,1
    1e1a:	e119                	bnez	a0,1e20 <linkunlink+0x42>
    1e1c:	06100c93          	li	s9,97
    1e20:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e24:	41c659b7          	lui	s3,0x41c65
    1e28:	e6d9899b          	addiw	s3,s3,-403
    1e2c:	690d                	lui	s2,0x3
    1e2e:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e32:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e34:	4b05                	li	s6,1
      unlink("x");
    1e36:	00004a97          	auipc	s5,0x4
    1e3a:	082a8a93          	addi	s5,s5,130 # 5eb8 <malloc+0x544>
      link("cat", "x");
    1e3e:	00005b97          	auipc	s7,0x5
    1e42:	abab8b93          	addi	s7,s7,-1350 # 68f8 <malloc+0xf84>
    1e46:	a091                	j	1e8a <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e48:	85a6                	mv	a1,s1
    1e4a:	00005517          	auipc	a0,0x5
    1e4e:	85650513          	addi	a0,a0,-1962 # 66a0 <malloc+0xd2c>
    1e52:	00004097          	auipc	ra,0x4
    1e56:	a62080e7          	jalr	-1438(ra) # 58b4 <printf>
    exit(1);
    1e5a:	4505                	li	a0,1
    1e5c:	00003097          	auipc	ra,0x3
    1e60:	6e0080e7          	jalr	1760(ra) # 553c <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e64:	20200593          	li	a1,514
    1e68:	8556                	mv	a0,s5
    1e6a:	00003097          	auipc	ra,0x3
    1e6e:	712080e7          	jalr	1810(ra) # 557c <open>
    1e72:	00003097          	auipc	ra,0x3
    1e76:	6f2080e7          	jalr	1778(ra) # 5564 <close>
    1e7a:	a031                	j	1e86 <linkunlink+0xa8>
      unlink("x");
    1e7c:	8556                	mv	a0,s5
    1e7e:	00003097          	auipc	ra,0x3
    1e82:	70e080e7          	jalr	1806(ra) # 558c <unlink>
  for(i = 0; i < 100; i++){
    1e86:	34fd                	addiw	s1,s1,-1
    1e88:	c09d                	beqz	s1,1eae <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e8a:	033c87bb          	mulw	a5,s9,s3
    1e8e:	012787bb          	addw	a5,a5,s2
    1e92:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1e96:	0347f7bb          	remuw	a5,a5,s4
    1e9a:	d7e9                	beqz	a5,1e64 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1e9c:	ff6790e3          	bne	a5,s6,1e7c <linkunlink+0x9e>
      link("cat", "x");
    1ea0:	85d6                	mv	a1,s5
    1ea2:	855e                	mv	a0,s7
    1ea4:	00003097          	auipc	ra,0x3
    1ea8:	6f8080e7          	jalr	1784(ra) # 559c <link>
    1eac:	bfe9                	j	1e86 <linkunlink+0xa8>
  if(pid)
    1eae:	020c0463          	beqz	s8,1ed6 <linkunlink+0xf8>
    wait(0);
    1eb2:	4501                	li	a0,0
    1eb4:	00003097          	auipc	ra,0x3
    1eb8:	690080e7          	jalr	1680(ra) # 5544 <wait>
}
    1ebc:	60e6                	ld	ra,88(sp)
    1ebe:	6446                	ld	s0,80(sp)
    1ec0:	64a6                	ld	s1,72(sp)
    1ec2:	6906                	ld	s2,64(sp)
    1ec4:	79e2                	ld	s3,56(sp)
    1ec6:	7a42                	ld	s4,48(sp)
    1ec8:	7aa2                	ld	s5,40(sp)
    1eca:	7b02                	ld	s6,32(sp)
    1ecc:	6be2                	ld	s7,24(sp)
    1ece:	6c42                	ld	s8,16(sp)
    1ed0:	6ca2                	ld	s9,8(sp)
    1ed2:	6125                	addi	sp,sp,96
    1ed4:	8082                	ret
    exit(0);
    1ed6:	4501                	li	a0,0
    1ed8:	00003097          	auipc	ra,0x3
    1edc:	664080e7          	jalr	1636(ra) # 553c <exit>

0000000000001ee0 <forktest>:
{
    1ee0:	7179                	addi	sp,sp,-48
    1ee2:	f406                	sd	ra,40(sp)
    1ee4:	f022                	sd	s0,32(sp)
    1ee6:	ec26                	sd	s1,24(sp)
    1ee8:	e84a                	sd	s2,16(sp)
    1eea:	e44e                	sd	s3,8(sp)
    1eec:	1800                	addi	s0,sp,48
    1eee:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1ef0:	4481                	li	s1,0
    1ef2:	3e800913          	li	s2,1000
    pid = fork();
    1ef6:	00003097          	auipc	ra,0x3
    1efa:	63e080e7          	jalr	1598(ra) # 5534 <fork>
    if(pid < 0)
    1efe:	02054863          	bltz	a0,1f2e <forktest+0x4e>
    if(pid == 0)
    1f02:	c115                	beqz	a0,1f26 <forktest+0x46>
  for(n=0; n<N; n++){
    1f04:	2485                	addiw	s1,s1,1
    1f06:	ff2498e3          	bne	s1,s2,1ef6 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1f0a:	85ce                	mv	a1,s3
    1f0c:	00005517          	auipc	a0,0x5
    1f10:	a0c50513          	addi	a0,a0,-1524 # 6918 <malloc+0xfa4>
    1f14:	00004097          	auipc	ra,0x4
    1f18:	9a0080e7          	jalr	-1632(ra) # 58b4 <printf>
    exit(1);
    1f1c:	4505                	li	a0,1
    1f1e:	00003097          	auipc	ra,0x3
    1f22:	61e080e7          	jalr	1566(ra) # 553c <exit>
      exit(0);
    1f26:	00003097          	auipc	ra,0x3
    1f2a:	616080e7          	jalr	1558(ra) # 553c <exit>
  if (n == 0) {
    1f2e:	cc9d                	beqz	s1,1f6c <forktest+0x8c>
  if(n == N){
    1f30:	3e800793          	li	a5,1000
    1f34:	fcf48be3          	beq	s1,a5,1f0a <forktest+0x2a>
  for(; n > 0; n--){
    1f38:	00905b63          	blez	s1,1f4e <forktest+0x6e>
    if(wait(0) < 0){
    1f3c:	4501                	li	a0,0
    1f3e:	00003097          	auipc	ra,0x3
    1f42:	606080e7          	jalr	1542(ra) # 5544 <wait>
    1f46:	04054163          	bltz	a0,1f88 <forktest+0xa8>
  for(; n > 0; n--){
    1f4a:	34fd                	addiw	s1,s1,-1
    1f4c:	f8e5                	bnez	s1,1f3c <forktest+0x5c>
  if(wait(0) != -1){
    1f4e:	4501                	li	a0,0
    1f50:	00003097          	auipc	ra,0x3
    1f54:	5f4080e7          	jalr	1524(ra) # 5544 <wait>
    1f58:	57fd                	li	a5,-1
    1f5a:	04f51563          	bne	a0,a5,1fa4 <forktest+0xc4>
}
    1f5e:	70a2                	ld	ra,40(sp)
    1f60:	7402                	ld	s0,32(sp)
    1f62:	64e2                	ld	s1,24(sp)
    1f64:	6942                	ld	s2,16(sp)
    1f66:	69a2                	ld	s3,8(sp)
    1f68:	6145                	addi	sp,sp,48
    1f6a:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1f6c:	85ce                	mv	a1,s3
    1f6e:	00005517          	auipc	a0,0x5
    1f72:	99250513          	addi	a0,a0,-1646 # 6900 <malloc+0xf8c>
    1f76:	00004097          	auipc	ra,0x4
    1f7a:	93e080e7          	jalr	-1730(ra) # 58b4 <printf>
    exit(1);
    1f7e:	4505                	li	a0,1
    1f80:	00003097          	auipc	ra,0x3
    1f84:	5bc080e7          	jalr	1468(ra) # 553c <exit>
      printf("%s: wait stopped early\n", s);
    1f88:	85ce                	mv	a1,s3
    1f8a:	00005517          	auipc	a0,0x5
    1f8e:	9b650513          	addi	a0,a0,-1610 # 6940 <malloc+0xfcc>
    1f92:	00004097          	auipc	ra,0x4
    1f96:	922080e7          	jalr	-1758(ra) # 58b4 <printf>
      exit(1);
    1f9a:	4505                	li	a0,1
    1f9c:	00003097          	auipc	ra,0x3
    1fa0:	5a0080e7          	jalr	1440(ra) # 553c <exit>
    printf("%s: wait got too many\n", s);
    1fa4:	85ce                	mv	a1,s3
    1fa6:	00005517          	auipc	a0,0x5
    1faa:	9b250513          	addi	a0,a0,-1614 # 6958 <malloc+0xfe4>
    1fae:	00004097          	auipc	ra,0x4
    1fb2:	906080e7          	jalr	-1786(ra) # 58b4 <printf>
    exit(1);
    1fb6:	4505                	li	a0,1
    1fb8:	00003097          	auipc	ra,0x3
    1fbc:	584080e7          	jalr	1412(ra) # 553c <exit>

0000000000001fc0 <kernmem>:
{
    1fc0:	715d                	addi	sp,sp,-80
    1fc2:	e486                	sd	ra,72(sp)
    1fc4:	e0a2                	sd	s0,64(sp)
    1fc6:	fc26                	sd	s1,56(sp)
    1fc8:	f84a                	sd	s2,48(sp)
    1fca:	f44e                	sd	s3,40(sp)
    1fcc:	f052                	sd	s4,32(sp)
    1fce:	ec56                	sd	s5,24(sp)
    1fd0:	0880                	addi	s0,sp,80
    1fd2:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fd4:	4485                	li	s1,1
    1fd6:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1fd8:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fda:	69b1                	lui	s3,0xc
    1fdc:	35098993          	addi	s3,s3,848 # c350 <buf+0x990>
    1fe0:	1003d937          	lui	s2,0x1003d
    1fe4:	090e                	slli	s2,s2,0x3
    1fe6:	48090913          	addi	s2,s2,1152 # 1003d480 <_end+0x1002eab0>
    pid = fork();
    1fea:	00003097          	auipc	ra,0x3
    1fee:	54a080e7          	jalr	1354(ra) # 5534 <fork>
    if(pid < 0){
    1ff2:	02054963          	bltz	a0,2024 <kernmem+0x64>
    if(pid == 0){
    1ff6:	c529                	beqz	a0,2040 <kernmem+0x80>
    wait(&xstatus);
    1ff8:	fbc40513          	addi	a0,s0,-68
    1ffc:	00003097          	auipc	ra,0x3
    2000:	548080e7          	jalr	1352(ra) # 5544 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2004:	fbc42783          	lw	a5,-68(s0)
    2008:	05479c63          	bne	a5,s4,2060 <kernmem+0xa0>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    200c:	94ce                	add	s1,s1,s3
    200e:	fd249ee3          	bne	s1,s2,1fea <kernmem+0x2a>
}
    2012:	60a6                	ld	ra,72(sp)
    2014:	6406                	ld	s0,64(sp)
    2016:	74e2                	ld	s1,56(sp)
    2018:	7942                	ld	s2,48(sp)
    201a:	79a2                	ld	s3,40(sp)
    201c:	7a02                	ld	s4,32(sp)
    201e:	6ae2                	ld	s5,24(sp)
    2020:	6161                	addi	sp,sp,80
    2022:	8082                	ret
      printf("%s: fork failed\n", s);
    2024:	85d6                	mv	a1,s5
    2026:	00004517          	auipc	a0,0x4
    202a:	67a50513          	addi	a0,a0,1658 # 66a0 <malloc+0xd2c>
    202e:	00004097          	auipc	ra,0x4
    2032:	886080e7          	jalr	-1914(ra) # 58b4 <printf>
      exit(1);
    2036:	4505                	li	a0,1
    2038:	00003097          	auipc	ra,0x3
    203c:	504080e7          	jalr	1284(ra) # 553c <exit>
      printf("%s: oops could read %x = %x\n", a, *a);
    2040:	0004c603          	lbu	a2,0(s1)
    2044:	85a6                	mv	a1,s1
    2046:	00005517          	auipc	a0,0x5
    204a:	92a50513          	addi	a0,a0,-1750 # 6970 <malloc+0xffc>
    204e:	00004097          	auipc	ra,0x4
    2052:	866080e7          	jalr	-1946(ra) # 58b4 <printf>
      exit(1);
    2056:	4505                	li	a0,1
    2058:	00003097          	auipc	ra,0x3
    205c:	4e4080e7          	jalr	1252(ra) # 553c <exit>
      exit(1);
    2060:	4505                	li	a0,1
    2062:	00003097          	auipc	ra,0x3
    2066:	4da080e7          	jalr	1242(ra) # 553c <exit>

000000000000206a <bigargtest>:
{
    206a:	7179                	addi	sp,sp,-48
    206c:	f406                	sd	ra,40(sp)
    206e:	f022                	sd	s0,32(sp)
    2070:	ec26                	sd	s1,24(sp)
    2072:	1800                	addi	s0,sp,48
    2074:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2076:	00005517          	auipc	a0,0x5
    207a:	91a50513          	addi	a0,a0,-1766 # 6990 <malloc+0x101c>
    207e:	00003097          	auipc	ra,0x3
    2082:	50e080e7          	jalr	1294(ra) # 558c <unlink>
  pid = fork();
    2086:	00003097          	auipc	ra,0x3
    208a:	4ae080e7          	jalr	1198(ra) # 5534 <fork>
  if(pid == 0){
    208e:	c121                	beqz	a0,20ce <bigargtest+0x64>
  } else if(pid < 0){
    2090:	0a054063          	bltz	a0,2130 <bigargtest+0xc6>
  wait(&xstatus);
    2094:	fdc40513          	addi	a0,s0,-36
    2098:	00003097          	auipc	ra,0x3
    209c:	4ac080e7          	jalr	1196(ra) # 5544 <wait>
  if(xstatus != 0)
    20a0:	fdc42503          	lw	a0,-36(s0)
    20a4:	e545                	bnez	a0,214c <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    20a6:	4581                	li	a1,0
    20a8:	00005517          	auipc	a0,0x5
    20ac:	8e850513          	addi	a0,a0,-1816 # 6990 <malloc+0x101c>
    20b0:	00003097          	auipc	ra,0x3
    20b4:	4cc080e7          	jalr	1228(ra) # 557c <open>
  if(fd < 0){
    20b8:	08054e63          	bltz	a0,2154 <bigargtest+0xea>
  close(fd);
    20bc:	00003097          	auipc	ra,0x3
    20c0:	4a8080e7          	jalr	1192(ra) # 5564 <close>
}
    20c4:	70a2                	ld	ra,40(sp)
    20c6:	7402                	ld	s0,32(sp)
    20c8:	64e2                	ld	s1,24(sp)
    20ca:	6145                	addi	sp,sp,48
    20cc:	8082                	ret
    20ce:	00006797          	auipc	a5,0x6
    20d2:	0da78793          	addi	a5,a5,218 # 81a8 <args.1827>
    20d6:	00006697          	auipc	a3,0x6
    20da:	1ca68693          	addi	a3,a3,458 # 82a0 <args.1827+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    20de:	00005717          	auipc	a4,0x5
    20e2:	8c270713          	addi	a4,a4,-1854 # 69a0 <malloc+0x102c>
    20e6:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    20e8:	07a1                	addi	a5,a5,8
    20ea:	fed79ee3          	bne	a5,a3,20e6 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    20ee:	00006597          	auipc	a1,0x6
    20f2:	0ba58593          	addi	a1,a1,186 # 81a8 <args.1827>
    20f6:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    20fa:	00004517          	auipc	a0,0x4
    20fe:	d4e50513          	addi	a0,a0,-690 # 5e48 <malloc+0x4d4>
    2102:	00003097          	auipc	ra,0x3
    2106:	472080e7          	jalr	1138(ra) # 5574 <exec>
    fd = open("bigarg-ok", O_CREATE);
    210a:	20000593          	li	a1,512
    210e:	00005517          	auipc	a0,0x5
    2112:	88250513          	addi	a0,a0,-1918 # 6990 <malloc+0x101c>
    2116:	00003097          	auipc	ra,0x3
    211a:	466080e7          	jalr	1126(ra) # 557c <open>
    close(fd);
    211e:	00003097          	auipc	ra,0x3
    2122:	446080e7          	jalr	1094(ra) # 5564 <close>
    exit(0);
    2126:	4501                	li	a0,0
    2128:	00003097          	auipc	ra,0x3
    212c:	414080e7          	jalr	1044(ra) # 553c <exit>
    printf("%s: bigargtest: fork failed\n", s);
    2130:	85a6                	mv	a1,s1
    2132:	00005517          	auipc	a0,0x5
    2136:	94e50513          	addi	a0,a0,-1714 # 6a80 <malloc+0x110c>
    213a:	00003097          	auipc	ra,0x3
    213e:	77a080e7          	jalr	1914(ra) # 58b4 <printf>
    exit(1);
    2142:	4505                	li	a0,1
    2144:	00003097          	auipc	ra,0x3
    2148:	3f8080e7          	jalr	1016(ra) # 553c <exit>
    exit(xstatus);
    214c:	00003097          	auipc	ra,0x3
    2150:	3f0080e7          	jalr	1008(ra) # 553c <exit>
    printf("%s: bigarg test failed!\n", s);
    2154:	85a6                	mv	a1,s1
    2156:	00005517          	auipc	a0,0x5
    215a:	94a50513          	addi	a0,a0,-1718 # 6aa0 <malloc+0x112c>
    215e:	00003097          	auipc	ra,0x3
    2162:	756080e7          	jalr	1878(ra) # 58b4 <printf>
    exit(1);
    2166:	4505                	li	a0,1
    2168:	00003097          	auipc	ra,0x3
    216c:	3d4080e7          	jalr	980(ra) # 553c <exit>

0000000000002170 <stacktest>:
{
    2170:	7179                	addi	sp,sp,-48
    2172:	f406                	sd	ra,40(sp)
    2174:	f022                	sd	s0,32(sp)
    2176:	ec26                	sd	s1,24(sp)
    2178:	1800                	addi	s0,sp,48
    217a:	84aa                	mv	s1,a0
  pid = fork();
    217c:	00003097          	auipc	ra,0x3
    2180:	3b8080e7          	jalr	952(ra) # 5534 <fork>
  if(pid == 0) {
    2184:	c115                	beqz	a0,21a8 <stacktest+0x38>
  } else if(pid < 0){
    2186:	04054363          	bltz	a0,21cc <stacktest+0x5c>
  wait(&xstatus);
    218a:	fdc40513          	addi	a0,s0,-36
    218e:	00003097          	auipc	ra,0x3
    2192:	3b6080e7          	jalr	950(ra) # 5544 <wait>
  if(xstatus == -1)  // kernel killed child?
    2196:	fdc42503          	lw	a0,-36(s0)
    219a:	57fd                	li	a5,-1
    219c:	04f50663          	beq	a0,a5,21e8 <stacktest+0x78>
    exit(xstatus);
    21a0:	00003097          	auipc	ra,0x3
    21a4:	39c080e7          	jalr	924(ra) # 553c <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    21a8:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", *sp);
    21aa:	77fd                	lui	a5,0xfffff
    21ac:	97ba                	add	a5,a5,a4
    21ae:	0007c583          	lbu	a1,0(a5) # fffffffffffff000 <_end+0xffffffffffff0630>
    21b2:	00005517          	auipc	a0,0x5
    21b6:	90e50513          	addi	a0,a0,-1778 # 6ac0 <malloc+0x114c>
    21ba:	00003097          	auipc	ra,0x3
    21be:	6fa080e7          	jalr	1786(ra) # 58b4 <printf>
    exit(1);
    21c2:	4505                	li	a0,1
    21c4:	00003097          	auipc	ra,0x3
    21c8:	378080e7          	jalr	888(ra) # 553c <exit>
    printf("%s: fork failed\n", s);
    21cc:	85a6                	mv	a1,s1
    21ce:	00004517          	auipc	a0,0x4
    21d2:	4d250513          	addi	a0,a0,1234 # 66a0 <malloc+0xd2c>
    21d6:	00003097          	auipc	ra,0x3
    21da:	6de080e7          	jalr	1758(ra) # 58b4 <printf>
    exit(1);
    21de:	4505                	li	a0,1
    21e0:	00003097          	auipc	ra,0x3
    21e4:	35c080e7          	jalr	860(ra) # 553c <exit>
    exit(0);
    21e8:	4501                	li	a0,0
    21ea:	00003097          	auipc	ra,0x3
    21ee:	352080e7          	jalr	850(ra) # 553c <exit>

00000000000021f2 <copyinstr3>:
{
    21f2:	7179                	addi	sp,sp,-48
    21f4:	f406                	sd	ra,40(sp)
    21f6:	f022                	sd	s0,32(sp)
    21f8:	ec26                	sd	s1,24(sp)
    21fa:	1800                	addi	s0,sp,48
  sbrk(8192);
    21fc:	6509                	lui	a0,0x2
    21fe:	00003097          	auipc	ra,0x3
    2202:	3c6080e7          	jalr	966(ra) # 55c4 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2206:	4501                	li	a0,0
    2208:	00003097          	auipc	ra,0x3
    220c:	3bc080e7          	jalr	956(ra) # 55c4 <sbrk>
  if((top % PGSIZE) != 0){
    2210:	6785                	lui	a5,0x1
    2212:	17fd                	addi	a5,a5,-1
    2214:	8fe9                	and	a5,a5,a0
    2216:	e3d1                	bnez	a5,229a <copyinstr3+0xa8>
  top = (uint64) sbrk(0);
    2218:	4501                	li	a0,0
    221a:	00003097          	auipc	ra,0x3
    221e:	3aa080e7          	jalr	938(ra) # 55c4 <sbrk>
  if(top % PGSIZE){
    2222:	6785                	lui	a5,0x1
    2224:	17fd                	addi	a5,a5,-1
    2226:	8fe9                	and	a5,a5,a0
    2228:	e7c1                	bnez	a5,22b0 <copyinstr3+0xbe>
  char *b = (char *) (top - 1);
    222a:	fff50493          	addi	s1,a0,-1 # 1fff <kernmem+0x3f>
  *b = 'x';
    222e:	07800793          	li	a5,120
    2232:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2236:	8526                	mv	a0,s1
    2238:	00003097          	auipc	ra,0x3
    223c:	354080e7          	jalr	852(ra) # 558c <unlink>
  if(ret != -1){
    2240:	57fd                	li	a5,-1
    2242:	08f51463          	bne	a0,a5,22ca <copyinstr3+0xd8>
  int fd = open(b, O_CREATE | O_WRONLY);
    2246:	20100593          	li	a1,513
    224a:	8526                	mv	a0,s1
    224c:	00003097          	auipc	ra,0x3
    2250:	330080e7          	jalr	816(ra) # 557c <open>
  if(fd != -1){
    2254:	57fd                	li	a5,-1
    2256:	08f51963          	bne	a0,a5,22e8 <copyinstr3+0xf6>
  ret = link(b, b);
    225a:	85a6                	mv	a1,s1
    225c:	8526                	mv	a0,s1
    225e:	00003097          	auipc	ra,0x3
    2262:	33e080e7          	jalr	830(ra) # 559c <link>
  if(ret != -1){
    2266:	57fd                	li	a5,-1
    2268:	08f51f63          	bne	a0,a5,2306 <copyinstr3+0x114>
  char *args[] = { "xx", 0 };
    226c:	00005797          	auipc	a5,0x5
    2270:	4ac78793          	addi	a5,a5,1196 # 7718 <malloc+0x1da4>
    2274:	fcf43823          	sd	a5,-48(s0)
    2278:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    227c:	fd040593          	addi	a1,s0,-48
    2280:	8526                	mv	a0,s1
    2282:	00003097          	auipc	ra,0x3
    2286:	2f2080e7          	jalr	754(ra) # 5574 <exec>
  if(ret != -1){
    228a:	57fd                	li	a5,-1
    228c:	08f51d63          	bne	a0,a5,2326 <copyinstr3+0x134>
}
    2290:	70a2                	ld	ra,40(sp)
    2292:	7402                	ld	s0,32(sp)
    2294:	64e2                	ld	s1,24(sp)
    2296:	6145                	addi	sp,sp,48
    2298:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    229a:	6785                	lui	a5,0x1
    229c:	17fd                	addi	a5,a5,-1
    229e:	8d7d                	and	a0,a0,a5
    22a0:	6785                	lui	a5,0x1
    22a2:	40a7853b          	subw	a0,a5,a0
    22a6:	00003097          	auipc	ra,0x3
    22aa:	31e080e7          	jalr	798(ra) # 55c4 <sbrk>
    22ae:	b7ad                	j	2218 <copyinstr3+0x26>
    printf("oops\n");
    22b0:	00005517          	auipc	a0,0x5
    22b4:	83850513          	addi	a0,a0,-1992 # 6ae8 <malloc+0x1174>
    22b8:	00003097          	auipc	ra,0x3
    22bc:	5fc080e7          	jalr	1532(ra) # 58b4 <printf>
    exit(1);
    22c0:	4505                	li	a0,1
    22c2:	00003097          	auipc	ra,0x3
    22c6:	27a080e7          	jalr	634(ra) # 553c <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    22ca:	862a                	mv	a2,a0
    22cc:	85a6                	mv	a1,s1
    22ce:	00004517          	auipc	a0,0x4
    22d2:	2f250513          	addi	a0,a0,754 # 65c0 <malloc+0xc4c>
    22d6:	00003097          	auipc	ra,0x3
    22da:	5de080e7          	jalr	1502(ra) # 58b4 <printf>
    exit(1);
    22de:	4505                	li	a0,1
    22e0:	00003097          	auipc	ra,0x3
    22e4:	25c080e7          	jalr	604(ra) # 553c <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    22e8:	862a                	mv	a2,a0
    22ea:	85a6                	mv	a1,s1
    22ec:	00004517          	auipc	a0,0x4
    22f0:	2f450513          	addi	a0,a0,756 # 65e0 <malloc+0xc6c>
    22f4:	00003097          	auipc	ra,0x3
    22f8:	5c0080e7          	jalr	1472(ra) # 58b4 <printf>
    exit(1);
    22fc:	4505                	li	a0,1
    22fe:	00003097          	auipc	ra,0x3
    2302:	23e080e7          	jalr	574(ra) # 553c <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2306:	86aa                	mv	a3,a0
    2308:	8626                	mv	a2,s1
    230a:	85a6                	mv	a1,s1
    230c:	00004517          	auipc	a0,0x4
    2310:	2f450513          	addi	a0,a0,756 # 6600 <malloc+0xc8c>
    2314:	00003097          	auipc	ra,0x3
    2318:	5a0080e7          	jalr	1440(ra) # 58b4 <printf>
    exit(1);
    231c:	4505                	li	a0,1
    231e:	00003097          	auipc	ra,0x3
    2322:	21e080e7          	jalr	542(ra) # 553c <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2326:	567d                	li	a2,-1
    2328:	85a6                	mv	a1,s1
    232a:	00004517          	auipc	a0,0x4
    232e:	2fe50513          	addi	a0,a0,766 # 6628 <malloc+0xcb4>
    2332:	00003097          	auipc	ra,0x3
    2336:	582080e7          	jalr	1410(ra) # 58b4 <printf>
    exit(1);
    233a:	4505                	li	a0,1
    233c:	00003097          	auipc	ra,0x3
    2340:	200080e7          	jalr	512(ra) # 553c <exit>

0000000000002344 <rwsbrk>:
{
    2344:	1101                	addi	sp,sp,-32
    2346:	ec06                	sd	ra,24(sp)
    2348:	e822                	sd	s0,16(sp)
    234a:	e426                	sd	s1,8(sp)
    234c:	e04a                	sd	s2,0(sp)
    234e:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2350:	6509                	lui	a0,0x2
    2352:	00003097          	auipc	ra,0x3
    2356:	272080e7          	jalr	626(ra) # 55c4 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    235a:	57fd                	li	a5,-1
    235c:	06f50263          	beq	a0,a5,23c0 <rwsbrk+0x7c>
    2360:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2362:	7579                	lui	a0,0xffffe
    2364:	00003097          	auipc	ra,0x3
    2368:	260080e7          	jalr	608(ra) # 55c4 <sbrk>
    236c:	57fd                	li	a5,-1
    236e:	06f50663          	beq	a0,a5,23da <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2372:	20100593          	li	a1,513
    2376:	00004517          	auipc	a0,0x4
    237a:	7b250513          	addi	a0,a0,1970 # 6b28 <malloc+0x11b4>
    237e:	00003097          	auipc	ra,0x3
    2382:	1fe080e7          	jalr	510(ra) # 557c <open>
    2386:	892a                	mv	s2,a0
  if(fd < 0){
    2388:	06054663          	bltz	a0,23f4 <rwsbrk+0xb0>
  n = write(fd, (void*)(a+4096), 1024);
    238c:	6785                	lui	a5,0x1
    238e:	94be                	add	s1,s1,a5
    2390:	40000613          	li	a2,1024
    2394:	85a6                	mv	a1,s1
    2396:	00003097          	auipc	ra,0x3
    239a:	1c6080e7          	jalr	454(ra) # 555c <write>
  if(n >= 0){
    239e:	06054863          	bltz	a0,240e <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    23a2:	862a                	mv	a2,a0
    23a4:	85a6                	mv	a1,s1
    23a6:	00004517          	auipc	a0,0x4
    23aa:	7a250513          	addi	a0,a0,1954 # 6b48 <malloc+0x11d4>
    23ae:	00003097          	auipc	ra,0x3
    23b2:	506080e7          	jalr	1286(ra) # 58b4 <printf>
    exit(1);
    23b6:	4505                	li	a0,1
    23b8:	00003097          	auipc	ra,0x3
    23bc:	184080e7          	jalr	388(ra) # 553c <exit>
    printf("sbrk(rwsbrk) failed\n");
    23c0:	00004517          	auipc	a0,0x4
    23c4:	73050513          	addi	a0,a0,1840 # 6af0 <malloc+0x117c>
    23c8:	00003097          	auipc	ra,0x3
    23cc:	4ec080e7          	jalr	1260(ra) # 58b4 <printf>
    exit(1);
    23d0:	4505                	li	a0,1
    23d2:	00003097          	auipc	ra,0x3
    23d6:	16a080e7          	jalr	362(ra) # 553c <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    23da:	00004517          	auipc	a0,0x4
    23de:	72e50513          	addi	a0,a0,1838 # 6b08 <malloc+0x1194>
    23e2:	00003097          	auipc	ra,0x3
    23e6:	4d2080e7          	jalr	1234(ra) # 58b4 <printf>
    exit(1);
    23ea:	4505                	li	a0,1
    23ec:	00003097          	auipc	ra,0x3
    23f0:	150080e7          	jalr	336(ra) # 553c <exit>
    printf("open(rwsbrk) failed\n");
    23f4:	00004517          	auipc	a0,0x4
    23f8:	73c50513          	addi	a0,a0,1852 # 6b30 <malloc+0x11bc>
    23fc:	00003097          	auipc	ra,0x3
    2400:	4b8080e7          	jalr	1208(ra) # 58b4 <printf>
    exit(1);
    2404:	4505                	li	a0,1
    2406:	00003097          	auipc	ra,0x3
    240a:	136080e7          	jalr	310(ra) # 553c <exit>
  close(fd);
    240e:	854a                	mv	a0,s2
    2410:	00003097          	auipc	ra,0x3
    2414:	154080e7          	jalr	340(ra) # 5564 <close>
  unlink("rwsbrk");
    2418:	00004517          	auipc	a0,0x4
    241c:	71050513          	addi	a0,a0,1808 # 6b28 <malloc+0x11b4>
    2420:	00003097          	auipc	ra,0x3
    2424:	16c080e7          	jalr	364(ra) # 558c <unlink>
  fd = open("README", O_RDONLY);
    2428:	4581                	li	a1,0
    242a:	00004517          	auipc	a0,0x4
    242e:	bc650513          	addi	a0,a0,-1082 # 5ff0 <malloc+0x67c>
    2432:	00003097          	auipc	ra,0x3
    2436:	14a080e7          	jalr	330(ra) # 557c <open>
    243a:	892a                	mv	s2,a0
  if(fd < 0){
    243c:	02054963          	bltz	a0,246e <rwsbrk+0x12a>
  n = read(fd, (void*)(a+4096), 10);
    2440:	4629                	li	a2,10
    2442:	85a6                	mv	a1,s1
    2444:	00003097          	auipc	ra,0x3
    2448:	110080e7          	jalr	272(ra) # 5554 <read>
  if(n >= 0){
    244c:	02054e63          	bltz	a0,2488 <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2450:	862a                	mv	a2,a0
    2452:	85a6                	mv	a1,s1
    2454:	00004517          	auipc	a0,0x4
    2458:	72450513          	addi	a0,a0,1828 # 6b78 <malloc+0x1204>
    245c:	00003097          	auipc	ra,0x3
    2460:	458080e7          	jalr	1112(ra) # 58b4 <printf>
    exit(1);
    2464:	4505                	li	a0,1
    2466:	00003097          	auipc	ra,0x3
    246a:	0d6080e7          	jalr	214(ra) # 553c <exit>
    printf("open(rwsbrk) failed\n");
    246e:	00004517          	auipc	a0,0x4
    2472:	6c250513          	addi	a0,a0,1730 # 6b30 <malloc+0x11bc>
    2476:	00003097          	auipc	ra,0x3
    247a:	43e080e7          	jalr	1086(ra) # 58b4 <printf>
    exit(1);
    247e:	4505                	li	a0,1
    2480:	00003097          	auipc	ra,0x3
    2484:	0bc080e7          	jalr	188(ra) # 553c <exit>
  close(fd);
    2488:	854a                	mv	a0,s2
    248a:	00003097          	auipc	ra,0x3
    248e:	0da080e7          	jalr	218(ra) # 5564 <close>
  exit(0);
    2492:	4501                	li	a0,0
    2494:	00003097          	auipc	ra,0x3
    2498:	0a8080e7          	jalr	168(ra) # 553c <exit>

000000000000249c <sbrkbasic>:
{
    249c:	715d                	addi	sp,sp,-80
    249e:	e486                	sd	ra,72(sp)
    24a0:	e0a2                	sd	s0,64(sp)
    24a2:	fc26                	sd	s1,56(sp)
    24a4:	f84a                	sd	s2,48(sp)
    24a6:	f44e                	sd	s3,40(sp)
    24a8:	f052                	sd	s4,32(sp)
    24aa:	ec56                	sd	s5,24(sp)
    24ac:	0880                	addi	s0,sp,80
    24ae:	8aaa                	mv	s5,a0
  pid = fork();
    24b0:	00003097          	auipc	ra,0x3
    24b4:	084080e7          	jalr	132(ra) # 5534 <fork>
  if(pid < 0){
    24b8:	02054c63          	bltz	a0,24f0 <sbrkbasic+0x54>
  if(pid == 0){
    24bc:	ed21                	bnez	a0,2514 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    24be:	40000537          	lui	a0,0x40000
    24c2:	00003097          	auipc	ra,0x3
    24c6:	102080e7          	jalr	258(ra) # 55c4 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    24ca:	57fd                	li	a5,-1
    24cc:	02f50f63          	beq	a0,a5,250a <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24d0:	400007b7          	lui	a5,0x40000
    24d4:	97aa                	add	a5,a5,a0
      *b = 99;
    24d6:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    24da:	6705                	lui	a4,0x1
      *b = 99;
    24dc:	00d50023          	sb	a3,0(a0) # 40000000 <_end+0x3fff1630>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24e0:	953a                	add	a0,a0,a4
    24e2:	fef51de3          	bne	a0,a5,24dc <sbrkbasic+0x40>
    exit(1);
    24e6:	4505                	li	a0,1
    24e8:	00003097          	auipc	ra,0x3
    24ec:	054080e7          	jalr	84(ra) # 553c <exit>
    printf("fork failed in sbrkbasic\n");
    24f0:	00004517          	auipc	a0,0x4
    24f4:	6b050513          	addi	a0,a0,1712 # 6ba0 <malloc+0x122c>
    24f8:	00003097          	auipc	ra,0x3
    24fc:	3bc080e7          	jalr	956(ra) # 58b4 <printf>
    exit(1);
    2500:	4505                	li	a0,1
    2502:	00003097          	auipc	ra,0x3
    2506:	03a080e7          	jalr	58(ra) # 553c <exit>
      exit(0);
    250a:	4501                	li	a0,0
    250c:	00003097          	auipc	ra,0x3
    2510:	030080e7          	jalr	48(ra) # 553c <exit>
  wait(&xstatus);
    2514:	fbc40513          	addi	a0,s0,-68
    2518:	00003097          	auipc	ra,0x3
    251c:	02c080e7          	jalr	44(ra) # 5544 <wait>
  if(xstatus == 1){
    2520:	fbc42703          	lw	a4,-68(s0)
    2524:	4785                	li	a5,1
    2526:	00f70e63          	beq	a4,a5,2542 <sbrkbasic+0xa6>
  a = sbrk(0);
    252a:	4501                	li	a0,0
    252c:	00003097          	auipc	ra,0x3
    2530:	098080e7          	jalr	152(ra) # 55c4 <sbrk>
    2534:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2536:	4901                	li	s2,0
    *b = 1;
    2538:	4a05                	li	s4,1
  for(i = 0; i < 5000; i++){
    253a:	6985                	lui	s3,0x1
    253c:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1ba>
    2540:	a005                	j	2560 <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    2542:	85d6                	mv	a1,s5
    2544:	00004517          	auipc	a0,0x4
    2548:	67c50513          	addi	a0,a0,1660 # 6bc0 <malloc+0x124c>
    254c:	00003097          	auipc	ra,0x3
    2550:	368080e7          	jalr	872(ra) # 58b4 <printf>
    exit(1);
    2554:	4505                	li	a0,1
    2556:	00003097          	auipc	ra,0x3
    255a:	fe6080e7          	jalr	-26(ra) # 553c <exit>
    a = b + 1;
    255e:	84be                	mv	s1,a5
    b = sbrk(1);
    2560:	4505                	li	a0,1
    2562:	00003097          	auipc	ra,0x3
    2566:	062080e7          	jalr	98(ra) # 55c4 <sbrk>
    if(b != a){
    256a:	04951b63          	bne	a0,s1,25c0 <sbrkbasic+0x124>
    *b = 1;
    256e:	01448023          	sb	s4,0(s1)
    a = b + 1;
    2572:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2576:	2905                	addiw	s2,s2,1
    2578:	ff3913e3          	bne	s2,s3,255e <sbrkbasic+0xc2>
  pid = fork();
    257c:	00003097          	auipc	ra,0x3
    2580:	fb8080e7          	jalr	-72(ra) # 5534 <fork>
    2584:	892a                	mv	s2,a0
  if(pid < 0){
    2586:	04054d63          	bltz	a0,25e0 <sbrkbasic+0x144>
  c = sbrk(1);
    258a:	4505                	li	a0,1
    258c:	00003097          	auipc	ra,0x3
    2590:	038080e7          	jalr	56(ra) # 55c4 <sbrk>
  c = sbrk(1);
    2594:	4505                	li	a0,1
    2596:	00003097          	auipc	ra,0x3
    259a:	02e080e7          	jalr	46(ra) # 55c4 <sbrk>
  if(c != a + 1){
    259e:	0489                	addi	s1,s1,2
    25a0:	04a48e63          	beq	s1,a0,25fc <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    25a4:	85d6                	mv	a1,s5
    25a6:	00004517          	auipc	a0,0x4
    25aa:	67a50513          	addi	a0,a0,1658 # 6c20 <malloc+0x12ac>
    25ae:	00003097          	auipc	ra,0x3
    25b2:	306080e7          	jalr	774(ra) # 58b4 <printf>
    exit(1);
    25b6:	4505                	li	a0,1
    25b8:	00003097          	auipc	ra,0x3
    25bc:	f84080e7          	jalr	-124(ra) # 553c <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    25c0:	86aa                	mv	a3,a0
    25c2:	8626                	mv	a2,s1
    25c4:	85ca                	mv	a1,s2
    25c6:	00004517          	auipc	a0,0x4
    25ca:	61a50513          	addi	a0,a0,1562 # 6be0 <malloc+0x126c>
    25ce:	00003097          	auipc	ra,0x3
    25d2:	2e6080e7          	jalr	742(ra) # 58b4 <printf>
      exit(1);
    25d6:	4505                	li	a0,1
    25d8:	00003097          	auipc	ra,0x3
    25dc:	f64080e7          	jalr	-156(ra) # 553c <exit>
    printf("%s: sbrk test fork failed\n", s);
    25e0:	85d6                	mv	a1,s5
    25e2:	00004517          	auipc	a0,0x4
    25e6:	61e50513          	addi	a0,a0,1566 # 6c00 <malloc+0x128c>
    25ea:	00003097          	auipc	ra,0x3
    25ee:	2ca080e7          	jalr	714(ra) # 58b4 <printf>
    exit(1);
    25f2:	4505                	li	a0,1
    25f4:	00003097          	auipc	ra,0x3
    25f8:	f48080e7          	jalr	-184(ra) # 553c <exit>
  if(pid == 0)
    25fc:	00091763          	bnez	s2,260a <sbrkbasic+0x16e>
    exit(0);
    2600:	4501                	li	a0,0
    2602:	00003097          	auipc	ra,0x3
    2606:	f3a080e7          	jalr	-198(ra) # 553c <exit>
  wait(&xstatus);
    260a:	fbc40513          	addi	a0,s0,-68
    260e:	00003097          	auipc	ra,0x3
    2612:	f36080e7          	jalr	-202(ra) # 5544 <wait>
  exit(xstatus);
    2616:	fbc42503          	lw	a0,-68(s0)
    261a:	00003097          	auipc	ra,0x3
    261e:	f22080e7          	jalr	-222(ra) # 553c <exit>

0000000000002622 <sbrkmuch>:
{
    2622:	7179                	addi	sp,sp,-48
    2624:	f406                	sd	ra,40(sp)
    2626:	f022                	sd	s0,32(sp)
    2628:	ec26                	sd	s1,24(sp)
    262a:	e84a                	sd	s2,16(sp)
    262c:	e44e                	sd	s3,8(sp)
    262e:	e052                	sd	s4,0(sp)
    2630:	1800                	addi	s0,sp,48
    2632:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2634:	4501                	li	a0,0
    2636:	00003097          	auipc	ra,0x3
    263a:	f8e080e7          	jalr	-114(ra) # 55c4 <sbrk>
    263e:	892a                	mv	s2,a0
  a = sbrk(0);
    2640:	4501                	li	a0,0
    2642:	00003097          	auipc	ra,0x3
    2646:	f82080e7          	jalr	-126(ra) # 55c4 <sbrk>
    264a:	84aa                	mv	s1,a0
  p = sbrk(amt);
    264c:	06400537          	lui	a0,0x6400
    2650:	9d05                	subw	a0,a0,s1
    2652:	00003097          	auipc	ra,0x3
    2656:	f72080e7          	jalr	-142(ra) # 55c4 <sbrk>
  if (p != a) {
    265a:	0ca49763          	bne	s1,a0,2728 <sbrkmuch+0x106>
  char *eee = sbrk(0);
    265e:	4501                	li	a0,0
    2660:	00003097          	auipc	ra,0x3
    2664:	f64080e7          	jalr	-156(ra) # 55c4 <sbrk>
  for(char *pp = a; pp < eee; pp += 4096)
    2668:	00a4f963          	bleu	a0,s1,267a <sbrkmuch+0x58>
    *pp = 1;
    266c:	4705                	li	a4,1
  for(char *pp = a; pp < eee; pp += 4096)
    266e:	6785                	lui	a5,0x1
    *pp = 1;
    2670:	00e48023          	sb	a4,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2674:	94be                	add	s1,s1,a5
    2676:	fea4ede3          	bltu	s1,a0,2670 <sbrkmuch+0x4e>
  *lastaddr = 99;
    267a:	064007b7          	lui	a5,0x6400
    267e:	06300713          	li	a4,99
    2682:	fee78fa3          	sb	a4,-1(a5) # 63fffff <_end+0x63f162f>
  a = sbrk(0);
    2686:	4501                	li	a0,0
    2688:	00003097          	auipc	ra,0x3
    268c:	f3c080e7          	jalr	-196(ra) # 55c4 <sbrk>
    2690:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    2692:	757d                	lui	a0,0xfffff
    2694:	00003097          	auipc	ra,0x3
    2698:	f30080e7          	jalr	-208(ra) # 55c4 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    269c:	57fd                	li	a5,-1
    269e:	0af50363          	beq	a0,a5,2744 <sbrkmuch+0x122>
  c = sbrk(0);
    26a2:	4501                	li	a0,0
    26a4:	00003097          	auipc	ra,0x3
    26a8:	f20080e7          	jalr	-224(ra) # 55c4 <sbrk>
  if(c != a - PGSIZE){
    26ac:	77fd                	lui	a5,0xfffff
    26ae:	97a6                	add	a5,a5,s1
    26b0:	0af51863          	bne	a0,a5,2760 <sbrkmuch+0x13e>
  a = sbrk(0);
    26b4:	4501                	li	a0,0
    26b6:	00003097          	auipc	ra,0x3
    26ba:	f0e080e7          	jalr	-242(ra) # 55c4 <sbrk>
    26be:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    26c0:	6505                	lui	a0,0x1
    26c2:	00003097          	auipc	ra,0x3
    26c6:	f02080e7          	jalr	-254(ra) # 55c4 <sbrk>
    26ca:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    26cc:	0aa49963          	bne	s1,a0,277e <sbrkmuch+0x15c>
    26d0:	4501                	li	a0,0
    26d2:	00003097          	auipc	ra,0x3
    26d6:	ef2080e7          	jalr	-270(ra) # 55c4 <sbrk>
    26da:	6785                	lui	a5,0x1
    26dc:	97a6                	add	a5,a5,s1
    26de:	0af51063          	bne	a0,a5,277e <sbrkmuch+0x15c>
  if(*lastaddr == 99){
    26e2:	064007b7          	lui	a5,0x6400
    26e6:	fff7c703          	lbu	a4,-1(a5) # 63fffff <_end+0x63f162f>
    26ea:	06300793          	li	a5,99
    26ee:	0af70763          	beq	a4,a5,279c <sbrkmuch+0x17a>
  a = sbrk(0);
    26f2:	4501                	li	a0,0
    26f4:	00003097          	auipc	ra,0x3
    26f8:	ed0080e7          	jalr	-304(ra) # 55c4 <sbrk>
    26fc:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    26fe:	4501                	li	a0,0
    2700:	00003097          	auipc	ra,0x3
    2704:	ec4080e7          	jalr	-316(ra) # 55c4 <sbrk>
    2708:	40a9053b          	subw	a0,s2,a0
    270c:	00003097          	auipc	ra,0x3
    2710:	eb8080e7          	jalr	-328(ra) # 55c4 <sbrk>
  if(c != a){
    2714:	0aa49263          	bne	s1,a0,27b8 <sbrkmuch+0x196>
}
    2718:	70a2                	ld	ra,40(sp)
    271a:	7402                	ld	s0,32(sp)
    271c:	64e2                	ld	s1,24(sp)
    271e:	6942                	ld	s2,16(sp)
    2720:	69a2                	ld	s3,8(sp)
    2722:	6a02                	ld	s4,0(sp)
    2724:	6145                	addi	sp,sp,48
    2726:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2728:	85ce                	mv	a1,s3
    272a:	00004517          	auipc	a0,0x4
    272e:	51650513          	addi	a0,a0,1302 # 6c40 <malloc+0x12cc>
    2732:	00003097          	auipc	ra,0x3
    2736:	182080e7          	jalr	386(ra) # 58b4 <printf>
    exit(1);
    273a:	4505                	li	a0,1
    273c:	00003097          	auipc	ra,0x3
    2740:	e00080e7          	jalr	-512(ra) # 553c <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2744:	85ce                	mv	a1,s3
    2746:	00004517          	auipc	a0,0x4
    274a:	54250513          	addi	a0,a0,1346 # 6c88 <malloc+0x1314>
    274e:	00003097          	auipc	ra,0x3
    2752:	166080e7          	jalr	358(ra) # 58b4 <printf>
    exit(1);
    2756:	4505                	li	a0,1
    2758:	00003097          	auipc	ra,0x3
    275c:	de4080e7          	jalr	-540(ra) # 553c <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", a, c);
    2760:	862a                	mv	a2,a0
    2762:	85a6                	mv	a1,s1
    2764:	00004517          	auipc	a0,0x4
    2768:	54450513          	addi	a0,a0,1348 # 6ca8 <malloc+0x1334>
    276c:	00003097          	auipc	ra,0x3
    2770:	148080e7          	jalr	328(ra) # 58b4 <printf>
    exit(1);
    2774:	4505                	li	a0,1
    2776:	00003097          	auipc	ra,0x3
    277a:	dc6080e7          	jalr	-570(ra) # 553c <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", a, c);
    277e:	8652                	mv	a2,s4
    2780:	85a6                	mv	a1,s1
    2782:	00004517          	auipc	a0,0x4
    2786:	56650513          	addi	a0,a0,1382 # 6ce8 <malloc+0x1374>
    278a:	00003097          	auipc	ra,0x3
    278e:	12a080e7          	jalr	298(ra) # 58b4 <printf>
    exit(1);
    2792:	4505                	li	a0,1
    2794:	00003097          	auipc	ra,0x3
    2798:	da8080e7          	jalr	-600(ra) # 553c <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    279c:	85ce                	mv	a1,s3
    279e:	00004517          	auipc	a0,0x4
    27a2:	57a50513          	addi	a0,a0,1402 # 6d18 <malloc+0x13a4>
    27a6:	00003097          	auipc	ra,0x3
    27aa:	10e080e7          	jalr	270(ra) # 58b4 <printf>
    exit(1);
    27ae:	4505                	li	a0,1
    27b0:	00003097          	auipc	ra,0x3
    27b4:	d8c080e7          	jalr	-628(ra) # 553c <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", a, c);
    27b8:	862a                	mv	a2,a0
    27ba:	85a6                	mv	a1,s1
    27bc:	00004517          	auipc	a0,0x4
    27c0:	59450513          	addi	a0,a0,1428 # 6d50 <malloc+0x13dc>
    27c4:	00003097          	auipc	ra,0x3
    27c8:	0f0080e7          	jalr	240(ra) # 58b4 <printf>
    exit(1);
    27cc:	4505                	li	a0,1
    27ce:	00003097          	auipc	ra,0x3
    27d2:	d6e080e7          	jalr	-658(ra) # 553c <exit>

00000000000027d6 <sbrkarg>:
{
    27d6:	7179                	addi	sp,sp,-48
    27d8:	f406                	sd	ra,40(sp)
    27da:	f022                	sd	s0,32(sp)
    27dc:	ec26                	sd	s1,24(sp)
    27de:	e84a                	sd	s2,16(sp)
    27e0:	e44e                	sd	s3,8(sp)
    27e2:	1800                	addi	s0,sp,48
    27e4:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    27e6:	6505                	lui	a0,0x1
    27e8:	00003097          	auipc	ra,0x3
    27ec:	ddc080e7          	jalr	-548(ra) # 55c4 <sbrk>
    27f0:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    27f2:	20100593          	li	a1,513
    27f6:	00004517          	auipc	a0,0x4
    27fa:	58250513          	addi	a0,a0,1410 # 6d78 <malloc+0x1404>
    27fe:	00003097          	auipc	ra,0x3
    2802:	d7e080e7          	jalr	-642(ra) # 557c <open>
    2806:	84aa                	mv	s1,a0
  unlink("sbrk");
    2808:	00004517          	auipc	a0,0x4
    280c:	57050513          	addi	a0,a0,1392 # 6d78 <malloc+0x1404>
    2810:	00003097          	auipc	ra,0x3
    2814:	d7c080e7          	jalr	-644(ra) # 558c <unlink>
  if(fd < 0)  {
    2818:	0404c163          	bltz	s1,285a <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    281c:	6605                	lui	a2,0x1
    281e:	85ca                	mv	a1,s2
    2820:	8526                	mv	a0,s1
    2822:	00003097          	auipc	ra,0x3
    2826:	d3a080e7          	jalr	-710(ra) # 555c <write>
    282a:	04054663          	bltz	a0,2876 <sbrkarg+0xa0>
  close(fd);
    282e:	8526                	mv	a0,s1
    2830:	00003097          	auipc	ra,0x3
    2834:	d34080e7          	jalr	-716(ra) # 5564 <close>
  a = sbrk(PGSIZE);
    2838:	6505                	lui	a0,0x1
    283a:	00003097          	auipc	ra,0x3
    283e:	d8a080e7          	jalr	-630(ra) # 55c4 <sbrk>
  if(pipe((int *) a) != 0){
    2842:	00003097          	auipc	ra,0x3
    2846:	d0a080e7          	jalr	-758(ra) # 554c <pipe>
    284a:	e521                	bnez	a0,2892 <sbrkarg+0xbc>
}
    284c:	70a2                	ld	ra,40(sp)
    284e:	7402                	ld	s0,32(sp)
    2850:	64e2                	ld	s1,24(sp)
    2852:	6942                	ld	s2,16(sp)
    2854:	69a2                	ld	s3,8(sp)
    2856:	6145                	addi	sp,sp,48
    2858:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    285a:	85ce                	mv	a1,s3
    285c:	00004517          	auipc	a0,0x4
    2860:	52450513          	addi	a0,a0,1316 # 6d80 <malloc+0x140c>
    2864:	00003097          	auipc	ra,0x3
    2868:	050080e7          	jalr	80(ra) # 58b4 <printf>
    exit(1);
    286c:	4505                	li	a0,1
    286e:	00003097          	auipc	ra,0x3
    2872:	cce080e7          	jalr	-818(ra) # 553c <exit>
    printf("%s: write sbrk failed\n", s);
    2876:	85ce                	mv	a1,s3
    2878:	00004517          	auipc	a0,0x4
    287c:	52050513          	addi	a0,a0,1312 # 6d98 <malloc+0x1424>
    2880:	00003097          	auipc	ra,0x3
    2884:	034080e7          	jalr	52(ra) # 58b4 <printf>
    exit(1);
    2888:	4505                	li	a0,1
    288a:	00003097          	auipc	ra,0x3
    288e:	cb2080e7          	jalr	-846(ra) # 553c <exit>
    printf("%s: pipe() failed\n", s);
    2892:	85ce                	mv	a1,s3
    2894:	00004517          	auipc	a0,0x4
    2898:	f1450513          	addi	a0,a0,-236 # 67a8 <malloc+0xe34>
    289c:	00003097          	auipc	ra,0x3
    28a0:	018080e7          	jalr	24(ra) # 58b4 <printf>
    exit(1);
    28a4:	4505                	li	a0,1
    28a6:	00003097          	auipc	ra,0x3
    28aa:	c96080e7          	jalr	-874(ra) # 553c <exit>

00000000000028ae <argptest>:
{
    28ae:	1101                	addi	sp,sp,-32
    28b0:	ec06                	sd	ra,24(sp)
    28b2:	e822                	sd	s0,16(sp)
    28b4:	e426                	sd	s1,8(sp)
    28b6:	e04a                	sd	s2,0(sp)
    28b8:	1000                	addi	s0,sp,32
    28ba:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    28bc:	4581                	li	a1,0
    28be:	00004517          	auipc	a0,0x4
    28c2:	4f250513          	addi	a0,a0,1266 # 6db0 <malloc+0x143c>
    28c6:	00003097          	auipc	ra,0x3
    28ca:	cb6080e7          	jalr	-842(ra) # 557c <open>
  if (fd < 0) {
    28ce:	02054b63          	bltz	a0,2904 <argptest+0x56>
    28d2:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    28d4:	4501                	li	a0,0
    28d6:	00003097          	auipc	ra,0x3
    28da:	cee080e7          	jalr	-786(ra) # 55c4 <sbrk>
    28de:	567d                	li	a2,-1
    28e0:	fff50593          	addi	a1,a0,-1
    28e4:	8526                	mv	a0,s1
    28e6:	00003097          	auipc	ra,0x3
    28ea:	c6e080e7          	jalr	-914(ra) # 5554 <read>
  close(fd);
    28ee:	8526                	mv	a0,s1
    28f0:	00003097          	auipc	ra,0x3
    28f4:	c74080e7          	jalr	-908(ra) # 5564 <close>
}
    28f8:	60e2                	ld	ra,24(sp)
    28fa:	6442                	ld	s0,16(sp)
    28fc:	64a2                	ld	s1,8(sp)
    28fe:	6902                	ld	s2,0(sp)
    2900:	6105                	addi	sp,sp,32
    2902:	8082                	ret
    printf("%s: open failed\n", s);
    2904:	85ca                	mv	a1,s2
    2906:	00004517          	auipc	a0,0x4
    290a:	db250513          	addi	a0,a0,-590 # 66b8 <malloc+0xd44>
    290e:	00003097          	auipc	ra,0x3
    2912:	fa6080e7          	jalr	-90(ra) # 58b4 <printf>
    exit(1);
    2916:	4505                	li	a0,1
    2918:	00003097          	auipc	ra,0x3
    291c:	c24080e7          	jalr	-988(ra) # 553c <exit>

0000000000002920 <sbrkbugs>:
{
    2920:	1141                	addi	sp,sp,-16
    2922:	e406                	sd	ra,8(sp)
    2924:	e022                	sd	s0,0(sp)
    2926:	0800                	addi	s0,sp,16
  int pid = fork();
    2928:	00003097          	auipc	ra,0x3
    292c:	c0c080e7          	jalr	-1012(ra) # 5534 <fork>
  if(pid < 0){
    2930:	02054363          	bltz	a0,2956 <sbrkbugs+0x36>
  if(pid == 0){
    2934:	ed15                	bnez	a0,2970 <sbrkbugs+0x50>
    int sz = (uint64) sbrk(0);
    2936:	00003097          	auipc	ra,0x3
    293a:	c8e080e7          	jalr	-882(ra) # 55c4 <sbrk>
    sbrk(-sz);
    293e:	40a0053b          	negw	a0,a0
    2942:	2501                	sext.w	a0,a0
    2944:	00003097          	auipc	ra,0x3
    2948:	c80080e7          	jalr	-896(ra) # 55c4 <sbrk>
    exit(0);
    294c:	4501                	li	a0,0
    294e:	00003097          	auipc	ra,0x3
    2952:	bee080e7          	jalr	-1042(ra) # 553c <exit>
    printf("fork failed\n");
    2956:	00004517          	auipc	a0,0x4
    295a:	13a50513          	addi	a0,a0,314 # 6a90 <malloc+0x111c>
    295e:	00003097          	auipc	ra,0x3
    2962:	f56080e7          	jalr	-170(ra) # 58b4 <printf>
    exit(1);
    2966:	4505                	li	a0,1
    2968:	00003097          	auipc	ra,0x3
    296c:	bd4080e7          	jalr	-1068(ra) # 553c <exit>
  wait(0);
    2970:	4501                	li	a0,0
    2972:	00003097          	auipc	ra,0x3
    2976:	bd2080e7          	jalr	-1070(ra) # 5544 <wait>
  pid = fork();
    297a:	00003097          	auipc	ra,0x3
    297e:	bba080e7          	jalr	-1094(ra) # 5534 <fork>
  if(pid < 0){
    2982:	02054563          	bltz	a0,29ac <sbrkbugs+0x8c>
  if(pid == 0){
    2986:	e121                	bnez	a0,29c6 <sbrkbugs+0xa6>
    int sz = (uint64) sbrk(0);
    2988:	00003097          	auipc	ra,0x3
    298c:	c3c080e7          	jalr	-964(ra) # 55c4 <sbrk>
    sbrk(-(sz - 3500));
    2990:	6785                	lui	a5,0x1
    2992:	dac7879b          	addiw	a5,a5,-596
    2996:	40a7853b          	subw	a0,a5,a0
    299a:	00003097          	auipc	ra,0x3
    299e:	c2a080e7          	jalr	-982(ra) # 55c4 <sbrk>
    exit(0);
    29a2:	4501                	li	a0,0
    29a4:	00003097          	auipc	ra,0x3
    29a8:	b98080e7          	jalr	-1128(ra) # 553c <exit>
    printf("fork failed\n");
    29ac:	00004517          	auipc	a0,0x4
    29b0:	0e450513          	addi	a0,a0,228 # 6a90 <malloc+0x111c>
    29b4:	00003097          	auipc	ra,0x3
    29b8:	f00080e7          	jalr	-256(ra) # 58b4 <printf>
    exit(1);
    29bc:	4505                	li	a0,1
    29be:	00003097          	auipc	ra,0x3
    29c2:	b7e080e7          	jalr	-1154(ra) # 553c <exit>
  wait(0);
    29c6:	4501                	li	a0,0
    29c8:	00003097          	auipc	ra,0x3
    29cc:	b7c080e7          	jalr	-1156(ra) # 5544 <wait>
  pid = fork();
    29d0:	00003097          	auipc	ra,0x3
    29d4:	b64080e7          	jalr	-1180(ra) # 5534 <fork>
  if(pid < 0){
    29d8:	02054a63          	bltz	a0,2a0c <sbrkbugs+0xec>
  if(pid == 0){
    29dc:	e529                	bnez	a0,2a26 <sbrkbugs+0x106>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    29de:	00003097          	auipc	ra,0x3
    29e2:	be6080e7          	jalr	-1050(ra) # 55c4 <sbrk>
    29e6:	67ad                	lui	a5,0xb
    29e8:	8007879b          	addiw	a5,a5,-2048
    29ec:	40a7853b          	subw	a0,a5,a0
    29f0:	00003097          	auipc	ra,0x3
    29f4:	bd4080e7          	jalr	-1068(ra) # 55c4 <sbrk>
    sbrk(-10);
    29f8:	5559                	li	a0,-10
    29fa:	00003097          	auipc	ra,0x3
    29fe:	bca080e7          	jalr	-1078(ra) # 55c4 <sbrk>
    exit(0);
    2a02:	4501                	li	a0,0
    2a04:	00003097          	auipc	ra,0x3
    2a08:	b38080e7          	jalr	-1224(ra) # 553c <exit>
    printf("fork failed\n");
    2a0c:	00004517          	auipc	a0,0x4
    2a10:	08450513          	addi	a0,a0,132 # 6a90 <malloc+0x111c>
    2a14:	00003097          	auipc	ra,0x3
    2a18:	ea0080e7          	jalr	-352(ra) # 58b4 <printf>
    exit(1);
    2a1c:	4505                	li	a0,1
    2a1e:	00003097          	auipc	ra,0x3
    2a22:	b1e080e7          	jalr	-1250(ra) # 553c <exit>
  wait(0);
    2a26:	4501                	li	a0,0
    2a28:	00003097          	auipc	ra,0x3
    2a2c:	b1c080e7          	jalr	-1252(ra) # 5544 <wait>
  exit(0);
    2a30:	4501                	li	a0,0
    2a32:	00003097          	auipc	ra,0x3
    2a36:	b0a080e7          	jalr	-1270(ra) # 553c <exit>

0000000000002a3a <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2a3a:	715d                	addi	sp,sp,-80
    2a3c:	e486                	sd	ra,72(sp)
    2a3e:	e0a2                	sd	s0,64(sp)
    2a40:	fc26                	sd	s1,56(sp)
    2a42:	f84a                	sd	s2,48(sp)
    2a44:	f44e                	sd	s3,40(sp)
    2a46:	f052                	sd	s4,32(sp)
    2a48:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2a4a:	4901                	li	s2,0
    2a4c:	49bd                	li	s3,15
    int pid = fork();
    2a4e:	00003097          	auipc	ra,0x3
    2a52:	ae6080e7          	jalr	-1306(ra) # 5534 <fork>
    2a56:	84aa                	mv	s1,a0
    if(pid < 0){
    2a58:	02054063          	bltz	a0,2a78 <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2a5c:	c91d                	beqz	a0,2a92 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2a5e:	4501                	li	a0,0
    2a60:	00003097          	auipc	ra,0x3
    2a64:	ae4080e7          	jalr	-1308(ra) # 5544 <wait>
  for(int avail = 0; avail < 15; avail++){
    2a68:	2905                	addiw	s2,s2,1
    2a6a:	ff3912e3          	bne	s2,s3,2a4e <execout+0x14>
    }
  }

  exit(0);
    2a6e:	4501                	li	a0,0
    2a70:	00003097          	auipc	ra,0x3
    2a74:	acc080e7          	jalr	-1332(ra) # 553c <exit>
      printf("fork failed\n");
    2a78:	00004517          	auipc	a0,0x4
    2a7c:	01850513          	addi	a0,a0,24 # 6a90 <malloc+0x111c>
    2a80:	00003097          	auipc	ra,0x3
    2a84:	e34080e7          	jalr	-460(ra) # 58b4 <printf>
      exit(1);
    2a88:	4505                	li	a0,1
    2a8a:	00003097          	auipc	ra,0x3
    2a8e:	ab2080e7          	jalr	-1358(ra) # 553c <exit>
        if(a == 0xffffffffffffffffLL)
    2a92:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2a94:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2a96:	6505                	lui	a0,0x1
    2a98:	00003097          	auipc	ra,0x3
    2a9c:	b2c080e7          	jalr	-1236(ra) # 55c4 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2aa0:	01350763          	beq	a0,s3,2aae <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2aa4:	6785                	lui	a5,0x1
    2aa6:	97aa                	add	a5,a5,a0
    2aa8:	ff478fa3          	sb	s4,-1(a5) # fff <bigdir+0x83>
      while(1){
    2aac:	b7ed                	j	2a96 <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2aae:	01205a63          	blez	s2,2ac2 <execout+0x88>
        sbrk(-4096);
    2ab2:	757d                	lui	a0,0xfffff
    2ab4:	00003097          	auipc	ra,0x3
    2ab8:	b10080e7          	jalr	-1264(ra) # 55c4 <sbrk>
      for(int i = 0; i < avail; i++)
    2abc:	2485                	addiw	s1,s1,1
    2abe:	ff249ae3          	bne	s1,s2,2ab2 <execout+0x78>
      close(1);
    2ac2:	4505                	li	a0,1
    2ac4:	00003097          	auipc	ra,0x3
    2ac8:	aa0080e7          	jalr	-1376(ra) # 5564 <close>
      char *args[] = { "echo", "x", 0 };
    2acc:	00003517          	auipc	a0,0x3
    2ad0:	37c50513          	addi	a0,a0,892 # 5e48 <malloc+0x4d4>
    2ad4:	faa43c23          	sd	a0,-72(s0)
    2ad8:	00003797          	auipc	a5,0x3
    2adc:	3e078793          	addi	a5,a5,992 # 5eb8 <malloc+0x544>
    2ae0:	fcf43023          	sd	a5,-64(s0)
    2ae4:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2ae8:	fb840593          	addi	a1,s0,-72
    2aec:	00003097          	auipc	ra,0x3
    2af0:	a88080e7          	jalr	-1400(ra) # 5574 <exec>
      exit(0);
    2af4:	4501                	li	a0,0
    2af6:	00003097          	auipc	ra,0x3
    2afa:	a46080e7          	jalr	-1466(ra) # 553c <exit>

0000000000002afe <fourteen>:
{
    2afe:	1101                	addi	sp,sp,-32
    2b00:	ec06                	sd	ra,24(sp)
    2b02:	e822                	sd	s0,16(sp)
    2b04:	e426                	sd	s1,8(sp)
    2b06:	1000                	addi	s0,sp,32
    2b08:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2b0a:	00004517          	auipc	a0,0x4
    2b0e:	47e50513          	addi	a0,a0,1150 # 6f88 <malloc+0x1614>
    2b12:	00003097          	auipc	ra,0x3
    2b16:	a92080e7          	jalr	-1390(ra) # 55a4 <mkdir>
    2b1a:	e165                	bnez	a0,2bfa <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2b1c:	00004517          	auipc	a0,0x4
    2b20:	2c450513          	addi	a0,a0,708 # 6de0 <malloc+0x146c>
    2b24:	00003097          	auipc	ra,0x3
    2b28:	a80080e7          	jalr	-1408(ra) # 55a4 <mkdir>
    2b2c:	e56d                	bnez	a0,2c16 <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2b2e:	20000593          	li	a1,512
    2b32:	00004517          	auipc	a0,0x4
    2b36:	30650513          	addi	a0,a0,774 # 6e38 <malloc+0x14c4>
    2b3a:	00003097          	auipc	ra,0x3
    2b3e:	a42080e7          	jalr	-1470(ra) # 557c <open>
  if(fd < 0){
    2b42:	0e054863          	bltz	a0,2c32 <fourteen+0x134>
  close(fd);
    2b46:	00003097          	auipc	ra,0x3
    2b4a:	a1e080e7          	jalr	-1506(ra) # 5564 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2b4e:	4581                	li	a1,0
    2b50:	00004517          	auipc	a0,0x4
    2b54:	36050513          	addi	a0,a0,864 # 6eb0 <malloc+0x153c>
    2b58:	00003097          	auipc	ra,0x3
    2b5c:	a24080e7          	jalr	-1500(ra) # 557c <open>
  if(fd < 0){
    2b60:	0e054763          	bltz	a0,2c4e <fourteen+0x150>
  close(fd);
    2b64:	00003097          	auipc	ra,0x3
    2b68:	a00080e7          	jalr	-1536(ra) # 5564 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2b6c:	00004517          	auipc	a0,0x4
    2b70:	3b450513          	addi	a0,a0,948 # 6f20 <malloc+0x15ac>
    2b74:	00003097          	auipc	ra,0x3
    2b78:	a30080e7          	jalr	-1488(ra) # 55a4 <mkdir>
    2b7c:	c57d                	beqz	a0,2c6a <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2b7e:	00004517          	auipc	a0,0x4
    2b82:	3fa50513          	addi	a0,a0,1018 # 6f78 <malloc+0x1604>
    2b86:	00003097          	auipc	ra,0x3
    2b8a:	a1e080e7          	jalr	-1506(ra) # 55a4 <mkdir>
    2b8e:	cd65                	beqz	a0,2c86 <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2b90:	00004517          	auipc	a0,0x4
    2b94:	3e850513          	addi	a0,a0,1000 # 6f78 <malloc+0x1604>
    2b98:	00003097          	auipc	ra,0x3
    2b9c:	9f4080e7          	jalr	-1548(ra) # 558c <unlink>
  unlink("12345678901234/12345678901234");
    2ba0:	00004517          	auipc	a0,0x4
    2ba4:	38050513          	addi	a0,a0,896 # 6f20 <malloc+0x15ac>
    2ba8:	00003097          	auipc	ra,0x3
    2bac:	9e4080e7          	jalr	-1564(ra) # 558c <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2bb0:	00004517          	auipc	a0,0x4
    2bb4:	30050513          	addi	a0,a0,768 # 6eb0 <malloc+0x153c>
    2bb8:	00003097          	auipc	ra,0x3
    2bbc:	9d4080e7          	jalr	-1580(ra) # 558c <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2bc0:	00004517          	auipc	a0,0x4
    2bc4:	27850513          	addi	a0,a0,632 # 6e38 <malloc+0x14c4>
    2bc8:	00003097          	auipc	ra,0x3
    2bcc:	9c4080e7          	jalr	-1596(ra) # 558c <unlink>
  unlink("12345678901234/123456789012345");
    2bd0:	00004517          	auipc	a0,0x4
    2bd4:	21050513          	addi	a0,a0,528 # 6de0 <malloc+0x146c>
    2bd8:	00003097          	auipc	ra,0x3
    2bdc:	9b4080e7          	jalr	-1612(ra) # 558c <unlink>
  unlink("12345678901234");
    2be0:	00004517          	auipc	a0,0x4
    2be4:	3a850513          	addi	a0,a0,936 # 6f88 <malloc+0x1614>
    2be8:	00003097          	auipc	ra,0x3
    2bec:	9a4080e7          	jalr	-1628(ra) # 558c <unlink>
}
    2bf0:	60e2                	ld	ra,24(sp)
    2bf2:	6442                	ld	s0,16(sp)
    2bf4:	64a2                	ld	s1,8(sp)
    2bf6:	6105                	addi	sp,sp,32
    2bf8:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2bfa:	85a6                	mv	a1,s1
    2bfc:	00004517          	auipc	a0,0x4
    2c00:	1bc50513          	addi	a0,a0,444 # 6db8 <malloc+0x1444>
    2c04:	00003097          	auipc	ra,0x3
    2c08:	cb0080e7          	jalr	-848(ra) # 58b4 <printf>
    exit(1);
    2c0c:	4505                	li	a0,1
    2c0e:	00003097          	auipc	ra,0x3
    2c12:	92e080e7          	jalr	-1746(ra) # 553c <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2c16:	85a6                	mv	a1,s1
    2c18:	00004517          	auipc	a0,0x4
    2c1c:	1e850513          	addi	a0,a0,488 # 6e00 <malloc+0x148c>
    2c20:	00003097          	auipc	ra,0x3
    2c24:	c94080e7          	jalr	-876(ra) # 58b4 <printf>
    exit(1);
    2c28:	4505                	li	a0,1
    2c2a:	00003097          	auipc	ra,0x3
    2c2e:	912080e7          	jalr	-1774(ra) # 553c <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2c32:	85a6                	mv	a1,s1
    2c34:	00004517          	auipc	a0,0x4
    2c38:	23450513          	addi	a0,a0,564 # 6e68 <malloc+0x14f4>
    2c3c:	00003097          	auipc	ra,0x3
    2c40:	c78080e7          	jalr	-904(ra) # 58b4 <printf>
    exit(1);
    2c44:	4505                	li	a0,1
    2c46:	00003097          	auipc	ra,0x3
    2c4a:	8f6080e7          	jalr	-1802(ra) # 553c <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2c4e:	85a6                	mv	a1,s1
    2c50:	00004517          	auipc	a0,0x4
    2c54:	29050513          	addi	a0,a0,656 # 6ee0 <malloc+0x156c>
    2c58:	00003097          	auipc	ra,0x3
    2c5c:	c5c080e7          	jalr	-932(ra) # 58b4 <printf>
    exit(1);
    2c60:	4505                	li	a0,1
    2c62:	00003097          	auipc	ra,0x3
    2c66:	8da080e7          	jalr	-1830(ra) # 553c <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2c6a:	85a6                	mv	a1,s1
    2c6c:	00004517          	auipc	a0,0x4
    2c70:	2d450513          	addi	a0,a0,724 # 6f40 <malloc+0x15cc>
    2c74:	00003097          	auipc	ra,0x3
    2c78:	c40080e7          	jalr	-960(ra) # 58b4 <printf>
    exit(1);
    2c7c:	4505                	li	a0,1
    2c7e:	00003097          	auipc	ra,0x3
    2c82:	8be080e7          	jalr	-1858(ra) # 553c <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2c86:	85a6                	mv	a1,s1
    2c88:	00004517          	auipc	a0,0x4
    2c8c:	31050513          	addi	a0,a0,784 # 6f98 <malloc+0x1624>
    2c90:	00003097          	auipc	ra,0x3
    2c94:	c24080e7          	jalr	-988(ra) # 58b4 <printf>
    exit(1);
    2c98:	4505                	li	a0,1
    2c9a:	00003097          	auipc	ra,0x3
    2c9e:	8a2080e7          	jalr	-1886(ra) # 553c <exit>

0000000000002ca2 <iputtest>:
{
    2ca2:	1101                	addi	sp,sp,-32
    2ca4:	ec06                	sd	ra,24(sp)
    2ca6:	e822                	sd	s0,16(sp)
    2ca8:	e426                	sd	s1,8(sp)
    2caa:	1000                	addi	s0,sp,32
    2cac:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2cae:	00004517          	auipc	a0,0x4
    2cb2:	32250513          	addi	a0,a0,802 # 6fd0 <malloc+0x165c>
    2cb6:	00003097          	auipc	ra,0x3
    2cba:	8ee080e7          	jalr	-1810(ra) # 55a4 <mkdir>
    2cbe:	04054563          	bltz	a0,2d08 <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2cc2:	00004517          	auipc	a0,0x4
    2cc6:	30e50513          	addi	a0,a0,782 # 6fd0 <malloc+0x165c>
    2cca:	00003097          	auipc	ra,0x3
    2cce:	8e2080e7          	jalr	-1822(ra) # 55ac <chdir>
    2cd2:	04054963          	bltz	a0,2d24 <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2cd6:	00004517          	auipc	a0,0x4
    2cda:	33a50513          	addi	a0,a0,826 # 7010 <malloc+0x169c>
    2cde:	00003097          	auipc	ra,0x3
    2ce2:	8ae080e7          	jalr	-1874(ra) # 558c <unlink>
    2ce6:	04054d63          	bltz	a0,2d40 <iputtest+0x9e>
  if(chdir("/") < 0){
    2cea:	00004517          	auipc	a0,0x4
    2cee:	35650513          	addi	a0,a0,854 # 7040 <malloc+0x16cc>
    2cf2:	00003097          	auipc	ra,0x3
    2cf6:	8ba080e7          	jalr	-1862(ra) # 55ac <chdir>
    2cfa:	06054163          	bltz	a0,2d5c <iputtest+0xba>
}
    2cfe:	60e2                	ld	ra,24(sp)
    2d00:	6442                	ld	s0,16(sp)
    2d02:	64a2                	ld	s1,8(sp)
    2d04:	6105                	addi	sp,sp,32
    2d06:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2d08:	85a6                	mv	a1,s1
    2d0a:	00004517          	auipc	a0,0x4
    2d0e:	2ce50513          	addi	a0,a0,718 # 6fd8 <malloc+0x1664>
    2d12:	00003097          	auipc	ra,0x3
    2d16:	ba2080e7          	jalr	-1118(ra) # 58b4 <printf>
    exit(1);
    2d1a:	4505                	li	a0,1
    2d1c:	00003097          	auipc	ra,0x3
    2d20:	820080e7          	jalr	-2016(ra) # 553c <exit>
    printf("%s: chdir iputdir failed\n", s);
    2d24:	85a6                	mv	a1,s1
    2d26:	00004517          	auipc	a0,0x4
    2d2a:	2ca50513          	addi	a0,a0,714 # 6ff0 <malloc+0x167c>
    2d2e:	00003097          	auipc	ra,0x3
    2d32:	b86080e7          	jalr	-1146(ra) # 58b4 <printf>
    exit(1);
    2d36:	4505                	li	a0,1
    2d38:	00003097          	auipc	ra,0x3
    2d3c:	804080e7          	jalr	-2044(ra) # 553c <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2d40:	85a6                	mv	a1,s1
    2d42:	00004517          	auipc	a0,0x4
    2d46:	2de50513          	addi	a0,a0,734 # 7020 <malloc+0x16ac>
    2d4a:	00003097          	auipc	ra,0x3
    2d4e:	b6a080e7          	jalr	-1174(ra) # 58b4 <printf>
    exit(1);
    2d52:	4505                	li	a0,1
    2d54:	00002097          	auipc	ra,0x2
    2d58:	7e8080e7          	jalr	2024(ra) # 553c <exit>
    printf("%s: chdir / failed\n", s);
    2d5c:	85a6                	mv	a1,s1
    2d5e:	00004517          	auipc	a0,0x4
    2d62:	2ea50513          	addi	a0,a0,746 # 7048 <malloc+0x16d4>
    2d66:	00003097          	auipc	ra,0x3
    2d6a:	b4e080e7          	jalr	-1202(ra) # 58b4 <printf>
    exit(1);
    2d6e:	4505                	li	a0,1
    2d70:	00002097          	auipc	ra,0x2
    2d74:	7cc080e7          	jalr	1996(ra) # 553c <exit>

0000000000002d78 <exitiputtest>:
{
    2d78:	7179                	addi	sp,sp,-48
    2d7a:	f406                	sd	ra,40(sp)
    2d7c:	f022                	sd	s0,32(sp)
    2d7e:	ec26                	sd	s1,24(sp)
    2d80:	1800                	addi	s0,sp,48
    2d82:	84aa                	mv	s1,a0
  pid = fork();
    2d84:	00002097          	auipc	ra,0x2
    2d88:	7b0080e7          	jalr	1968(ra) # 5534 <fork>
  if(pid < 0){
    2d8c:	04054663          	bltz	a0,2dd8 <exitiputtest+0x60>
  if(pid == 0){
    2d90:	ed45                	bnez	a0,2e48 <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2d92:	00004517          	auipc	a0,0x4
    2d96:	23e50513          	addi	a0,a0,574 # 6fd0 <malloc+0x165c>
    2d9a:	00003097          	auipc	ra,0x3
    2d9e:	80a080e7          	jalr	-2038(ra) # 55a4 <mkdir>
    2da2:	04054963          	bltz	a0,2df4 <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2da6:	00004517          	auipc	a0,0x4
    2daa:	22a50513          	addi	a0,a0,554 # 6fd0 <malloc+0x165c>
    2dae:	00002097          	auipc	ra,0x2
    2db2:	7fe080e7          	jalr	2046(ra) # 55ac <chdir>
    2db6:	04054d63          	bltz	a0,2e10 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2dba:	00004517          	auipc	a0,0x4
    2dbe:	25650513          	addi	a0,a0,598 # 7010 <malloc+0x169c>
    2dc2:	00002097          	auipc	ra,0x2
    2dc6:	7ca080e7          	jalr	1994(ra) # 558c <unlink>
    2dca:	06054163          	bltz	a0,2e2c <exitiputtest+0xb4>
    exit(0);
    2dce:	4501                	li	a0,0
    2dd0:	00002097          	auipc	ra,0x2
    2dd4:	76c080e7          	jalr	1900(ra) # 553c <exit>
    printf("%s: fork failed\n", s);
    2dd8:	85a6                	mv	a1,s1
    2dda:	00004517          	auipc	a0,0x4
    2dde:	8c650513          	addi	a0,a0,-1850 # 66a0 <malloc+0xd2c>
    2de2:	00003097          	auipc	ra,0x3
    2de6:	ad2080e7          	jalr	-1326(ra) # 58b4 <printf>
    exit(1);
    2dea:	4505                	li	a0,1
    2dec:	00002097          	auipc	ra,0x2
    2df0:	750080e7          	jalr	1872(ra) # 553c <exit>
      printf("%s: mkdir failed\n", s);
    2df4:	85a6                	mv	a1,s1
    2df6:	00004517          	auipc	a0,0x4
    2dfa:	1e250513          	addi	a0,a0,482 # 6fd8 <malloc+0x1664>
    2dfe:	00003097          	auipc	ra,0x3
    2e02:	ab6080e7          	jalr	-1354(ra) # 58b4 <printf>
      exit(1);
    2e06:	4505                	li	a0,1
    2e08:	00002097          	auipc	ra,0x2
    2e0c:	734080e7          	jalr	1844(ra) # 553c <exit>
      printf("%s: child chdir failed\n", s);
    2e10:	85a6                	mv	a1,s1
    2e12:	00004517          	auipc	a0,0x4
    2e16:	24e50513          	addi	a0,a0,590 # 7060 <malloc+0x16ec>
    2e1a:	00003097          	auipc	ra,0x3
    2e1e:	a9a080e7          	jalr	-1382(ra) # 58b4 <printf>
      exit(1);
    2e22:	4505                	li	a0,1
    2e24:	00002097          	auipc	ra,0x2
    2e28:	718080e7          	jalr	1816(ra) # 553c <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2e2c:	85a6                	mv	a1,s1
    2e2e:	00004517          	auipc	a0,0x4
    2e32:	1f250513          	addi	a0,a0,498 # 7020 <malloc+0x16ac>
    2e36:	00003097          	auipc	ra,0x3
    2e3a:	a7e080e7          	jalr	-1410(ra) # 58b4 <printf>
      exit(1);
    2e3e:	4505                	li	a0,1
    2e40:	00002097          	auipc	ra,0x2
    2e44:	6fc080e7          	jalr	1788(ra) # 553c <exit>
  wait(&xstatus);
    2e48:	fdc40513          	addi	a0,s0,-36
    2e4c:	00002097          	auipc	ra,0x2
    2e50:	6f8080e7          	jalr	1784(ra) # 5544 <wait>
  exit(xstatus);
    2e54:	fdc42503          	lw	a0,-36(s0)
    2e58:	00002097          	auipc	ra,0x2
    2e5c:	6e4080e7          	jalr	1764(ra) # 553c <exit>

0000000000002e60 <subdir>:
{
    2e60:	1101                	addi	sp,sp,-32
    2e62:	ec06                	sd	ra,24(sp)
    2e64:	e822                	sd	s0,16(sp)
    2e66:	e426                	sd	s1,8(sp)
    2e68:	e04a                	sd	s2,0(sp)
    2e6a:	1000                	addi	s0,sp,32
    2e6c:	892a                	mv	s2,a0
  unlink("ff");
    2e6e:	00004517          	auipc	a0,0x4
    2e72:	33a50513          	addi	a0,a0,826 # 71a8 <malloc+0x1834>
    2e76:	00002097          	auipc	ra,0x2
    2e7a:	716080e7          	jalr	1814(ra) # 558c <unlink>
  if(mkdir("dd") != 0){
    2e7e:	00004517          	auipc	a0,0x4
    2e82:	1fa50513          	addi	a0,a0,506 # 7078 <malloc+0x1704>
    2e86:	00002097          	auipc	ra,0x2
    2e8a:	71e080e7          	jalr	1822(ra) # 55a4 <mkdir>
    2e8e:	38051663          	bnez	a0,321a <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2e92:	20200593          	li	a1,514
    2e96:	00004517          	auipc	a0,0x4
    2e9a:	20250513          	addi	a0,a0,514 # 7098 <malloc+0x1724>
    2e9e:	00002097          	auipc	ra,0x2
    2ea2:	6de080e7          	jalr	1758(ra) # 557c <open>
    2ea6:	84aa                	mv	s1,a0
  if(fd < 0){
    2ea8:	38054763          	bltz	a0,3236 <subdir+0x3d6>
  write(fd, "ff", 2);
    2eac:	4609                	li	a2,2
    2eae:	00004597          	auipc	a1,0x4
    2eb2:	2fa58593          	addi	a1,a1,762 # 71a8 <malloc+0x1834>
    2eb6:	00002097          	auipc	ra,0x2
    2eba:	6a6080e7          	jalr	1702(ra) # 555c <write>
  close(fd);
    2ebe:	8526                	mv	a0,s1
    2ec0:	00002097          	auipc	ra,0x2
    2ec4:	6a4080e7          	jalr	1700(ra) # 5564 <close>
  if(unlink("dd") >= 0){
    2ec8:	00004517          	auipc	a0,0x4
    2ecc:	1b050513          	addi	a0,a0,432 # 7078 <malloc+0x1704>
    2ed0:	00002097          	auipc	ra,0x2
    2ed4:	6bc080e7          	jalr	1724(ra) # 558c <unlink>
    2ed8:	36055d63          	bgez	a0,3252 <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2edc:	00004517          	auipc	a0,0x4
    2ee0:	21450513          	addi	a0,a0,532 # 70f0 <malloc+0x177c>
    2ee4:	00002097          	auipc	ra,0x2
    2ee8:	6c0080e7          	jalr	1728(ra) # 55a4 <mkdir>
    2eec:	38051163          	bnez	a0,326e <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2ef0:	20200593          	li	a1,514
    2ef4:	00004517          	auipc	a0,0x4
    2ef8:	22450513          	addi	a0,a0,548 # 7118 <malloc+0x17a4>
    2efc:	00002097          	auipc	ra,0x2
    2f00:	680080e7          	jalr	1664(ra) # 557c <open>
    2f04:	84aa                	mv	s1,a0
  if(fd < 0){
    2f06:	38054263          	bltz	a0,328a <subdir+0x42a>
  write(fd, "FF", 2);
    2f0a:	4609                	li	a2,2
    2f0c:	00004597          	auipc	a1,0x4
    2f10:	23c58593          	addi	a1,a1,572 # 7148 <malloc+0x17d4>
    2f14:	00002097          	auipc	ra,0x2
    2f18:	648080e7          	jalr	1608(ra) # 555c <write>
  close(fd);
    2f1c:	8526                	mv	a0,s1
    2f1e:	00002097          	auipc	ra,0x2
    2f22:	646080e7          	jalr	1606(ra) # 5564 <close>
  fd = open("dd/dd/../ff", 0);
    2f26:	4581                	li	a1,0
    2f28:	00004517          	auipc	a0,0x4
    2f2c:	22850513          	addi	a0,a0,552 # 7150 <malloc+0x17dc>
    2f30:	00002097          	auipc	ra,0x2
    2f34:	64c080e7          	jalr	1612(ra) # 557c <open>
    2f38:	84aa                	mv	s1,a0
  if(fd < 0){
    2f3a:	36054663          	bltz	a0,32a6 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    2f3e:	660d                	lui	a2,0x3
    2f40:	00009597          	auipc	a1,0x9
    2f44:	a8058593          	addi	a1,a1,-1408 # b9c0 <buf>
    2f48:	00002097          	auipc	ra,0x2
    2f4c:	60c080e7          	jalr	1548(ra) # 5554 <read>
  if(cc != 2 || buf[0] != 'f'){
    2f50:	4789                	li	a5,2
    2f52:	36f51863          	bne	a0,a5,32c2 <subdir+0x462>
    2f56:	00009717          	auipc	a4,0x9
    2f5a:	a6a74703          	lbu	a4,-1430(a4) # b9c0 <buf>
    2f5e:	06600793          	li	a5,102
    2f62:	36f71063          	bne	a4,a5,32c2 <subdir+0x462>
  close(fd);
    2f66:	8526                	mv	a0,s1
    2f68:	00002097          	auipc	ra,0x2
    2f6c:	5fc080e7          	jalr	1532(ra) # 5564 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    2f70:	00004597          	auipc	a1,0x4
    2f74:	23058593          	addi	a1,a1,560 # 71a0 <malloc+0x182c>
    2f78:	00004517          	auipc	a0,0x4
    2f7c:	1a050513          	addi	a0,a0,416 # 7118 <malloc+0x17a4>
    2f80:	00002097          	auipc	ra,0x2
    2f84:	61c080e7          	jalr	1564(ra) # 559c <link>
    2f88:	34051b63          	bnez	a0,32de <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    2f8c:	00004517          	auipc	a0,0x4
    2f90:	18c50513          	addi	a0,a0,396 # 7118 <malloc+0x17a4>
    2f94:	00002097          	auipc	ra,0x2
    2f98:	5f8080e7          	jalr	1528(ra) # 558c <unlink>
    2f9c:	34051f63          	bnez	a0,32fa <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    2fa0:	4581                	li	a1,0
    2fa2:	00004517          	auipc	a0,0x4
    2fa6:	17650513          	addi	a0,a0,374 # 7118 <malloc+0x17a4>
    2faa:	00002097          	auipc	ra,0x2
    2fae:	5d2080e7          	jalr	1490(ra) # 557c <open>
    2fb2:	36055263          	bgez	a0,3316 <subdir+0x4b6>
  if(chdir("dd") != 0){
    2fb6:	00004517          	auipc	a0,0x4
    2fba:	0c250513          	addi	a0,a0,194 # 7078 <malloc+0x1704>
    2fbe:	00002097          	auipc	ra,0x2
    2fc2:	5ee080e7          	jalr	1518(ra) # 55ac <chdir>
    2fc6:	36051663          	bnez	a0,3332 <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    2fca:	00004517          	auipc	a0,0x4
    2fce:	26e50513          	addi	a0,a0,622 # 7238 <malloc+0x18c4>
    2fd2:	00002097          	auipc	ra,0x2
    2fd6:	5da080e7          	jalr	1498(ra) # 55ac <chdir>
    2fda:	36051a63          	bnez	a0,334e <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    2fde:	00004517          	auipc	a0,0x4
    2fe2:	28a50513          	addi	a0,a0,650 # 7268 <malloc+0x18f4>
    2fe6:	00002097          	auipc	ra,0x2
    2fea:	5c6080e7          	jalr	1478(ra) # 55ac <chdir>
    2fee:	36051e63          	bnez	a0,336a <subdir+0x50a>
  if(chdir("./..") != 0){
    2ff2:	00004517          	auipc	a0,0x4
    2ff6:	2a650513          	addi	a0,a0,678 # 7298 <malloc+0x1924>
    2ffa:	00002097          	auipc	ra,0x2
    2ffe:	5b2080e7          	jalr	1458(ra) # 55ac <chdir>
    3002:	38051263          	bnez	a0,3386 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    3006:	4581                	li	a1,0
    3008:	00004517          	auipc	a0,0x4
    300c:	19850513          	addi	a0,a0,408 # 71a0 <malloc+0x182c>
    3010:	00002097          	auipc	ra,0x2
    3014:	56c080e7          	jalr	1388(ra) # 557c <open>
    3018:	84aa                	mv	s1,a0
  if(fd < 0){
    301a:	38054463          	bltz	a0,33a2 <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    301e:	660d                	lui	a2,0x3
    3020:	00009597          	auipc	a1,0x9
    3024:	9a058593          	addi	a1,a1,-1632 # b9c0 <buf>
    3028:	00002097          	auipc	ra,0x2
    302c:	52c080e7          	jalr	1324(ra) # 5554 <read>
    3030:	4789                	li	a5,2
    3032:	38f51663          	bne	a0,a5,33be <subdir+0x55e>
  close(fd);
    3036:	8526                	mv	a0,s1
    3038:	00002097          	auipc	ra,0x2
    303c:	52c080e7          	jalr	1324(ra) # 5564 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    3040:	4581                	li	a1,0
    3042:	00004517          	auipc	a0,0x4
    3046:	0d650513          	addi	a0,a0,214 # 7118 <malloc+0x17a4>
    304a:	00002097          	auipc	ra,0x2
    304e:	532080e7          	jalr	1330(ra) # 557c <open>
    3052:	38055463          	bgez	a0,33da <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3056:	20200593          	li	a1,514
    305a:	00004517          	auipc	a0,0x4
    305e:	2ce50513          	addi	a0,a0,718 # 7328 <malloc+0x19b4>
    3062:	00002097          	auipc	ra,0x2
    3066:	51a080e7          	jalr	1306(ra) # 557c <open>
    306a:	38055663          	bgez	a0,33f6 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    306e:	20200593          	li	a1,514
    3072:	00004517          	auipc	a0,0x4
    3076:	2e650513          	addi	a0,a0,742 # 7358 <malloc+0x19e4>
    307a:	00002097          	auipc	ra,0x2
    307e:	502080e7          	jalr	1282(ra) # 557c <open>
    3082:	38055863          	bgez	a0,3412 <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3086:	20000593          	li	a1,512
    308a:	00004517          	auipc	a0,0x4
    308e:	fee50513          	addi	a0,a0,-18 # 7078 <malloc+0x1704>
    3092:	00002097          	auipc	ra,0x2
    3096:	4ea080e7          	jalr	1258(ra) # 557c <open>
    309a:	38055a63          	bgez	a0,342e <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    309e:	4589                	li	a1,2
    30a0:	00004517          	auipc	a0,0x4
    30a4:	fd850513          	addi	a0,a0,-40 # 7078 <malloc+0x1704>
    30a8:	00002097          	auipc	ra,0x2
    30ac:	4d4080e7          	jalr	1236(ra) # 557c <open>
    30b0:	38055d63          	bgez	a0,344a <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    30b4:	4585                	li	a1,1
    30b6:	00004517          	auipc	a0,0x4
    30ba:	fc250513          	addi	a0,a0,-62 # 7078 <malloc+0x1704>
    30be:	00002097          	auipc	ra,0x2
    30c2:	4be080e7          	jalr	1214(ra) # 557c <open>
    30c6:	3a055063          	bgez	a0,3466 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    30ca:	00004597          	auipc	a1,0x4
    30ce:	31e58593          	addi	a1,a1,798 # 73e8 <malloc+0x1a74>
    30d2:	00004517          	auipc	a0,0x4
    30d6:	25650513          	addi	a0,a0,598 # 7328 <malloc+0x19b4>
    30da:	00002097          	auipc	ra,0x2
    30de:	4c2080e7          	jalr	1218(ra) # 559c <link>
    30e2:	3a050063          	beqz	a0,3482 <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    30e6:	00004597          	auipc	a1,0x4
    30ea:	30258593          	addi	a1,a1,770 # 73e8 <malloc+0x1a74>
    30ee:	00004517          	auipc	a0,0x4
    30f2:	26a50513          	addi	a0,a0,618 # 7358 <malloc+0x19e4>
    30f6:	00002097          	auipc	ra,0x2
    30fa:	4a6080e7          	jalr	1190(ra) # 559c <link>
    30fe:	3a050063          	beqz	a0,349e <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    3102:	00004597          	auipc	a1,0x4
    3106:	09e58593          	addi	a1,a1,158 # 71a0 <malloc+0x182c>
    310a:	00004517          	auipc	a0,0x4
    310e:	f8e50513          	addi	a0,a0,-114 # 7098 <malloc+0x1724>
    3112:	00002097          	auipc	ra,0x2
    3116:	48a080e7          	jalr	1162(ra) # 559c <link>
    311a:	3a050063          	beqz	a0,34ba <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    311e:	00004517          	auipc	a0,0x4
    3122:	20a50513          	addi	a0,a0,522 # 7328 <malloc+0x19b4>
    3126:	00002097          	auipc	ra,0x2
    312a:	47e080e7          	jalr	1150(ra) # 55a4 <mkdir>
    312e:	3a050463          	beqz	a0,34d6 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    3132:	00004517          	auipc	a0,0x4
    3136:	22650513          	addi	a0,a0,550 # 7358 <malloc+0x19e4>
    313a:	00002097          	auipc	ra,0x2
    313e:	46a080e7          	jalr	1130(ra) # 55a4 <mkdir>
    3142:	3a050863          	beqz	a0,34f2 <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3146:	00004517          	auipc	a0,0x4
    314a:	05a50513          	addi	a0,a0,90 # 71a0 <malloc+0x182c>
    314e:	00002097          	auipc	ra,0x2
    3152:	456080e7          	jalr	1110(ra) # 55a4 <mkdir>
    3156:	3a050c63          	beqz	a0,350e <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    315a:	00004517          	auipc	a0,0x4
    315e:	1fe50513          	addi	a0,a0,510 # 7358 <malloc+0x19e4>
    3162:	00002097          	auipc	ra,0x2
    3166:	42a080e7          	jalr	1066(ra) # 558c <unlink>
    316a:	3c050063          	beqz	a0,352a <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    316e:	00004517          	auipc	a0,0x4
    3172:	1ba50513          	addi	a0,a0,442 # 7328 <malloc+0x19b4>
    3176:	00002097          	auipc	ra,0x2
    317a:	416080e7          	jalr	1046(ra) # 558c <unlink>
    317e:	3c050463          	beqz	a0,3546 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    3182:	00004517          	auipc	a0,0x4
    3186:	f1650513          	addi	a0,a0,-234 # 7098 <malloc+0x1724>
    318a:	00002097          	auipc	ra,0x2
    318e:	422080e7          	jalr	1058(ra) # 55ac <chdir>
    3192:	3c050863          	beqz	a0,3562 <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3196:	00004517          	auipc	a0,0x4
    319a:	3a250513          	addi	a0,a0,930 # 7538 <malloc+0x1bc4>
    319e:	00002097          	auipc	ra,0x2
    31a2:	40e080e7          	jalr	1038(ra) # 55ac <chdir>
    31a6:	3c050c63          	beqz	a0,357e <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    31aa:	00004517          	auipc	a0,0x4
    31ae:	ff650513          	addi	a0,a0,-10 # 71a0 <malloc+0x182c>
    31b2:	00002097          	auipc	ra,0x2
    31b6:	3da080e7          	jalr	986(ra) # 558c <unlink>
    31ba:	3e051063          	bnez	a0,359a <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    31be:	00004517          	auipc	a0,0x4
    31c2:	eda50513          	addi	a0,a0,-294 # 7098 <malloc+0x1724>
    31c6:	00002097          	auipc	ra,0x2
    31ca:	3c6080e7          	jalr	966(ra) # 558c <unlink>
    31ce:	3e051463          	bnez	a0,35b6 <subdir+0x756>
  if(unlink("dd") == 0){
    31d2:	00004517          	auipc	a0,0x4
    31d6:	ea650513          	addi	a0,a0,-346 # 7078 <malloc+0x1704>
    31da:	00002097          	auipc	ra,0x2
    31de:	3b2080e7          	jalr	946(ra) # 558c <unlink>
    31e2:	3e050863          	beqz	a0,35d2 <subdir+0x772>
  if(unlink("dd/dd") < 0){
    31e6:	00004517          	auipc	a0,0x4
    31ea:	3c250513          	addi	a0,a0,962 # 75a8 <malloc+0x1c34>
    31ee:	00002097          	auipc	ra,0x2
    31f2:	39e080e7          	jalr	926(ra) # 558c <unlink>
    31f6:	3e054c63          	bltz	a0,35ee <subdir+0x78e>
  if(unlink("dd") < 0){
    31fa:	00004517          	auipc	a0,0x4
    31fe:	e7e50513          	addi	a0,a0,-386 # 7078 <malloc+0x1704>
    3202:	00002097          	auipc	ra,0x2
    3206:	38a080e7          	jalr	906(ra) # 558c <unlink>
    320a:	40054063          	bltz	a0,360a <subdir+0x7aa>
}
    320e:	60e2                	ld	ra,24(sp)
    3210:	6442                	ld	s0,16(sp)
    3212:	64a2                	ld	s1,8(sp)
    3214:	6902                	ld	s2,0(sp)
    3216:	6105                	addi	sp,sp,32
    3218:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    321a:	85ca                	mv	a1,s2
    321c:	00004517          	auipc	a0,0x4
    3220:	e6450513          	addi	a0,a0,-412 # 7080 <malloc+0x170c>
    3224:	00002097          	auipc	ra,0x2
    3228:	690080e7          	jalr	1680(ra) # 58b4 <printf>
    exit(1);
    322c:	4505                	li	a0,1
    322e:	00002097          	auipc	ra,0x2
    3232:	30e080e7          	jalr	782(ra) # 553c <exit>
    printf("%s: create dd/ff failed\n", s);
    3236:	85ca                	mv	a1,s2
    3238:	00004517          	auipc	a0,0x4
    323c:	e6850513          	addi	a0,a0,-408 # 70a0 <malloc+0x172c>
    3240:	00002097          	auipc	ra,0x2
    3244:	674080e7          	jalr	1652(ra) # 58b4 <printf>
    exit(1);
    3248:	4505                	li	a0,1
    324a:	00002097          	auipc	ra,0x2
    324e:	2f2080e7          	jalr	754(ra) # 553c <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    3252:	85ca                	mv	a1,s2
    3254:	00004517          	auipc	a0,0x4
    3258:	e6c50513          	addi	a0,a0,-404 # 70c0 <malloc+0x174c>
    325c:	00002097          	auipc	ra,0x2
    3260:	658080e7          	jalr	1624(ra) # 58b4 <printf>
    exit(1);
    3264:	4505                	li	a0,1
    3266:	00002097          	auipc	ra,0x2
    326a:	2d6080e7          	jalr	726(ra) # 553c <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    326e:	85ca                	mv	a1,s2
    3270:	00004517          	auipc	a0,0x4
    3274:	e8850513          	addi	a0,a0,-376 # 70f8 <malloc+0x1784>
    3278:	00002097          	auipc	ra,0x2
    327c:	63c080e7          	jalr	1596(ra) # 58b4 <printf>
    exit(1);
    3280:	4505                	li	a0,1
    3282:	00002097          	auipc	ra,0x2
    3286:	2ba080e7          	jalr	698(ra) # 553c <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    328a:	85ca                	mv	a1,s2
    328c:	00004517          	auipc	a0,0x4
    3290:	e9c50513          	addi	a0,a0,-356 # 7128 <malloc+0x17b4>
    3294:	00002097          	auipc	ra,0x2
    3298:	620080e7          	jalr	1568(ra) # 58b4 <printf>
    exit(1);
    329c:	4505                	li	a0,1
    329e:	00002097          	auipc	ra,0x2
    32a2:	29e080e7          	jalr	670(ra) # 553c <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    32a6:	85ca                	mv	a1,s2
    32a8:	00004517          	auipc	a0,0x4
    32ac:	eb850513          	addi	a0,a0,-328 # 7160 <malloc+0x17ec>
    32b0:	00002097          	auipc	ra,0x2
    32b4:	604080e7          	jalr	1540(ra) # 58b4 <printf>
    exit(1);
    32b8:	4505                	li	a0,1
    32ba:	00002097          	auipc	ra,0x2
    32be:	282080e7          	jalr	642(ra) # 553c <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    32c2:	85ca                	mv	a1,s2
    32c4:	00004517          	auipc	a0,0x4
    32c8:	ebc50513          	addi	a0,a0,-324 # 7180 <malloc+0x180c>
    32cc:	00002097          	auipc	ra,0x2
    32d0:	5e8080e7          	jalr	1512(ra) # 58b4 <printf>
    exit(1);
    32d4:	4505                	li	a0,1
    32d6:	00002097          	auipc	ra,0x2
    32da:	266080e7          	jalr	614(ra) # 553c <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    32de:	85ca                	mv	a1,s2
    32e0:	00004517          	auipc	a0,0x4
    32e4:	ed050513          	addi	a0,a0,-304 # 71b0 <malloc+0x183c>
    32e8:	00002097          	auipc	ra,0x2
    32ec:	5cc080e7          	jalr	1484(ra) # 58b4 <printf>
    exit(1);
    32f0:	4505                	li	a0,1
    32f2:	00002097          	auipc	ra,0x2
    32f6:	24a080e7          	jalr	586(ra) # 553c <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    32fa:	85ca                	mv	a1,s2
    32fc:	00004517          	auipc	a0,0x4
    3300:	edc50513          	addi	a0,a0,-292 # 71d8 <malloc+0x1864>
    3304:	00002097          	auipc	ra,0x2
    3308:	5b0080e7          	jalr	1456(ra) # 58b4 <printf>
    exit(1);
    330c:	4505                	li	a0,1
    330e:	00002097          	auipc	ra,0x2
    3312:	22e080e7          	jalr	558(ra) # 553c <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3316:	85ca                	mv	a1,s2
    3318:	00004517          	auipc	a0,0x4
    331c:	ee050513          	addi	a0,a0,-288 # 71f8 <malloc+0x1884>
    3320:	00002097          	auipc	ra,0x2
    3324:	594080e7          	jalr	1428(ra) # 58b4 <printf>
    exit(1);
    3328:	4505                	li	a0,1
    332a:	00002097          	auipc	ra,0x2
    332e:	212080e7          	jalr	530(ra) # 553c <exit>
    printf("%s: chdir dd failed\n", s);
    3332:	85ca                	mv	a1,s2
    3334:	00004517          	auipc	a0,0x4
    3338:	eec50513          	addi	a0,a0,-276 # 7220 <malloc+0x18ac>
    333c:	00002097          	auipc	ra,0x2
    3340:	578080e7          	jalr	1400(ra) # 58b4 <printf>
    exit(1);
    3344:	4505                	li	a0,1
    3346:	00002097          	auipc	ra,0x2
    334a:	1f6080e7          	jalr	502(ra) # 553c <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    334e:	85ca                	mv	a1,s2
    3350:	00004517          	auipc	a0,0x4
    3354:	ef850513          	addi	a0,a0,-264 # 7248 <malloc+0x18d4>
    3358:	00002097          	auipc	ra,0x2
    335c:	55c080e7          	jalr	1372(ra) # 58b4 <printf>
    exit(1);
    3360:	4505                	li	a0,1
    3362:	00002097          	auipc	ra,0x2
    3366:	1da080e7          	jalr	474(ra) # 553c <exit>
    printf("chdir dd/../../dd failed\n", s);
    336a:	85ca                	mv	a1,s2
    336c:	00004517          	auipc	a0,0x4
    3370:	f0c50513          	addi	a0,a0,-244 # 7278 <malloc+0x1904>
    3374:	00002097          	auipc	ra,0x2
    3378:	540080e7          	jalr	1344(ra) # 58b4 <printf>
    exit(1);
    337c:	4505                	li	a0,1
    337e:	00002097          	auipc	ra,0x2
    3382:	1be080e7          	jalr	446(ra) # 553c <exit>
    printf("%s: chdir ./.. failed\n", s);
    3386:	85ca                	mv	a1,s2
    3388:	00004517          	auipc	a0,0x4
    338c:	f1850513          	addi	a0,a0,-232 # 72a0 <malloc+0x192c>
    3390:	00002097          	auipc	ra,0x2
    3394:	524080e7          	jalr	1316(ra) # 58b4 <printf>
    exit(1);
    3398:	4505                	li	a0,1
    339a:	00002097          	auipc	ra,0x2
    339e:	1a2080e7          	jalr	418(ra) # 553c <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    33a2:	85ca                	mv	a1,s2
    33a4:	00004517          	auipc	a0,0x4
    33a8:	f1450513          	addi	a0,a0,-236 # 72b8 <malloc+0x1944>
    33ac:	00002097          	auipc	ra,0x2
    33b0:	508080e7          	jalr	1288(ra) # 58b4 <printf>
    exit(1);
    33b4:	4505                	li	a0,1
    33b6:	00002097          	auipc	ra,0x2
    33ba:	186080e7          	jalr	390(ra) # 553c <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    33be:	85ca                	mv	a1,s2
    33c0:	00004517          	auipc	a0,0x4
    33c4:	f1850513          	addi	a0,a0,-232 # 72d8 <malloc+0x1964>
    33c8:	00002097          	auipc	ra,0x2
    33cc:	4ec080e7          	jalr	1260(ra) # 58b4 <printf>
    exit(1);
    33d0:	4505                	li	a0,1
    33d2:	00002097          	auipc	ra,0x2
    33d6:	16a080e7          	jalr	362(ra) # 553c <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    33da:	85ca                	mv	a1,s2
    33dc:	00004517          	auipc	a0,0x4
    33e0:	f1c50513          	addi	a0,a0,-228 # 72f8 <malloc+0x1984>
    33e4:	00002097          	auipc	ra,0x2
    33e8:	4d0080e7          	jalr	1232(ra) # 58b4 <printf>
    exit(1);
    33ec:	4505                	li	a0,1
    33ee:	00002097          	auipc	ra,0x2
    33f2:	14e080e7          	jalr	334(ra) # 553c <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    33f6:	85ca                	mv	a1,s2
    33f8:	00004517          	auipc	a0,0x4
    33fc:	f4050513          	addi	a0,a0,-192 # 7338 <malloc+0x19c4>
    3400:	00002097          	auipc	ra,0x2
    3404:	4b4080e7          	jalr	1204(ra) # 58b4 <printf>
    exit(1);
    3408:	4505                	li	a0,1
    340a:	00002097          	auipc	ra,0x2
    340e:	132080e7          	jalr	306(ra) # 553c <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    3412:	85ca                	mv	a1,s2
    3414:	00004517          	auipc	a0,0x4
    3418:	f5450513          	addi	a0,a0,-172 # 7368 <malloc+0x19f4>
    341c:	00002097          	auipc	ra,0x2
    3420:	498080e7          	jalr	1176(ra) # 58b4 <printf>
    exit(1);
    3424:	4505                	li	a0,1
    3426:	00002097          	auipc	ra,0x2
    342a:	116080e7          	jalr	278(ra) # 553c <exit>
    printf("%s: create dd succeeded!\n", s);
    342e:	85ca                	mv	a1,s2
    3430:	00004517          	auipc	a0,0x4
    3434:	f5850513          	addi	a0,a0,-168 # 7388 <malloc+0x1a14>
    3438:	00002097          	auipc	ra,0x2
    343c:	47c080e7          	jalr	1148(ra) # 58b4 <printf>
    exit(1);
    3440:	4505                	li	a0,1
    3442:	00002097          	auipc	ra,0x2
    3446:	0fa080e7          	jalr	250(ra) # 553c <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    344a:	85ca                	mv	a1,s2
    344c:	00004517          	auipc	a0,0x4
    3450:	f5c50513          	addi	a0,a0,-164 # 73a8 <malloc+0x1a34>
    3454:	00002097          	auipc	ra,0x2
    3458:	460080e7          	jalr	1120(ra) # 58b4 <printf>
    exit(1);
    345c:	4505                	li	a0,1
    345e:	00002097          	auipc	ra,0x2
    3462:	0de080e7          	jalr	222(ra) # 553c <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3466:	85ca                	mv	a1,s2
    3468:	00004517          	auipc	a0,0x4
    346c:	f6050513          	addi	a0,a0,-160 # 73c8 <malloc+0x1a54>
    3470:	00002097          	auipc	ra,0x2
    3474:	444080e7          	jalr	1092(ra) # 58b4 <printf>
    exit(1);
    3478:	4505                	li	a0,1
    347a:	00002097          	auipc	ra,0x2
    347e:	0c2080e7          	jalr	194(ra) # 553c <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    3482:	85ca                	mv	a1,s2
    3484:	00004517          	auipc	a0,0x4
    3488:	f7450513          	addi	a0,a0,-140 # 73f8 <malloc+0x1a84>
    348c:	00002097          	auipc	ra,0x2
    3490:	428080e7          	jalr	1064(ra) # 58b4 <printf>
    exit(1);
    3494:	4505                	li	a0,1
    3496:	00002097          	auipc	ra,0x2
    349a:	0a6080e7          	jalr	166(ra) # 553c <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    349e:	85ca                	mv	a1,s2
    34a0:	00004517          	auipc	a0,0x4
    34a4:	f8050513          	addi	a0,a0,-128 # 7420 <malloc+0x1aac>
    34a8:	00002097          	auipc	ra,0x2
    34ac:	40c080e7          	jalr	1036(ra) # 58b4 <printf>
    exit(1);
    34b0:	4505                	li	a0,1
    34b2:	00002097          	auipc	ra,0x2
    34b6:	08a080e7          	jalr	138(ra) # 553c <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    34ba:	85ca                	mv	a1,s2
    34bc:	00004517          	auipc	a0,0x4
    34c0:	f8c50513          	addi	a0,a0,-116 # 7448 <malloc+0x1ad4>
    34c4:	00002097          	auipc	ra,0x2
    34c8:	3f0080e7          	jalr	1008(ra) # 58b4 <printf>
    exit(1);
    34cc:	4505                	li	a0,1
    34ce:	00002097          	auipc	ra,0x2
    34d2:	06e080e7          	jalr	110(ra) # 553c <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    34d6:	85ca                	mv	a1,s2
    34d8:	00004517          	auipc	a0,0x4
    34dc:	f9850513          	addi	a0,a0,-104 # 7470 <malloc+0x1afc>
    34e0:	00002097          	auipc	ra,0x2
    34e4:	3d4080e7          	jalr	980(ra) # 58b4 <printf>
    exit(1);
    34e8:	4505                	li	a0,1
    34ea:	00002097          	auipc	ra,0x2
    34ee:	052080e7          	jalr	82(ra) # 553c <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    34f2:	85ca                	mv	a1,s2
    34f4:	00004517          	auipc	a0,0x4
    34f8:	f9c50513          	addi	a0,a0,-100 # 7490 <malloc+0x1b1c>
    34fc:	00002097          	auipc	ra,0x2
    3500:	3b8080e7          	jalr	952(ra) # 58b4 <printf>
    exit(1);
    3504:	4505                	li	a0,1
    3506:	00002097          	auipc	ra,0x2
    350a:	036080e7          	jalr	54(ra) # 553c <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    350e:	85ca                	mv	a1,s2
    3510:	00004517          	auipc	a0,0x4
    3514:	fa050513          	addi	a0,a0,-96 # 74b0 <malloc+0x1b3c>
    3518:	00002097          	auipc	ra,0x2
    351c:	39c080e7          	jalr	924(ra) # 58b4 <printf>
    exit(1);
    3520:	4505                	li	a0,1
    3522:	00002097          	auipc	ra,0x2
    3526:	01a080e7          	jalr	26(ra) # 553c <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    352a:	85ca                	mv	a1,s2
    352c:	00004517          	auipc	a0,0x4
    3530:	fac50513          	addi	a0,a0,-84 # 74d8 <malloc+0x1b64>
    3534:	00002097          	auipc	ra,0x2
    3538:	380080e7          	jalr	896(ra) # 58b4 <printf>
    exit(1);
    353c:	4505                	li	a0,1
    353e:	00002097          	auipc	ra,0x2
    3542:	ffe080e7          	jalr	-2(ra) # 553c <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3546:	85ca                	mv	a1,s2
    3548:	00004517          	auipc	a0,0x4
    354c:	fb050513          	addi	a0,a0,-80 # 74f8 <malloc+0x1b84>
    3550:	00002097          	auipc	ra,0x2
    3554:	364080e7          	jalr	868(ra) # 58b4 <printf>
    exit(1);
    3558:	4505                	li	a0,1
    355a:	00002097          	auipc	ra,0x2
    355e:	fe2080e7          	jalr	-30(ra) # 553c <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    3562:	85ca                	mv	a1,s2
    3564:	00004517          	auipc	a0,0x4
    3568:	fb450513          	addi	a0,a0,-76 # 7518 <malloc+0x1ba4>
    356c:	00002097          	auipc	ra,0x2
    3570:	348080e7          	jalr	840(ra) # 58b4 <printf>
    exit(1);
    3574:	4505                	li	a0,1
    3576:	00002097          	auipc	ra,0x2
    357a:	fc6080e7          	jalr	-58(ra) # 553c <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    357e:	85ca                	mv	a1,s2
    3580:	00004517          	auipc	a0,0x4
    3584:	fc050513          	addi	a0,a0,-64 # 7540 <malloc+0x1bcc>
    3588:	00002097          	auipc	ra,0x2
    358c:	32c080e7          	jalr	812(ra) # 58b4 <printf>
    exit(1);
    3590:	4505                	li	a0,1
    3592:	00002097          	auipc	ra,0x2
    3596:	faa080e7          	jalr	-86(ra) # 553c <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    359a:	85ca                	mv	a1,s2
    359c:	00004517          	auipc	a0,0x4
    35a0:	c3c50513          	addi	a0,a0,-964 # 71d8 <malloc+0x1864>
    35a4:	00002097          	auipc	ra,0x2
    35a8:	310080e7          	jalr	784(ra) # 58b4 <printf>
    exit(1);
    35ac:	4505                	li	a0,1
    35ae:	00002097          	auipc	ra,0x2
    35b2:	f8e080e7          	jalr	-114(ra) # 553c <exit>
    printf("%s: unlink dd/ff failed\n", s);
    35b6:	85ca                	mv	a1,s2
    35b8:	00004517          	auipc	a0,0x4
    35bc:	fa850513          	addi	a0,a0,-88 # 7560 <malloc+0x1bec>
    35c0:	00002097          	auipc	ra,0x2
    35c4:	2f4080e7          	jalr	756(ra) # 58b4 <printf>
    exit(1);
    35c8:	4505                	li	a0,1
    35ca:	00002097          	auipc	ra,0x2
    35ce:	f72080e7          	jalr	-142(ra) # 553c <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    35d2:	85ca                	mv	a1,s2
    35d4:	00004517          	auipc	a0,0x4
    35d8:	fac50513          	addi	a0,a0,-84 # 7580 <malloc+0x1c0c>
    35dc:	00002097          	auipc	ra,0x2
    35e0:	2d8080e7          	jalr	728(ra) # 58b4 <printf>
    exit(1);
    35e4:	4505                	li	a0,1
    35e6:	00002097          	auipc	ra,0x2
    35ea:	f56080e7          	jalr	-170(ra) # 553c <exit>
    printf("%s: unlink dd/dd failed\n", s);
    35ee:	85ca                	mv	a1,s2
    35f0:	00004517          	auipc	a0,0x4
    35f4:	fc050513          	addi	a0,a0,-64 # 75b0 <malloc+0x1c3c>
    35f8:	00002097          	auipc	ra,0x2
    35fc:	2bc080e7          	jalr	700(ra) # 58b4 <printf>
    exit(1);
    3600:	4505                	li	a0,1
    3602:	00002097          	auipc	ra,0x2
    3606:	f3a080e7          	jalr	-198(ra) # 553c <exit>
    printf("%s: unlink dd failed\n", s);
    360a:	85ca                	mv	a1,s2
    360c:	00004517          	auipc	a0,0x4
    3610:	fc450513          	addi	a0,a0,-60 # 75d0 <malloc+0x1c5c>
    3614:	00002097          	auipc	ra,0x2
    3618:	2a0080e7          	jalr	672(ra) # 58b4 <printf>
    exit(1);
    361c:	4505                	li	a0,1
    361e:	00002097          	auipc	ra,0x2
    3622:	f1e080e7          	jalr	-226(ra) # 553c <exit>

0000000000003626 <rmdot>:
{
    3626:	1101                	addi	sp,sp,-32
    3628:	ec06                	sd	ra,24(sp)
    362a:	e822                	sd	s0,16(sp)
    362c:	e426                	sd	s1,8(sp)
    362e:	1000                	addi	s0,sp,32
    3630:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    3632:	00004517          	auipc	a0,0x4
    3636:	fb650513          	addi	a0,a0,-74 # 75e8 <malloc+0x1c74>
    363a:	00002097          	auipc	ra,0x2
    363e:	f6a080e7          	jalr	-150(ra) # 55a4 <mkdir>
    3642:	e549                	bnez	a0,36cc <rmdot+0xa6>
  if(chdir("dots") != 0){
    3644:	00004517          	auipc	a0,0x4
    3648:	fa450513          	addi	a0,a0,-92 # 75e8 <malloc+0x1c74>
    364c:	00002097          	auipc	ra,0x2
    3650:	f60080e7          	jalr	-160(ra) # 55ac <chdir>
    3654:	e951                	bnez	a0,36e8 <rmdot+0xc2>
  if(unlink(".") == 0){
    3656:	00003517          	auipc	a0,0x3
    365a:	eaa50513          	addi	a0,a0,-342 # 6500 <malloc+0xb8c>
    365e:	00002097          	auipc	ra,0x2
    3662:	f2e080e7          	jalr	-210(ra) # 558c <unlink>
    3666:	cd59                	beqz	a0,3704 <rmdot+0xde>
  if(unlink("..") == 0){
    3668:	00004517          	auipc	a0,0x4
    366c:	fd050513          	addi	a0,a0,-48 # 7638 <malloc+0x1cc4>
    3670:	00002097          	auipc	ra,0x2
    3674:	f1c080e7          	jalr	-228(ra) # 558c <unlink>
    3678:	c545                	beqz	a0,3720 <rmdot+0xfa>
  if(chdir("/") != 0){
    367a:	00004517          	auipc	a0,0x4
    367e:	9c650513          	addi	a0,a0,-1594 # 7040 <malloc+0x16cc>
    3682:	00002097          	auipc	ra,0x2
    3686:	f2a080e7          	jalr	-214(ra) # 55ac <chdir>
    368a:	e94d                	bnez	a0,373c <rmdot+0x116>
  if(unlink("dots/.") == 0){
    368c:	00004517          	auipc	a0,0x4
    3690:	fcc50513          	addi	a0,a0,-52 # 7658 <malloc+0x1ce4>
    3694:	00002097          	auipc	ra,0x2
    3698:	ef8080e7          	jalr	-264(ra) # 558c <unlink>
    369c:	cd55                	beqz	a0,3758 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    369e:	00004517          	auipc	a0,0x4
    36a2:	fe250513          	addi	a0,a0,-30 # 7680 <malloc+0x1d0c>
    36a6:	00002097          	auipc	ra,0x2
    36aa:	ee6080e7          	jalr	-282(ra) # 558c <unlink>
    36ae:	c179                	beqz	a0,3774 <rmdot+0x14e>
  if(unlink("dots") != 0){
    36b0:	00004517          	auipc	a0,0x4
    36b4:	f3850513          	addi	a0,a0,-200 # 75e8 <malloc+0x1c74>
    36b8:	00002097          	auipc	ra,0x2
    36bc:	ed4080e7          	jalr	-300(ra) # 558c <unlink>
    36c0:	e961                	bnez	a0,3790 <rmdot+0x16a>
}
    36c2:	60e2                	ld	ra,24(sp)
    36c4:	6442                	ld	s0,16(sp)
    36c6:	64a2                	ld	s1,8(sp)
    36c8:	6105                	addi	sp,sp,32
    36ca:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    36cc:	85a6                	mv	a1,s1
    36ce:	00004517          	auipc	a0,0x4
    36d2:	f2250513          	addi	a0,a0,-222 # 75f0 <malloc+0x1c7c>
    36d6:	00002097          	auipc	ra,0x2
    36da:	1de080e7          	jalr	478(ra) # 58b4 <printf>
    exit(1);
    36de:	4505                	li	a0,1
    36e0:	00002097          	auipc	ra,0x2
    36e4:	e5c080e7          	jalr	-420(ra) # 553c <exit>
    printf("%s: chdir dots failed\n", s);
    36e8:	85a6                	mv	a1,s1
    36ea:	00004517          	auipc	a0,0x4
    36ee:	f1e50513          	addi	a0,a0,-226 # 7608 <malloc+0x1c94>
    36f2:	00002097          	auipc	ra,0x2
    36f6:	1c2080e7          	jalr	450(ra) # 58b4 <printf>
    exit(1);
    36fa:	4505                	li	a0,1
    36fc:	00002097          	auipc	ra,0x2
    3700:	e40080e7          	jalr	-448(ra) # 553c <exit>
    printf("%s: rm . worked!\n", s);
    3704:	85a6                	mv	a1,s1
    3706:	00004517          	auipc	a0,0x4
    370a:	f1a50513          	addi	a0,a0,-230 # 7620 <malloc+0x1cac>
    370e:	00002097          	auipc	ra,0x2
    3712:	1a6080e7          	jalr	422(ra) # 58b4 <printf>
    exit(1);
    3716:	4505                	li	a0,1
    3718:	00002097          	auipc	ra,0x2
    371c:	e24080e7          	jalr	-476(ra) # 553c <exit>
    printf("%s: rm .. worked!\n", s);
    3720:	85a6                	mv	a1,s1
    3722:	00004517          	auipc	a0,0x4
    3726:	f1e50513          	addi	a0,a0,-226 # 7640 <malloc+0x1ccc>
    372a:	00002097          	auipc	ra,0x2
    372e:	18a080e7          	jalr	394(ra) # 58b4 <printf>
    exit(1);
    3732:	4505                	li	a0,1
    3734:	00002097          	auipc	ra,0x2
    3738:	e08080e7          	jalr	-504(ra) # 553c <exit>
    printf("%s: chdir / failed\n", s);
    373c:	85a6                	mv	a1,s1
    373e:	00004517          	auipc	a0,0x4
    3742:	90a50513          	addi	a0,a0,-1782 # 7048 <malloc+0x16d4>
    3746:	00002097          	auipc	ra,0x2
    374a:	16e080e7          	jalr	366(ra) # 58b4 <printf>
    exit(1);
    374e:	4505                	li	a0,1
    3750:	00002097          	auipc	ra,0x2
    3754:	dec080e7          	jalr	-532(ra) # 553c <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3758:	85a6                	mv	a1,s1
    375a:	00004517          	auipc	a0,0x4
    375e:	f0650513          	addi	a0,a0,-250 # 7660 <malloc+0x1cec>
    3762:	00002097          	auipc	ra,0x2
    3766:	152080e7          	jalr	338(ra) # 58b4 <printf>
    exit(1);
    376a:	4505                	li	a0,1
    376c:	00002097          	auipc	ra,0x2
    3770:	dd0080e7          	jalr	-560(ra) # 553c <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3774:	85a6                	mv	a1,s1
    3776:	00004517          	auipc	a0,0x4
    377a:	f1250513          	addi	a0,a0,-238 # 7688 <malloc+0x1d14>
    377e:	00002097          	auipc	ra,0x2
    3782:	136080e7          	jalr	310(ra) # 58b4 <printf>
    exit(1);
    3786:	4505                	li	a0,1
    3788:	00002097          	auipc	ra,0x2
    378c:	db4080e7          	jalr	-588(ra) # 553c <exit>
    printf("%s: unlink dots failed!\n", s);
    3790:	85a6                	mv	a1,s1
    3792:	00004517          	auipc	a0,0x4
    3796:	f1650513          	addi	a0,a0,-234 # 76a8 <malloc+0x1d34>
    379a:	00002097          	auipc	ra,0x2
    379e:	11a080e7          	jalr	282(ra) # 58b4 <printf>
    exit(1);
    37a2:	4505                	li	a0,1
    37a4:	00002097          	auipc	ra,0x2
    37a8:	d98080e7          	jalr	-616(ra) # 553c <exit>

00000000000037ac <dirfile>:
{
    37ac:	1101                	addi	sp,sp,-32
    37ae:	ec06                	sd	ra,24(sp)
    37b0:	e822                	sd	s0,16(sp)
    37b2:	e426                	sd	s1,8(sp)
    37b4:	e04a                	sd	s2,0(sp)
    37b6:	1000                	addi	s0,sp,32
    37b8:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    37ba:	20000593          	li	a1,512
    37be:	00004517          	auipc	a0,0x4
    37c2:	f0a50513          	addi	a0,a0,-246 # 76c8 <malloc+0x1d54>
    37c6:	00002097          	auipc	ra,0x2
    37ca:	db6080e7          	jalr	-586(ra) # 557c <open>
  if(fd < 0){
    37ce:	0e054d63          	bltz	a0,38c8 <dirfile+0x11c>
  close(fd);
    37d2:	00002097          	auipc	ra,0x2
    37d6:	d92080e7          	jalr	-622(ra) # 5564 <close>
  if(chdir("dirfile") == 0){
    37da:	00004517          	auipc	a0,0x4
    37de:	eee50513          	addi	a0,a0,-274 # 76c8 <malloc+0x1d54>
    37e2:	00002097          	auipc	ra,0x2
    37e6:	dca080e7          	jalr	-566(ra) # 55ac <chdir>
    37ea:	cd6d                	beqz	a0,38e4 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    37ec:	4581                	li	a1,0
    37ee:	00004517          	auipc	a0,0x4
    37f2:	f2250513          	addi	a0,a0,-222 # 7710 <malloc+0x1d9c>
    37f6:	00002097          	auipc	ra,0x2
    37fa:	d86080e7          	jalr	-634(ra) # 557c <open>
  if(fd >= 0){
    37fe:	10055163          	bgez	a0,3900 <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    3802:	20000593          	li	a1,512
    3806:	00004517          	auipc	a0,0x4
    380a:	f0a50513          	addi	a0,a0,-246 # 7710 <malloc+0x1d9c>
    380e:	00002097          	auipc	ra,0x2
    3812:	d6e080e7          	jalr	-658(ra) # 557c <open>
  if(fd >= 0){
    3816:	10055363          	bgez	a0,391c <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    381a:	00004517          	auipc	a0,0x4
    381e:	ef650513          	addi	a0,a0,-266 # 7710 <malloc+0x1d9c>
    3822:	00002097          	auipc	ra,0x2
    3826:	d82080e7          	jalr	-638(ra) # 55a4 <mkdir>
    382a:	10050763          	beqz	a0,3938 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    382e:	00004517          	auipc	a0,0x4
    3832:	ee250513          	addi	a0,a0,-286 # 7710 <malloc+0x1d9c>
    3836:	00002097          	auipc	ra,0x2
    383a:	d56080e7          	jalr	-682(ra) # 558c <unlink>
    383e:	10050b63          	beqz	a0,3954 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    3842:	00004597          	auipc	a1,0x4
    3846:	ece58593          	addi	a1,a1,-306 # 7710 <malloc+0x1d9c>
    384a:	00002517          	auipc	a0,0x2
    384e:	7a650513          	addi	a0,a0,1958 # 5ff0 <malloc+0x67c>
    3852:	00002097          	auipc	ra,0x2
    3856:	d4a080e7          	jalr	-694(ra) # 559c <link>
    385a:	10050b63          	beqz	a0,3970 <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    385e:	00004517          	auipc	a0,0x4
    3862:	e6a50513          	addi	a0,a0,-406 # 76c8 <malloc+0x1d54>
    3866:	00002097          	auipc	ra,0x2
    386a:	d26080e7          	jalr	-730(ra) # 558c <unlink>
    386e:	10051f63          	bnez	a0,398c <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    3872:	4589                	li	a1,2
    3874:	00003517          	auipc	a0,0x3
    3878:	c8c50513          	addi	a0,a0,-884 # 6500 <malloc+0xb8c>
    387c:	00002097          	auipc	ra,0x2
    3880:	d00080e7          	jalr	-768(ra) # 557c <open>
  if(fd >= 0){
    3884:	12055263          	bgez	a0,39a8 <dirfile+0x1fc>
  fd = open(".", 0);
    3888:	4581                	li	a1,0
    388a:	00003517          	auipc	a0,0x3
    388e:	c7650513          	addi	a0,a0,-906 # 6500 <malloc+0xb8c>
    3892:	00002097          	auipc	ra,0x2
    3896:	cea080e7          	jalr	-790(ra) # 557c <open>
    389a:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    389c:	4605                	li	a2,1
    389e:	00002597          	auipc	a1,0x2
    38a2:	61a58593          	addi	a1,a1,1562 # 5eb8 <malloc+0x544>
    38a6:	00002097          	auipc	ra,0x2
    38aa:	cb6080e7          	jalr	-842(ra) # 555c <write>
    38ae:	10a04b63          	bgtz	a0,39c4 <dirfile+0x218>
  close(fd);
    38b2:	8526                	mv	a0,s1
    38b4:	00002097          	auipc	ra,0x2
    38b8:	cb0080e7          	jalr	-848(ra) # 5564 <close>
}
    38bc:	60e2                	ld	ra,24(sp)
    38be:	6442                	ld	s0,16(sp)
    38c0:	64a2                	ld	s1,8(sp)
    38c2:	6902                	ld	s2,0(sp)
    38c4:	6105                	addi	sp,sp,32
    38c6:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    38c8:	85ca                	mv	a1,s2
    38ca:	00004517          	auipc	a0,0x4
    38ce:	e0650513          	addi	a0,a0,-506 # 76d0 <malloc+0x1d5c>
    38d2:	00002097          	auipc	ra,0x2
    38d6:	fe2080e7          	jalr	-30(ra) # 58b4 <printf>
    exit(1);
    38da:	4505                	li	a0,1
    38dc:	00002097          	auipc	ra,0x2
    38e0:	c60080e7          	jalr	-928(ra) # 553c <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    38e4:	85ca                	mv	a1,s2
    38e6:	00004517          	auipc	a0,0x4
    38ea:	e0a50513          	addi	a0,a0,-502 # 76f0 <malloc+0x1d7c>
    38ee:	00002097          	auipc	ra,0x2
    38f2:	fc6080e7          	jalr	-58(ra) # 58b4 <printf>
    exit(1);
    38f6:	4505                	li	a0,1
    38f8:	00002097          	auipc	ra,0x2
    38fc:	c44080e7          	jalr	-956(ra) # 553c <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3900:	85ca                	mv	a1,s2
    3902:	00004517          	auipc	a0,0x4
    3906:	e1e50513          	addi	a0,a0,-482 # 7720 <malloc+0x1dac>
    390a:	00002097          	auipc	ra,0x2
    390e:	faa080e7          	jalr	-86(ra) # 58b4 <printf>
    exit(1);
    3912:	4505                	li	a0,1
    3914:	00002097          	auipc	ra,0x2
    3918:	c28080e7          	jalr	-984(ra) # 553c <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    391c:	85ca                	mv	a1,s2
    391e:	00004517          	auipc	a0,0x4
    3922:	e0250513          	addi	a0,a0,-510 # 7720 <malloc+0x1dac>
    3926:	00002097          	auipc	ra,0x2
    392a:	f8e080e7          	jalr	-114(ra) # 58b4 <printf>
    exit(1);
    392e:	4505                	li	a0,1
    3930:	00002097          	auipc	ra,0x2
    3934:	c0c080e7          	jalr	-1012(ra) # 553c <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3938:	85ca                	mv	a1,s2
    393a:	00004517          	auipc	a0,0x4
    393e:	e0e50513          	addi	a0,a0,-498 # 7748 <malloc+0x1dd4>
    3942:	00002097          	auipc	ra,0x2
    3946:	f72080e7          	jalr	-142(ra) # 58b4 <printf>
    exit(1);
    394a:	4505                	li	a0,1
    394c:	00002097          	auipc	ra,0x2
    3950:	bf0080e7          	jalr	-1040(ra) # 553c <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3954:	85ca                	mv	a1,s2
    3956:	00004517          	auipc	a0,0x4
    395a:	e1a50513          	addi	a0,a0,-486 # 7770 <malloc+0x1dfc>
    395e:	00002097          	auipc	ra,0x2
    3962:	f56080e7          	jalr	-170(ra) # 58b4 <printf>
    exit(1);
    3966:	4505                	li	a0,1
    3968:	00002097          	auipc	ra,0x2
    396c:	bd4080e7          	jalr	-1068(ra) # 553c <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3970:	85ca                	mv	a1,s2
    3972:	00004517          	auipc	a0,0x4
    3976:	e2650513          	addi	a0,a0,-474 # 7798 <malloc+0x1e24>
    397a:	00002097          	auipc	ra,0x2
    397e:	f3a080e7          	jalr	-198(ra) # 58b4 <printf>
    exit(1);
    3982:	4505                	li	a0,1
    3984:	00002097          	auipc	ra,0x2
    3988:	bb8080e7          	jalr	-1096(ra) # 553c <exit>
    printf("%s: unlink dirfile failed!\n", s);
    398c:	85ca                	mv	a1,s2
    398e:	00004517          	auipc	a0,0x4
    3992:	e3250513          	addi	a0,a0,-462 # 77c0 <malloc+0x1e4c>
    3996:	00002097          	auipc	ra,0x2
    399a:	f1e080e7          	jalr	-226(ra) # 58b4 <printf>
    exit(1);
    399e:	4505                	li	a0,1
    39a0:	00002097          	auipc	ra,0x2
    39a4:	b9c080e7          	jalr	-1124(ra) # 553c <exit>
    printf("%s: open . for writing succeeded!\n", s);
    39a8:	85ca                	mv	a1,s2
    39aa:	00004517          	auipc	a0,0x4
    39ae:	e3650513          	addi	a0,a0,-458 # 77e0 <malloc+0x1e6c>
    39b2:	00002097          	auipc	ra,0x2
    39b6:	f02080e7          	jalr	-254(ra) # 58b4 <printf>
    exit(1);
    39ba:	4505                	li	a0,1
    39bc:	00002097          	auipc	ra,0x2
    39c0:	b80080e7          	jalr	-1152(ra) # 553c <exit>
    printf("%s: write . succeeded!\n", s);
    39c4:	85ca                	mv	a1,s2
    39c6:	00004517          	auipc	a0,0x4
    39ca:	e4250513          	addi	a0,a0,-446 # 7808 <malloc+0x1e94>
    39ce:	00002097          	auipc	ra,0x2
    39d2:	ee6080e7          	jalr	-282(ra) # 58b4 <printf>
    exit(1);
    39d6:	4505                	li	a0,1
    39d8:	00002097          	auipc	ra,0x2
    39dc:	b64080e7          	jalr	-1180(ra) # 553c <exit>

00000000000039e0 <iref>:
{
    39e0:	7139                	addi	sp,sp,-64
    39e2:	fc06                	sd	ra,56(sp)
    39e4:	f822                	sd	s0,48(sp)
    39e6:	f426                	sd	s1,40(sp)
    39e8:	f04a                	sd	s2,32(sp)
    39ea:	ec4e                	sd	s3,24(sp)
    39ec:	e852                	sd	s4,16(sp)
    39ee:	e456                	sd	s5,8(sp)
    39f0:	e05a                	sd	s6,0(sp)
    39f2:	0080                	addi	s0,sp,64
    39f4:	8b2a                	mv	s6,a0
    39f6:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    39fa:	00004a17          	auipc	s4,0x4
    39fe:	e26a0a13          	addi	s4,s4,-474 # 7820 <malloc+0x1eac>
    mkdir("");
    3a02:	00004497          	auipc	s1,0x4
    3a06:	91e48493          	addi	s1,s1,-1762 # 7320 <malloc+0x19ac>
    link("README", "");
    3a0a:	00002a97          	auipc	s5,0x2
    3a0e:	5e6a8a93          	addi	s5,s5,1510 # 5ff0 <malloc+0x67c>
    fd = open("xx", O_CREATE);
    3a12:	00004997          	auipc	s3,0x4
    3a16:	d0698993          	addi	s3,s3,-762 # 7718 <malloc+0x1da4>
    3a1a:	a891                	j	3a6e <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3a1c:	85da                	mv	a1,s6
    3a1e:	00004517          	auipc	a0,0x4
    3a22:	e0a50513          	addi	a0,a0,-502 # 7828 <malloc+0x1eb4>
    3a26:	00002097          	auipc	ra,0x2
    3a2a:	e8e080e7          	jalr	-370(ra) # 58b4 <printf>
      exit(1);
    3a2e:	4505                	li	a0,1
    3a30:	00002097          	auipc	ra,0x2
    3a34:	b0c080e7          	jalr	-1268(ra) # 553c <exit>
      printf("%s: chdir irefd failed\n", s);
    3a38:	85da                	mv	a1,s6
    3a3a:	00004517          	auipc	a0,0x4
    3a3e:	e0650513          	addi	a0,a0,-506 # 7840 <malloc+0x1ecc>
    3a42:	00002097          	auipc	ra,0x2
    3a46:	e72080e7          	jalr	-398(ra) # 58b4 <printf>
      exit(1);
    3a4a:	4505                	li	a0,1
    3a4c:	00002097          	auipc	ra,0x2
    3a50:	af0080e7          	jalr	-1296(ra) # 553c <exit>
      close(fd);
    3a54:	00002097          	auipc	ra,0x2
    3a58:	b10080e7          	jalr	-1264(ra) # 5564 <close>
    3a5c:	a889                	j	3aae <iref+0xce>
    unlink("xx");
    3a5e:	854e                	mv	a0,s3
    3a60:	00002097          	auipc	ra,0x2
    3a64:	b2c080e7          	jalr	-1236(ra) # 558c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3a68:	397d                	addiw	s2,s2,-1
    3a6a:	06090063          	beqz	s2,3aca <iref+0xea>
    if(mkdir("irefd") != 0){
    3a6e:	8552                	mv	a0,s4
    3a70:	00002097          	auipc	ra,0x2
    3a74:	b34080e7          	jalr	-1228(ra) # 55a4 <mkdir>
    3a78:	f155                	bnez	a0,3a1c <iref+0x3c>
    if(chdir("irefd") != 0){
    3a7a:	8552                	mv	a0,s4
    3a7c:	00002097          	auipc	ra,0x2
    3a80:	b30080e7          	jalr	-1232(ra) # 55ac <chdir>
    3a84:	f955                	bnez	a0,3a38 <iref+0x58>
    mkdir("");
    3a86:	8526                	mv	a0,s1
    3a88:	00002097          	auipc	ra,0x2
    3a8c:	b1c080e7          	jalr	-1252(ra) # 55a4 <mkdir>
    link("README", "");
    3a90:	85a6                	mv	a1,s1
    3a92:	8556                	mv	a0,s5
    3a94:	00002097          	auipc	ra,0x2
    3a98:	b08080e7          	jalr	-1272(ra) # 559c <link>
    fd = open("", O_CREATE);
    3a9c:	20000593          	li	a1,512
    3aa0:	8526                	mv	a0,s1
    3aa2:	00002097          	auipc	ra,0x2
    3aa6:	ada080e7          	jalr	-1318(ra) # 557c <open>
    if(fd >= 0)
    3aaa:	fa0555e3          	bgez	a0,3a54 <iref+0x74>
    fd = open("xx", O_CREATE);
    3aae:	20000593          	li	a1,512
    3ab2:	854e                	mv	a0,s3
    3ab4:	00002097          	auipc	ra,0x2
    3ab8:	ac8080e7          	jalr	-1336(ra) # 557c <open>
    if(fd >= 0)
    3abc:	fa0541e3          	bltz	a0,3a5e <iref+0x7e>
      close(fd);
    3ac0:	00002097          	auipc	ra,0x2
    3ac4:	aa4080e7          	jalr	-1372(ra) # 5564 <close>
    3ac8:	bf59                	j	3a5e <iref+0x7e>
    3aca:	03300493          	li	s1,51
    chdir("..");
    3ace:	00004997          	auipc	s3,0x4
    3ad2:	b6a98993          	addi	s3,s3,-1174 # 7638 <malloc+0x1cc4>
    unlink("irefd");
    3ad6:	00004917          	auipc	s2,0x4
    3ada:	d4a90913          	addi	s2,s2,-694 # 7820 <malloc+0x1eac>
    chdir("..");
    3ade:	854e                	mv	a0,s3
    3ae0:	00002097          	auipc	ra,0x2
    3ae4:	acc080e7          	jalr	-1332(ra) # 55ac <chdir>
    unlink("irefd");
    3ae8:	854a                	mv	a0,s2
    3aea:	00002097          	auipc	ra,0x2
    3aee:	aa2080e7          	jalr	-1374(ra) # 558c <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3af2:	34fd                	addiw	s1,s1,-1
    3af4:	f4ed                	bnez	s1,3ade <iref+0xfe>
  chdir("/");
    3af6:	00003517          	auipc	a0,0x3
    3afa:	54a50513          	addi	a0,a0,1354 # 7040 <malloc+0x16cc>
    3afe:	00002097          	auipc	ra,0x2
    3b02:	aae080e7          	jalr	-1362(ra) # 55ac <chdir>
}
    3b06:	70e2                	ld	ra,56(sp)
    3b08:	7442                	ld	s0,48(sp)
    3b0a:	74a2                	ld	s1,40(sp)
    3b0c:	7902                	ld	s2,32(sp)
    3b0e:	69e2                	ld	s3,24(sp)
    3b10:	6a42                	ld	s4,16(sp)
    3b12:	6aa2                	ld	s5,8(sp)
    3b14:	6b02                	ld	s6,0(sp)
    3b16:	6121                	addi	sp,sp,64
    3b18:	8082                	ret

0000000000003b1a <openiputtest>:
{
    3b1a:	7179                	addi	sp,sp,-48
    3b1c:	f406                	sd	ra,40(sp)
    3b1e:	f022                	sd	s0,32(sp)
    3b20:	ec26                	sd	s1,24(sp)
    3b22:	1800                	addi	s0,sp,48
    3b24:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3b26:	00004517          	auipc	a0,0x4
    3b2a:	d3250513          	addi	a0,a0,-718 # 7858 <malloc+0x1ee4>
    3b2e:	00002097          	auipc	ra,0x2
    3b32:	a76080e7          	jalr	-1418(ra) # 55a4 <mkdir>
    3b36:	04054263          	bltz	a0,3b7a <openiputtest+0x60>
  pid = fork();
    3b3a:	00002097          	auipc	ra,0x2
    3b3e:	9fa080e7          	jalr	-1542(ra) # 5534 <fork>
  if(pid < 0){
    3b42:	04054a63          	bltz	a0,3b96 <openiputtest+0x7c>
  if(pid == 0){
    3b46:	e93d                	bnez	a0,3bbc <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3b48:	4589                	li	a1,2
    3b4a:	00004517          	auipc	a0,0x4
    3b4e:	d0e50513          	addi	a0,a0,-754 # 7858 <malloc+0x1ee4>
    3b52:	00002097          	auipc	ra,0x2
    3b56:	a2a080e7          	jalr	-1494(ra) # 557c <open>
    if(fd >= 0){
    3b5a:	04054c63          	bltz	a0,3bb2 <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3b5e:	85a6                	mv	a1,s1
    3b60:	00004517          	auipc	a0,0x4
    3b64:	d1850513          	addi	a0,a0,-744 # 7878 <malloc+0x1f04>
    3b68:	00002097          	auipc	ra,0x2
    3b6c:	d4c080e7          	jalr	-692(ra) # 58b4 <printf>
      exit(1);
    3b70:	4505                	li	a0,1
    3b72:	00002097          	auipc	ra,0x2
    3b76:	9ca080e7          	jalr	-1590(ra) # 553c <exit>
    printf("%s: mkdir oidir failed\n", s);
    3b7a:	85a6                	mv	a1,s1
    3b7c:	00004517          	auipc	a0,0x4
    3b80:	ce450513          	addi	a0,a0,-796 # 7860 <malloc+0x1eec>
    3b84:	00002097          	auipc	ra,0x2
    3b88:	d30080e7          	jalr	-720(ra) # 58b4 <printf>
    exit(1);
    3b8c:	4505                	li	a0,1
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	9ae080e7          	jalr	-1618(ra) # 553c <exit>
    printf("%s: fork failed\n", s);
    3b96:	85a6                	mv	a1,s1
    3b98:	00003517          	auipc	a0,0x3
    3b9c:	b0850513          	addi	a0,a0,-1272 # 66a0 <malloc+0xd2c>
    3ba0:	00002097          	auipc	ra,0x2
    3ba4:	d14080e7          	jalr	-748(ra) # 58b4 <printf>
    exit(1);
    3ba8:	4505                	li	a0,1
    3baa:	00002097          	auipc	ra,0x2
    3bae:	992080e7          	jalr	-1646(ra) # 553c <exit>
    exit(0);
    3bb2:	4501                	li	a0,0
    3bb4:	00002097          	auipc	ra,0x2
    3bb8:	988080e7          	jalr	-1656(ra) # 553c <exit>
  sleep(1);
    3bbc:	4505                	li	a0,1
    3bbe:	00002097          	auipc	ra,0x2
    3bc2:	a0e080e7          	jalr	-1522(ra) # 55cc <sleep>
  if(unlink("oidir") != 0){
    3bc6:	00004517          	auipc	a0,0x4
    3bca:	c9250513          	addi	a0,a0,-878 # 7858 <malloc+0x1ee4>
    3bce:	00002097          	auipc	ra,0x2
    3bd2:	9be080e7          	jalr	-1602(ra) # 558c <unlink>
    3bd6:	cd19                	beqz	a0,3bf4 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3bd8:	85a6                	mv	a1,s1
    3bda:	00003517          	auipc	a0,0x3
    3bde:	cb650513          	addi	a0,a0,-842 # 6890 <malloc+0xf1c>
    3be2:	00002097          	auipc	ra,0x2
    3be6:	cd2080e7          	jalr	-814(ra) # 58b4 <printf>
    exit(1);
    3bea:	4505                	li	a0,1
    3bec:	00002097          	auipc	ra,0x2
    3bf0:	950080e7          	jalr	-1712(ra) # 553c <exit>
  wait(&xstatus);
    3bf4:	fdc40513          	addi	a0,s0,-36
    3bf8:	00002097          	auipc	ra,0x2
    3bfc:	94c080e7          	jalr	-1716(ra) # 5544 <wait>
  exit(xstatus);
    3c00:	fdc42503          	lw	a0,-36(s0)
    3c04:	00002097          	auipc	ra,0x2
    3c08:	938080e7          	jalr	-1736(ra) # 553c <exit>

0000000000003c0c <forkforkfork>:
{
    3c0c:	1101                	addi	sp,sp,-32
    3c0e:	ec06                	sd	ra,24(sp)
    3c10:	e822                	sd	s0,16(sp)
    3c12:	e426                	sd	s1,8(sp)
    3c14:	1000                	addi	s0,sp,32
    3c16:	84aa                	mv	s1,a0
  unlink("stopforking");
    3c18:	00004517          	auipc	a0,0x4
    3c1c:	c8850513          	addi	a0,a0,-888 # 78a0 <malloc+0x1f2c>
    3c20:	00002097          	auipc	ra,0x2
    3c24:	96c080e7          	jalr	-1684(ra) # 558c <unlink>
  int pid = fork();
    3c28:	00002097          	auipc	ra,0x2
    3c2c:	90c080e7          	jalr	-1780(ra) # 5534 <fork>
  if(pid < 0){
    3c30:	04054563          	bltz	a0,3c7a <forkforkfork+0x6e>
  if(pid == 0){
    3c34:	c12d                	beqz	a0,3c96 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3c36:	4551                	li	a0,20
    3c38:	00002097          	auipc	ra,0x2
    3c3c:	994080e7          	jalr	-1644(ra) # 55cc <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3c40:	20200593          	li	a1,514
    3c44:	00004517          	auipc	a0,0x4
    3c48:	c5c50513          	addi	a0,a0,-932 # 78a0 <malloc+0x1f2c>
    3c4c:	00002097          	auipc	ra,0x2
    3c50:	930080e7          	jalr	-1744(ra) # 557c <open>
    3c54:	00002097          	auipc	ra,0x2
    3c58:	910080e7          	jalr	-1776(ra) # 5564 <close>
  wait(0);
    3c5c:	4501                	li	a0,0
    3c5e:	00002097          	auipc	ra,0x2
    3c62:	8e6080e7          	jalr	-1818(ra) # 5544 <wait>
  sleep(10); // one second
    3c66:	4529                	li	a0,10
    3c68:	00002097          	auipc	ra,0x2
    3c6c:	964080e7          	jalr	-1692(ra) # 55cc <sleep>
}
    3c70:	60e2                	ld	ra,24(sp)
    3c72:	6442                	ld	s0,16(sp)
    3c74:	64a2                	ld	s1,8(sp)
    3c76:	6105                	addi	sp,sp,32
    3c78:	8082                	ret
    printf("%s: fork failed", s);
    3c7a:	85a6                	mv	a1,s1
    3c7c:	00003517          	auipc	a0,0x3
    3c80:	be450513          	addi	a0,a0,-1052 # 6860 <malloc+0xeec>
    3c84:	00002097          	auipc	ra,0x2
    3c88:	c30080e7          	jalr	-976(ra) # 58b4 <printf>
    exit(1);
    3c8c:	4505                	li	a0,1
    3c8e:	00002097          	auipc	ra,0x2
    3c92:	8ae080e7          	jalr	-1874(ra) # 553c <exit>
      int fd = open("stopforking", 0);
    3c96:	00004497          	auipc	s1,0x4
    3c9a:	c0a48493          	addi	s1,s1,-1014 # 78a0 <malloc+0x1f2c>
    3c9e:	4581                	li	a1,0
    3ca0:	8526                	mv	a0,s1
    3ca2:	00002097          	auipc	ra,0x2
    3ca6:	8da080e7          	jalr	-1830(ra) # 557c <open>
      if(fd >= 0){
    3caa:	02055463          	bgez	a0,3cd2 <forkforkfork+0xc6>
      if(fork() < 0){
    3cae:	00002097          	auipc	ra,0x2
    3cb2:	886080e7          	jalr	-1914(ra) # 5534 <fork>
    3cb6:	fe0554e3          	bgez	a0,3c9e <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3cba:	20200593          	li	a1,514
    3cbe:	8526                	mv	a0,s1
    3cc0:	00002097          	auipc	ra,0x2
    3cc4:	8bc080e7          	jalr	-1860(ra) # 557c <open>
    3cc8:	00002097          	auipc	ra,0x2
    3ccc:	89c080e7          	jalr	-1892(ra) # 5564 <close>
    3cd0:	b7f9                	j	3c9e <forkforkfork+0x92>
        exit(0);
    3cd2:	4501                	li	a0,0
    3cd4:	00002097          	auipc	ra,0x2
    3cd8:	868080e7          	jalr	-1944(ra) # 553c <exit>

0000000000003cdc <preempt>:
{
    3cdc:	7139                	addi	sp,sp,-64
    3cde:	fc06                	sd	ra,56(sp)
    3ce0:	f822                	sd	s0,48(sp)
    3ce2:	f426                	sd	s1,40(sp)
    3ce4:	f04a                	sd	s2,32(sp)
    3ce6:	ec4e                	sd	s3,24(sp)
    3ce8:	e852                	sd	s4,16(sp)
    3cea:	0080                	addi	s0,sp,64
    3cec:	8a2a                	mv	s4,a0
  pid1 = fork();
    3cee:	00002097          	auipc	ra,0x2
    3cf2:	846080e7          	jalr	-1978(ra) # 5534 <fork>
  if(pid1 < 0) {
    3cf6:	00054563          	bltz	a0,3d00 <preempt+0x24>
    3cfa:	89aa                	mv	s3,a0
  if(pid1 == 0)
    3cfc:	ed19                	bnez	a0,3d1a <preempt+0x3e>
    for(;;)
    3cfe:	a001                	j	3cfe <preempt+0x22>
    printf("%s: fork failed");
    3d00:	00003517          	auipc	a0,0x3
    3d04:	b6050513          	addi	a0,a0,-1184 # 6860 <malloc+0xeec>
    3d08:	00002097          	auipc	ra,0x2
    3d0c:	bac080e7          	jalr	-1108(ra) # 58b4 <printf>
    exit(1);
    3d10:	4505                	li	a0,1
    3d12:	00002097          	auipc	ra,0x2
    3d16:	82a080e7          	jalr	-2006(ra) # 553c <exit>
  pid2 = fork();
    3d1a:	00002097          	auipc	ra,0x2
    3d1e:	81a080e7          	jalr	-2022(ra) # 5534 <fork>
    3d22:	892a                	mv	s2,a0
  if(pid2 < 0) {
    3d24:	00054463          	bltz	a0,3d2c <preempt+0x50>
  if(pid2 == 0)
    3d28:	e105                	bnez	a0,3d48 <preempt+0x6c>
    for(;;)
    3d2a:	a001                	j	3d2a <preempt+0x4e>
    printf("%s: fork failed\n", s);
    3d2c:	85d2                	mv	a1,s4
    3d2e:	00003517          	auipc	a0,0x3
    3d32:	97250513          	addi	a0,a0,-1678 # 66a0 <malloc+0xd2c>
    3d36:	00002097          	auipc	ra,0x2
    3d3a:	b7e080e7          	jalr	-1154(ra) # 58b4 <printf>
    exit(1);
    3d3e:	4505                	li	a0,1
    3d40:	00001097          	auipc	ra,0x1
    3d44:	7fc080e7          	jalr	2044(ra) # 553c <exit>
  pipe(pfds);
    3d48:	fc840513          	addi	a0,s0,-56
    3d4c:	00002097          	auipc	ra,0x2
    3d50:	800080e7          	jalr	-2048(ra) # 554c <pipe>
  pid3 = fork();
    3d54:	00001097          	auipc	ra,0x1
    3d58:	7e0080e7          	jalr	2016(ra) # 5534 <fork>
    3d5c:	84aa                	mv	s1,a0
  if(pid3 < 0) {
    3d5e:	02054e63          	bltz	a0,3d9a <preempt+0xbe>
  if(pid3 == 0){
    3d62:	e13d                	bnez	a0,3dc8 <preempt+0xec>
    close(pfds[0]);
    3d64:	fc842503          	lw	a0,-56(s0)
    3d68:	00001097          	auipc	ra,0x1
    3d6c:	7fc080e7          	jalr	2044(ra) # 5564 <close>
    if(write(pfds[1], "x", 1) != 1)
    3d70:	4605                	li	a2,1
    3d72:	00002597          	auipc	a1,0x2
    3d76:	14658593          	addi	a1,a1,326 # 5eb8 <malloc+0x544>
    3d7a:	fcc42503          	lw	a0,-52(s0)
    3d7e:	00001097          	auipc	ra,0x1
    3d82:	7de080e7          	jalr	2014(ra) # 555c <write>
    3d86:	4785                	li	a5,1
    3d88:	02f51763          	bne	a0,a5,3db6 <preempt+0xda>
    close(pfds[1]);
    3d8c:	fcc42503          	lw	a0,-52(s0)
    3d90:	00001097          	auipc	ra,0x1
    3d94:	7d4080e7          	jalr	2004(ra) # 5564 <close>
    for(;;)
    3d98:	a001                	j	3d98 <preempt+0xbc>
     printf("%s: fork failed\n", s);
    3d9a:	85d2                	mv	a1,s4
    3d9c:	00003517          	auipc	a0,0x3
    3da0:	90450513          	addi	a0,a0,-1788 # 66a0 <malloc+0xd2c>
    3da4:	00002097          	auipc	ra,0x2
    3da8:	b10080e7          	jalr	-1264(ra) # 58b4 <printf>
     exit(1);
    3dac:	4505                	li	a0,1
    3dae:	00001097          	auipc	ra,0x1
    3db2:	78e080e7          	jalr	1934(ra) # 553c <exit>
      printf("%s: preempt write error");
    3db6:	00004517          	auipc	a0,0x4
    3dba:	afa50513          	addi	a0,a0,-1286 # 78b0 <malloc+0x1f3c>
    3dbe:	00002097          	auipc	ra,0x2
    3dc2:	af6080e7          	jalr	-1290(ra) # 58b4 <printf>
    3dc6:	b7d9                	j	3d8c <preempt+0xb0>
  close(pfds[1]);
    3dc8:	fcc42503          	lw	a0,-52(s0)
    3dcc:	00001097          	auipc	ra,0x1
    3dd0:	798080e7          	jalr	1944(ra) # 5564 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3dd4:	660d                	lui	a2,0x3
    3dd6:	00008597          	auipc	a1,0x8
    3dda:	bea58593          	addi	a1,a1,-1046 # b9c0 <buf>
    3dde:	fc842503          	lw	a0,-56(s0)
    3de2:	00001097          	auipc	ra,0x1
    3de6:	772080e7          	jalr	1906(ra) # 5554 <read>
    3dea:	4785                	li	a5,1
    3dec:	02f50263          	beq	a0,a5,3e10 <preempt+0x134>
    printf("%s: preempt read error");
    3df0:	00004517          	auipc	a0,0x4
    3df4:	ad850513          	addi	a0,a0,-1320 # 78c8 <malloc+0x1f54>
    3df8:	00002097          	auipc	ra,0x2
    3dfc:	abc080e7          	jalr	-1348(ra) # 58b4 <printf>
}
    3e00:	70e2                	ld	ra,56(sp)
    3e02:	7442                	ld	s0,48(sp)
    3e04:	74a2                	ld	s1,40(sp)
    3e06:	7902                	ld	s2,32(sp)
    3e08:	69e2                	ld	s3,24(sp)
    3e0a:	6a42                	ld	s4,16(sp)
    3e0c:	6121                	addi	sp,sp,64
    3e0e:	8082                	ret
  close(pfds[0]);
    3e10:	fc842503          	lw	a0,-56(s0)
    3e14:	00001097          	auipc	ra,0x1
    3e18:	750080e7          	jalr	1872(ra) # 5564 <close>
  printf("kill... ");
    3e1c:	00004517          	auipc	a0,0x4
    3e20:	ac450513          	addi	a0,a0,-1340 # 78e0 <malloc+0x1f6c>
    3e24:	00002097          	auipc	ra,0x2
    3e28:	a90080e7          	jalr	-1392(ra) # 58b4 <printf>
  kill(pid1);
    3e2c:	854e                	mv	a0,s3
    3e2e:	00001097          	auipc	ra,0x1
    3e32:	73e080e7          	jalr	1854(ra) # 556c <kill>
  kill(pid2);
    3e36:	854a                	mv	a0,s2
    3e38:	00001097          	auipc	ra,0x1
    3e3c:	734080e7          	jalr	1844(ra) # 556c <kill>
  kill(pid3);
    3e40:	8526                	mv	a0,s1
    3e42:	00001097          	auipc	ra,0x1
    3e46:	72a080e7          	jalr	1834(ra) # 556c <kill>
  printf("wait... ");
    3e4a:	00004517          	auipc	a0,0x4
    3e4e:	aa650513          	addi	a0,a0,-1370 # 78f0 <malloc+0x1f7c>
    3e52:	00002097          	auipc	ra,0x2
    3e56:	a62080e7          	jalr	-1438(ra) # 58b4 <printf>
  wait(0);
    3e5a:	4501                	li	a0,0
    3e5c:	00001097          	auipc	ra,0x1
    3e60:	6e8080e7          	jalr	1768(ra) # 5544 <wait>
  wait(0);
    3e64:	4501                	li	a0,0
    3e66:	00001097          	auipc	ra,0x1
    3e6a:	6de080e7          	jalr	1758(ra) # 5544 <wait>
  wait(0);
    3e6e:	4501                	li	a0,0
    3e70:	00001097          	auipc	ra,0x1
    3e74:	6d4080e7          	jalr	1748(ra) # 5544 <wait>
    3e78:	b761                	j	3e00 <preempt+0x124>

0000000000003e7a <sbrkfail>:
{
    3e7a:	7119                	addi	sp,sp,-128
    3e7c:	fc86                	sd	ra,120(sp)
    3e7e:	f8a2                	sd	s0,112(sp)
    3e80:	f4a6                	sd	s1,104(sp)
    3e82:	f0ca                	sd	s2,96(sp)
    3e84:	ecce                	sd	s3,88(sp)
    3e86:	e8d2                	sd	s4,80(sp)
    3e88:	e4d6                	sd	s5,72(sp)
    3e8a:	0100                	addi	s0,sp,128
    3e8c:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    3e8e:	fb040513          	addi	a0,s0,-80
    3e92:	00001097          	auipc	ra,0x1
    3e96:	6ba080e7          	jalr	1722(ra) # 554c <pipe>
    3e9a:	e901                	bnez	a0,3eaa <sbrkfail+0x30>
    3e9c:	f8040493          	addi	s1,s0,-128
    3ea0:	fa840993          	addi	s3,s0,-88
    3ea4:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3ea6:	5a7d                	li	s4,-1
    3ea8:	a085                	j	3f08 <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3eaa:	85d6                	mv	a1,s5
    3eac:	00003517          	auipc	a0,0x3
    3eb0:	8fc50513          	addi	a0,a0,-1796 # 67a8 <malloc+0xe34>
    3eb4:	00002097          	auipc	ra,0x2
    3eb8:	a00080e7          	jalr	-1536(ra) # 58b4 <printf>
    exit(1);
    3ebc:	4505                	li	a0,1
    3ebe:	00001097          	auipc	ra,0x1
    3ec2:	67e080e7          	jalr	1662(ra) # 553c <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3ec6:	00001097          	auipc	ra,0x1
    3eca:	6fe080e7          	jalr	1790(ra) # 55c4 <sbrk>
    3ece:	064007b7          	lui	a5,0x6400
    3ed2:	40a7853b          	subw	a0,a5,a0
    3ed6:	00001097          	auipc	ra,0x1
    3eda:	6ee080e7          	jalr	1774(ra) # 55c4 <sbrk>
      write(fds[1], "x", 1);
    3ede:	4605                	li	a2,1
    3ee0:	00002597          	auipc	a1,0x2
    3ee4:	fd858593          	addi	a1,a1,-40 # 5eb8 <malloc+0x544>
    3ee8:	fb442503          	lw	a0,-76(s0)
    3eec:	00001097          	auipc	ra,0x1
    3ef0:	670080e7          	jalr	1648(ra) # 555c <write>
      for(;;) sleep(1000);
    3ef4:	3e800513          	li	a0,1000
    3ef8:	00001097          	auipc	ra,0x1
    3efc:	6d4080e7          	jalr	1748(ra) # 55cc <sleep>
    3f00:	bfd5                	j	3ef4 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3f02:	0911                	addi	s2,s2,4
    3f04:	03390563          	beq	s2,s3,3f2e <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    3f08:	00001097          	auipc	ra,0x1
    3f0c:	62c080e7          	jalr	1580(ra) # 5534 <fork>
    3f10:	00a92023          	sw	a0,0(s2)
    3f14:	d94d                	beqz	a0,3ec6 <sbrkfail+0x4c>
    if(pids[i] != -1)
    3f16:	ff4506e3          	beq	a0,s4,3f02 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    3f1a:	4605                	li	a2,1
    3f1c:	faf40593          	addi	a1,s0,-81
    3f20:	fb042503          	lw	a0,-80(s0)
    3f24:	00001097          	auipc	ra,0x1
    3f28:	630080e7          	jalr	1584(ra) # 5554 <read>
    3f2c:	bfd9                	j	3f02 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    3f2e:	6505                	lui	a0,0x1
    3f30:	00001097          	auipc	ra,0x1
    3f34:	694080e7          	jalr	1684(ra) # 55c4 <sbrk>
    3f38:	892a                	mv	s2,a0
    if(pids[i] == -1)
    3f3a:	5a7d                	li	s4,-1
    3f3c:	a021                	j	3f44 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3f3e:	0491                	addi	s1,s1,4
    3f40:	01348f63          	beq	s1,s3,3f5e <sbrkfail+0xe4>
    if(pids[i] == -1)
    3f44:	4088                	lw	a0,0(s1)
    3f46:	ff450ce3          	beq	a0,s4,3f3e <sbrkfail+0xc4>
    kill(pids[i]);
    3f4a:	00001097          	auipc	ra,0x1
    3f4e:	622080e7          	jalr	1570(ra) # 556c <kill>
    wait(0);
    3f52:	4501                	li	a0,0
    3f54:	00001097          	auipc	ra,0x1
    3f58:	5f0080e7          	jalr	1520(ra) # 5544 <wait>
    3f5c:	b7cd                	j	3f3e <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    3f5e:	57fd                	li	a5,-1
    3f60:	04f90163          	beq	s2,a5,3fa2 <sbrkfail+0x128>
  pid = fork();
    3f64:	00001097          	auipc	ra,0x1
    3f68:	5d0080e7          	jalr	1488(ra) # 5534 <fork>
    3f6c:	84aa                	mv	s1,a0
  if(pid < 0){
    3f6e:	04054863          	bltz	a0,3fbe <sbrkfail+0x144>
  if(pid == 0){
    3f72:	c525                	beqz	a0,3fda <sbrkfail+0x160>
  wait(&xstatus);
    3f74:	fbc40513          	addi	a0,s0,-68
    3f78:	00001097          	auipc	ra,0x1
    3f7c:	5cc080e7          	jalr	1484(ra) # 5544 <wait>
  if(xstatus != -1 && xstatus != 2)
    3f80:	fbc42783          	lw	a5,-68(s0)
    3f84:	577d                	li	a4,-1
    3f86:	00e78563          	beq	a5,a4,3f90 <sbrkfail+0x116>
    3f8a:	4709                	li	a4,2
    3f8c:	08e79c63          	bne	a5,a4,4024 <sbrkfail+0x1aa>
}
    3f90:	70e6                	ld	ra,120(sp)
    3f92:	7446                	ld	s0,112(sp)
    3f94:	74a6                	ld	s1,104(sp)
    3f96:	7906                	ld	s2,96(sp)
    3f98:	69e6                	ld	s3,88(sp)
    3f9a:	6a46                	ld	s4,80(sp)
    3f9c:	6aa6                	ld	s5,72(sp)
    3f9e:	6109                	addi	sp,sp,128
    3fa0:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    3fa2:	85d6                	mv	a1,s5
    3fa4:	00004517          	auipc	a0,0x4
    3fa8:	95c50513          	addi	a0,a0,-1700 # 7900 <malloc+0x1f8c>
    3fac:	00002097          	auipc	ra,0x2
    3fb0:	908080e7          	jalr	-1784(ra) # 58b4 <printf>
    exit(1);
    3fb4:	4505                	li	a0,1
    3fb6:	00001097          	auipc	ra,0x1
    3fba:	586080e7          	jalr	1414(ra) # 553c <exit>
    printf("%s: fork failed\n", s);
    3fbe:	85d6                	mv	a1,s5
    3fc0:	00002517          	auipc	a0,0x2
    3fc4:	6e050513          	addi	a0,a0,1760 # 66a0 <malloc+0xd2c>
    3fc8:	00002097          	auipc	ra,0x2
    3fcc:	8ec080e7          	jalr	-1812(ra) # 58b4 <printf>
    exit(1);
    3fd0:	4505                	li	a0,1
    3fd2:	00001097          	auipc	ra,0x1
    3fd6:	56a080e7          	jalr	1386(ra) # 553c <exit>
    a = sbrk(0);
    3fda:	4501                	li	a0,0
    3fdc:	00001097          	auipc	ra,0x1
    3fe0:	5e8080e7          	jalr	1512(ra) # 55c4 <sbrk>
    3fe4:	892a                	mv	s2,a0
    sbrk(10*BIG);
    3fe6:	3e800537          	lui	a0,0x3e800
    3fea:	00001097          	auipc	ra,0x1
    3fee:	5da080e7          	jalr	1498(ra) # 55c4 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    3ff2:	874a                	mv	a4,s2
    3ff4:	3e8007b7          	lui	a5,0x3e800
    3ff8:	97ca                	add	a5,a5,s2
    3ffa:	6685                	lui	a3,0x1
      n += *(a+i);
    3ffc:	00074603          	lbu	a2,0(a4)
    4000:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    4002:	9736                	add	a4,a4,a3
    4004:	fee79ce3          	bne	a5,a4,3ffc <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", n);
    4008:	85a6                	mv	a1,s1
    400a:	00004517          	auipc	a0,0x4
    400e:	91650513          	addi	a0,a0,-1770 # 7920 <malloc+0x1fac>
    4012:	00002097          	auipc	ra,0x2
    4016:	8a2080e7          	jalr	-1886(ra) # 58b4 <printf>
    exit(1);
    401a:	4505                	li	a0,1
    401c:	00001097          	auipc	ra,0x1
    4020:	520080e7          	jalr	1312(ra) # 553c <exit>
    exit(1);
    4024:	4505                	li	a0,1
    4026:	00001097          	auipc	ra,0x1
    402a:	516080e7          	jalr	1302(ra) # 553c <exit>

000000000000402e <reparent>:
{
    402e:	7179                	addi	sp,sp,-48
    4030:	f406                	sd	ra,40(sp)
    4032:	f022                	sd	s0,32(sp)
    4034:	ec26                	sd	s1,24(sp)
    4036:	e84a                	sd	s2,16(sp)
    4038:	e44e                	sd	s3,8(sp)
    403a:	e052                	sd	s4,0(sp)
    403c:	1800                	addi	s0,sp,48
    403e:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4040:	00001097          	auipc	ra,0x1
    4044:	57c080e7          	jalr	1404(ra) # 55bc <getpid>
    4048:	8a2a                	mv	s4,a0
    404a:	0c800913          	li	s2,200
    int pid = fork();
    404e:	00001097          	auipc	ra,0x1
    4052:	4e6080e7          	jalr	1254(ra) # 5534 <fork>
    4056:	84aa                	mv	s1,a0
    if(pid < 0){
    4058:	02054263          	bltz	a0,407c <reparent+0x4e>
    if(pid){
    405c:	cd21                	beqz	a0,40b4 <reparent+0x86>
      if(wait(0) != pid){
    405e:	4501                	li	a0,0
    4060:	00001097          	auipc	ra,0x1
    4064:	4e4080e7          	jalr	1252(ra) # 5544 <wait>
    4068:	02951863          	bne	a0,s1,4098 <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    406c:	397d                	addiw	s2,s2,-1
    406e:	fe0910e3          	bnez	s2,404e <reparent+0x20>
  exit(0);
    4072:	4501                	li	a0,0
    4074:	00001097          	auipc	ra,0x1
    4078:	4c8080e7          	jalr	1224(ra) # 553c <exit>
      printf("%s: fork failed\n", s);
    407c:	85ce                	mv	a1,s3
    407e:	00002517          	auipc	a0,0x2
    4082:	62250513          	addi	a0,a0,1570 # 66a0 <malloc+0xd2c>
    4086:	00002097          	auipc	ra,0x2
    408a:	82e080e7          	jalr	-2002(ra) # 58b4 <printf>
      exit(1);
    408e:	4505                	li	a0,1
    4090:	00001097          	auipc	ra,0x1
    4094:	4ac080e7          	jalr	1196(ra) # 553c <exit>
        printf("%s: wait wrong pid\n", s);
    4098:	85ce                	mv	a1,s3
    409a:	00002517          	auipc	a0,0x2
    409e:	78e50513          	addi	a0,a0,1934 # 6828 <malloc+0xeb4>
    40a2:	00002097          	auipc	ra,0x2
    40a6:	812080e7          	jalr	-2030(ra) # 58b4 <printf>
        exit(1);
    40aa:	4505                	li	a0,1
    40ac:	00001097          	auipc	ra,0x1
    40b0:	490080e7          	jalr	1168(ra) # 553c <exit>
      int pid2 = fork();
    40b4:	00001097          	auipc	ra,0x1
    40b8:	480080e7          	jalr	1152(ra) # 5534 <fork>
      if(pid2 < 0){
    40bc:	00054763          	bltz	a0,40ca <reparent+0x9c>
      exit(0);
    40c0:	4501                	li	a0,0
    40c2:	00001097          	auipc	ra,0x1
    40c6:	47a080e7          	jalr	1146(ra) # 553c <exit>
        kill(master_pid);
    40ca:	8552                	mv	a0,s4
    40cc:	00001097          	auipc	ra,0x1
    40d0:	4a0080e7          	jalr	1184(ra) # 556c <kill>
        exit(1);
    40d4:	4505                	li	a0,1
    40d6:	00001097          	auipc	ra,0x1
    40da:	466080e7          	jalr	1126(ra) # 553c <exit>

00000000000040de <mem>:
{
    40de:	7139                	addi	sp,sp,-64
    40e0:	fc06                	sd	ra,56(sp)
    40e2:	f822                	sd	s0,48(sp)
    40e4:	f426                	sd	s1,40(sp)
    40e6:	f04a                	sd	s2,32(sp)
    40e8:	ec4e                	sd	s3,24(sp)
    40ea:	0080                	addi	s0,sp,64
    40ec:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    40ee:	00001097          	auipc	ra,0x1
    40f2:	446080e7          	jalr	1094(ra) # 5534 <fork>
    m1 = 0;
    40f6:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    40f8:	6909                	lui	s2,0x2
    40fa:	71190913          	addi	s2,s2,1809 # 2711 <sbrkmuch+0xef>
  if((pid = fork()) == 0){
    40fe:	e135                	bnez	a0,4162 <mem+0x84>
    while((m2 = malloc(10001)) != 0){
    4100:	854a                	mv	a0,s2
    4102:	00002097          	auipc	ra,0x2
    4106:	872080e7          	jalr	-1934(ra) # 5974 <malloc>
    410a:	c501                	beqz	a0,4112 <mem+0x34>
      *(char**)m2 = m1;
    410c:	e104                	sd	s1,0(a0)
      m1 = m2;
    410e:	84aa                	mv	s1,a0
    4110:	bfc5                	j	4100 <mem+0x22>
    while(m1){
    4112:	c899                	beqz	s1,4128 <mem+0x4a>
      m2 = *(char**)m1;
    4114:	0004b903          	ld	s2,0(s1)
      free(m1);
    4118:	8526                	mv	a0,s1
    411a:	00001097          	auipc	ra,0x1
    411e:	7d0080e7          	jalr	2000(ra) # 58ea <free>
      m1 = m2;
    4122:	84ca                	mv	s1,s2
    while(m1){
    4124:	fe0918e3          	bnez	s2,4114 <mem+0x36>
    m1 = malloc(1024*20);
    4128:	6515                	lui	a0,0x5
    412a:	00002097          	auipc	ra,0x2
    412e:	84a080e7          	jalr	-1974(ra) # 5974 <malloc>
    if(m1 == 0){
    4132:	c911                	beqz	a0,4146 <mem+0x68>
    free(m1);
    4134:	00001097          	auipc	ra,0x1
    4138:	7b6080e7          	jalr	1974(ra) # 58ea <free>
    exit(0);
    413c:	4501                	li	a0,0
    413e:	00001097          	auipc	ra,0x1
    4142:	3fe080e7          	jalr	1022(ra) # 553c <exit>
      printf("couldn't allocate mem?!!\n", s);
    4146:	85ce                	mv	a1,s3
    4148:	00004517          	auipc	a0,0x4
    414c:	80850513          	addi	a0,a0,-2040 # 7950 <malloc+0x1fdc>
    4150:	00001097          	auipc	ra,0x1
    4154:	764080e7          	jalr	1892(ra) # 58b4 <printf>
      exit(1);
    4158:	4505                	li	a0,1
    415a:	00001097          	auipc	ra,0x1
    415e:	3e2080e7          	jalr	994(ra) # 553c <exit>
    wait(&xstatus);
    4162:	fcc40513          	addi	a0,s0,-52
    4166:	00001097          	auipc	ra,0x1
    416a:	3de080e7          	jalr	990(ra) # 5544 <wait>
    if(xstatus == -1){
    416e:	fcc42503          	lw	a0,-52(s0)
    4172:	57fd                	li	a5,-1
    4174:	00f50663          	beq	a0,a5,4180 <mem+0xa2>
    exit(xstatus);
    4178:	00001097          	auipc	ra,0x1
    417c:	3c4080e7          	jalr	964(ra) # 553c <exit>
      exit(0);
    4180:	4501                	li	a0,0
    4182:	00001097          	auipc	ra,0x1
    4186:	3ba080e7          	jalr	954(ra) # 553c <exit>

000000000000418a <sharedfd>:
{
    418a:	7159                	addi	sp,sp,-112
    418c:	f486                	sd	ra,104(sp)
    418e:	f0a2                	sd	s0,96(sp)
    4190:	eca6                	sd	s1,88(sp)
    4192:	e8ca                	sd	s2,80(sp)
    4194:	e4ce                	sd	s3,72(sp)
    4196:	e0d2                	sd	s4,64(sp)
    4198:	fc56                	sd	s5,56(sp)
    419a:	f85a                	sd	s6,48(sp)
    419c:	f45e                	sd	s7,40(sp)
    419e:	1880                	addi	s0,sp,112
    41a0:	89aa                	mv	s3,a0
  unlink("sharedfd");
    41a2:	00003517          	auipc	a0,0x3
    41a6:	7ce50513          	addi	a0,a0,1998 # 7970 <malloc+0x1ffc>
    41aa:	00001097          	auipc	ra,0x1
    41ae:	3e2080e7          	jalr	994(ra) # 558c <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    41b2:	20200593          	li	a1,514
    41b6:	00003517          	auipc	a0,0x3
    41ba:	7ba50513          	addi	a0,a0,1978 # 7970 <malloc+0x1ffc>
    41be:	00001097          	auipc	ra,0x1
    41c2:	3be080e7          	jalr	958(ra) # 557c <open>
  if(fd < 0){
    41c6:	04054a63          	bltz	a0,421a <sharedfd+0x90>
    41ca:	892a                	mv	s2,a0
  pid = fork();
    41cc:	00001097          	auipc	ra,0x1
    41d0:	368080e7          	jalr	872(ra) # 5534 <fork>
    41d4:	8a2a                	mv	s4,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    41d6:	06300593          	li	a1,99
    41da:	c119                	beqz	a0,41e0 <sharedfd+0x56>
    41dc:	07000593          	li	a1,112
    41e0:	4629                	li	a2,10
    41e2:	fa040513          	addi	a0,s0,-96
    41e6:	00001097          	auipc	ra,0x1
    41ea:	140080e7          	jalr	320(ra) # 5326 <memset>
    41ee:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    41f2:	4629                	li	a2,10
    41f4:	fa040593          	addi	a1,s0,-96
    41f8:	854a                	mv	a0,s2
    41fa:	00001097          	auipc	ra,0x1
    41fe:	362080e7          	jalr	866(ra) # 555c <write>
    4202:	47a9                	li	a5,10
    4204:	02f51963          	bne	a0,a5,4236 <sharedfd+0xac>
  for(i = 0; i < N; i++){
    4208:	34fd                	addiw	s1,s1,-1
    420a:	f4e5                	bnez	s1,41f2 <sharedfd+0x68>
  if(pid == 0) {
    420c:	040a1363          	bnez	s4,4252 <sharedfd+0xc8>
    exit(0);
    4210:	4501                	li	a0,0
    4212:	00001097          	auipc	ra,0x1
    4216:	32a080e7          	jalr	810(ra) # 553c <exit>
    printf("%s: cannot open sharedfd for writing", s);
    421a:	85ce                	mv	a1,s3
    421c:	00003517          	auipc	a0,0x3
    4220:	76450513          	addi	a0,a0,1892 # 7980 <malloc+0x200c>
    4224:	00001097          	auipc	ra,0x1
    4228:	690080e7          	jalr	1680(ra) # 58b4 <printf>
    exit(1);
    422c:	4505                	li	a0,1
    422e:	00001097          	auipc	ra,0x1
    4232:	30e080e7          	jalr	782(ra) # 553c <exit>
      printf("%s: write sharedfd failed\n", s);
    4236:	85ce                	mv	a1,s3
    4238:	00003517          	auipc	a0,0x3
    423c:	77050513          	addi	a0,a0,1904 # 79a8 <malloc+0x2034>
    4240:	00001097          	auipc	ra,0x1
    4244:	674080e7          	jalr	1652(ra) # 58b4 <printf>
      exit(1);
    4248:	4505                	li	a0,1
    424a:	00001097          	auipc	ra,0x1
    424e:	2f2080e7          	jalr	754(ra) # 553c <exit>
    wait(&xstatus);
    4252:	f9c40513          	addi	a0,s0,-100
    4256:	00001097          	auipc	ra,0x1
    425a:	2ee080e7          	jalr	750(ra) # 5544 <wait>
    if(xstatus != 0)
    425e:	f9c42a03          	lw	s4,-100(s0)
    4262:	000a0763          	beqz	s4,4270 <sharedfd+0xe6>
      exit(xstatus);
    4266:	8552                	mv	a0,s4
    4268:	00001097          	auipc	ra,0x1
    426c:	2d4080e7          	jalr	724(ra) # 553c <exit>
  close(fd);
    4270:	854a                	mv	a0,s2
    4272:	00001097          	auipc	ra,0x1
    4276:	2f2080e7          	jalr	754(ra) # 5564 <close>
  fd = open("sharedfd", 0);
    427a:	4581                	li	a1,0
    427c:	00003517          	auipc	a0,0x3
    4280:	6f450513          	addi	a0,a0,1780 # 7970 <malloc+0x1ffc>
    4284:	00001097          	auipc	ra,0x1
    4288:	2f8080e7          	jalr	760(ra) # 557c <open>
    428c:	8baa                	mv	s7,a0
  nc = np = 0;
    428e:	8ad2                	mv	s5,s4
  if(fd < 0){
    4290:	02054563          	bltz	a0,42ba <sharedfd+0x130>
    4294:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    4298:	06300493          	li	s1,99
      if(buf[i] == 'p')
    429c:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    42a0:	4629                	li	a2,10
    42a2:	fa040593          	addi	a1,s0,-96
    42a6:	855e                	mv	a0,s7
    42a8:	00001097          	auipc	ra,0x1
    42ac:	2ac080e7          	jalr	684(ra) # 5554 <read>
    42b0:	02a05f63          	blez	a0,42ee <sharedfd+0x164>
    42b4:	fa040793          	addi	a5,s0,-96
    42b8:	a01d                	j	42de <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    42ba:	85ce                	mv	a1,s3
    42bc:	00003517          	auipc	a0,0x3
    42c0:	70c50513          	addi	a0,a0,1804 # 79c8 <malloc+0x2054>
    42c4:	00001097          	auipc	ra,0x1
    42c8:	5f0080e7          	jalr	1520(ra) # 58b4 <printf>
    exit(1);
    42cc:	4505                	li	a0,1
    42ce:	00001097          	auipc	ra,0x1
    42d2:	26e080e7          	jalr	622(ra) # 553c <exit>
        nc++;
    42d6:	2a05                	addiw	s4,s4,1
    for(i = 0; i < sizeof(buf); i++){
    42d8:	0785                	addi	a5,a5,1
    42da:	fd2783e3          	beq	a5,s2,42a0 <sharedfd+0x116>
      if(buf[i] == 'c')
    42de:	0007c703          	lbu	a4,0(a5) # 3e800000 <_end+0x3e7f1630>
    42e2:	fe970ae3          	beq	a4,s1,42d6 <sharedfd+0x14c>
      if(buf[i] == 'p')
    42e6:	ff6719e3          	bne	a4,s6,42d8 <sharedfd+0x14e>
        np++;
    42ea:	2a85                	addiw	s5,s5,1
    42ec:	b7f5                	j	42d8 <sharedfd+0x14e>
  close(fd);
    42ee:	855e                	mv	a0,s7
    42f0:	00001097          	auipc	ra,0x1
    42f4:	274080e7          	jalr	628(ra) # 5564 <close>
  unlink("sharedfd");
    42f8:	00003517          	auipc	a0,0x3
    42fc:	67850513          	addi	a0,a0,1656 # 7970 <malloc+0x1ffc>
    4300:	00001097          	auipc	ra,0x1
    4304:	28c080e7          	jalr	652(ra) # 558c <unlink>
  if(nc == N*SZ && np == N*SZ){
    4308:	6789                	lui	a5,0x2
    430a:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0xee>
    430e:	00fa1763          	bne	s4,a5,431c <sharedfd+0x192>
    4312:	6789                	lui	a5,0x2
    4314:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0xee>
    4318:	02fa8063          	beq	s5,a5,4338 <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    431c:	85ce                	mv	a1,s3
    431e:	00003517          	auipc	a0,0x3
    4322:	6d250513          	addi	a0,a0,1746 # 79f0 <malloc+0x207c>
    4326:	00001097          	auipc	ra,0x1
    432a:	58e080e7          	jalr	1422(ra) # 58b4 <printf>
    exit(1);
    432e:	4505                	li	a0,1
    4330:	00001097          	auipc	ra,0x1
    4334:	20c080e7          	jalr	524(ra) # 553c <exit>
    exit(0);
    4338:	4501                	li	a0,0
    433a:	00001097          	auipc	ra,0x1
    433e:	202080e7          	jalr	514(ra) # 553c <exit>

0000000000004342 <fourfiles>:
{
    4342:	7135                	addi	sp,sp,-160
    4344:	ed06                	sd	ra,152(sp)
    4346:	e922                	sd	s0,144(sp)
    4348:	e526                	sd	s1,136(sp)
    434a:	e14a                	sd	s2,128(sp)
    434c:	fcce                	sd	s3,120(sp)
    434e:	f8d2                	sd	s4,112(sp)
    4350:	f4d6                	sd	s5,104(sp)
    4352:	f0da                	sd	s6,96(sp)
    4354:	ecde                	sd	s7,88(sp)
    4356:	e8e2                	sd	s8,80(sp)
    4358:	e4e6                	sd	s9,72(sp)
    435a:	e0ea                	sd	s10,64(sp)
    435c:	fc6e                	sd	s11,56(sp)
    435e:	1100                	addi	s0,sp,160
    4360:	8d2a                	mv	s10,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4362:	00003797          	auipc	a5,0x3
    4366:	6a678793          	addi	a5,a5,1702 # 7a08 <malloc+0x2094>
    436a:	f6f43823          	sd	a5,-144(s0)
    436e:	00003797          	auipc	a5,0x3
    4372:	6a278793          	addi	a5,a5,1698 # 7a10 <malloc+0x209c>
    4376:	f6f43c23          	sd	a5,-136(s0)
    437a:	00003797          	auipc	a5,0x3
    437e:	69e78793          	addi	a5,a5,1694 # 7a18 <malloc+0x20a4>
    4382:	f8f43023          	sd	a5,-128(s0)
    4386:	00003797          	auipc	a5,0x3
    438a:	69a78793          	addi	a5,a5,1690 # 7a20 <malloc+0x20ac>
    438e:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4392:	f7040b13          	addi	s6,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    4396:	895a                	mv	s2,s6
  for(pi = 0; pi < NCHILD; pi++){
    4398:	4481                	li	s1,0
    439a:	4a11                	li	s4,4
    fname = names[pi];
    439c:	00093983          	ld	s3,0(s2)
    unlink(fname);
    43a0:	854e                	mv	a0,s3
    43a2:	00001097          	auipc	ra,0x1
    43a6:	1ea080e7          	jalr	490(ra) # 558c <unlink>
    pid = fork();
    43aa:	00001097          	auipc	ra,0x1
    43ae:	18a080e7          	jalr	394(ra) # 5534 <fork>
    if(pid < 0){
    43b2:	04054063          	bltz	a0,43f2 <fourfiles+0xb0>
    if(pid == 0){
    43b6:	cd21                	beqz	a0,440e <fourfiles+0xcc>
  for(pi = 0; pi < NCHILD; pi++){
    43b8:	2485                	addiw	s1,s1,1
    43ba:	0921                	addi	s2,s2,8
    43bc:	ff4490e3          	bne	s1,s4,439c <fourfiles+0x5a>
    43c0:	4491                	li	s1,4
    wait(&xstatus);
    43c2:	f6c40513          	addi	a0,s0,-148
    43c6:	00001097          	auipc	ra,0x1
    43ca:	17e080e7          	jalr	382(ra) # 5544 <wait>
    if(xstatus != 0)
    43ce:	f6c42503          	lw	a0,-148(s0)
    43d2:	e961                	bnez	a0,44a2 <fourfiles+0x160>
  for(pi = 0; pi < NCHILD; pi++){
    43d4:	34fd                	addiw	s1,s1,-1
    43d6:	f4f5                	bnez	s1,43c2 <fourfiles+0x80>
    43d8:	03000a93          	li	s5,48
    total = 0;
    43dc:	8daa                	mv	s11,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    43de:	00007997          	auipc	s3,0x7
    43e2:	5e298993          	addi	s3,s3,1506 # b9c0 <buf>
    if(total != N*SZ){
    43e6:	6c05                	lui	s8,0x1
    43e8:	770c0c13          	addi	s8,s8,1904 # 1770 <pipe1+0x16>
  for(i = 0; i < NCHILD; i++){
    43ec:	03400c93          	li	s9,52
    43f0:	aa15                	j	4524 <fourfiles+0x1e2>
      printf("fork failed\n", s);
    43f2:	85ea                	mv	a1,s10
    43f4:	00002517          	auipc	a0,0x2
    43f8:	69c50513          	addi	a0,a0,1692 # 6a90 <malloc+0x111c>
    43fc:	00001097          	auipc	ra,0x1
    4400:	4b8080e7          	jalr	1208(ra) # 58b4 <printf>
      exit(1);
    4404:	4505                	li	a0,1
    4406:	00001097          	auipc	ra,0x1
    440a:	136080e7          	jalr	310(ra) # 553c <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    440e:	20200593          	li	a1,514
    4412:	854e                	mv	a0,s3
    4414:	00001097          	auipc	ra,0x1
    4418:	168080e7          	jalr	360(ra) # 557c <open>
    441c:	892a                	mv	s2,a0
      if(fd < 0){
    441e:	04054663          	bltz	a0,446a <fourfiles+0x128>
      memset(buf, '0'+pi, SZ);
    4422:	1f400613          	li	a2,500
    4426:	0304859b          	addiw	a1,s1,48
    442a:	00007517          	auipc	a0,0x7
    442e:	59650513          	addi	a0,a0,1430 # b9c0 <buf>
    4432:	00001097          	auipc	ra,0x1
    4436:	ef4080e7          	jalr	-268(ra) # 5326 <memset>
    443a:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    443c:	00007997          	auipc	s3,0x7
    4440:	58498993          	addi	s3,s3,1412 # b9c0 <buf>
    4444:	1f400613          	li	a2,500
    4448:	85ce                	mv	a1,s3
    444a:	854a                	mv	a0,s2
    444c:	00001097          	auipc	ra,0x1
    4450:	110080e7          	jalr	272(ra) # 555c <write>
    4454:	1f400793          	li	a5,500
    4458:	02f51763          	bne	a0,a5,4486 <fourfiles+0x144>
      for(i = 0; i < N; i++){
    445c:	34fd                	addiw	s1,s1,-1
    445e:	f0fd                	bnez	s1,4444 <fourfiles+0x102>
      exit(0);
    4460:	4501                	li	a0,0
    4462:	00001097          	auipc	ra,0x1
    4466:	0da080e7          	jalr	218(ra) # 553c <exit>
        printf("create failed\n", s);
    446a:	85ea                	mv	a1,s10
    446c:	00003517          	auipc	a0,0x3
    4470:	5bc50513          	addi	a0,a0,1468 # 7a28 <malloc+0x20b4>
    4474:	00001097          	auipc	ra,0x1
    4478:	440080e7          	jalr	1088(ra) # 58b4 <printf>
        exit(1);
    447c:	4505                	li	a0,1
    447e:	00001097          	auipc	ra,0x1
    4482:	0be080e7          	jalr	190(ra) # 553c <exit>
          printf("write failed %d\n", n);
    4486:	85aa                	mv	a1,a0
    4488:	00003517          	auipc	a0,0x3
    448c:	5b050513          	addi	a0,a0,1456 # 7a38 <malloc+0x20c4>
    4490:	00001097          	auipc	ra,0x1
    4494:	424080e7          	jalr	1060(ra) # 58b4 <printf>
          exit(1);
    4498:	4505                	li	a0,1
    449a:	00001097          	auipc	ra,0x1
    449e:	0a2080e7          	jalr	162(ra) # 553c <exit>
      exit(xstatus);
    44a2:	00001097          	auipc	ra,0x1
    44a6:	09a080e7          	jalr	154(ra) # 553c <exit>
      total += n;
    44aa:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    44ae:	660d                	lui	a2,0x3
    44b0:	85ce                	mv	a1,s3
    44b2:	8552                	mv	a0,s4
    44b4:	00001097          	auipc	ra,0x1
    44b8:	0a0080e7          	jalr	160(ra) # 5554 <read>
    44bc:	04a05463          	blez	a0,4504 <fourfiles+0x1c2>
        if(buf[j] != '0'+i){
    44c0:	0009c783          	lbu	a5,0(s3)
    44c4:	02979263          	bne	a5,s1,44e8 <fourfiles+0x1a6>
    44c8:	00007797          	auipc	a5,0x7
    44cc:	4f978793          	addi	a5,a5,1273 # b9c1 <buf+0x1>
    44d0:	fff5069b          	addiw	a3,a0,-1
    44d4:	1682                	slli	a3,a3,0x20
    44d6:	9281                	srli	a3,a3,0x20
    44d8:	96be                	add	a3,a3,a5
      for(j = 0; j < n; j++){
    44da:	fcd788e3          	beq	a5,a3,44aa <fourfiles+0x168>
        if(buf[j] != '0'+i){
    44de:	0007c703          	lbu	a4,0(a5)
    44e2:	0785                	addi	a5,a5,1
    44e4:	fe970be3          	beq	a4,s1,44da <fourfiles+0x198>
          printf("wrong char\n", s);
    44e8:	85ea                	mv	a1,s10
    44ea:	00003517          	auipc	a0,0x3
    44ee:	56650513          	addi	a0,a0,1382 # 7a50 <malloc+0x20dc>
    44f2:	00001097          	auipc	ra,0x1
    44f6:	3c2080e7          	jalr	962(ra) # 58b4 <printf>
          exit(1);
    44fa:	4505                	li	a0,1
    44fc:	00001097          	auipc	ra,0x1
    4500:	040080e7          	jalr	64(ra) # 553c <exit>
    close(fd);
    4504:	8552                	mv	a0,s4
    4506:	00001097          	auipc	ra,0x1
    450a:	05e080e7          	jalr	94(ra) # 5564 <close>
    if(total != N*SZ){
    450e:	03891863          	bne	s2,s8,453e <fourfiles+0x1fc>
    unlink(fname);
    4512:	855e                	mv	a0,s7
    4514:	00001097          	auipc	ra,0x1
    4518:	078080e7          	jalr	120(ra) # 558c <unlink>
  for(i = 0; i < NCHILD; i++){
    451c:	0b21                	addi	s6,s6,8
    451e:	2a85                	addiw	s5,s5,1
    4520:	039a8d63          	beq	s5,s9,455a <fourfiles+0x218>
    fname = names[i];
    4524:	000b3b83          	ld	s7,0(s6) # 3000 <subdir+0x1a0>
    fd = open(fname, 0);
    4528:	4581                	li	a1,0
    452a:	855e                	mv	a0,s7
    452c:	00001097          	auipc	ra,0x1
    4530:	050080e7          	jalr	80(ra) # 557c <open>
    4534:	8a2a                	mv	s4,a0
    total = 0;
    4536:	896e                	mv	s2,s11
    4538:	000a849b          	sext.w	s1,s5
    while((n = read(fd, buf, sizeof(buf))) > 0){
    453c:	bf8d                	j	44ae <fourfiles+0x16c>
      printf("wrong length %d\n", total);
    453e:	85ca                	mv	a1,s2
    4540:	00003517          	auipc	a0,0x3
    4544:	52050513          	addi	a0,a0,1312 # 7a60 <malloc+0x20ec>
    4548:	00001097          	auipc	ra,0x1
    454c:	36c080e7          	jalr	876(ra) # 58b4 <printf>
      exit(1);
    4550:	4505                	li	a0,1
    4552:	00001097          	auipc	ra,0x1
    4556:	fea080e7          	jalr	-22(ra) # 553c <exit>
}
    455a:	60ea                	ld	ra,152(sp)
    455c:	644a                	ld	s0,144(sp)
    455e:	64aa                	ld	s1,136(sp)
    4560:	690a                	ld	s2,128(sp)
    4562:	79e6                	ld	s3,120(sp)
    4564:	7a46                	ld	s4,112(sp)
    4566:	7aa6                	ld	s5,104(sp)
    4568:	7b06                	ld	s6,96(sp)
    456a:	6be6                	ld	s7,88(sp)
    456c:	6c46                	ld	s8,80(sp)
    456e:	6ca6                	ld	s9,72(sp)
    4570:	6d06                	ld	s10,64(sp)
    4572:	7de2                	ld	s11,56(sp)
    4574:	610d                	addi	sp,sp,160
    4576:	8082                	ret

0000000000004578 <concreate>:
{
    4578:	7135                	addi	sp,sp,-160
    457a:	ed06                	sd	ra,152(sp)
    457c:	e922                	sd	s0,144(sp)
    457e:	e526                	sd	s1,136(sp)
    4580:	e14a                	sd	s2,128(sp)
    4582:	fcce                	sd	s3,120(sp)
    4584:	f8d2                	sd	s4,112(sp)
    4586:	f4d6                	sd	s5,104(sp)
    4588:	f0da                	sd	s6,96(sp)
    458a:	ecde                	sd	s7,88(sp)
    458c:	1100                	addi	s0,sp,160
    458e:	89aa                	mv	s3,a0
  file[0] = 'C';
    4590:	04300793          	li	a5,67
    4594:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    4598:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    459c:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    459e:	4b0d                	li	s6,3
    45a0:	4a85                	li	s5,1
      link("C0", file);
    45a2:	00003b97          	auipc	s7,0x3
    45a6:	4d6b8b93          	addi	s7,s7,1238 # 7a78 <malloc+0x2104>
  for(i = 0; i < N; i++){
    45aa:	02800a13          	li	s4,40
    45ae:	acc1                	j	487e <concreate+0x306>
      link("C0", file);
    45b0:	fa840593          	addi	a1,s0,-88
    45b4:	855e                	mv	a0,s7
    45b6:	00001097          	auipc	ra,0x1
    45ba:	fe6080e7          	jalr	-26(ra) # 559c <link>
    if(pid == 0) {
    45be:	a45d                	j	4864 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    45c0:	4795                	li	a5,5
    45c2:	02f9693b          	remw	s2,s2,a5
    45c6:	4785                	li	a5,1
    45c8:	02f90b63          	beq	s2,a5,45fe <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    45cc:	20200593          	li	a1,514
    45d0:	fa840513          	addi	a0,s0,-88
    45d4:	00001097          	auipc	ra,0x1
    45d8:	fa8080e7          	jalr	-88(ra) # 557c <open>
      if(fd < 0){
    45dc:	26055b63          	bgez	a0,4852 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    45e0:	fa840593          	addi	a1,s0,-88
    45e4:	00003517          	auipc	a0,0x3
    45e8:	49c50513          	addi	a0,a0,1180 # 7a80 <malloc+0x210c>
    45ec:	00001097          	auipc	ra,0x1
    45f0:	2c8080e7          	jalr	712(ra) # 58b4 <printf>
        exit(1);
    45f4:	4505                	li	a0,1
    45f6:	00001097          	auipc	ra,0x1
    45fa:	f46080e7          	jalr	-186(ra) # 553c <exit>
      link("C0", file);
    45fe:	fa840593          	addi	a1,s0,-88
    4602:	00003517          	auipc	a0,0x3
    4606:	47650513          	addi	a0,a0,1142 # 7a78 <malloc+0x2104>
    460a:	00001097          	auipc	ra,0x1
    460e:	f92080e7          	jalr	-110(ra) # 559c <link>
      exit(0);
    4612:	4501                	li	a0,0
    4614:	00001097          	auipc	ra,0x1
    4618:	f28080e7          	jalr	-216(ra) # 553c <exit>
        exit(1);
    461c:	4505                	li	a0,1
    461e:	00001097          	auipc	ra,0x1
    4622:	f1e080e7          	jalr	-226(ra) # 553c <exit>
  memset(fa, 0, sizeof(fa));
    4626:	02800613          	li	a2,40
    462a:	4581                	li	a1,0
    462c:	f8040513          	addi	a0,s0,-128
    4630:	00001097          	auipc	ra,0x1
    4634:	cf6080e7          	jalr	-778(ra) # 5326 <memset>
  fd = open(".", 0);
    4638:	4581                	li	a1,0
    463a:	00002517          	auipc	a0,0x2
    463e:	ec650513          	addi	a0,a0,-314 # 6500 <malloc+0xb8c>
    4642:	00001097          	auipc	ra,0x1
    4646:	f3a080e7          	jalr	-198(ra) # 557c <open>
    464a:	892a                	mv	s2,a0
  n = 0;
    464c:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    464e:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4652:	02700b13          	li	s6,39
      fa[i] = 1;
    4656:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    4658:	4641                	li	a2,16
    465a:	f7040593          	addi	a1,s0,-144
    465e:	854a                	mv	a0,s2
    4660:	00001097          	auipc	ra,0x1
    4664:	ef4080e7          	jalr	-268(ra) # 5554 <read>
    4668:	08a05163          	blez	a0,46ea <concreate+0x172>
    if(de.inum == 0)
    466c:	f7045783          	lhu	a5,-144(s0)
    4670:	d7e5                	beqz	a5,4658 <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4672:	f7244783          	lbu	a5,-142(s0)
    4676:	ff4791e3          	bne	a5,s4,4658 <concreate+0xe0>
    467a:	f7444783          	lbu	a5,-140(s0)
    467e:	ffe9                	bnez	a5,4658 <concreate+0xe0>
      i = de.name[1] - '0';
    4680:	f7344783          	lbu	a5,-141(s0)
    4684:	fd07879b          	addiw	a5,a5,-48
    4688:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    468c:	00eb6f63          	bltu	s6,a4,46aa <concreate+0x132>
      if(fa[i]){
    4690:	fb040793          	addi	a5,s0,-80
    4694:	97ba                	add	a5,a5,a4
    4696:	fd07c783          	lbu	a5,-48(a5)
    469a:	eb85                	bnez	a5,46ca <concreate+0x152>
      fa[i] = 1;
    469c:	fb040793          	addi	a5,s0,-80
    46a0:	973e                	add	a4,a4,a5
    46a2:	fd770823          	sb	s7,-48(a4)
      n++;
    46a6:	2a85                	addiw	s5,s5,1
    46a8:	bf45                	j	4658 <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    46aa:	f7240613          	addi	a2,s0,-142
    46ae:	85ce                	mv	a1,s3
    46b0:	00003517          	auipc	a0,0x3
    46b4:	3f050513          	addi	a0,a0,1008 # 7aa0 <malloc+0x212c>
    46b8:	00001097          	auipc	ra,0x1
    46bc:	1fc080e7          	jalr	508(ra) # 58b4 <printf>
        exit(1);
    46c0:	4505                	li	a0,1
    46c2:	00001097          	auipc	ra,0x1
    46c6:	e7a080e7          	jalr	-390(ra) # 553c <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    46ca:	f7240613          	addi	a2,s0,-142
    46ce:	85ce                	mv	a1,s3
    46d0:	00003517          	auipc	a0,0x3
    46d4:	3f050513          	addi	a0,a0,1008 # 7ac0 <malloc+0x214c>
    46d8:	00001097          	auipc	ra,0x1
    46dc:	1dc080e7          	jalr	476(ra) # 58b4 <printf>
        exit(1);
    46e0:	4505                	li	a0,1
    46e2:	00001097          	auipc	ra,0x1
    46e6:	e5a080e7          	jalr	-422(ra) # 553c <exit>
  close(fd);
    46ea:	854a                	mv	a0,s2
    46ec:	00001097          	auipc	ra,0x1
    46f0:	e78080e7          	jalr	-392(ra) # 5564 <close>
  if(n != N){
    46f4:	02800793          	li	a5,40
    46f8:	00fa9763          	bne	s5,a5,4706 <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    46fc:	4a8d                	li	s5,3
    46fe:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    4700:	02800a13          	li	s4,40
    4704:	a8c9                	j	47d6 <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    4706:	85ce                	mv	a1,s3
    4708:	00003517          	auipc	a0,0x3
    470c:	3e050513          	addi	a0,a0,992 # 7ae8 <malloc+0x2174>
    4710:	00001097          	auipc	ra,0x1
    4714:	1a4080e7          	jalr	420(ra) # 58b4 <printf>
    exit(1);
    4718:	4505                	li	a0,1
    471a:	00001097          	auipc	ra,0x1
    471e:	e22080e7          	jalr	-478(ra) # 553c <exit>
      printf("%s: fork failed\n", s);
    4722:	85ce                	mv	a1,s3
    4724:	00002517          	auipc	a0,0x2
    4728:	f7c50513          	addi	a0,a0,-132 # 66a0 <malloc+0xd2c>
    472c:	00001097          	auipc	ra,0x1
    4730:	188080e7          	jalr	392(ra) # 58b4 <printf>
      exit(1);
    4734:	4505                	li	a0,1
    4736:	00001097          	auipc	ra,0x1
    473a:	e06080e7          	jalr	-506(ra) # 553c <exit>
      close(open(file, 0));
    473e:	4581                	li	a1,0
    4740:	fa840513          	addi	a0,s0,-88
    4744:	00001097          	auipc	ra,0x1
    4748:	e38080e7          	jalr	-456(ra) # 557c <open>
    474c:	00001097          	auipc	ra,0x1
    4750:	e18080e7          	jalr	-488(ra) # 5564 <close>
      close(open(file, 0));
    4754:	4581                	li	a1,0
    4756:	fa840513          	addi	a0,s0,-88
    475a:	00001097          	auipc	ra,0x1
    475e:	e22080e7          	jalr	-478(ra) # 557c <open>
    4762:	00001097          	auipc	ra,0x1
    4766:	e02080e7          	jalr	-510(ra) # 5564 <close>
      close(open(file, 0));
    476a:	4581                	li	a1,0
    476c:	fa840513          	addi	a0,s0,-88
    4770:	00001097          	auipc	ra,0x1
    4774:	e0c080e7          	jalr	-500(ra) # 557c <open>
    4778:	00001097          	auipc	ra,0x1
    477c:	dec080e7          	jalr	-532(ra) # 5564 <close>
      close(open(file, 0));
    4780:	4581                	li	a1,0
    4782:	fa840513          	addi	a0,s0,-88
    4786:	00001097          	auipc	ra,0x1
    478a:	df6080e7          	jalr	-522(ra) # 557c <open>
    478e:	00001097          	auipc	ra,0x1
    4792:	dd6080e7          	jalr	-554(ra) # 5564 <close>
      close(open(file, 0));
    4796:	4581                	li	a1,0
    4798:	fa840513          	addi	a0,s0,-88
    479c:	00001097          	auipc	ra,0x1
    47a0:	de0080e7          	jalr	-544(ra) # 557c <open>
    47a4:	00001097          	auipc	ra,0x1
    47a8:	dc0080e7          	jalr	-576(ra) # 5564 <close>
      close(open(file, 0));
    47ac:	4581                	li	a1,0
    47ae:	fa840513          	addi	a0,s0,-88
    47b2:	00001097          	auipc	ra,0x1
    47b6:	dca080e7          	jalr	-566(ra) # 557c <open>
    47ba:	00001097          	auipc	ra,0x1
    47be:	daa080e7          	jalr	-598(ra) # 5564 <close>
    if(pid == 0)
    47c2:	08090363          	beqz	s2,4848 <concreate+0x2d0>
      wait(0);
    47c6:	4501                	li	a0,0
    47c8:	00001097          	auipc	ra,0x1
    47cc:	d7c080e7          	jalr	-644(ra) # 5544 <wait>
  for(i = 0; i < N; i++){
    47d0:	2485                	addiw	s1,s1,1
    47d2:	0f448563          	beq	s1,s4,48bc <concreate+0x344>
    file[1] = '0' + i;
    47d6:	0304879b          	addiw	a5,s1,48
    47da:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    47de:	00001097          	auipc	ra,0x1
    47e2:	d56080e7          	jalr	-682(ra) # 5534 <fork>
    47e6:	892a                	mv	s2,a0
    if(pid < 0){
    47e8:	f2054de3          	bltz	a0,4722 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    47ec:	0354e73b          	remw	a4,s1,s5
    47f0:	00a767b3          	or	a5,a4,a0
    47f4:	2781                	sext.w	a5,a5
    47f6:	d7a1                	beqz	a5,473e <concreate+0x1c6>
    47f8:	01671363          	bne	a4,s6,47fe <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    47fc:	f129                	bnez	a0,473e <concreate+0x1c6>
      unlink(file);
    47fe:	fa840513          	addi	a0,s0,-88
    4802:	00001097          	auipc	ra,0x1
    4806:	d8a080e7          	jalr	-630(ra) # 558c <unlink>
      unlink(file);
    480a:	fa840513          	addi	a0,s0,-88
    480e:	00001097          	auipc	ra,0x1
    4812:	d7e080e7          	jalr	-642(ra) # 558c <unlink>
      unlink(file);
    4816:	fa840513          	addi	a0,s0,-88
    481a:	00001097          	auipc	ra,0x1
    481e:	d72080e7          	jalr	-654(ra) # 558c <unlink>
      unlink(file);
    4822:	fa840513          	addi	a0,s0,-88
    4826:	00001097          	auipc	ra,0x1
    482a:	d66080e7          	jalr	-666(ra) # 558c <unlink>
      unlink(file);
    482e:	fa840513          	addi	a0,s0,-88
    4832:	00001097          	auipc	ra,0x1
    4836:	d5a080e7          	jalr	-678(ra) # 558c <unlink>
      unlink(file);
    483a:	fa840513          	addi	a0,s0,-88
    483e:	00001097          	auipc	ra,0x1
    4842:	d4e080e7          	jalr	-690(ra) # 558c <unlink>
    4846:	bfb5                	j	47c2 <concreate+0x24a>
      exit(0);
    4848:	4501                	li	a0,0
    484a:	00001097          	auipc	ra,0x1
    484e:	cf2080e7          	jalr	-782(ra) # 553c <exit>
      close(fd);
    4852:	00001097          	auipc	ra,0x1
    4856:	d12080e7          	jalr	-750(ra) # 5564 <close>
    if(pid == 0) {
    485a:	bb65                	j	4612 <concreate+0x9a>
      close(fd);
    485c:	00001097          	auipc	ra,0x1
    4860:	d08080e7          	jalr	-760(ra) # 5564 <close>
      wait(&xstatus);
    4864:	f6c40513          	addi	a0,s0,-148
    4868:	00001097          	auipc	ra,0x1
    486c:	cdc080e7          	jalr	-804(ra) # 5544 <wait>
      if(xstatus != 0)
    4870:	f6c42483          	lw	s1,-148(s0)
    4874:	da0494e3          	bnez	s1,461c <concreate+0xa4>
  for(i = 0; i < N; i++){
    4878:	2905                	addiw	s2,s2,1
    487a:	db4906e3          	beq	s2,s4,4626 <concreate+0xae>
    file[1] = '0' + i;
    487e:	0309079b          	addiw	a5,s2,48
    4882:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    4886:	fa840513          	addi	a0,s0,-88
    488a:	00001097          	auipc	ra,0x1
    488e:	d02080e7          	jalr	-766(ra) # 558c <unlink>
    pid = fork();
    4892:	00001097          	auipc	ra,0x1
    4896:	ca2080e7          	jalr	-862(ra) # 5534 <fork>
    if(pid && (i % 3) == 1){
    489a:	d20503e3          	beqz	a0,45c0 <concreate+0x48>
    489e:	036967bb          	remw	a5,s2,s6
    48a2:	d15787e3          	beq	a5,s5,45b0 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    48a6:	20200593          	li	a1,514
    48aa:	fa840513          	addi	a0,s0,-88
    48ae:	00001097          	auipc	ra,0x1
    48b2:	cce080e7          	jalr	-818(ra) # 557c <open>
      if(fd < 0){
    48b6:	fa0553e3          	bgez	a0,485c <concreate+0x2e4>
    48ba:	b31d                	j	45e0 <concreate+0x68>
}
    48bc:	60ea                	ld	ra,152(sp)
    48be:	644a                	ld	s0,144(sp)
    48c0:	64aa                	ld	s1,136(sp)
    48c2:	690a                	ld	s2,128(sp)
    48c4:	79e6                	ld	s3,120(sp)
    48c6:	7a46                	ld	s4,112(sp)
    48c8:	7aa6                	ld	s5,104(sp)
    48ca:	7b06                	ld	s6,96(sp)
    48cc:	6be6                	ld	s7,88(sp)
    48ce:	610d                	addi	sp,sp,160
    48d0:	8082                	ret

00000000000048d2 <bigfile>:
{
    48d2:	7139                	addi	sp,sp,-64
    48d4:	fc06                	sd	ra,56(sp)
    48d6:	f822                	sd	s0,48(sp)
    48d8:	f426                	sd	s1,40(sp)
    48da:	f04a                	sd	s2,32(sp)
    48dc:	ec4e                	sd	s3,24(sp)
    48de:	e852                	sd	s4,16(sp)
    48e0:	e456                	sd	s5,8(sp)
    48e2:	0080                	addi	s0,sp,64
    48e4:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    48e6:	00003517          	auipc	a0,0x3
    48ea:	23a50513          	addi	a0,a0,570 # 7b20 <malloc+0x21ac>
    48ee:	00001097          	auipc	ra,0x1
    48f2:	c9e080e7          	jalr	-866(ra) # 558c <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    48f6:	20200593          	li	a1,514
    48fa:	00003517          	auipc	a0,0x3
    48fe:	22650513          	addi	a0,a0,550 # 7b20 <malloc+0x21ac>
    4902:	00001097          	auipc	ra,0x1
    4906:	c7a080e7          	jalr	-902(ra) # 557c <open>
    490a:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    490c:	4481                	li	s1,0
    memset(buf, i, SZ);
    490e:	00007917          	auipc	s2,0x7
    4912:	0b290913          	addi	s2,s2,178 # b9c0 <buf>
  for(i = 0; i < N; i++){
    4916:	4a51                	li	s4,20
  if(fd < 0){
    4918:	0a054063          	bltz	a0,49b8 <bigfile+0xe6>
    memset(buf, i, SZ);
    491c:	25800613          	li	a2,600
    4920:	85a6                	mv	a1,s1
    4922:	854a                	mv	a0,s2
    4924:	00001097          	auipc	ra,0x1
    4928:	a02080e7          	jalr	-1534(ra) # 5326 <memset>
    if(write(fd, buf, SZ) != SZ){
    492c:	25800613          	li	a2,600
    4930:	85ca                	mv	a1,s2
    4932:	854e                	mv	a0,s3
    4934:	00001097          	auipc	ra,0x1
    4938:	c28080e7          	jalr	-984(ra) # 555c <write>
    493c:	25800793          	li	a5,600
    4940:	08f51a63          	bne	a0,a5,49d4 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4944:	2485                	addiw	s1,s1,1
    4946:	fd449be3          	bne	s1,s4,491c <bigfile+0x4a>
  close(fd);
    494a:	854e                	mv	a0,s3
    494c:	00001097          	auipc	ra,0x1
    4950:	c18080e7          	jalr	-1000(ra) # 5564 <close>
  fd = open("bigfile.dat", 0);
    4954:	4581                	li	a1,0
    4956:	00003517          	auipc	a0,0x3
    495a:	1ca50513          	addi	a0,a0,458 # 7b20 <malloc+0x21ac>
    495e:	00001097          	auipc	ra,0x1
    4962:	c1e080e7          	jalr	-994(ra) # 557c <open>
    4966:	8a2a                	mv	s4,a0
  total = 0;
    4968:	4981                	li	s3,0
  for(i = 0; ; i++){
    496a:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    496c:	00007917          	auipc	s2,0x7
    4970:	05490913          	addi	s2,s2,84 # b9c0 <buf>
  if(fd < 0){
    4974:	06054e63          	bltz	a0,49f0 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4978:	12c00613          	li	a2,300
    497c:	85ca                	mv	a1,s2
    497e:	8552                	mv	a0,s4
    4980:	00001097          	auipc	ra,0x1
    4984:	bd4080e7          	jalr	-1068(ra) # 5554 <read>
    if(cc < 0){
    4988:	08054263          	bltz	a0,4a0c <bigfile+0x13a>
    if(cc == 0)
    498c:	c971                	beqz	a0,4a60 <bigfile+0x18e>
    if(cc != SZ/2){
    498e:	12c00793          	li	a5,300
    4992:	08f51b63          	bne	a0,a5,4a28 <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4996:	01f4d79b          	srliw	a5,s1,0x1f
    499a:	9fa5                	addw	a5,a5,s1
    499c:	4017d79b          	sraiw	a5,a5,0x1
    49a0:	00094703          	lbu	a4,0(s2)
    49a4:	0af71063          	bne	a4,a5,4a44 <bigfile+0x172>
    49a8:	12b94703          	lbu	a4,299(s2)
    49ac:	08f71c63          	bne	a4,a5,4a44 <bigfile+0x172>
    total += cc;
    49b0:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    49b4:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    49b6:	b7c9                	j	4978 <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    49b8:	85d6                	mv	a1,s5
    49ba:	00003517          	auipc	a0,0x3
    49be:	17650513          	addi	a0,a0,374 # 7b30 <malloc+0x21bc>
    49c2:	00001097          	auipc	ra,0x1
    49c6:	ef2080e7          	jalr	-270(ra) # 58b4 <printf>
    exit(1);
    49ca:	4505                	li	a0,1
    49cc:	00001097          	auipc	ra,0x1
    49d0:	b70080e7          	jalr	-1168(ra) # 553c <exit>
      printf("%s: write bigfile failed\n", s);
    49d4:	85d6                	mv	a1,s5
    49d6:	00003517          	auipc	a0,0x3
    49da:	17a50513          	addi	a0,a0,378 # 7b50 <malloc+0x21dc>
    49de:	00001097          	auipc	ra,0x1
    49e2:	ed6080e7          	jalr	-298(ra) # 58b4 <printf>
      exit(1);
    49e6:	4505                	li	a0,1
    49e8:	00001097          	auipc	ra,0x1
    49ec:	b54080e7          	jalr	-1196(ra) # 553c <exit>
    printf("%s: cannot open bigfile\n", s);
    49f0:	85d6                	mv	a1,s5
    49f2:	00003517          	auipc	a0,0x3
    49f6:	17e50513          	addi	a0,a0,382 # 7b70 <malloc+0x21fc>
    49fa:	00001097          	auipc	ra,0x1
    49fe:	eba080e7          	jalr	-326(ra) # 58b4 <printf>
    exit(1);
    4a02:	4505                	li	a0,1
    4a04:	00001097          	auipc	ra,0x1
    4a08:	b38080e7          	jalr	-1224(ra) # 553c <exit>
      printf("%s: read bigfile failed\n", s);
    4a0c:	85d6                	mv	a1,s5
    4a0e:	00003517          	auipc	a0,0x3
    4a12:	18250513          	addi	a0,a0,386 # 7b90 <malloc+0x221c>
    4a16:	00001097          	auipc	ra,0x1
    4a1a:	e9e080e7          	jalr	-354(ra) # 58b4 <printf>
      exit(1);
    4a1e:	4505                	li	a0,1
    4a20:	00001097          	auipc	ra,0x1
    4a24:	b1c080e7          	jalr	-1252(ra) # 553c <exit>
      printf("%s: short read bigfile\n", s);
    4a28:	85d6                	mv	a1,s5
    4a2a:	00003517          	auipc	a0,0x3
    4a2e:	18650513          	addi	a0,a0,390 # 7bb0 <malloc+0x223c>
    4a32:	00001097          	auipc	ra,0x1
    4a36:	e82080e7          	jalr	-382(ra) # 58b4 <printf>
      exit(1);
    4a3a:	4505                	li	a0,1
    4a3c:	00001097          	auipc	ra,0x1
    4a40:	b00080e7          	jalr	-1280(ra) # 553c <exit>
      printf("%s: read bigfile wrong data\n", s);
    4a44:	85d6                	mv	a1,s5
    4a46:	00003517          	auipc	a0,0x3
    4a4a:	18250513          	addi	a0,a0,386 # 7bc8 <malloc+0x2254>
    4a4e:	00001097          	auipc	ra,0x1
    4a52:	e66080e7          	jalr	-410(ra) # 58b4 <printf>
      exit(1);
    4a56:	4505                	li	a0,1
    4a58:	00001097          	auipc	ra,0x1
    4a5c:	ae4080e7          	jalr	-1308(ra) # 553c <exit>
  close(fd);
    4a60:	8552                	mv	a0,s4
    4a62:	00001097          	auipc	ra,0x1
    4a66:	b02080e7          	jalr	-1278(ra) # 5564 <close>
  if(total != N*SZ){
    4a6a:	678d                	lui	a5,0x3
    4a6c:	ee078793          	addi	a5,a5,-288 # 2ee0 <subdir+0x80>
    4a70:	02f99363          	bne	s3,a5,4a96 <bigfile+0x1c4>
  unlink("bigfile.dat");
    4a74:	00003517          	auipc	a0,0x3
    4a78:	0ac50513          	addi	a0,a0,172 # 7b20 <malloc+0x21ac>
    4a7c:	00001097          	auipc	ra,0x1
    4a80:	b10080e7          	jalr	-1264(ra) # 558c <unlink>
}
    4a84:	70e2                	ld	ra,56(sp)
    4a86:	7442                	ld	s0,48(sp)
    4a88:	74a2                	ld	s1,40(sp)
    4a8a:	7902                	ld	s2,32(sp)
    4a8c:	69e2                	ld	s3,24(sp)
    4a8e:	6a42                	ld	s4,16(sp)
    4a90:	6aa2                	ld	s5,8(sp)
    4a92:	6121                	addi	sp,sp,64
    4a94:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4a96:	85d6                	mv	a1,s5
    4a98:	00003517          	auipc	a0,0x3
    4a9c:	15050513          	addi	a0,a0,336 # 7be8 <malloc+0x2274>
    4aa0:	00001097          	auipc	ra,0x1
    4aa4:	e14080e7          	jalr	-492(ra) # 58b4 <printf>
    exit(1);
    4aa8:	4505                	li	a0,1
    4aaa:	00001097          	auipc	ra,0x1
    4aae:	a92080e7          	jalr	-1390(ra) # 553c <exit>

0000000000004ab2 <dirtest>:
{
    4ab2:	1101                	addi	sp,sp,-32
    4ab4:	ec06                	sd	ra,24(sp)
    4ab6:	e822                	sd	s0,16(sp)
    4ab8:	e426                	sd	s1,8(sp)
    4aba:	1000                	addi	s0,sp,32
    4abc:	84aa                	mv	s1,a0
  printf("mkdir test\n");
    4abe:	00003517          	auipc	a0,0x3
    4ac2:	14a50513          	addi	a0,a0,330 # 7c08 <malloc+0x2294>
    4ac6:	00001097          	auipc	ra,0x1
    4aca:	dee080e7          	jalr	-530(ra) # 58b4 <printf>
  if(mkdir("dir0") < 0){
    4ace:	00003517          	auipc	a0,0x3
    4ad2:	14a50513          	addi	a0,a0,330 # 7c18 <malloc+0x22a4>
    4ad6:	00001097          	auipc	ra,0x1
    4ada:	ace080e7          	jalr	-1330(ra) # 55a4 <mkdir>
    4ade:	04054d63          	bltz	a0,4b38 <dirtest+0x86>
  if(chdir("dir0") < 0){
    4ae2:	00003517          	auipc	a0,0x3
    4ae6:	13650513          	addi	a0,a0,310 # 7c18 <malloc+0x22a4>
    4aea:	00001097          	auipc	ra,0x1
    4aee:	ac2080e7          	jalr	-1342(ra) # 55ac <chdir>
    4af2:	06054163          	bltz	a0,4b54 <dirtest+0xa2>
  if(chdir("..") < 0){
    4af6:	00003517          	auipc	a0,0x3
    4afa:	b4250513          	addi	a0,a0,-1214 # 7638 <malloc+0x1cc4>
    4afe:	00001097          	auipc	ra,0x1
    4b02:	aae080e7          	jalr	-1362(ra) # 55ac <chdir>
    4b06:	06054563          	bltz	a0,4b70 <dirtest+0xbe>
  if(unlink("dir0") < 0){
    4b0a:	00003517          	auipc	a0,0x3
    4b0e:	10e50513          	addi	a0,a0,270 # 7c18 <malloc+0x22a4>
    4b12:	00001097          	auipc	ra,0x1
    4b16:	a7a080e7          	jalr	-1414(ra) # 558c <unlink>
    4b1a:	06054963          	bltz	a0,4b8c <dirtest+0xda>
  printf("%s: mkdir test ok\n");
    4b1e:	00003517          	auipc	a0,0x3
    4b22:	14a50513          	addi	a0,a0,330 # 7c68 <malloc+0x22f4>
    4b26:	00001097          	auipc	ra,0x1
    4b2a:	d8e080e7          	jalr	-626(ra) # 58b4 <printf>
}
    4b2e:	60e2                	ld	ra,24(sp)
    4b30:	6442                	ld	s0,16(sp)
    4b32:	64a2                	ld	s1,8(sp)
    4b34:	6105                	addi	sp,sp,32
    4b36:	8082                	ret
    printf("%s: mkdir failed\n", s);
    4b38:	85a6                	mv	a1,s1
    4b3a:	00002517          	auipc	a0,0x2
    4b3e:	49e50513          	addi	a0,a0,1182 # 6fd8 <malloc+0x1664>
    4b42:	00001097          	auipc	ra,0x1
    4b46:	d72080e7          	jalr	-654(ra) # 58b4 <printf>
    exit(1);
    4b4a:	4505                	li	a0,1
    4b4c:	00001097          	auipc	ra,0x1
    4b50:	9f0080e7          	jalr	-1552(ra) # 553c <exit>
    printf("%s: chdir dir0 failed\n", s);
    4b54:	85a6                	mv	a1,s1
    4b56:	00003517          	auipc	a0,0x3
    4b5a:	0ca50513          	addi	a0,a0,202 # 7c20 <malloc+0x22ac>
    4b5e:	00001097          	auipc	ra,0x1
    4b62:	d56080e7          	jalr	-682(ra) # 58b4 <printf>
    exit(1);
    4b66:	4505                	li	a0,1
    4b68:	00001097          	auipc	ra,0x1
    4b6c:	9d4080e7          	jalr	-1580(ra) # 553c <exit>
    printf("%s: chdir .. failed\n", s);
    4b70:	85a6                	mv	a1,s1
    4b72:	00003517          	auipc	a0,0x3
    4b76:	0c650513          	addi	a0,a0,198 # 7c38 <malloc+0x22c4>
    4b7a:	00001097          	auipc	ra,0x1
    4b7e:	d3a080e7          	jalr	-710(ra) # 58b4 <printf>
    exit(1);
    4b82:	4505                	li	a0,1
    4b84:	00001097          	auipc	ra,0x1
    4b88:	9b8080e7          	jalr	-1608(ra) # 553c <exit>
    printf("%s: unlink dir0 failed\n", s);
    4b8c:	85a6                	mv	a1,s1
    4b8e:	00003517          	auipc	a0,0x3
    4b92:	0c250513          	addi	a0,a0,194 # 7c50 <malloc+0x22dc>
    4b96:	00001097          	auipc	ra,0x1
    4b9a:	d1e080e7          	jalr	-738(ra) # 58b4 <printf>
    exit(1);
    4b9e:	4505                	li	a0,1
    4ba0:	00001097          	auipc	ra,0x1
    4ba4:	99c080e7          	jalr	-1636(ra) # 553c <exit>

0000000000004ba8 <fsfull>:
{
    4ba8:	7171                	addi	sp,sp,-176
    4baa:	f506                	sd	ra,168(sp)
    4bac:	f122                	sd	s0,160(sp)
    4bae:	ed26                	sd	s1,152(sp)
    4bb0:	e94a                	sd	s2,144(sp)
    4bb2:	e54e                	sd	s3,136(sp)
    4bb4:	e152                	sd	s4,128(sp)
    4bb6:	fcd6                	sd	s5,120(sp)
    4bb8:	f8da                	sd	s6,112(sp)
    4bba:	f4de                	sd	s7,104(sp)
    4bbc:	f0e2                	sd	s8,96(sp)
    4bbe:	ece6                	sd	s9,88(sp)
    4bc0:	e8ea                	sd	s10,80(sp)
    4bc2:	e4ee                	sd	s11,72(sp)
    4bc4:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4bc6:	00003517          	auipc	a0,0x3
    4bca:	0ba50513          	addi	a0,a0,186 # 7c80 <malloc+0x230c>
    4bce:	00001097          	auipc	ra,0x1
    4bd2:	ce6080e7          	jalr	-794(ra) # 58b4 <printf>
  for(nfiles = 0; ; nfiles++){
    4bd6:	4481                	li	s1,0
    name[0] = 'f';
    4bd8:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4bdc:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4be0:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4be4:	4b29                	li	s6,10
    printf("%s: writing %s\n", name);
    4be6:	00003c97          	auipc	s9,0x3
    4bea:	0aac8c93          	addi	s9,s9,170 # 7c90 <malloc+0x231c>
    int total = 0;
    4bee:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4bf0:	00007a17          	auipc	s4,0x7
    4bf4:	dd0a0a13          	addi	s4,s4,-560 # b9c0 <buf>
    name[0] = 'f';
    4bf8:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4bfc:	0384c7bb          	divw	a5,s1,s8
    4c00:	0307879b          	addiw	a5,a5,48
    4c04:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c08:	0384e7bb          	remw	a5,s1,s8
    4c0c:	0377c7bb          	divw	a5,a5,s7
    4c10:	0307879b          	addiw	a5,a5,48
    4c14:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c18:	0374e7bb          	remw	a5,s1,s7
    4c1c:	0367c7bb          	divw	a5,a5,s6
    4c20:	0307879b          	addiw	a5,a5,48
    4c24:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c28:	0364e7bb          	remw	a5,s1,s6
    4c2c:	0307879b          	addiw	a5,a5,48
    4c30:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c34:	f4040aa3          	sb	zero,-171(s0)
    printf("%s: writing %s\n", name);
    4c38:	f5040593          	addi	a1,s0,-176
    4c3c:	8566                	mv	a0,s9
    4c3e:	00001097          	auipc	ra,0x1
    4c42:	c76080e7          	jalr	-906(ra) # 58b4 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4c46:	20200593          	li	a1,514
    4c4a:	f5040513          	addi	a0,s0,-176
    4c4e:	00001097          	auipc	ra,0x1
    4c52:	92e080e7          	jalr	-1746(ra) # 557c <open>
    4c56:	89aa                	mv	s3,a0
    if(fd < 0){
    4c58:	0a055663          	bgez	a0,4d04 <fsfull+0x15c>
      printf("%s: open %s failed\n", name);
    4c5c:	f5040593          	addi	a1,s0,-176
    4c60:	00003517          	auipc	a0,0x3
    4c64:	04050513          	addi	a0,a0,64 # 7ca0 <malloc+0x232c>
    4c68:	00001097          	auipc	ra,0x1
    4c6c:	c4c080e7          	jalr	-948(ra) # 58b4 <printf>
  while(nfiles >= 0){
    4c70:	0604c363          	bltz	s1,4cd6 <fsfull+0x12e>
    name[0] = 'f';
    4c74:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4c78:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c7c:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c80:	4929                	li	s2,10
  while(nfiles >= 0){
    4c82:	5afd                	li	s5,-1
    name[0] = 'f';
    4c84:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c88:	0344c7bb          	divw	a5,s1,s4
    4c8c:	0307879b          	addiw	a5,a5,48
    4c90:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c94:	0344e7bb          	remw	a5,s1,s4
    4c98:	0337c7bb          	divw	a5,a5,s3
    4c9c:	0307879b          	addiw	a5,a5,48
    4ca0:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4ca4:	0334e7bb          	remw	a5,s1,s3
    4ca8:	0327c7bb          	divw	a5,a5,s2
    4cac:	0307879b          	addiw	a5,a5,48
    4cb0:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4cb4:	0324e7bb          	remw	a5,s1,s2
    4cb8:	0307879b          	addiw	a5,a5,48
    4cbc:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4cc0:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4cc4:	f5040513          	addi	a0,s0,-176
    4cc8:	00001097          	auipc	ra,0x1
    4ccc:	8c4080e7          	jalr	-1852(ra) # 558c <unlink>
    nfiles--;
    4cd0:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4cd2:	fb5499e3          	bne	s1,s5,4c84 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4cd6:	00003517          	auipc	a0,0x3
    4cda:	ffa50513          	addi	a0,a0,-6 # 7cd0 <malloc+0x235c>
    4cde:	00001097          	auipc	ra,0x1
    4ce2:	bd6080e7          	jalr	-1066(ra) # 58b4 <printf>
}
    4ce6:	70aa                	ld	ra,168(sp)
    4ce8:	740a                	ld	s0,160(sp)
    4cea:	64ea                	ld	s1,152(sp)
    4cec:	694a                	ld	s2,144(sp)
    4cee:	69aa                	ld	s3,136(sp)
    4cf0:	6a0a                	ld	s4,128(sp)
    4cf2:	7ae6                	ld	s5,120(sp)
    4cf4:	7b46                	ld	s6,112(sp)
    4cf6:	7ba6                	ld	s7,104(sp)
    4cf8:	7c06                	ld	s8,96(sp)
    4cfa:	6ce6                	ld	s9,88(sp)
    4cfc:	6d46                	ld	s10,80(sp)
    4cfe:	6da6                	ld	s11,72(sp)
    4d00:	614d                	addi	sp,sp,176
    4d02:	8082                	ret
    int total = 0;
    4d04:	896e                	mv	s2,s11
      if(cc < BSIZE)
    4d06:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4d0a:	40000613          	li	a2,1024
    4d0e:	85d2                	mv	a1,s4
    4d10:	854e                	mv	a0,s3
    4d12:	00001097          	auipc	ra,0x1
    4d16:	84a080e7          	jalr	-1974(ra) # 555c <write>
      if(cc < BSIZE)
    4d1a:	00aad563          	ble	a0,s5,4d24 <fsfull+0x17c>
      total += cc;
    4d1e:	00a9093b          	addw	s2,s2,a0
    while(1){
    4d22:	b7e5                	j	4d0a <fsfull+0x162>
    printf("%s: wrote %d bytes\n", total);
    4d24:	85ca                	mv	a1,s2
    4d26:	00003517          	auipc	a0,0x3
    4d2a:	f9250513          	addi	a0,a0,-110 # 7cb8 <malloc+0x2344>
    4d2e:	00001097          	auipc	ra,0x1
    4d32:	b86080e7          	jalr	-1146(ra) # 58b4 <printf>
    close(fd);
    4d36:	854e                	mv	a0,s3
    4d38:	00001097          	auipc	ra,0x1
    4d3c:	82c080e7          	jalr	-2004(ra) # 5564 <close>
    if(total == 0)
    4d40:	f20908e3          	beqz	s2,4c70 <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4d44:	2485                	addiw	s1,s1,1
    4d46:	bd4d                	j	4bf8 <fsfull+0x50>

0000000000004d48 <rand>:
{
    4d48:	1141                	addi	sp,sp,-16
    4d4a:	e422                	sd	s0,8(sp)
    4d4c:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4d4e:	00003717          	auipc	a4,0x3
    4d52:	44270713          	addi	a4,a4,1090 # 8190 <randstate>
    4d56:	6308                	ld	a0,0(a4)
    4d58:	001967b7          	lui	a5,0x196
    4d5c:	60d78793          	addi	a5,a5,1549 # 19660d <_end+0x187c3d>
    4d60:	02f50533          	mul	a0,a0,a5
    4d64:	3c6ef7b7          	lui	a5,0x3c6ef
    4d68:	35f78793          	addi	a5,a5,863 # 3c6ef35f <_end+0x3c6e098f>
    4d6c:	953e                	add	a0,a0,a5
    4d6e:	e308                	sd	a0,0(a4)
}
    4d70:	2501                	sext.w	a0,a0
    4d72:	6422                	ld	s0,8(sp)
    4d74:	0141                	addi	sp,sp,16
    4d76:	8082                	ret

0000000000004d78 <badwrite>:
{
    4d78:	7179                	addi	sp,sp,-48
    4d7a:	f406                	sd	ra,40(sp)
    4d7c:	f022                	sd	s0,32(sp)
    4d7e:	ec26                	sd	s1,24(sp)
    4d80:	e84a                	sd	s2,16(sp)
    4d82:	e44e                	sd	s3,8(sp)
    4d84:	e052                	sd	s4,0(sp)
    4d86:	1800                	addi	s0,sp,48
  unlink("junk");
    4d88:	00003517          	auipc	a0,0x3
    4d8c:	f6050513          	addi	a0,a0,-160 # 7ce8 <malloc+0x2374>
    4d90:	00000097          	auipc	ra,0x0
    4d94:	7fc080e7          	jalr	2044(ra) # 558c <unlink>
    4d98:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d9c:	00003997          	auipc	s3,0x3
    4da0:	f4c98993          	addi	s3,s3,-180 # 7ce8 <malloc+0x2374>
    write(fd, (char*)0xffffffffffL, 1);
    4da4:	5a7d                	li	s4,-1
    4da6:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4daa:	20100593          	li	a1,513
    4dae:	854e                	mv	a0,s3
    4db0:	00000097          	auipc	ra,0x0
    4db4:	7cc080e7          	jalr	1996(ra) # 557c <open>
    4db8:	84aa                	mv	s1,a0
    if(fd < 0){
    4dba:	06054b63          	bltz	a0,4e30 <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4dbe:	4605                	li	a2,1
    4dc0:	85d2                	mv	a1,s4
    4dc2:	00000097          	auipc	ra,0x0
    4dc6:	79a080e7          	jalr	1946(ra) # 555c <write>
    close(fd);
    4dca:	8526                	mv	a0,s1
    4dcc:	00000097          	auipc	ra,0x0
    4dd0:	798080e7          	jalr	1944(ra) # 5564 <close>
    unlink("junk");
    4dd4:	854e                	mv	a0,s3
    4dd6:	00000097          	auipc	ra,0x0
    4dda:	7b6080e7          	jalr	1974(ra) # 558c <unlink>
  for(int i = 0; i < assumed_free; i++){
    4dde:	397d                	addiw	s2,s2,-1
    4de0:	fc0915e3          	bnez	s2,4daa <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4de4:	20100593          	li	a1,513
    4de8:	00003517          	auipc	a0,0x3
    4dec:	f0050513          	addi	a0,a0,-256 # 7ce8 <malloc+0x2374>
    4df0:	00000097          	auipc	ra,0x0
    4df4:	78c080e7          	jalr	1932(ra) # 557c <open>
    4df8:	84aa                	mv	s1,a0
  if(fd < 0){
    4dfa:	04054863          	bltz	a0,4e4a <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4dfe:	4605                	li	a2,1
    4e00:	00001597          	auipc	a1,0x1
    4e04:	0b858593          	addi	a1,a1,184 # 5eb8 <malloc+0x544>
    4e08:	00000097          	auipc	ra,0x0
    4e0c:	754080e7          	jalr	1876(ra) # 555c <write>
    4e10:	4785                	li	a5,1
    4e12:	04f50963          	beq	a0,a5,4e64 <badwrite+0xec>
    printf("write failed\n");
    4e16:	00003517          	auipc	a0,0x3
    4e1a:	ef250513          	addi	a0,a0,-270 # 7d08 <malloc+0x2394>
    4e1e:	00001097          	auipc	ra,0x1
    4e22:	a96080e7          	jalr	-1386(ra) # 58b4 <printf>
    exit(1);
    4e26:	4505                	li	a0,1
    4e28:	00000097          	auipc	ra,0x0
    4e2c:	714080e7          	jalr	1812(ra) # 553c <exit>
      printf("open junk failed\n");
    4e30:	00003517          	auipc	a0,0x3
    4e34:	ec050513          	addi	a0,a0,-320 # 7cf0 <malloc+0x237c>
    4e38:	00001097          	auipc	ra,0x1
    4e3c:	a7c080e7          	jalr	-1412(ra) # 58b4 <printf>
      exit(1);
    4e40:	4505                	li	a0,1
    4e42:	00000097          	auipc	ra,0x0
    4e46:	6fa080e7          	jalr	1786(ra) # 553c <exit>
    printf("open junk failed\n");
    4e4a:	00003517          	auipc	a0,0x3
    4e4e:	ea650513          	addi	a0,a0,-346 # 7cf0 <malloc+0x237c>
    4e52:	00001097          	auipc	ra,0x1
    4e56:	a62080e7          	jalr	-1438(ra) # 58b4 <printf>
    exit(1);
    4e5a:	4505                	li	a0,1
    4e5c:	00000097          	auipc	ra,0x0
    4e60:	6e0080e7          	jalr	1760(ra) # 553c <exit>
  close(fd);
    4e64:	8526                	mv	a0,s1
    4e66:	00000097          	auipc	ra,0x0
    4e6a:	6fe080e7          	jalr	1790(ra) # 5564 <close>
  unlink("junk");
    4e6e:	00003517          	auipc	a0,0x3
    4e72:	e7a50513          	addi	a0,a0,-390 # 7ce8 <malloc+0x2374>
    4e76:	00000097          	auipc	ra,0x0
    4e7a:	716080e7          	jalr	1814(ra) # 558c <unlink>
  exit(0);
    4e7e:	4501                	li	a0,0
    4e80:	00000097          	auipc	ra,0x0
    4e84:	6bc080e7          	jalr	1724(ra) # 553c <exit>

0000000000004e88 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4e88:	7139                	addi	sp,sp,-64
    4e8a:	fc06                	sd	ra,56(sp)
    4e8c:	f822                	sd	s0,48(sp)
    4e8e:	f426                	sd	s1,40(sp)
    4e90:	f04a                	sd	s2,32(sp)
    4e92:	ec4e                	sd	s3,24(sp)
    4e94:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4e96:	fc840513          	addi	a0,s0,-56
    4e9a:	00000097          	auipc	ra,0x0
    4e9e:	6b2080e7          	jalr	1714(ra) # 554c <pipe>
    4ea2:	06054863          	bltz	a0,4f12 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4ea6:	00000097          	auipc	ra,0x0
    4eaa:	68e080e7          	jalr	1678(ra) # 5534 <fork>

  if(pid < 0){
    4eae:	06054f63          	bltz	a0,4f2c <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4eb2:	ed59                	bnez	a0,4f50 <countfree+0xc8>
    close(fds[0]);
    4eb4:	fc842503          	lw	a0,-56(s0)
    4eb8:	00000097          	auipc	ra,0x0
    4ebc:	6ac080e7          	jalr	1708(ra) # 5564 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4ec0:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4ec2:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4ec4:	00001917          	auipc	s2,0x1
    4ec8:	ff490913          	addi	s2,s2,-12 # 5eb8 <malloc+0x544>
      uint64 a = (uint64) sbrk(4096);
    4ecc:	6505                	lui	a0,0x1
    4ece:	00000097          	auipc	ra,0x0
    4ed2:	6f6080e7          	jalr	1782(ra) # 55c4 <sbrk>
      if(a == 0xffffffffffffffff){
    4ed6:	06950863          	beq	a0,s1,4f46 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    4eda:	6785                	lui	a5,0x1
    4edc:	97aa                	add	a5,a5,a0
    4ede:	ff378fa3          	sb	s3,-1(a5) # fff <bigdir+0x83>
      if(write(fds[1], "x", 1) != 1){
    4ee2:	4605                	li	a2,1
    4ee4:	85ca                	mv	a1,s2
    4ee6:	fcc42503          	lw	a0,-52(s0)
    4eea:	00000097          	auipc	ra,0x0
    4eee:	672080e7          	jalr	1650(ra) # 555c <write>
    4ef2:	4785                	li	a5,1
    4ef4:	fcf50ce3          	beq	a0,a5,4ecc <countfree+0x44>
        printf("write() failed in countfree()\n");
    4ef8:	00003517          	auipc	a0,0x3
    4efc:	e6050513          	addi	a0,a0,-416 # 7d58 <malloc+0x23e4>
    4f00:	00001097          	auipc	ra,0x1
    4f04:	9b4080e7          	jalr	-1612(ra) # 58b4 <printf>
        exit(1);
    4f08:	4505                	li	a0,1
    4f0a:	00000097          	auipc	ra,0x0
    4f0e:	632080e7          	jalr	1586(ra) # 553c <exit>
    printf("pipe() failed in countfree()\n");
    4f12:	00003517          	auipc	a0,0x3
    4f16:	e0650513          	addi	a0,a0,-506 # 7d18 <malloc+0x23a4>
    4f1a:	00001097          	auipc	ra,0x1
    4f1e:	99a080e7          	jalr	-1638(ra) # 58b4 <printf>
    exit(1);
    4f22:	4505                	li	a0,1
    4f24:	00000097          	auipc	ra,0x0
    4f28:	618080e7          	jalr	1560(ra) # 553c <exit>
    printf("fork failed in countfree()\n");
    4f2c:	00003517          	auipc	a0,0x3
    4f30:	e0c50513          	addi	a0,a0,-500 # 7d38 <malloc+0x23c4>
    4f34:	00001097          	auipc	ra,0x1
    4f38:	980080e7          	jalr	-1664(ra) # 58b4 <printf>
    exit(1);
    4f3c:	4505                	li	a0,1
    4f3e:	00000097          	auipc	ra,0x0
    4f42:	5fe080e7          	jalr	1534(ra) # 553c <exit>
      }
    }

    exit(0);
    4f46:	4501                	li	a0,0
    4f48:	00000097          	auipc	ra,0x0
    4f4c:	5f4080e7          	jalr	1524(ra) # 553c <exit>
  }

  close(fds[1]);
    4f50:	fcc42503          	lw	a0,-52(s0)
    4f54:	00000097          	auipc	ra,0x0
    4f58:	610080e7          	jalr	1552(ra) # 5564 <close>

  int n = 0;
    4f5c:	4481                	li	s1,0
    4f5e:	a839                	j	4f7c <countfree+0xf4>
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    if(cc < 0){
      printf("read() failed in countfree()\n");
    4f60:	00003517          	auipc	a0,0x3
    4f64:	e1850513          	addi	a0,a0,-488 # 7d78 <malloc+0x2404>
    4f68:	00001097          	auipc	ra,0x1
    4f6c:	94c080e7          	jalr	-1716(ra) # 58b4 <printf>
      exit(1);
    4f70:	4505                	li	a0,1
    4f72:	00000097          	auipc	ra,0x0
    4f76:	5ca080e7          	jalr	1482(ra) # 553c <exit>
    }
    if(cc == 0)
      break;
    n += 1;
    4f7a:	2485                	addiw	s1,s1,1
    int cc = read(fds[0], &c, 1);
    4f7c:	4605                	li	a2,1
    4f7e:	fc740593          	addi	a1,s0,-57
    4f82:	fc842503          	lw	a0,-56(s0)
    4f86:	00000097          	auipc	ra,0x0
    4f8a:	5ce080e7          	jalr	1486(ra) # 5554 <read>
    if(cc < 0){
    4f8e:	fc0549e3          	bltz	a0,4f60 <countfree+0xd8>
    if(cc == 0)
    4f92:	f565                	bnez	a0,4f7a <countfree+0xf2>
  }

  close(fds[0]);
    4f94:	fc842503          	lw	a0,-56(s0)
    4f98:	00000097          	auipc	ra,0x0
    4f9c:	5cc080e7          	jalr	1484(ra) # 5564 <close>
  wait((int*)0);
    4fa0:	4501                	li	a0,0
    4fa2:	00000097          	auipc	ra,0x0
    4fa6:	5a2080e7          	jalr	1442(ra) # 5544 <wait>
  
  return n;
}
    4faa:	8526                	mv	a0,s1
    4fac:	70e2                	ld	ra,56(sp)
    4fae:	7442                	ld	s0,48(sp)
    4fb0:	74a2                	ld	s1,40(sp)
    4fb2:	7902                	ld	s2,32(sp)
    4fb4:	69e2                	ld	s3,24(sp)
    4fb6:	6121                	addi	sp,sp,64
    4fb8:	8082                	ret

0000000000004fba <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4fba:	7179                	addi	sp,sp,-48
    4fbc:	f406                	sd	ra,40(sp)
    4fbe:	f022                	sd	s0,32(sp)
    4fc0:	ec26                	sd	s1,24(sp)
    4fc2:	e84a                	sd	s2,16(sp)
    4fc4:	1800                	addi	s0,sp,48
    4fc6:	84aa                	mv	s1,a0
    4fc8:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4fca:	00003517          	auipc	a0,0x3
    4fce:	dce50513          	addi	a0,a0,-562 # 7d98 <malloc+0x2424>
    4fd2:	00001097          	auipc	ra,0x1
    4fd6:	8e2080e7          	jalr	-1822(ra) # 58b4 <printf>
  if((pid = fork()) < 0) {
    4fda:	00000097          	auipc	ra,0x0
    4fde:	55a080e7          	jalr	1370(ra) # 5534 <fork>
    4fe2:	02054e63          	bltz	a0,501e <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4fe6:	c929                	beqz	a0,5038 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4fe8:	fdc40513          	addi	a0,s0,-36
    4fec:	00000097          	auipc	ra,0x0
    4ff0:	558080e7          	jalr	1368(ra) # 5544 <wait>
    if(xstatus != 0) 
    4ff4:	fdc42783          	lw	a5,-36(s0)
    4ff8:	c7b9                	beqz	a5,5046 <run+0x8c>
      printf("FAILED\n");
    4ffa:	00003517          	auipc	a0,0x3
    4ffe:	dc650513          	addi	a0,a0,-570 # 7dc0 <malloc+0x244c>
    5002:	00001097          	auipc	ra,0x1
    5006:	8b2080e7          	jalr	-1870(ra) # 58b4 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    500a:	fdc42503          	lw	a0,-36(s0)
  }
}
    500e:	00153513          	seqz	a0,a0
    5012:	70a2                	ld	ra,40(sp)
    5014:	7402                	ld	s0,32(sp)
    5016:	64e2                	ld	s1,24(sp)
    5018:	6942                	ld	s2,16(sp)
    501a:	6145                	addi	sp,sp,48
    501c:	8082                	ret
    printf("runtest: fork error\n");
    501e:	00003517          	auipc	a0,0x3
    5022:	d8a50513          	addi	a0,a0,-630 # 7da8 <malloc+0x2434>
    5026:	00001097          	auipc	ra,0x1
    502a:	88e080e7          	jalr	-1906(ra) # 58b4 <printf>
    exit(1);
    502e:	4505                	li	a0,1
    5030:	00000097          	auipc	ra,0x0
    5034:	50c080e7          	jalr	1292(ra) # 553c <exit>
    f(s);
    5038:	854a                	mv	a0,s2
    503a:	9482                	jalr	s1
    exit(0);
    503c:	4501                	li	a0,0
    503e:	00000097          	auipc	ra,0x0
    5042:	4fe080e7          	jalr	1278(ra) # 553c <exit>
      printf("OK\n");
    5046:	00003517          	auipc	a0,0x3
    504a:	d8250513          	addi	a0,a0,-638 # 7dc8 <malloc+0x2454>
    504e:	00001097          	auipc	ra,0x1
    5052:	866080e7          	jalr	-1946(ra) # 58b4 <printf>
    5056:	bf55                	j	500a <run+0x50>

0000000000005058 <main>:

int
main(int argc, char *argv[])
{
    5058:	c3010113          	addi	sp,sp,-976
    505c:	3c113423          	sd	ra,968(sp)
    5060:	3c813023          	sd	s0,960(sp)
    5064:	3a913c23          	sd	s1,952(sp)
    5068:	3b213823          	sd	s2,944(sp)
    506c:	3b313423          	sd	s3,936(sp)
    5070:	3b413023          	sd	s4,928(sp)
    5074:	39513c23          	sd	s5,920(sp)
    5078:	39613823          	sd	s6,912(sp)
    507c:	0f80                	addi	s0,sp,976
    507e:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5080:	4789                	li	a5,2
    5082:	0af50063          	beq	a0,a5,5122 <main+0xca>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5086:	4785                	li	a5,1
    5088:	0ca7cb63          	blt	a5,a0,515e <main+0x106>
  char *justone = 0;
    508c:	4981                	li	s3,0
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    508e:	00001797          	auipc	a5,0x1
    5092:	9f278793          	addi	a5,a5,-1550 # 5a80 <malloc+0x10c>
    5096:	c3040713          	addi	a4,s0,-976
    509a:	00001317          	auipc	t1,0x1
    509e:	d7630313          	addi	t1,t1,-650 # 5e10 <malloc+0x49c>
    50a2:	0007b883          	ld	a7,0(a5)
    50a6:	0087b803          	ld	a6,8(a5)
    50aa:	6b88                	ld	a0,16(a5)
    50ac:	6f8c                	ld	a1,24(a5)
    50ae:	7390                	ld	a2,32(a5)
    50b0:	7794                	ld	a3,40(a5)
    50b2:	01173023          	sd	a7,0(a4)
    50b6:	01073423          	sd	a6,8(a4)
    50ba:	eb08                	sd	a0,16(a4)
    50bc:	ef0c                	sd	a1,24(a4)
    50be:	f310                	sd	a2,32(a4)
    50c0:	f714                	sd	a3,40(a4)
    50c2:	03078793          	addi	a5,a5,48
    50c6:	03070713          	addi	a4,a4,48
    50ca:	fc679ce3          	bne	a5,t1,50a2 <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    50ce:	00003517          	auipc	a0,0x3
    50d2:	db250513          	addi	a0,a0,-590 # 7e80 <malloc+0x250c>
    50d6:	00000097          	auipc	ra,0x0
    50da:	7de080e7          	jalr	2014(ra) # 58b4 <printf>
  int free0 = countfree();
    50de:	00000097          	auipc	ra,0x0
    50e2:	daa080e7          	jalr	-598(ra) # 4e88 <countfree>
    50e6:	8b2a                	mv	s6,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    50e8:	c3843903          	ld	s2,-968(s0)
    50ec:	c3040493          	addi	s1,s0,-976
  int fail = 0;
    50f0:	4a01                	li	s4,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    50f2:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    50f4:	0a091a63          	bnez	s2,51a8 <main+0x150>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    50f8:	00000097          	auipc	ra,0x0
    50fc:	d90080e7          	jalr	-624(ra) # 4e88 <countfree>
    5100:	85aa                	mv	a1,a0
    5102:	0f655463          	ble	s6,a0,51ea <main+0x192>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    5106:	865a                	mv	a2,s6
    5108:	00003517          	auipc	a0,0x3
    510c:	d3050513          	addi	a0,a0,-720 # 7e38 <malloc+0x24c4>
    5110:	00000097          	auipc	ra,0x0
    5114:	7a4080e7          	jalr	1956(ra) # 58b4 <printf>
    exit(1);
    5118:	4505                	li	a0,1
    511a:	00000097          	auipc	ra,0x0
    511e:	422080e7          	jalr	1058(ra) # 553c <exit>
    5122:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5124:	00003597          	auipc	a1,0x3
    5128:	cac58593          	addi	a1,a1,-852 # 7dd0 <malloc+0x245c>
    512c:	6488                	ld	a0,8(s1)
    512e:	00000097          	auipc	ra,0x0
    5132:	19a080e7          	jalr	410(ra) # 52c8 <strcmp>
    5136:	10050863          	beqz	a0,5246 <main+0x1ee>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    513a:	00003597          	auipc	a1,0x3
    513e:	d7e58593          	addi	a1,a1,-642 # 7eb8 <malloc+0x2544>
    5142:	6488                	ld	a0,8(s1)
    5144:	00000097          	auipc	ra,0x0
    5148:	184080e7          	jalr	388(ra) # 52c8 <strcmp>
    514c:	cd75                	beqz	a0,5248 <main+0x1f0>
  } else if(argc == 2 && argv[1][0] != '-'){
    514e:	0084b983          	ld	s3,8(s1)
    5152:	0009c703          	lbu	a4,0(s3)
    5156:	02d00793          	li	a5,45
    515a:	f2f71ae3          	bne	a4,a5,508e <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    515e:	00003517          	auipc	a0,0x3
    5162:	c7a50513          	addi	a0,a0,-902 # 7dd8 <malloc+0x2464>
    5166:	00000097          	auipc	ra,0x0
    516a:	74e080e7          	jalr	1870(ra) # 58b4 <printf>
    exit(1);
    516e:	4505                	li	a0,1
    5170:	00000097          	auipc	ra,0x0
    5174:	3cc080e7          	jalr	972(ra) # 553c <exit>
          exit(1);
    5178:	4505                	li	a0,1
    517a:	00000097          	auipc	ra,0x0
    517e:	3c2080e7          	jalr	962(ra) # 553c <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5182:	40a905bb          	subw	a1,s2,a0
    5186:	855a                	mv	a0,s6
    5188:	00000097          	auipc	ra,0x0
    518c:	72c080e7          	jalr	1836(ra) # 58b4 <printf>
        if(continuous != 2)
    5190:	09498763          	beq	s3,s4,521e <main+0x1c6>
          exit(1);
    5194:	4505                	li	a0,1
    5196:	00000097          	auipc	ra,0x0
    519a:	3a6080e7          	jalr	934(ra) # 553c <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    519e:	04c1                	addi	s1,s1,16
    51a0:	0084b903          	ld	s2,8(s1)
    51a4:	02090463          	beqz	s2,51cc <main+0x174>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    51a8:	00098963          	beqz	s3,51ba <main+0x162>
    51ac:	85ce                	mv	a1,s3
    51ae:	854a                	mv	a0,s2
    51b0:	00000097          	auipc	ra,0x0
    51b4:	118080e7          	jalr	280(ra) # 52c8 <strcmp>
    51b8:	f17d                	bnez	a0,519e <main+0x146>
      if(!run(t->f, t->s))
    51ba:	85ca                	mv	a1,s2
    51bc:	6088                	ld	a0,0(s1)
    51be:	00000097          	auipc	ra,0x0
    51c2:	dfc080e7          	jalr	-516(ra) # 4fba <run>
    51c6:	fd61                	bnez	a0,519e <main+0x146>
        fail = 1;
    51c8:	8a56                	mv	s4,s5
    51ca:	bfd1                	j	519e <main+0x146>
  if(fail){
    51cc:	f20a06e3          	beqz	s4,50f8 <main+0xa0>
    printf("SOME TESTS FAILED\n");
    51d0:	00003517          	auipc	a0,0x3
    51d4:	c5050513          	addi	a0,a0,-944 # 7e20 <malloc+0x24ac>
    51d8:	00000097          	auipc	ra,0x0
    51dc:	6dc080e7          	jalr	1756(ra) # 58b4 <printf>
    exit(1);
    51e0:	4505                	li	a0,1
    51e2:	00000097          	auipc	ra,0x0
    51e6:	35a080e7          	jalr	858(ra) # 553c <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    51ea:	00003517          	auipc	a0,0x3
    51ee:	c7e50513          	addi	a0,a0,-898 # 7e68 <malloc+0x24f4>
    51f2:	00000097          	auipc	ra,0x0
    51f6:	6c2080e7          	jalr	1730(ra) # 58b4 <printf>
    exit(0);
    51fa:	4501                	li	a0,0
    51fc:	00000097          	auipc	ra,0x0
    5200:	340080e7          	jalr	832(ra) # 553c <exit>
        printf("SOME TESTS FAILED\n");
    5204:	8556                	mv	a0,s5
    5206:	00000097          	auipc	ra,0x0
    520a:	6ae080e7          	jalr	1710(ra) # 58b4 <printf>
        if(continuous != 2)
    520e:	f74995e3          	bne	s3,s4,5178 <main+0x120>
      int free1 = countfree();
    5212:	00000097          	auipc	ra,0x0
    5216:	c76080e7          	jalr	-906(ra) # 4e88 <countfree>
      if(free1 < free0){
    521a:	f72544e3          	blt	a0,s2,5182 <main+0x12a>
      int free0 = countfree();
    521e:	00000097          	auipc	ra,0x0
    5222:	c6a080e7          	jalr	-918(ra) # 4e88 <countfree>
    5226:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5228:	c3843583          	ld	a1,-968(s0)
    522c:	d1fd                	beqz	a1,5212 <main+0x1ba>
    522e:	c3040493          	addi	s1,s0,-976
        if(!run(t->f, t->s)){
    5232:	6088                	ld	a0,0(s1)
    5234:	00000097          	auipc	ra,0x0
    5238:	d86080e7          	jalr	-634(ra) # 4fba <run>
    523c:	d561                	beqz	a0,5204 <main+0x1ac>
      for (struct test *t = tests; t->s != 0; t++) {
    523e:	04c1                	addi	s1,s1,16
    5240:	648c                	ld	a1,8(s1)
    5242:	f9e5                	bnez	a1,5232 <main+0x1da>
    5244:	b7f9                	j	5212 <main+0x1ba>
    continuous = 1;
    5246:	4985                	li	s3,1
  } tests[] = {
    5248:	00001797          	auipc	a5,0x1
    524c:	83878793          	addi	a5,a5,-1992 # 5a80 <malloc+0x10c>
    5250:	c3040713          	addi	a4,s0,-976
    5254:	00001317          	auipc	t1,0x1
    5258:	bbc30313          	addi	t1,t1,-1092 # 5e10 <malloc+0x49c>
    525c:	0007b883          	ld	a7,0(a5)
    5260:	0087b803          	ld	a6,8(a5)
    5264:	6b88                	ld	a0,16(a5)
    5266:	6f8c                	ld	a1,24(a5)
    5268:	7390                	ld	a2,32(a5)
    526a:	7794                	ld	a3,40(a5)
    526c:	01173023          	sd	a7,0(a4)
    5270:	01073423          	sd	a6,8(a4)
    5274:	eb08                	sd	a0,16(a4)
    5276:	ef0c                	sd	a1,24(a4)
    5278:	f310                	sd	a2,32(a4)
    527a:	f714                	sd	a3,40(a4)
    527c:	03078793          	addi	a5,a5,48
    5280:	03070713          	addi	a4,a4,48
    5284:	fc679ce3          	bne	a5,t1,525c <main+0x204>
    printf("continuous usertests starting\n");
    5288:	00003517          	auipc	a0,0x3
    528c:	c1050513          	addi	a0,a0,-1008 # 7e98 <malloc+0x2524>
    5290:	00000097          	auipc	ra,0x0
    5294:	624080e7          	jalr	1572(ra) # 58b4 <printf>
        printf("SOME TESTS FAILED\n");
    5298:	00003a97          	auipc	s5,0x3
    529c:	b88a8a93          	addi	s5,s5,-1144 # 7e20 <malloc+0x24ac>
        if(continuous != 2)
    52a0:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    52a2:	00003b17          	auipc	s6,0x3
    52a6:	b5eb0b13          	addi	s6,s6,-1186 # 7e00 <malloc+0x248c>
    52aa:	bf95                	j	521e <main+0x1c6>

00000000000052ac <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    52ac:	1141                	addi	sp,sp,-16
    52ae:	e422                	sd	s0,8(sp)
    52b0:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    52b2:	87aa                	mv	a5,a0
    52b4:	0585                	addi	a1,a1,1
    52b6:	0785                	addi	a5,a5,1
    52b8:	fff5c703          	lbu	a4,-1(a1)
    52bc:	fee78fa3          	sb	a4,-1(a5)
    52c0:	fb75                	bnez	a4,52b4 <strcpy+0x8>
    ;
  return os;
}
    52c2:	6422                	ld	s0,8(sp)
    52c4:	0141                	addi	sp,sp,16
    52c6:	8082                	ret

00000000000052c8 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    52c8:	1141                	addi	sp,sp,-16
    52ca:	e422                	sd	s0,8(sp)
    52cc:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    52ce:	00054783          	lbu	a5,0(a0)
    52d2:	cf91                	beqz	a5,52ee <strcmp+0x26>
    52d4:	0005c703          	lbu	a4,0(a1)
    52d8:	00f71b63          	bne	a4,a5,52ee <strcmp+0x26>
    p++, q++;
    52dc:	0505                	addi	a0,a0,1
    52de:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    52e0:	00054783          	lbu	a5,0(a0)
    52e4:	c789                	beqz	a5,52ee <strcmp+0x26>
    52e6:	0005c703          	lbu	a4,0(a1)
    52ea:	fef709e3          	beq	a4,a5,52dc <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
    52ee:	0005c503          	lbu	a0,0(a1)
}
    52f2:	40a7853b          	subw	a0,a5,a0
    52f6:	6422                	ld	s0,8(sp)
    52f8:	0141                	addi	sp,sp,16
    52fa:	8082                	ret

00000000000052fc <strlen>:

uint
strlen(const char *s)
{
    52fc:	1141                	addi	sp,sp,-16
    52fe:	e422                	sd	s0,8(sp)
    5300:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    5302:	00054783          	lbu	a5,0(a0)
    5306:	cf91                	beqz	a5,5322 <strlen+0x26>
    5308:	0505                	addi	a0,a0,1
    530a:	87aa                	mv	a5,a0
    530c:	4685                	li	a3,1
    530e:	9e89                	subw	a3,a3,a0
    5310:	00f6853b          	addw	a0,a3,a5
    5314:	0785                	addi	a5,a5,1
    5316:	fff7c703          	lbu	a4,-1(a5)
    531a:	fb7d                	bnez	a4,5310 <strlen+0x14>
    ;
  return n;
}
    531c:	6422                	ld	s0,8(sp)
    531e:	0141                	addi	sp,sp,16
    5320:	8082                	ret
  for(n = 0; s[n]; n++)
    5322:	4501                	li	a0,0
    5324:	bfe5                	j	531c <strlen+0x20>

0000000000005326 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5326:	1141                	addi	sp,sp,-16
    5328:	e422                	sd	s0,8(sp)
    532a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    532c:	ce09                	beqz	a2,5346 <memset+0x20>
    532e:	87aa                	mv	a5,a0
    5330:	fff6071b          	addiw	a4,a2,-1
    5334:	1702                	slli	a4,a4,0x20
    5336:	9301                	srli	a4,a4,0x20
    5338:	0705                	addi	a4,a4,1
    533a:	972a                	add	a4,a4,a0
    cdst[i] = c;
    533c:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    5340:	0785                	addi	a5,a5,1
    5342:	fee79de3          	bne	a5,a4,533c <memset+0x16>
  }
  return dst;
}
    5346:	6422                	ld	s0,8(sp)
    5348:	0141                	addi	sp,sp,16
    534a:	8082                	ret

000000000000534c <strchr>:

char*
strchr(const char *s, char c)
{
    534c:	1141                	addi	sp,sp,-16
    534e:	e422                	sd	s0,8(sp)
    5350:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5352:	00054783          	lbu	a5,0(a0)
    5356:	cf91                	beqz	a5,5372 <strchr+0x26>
    if(*s == c)
    5358:	00f58a63          	beq	a1,a5,536c <strchr+0x20>
  for(; *s; s++)
    535c:	0505                	addi	a0,a0,1
    535e:	00054783          	lbu	a5,0(a0)
    5362:	c781                	beqz	a5,536a <strchr+0x1e>
    if(*s == c)
    5364:	feb79ce3          	bne	a5,a1,535c <strchr+0x10>
    5368:	a011                	j	536c <strchr+0x20>
      return (char*)s;
  return 0;
    536a:	4501                	li	a0,0
}
    536c:	6422                	ld	s0,8(sp)
    536e:	0141                	addi	sp,sp,16
    5370:	8082                	ret
  return 0;
    5372:	4501                	li	a0,0
    5374:	bfe5                	j	536c <strchr+0x20>

0000000000005376 <gets>:

char*
gets(char *buf, int max)
{
    5376:	711d                	addi	sp,sp,-96
    5378:	ec86                	sd	ra,88(sp)
    537a:	e8a2                	sd	s0,80(sp)
    537c:	e4a6                	sd	s1,72(sp)
    537e:	e0ca                	sd	s2,64(sp)
    5380:	fc4e                	sd	s3,56(sp)
    5382:	f852                	sd	s4,48(sp)
    5384:	f456                	sd	s5,40(sp)
    5386:	f05a                	sd	s6,32(sp)
    5388:	ec5e                	sd	s7,24(sp)
    538a:	1080                	addi	s0,sp,96
    538c:	8baa                	mv	s7,a0
    538e:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    5390:	892a                	mv	s2,a0
    5392:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5394:	4aa9                	li	s5,10
    5396:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5398:	0019849b          	addiw	s1,s3,1
    539c:	0344d863          	ble	s4,s1,53cc <gets+0x56>
    cc = read(0, &c, 1);
    53a0:	4605                	li	a2,1
    53a2:	faf40593          	addi	a1,s0,-81
    53a6:	4501                	li	a0,0
    53a8:	00000097          	auipc	ra,0x0
    53ac:	1ac080e7          	jalr	428(ra) # 5554 <read>
    if(cc < 1)
    53b0:	00a05e63          	blez	a0,53cc <gets+0x56>
    buf[i++] = c;
    53b4:	faf44783          	lbu	a5,-81(s0)
    53b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    53bc:	01578763          	beq	a5,s5,53ca <gets+0x54>
    53c0:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
    53c2:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
    53c4:	fd679ae3          	bne	a5,s6,5398 <gets+0x22>
    53c8:	a011                	j	53cc <gets+0x56>
  for(i=0; i+1 < max; ){
    53ca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    53cc:	99de                	add	s3,s3,s7
    53ce:	00098023          	sb	zero,0(s3)
  return buf;
}
    53d2:	855e                	mv	a0,s7
    53d4:	60e6                	ld	ra,88(sp)
    53d6:	6446                	ld	s0,80(sp)
    53d8:	64a6                	ld	s1,72(sp)
    53da:	6906                	ld	s2,64(sp)
    53dc:	79e2                	ld	s3,56(sp)
    53de:	7a42                	ld	s4,48(sp)
    53e0:	7aa2                	ld	s5,40(sp)
    53e2:	7b02                	ld	s6,32(sp)
    53e4:	6be2                	ld	s7,24(sp)
    53e6:	6125                	addi	sp,sp,96
    53e8:	8082                	ret

00000000000053ea <stat>:

int
stat(const char *n, struct stat *st)
{
    53ea:	1101                	addi	sp,sp,-32
    53ec:	ec06                	sd	ra,24(sp)
    53ee:	e822                	sd	s0,16(sp)
    53f0:	e426                	sd	s1,8(sp)
    53f2:	e04a                	sd	s2,0(sp)
    53f4:	1000                	addi	s0,sp,32
    53f6:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    53f8:	4581                	li	a1,0
    53fa:	00000097          	auipc	ra,0x0
    53fe:	182080e7          	jalr	386(ra) # 557c <open>
  if(fd < 0)
    5402:	02054563          	bltz	a0,542c <stat+0x42>
    5406:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    5408:	85ca                	mv	a1,s2
    540a:	00000097          	auipc	ra,0x0
    540e:	18a080e7          	jalr	394(ra) # 5594 <fstat>
    5412:	892a                	mv	s2,a0
  close(fd);
    5414:	8526                	mv	a0,s1
    5416:	00000097          	auipc	ra,0x0
    541a:	14e080e7          	jalr	334(ra) # 5564 <close>
  return r;
}
    541e:	854a                	mv	a0,s2
    5420:	60e2                	ld	ra,24(sp)
    5422:	6442                	ld	s0,16(sp)
    5424:	64a2                	ld	s1,8(sp)
    5426:	6902                	ld	s2,0(sp)
    5428:	6105                	addi	sp,sp,32
    542a:	8082                	ret
    return -1;
    542c:	597d                	li	s2,-1
    542e:	bfc5                	j	541e <stat+0x34>

0000000000005430 <atoi>:

int
atoi(const char *s)
{
    5430:	1141                	addi	sp,sp,-16
    5432:	e422                	sd	s0,8(sp)
    5434:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5436:	00054683          	lbu	a3,0(a0)
    543a:	fd06879b          	addiw	a5,a3,-48
    543e:	0ff7f793          	andi	a5,a5,255
    5442:	4725                	li	a4,9
    5444:	02f76963          	bltu	a4,a5,5476 <atoi+0x46>
    5448:	862a                	mv	a2,a0
  n = 0;
    544a:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    544c:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    544e:	0605                	addi	a2,a2,1
    5450:	0025179b          	slliw	a5,a0,0x2
    5454:	9fa9                	addw	a5,a5,a0
    5456:	0017979b          	slliw	a5,a5,0x1
    545a:	9fb5                	addw	a5,a5,a3
    545c:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    5460:	00064683          	lbu	a3,0(a2) # 3000 <subdir+0x1a0>
    5464:	fd06871b          	addiw	a4,a3,-48
    5468:	0ff77713          	andi	a4,a4,255
    546c:	fee5f1e3          	bleu	a4,a1,544e <atoi+0x1e>
  return n;
}
    5470:	6422                	ld	s0,8(sp)
    5472:	0141                	addi	sp,sp,16
    5474:	8082                	ret
  n = 0;
    5476:	4501                	li	a0,0
    5478:	bfe5                	j	5470 <atoi+0x40>

000000000000547a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    547a:	1141                	addi	sp,sp,-16
    547c:	e422                	sd	s0,8(sp)
    547e:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    5480:	02b57663          	bleu	a1,a0,54ac <memmove+0x32>
    while(n-- > 0)
    5484:	02c05163          	blez	a2,54a6 <memmove+0x2c>
    5488:	fff6079b          	addiw	a5,a2,-1
    548c:	1782                	slli	a5,a5,0x20
    548e:	9381                	srli	a5,a5,0x20
    5490:	0785                	addi	a5,a5,1
    5492:	97aa                	add	a5,a5,a0
  dst = vdst;
    5494:	872a                	mv	a4,a0
      *dst++ = *src++;
    5496:	0585                	addi	a1,a1,1
    5498:	0705                	addi	a4,a4,1
    549a:	fff5c683          	lbu	a3,-1(a1)
    549e:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    54a2:	fee79ae3          	bne	a5,a4,5496 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    54a6:	6422                	ld	s0,8(sp)
    54a8:	0141                	addi	sp,sp,16
    54aa:	8082                	ret
    dst += n;
    54ac:	00c50733          	add	a4,a0,a2
    src += n;
    54b0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    54b2:	fec05ae3          	blez	a2,54a6 <memmove+0x2c>
    54b6:	fff6079b          	addiw	a5,a2,-1
    54ba:	1782                	slli	a5,a5,0x20
    54bc:	9381                	srli	a5,a5,0x20
    54be:	fff7c793          	not	a5,a5
    54c2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    54c4:	15fd                	addi	a1,a1,-1
    54c6:	177d                	addi	a4,a4,-1
    54c8:	0005c683          	lbu	a3,0(a1)
    54cc:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    54d0:	fef71ae3          	bne	a4,a5,54c4 <memmove+0x4a>
    54d4:	bfc9                	j	54a6 <memmove+0x2c>

00000000000054d6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    54d6:	1141                	addi	sp,sp,-16
    54d8:	e422                	sd	s0,8(sp)
    54da:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    54dc:	ce15                	beqz	a2,5518 <memcmp+0x42>
    54de:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
    54e2:	00054783          	lbu	a5,0(a0)
    54e6:	0005c703          	lbu	a4,0(a1)
    54ea:	02e79063          	bne	a5,a4,550a <memcmp+0x34>
    54ee:	1682                	slli	a3,a3,0x20
    54f0:	9281                	srli	a3,a3,0x20
    54f2:	0685                	addi	a3,a3,1
    54f4:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
    54f6:	0505                	addi	a0,a0,1
    p2++;
    54f8:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    54fa:	00d50d63          	beq	a0,a3,5514 <memcmp+0x3e>
    if (*p1 != *p2) {
    54fe:	00054783          	lbu	a5,0(a0)
    5502:	0005c703          	lbu	a4,0(a1)
    5506:	fee788e3          	beq	a5,a4,54f6 <memcmp+0x20>
      return *p1 - *p2;
    550a:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
    550e:	6422                	ld	s0,8(sp)
    5510:	0141                	addi	sp,sp,16
    5512:	8082                	ret
  return 0;
    5514:	4501                	li	a0,0
    5516:	bfe5                	j	550e <memcmp+0x38>
    5518:	4501                	li	a0,0
    551a:	bfd5                	j	550e <memcmp+0x38>

000000000000551c <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    551c:	1141                	addi	sp,sp,-16
    551e:	e406                	sd	ra,8(sp)
    5520:	e022                	sd	s0,0(sp)
    5522:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5524:	00000097          	auipc	ra,0x0
    5528:	f56080e7          	jalr	-170(ra) # 547a <memmove>
}
    552c:	60a2                	ld	ra,8(sp)
    552e:	6402                	ld	s0,0(sp)
    5530:	0141                	addi	sp,sp,16
    5532:	8082                	ret

0000000000005534 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5534:	4885                	li	a7,1
 ecall
    5536:	00000073          	ecall
 ret
    553a:	8082                	ret

000000000000553c <exit>:
.global exit
exit:
 li a7, SYS_exit
    553c:	4889                	li	a7,2
 ecall
    553e:	00000073          	ecall
 ret
    5542:	8082                	ret

0000000000005544 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5544:	488d                	li	a7,3
 ecall
    5546:	00000073          	ecall
 ret
    554a:	8082                	ret

000000000000554c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    554c:	4891                	li	a7,4
 ecall
    554e:	00000073          	ecall
 ret
    5552:	8082                	ret

0000000000005554 <read>:
.global read
read:
 li a7, SYS_read
    5554:	4895                	li	a7,5
 ecall
    5556:	00000073          	ecall
 ret
    555a:	8082                	ret

000000000000555c <write>:
.global write
write:
 li a7, SYS_write
    555c:	48c1                	li	a7,16
 ecall
    555e:	00000073          	ecall
 ret
    5562:	8082                	ret

0000000000005564 <close>:
.global close
close:
 li a7, SYS_close
    5564:	48d5                	li	a7,21
 ecall
    5566:	00000073          	ecall
 ret
    556a:	8082                	ret

000000000000556c <kill>:
.global kill
kill:
 li a7, SYS_kill
    556c:	4899                	li	a7,6
 ecall
    556e:	00000073          	ecall
 ret
    5572:	8082                	ret

0000000000005574 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5574:	489d                	li	a7,7
 ecall
    5576:	00000073          	ecall
 ret
    557a:	8082                	ret

000000000000557c <open>:
.global open
open:
 li a7, SYS_open
    557c:	48bd                	li	a7,15
 ecall
    557e:	00000073          	ecall
 ret
    5582:	8082                	ret

0000000000005584 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5584:	48c5                	li	a7,17
 ecall
    5586:	00000073          	ecall
 ret
    558a:	8082                	ret

000000000000558c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    558c:	48c9                	li	a7,18
 ecall
    558e:	00000073          	ecall
 ret
    5592:	8082                	ret

0000000000005594 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5594:	48a1                	li	a7,8
 ecall
    5596:	00000073          	ecall
 ret
    559a:	8082                	ret

000000000000559c <link>:
.global link
link:
 li a7, SYS_link
    559c:	48cd                	li	a7,19
 ecall
    559e:	00000073          	ecall
 ret
    55a2:	8082                	ret

00000000000055a4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    55a4:	48d1                	li	a7,20
 ecall
    55a6:	00000073          	ecall
 ret
    55aa:	8082                	ret

00000000000055ac <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    55ac:	48a5                	li	a7,9
 ecall
    55ae:	00000073          	ecall
 ret
    55b2:	8082                	ret

00000000000055b4 <dup>:
.global dup
dup:
 li a7, SYS_dup
    55b4:	48a9                	li	a7,10
 ecall
    55b6:	00000073          	ecall
 ret
    55ba:	8082                	ret

00000000000055bc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    55bc:	48ad                	li	a7,11
 ecall
    55be:	00000073          	ecall
 ret
    55c2:	8082                	ret

00000000000055c4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    55c4:	48b1                	li	a7,12
 ecall
    55c6:	00000073          	ecall
 ret
    55ca:	8082                	ret

00000000000055cc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    55cc:	48b5                	li	a7,13
 ecall
    55ce:	00000073          	ecall
 ret
    55d2:	8082                	ret

00000000000055d4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    55d4:	48b9                	li	a7,14
 ecall
    55d6:	00000073          	ecall
 ret
    55da:	8082                	ret

00000000000055dc <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    55dc:	1101                	addi	sp,sp,-32
    55de:	ec06                	sd	ra,24(sp)
    55e0:	e822                	sd	s0,16(sp)
    55e2:	1000                	addi	s0,sp,32
    55e4:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    55e8:	4605                	li	a2,1
    55ea:	fef40593          	addi	a1,s0,-17
    55ee:	00000097          	auipc	ra,0x0
    55f2:	f6e080e7          	jalr	-146(ra) # 555c <write>
}
    55f6:	60e2                	ld	ra,24(sp)
    55f8:	6442                	ld	s0,16(sp)
    55fa:	6105                	addi	sp,sp,32
    55fc:	8082                	ret

00000000000055fe <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    55fe:	7139                	addi	sp,sp,-64
    5600:	fc06                	sd	ra,56(sp)
    5602:	f822                	sd	s0,48(sp)
    5604:	f426                	sd	s1,40(sp)
    5606:	f04a                	sd	s2,32(sp)
    5608:	ec4e                	sd	s3,24(sp)
    560a:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    560c:	c299                	beqz	a3,5612 <printint+0x14>
    560e:	0005cd63          	bltz	a1,5628 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    5612:	2581                	sext.w	a1,a1
  neg = 0;
    5614:	4301                	li	t1,0
    5616:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
    561a:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
    561c:	2601                	sext.w	a2,a2
    561e:	00003897          	auipc	a7,0x3
    5622:	b4a88893          	addi	a7,a7,-1206 # 8168 <digits>
    5626:	a801                	j	5636 <printint+0x38>
    x = -xx;
    5628:	40b005bb          	negw	a1,a1
    562c:	2581                	sext.w	a1,a1
    neg = 1;
    562e:	4305                	li	t1,1
    x = -xx;
    5630:	b7dd                	j	5616 <printint+0x18>
  }while((x /= base) != 0);
    5632:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
    5634:	8836                	mv	a6,a3
    5636:	0018069b          	addiw	a3,a6,1
    563a:	02c5f7bb          	remuw	a5,a1,a2
    563e:	1782                	slli	a5,a5,0x20
    5640:	9381                	srli	a5,a5,0x20
    5642:	97c6                	add	a5,a5,a7
    5644:	0007c783          	lbu	a5,0(a5)
    5648:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
    564c:	0705                	addi	a4,a4,1
    564e:	02c5d7bb          	divuw	a5,a1,a2
    5652:	fec5f0e3          	bleu	a2,a1,5632 <printint+0x34>
  if(neg)
    5656:	00030b63          	beqz	t1,566c <printint+0x6e>
    buf[i++] = '-';
    565a:	fd040793          	addi	a5,s0,-48
    565e:	96be                	add	a3,a3,a5
    5660:	02d00793          	li	a5,45
    5664:	fef68823          	sb	a5,-16(a3) # ff0 <bigdir+0x74>
    5668:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
    566c:	02d05963          	blez	a3,569e <printint+0xa0>
    5670:	89aa                	mv	s3,a0
    5672:	fc040793          	addi	a5,s0,-64
    5676:	00d784b3          	add	s1,a5,a3
    567a:	fff78913          	addi	s2,a5,-1
    567e:	9936                	add	s2,s2,a3
    5680:	36fd                	addiw	a3,a3,-1
    5682:	1682                	slli	a3,a3,0x20
    5684:	9281                	srli	a3,a3,0x20
    5686:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
    568a:	fff4c583          	lbu	a1,-1(s1)
    568e:	854e                	mv	a0,s3
    5690:	00000097          	auipc	ra,0x0
    5694:	f4c080e7          	jalr	-180(ra) # 55dc <putc>
  while(--i >= 0)
    5698:	14fd                	addi	s1,s1,-1
    569a:	ff2498e3          	bne	s1,s2,568a <printint+0x8c>
}
    569e:	70e2                	ld	ra,56(sp)
    56a0:	7442                	ld	s0,48(sp)
    56a2:	74a2                	ld	s1,40(sp)
    56a4:	7902                	ld	s2,32(sp)
    56a6:	69e2                	ld	s3,24(sp)
    56a8:	6121                	addi	sp,sp,64
    56aa:	8082                	ret

00000000000056ac <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    56ac:	7119                	addi	sp,sp,-128
    56ae:	fc86                	sd	ra,120(sp)
    56b0:	f8a2                	sd	s0,112(sp)
    56b2:	f4a6                	sd	s1,104(sp)
    56b4:	f0ca                	sd	s2,96(sp)
    56b6:	ecce                	sd	s3,88(sp)
    56b8:	e8d2                	sd	s4,80(sp)
    56ba:	e4d6                	sd	s5,72(sp)
    56bc:	e0da                	sd	s6,64(sp)
    56be:	fc5e                	sd	s7,56(sp)
    56c0:	f862                	sd	s8,48(sp)
    56c2:	f466                	sd	s9,40(sp)
    56c4:	f06a                	sd	s10,32(sp)
    56c6:	ec6e                	sd	s11,24(sp)
    56c8:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    56ca:	0005c483          	lbu	s1,0(a1)
    56ce:	18048d63          	beqz	s1,5868 <vprintf+0x1bc>
    56d2:	8aaa                	mv	s5,a0
    56d4:	8b32                	mv	s6,a2
    56d6:	00158913          	addi	s2,a1,1
  state = 0;
    56da:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    56dc:	02500a13          	li	s4,37
      if(c == 'd'){
    56e0:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    56e4:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    56e8:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    56ec:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    56f0:	00003b97          	auipc	s7,0x3
    56f4:	a78b8b93          	addi	s7,s7,-1416 # 8168 <digits>
    56f8:	a839                	j	5716 <vprintf+0x6a>
        putc(fd, c);
    56fa:	85a6                	mv	a1,s1
    56fc:	8556                	mv	a0,s5
    56fe:	00000097          	auipc	ra,0x0
    5702:	ede080e7          	jalr	-290(ra) # 55dc <putc>
    5706:	a019                	j	570c <vprintf+0x60>
    } else if(state == '%'){
    5708:	01498f63          	beq	s3,s4,5726 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    570c:	0905                	addi	s2,s2,1
    570e:	fff94483          	lbu	s1,-1(s2)
    5712:	14048b63          	beqz	s1,5868 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
    5716:	0004879b          	sext.w	a5,s1
    if(state == 0){
    571a:	fe0997e3          	bnez	s3,5708 <vprintf+0x5c>
      if(c == '%'){
    571e:	fd479ee3          	bne	a5,s4,56fa <vprintf+0x4e>
        state = '%';
    5722:	89be                	mv	s3,a5
    5724:	b7e5                	j	570c <vprintf+0x60>
      if(c == 'd'){
    5726:	05878063          	beq	a5,s8,5766 <vprintf+0xba>
      } else if(c == 'l') {
    572a:	05978c63          	beq	a5,s9,5782 <vprintf+0xd6>
      } else if(c == 'x') {
    572e:	07a78863          	beq	a5,s10,579e <vprintf+0xf2>
      } else if(c == 'p') {
    5732:	09b78463          	beq	a5,s11,57ba <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5736:	07300713          	li	a4,115
    573a:	0ce78563          	beq	a5,a4,5804 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    573e:	06300713          	li	a4,99
    5742:	0ee78c63          	beq	a5,a4,583a <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5746:	11478663          	beq	a5,s4,5852 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    574a:	85d2                	mv	a1,s4
    574c:	8556                	mv	a0,s5
    574e:	00000097          	auipc	ra,0x0
    5752:	e8e080e7          	jalr	-370(ra) # 55dc <putc>
        putc(fd, c);
    5756:	85a6                	mv	a1,s1
    5758:	8556                	mv	a0,s5
    575a:	00000097          	auipc	ra,0x0
    575e:	e82080e7          	jalr	-382(ra) # 55dc <putc>
      }
      state = 0;
    5762:	4981                	li	s3,0
    5764:	b765                	j	570c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5766:	008b0493          	addi	s1,s6,8
    576a:	4685                	li	a3,1
    576c:	4629                	li	a2,10
    576e:	000b2583          	lw	a1,0(s6)
    5772:	8556                	mv	a0,s5
    5774:	00000097          	auipc	ra,0x0
    5778:	e8a080e7          	jalr	-374(ra) # 55fe <printint>
    577c:	8b26                	mv	s6,s1
      state = 0;
    577e:	4981                	li	s3,0
    5780:	b771                	j	570c <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5782:	008b0493          	addi	s1,s6,8
    5786:	4681                	li	a3,0
    5788:	4629                	li	a2,10
    578a:	000b2583          	lw	a1,0(s6)
    578e:	8556                	mv	a0,s5
    5790:	00000097          	auipc	ra,0x0
    5794:	e6e080e7          	jalr	-402(ra) # 55fe <printint>
    5798:	8b26                	mv	s6,s1
      state = 0;
    579a:	4981                	li	s3,0
    579c:	bf85                	j	570c <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    579e:	008b0493          	addi	s1,s6,8
    57a2:	4681                	li	a3,0
    57a4:	4641                	li	a2,16
    57a6:	000b2583          	lw	a1,0(s6)
    57aa:	8556                	mv	a0,s5
    57ac:	00000097          	auipc	ra,0x0
    57b0:	e52080e7          	jalr	-430(ra) # 55fe <printint>
    57b4:	8b26                	mv	s6,s1
      state = 0;
    57b6:	4981                	li	s3,0
    57b8:	bf91                	j	570c <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    57ba:	008b0793          	addi	a5,s6,8
    57be:	f8f43423          	sd	a5,-120(s0)
    57c2:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    57c6:	03000593          	li	a1,48
    57ca:	8556                	mv	a0,s5
    57cc:	00000097          	auipc	ra,0x0
    57d0:	e10080e7          	jalr	-496(ra) # 55dc <putc>
  putc(fd, 'x');
    57d4:	85ea                	mv	a1,s10
    57d6:	8556                	mv	a0,s5
    57d8:	00000097          	auipc	ra,0x0
    57dc:	e04080e7          	jalr	-508(ra) # 55dc <putc>
    57e0:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    57e2:	03c9d793          	srli	a5,s3,0x3c
    57e6:	97de                	add	a5,a5,s7
    57e8:	0007c583          	lbu	a1,0(a5)
    57ec:	8556                	mv	a0,s5
    57ee:	00000097          	auipc	ra,0x0
    57f2:	dee080e7          	jalr	-530(ra) # 55dc <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    57f6:	0992                	slli	s3,s3,0x4
    57f8:	34fd                	addiw	s1,s1,-1
    57fa:	f4e5                	bnez	s1,57e2 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    57fc:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    5800:	4981                	li	s3,0
    5802:	b729                	j	570c <vprintf+0x60>
        s = va_arg(ap, char*);
    5804:	008b0993          	addi	s3,s6,8
    5808:	000b3483          	ld	s1,0(s6)
        if(s == 0)
    580c:	c085                	beqz	s1,582c <vprintf+0x180>
        while(*s != 0){
    580e:	0004c583          	lbu	a1,0(s1)
    5812:	c9a1                	beqz	a1,5862 <vprintf+0x1b6>
          putc(fd, *s);
    5814:	8556                	mv	a0,s5
    5816:	00000097          	auipc	ra,0x0
    581a:	dc6080e7          	jalr	-570(ra) # 55dc <putc>
          s++;
    581e:	0485                	addi	s1,s1,1
        while(*s != 0){
    5820:	0004c583          	lbu	a1,0(s1)
    5824:	f9e5                	bnez	a1,5814 <vprintf+0x168>
        s = va_arg(ap, char*);
    5826:	8b4e                	mv	s6,s3
      state = 0;
    5828:	4981                	li	s3,0
    582a:	b5cd                	j	570c <vprintf+0x60>
          s = "(null)";
    582c:	00003497          	auipc	s1,0x3
    5830:	95448493          	addi	s1,s1,-1708 # 8180 <digits+0x18>
        while(*s != 0){
    5834:	02800593          	li	a1,40
    5838:	bff1                	j	5814 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
    583a:	008b0493          	addi	s1,s6,8
    583e:	000b4583          	lbu	a1,0(s6)
    5842:	8556                	mv	a0,s5
    5844:	00000097          	auipc	ra,0x0
    5848:	d98080e7          	jalr	-616(ra) # 55dc <putc>
    584c:	8b26                	mv	s6,s1
      state = 0;
    584e:	4981                	li	s3,0
    5850:	bd75                	j	570c <vprintf+0x60>
        putc(fd, c);
    5852:	85d2                	mv	a1,s4
    5854:	8556                	mv	a0,s5
    5856:	00000097          	auipc	ra,0x0
    585a:	d86080e7          	jalr	-634(ra) # 55dc <putc>
      state = 0;
    585e:	4981                	li	s3,0
    5860:	b575                	j	570c <vprintf+0x60>
        s = va_arg(ap, char*);
    5862:	8b4e                	mv	s6,s3
      state = 0;
    5864:	4981                	li	s3,0
    5866:	b55d                	j	570c <vprintf+0x60>
    }
  }
}
    5868:	70e6                	ld	ra,120(sp)
    586a:	7446                	ld	s0,112(sp)
    586c:	74a6                	ld	s1,104(sp)
    586e:	7906                	ld	s2,96(sp)
    5870:	69e6                	ld	s3,88(sp)
    5872:	6a46                	ld	s4,80(sp)
    5874:	6aa6                	ld	s5,72(sp)
    5876:	6b06                	ld	s6,64(sp)
    5878:	7be2                	ld	s7,56(sp)
    587a:	7c42                	ld	s8,48(sp)
    587c:	7ca2                	ld	s9,40(sp)
    587e:	7d02                	ld	s10,32(sp)
    5880:	6de2                	ld	s11,24(sp)
    5882:	6109                	addi	sp,sp,128
    5884:	8082                	ret

0000000000005886 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5886:	715d                	addi	sp,sp,-80
    5888:	ec06                	sd	ra,24(sp)
    588a:	e822                	sd	s0,16(sp)
    588c:	1000                	addi	s0,sp,32
    588e:	e010                	sd	a2,0(s0)
    5890:	e414                	sd	a3,8(s0)
    5892:	e818                	sd	a4,16(s0)
    5894:	ec1c                	sd	a5,24(s0)
    5896:	03043023          	sd	a6,32(s0)
    589a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    589e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    58a2:	8622                	mv	a2,s0
    58a4:	00000097          	auipc	ra,0x0
    58a8:	e08080e7          	jalr	-504(ra) # 56ac <vprintf>
}
    58ac:	60e2                	ld	ra,24(sp)
    58ae:	6442                	ld	s0,16(sp)
    58b0:	6161                	addi	sp,sp,80
    58b2:	8082                	ret

00000000000058b4 <printf>:

void
printf(const char *fmt, ...)
{
    58b4:	711d                	addi	sp,sp,-96
    58b6:	ec06                	sd	ra,24(sp)
    58b8:	e822                	sd	s0,16(sp)
    58ba:	1000                	addi	s0,sp,32
    58bc:	e40c                	sd	a1,8(s0)
    58be:	e810                	sd	a2,16(s0)
    58c0:	ec14                	sd	a3,24(s0)
    58c2:	f018                	sd	a4,32(s0)
    58c4:	f41c                	sd	a5,40(s0)
    58c6:	03043823          	sd	a6,48(s0)
    58ca:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    58ce:	00840613          	addi	a2,s0,8
    58d2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    58d6:	85aa                	mv	a1,a0
    58d8:	4505                	li	a0,1
    58da:	00000097          	auipc	ra,0x0
    58de:	dd2080e7          	jalr	-558(ra) # 56ac <vprintf>
}
    58e2:	60e2                	ld	ra,24(sp)
    58e4:	6442                	ld	s0,16(sp)
    58e6:	6125                	addi	sp,sp,96
    58e8:	8082                	ret

00000000000058ea <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    58ea:	1141                	addi	sp,sp,-16
    58ec:	e422                	sd	s0,8(sp)
    58ee:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    58f0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    58f4:	00003797          	auipc	a5,0x3
    58f8:	8ac78793          	addi	a5,a5,-1876 # 81a0 <freep>
    58fc:	639c                	ld	a5,0(a5)
    58fe:	a805                	j	592e <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    5900:	4618                	lw	a4,8(a2)
    5902:	9db9                	addw	a1,a1,a4
    5904:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    5908:	6398                	ld	a4,0(a5)
    590a:	6318                	ld	a4,0(a4)
    590c:	fee53823          	sd	a4,-16(a0)
    5910:	a091                	j	5954 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    5912:	ff852703          	lw	a4,-8(a0)
    5916:	9e39                	addw	a2,a2,a4
    5918:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    591a:	ff053703          	ld	a4,-16(a0)
    591e:	e398                	sd	a4,0(a5)
    5920:	a099                	j	5966 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5922:	6398                	ld	a4,0(a5)
    5924:	00e7e463          	bltu	a5,a4,592c <free+0x42>
    5928:	00e6ea63          	bltu	a3,a4,593c <free+0x52>
{
    592c:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    592e:	fed7fae3          	bleu	a3,a5,5922 <free+0x38>
    5932:	6398                	ld	a4,0(a5)
    5934:	00e6e463          	bltu	a3,a4,593c <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5938:	fee7eae3          	bltu	a5,a4,592c <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
    593c:	ff852583          	lw	a1,-8(a0)
    5940:	6390                	ld	a2,0(a5)
    5942:	02059713          	slli	a4,a1,0x20
    5946:	9301                	srli	a4,a4,0x20
    5948:	0712                	slli	a4,a4,0x4
    594a:	9736                	add	a4,a4,a3
    594c:	fae60ae3          	beq	a2,a4,5900 <free+0x16>
    bp->s.ptr = p->s.ptr;
    5950:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5954:	4790                	lw	a2,8(a5)
    5956:	02061713          	slli	a4,a2,0x20
    595a:	9301                	srli	a4,a4,0x20
    595c:	0712                	slli	a4,a4,0x4
    595e:	973e                	add	a4,a4,a5
    5960:	fae689e3          	beq	a3,a4,5912 <free+0x28>
  } else
    p->s.ptr = bp;
    5964:	e394                	sd	a3,0(a5)
  freep = p;
    5966:	00003717          	auipc	a4,0x3
    596a:	82f73d23          	sd	a5,-1990(a4) # 81a0 <freep>
}
    596e:	6422                	ld	s0,8(sp)
    5970:	0141                	addi	sp,sp,16
    5972:	8082                	ret

0000000000005974 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5974:	7139                	addi	sp,sp,-64
    5976:	fc06                	sd	ra,56(sp)
    5978:	f822                	sd	s0,48(sp)
    597a:	f426                	sd	s1,40(sp)
    597c:	f04a                	sd	s2,32(sp)
    597e:	ec4e                	sd	s3,24(sp)
    5980:	e852                	sd	s4,16(sp)
    5982:	e456                	sd	s5,8(sp)
    5984:	e05a                	sd	s6,0(sp)
    5986:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5988:	02051993          	slli	s3,a0,0x20
    598c:	0209d993          	srli	s3,s3,0x20
    5990:	09bd                	addi	s3,s3,15
    5992:	0049d993          	srli	s3,s3,0x4
    5996:	2985                	addiw	s3,s3,1
    5998:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
    599c:	00003797          	auipc	a5,0x3
    59a0:	80478793          	addi	a5,a5,-2044 # 81a0 <freep>
    59a4:	6388                	ld	a0,0(a5)
    59a6:	c515                	beqz	a0,59d2 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    59a8:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    59aa:	4798                	lw	a4,8(a5)
    59ac:	03277f63          	bleu	s2,a4,59ea <malloc+0x76>
    59b0:	8a4e                	mv	s4,s3
    59b2:	0009871b          	sext.w	a4,s3
    59b6:	6685                	lui	a3,0x1
    59b8:	00d77363          	bleu	a3,a4,59be <malloc+0x4a>
    59bc:	6a05                	lui	s4,0x1
    59be:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
    59c2:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    59c6:	00002497          	auipc	s1,0x2
    59ca:	7da48493          	addi	s1,s1,2010 # 81a0 <freep>
  if(p == (char*)-1)
    59ce:	5b7d                	li	s6,-1
    59d0:	a885                	j	5a40 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
    59d2:	00009797          	auipc	a5,0x9
    59d6:	fee78793          	addi	a5,a5,-18 # e9c0 <base>
    59da:	00002717          	auipc	a4,0x2
    59de:	7cf73323          	sd	a5,1990(a4) # 81a0 <freep>
    59e2:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    59e4:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    59e8:	b7e1                	j	59b0 <malloc+0x3c>
      if(p->s.size == nunits)
    59ea:	02e90b63          	beq	s2,a4,5a20 <malloc+0xac>
        p->s.size -= nunits;
    59ee:	4137073b          	subw	a4,a4,s3
    59f2:	c798                	sw	a4,8(a5)
        p += p->s.size;
    59f4:	1702                	slli	a4,a4,0x20
    59f6:	9301                	srli	a4,a4,0x20
    59f8:	0712                	slli	a4,a4,0x4
    59fa:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    59fc:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    5a00:	00002717          	auipc	a4,0x2
    5a04:	7aa73023          	sd	a0,1952(a4) # 81a0 <freep>
      return (void*)(p + 1);
    5a08:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    5a0c:	70e2                	ld	ra,56(sp)
    5a0e:	7442                	ld	s0,48(sp)
    5a10:	74a2                	ld	s1,40(sp)
    5a12:	7902                	ld	s2,32(sp)
    5a14:	69e2                	ld	s3,24(sp)
    5a16:	6a42                	ld	s4,16(sp)
    5a18:	6aa2                	ld	s5,8(sp)
    5a1a:	6b02                	ld	s6,0(sp)
    5a1c:	6121                	addi	sp,sp,64
    5a1e:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    5a20:	6398                	ld	a4,0(a5)
    5a22:	e118                	sd	a4,0(a0)
    5a24:	bff1                	j	5a00 <malloc+0x8c>
  hp->s.size = nu;
    5a26:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
    5a2a:	0541                	addi	a0,a0,16
    5a2c:	00000097          	auipc	ra,0x0
    5a30:	ebe080e7          	jalr	-322(ra) # 58ea <free>
  return freep;
    5a34:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    5a36:	d979                	beqz	a0,5a0c <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5a38:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5a3a:	4798                	lw	a4,8(a5)
    5a3c:	fb2777e3          	bleu	s2,a4,59ea <malloc+0x76>
    if(p == freep)
    5a40:	6098                	ld	a4,0(s1)
    5a42:	853e                	mv	a0,a5
    5a44:	fef71ae3          	bne	a4,a5,5a38 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
    5a48:	8552                	mv	a0,s4
    5a4a:	00000097          	auipc	ra,0x0
    5a4e:	b7a080e7          	jalr	-1158(ra) # 55c4 <sbrk>
  if(p == (char*)-1)
    5a52:	fd651ae3          	bne	a0,s6,5a26 <malloc+0xb2>
        return 0;
    5a56:	4501                	li	a0,0
    5a58:	bf55                	j	5a0c <malloc+0x98>
