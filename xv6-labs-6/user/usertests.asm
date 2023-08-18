
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
      14:	54a080e7          	jalr	1354(ra) # 555a <open>
    if(fd >= 0){
      18:	02055063          	bgez	a0,38 <copyinstr1+0x38>
    int fd = open((char *)addr, O_CREATE|O_WRONLY);
      1c:	20100593          	li	a1,513
      20:	557d                	li	a0,-1
      22:	00005097          	auipc	ra,0x5
      26:	538080e7          	jalr	1336(ra) # 555a <open>
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
      42:	dba50513          	addi	a0,a0,-582 # 5df8 <malloc+0x4a6>
      46:	00006097          	auipc	ra,0x6
      4a:	84c080e7          	jalr	-1972(ra) # 5892 <printf>
      exit(1);
      4e:	4505                	li	a0,1
      50:	00005097          	auipc	ra,0x5
      54:	4ca080e7          	jalr	1226(ra) # 551a <exit>

0000000000000058 <bsstest>:
bsstest(char *s)
{
  int i;

  for(i = 0; i < sizeof(uninit); i++){
    if(uninit[i] != '\0'){
      58:	00009797          	auipc	a5,0x9
      5c:	2107c783          	lbu	a5,528(a5) # 9268 <uninit>
      60:	e385                	bnez	a5,80 <bsstest+0x28>
      62:	00009797          	auipc	a5,0x9
      66:	20778793          	addi	a5,a5,519 # 9269 <uninit+0x1>
      6a:	0000c697          	auipc	a3,0xc
      6e:	90e68693          	addi	a3,a3,-1778 # b978 <buf>
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
      8e:	d8e50513          	addi	a0,a0,-626 # 5e18 <malloc+0x4c6>
      92:	00006097          	auipc	ra,0x6
      96:	800080e7          	jalr	-2048(ra) # 5892 <printf>
      exit(1);
      9a:	4505                	li	a0,1
      9c:	00005097          	auipc	ra,0x5
      a0:	47e080e7          	jalr	1150(ra) # 551a <exit>

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
      b6:	d7e50513          	addi	a0,a0,-642 # 5e30 <malloc+0x4de>
      ba:	00005097          	auipc	ra,0x5
      be:	4a0080e7          	jalr	1184(ra) # 555a <open>
  if(fd < 0){
      c2:	02054663          	bltz	a0,ee <opentest+0x4a>
  close(fd);
      c6:	00005097          	auipc	ra,0x5
      ca:	47c080e7          	jalr	1148(ra) # 5542 <close>
  fd = open("doesnotexist", 0);
      ce:	4581                	li	a1,0
      d0:	00006517          	auipc	a0,0x6
      d4:	d8050513          	addi	a0,a0,-640 # 5e50 <malloc+0x4fe>
      d8:	00005097          	auipc	ra,0x5
      dc:	482080e7          	jalr	1154(ra) # 555a <open>
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
      f4:	d4850513          	addi	a0,a0,-696 # 5e38 <malloc+0x4e6>
      f8:	00005097          	auipc	ra,0x5
      fc:	79a080e7          	jalr	1946(ra) # 5892 <printf>
    exit(1);
     100:	4505                	li	a0,1
     102:	00005097          	auipc	ra,0x5
     106:	418080e7          	jalr	1048(ra) # 551a <exit>
    printf("%s: open doesnotexist succeeded!\n", s);
     10a:	85a6                	mv	a1,s1
     10c:	00006517          	auipc	a0,0x6
     110:	d5450513          	addi	a0,a0,-684 # 5e60 <malloc+0x50e>
     114:	00005097          	auipc	ra,0x5
     118:	77e080e7          	jalr	1918(ra) # 5892 <printf>
    exit(1);
     11c:	4505                	li	a0,1
     11e:	00005097          	auipc	ra,0x5
     122:	3fc080e7          	jalr	1020(ra) # 551a <exit>

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
     13a:	d5250513          	addi	a0,a0,-686 # 5e88 <malloc+0x536>
     13e:	00005097          	auipc	ra,0x5
     142:	42c080e7          	jalr	1068(ra) # 556a <unlink>
  int fd1 = open("truncfile", O_CREATE|O_TRUNC|O_WRONLY);
     146:	60100593          	li	a1,1537
     14a:	00006517          	auipc	a0,0x6
     14e:	d3e50513          	addi	a0,a0,-706 # 5e88 <malloc+0x536>
     152:	00005097          	auipc	ra,0x5
     156:	408080e7          	jalr	1032(ra) # 555a <open>
     15a:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     15c:	4611                	li	a2,4
     15e:	00006597          	auipc	a1,0x6
     162:	d3a58593          	addi	a1,a1,-710 # 5e98 <malloc+0x546>
     166:	00005097          	auipc	ra,0x5
     16a:	3d4080e7          	jalr	980(ra) # 553a <write>
  int fd2 = open("truncfile", O_TRUNC|O_WRONLY);
     16e:	40100593          	li	a1,1025
     172:	00006517          	auipc	a0,0x6
     176:	d1650513          	addi	a0,a0,-746 # 5e88 <malloc+0x536>
     17a:	00005097          	auipc	ra,0x5
     17e:	3e0080e7          	jalr	992(ra) # 555a <open>
     182:	892a                	mv	s2,a0
  int n = write(fd1, "x", 1);
     184:	4605                	li	a2,1
     186:	00006597          	auipc	a1,0x6
     18a:	d1a58593          	addi	a1,a1,-742 # 5ea0 <malloc+0x54e>
     18e:	8526                	mv	a0,s1
     190:	00005097          	auipc	ra,0x5
     194:	3aa080e7          	jalr	938(ra) # 553a <write>
  if(n != -1){
     198:	57fd                	li	a5,-1
     19a:	02f51b63          	bne	a0,a5,1d0 <truncate2+0xaa>
  unlink("truncfile");
     19e:	00006517          	auipc	a0,0x6
     1a2:	cea50513          	addi	a0,a0,-790 # 5e88 <malloc+0x536>
     1a6:	00005097          	auipc	ra,0x5
     1aa:	3c4080e7          	jalr	964(ra) # 556a <unlink>
  close(fd1);
     1ae:	8526                	mv	a0,s1
     1b0:	00005097          	auipc	ra,0x5
     1b4:	392080e7          	jalr	914(ra) # 5542 <close>
  close(fd2);
     1b8:	854a                	mv	a0,s2
     1ba:	00005097          	auipc	ra,0x5
     1be:	388080e7          	jalr	904(ra) # 5542 <close>
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
     1d8:	cd450513          	addi	a0,a0,-812 # 5ea8 <malloc+0x556>
     1dc:	00005097          	auipc	ra,0x5
     1e0:	6b6080e7          	jalr	1718(ra) # 5892 <printf>
    exit(1);
     1e4:	4505                	li	a0,1
     1e6:	00005097          	auipc	ra,0x5
     1ea:	334080e7          	jalr	820(ra) # 551a <exit>

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
     200:	f5478793          	addi	a5,a5,-172 # 8150 <_edata>
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
     228:	336080e7          	jalr	822(ra) # 555a <open>
    close(fd);
     22c:	00005097          	auipc	ra,0x5
     230:	316080e7          	jalr	790(ra) # 5542 <close>
  for(i = 0; i < N; i++){
     234:	2485                	addiw	s1,s1,1
     236:	0ff4f493          	andi	s1,s1,255
     23a:	ff3490e3          	bne	s1,s3,21a <createtest+0x2c>
  name[0] = 'a';
     23e:	00008797          	auipc	a5,0x8
     242:	f1278793          	addi	a5,a5,-238 # 8150 <_edata>
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
     266:	308080e7          	jalr	776(ra) # 556a <unlink>
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
     29e:	c3650513          	addi	a0,a0,-970 # 5ed0 <malloc+0x57e>
     2a2:	00005097          	auipc	ra,0x5
     2a6:	2c8080e7          	jalr	712(ra) # 556a <unlink>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2aa:	1f300493          	li	s1,499
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2ae:	00006a17          	auipc	s4,0x6
     2b2:	c22a0a13          	addi	s4,s4,-990 # 5ed0 <malloc+0x57e>
      int cc = write(fd, buf, sz);
     2b6:	0000b997          	auipc	s3,0xb
     2ba:	6c298993          	addi	s3,s3,1730 # b978 <buf>
  for(sz = 499; sz < (MAXOPBLOCKS+2)*BSIZE; sz += 471){
     2be:	6b0d                	lui	s6,0x3
     2c0:	1c9b0b13          	addi	s6,s6,457 # 31c9 <subdir+0x27d>
    fd = open("bigwrite", O_CREATE | O_RDWR);
     2c4:	20200593          	li	a1,514
     2c8:	8552                	mv	a0,s4
     2ca:	00005097          	auipc	ra,0x5
     2ce:	290080e7          	jalr	656(ra) # 555a <open>
     2d2:	892a                	mv	s2,a0
    if(fd < 0){
     2d4:	04054d63          	bltz	a0,32e <bigwrite+0xac>
      int cc = write(fd, buf, sz);
     2d8:	8626                	mv	a2,s1
     2da:	85ce                	mv	a1,s3
     2dc:	00005097          	auipc	ra,0x5
     2e0:	25e080e7          	jalr	606(ra) # 553a <write>
     2e4:	8aaa                	mv	s5,a0
      if(cc != sz){
     2e6:	06a49463          	bne	s1,a0,34e <bigwrite+0xcc>
      int cc = write(fd, buf, sz);
     2ea:	8626                	mv	a2,s1
     2ec:	85ce                	mv	a1,s3
     2ee:	854a                	mv	a0,s2
     2f0:	00005097          	auipc	ra,0x5
     2f4:	24a080e7          	jalr	586(ra) # 553a <write>
      if(cc != sz){
     2f8:	04951963          	bne	a0,s1,34a <bigwrite+0xc8>
    close(fd);
     2fc:	854a                	mv	a0,s2
     2fe:	00005097          	auipc	ra,0x5
     302:	244080e7          	jalr	580(ra) # 5542 <close>
    unlink("bigwrite");
     306:	8552                	mv	a0,s4
     308:	00005097          	auipc	ra,0x5
     30c:	262080e7          	jalr	610(ra) # 556a <unlink>
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
     334:	bb050513          	addi	a0,a0,-1104 # 5ee0 <malloc+0x58e>
     338:	00005097          	auipc	ra,0x5
     33c:	55a080e7          	jalr	1370(ra) # 5892 <printf>
      exit(1);
     340:	4505                	li	a0,1
     342:	00005097          	auipc	ra,0x5
     346:	1d8080e7          	jalr	472(ra) # 551a <exit>
     34a:	84d6                	mv	s1,s5
      int cc = write(fd, buf, sz);
     34c:	8aaa                	mv	s5,a0
        printf("%s: write(%d) ret %d\n", s, sz, cc);
     34e:	86d6                	mv	a3,s5
     350:	8626                	mv	a2,s1
     352:	85de                	mv	a1,s7
     354:	00006517          	auipc	a0,0x6
     358:	bac50513          	addi	a0,a0,-1108 # 5f00 <malloc+0x5ae>
     35c:	00005097          	auipc	ra,0x5
     360:	536080e7          	jalr	1334(ra) # 5892 <printf>
        exit(1);
     364:	4505                	li	a0,1
     366:	00005097          	auipc	ra,0x5
     36a:	1b4080e7          	jalr	436(ra) # 551a <exit>

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
     39a:	b82a0a13          	addi	s4,s4,-1150 # 5f18 <malloc+0x5c6>
    uint64 addr = addrs[ai];
     39e:	0004b903          	ld	s2,0(s1)
    int fd = open("copyin1", O_CREATE|O_WRONLY);
     3a2:	20100593          	li	a1,513
     3a6:	8552                	mv	a0,s4
     3a8:	00005097          	auipc	ra,0x5
     3ac:	1b2080e7          	jalr	434(ra) # 555a <open>
     3b0:	89aa                	mv	s3,a0
    if(fd < 0){
     3b2:	08054763          	bltz	a0,440 <copyin+0xd2>
    int n = write(fd, (void*)addr, 8192);
     3b6:	6609                	lui	a2,0x2
     3b8:	85ca                	mv	a1,s2
     3ba:	00005097          	auipc	ra,0x5
     3be:	180080e7          	jalr	384(ra) # 553a <write>
    if(n >= 0){
     3c2:	08055c63          	bgez	a0,45a <copyin+0xec>
    close(fd);
     3c6:	854e                	mv	a0,s3
     3c8:	00005097          	auipc	ra,0x5
     3cc:	17a080e7          	jalr	378(ra) # 5542 <close>
    unlink("copyin1");
     3d0:	8552                	mv	a0,s4
     3d2:	00005097          	auipc	ra,0x5
     3d6:	198080e7          	jalr	408(ra) # 556a <unlink>
    n = write(1, (char*)addr, 8192);
     3da:	6609                	lui	a2,0x2
     3dc:	85ca                	mv	a1,s2
     3de:	4505                	li	a0,1
     3e0:	00005097          	auipc	ra,0x5
     3e4:	15a080e7          	jalr	346(ra) # 553a <write>
    if(n > 0){
     3e8:	08a04863          	bgtz	a0,478 <copyin+0x10a>
    if(pipe(fds) < 0){
     3ec:	fa840513          	addi	a0,s0,-88
     3f0:	00005097          	auipc	ra,0x5
     3f4:	13a080e7          	jalr	314(ra) # 552a <pipe>
     3f8:	08054f63          	bltz	a0,496 <copyin+0x128>
    n = write(fds[1], (char*)addr, 8192);
     3fc:	6609                	lui	a2,0x2
     3fe:	85ca                	mv	a1,s2
     400:	fac42503          	lw	a0,-84(s0)
     404:	00005097          	auipc	ra,0x5
     408:	136080e7          	jalr	310(ra) # 553a <write>
    if(n > 0){
     40c:	0aa04263          	bgtz	a0,4b0 <copyin+0x142>
    close(fds[0]);
     410:	fa842503          	lw	a0,-88(s0)
     414:	00005097          	auipc	ra,0x5
     418:	12e080e7          	jalr	302(ra) # 5542 <close>
    close(fds[1]);
     41c:	fac42503          	lw	a0,-84(s0)
     420:	00005097          	auipc	ra,0x5
     424:	122080e7          	jalr	290(ra) # 5542 <close>
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
     444:	ae050513          	addi	a0,a0,-1312 # 5f20 <malloc+0x5ce>
     448:	00005097          	auipc	ra,0x5
     44c:	44a080e7          	jalr	1098(ra) # 5892 <printf>
      exit(1);
     450:	4505                	li	a0,1
     452:	00005097          	auipc	ra,0x5
     456:	0c8080e7          	jalr	200(ra) # 551a <exit>
      printf("write(fd, %p, 8192) returned %d, not -1\n", addr, n);
     45a:	862a                	mv	a2,a0
     45c:	85ca                	mv	a1,s2
     45e:	00006517          	auipc	a0,0x6
     462:	ada50513          	addi	a0,a0,-1318 # 5f38 <malloc+0x5e6>
     466:	00005097          	auipc	ra,0x5
     46a:	42c080e7          	jalr	1068(ra) # 5892 <printf>
      exit(1);
     46e:	4505                	li	a0,1
     470:	00005097          	auipc	ra,0x5
     474:	0aa080e7          	jalr	170(ra) # 551a <exit>
      printf("write(1, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     478:	862a                	mv	a2,a0
     47a:	85ca                	mv	a1,s2
     47c:	00006517          	auipc	a0,0x6
     480:	aec50513          	addi	a0,a0,-1300 # 5f68 <malloc+0x616>
     484:	00005097          	auipc	ra,0x5
     488:	40e080e7          	jalr	1038(ra) # 5892 <printf>
      exit(1);
     48c:	4505                	li	a0,1
     48e:	00005097          	auipc	ra,0x5
     492:	08c080e7          	jalr	140(ra) # 551a <exit>
      printf("pipe() failed\n");
     496:	00006517          	auipc	a0,0x6
     49a:	b0250513          	addi	a0,a0,-1278 # 5f98 <malloc+0x646>
     49e:	00005097          	auipc	ra,0x5
     4a2:	3f4080e7          	jalr	1012(ra) # 5892 <printf>
      exit(1);
     4a6:	4505                	li	a0,1
     4a8:	00005097          	auipc	ra,0x5
     4ac:	072080e7          	jalr	114(ra) # 551a <exit>
      printf("write(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     4b0:	862a                	mv	a2,a0
     4b2:	85ca                	mv	a1,s2
     4b4:	00006517          	auipc	a0,0x6
     4b8:	af450513          	addi	a0,a0,-1292 # 5fa8 <malloc+0x656>
     4bc:	00005097          	auipc	ra,0x5
     4c0:	3d6080e7          	jalr	982(ra) # 5892 <printf>
      exit(1);
     4c4:	4505                	li	a0,1
     4c6:	00005097          	auipc	ra,0x5
     4ca:	054080e7          	jalr	84(ra) # 551a <exit>

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
     4fc:	ae0a0a13          	addi	s4,s4,-1312 # 5fd8 <malloc+0x686>
    n = write(fds[1], "x", 1);
     500:	00006a97          	auipc	s5,0x6
     504:	9a0a8a93          	addi	s5,s5,-1632 # 5ea0 <malloc+0x54e>
    uint64 addr = addrs[ai];
     508:	0004b983          	ld	s3,0(s1)
    int fd = open("README", 0);
     50c:	4581                	li	a1,0
     50e:	8552                	mv	a0,s4
     510:	00005097          	auipc	ra,0x5
     514:	04a080e7          	jalr	74(ra) # 555a <open>
     518:	892a                	mv	s2,a0
    if(fd < 0){
     51a:	08054563          	bltz	a0,5a4 <copyout+0xd6>
    int n = read(fd, (void*)addr, 8192);
     51e:	6609                	lui	a2,0x2
     520:	85ce                	mv	a1,s3
     522:	00005097          	auipc	ra,0x5
     526:	010080e7          	jalr	16(ra) # 5532 <read>
    if(n > 0){
     52a:	08a04a63          	bgtz	a0,5be <copyout+0xf0>
    close(fd);
     52e:	854a                	mv	a0,s2
     530:	00005097          	auipc	ra,0x5
     534:	012080e7          	jalr	18(ra) # 5542 <close>
    if(pipe(fds) < 0){
     538:	fa840513          	addi	a0,s0,-88
     53c:	00005097          	auipc	ra,0x5
     540:	fee080e7          	jalr	-18(ra) # 552a <pipe>
     544:	08054c63          	bltz	a0,5dc <copyout+0x10e>
    n = write(fds[1], "x", 1);
     548:	4605                	li	a2,1
     54a:	85d6                	mv	a1,s5
     54c:	fac42503          	lw	a0,-84(s0)
     550:	00005097          	auipc	ra,0x5
     554:	fea080e7          	jalr	-22(ra) # 553a <write>
    if(n != 1){
     558:	4785                	li	a5,1
     55a:	08f51e63          	bne	a0,a5,5f6 <copyout+0x128>
    n = read(fds[0], (void*)addr, 8192);
     55e:	6609                	lui	a2,0x2
     560:	85ce                	mv	a1,s3
     562:	fa842503          	lw	a0,-88(s0)
     566:	00005097          	auipc	ra,0x5
     56a:	fcc080e7          	jalr	-52(ra) # 5532 <read>
    if(n > 0){
     56e:	0aa04163          	bgtz	a0,610 <copyout+0x142>
    close(fds[0]);
     572:	fa842503          	lw	a0,-88(s0)
     576:	00005097          	auipc	ra,0x5
     57a:	fcc080e7          	jalr	-52(ra) # 5542 <close>
    close(fds[1]);
     57e:	fac42503          	lw	a0,-84(s0)
     582:	00005097          	auipc	ra,0x5
     586:	fc0080e7          	jalr	-64(ra) # 5542 <close>
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
     5a8:	a3c50513          	addi	a0,a0,-1476 # 5fe0 <malloc+0x68e>
     5ac:	00005097          	auipc	ra,0x5
     5b0:	2e6080e7          	jalr	742(ra) # 5892 <printf>
      exit(1);
     5b4:	4505                	li	a0,1
     5b6:	00005097          	auipc	ra,0x5
     5ba:	f64080e7          	jalr	-156(ra) # 551a <exit>
      printf("read(fd, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     5be:	862a                	mv	a2,a0
     5c0:	85ce                	mv	a1,s3
     5c2:	00006517          	auipc	a0,0x6
     5c6:	a3650513          	addi	a0,a0,-1482 # 5ff8 <malloc+0x6a6>
     5ca:	00005097          	auipc	ra,0x5
     5ce:	2c8080e7          	jalr	712(ra) # 5892 <printf>
      exit(1);
     5d2:	4505                	li	a0,1
     5d4:	00005097          	auipc	ra,0x5
     5d8:	f46080e7          	jalr	-186(ra) # 551a <exit>
      printf("pipe() failed\n");
     5dc:	00006517          	auipc	a0,0x6
     5e0:	9bc50513          	addi	a0,a0,-1604 # 5f98 <malloc+0x646>
     5e4:	00005097          	auipc	ra,0x5
     5e8:	2ae080e7          	jalr	686(ra) # 5892 <printf>
      exit(1);
     5ec:	4505                	li	a0,1
     5ee:	00005097          	auipc	ra,0x5
     5f2:	f2c080e7          	jalr	-212(ra) # 551a <exit>
      printf("pipe write failed\n");
     5f6:	00006517          	auipc	a0,0x6
     5fa:	a3250513          	addi	a0,a0,-1486 # 6028 <malloc+0x6d6>
     5fe:	00005097          	auipc	ra,0x5
     602:	294080e7          	jalr	660(ra) # 5892 <printf>
      exit(1);
     606:	4505                	li	a0,1
     608:	00005097          	auipc	ra,0x5
     60c:	f12080e7          	jalr	-238(ra) # 551a <exit>
      printf("read(pipe, %p, 8192) returned %d, not -1 or 0\n", addr, n);
     610:	862a                	mv	a2,a0
     612:	85ce                	mv	a1,s3
     614:	00006517          	auipc	a0,0x6
     618:	a2c50513          	addi	a0,a0,-1492 # 6040 <malloc+0x6ee>
     61c:	00005097          	auipc	ra,0x5
     620:	276080e7          	jalr	630(ra) # 5892 <printf>
      exit(1);
     624:	4505                	li	a0,1
     626:	00005097          	auipc	ra,0x5
     62a:	ef4080e7          	jalr	-268(ra) # 551a <exit>

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
     646:	84650513          	addi	a0,a0,-1978 # 5e88 <malloc+0x536>
     64a:	00005097          	auipc	ra,0x5
     64e:	f20080e7          	jalr	-224(ra) # 556a <unlink>
  int fd1 = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
     652:	60100593          	li	a1,1537
     656:	00006517          	auipc	a0,0x6
     65a:	83250513          	addi	a0,a0,-1998 # 5e88 <malloc+0x536>
     65e:	00005097          	auipc	ra,0x5
     662:	efc080e7          	jalr	-260(ra) # 555a <open>
     666:	84aa                	mv	s1,a0
  write(fd1, "abcd", 4);
     668:	4611                	li	a2,4
     66a:	00006597          	auipc	a1,0x6
     66e:	82e58593          	addi	a1,a1,-2002 # 5e98 <malloc+0x546>
     672:	00005097          	auipc	ra,0x5
     676:	ec8080e7          	jalr	-312(ra) # 553a <write>
  close(fd1);
     67a:	8526                	mv	a0,s1
     67c:	00005097          	auipc	ra,0x5
     680:	ec6080e7          	jalr	-314(ra) # 5542 <close>
  int fd2 = open("truncfile", O_RDONLY);
     684:	4581                	li	a1,0
     686:	00006517          	auipc	a0,0x6
     68a:	80250513          	addi	a0,a0,-2046 # 5e88 <malloc+0x536>
     68e:	00005097          	auipc	ra,0x5
     692:	ecc080e7          	jalr	-308(ra) # 555a <open>
     696:	84aa                	mv	s1,a0
  int n = read(fd2, buf, sizeof(buf));
     698:	02000613          	li	a2,32
     69c:	fa040593          	addi	a1,s0,-96
     6a0:	00005097          	auipc	ra,0x5
     6a4:	e92080e7          	jalr	-366(ra) # 5532 <read>
  if(n != 4){
     6a8:	4791                	li	a5,4
     6aa:	0cf51e63          	bne	a0,a5,786 <truncate1+0x158>
  fd1 = open("truncfile", O_WRONLY|O_TRUNC);
     6ae:	40100593          	li	a1,1025
     6b2:	00005517          	auipc	a0,0x5
     6b6:	7d650513          	addi	a0,a0,2006 # 5e88 <malloc+0x536>
     6ba:	00005097          	auipc	ra,0x5
     6be:	ea0080e7          	jalr	-352(ra) # 555a <open>
     6c2:	89aa                	mv	s3,a0
  int fd3 = open("truncfile", O_RDONLY);
     6c4:	4581                	li	a1,0
     6c6:	00005517          	auipc	a0,0x5
     6ca:	7c250513          	addi	a0,a0,1986 # 5e88 <malloc+0x536>
     6ce:	00005097          	auipc	ra,0x5
     6d2:	e8c080e7          	jalr	-372(ra) # 555a <open>
     6d6:	892a                	mv	s2,a0
  n = read(fd3, buf, sizeof(buf));
     6d8:	02000613          	li	a2,32
     6dc:	fa040593          	addi	a1,s0,-96
     6e0:	00005097          	auipc	ra,0x5
     6e4:	e52080e7          	jalr	-430(ra) # 5532 <read>
     6e8:	8a2a                	mv	s4,a0
  if(n != 0){
     6ea:	ed4d                	bnez	a0,7a4 <truncate1+0x176>
  n = read(fd2, buf, sizeof(buf));
     6ec:	02000613          	li	a2,32
     6f0:	fa040593          	addi	a1,s0,-96
     6f4:	8526                	mv	a0,s1
     6f6:	00005097          	auipc	ra,0x5
     6fa:	e3c080e7          	jalr	-452(ra) # 5532 <read>
     6fe:	8a2a                	mv	s4,a0
  if(n != 0){
     700:	e971                	bnez	a0,7d4 <truncate1+0x1a6>
  write(fd1, "abcdef", 6);
     702:	4619                	li	a2,6
     704:	00006597          	auipc	a1,0x6
     708:	9cc58593          	addi	a1,a1,-1588 # 60d0 <malloc+0x77e>
     70c:	854e                	mv	a0,s3
     70e:	00005097          	auipc	ra,0x5
     712:	e2c080e7          	jalr	-468(ra) # 553a <write>
  n = read(fd3, buf, sizeof(buf));
     716:	02000613          	li	a2,32
     71a:	fa040593          	addi	a1,s0,-96
     71e:	854a                	mv	a0,s2
     720:	00005097          	auipc	ra,0x5
     724:	e12080e7          	jalr	-494(ra) # 5532 <read>
  if(n != 6){
     728:	4799                	li	a5,6
     72a:	0cf51d63          	bne	a0,a5,804 <truncate1+0x1d6>
  n = read(fd2, buf, sizeof(buf));
     72e:	02000613          	li	a2,32
     732:	fa040593          	addi	a1,s0,-96
     736:	8526                	mv	a0,s1
     738:	00005097          	auipc	ra,0x5
     73c:	dfa080e7          	jalr	-518(ra) # 5532 <read>
  if(n != 2){
     740:	4789                	li	a5,2
     742:	0ef51063          	bne	a0,a5,822 <truncate1+0x1f4>
  unlink("truncfile");
     746:	00005517          	auipc	a0,0x5
     74a:	74250513          	addi	a0,a0,1858 # 5e88 <malloc+0x536>
     74e:	00005097          	auipc	ra,0x5
     752:	e1c080e7          	jalr	-484(ra) # 556a <unlink>
  close(fd1);
     756:	854e                	mv	a0,s3
     758:	00005097          	auipc	ra,0x5
     75c:	dea080e7          	jalr	-534(ra) # 5542 <close>
  close(fd2);
     760:	8526                	mv	a0,s1
     762:	00005097          	auipc	ra,0x5
     766:	de0080e7          	jalr	-544(ra) # 5542 <close>
  close(fd3);
     76a:	854a                	mv	a0,s2
     76c:	00005097          	auipc	ra,0x5
     770:	dd6080e7          	jalr	-554(ra) # 5542 <close>
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
     78e:	8e650513          	addi	a0,a0,-1818 # 6070 <malloc+0x71e>
     792:	00005097          	auipc	ra,0x5
     796:	100080e7          	jalr	256(ra) # 5892 <printf>
    exit(1);
     79a:	4505                	li	a0,1
     79c:	00005097          	auipc	ra,0x5
     7a0:	d7e080e7          	jalr	-642(ra) # 551a <exit>
    printf("aaa fd3=%d\n", fd3);
     7a4:	85ca                	mv	a1,s2
     7a6:	00006517          	auipc	a0,0x6
     7aa:	8ea50513          	addi	a0,a0,-1814 # 6090 <malloc+0x73e>
     7ae:	00005097          	auipc	ra,0x5
     7b2:	0e4080e7          	jalr	228(ra) # 5892 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7b6:	8652                	mv	a2,s4
     7b8:	85d6                	mv	a1,s5
     7ba:	00006517          	auipc	a0,0x6
     7be:	8e650513          	addi	a0,a0,-1818 # 60a0 <malloc+0x74e>
     7c2:	00005097          	auipc	ra,0x5
     7c6:	0d0080e7          	jalr	208(ra) # 5892 <printf>
    exit(1);
     7ca:	4505                	li	a0,1
     7cc:	00005097          	auipc	ra,0x5
     7d0:	d4e080e7          	jalr	-690(ra) # 551a <exit>
    printf("bbb fd2=%d\n", fd2);
     7d4:	85a6                	mv	a1,s1
     7d6:	00006517          	auipc	a0,0x6
     7da:	8ea50513          	addi	a0,a0,-1814 # 60c0 <malloc+0x76e>
     7de:	00005097          	auipc	ra,0x5
     7e2:	0b4080e7          	jalr	180(ra) # 5892 <printf>
    printf("%s: read %d bytes, wanted 0\n", s, n);
     7e6:	8652                	mv	a2,s4
     7e8:	85d6                	mv	a1,s5
     7ea:	00006517          	auipc	a0,0x6
     7ee:	8b650513          	addi	a0,a0,-1866 # 60a0 <malloc+0x74e>
     7f2:	00005097          	auipc	ra,0x5
     7f6:	0a0080e7          	jalr	160(ra) # 5892 <printf>
    exit(1);
     7fa:	4505                	li	a0,1
     7fc:	00005097          	auipc	ra,0x5
     800:	d1e080e7          	jalr	-738(ra) # 551a <exit>
    printf("%s: read %d bytes, wanted 6\n", s, n);
     804:	862a                	mv	a2,a0
     806:	85d6                	mv	a1,s5
     808:	00006517          	auipc	a0,0x6
     80c:	8d050513          	addi	a0,a0,-1840 # 60d8 <malloc+0x786>
     810:	00005097          	auipc	ra,0x5
     814:	082080e7          	jalr	130(ra) # 5892 <printf>
    exit(1);
     818:	4505                	li	a0,1
     81a:	00005097          	auipc	ra,0x5
     81e:	d00080e7          	jalr	-768(ra) # 551a <exit>
    printf("%s: read %d bytes, wanted 2\n", s, n);
     822:	862a                	mv	a2,a0
     824:	85d6                	mv	a1,s5
     826:	00006517          	auipc	a0,0x6
     82a:	8d250513          	addi	a0,a0,-1838 # 60f8 <malloc+0x7a6>
     82e:	00005097          	auipc	ra,0x5
     832:	064080e7          	jalr	100(ra) # 5892 <printf>
    exit(1);
     836:	4505                	li	a0,1
     838:	00005097          	auipc	ra,0x5
     83c:	ce2080e7          	jalr	-798(ra) # 551a <exit>

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
     85e:	8be50513          	addi	a0,a0,-1858 # 6118 <malloc+0x7c6>
     862:	00005097          	auipc	ra,0x5
     866:	cf8080e7          	jalr	-776(ra) # 555a <open>
  if(fd < 0){
     86a:	0a054d63          	bltz	a0,924 <writetest+0xe4>
     86e:	892a                	mv	s2,a0
     870:	4481                	li	s1,0
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     872:	00006997          	auipc	s3,0x6
     876:	8ce98993          	addi	s3,s3,-1842 # 6140 <malloc+0x7ee>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     87a:	00006a97          	auipc	s5,0x6
     87e:	8fea8a93          	addi	s5,s5,-1794 # 6178 <malloc+0x826>
  for(i = 0; i < N; i++){
     882:	06400a13          	li	s4,100
    if(write(fd, "aaaaaaaaaa", SZ) != SZ){
     886:	4629                	li	a2,10
     888:	85ce                	mv	a1,s3
     88a:	854a                	mv	a0,s2
     88c:	00005097          	auipc	ra,0x5
     890:	cae080e7          	jalr	-850(ra) # 553a <write>
     894:	47a9                	li	a5,10
     896:	0af51563          	bne	a0,a5,940 <writetest+0x100>
    if(write(fd, "bbbbbbbbbb", SZ) != SZ){
     89a:	4629                	li	a2,10
     89c:	85d6                	mv	a1,s5
     89e:	854a                	mv	a0,s2
     8a0:	00005097          	auipc	ra,0x5
     8a4:	c9a080e7          	jalr	-870(ra) # 553a <write>
     8a8:	47a9                	li	a5,10
     8aa:	0af51a63          	bne	a0,a5,95e <writetest+0x11e>
  for(i = 0; i < N; i++){
     8ae:	2485                	addiw	s1,s1,1
     8b0:	fd449be3          	bne	s1,s4,886 <writetest+0x46>
  close(fd);
     8b4:	854a                	mv	a0,s2
     8b6:	00005097          	auipc	ra,0x5
     8ba:	c8c080e7          	jalr	-884(ra) # 5542 <close>
  fd = open("small", O_RDONLY);
     8be:	4581                	li	a1,0
     8c0:	00006517          	auipc	a0,0x6
     8c4:	85850513          	addi	a0,a0,-1960 # 6118 <malloc+0x7c6>
     8c8:	00005097          	auipc	ra,0x5
     8cc:	c92080e7          	jalr	-878(ra) # 555a <open>
     8d0:	84aa                	mv	s1,a0
  if(fd < 0){
     8d2:	0a054563          	bltz	a0,97c <writetest+0x13c>
  i = read(fd, buf, N*SZ*2);
     8d6:	7d000613          	li	a2,2000
     8da:	0000b597          	auipc	a1,0xb
     8de:	09e58593          	addi	a1,a1,158 # b978 <buf>
     8e2:	00005097          	auipc	ra,0x5
     8e6:	c50080e7          	jalr	-944(ra) # 5532 <read>
  if(i != N*SZ*2){
     8ea:	7d000793          	li	a5,2000
     8ee:	0af51563          	bne	a0,a5,998 <writetest+0x158>
  close(fd);
     8f2:	8526                	mv	a0,s1
     8f4:	00005097          	auipc	ra,0x5
     8f8:	c4e080e7          	jalr	-946(ra) # 5542 <close>
  if(unlink("small") < 0){
     8fc:	00006517          	auipc	a0,0x6
     900:	81c50513          	addi	a0,a0,-2020 # 6118 <malloc+0x7c6>
     904:	00005097          	auipc	ra,0x5
     908:	c66080e7          	jalr	-922(ra) # 556a <unlink>
     90c:	0a054463          	bltz	a0,9b4 <writetest+0x174>
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
     926:	00005517          	auipc	a0,0x5
     92a:	7fa50513          	addi	a0,a0,2042 # 6120 <malloc+0x7ce>
     92e:	00005097          	auipc	ra,0x5
     932:	f64080e7          	jalr	-156(ra) # 5892 <printf>
    exit(1);
     936:	4505                	li	a0,1
     938:	00005097          	auipc	ra,0x5
     93c:	be2080e7          	jalr	-1054(ra) # 551a <exit>
      printf("%s: error: write aa %d new file failed\n", s, i);
     940:	8626                	mv	a2,s1
     942:	85da                	mv	a1,s6
     944:	00006517          	auipc	a0,0x6
     948:	80c50513          	addi	a0,a0,-2036 # 6150 <malloc+0x7fe>
     94c:	00005097          	auipc	ra,0x5
     950:	f46080e7          	jalr	-186(ra) # 5892 <printf>
      exit(1);
     954:	4505                	li	a0,1
     956:	00005097          	auipc	ra,0x5
     95a:	bc4080e7          	jalr	-1084(ra) # 551a <exit>
      printf("%s: error: write bb %d new file failed\n", s, i);
     95e:	8626                	mv	a2,s1
     960:	85da                	mv	a1,s6
     962:	00006517          	auipc	a0,0x6
     966:	82650513          	addi	a0,a0,-2010 # 6188 <malloc+0x836>
     96a:	00005097          	auipc	ra,0x5
     96e:	f28080e7          	jalr	-216(ra) # 5892 <printf>
      exit(1);
     972:	4505                	li	a0,1
     974:	00005097          	auipc	ra,0x5
     978:	ba6080e7          	jalr	-1114(ra) # 551a <exit>
    printf("%s: error: open small failed!\n", s);
     97c:	85da                	mv	a1,s6
     97e:	00006517          	auipc	a0,0x6
     982:	83250513          	addi	a0,a0,-1998 # 61b0 <malloc+0x85e>
     986:	00005097          	auipc	ra,0x5
     98a:	f0c080e7          	jalr	-244(ra) # 5892 <printf>
    exit(1);
     98e:	4505                	li	a0,1
     990:	00005097          	auipc	ra,0x5
     994:	b8a080e7          	jalr	-1142(ra) # 551a <exit>
    printf("%s: read failed\n", s);
     998:	85da                	mv	a1,s6
     99a:	00006517          	auipc	a0,0x6
     99e:	83650513          	addi	a0,a0,-1994 # 61d0 <malloc+0x87e>
     9a2:	00005097          	auipc	ra,0x5
     9a6:	ef0080e7          	jalr	-272(ra) # 5892 <printf>
    exit(1);
     9aa:	4505                	li	a0,1
     9ac:	00005097          	auipc	ra,0x5
     9b0:	b6e080e7          	jalr	-1170(ra) # 551a <exit>
    printf("%s: unlink small failed\n", s);
     9b4:	85da                	mv	a1,s6
     9b6:	00006517          	auipc	a0,0x6
     9ba:	83250513          	addi	a0,a0,-1998 # 61e8 <malloc+0x896>
     9be:	00005097          	auipc	ra,0x5
     9c2:	ed4080e7          	jalr	-300(ra) # 5892 <printf>
    exit(1);
     9c6:	4505                	li	a0,1
     9c8:	00005097          	auipc	ra,0x5
     9cc:	b52080e7          	jalr	-1198(ra) # 551a <exit>

00000000000009d0 <writebig>:
{
     9d0:	7139                	addi	sp,sp,-64
     9d2:	fc06                	sd	ra,56(sp)
     9d4:	f822                	sd	s0,48(sp)
     9d6:	f426                	sd	s1,40(sp)
     9d8:	f04a                	sd	s2,32(sp)
     9da:	ec4e                	sd	s3,24(sp)
     9dc:	e852                	sd	s4,16(sp)
     9de:	e456                	sd	s5,8(sp)
     9e0:	0080                	addi	s0,sp,64
     9e2:	8aaa                	mv	s5,a0
  fd = open("big", O_CREATE|O_RDWR);
     9e4:	20200593          	li	a1,514
     9e8:	00006517          	auipc	a0,0x6
     9ec:	82050513          	addi	a0,a0,-2016 # 6208 <malloc+0x8b6>
     9f0:	00005097          	auipc	ra,0x5
     9f4:	b6a080e7          	jalr	-1174(ra) # 555a <open>
     9f8:	89aa                	mv	s3,a0
  for(i = 0; i < MAXFILE; i++){
     9fa:	4481                	li	s1,0
    ((int*)buf)[0] = i;
     9fc:	0000b917          	auipc	s2,0xb
     a00:	f7c90913          	addi	s2,s2,-132 # b978 <buf>
  for(i = 0; i < MAXFILE; i++){
     a04:	10c00a13          	li	s4,268
  if(fd < 0){
     a08:	06054c63          	bltz	a0,a80 <writebig+0xb0>
    ((int*)buf)[0] = i;
     a0c:	00992023          	sw	s1,0(s2)
    if(write(fd, buf, BSIZE) != BSIZE){
     a10:	40000613          	li	a2,1024
     a14:	85ca                	mv	a1,s2
     a16:	854e                	mv	a0,s3
     a18:	00005097          	auipc	ra,0x5
     a1c:	b22080e7          	jalr	-1246(ra) # 553a <write>
     a20:	40000793          	li	a5,1024
     a24:	06f51c63          	bne	a0,a5,a9c <writebig+0xcc>
  for(i = 0; i < MAXFILE; i++){
     a28:	2485                	addiw	s1,s1,1
     a2a:	ff4491e3          	bne	s1,s4,a0c <writebig+0x3c>
  close(fd);
     a2e:	854e                	mv	a0,s3
     a30:	00005097          	auipc	ra,0x5
     a34:	b12080e7          	jalr	-1262(ra) # 5542 <close>
  fd = open("big", O_RDONLY);
     a38:	4581                	li	a1,0
     a3a:	00005517          	auipc	a0,0x5
     a3e:	7ce50513          	addi	a0,a0,1998 # 6208 <malloc+0x8b6>
     a42:	00005097          	auipc	ra,0x5
     a46:	b18080e7          	jalr	-1256(ra) # 555a <open>
     a4a:	89aa                	mv	s3,a0
  n = 0;
     a4c:	4481                	li	s1,0
    i = read(fd, buf, BSIZE);
     a4e:	0000b917          	auipc	s2,0xb
     a52:	f2a90913          	addi	s2,s2,-214 # b978 <buf>
  if(fd < 0){
     a56:	06054263          	bltz	a0,aba <writebig+0xea>
    i = read(fd, buf, BSIZE);
     a5a:	40000613          	li	a2,1024
     a5e:	85ca                	mv	a1,s2
     a60:	854e                	mv	a0,s3
     a62:	00005097          	auipc	ra,0x5
     a66:	ad0080e7          	jalr	-1328(ra) # 5532 <read>
    if(i == 0){
     a6a:	c535                	beqz	a0,ad6 <writebig+0x106>
    } else if(i != BSIZE){
     a6c:	40000793          	li	a5,1024
     a70:	0af51f63          	bne	a0,a5,b2e <writebig+0x15e>
    if(((int*)buf)[0] != n){
     a74:	00092683          	lw	a3,0(s2)
     a78:	0c969a63          	bne	a3,s1,b4c <writebig+0x17c>
    n++;
     a7c:	2485                	addiw	s1,s1,1
    i = read(fd, buf, BSIZE);
     a7e:	bff1                	j	a5a <writebig+0x8a>
    printf("%s: error: creat big failed!\n", s);
     a80:	85d6                	mv	a1,s5
     a82:	00005517          	auipc	a0,0x5
     a86:	78e50513          	addi	a0,a0,1934 # 6210 <malloc+0x8be>
     a8a:	00005097          	auipc	ra,0x5
     a8e:	e08080e7          	jalr	-504(ra) # 5892 <printf>
    exit(1);
     a92:	4505                	li	a0,1
     a94:	00005097          	auipc	ra,0x5
     a98:	a86080e7          	jalr	-1402(ra) # 551a <exit>
      printf("%s: error: write big file failed\n", s, i);
     a9c:	8626                	mv	a2,s1
     a9e:	85d6                	mv	a1,s5
     aa0:	00005517          	auipc	a0,0x5
     aa4:	79050513          	addi	a0,a0,1936 # 6230 <malloc+0x8de>
     aa8:	00005097          	auipc	ra,0x5
     aac:	dea080e7          	jalr	-534(ra) # 5892 <printf>
      exit(1);
     ab0:	4505                	li	a0,1
     ab2:	00005097          	auipc	ra,0x5
     ab6:	a68080e7          	jalr	-1432(ra) # 551a <exit>
    printf("%s: error: open big failed!\n", s);
     aba:	85d6                	mv	a1,s5
     abc:	00005517          	auipc	a0,0x5
     ac0:	79c50513          	addi	a0,a0,1948 # 6258 <malloc+0x906>
     ac4:	00005097          	auipc	ra,0x5
     ac8:	dce080e7          	jalr	-562(ra) # 5892 <printf>
    exit(1);
     acc:	4505                	li	a0,1
     ace:	00005097          	auipc	ra,0x5
     ad2:	a4c080e7          	jalr	-1460(ra) # 551a <exit>
      if(n == MAXFILE - 1){
     ad6:	10b00793          	li	a5,267
     ada:	02f48a63          	beq	s1,a5,b0e <writebig+0x13e>
  close(fd);
     ade:	854e                	mv	a0,s3
     ae0:	00005097          	auipc	ra,0x5
     ae4:	a62080e7          	jalr	-1438(ra) # 5542 <close>
  if(unlink("big") < 0){
     ae8:	00005517          	auipc	a0,0x5
     aec:	72050513          	addi	a0,a0,1824 # 6208 <malloc+0x8b6>
     af0:	00005097          	auipc	ra,0x5
     af4:	a7a080e7          	jalr	-1414(ra) # 556a <unlink>
     af8:	06054963          	bltz	a0,b6a <writebig+0x19a>
}
     afc:	70e2                	ld	ra,56(sp)
     afe:	7442                	ld	s0,48(sp)
     b00:	74a2                	ld	s1,40(sp)
     b02:	7902                	ld	s2,32(sp)
     b04:	69e2                	ld	s3,24(sp)
     b06:	6a42                	ld	s4,16(sp)
     b08:	6aa2                	ld	s5,8(sp)
     b0a:	6121                	addi	sp,sp,64
     b0c:	8082                	ret
        printf("%s: read only %d blocks from big", s, n);
     b0e:	10b00613          	li	a2,267
     b12:	85d6                	mv	a1,s5
     b14:	00005517          	auipc	a0,0x5
     b18:	76450513          	addi	a0,a0,1892 # 6278 <malloc+0x926>
     b1c:	00005097          	auipc	ra,0x5
     b20:	d76080e7          	jalr	-650(ra) # 5892 <printf>
        exit(1);
     b24:	4505                	li	a0,1
     b26:	00005097          	auipc	ra,0x5
     b2a:	9f4080e7          	jalr	-1548(ra) # 551a <exit>
      printf("%s: read failed %d\n", s, i);
     b2e:	862a                	mv	a2,a0
     b30:	85d6                	mv	a1,s5
     b32:	00005517          	auipc	a0,0x5
     b36:	76e50513          	addi	a0,a0,1902 # 62a0 <malloc+0x94e>
     b3a:	00005097          	auipc	ra,0x5
     b3e:	d58080e7          	jalr	-680(ra) # 5892 <printf>
      exit(1);
     b42:	4505                	li	a0,1
     b44:	00005097          	auipc	ra,0x5
     b48:	9d6080e7          	jalr	-1578(ra) # 551a <exit>
      printf("%s: read content of block %d is %d\n", s,
     b4c:	8626                	mv	a2,s1
     b4e:	85d6                	mv	a1,s5
     b50:	00005517          	auipc	a0,0x5
     b54:	76850513          	addi	a0,a0,1896 # 62b8 <malloc+0x966>
     b58:	00005097          	auipc	ra,0x5
     b5c:	d3a080e7          	jalr	-710(ra) # 5892 <printf>
      exit(1);
     b60:	4505                	li	a0,1
     b62:	00005097          	auipc	ra,0x5
     b66:	9b8080e7          	jalr	-1608(ra) # 551a <exit>
    printf("%s: unlink big failed\n", s);
     b6a:	85d6                	mv	a1,s5
     b6c:	00005517          	auipc	a0,0x5
     b70:	77450513          	addi	a0,a0,1908 # 62e0 <malloc+0x98e>
     b74:	00005097          	auipc	ra,0x5
     b78:	d1e080e7          	jalr	-738(ra) # 5892 <printf>
    exit(1);
     b7c:	4505                	li	a0,1
     b7e:	00005097          	auipc	ra,0x5
     b82:	99c080e7          	jalr	-1636(ra) # 551a <exit>

0000000000000b86 <unlinkread>:
{
     b86:	7179                	addi	sp,sp,-48
     b88:	f406                	sd	ra,40(sp)
     b8a:	f022                	sd	s0,32(sp)
     b8c:	ec26                	sd	s1,24(sp)
     b8e:	e84a                	sd	s2,16(sp)
     b90:	e44e                	sd	s3,8(sp)
     b92:	1800                	addi	s0,sp,48
     b94:	89aa                	mv	s3,a0
  fd = open("unlinkread", O_CREATE | O_RDWR);
     b96:	20200593          	li	a1,514
     b9a:	00005517          	auipc	a0,0x5
     b9e:	75e50513          	addi	a0,a0,1886 # 62f8 <malloc+0x9a6>
     ba2:	00005097          	auipc	ra,0x5
     ba6:	9b8080e7          	jalr	-1608(ra) # 555a <open>
  if(fd < 0){
     baa:	0e054563          	bltz	a0,c94 <unlinkread+0x10e>
     bae:	84aa                	mv	s1,a0
  write(fd, "hello", SZ);
     bb0:	4615                	li	a2,5
     bb2:	00005597          	auipc	a1,0x5
     bb6:	77658593          	addi	a1,a1,1910 # 6328 <malloc+0x9d6>
     bba:	00005097          	auipc	ra,0x5
     bbe:	980080e7          	jalr	-1664(ra) # 553a <write>
  close(fd);
     bc2:	8526                	mv	a0,s1
     bc4:	00005097          	auipc	ra,0x5
     bc8:	97e080e7          	jalr	-1666(ra) # 5542 <close>
  fd = open("unlinkread", O_RDWR);
     bcc:	4589                	li	a1,2
     bce:	00005517          	auipc	a0,0x5
     bd2:	72a50513          	addi	a0,a0,1834 # 62f8 <malloc+0x9a6>
     bd6:	00005097          	auipc	ra,0x5
     bda:	984080e7          	jalr	-1660(ra) # 555a <open>
     bde:	84aa                	mv	s1,a0
  if(fd < 0){
     be0:	0c054863          	bltz	a0,cb0 <unlinkread+0x12a>
  if(unlink("unlinkread") != 0){
     be4:	00005517          	auipc	a0,0x5
     be8:	71450513          	addi	a0,a0,1812 # 62f8 <malloc+0x9a6>
     bec:	00005097          	auipc	ra,0x5
     bf0:	97e080e7          	jalr	-1666(ra) # 556a <unlink>
     bf4:	ed61                	bnez	a0,ccc <unlinkread+0x146>
  fd1 = open("unlinkread", O_CREATE | O_RDWR);
     bf6:	20200593          	li	a1,514
     bfa:	00005517          	auipc	a0,0x5
     bfe:	6fe50513          	addi	a0,a0,1790 # 62f8 <malloc+0x9a6>
     c02:	00005097          	auipc	ra,0x5
     c06:	958080e7          	jalr	-1704(ra) # 555a <open>
     c0a:	892a                	mv	s2,a0
  write(fd1, "yyy", 3);
     c0c:	460d                	li	a2,3
     c0e:	00005597          	auipc	a1,0x5
     c12:	76258593          	addi	a1,a1,1890 # 6370 <malloc+0xa1e>
     c16:	00005097          	auipc	ra,0x5
     c1a:	924080e7          	jalr	-1756(ra) # 553a <write>
  close(fd1);
     c1e:	854a                	mv	a0,s2
     c20:	00005097          	auipc	ra,0x5
     c24:	922080e7          	jalr	-1758(ra) # 5542 <close>
  if(read(fd, buf, sizeof(buf)) != SZ){
     c28:	660d                	lui	a2,0x3
     c2a:	0000b597          	auipc	a1,0xb
     c2e:	d4e58593          	addi	a1,a1,-690 # b978 <buf>
     c32:	8526                	mv	a0,s1
     c34:	00005097          	auipc	ra,0x5
     c38:	8fe080e7          	jalr	-1794(ra) # 5532 <read>
     c3c:	4795                	li	a5,5
     c3e:	0af51563          	bne	a0,a5,ce8 <unlinkread+0x162>
  if(buf[0] != 'h'){
     c42:	0000b717          	auipc	a4,0xb
     c46:	d3674703          	lbu	a4,-714(a4) # b978 <buf>
     c4a:	06800793          	li	a5,104
     c4e:	0af71b63          	bne	a4,a5,d04 <unlinkread+0x17e>
  if(write(fd, buf, 10) != 10){
     c52:	4629                	li	a2,10
     c54:	0000b597          	auipc	a1,0xb
     c58:	d2458593          	addi	a1,a1,-732 # b978 <buf>
     c5c:	8526                	mv	a0,s1
     c5e:	00005097          	auipc	ra,0x5
     c62:	8dc080e7          	jalr	-1828(ra) # 553a <write>
     c66:	47a9                	li	a5,10
     c68:	0af51c63          	bne	a0,a5,d20 <unlinkread+0x19a>
  close(fd);
     c6c:	8526                	mv	a0,s1
     c6e:	00005097          	auipc	ra,0x5
     c72:	8d4080e7          	jalr	-1836(ra) # 5542 <close>
  unlink("unlinkread");
     c76:	00005517          	auipc	a0,0x5
     c7a:	68250513          	addi	a0,a0,1666 # 62f8 <malloc+0x9a6>
     c7e:	00005097          	auipc	ra,0x5
     c82:	8ec080e7          	jalr	-1812(ra) # 556a <unlink>
}
     c86:	70a2                	ld	ra,40(sp)
     c88:	7402                	ld	s0,32(sp)
     c8a:	64e2                	ld	s1,24(sp)
     c8c:	6942                	ld	s2,16(sp)
     c8e:	69a2                	ld	s3,8(sp)
     c90:	6145                	addi	sp,sp,48
     c92:	8082                	ret
    printf("%s: create unlinkread failed\n", s);
     c94:	85ce                	mv	a1,s3
     c96:	00005517          	auipc	a0,0x5
     c9a:	67250513          	addi	a0,a0,1650 # 6308 <malloc+0x9b6>
     c9e:	00005097          	auipc	ra,0x5
     ca2:	bf4080e7          	jalr	-1036(ra) # 5892 <printf>
    exit(1);
     ca6:	4505                	li	a0,1
     ca8:	00005097          	auipc	ra,0x5
     cac:	872080e7          	jalr	-1934(ra) # 551a <exit>
    printf("%s: open unlinkread failed\n", s);
     cb0:	85ce                	mv	a1,s3
     cb2:	00005517          	auipc	a0,0x5
     cb6:	67e50513          	addi	a0,a0,1662 # 6330 <malloc+0x9de>
     cba:	00005097          	auipc	ra,0x5
     cbe:	bd8080e7          	jalr	-1064(ra) # 5892 <printf>
    exit(1);
     cc2:	4505                	li	a0,1
     cc4:	00005097          	auipc	ra,0x5
     cc8:	856080e7          	jalr	-1962(ra) # 551a <exit>
    printf("%s: unlink unlinkread failed\n", s);
     ccc:	85ce                	mv	a1,s3
     cce:	00005517          	auipc	a0,0x5
     cd2:	68250513          	addi	a0,a0,1666 # 6350 <malloc+0x9fe>
     cd6:	00005097          	auipc	ra,0x5
     cda:	bbc080e7          	jalr	-1092(ra) # 5892 <printf>
    exit(1);
     cde:	4505                	li	a0,1
     ce0:	00005097          	auipc	ra,0x5
     ce4:	83a080e7          	jalr	-1990(ra) # 551a <exit>
    printf("%s: unlinkread read failed", s);
     ce8:	85ce                	mv	a1,s3
     cea:	00005517          	auipc	a0,0x5
     cee:	68e50513          	addi	a0,a0,1678 # 6378 <malloc+0xa26>
     cf2:	00005097          	auipc	ra,0x5
     cf6:	ba0080e7          	jalr	-1120(ra) # 5892 <printf>
    exit(1);
     cfa:	4505                	li	a0,1
     cfc:	00005097          	auipc	ra,0x5
     d00:	81e080e7          	jalr	-2018(ra) # 551a <exit>
    printf("%s: unlinkread wrong data\n", s);
     d04:	85ce                	mv	a1,s3
     d06:	00005517          	auipc	a0,0x5
     d0a:	69250513          	addi	a0,a0,1682 # 6398 <malloc+0xa46>
     d0e:	00005097          	auipc	ra,0x5
     d12:	b84080e7          	jalr	-1148(ra) # 5892 <printf>
    exit(1);
     d16:	4505                	li	a0,1
     d18:	00005097          	auipc	ra,0x5
     d1c:	802080e7          	jalr	-2046(ra) # 551a <exit>
    printf("%s: unlinkread write failed\n", s);
     d20:	85ce                	mv	a1,s3
     d22:	00005517          	auipc	a0,0x5
     d26:	69650513          	addi	a0,a0,1686 # 63b8 <malloc+0xa66>
     d2a:	00005097          	auipc	ra,0x5
     d2e:	b68080e7          	jalr	-1176(ra) # 5892 <printf>
    exit(1);
     d32:	4505                	li	a0,1
     d34:	00004097          	auipc	ra,0x4
     d38:	7e6080e7          	jalr	2022(ra) # 551a <exit>

0000000000000d3c <linktest>:
{
     d3c:	1101                	addi	sp,sp,-32
     d3e:	ec06                	sd	ra,24(sp)
     d40:	e822                	sd	s0,16(sp)
     d42:	e426                	sd	s1,8(sp)
     d44:	e04a                	sd	s2,0(sp)
     d46:	1000                	addi	s0,sp,32
     d48:	892a                	mv	s2,a0
  unlink("lf1");
     d4a:	00005517          	auipc	a0,0x5
     d4e:	68e50513          	addi	a0,a0,1678 # 63d8 <malloc+0xa86>
     d52:	00005097          	auipc	ra,0x5
     d56:	818080e7          	jalr	-2024(ra) # 556a <unlink>
  unlink("lf2");
     d5a:	00005517          	auipc	a0,0x5
     d5e:	68650513          	addi	a0,a0,1670 # 63e0 <malloc+0xa8e>
     d62:	00005097          	auipc	ra,0x5
     d66:	808080e7          	jalr	-2040(ra) # 556a <unlink>
  fd = open("lf1", O_CREATE|O_RDWR);
     d6a:	20200593          	li	a1,514
     d6e:	00005517          	auipc	a0,0x5
     d72:	66a50513          	addi	a0,a0,1642 # 63d8 <malloc+0xa86>
     d76:	00004097          	auipc	ra,0x4
     d7a:	7e4080e7          	jalr	2020(ra) # 555a <open>
  if(fd < 0){
     d7e:	10054763          	bltz	a0,e8c <linktest+0x150>
     d82:	84aa                	mv	s1,a0
  if(write(fd, "hello", SZ) != SZ){
     d84:	4615                	li	a2,5
     d86:	00005597          	auipc	a1,0x5
     d8a:	5a258593          	addi	a1,a1,1442 # 6328 <malloc+0x9d6>
     d8e:	00004097          	auipc	ra,0x4
     d92:	7ac080e7          	jalr	1964(ra) # 553a <write>
     d96:	4795                	li	a5,5
     d98:	10f51863          	bne	a0,a5,ea8 <linktest+0x16c>
  close(fd);
     d9c:	8526                	mv	a0,s1
     d9e:	00004097          	auipc	ra,0x4
     da2:	7a4080e7          	jalr	1956(ra) # 5542 <close>
  if(link("lf1", "lf2") < 0){
     da6:	00005597          	auipc	a1,0x5
     daa:	63a58593          	addi	a1,a1,1594 # 63e0 <malloc+0xa8e>
     dae:	00005517          	auipc	a0,0x5
     db2:	62a50513          	addi	a0,a0,1578 # 63d8 <malloc+0xa86>
     db6:	00004097          	auipc	ra,0x4
     dba:	7c4080e7          	jalr	1988(ra) # 557a <link>
     dbe:	10054363          	bltz	a0,ec4 <linktest+0x188>
  unlink("lf1");
     dc2:	00005517          	auipc	a0,0x5
     dc6:	61650513          	addi	a0,a0,1558 # 63d8 <malloc+0xa86>
     dca:	00004097          	auipc	ra,0x4
     dce:	7a0080e7          	jalr	1952(ra) # 556a <unlink>
  if(open("lf1", 0) >= 0){
     dd2:	4581                	li	a1,0
     dd4:	00005517          	auipc	a0,0x5
     dd8:	60450513          	addi	a0,a0,1540 # 63d8 <malloc+0xa86>
     ddc:	00004097          	auipc	ra,0x4
     de0:	77e080e7          	jalr	1918(ra) # 555a <open>
     de4:	0e055e63          	bgez	a0,ee0 <linktest+0x1a4>
  fd = open("lf2", 0);
     de8:	4581                	li	a1,0
     dea:	00005517          	auipc	a0,0x5
     dee:	5f650513          	addi	a0,a0,1526 # 63e0 <malloc+0xa8e>
     df2:	00004097          	auipc	ra,0x4
     df6:	768080e7          	jalr	1896(ra) # 555a <open>
     dfa:	84aa                	mv	s1,a0
  if(fd < 0){
     dfc:	10054063          	bltz	a0,efc <linktest+0x1c0>
  if(read(fd, buf, sizeof(buf)) != SZ){
     e00:	660d                	lui	a2,0x3
     e02:	0000b597          	auipc	a1,0xb
     e06:	b7658593          	addi	a1,a1,-1162 # b978 <buf>
     e0a:	00004097          	auipc	ra,0x4
     e0e:	728080e7          	jalr	1832(ra) # 5532 <read>
     e12:	4795                	li	a5,5
     e14:	10f51263          	bne	a0,a5,f18 <linktest+0x1dc>
  close(fd);
     e18:	8526                	mv	a0,s1
     e1a:	00004097          	auipc	ra,0x4
     e1e:	728080e7          	jalr	1832(ra) # 5542 <close>
  if(link("lf2", "lf2") >= 0){
     e22:	00005597          	auipc	a1,0x5
     e26:	5be58593          	addi	a1,a1,1470 # 63e0 <malloc+0xa8e>
     e2a:	852e                	mv	a0,a1
     e2c:	00004097          	auipc	ra,0x4
     e30:	74e080e7          	jalr	1870(ra) # 557a <link>
     e34:	10055063          	bgez	a0,f34 <linktest+0x1f8>
  unlink("lf2");
     e38:	00005517          	auipc	a0,0x5
     e3c:	5a850513          	addi	a0,a0,1448 # 63e0 <malloc+0xa8e>
     e40:	00004097          	auipc	ra,0x4
     e44:	72a080e7          	jalr	1834(ra) # 556a <unlink>
  if(link("lf2", "lf1") >= 0){
     e48:	00005597          	auipc	a1,0x5
     e4c:	59058593          	addi	a1,a1,1424 # 63d8 <malloc+0xa86>
     e50:	00005517          	auipc	a0,0x5
     e54:	59050513          	addi	a0,a0,1424 # 63e0 <malloc+0xa8e>
     e58:	00004097          	auipc	ra,0x4
     e5c:	722080e7          	jalr	1826(ra) # 557a <link>
     e60:	0e055863          	bgez	a0,f50 <linktest+0x214>
  if(link(".", "lf1") >= 0){
     e64:	00005597          	auipc	a1,0x5
     e68:	57458593          	addi	a1,a1,1396 # 63d8 <malloc+0xa86>
     e6c:	00005517          	auipc	a0,0x5
     e70:	67c50513          	addi	a0,a0,1660 # 64e8 <malloc+0xb96>
     e74:	00004097          	auipc	ra,0x4
     e78:	706080e7          	jalr	1798(ra) # 557a <link>
     e7c:	0e055863          	bgez	a0,f6c <linktest+0x230>
}
     e80:	60e2                	ld	ra,24(sp)
     e82:	6442                	ld	s0,16(sp)
     e84:	64a2                	ld	s1,8(sp)
     e86:	6902                	ld	s2,0(sp)
     e88:	6105                	addi	sp,sp,32
     e8a:	8082                	ret
    printf("%s: create lf1 failed\n", s);
     e8c:	85ca                	mv	a1,s2
     e8e:	00005517          	auipc	a0,0x5
     e92:	55a50513          	addi	a0,a0,1370 # 63e8 <malloc+0xa96>
     e96:	00005097          	auipc	ra,0x5
     e9a:	9fc080e7          	jalr	-1540(ra) # 5892 <printf>
    exit(1);
     e9e:	4505                	li	a0,1
     ea0:	00004097          	auipc	ra,0x4
     ea4:	67a080e7          	jalr	1658(ra) # 551a <exit>
    printf("%s: write lf1 failed\n", s);
     ea8:	85ca                	mv	a1,s2
     eaa:	00005517          	auipc	a0,0x5
     eae:	55650513          	addi	a0,a0,1366 # 6400 <malloc+0xaae>
     eb2:	00005097          	auipc	ra,0x5
     eb6:	9e0080e7          	jalr	-1568(ra) # 5892 <printf>
    exit(1);
     eba:	4505                	li	a0,1
     ebc:	00004097          	auipc	ra,0x4
     ec0:	65e080e7          	jalr	1630(ra) # 551a <exit>
    printf("%s: link lf1 lf2 failed\n", s);
     ec4:	85ca                	mv	a1,s2
     ec6:	00005517          	auipc	a0,0x5
     eca:	55250513          	addi	a0,a0,1362 # 6418 <malloc+0xac6>
     ece:	00005097          	auipc	ra,0x5
     ed2:	9c4080e7          	jalr	-1596(ra) # 5892 <printf>
    exit(1);
     ed6:	4505                	li	a0,1
     ed8:	00004097          	auipc	ra,0x4
     edc:	642080e7          	jalr	1602(ra) # 551a <exit>
    printf("%s: unlinked lf1 but it is still there!\n", s);
     ee0:	85ca                	mv	a1,s2
     ee2:	00005517          	auipc	a0,0x5
     ee6:	55650513          	addi	a0,a0,1366 # 6438 <malloc+0xae6>
     eea:	00005097          	auipc	ra,0x5
     eee:	9a8080e7          	jalr	-1624(ra) # 5892 <printf>
    exit(1);
     ef2:	4505                	li	a0,1
     ef4:	00004097          	auipc	ra,0x4
     ef8:	626080e7          	jalr	1574(ra) # 551a <exit>
    printf("%s: open lf2 failed\n", s);
     efc:	85ca                	mv	a1,s2
     efe:	00005517          	auipc	a0,0x5
     f02:	56a50513          	addi	a0,a0,1386 # 6468 <malloc+0xb16>
     f06:	00005097          	auipc	ra,0x5
     f0a:	98c080e7          	jalr	-1652(ra) # 5892 <printf>
    exit(1);
     f0e:	4505                	li	a0,1
     f10:	00004097          	auipc	ra,0x4
     f14:	60a080e7          	jalr	1546(ra) # 551a <exit>
    printf("%s: read lf2 failed\n", s);
     f18:	85ca                	mv	a1,s2
     f1a:	00005517          	auipc	a0,0x5
     f1e:	56650513          	addi	a0,a0,1382 # 6480 <malloc+0xb2e>
     f22:	00005097          	auipc	ra,0x5
     f26:	970080e7          	jalr	-1680(ra) # 5892 <printf>
    exit(1);
     f2a:	4505                	li	a0,1
     f2c:	00004097          	auipc	ra,0x4
     f30:	5ee080e7          	jalr	1518(ra) # 551a <exit>
    printf("%s: link lf2 lf2 succeeded! oops\n", s);
     f34:	85ca                	mv	a1,s2
     f36:	00005517          	auipc	a0,0x5
     f3a:	56250513          	addi	a0,a0,1378 # 6498 <malloc+0xb46>
     f3e:	00005097          	auipc	ra,0x5
     f42:	954080e7          	jalr	-1708(ra) # 5892 <printf>
    exit(1);
     f46:	4505                	li	a0,1
     f48:	00004097          	auipc	ra,0x4
     f4c:	5d2080e7          	jalr	1490(ra) # 551a <exit>
    printf("%s: link non-existant succeeded! oops\n", s);
     f50:	85ca                	mv	a1,s2
     f52:	00005517          	auipc	a0,0x5
     f56:	56e50513          	addi	a0,a0,1390 # 64c0 <malloc+0xb6e>
     f5a:	00005097          	auipc	ra,0x5
     f5e:	938080e7          	jalr	-1736(ra) # 5892 <printf>
    exit(1);
     f62:	4505                	li	a0,1
     f64:	00004097          	auipc	ra,0x4
     f68:	5b6080e7          	jalr	1462(ra) # 551a <exit>
    printf("%s: link . lf1 succeeded! oops\n", s);
     f6c:	85ca                	mv	a1,s2
     f6e:	00005517          	auipc	a0,0x5
     f72:	58250513          	addi	a0,a0,1410 # 64f0 <malloc+0xb9e>
     f76:	00005097          	auipc	ra,0x5
     f7a:	91c080e7          	jalr	-1764(ra) # 5892 <printf>
    exit(1);
     f7e:	4505                	li	a0,1
     f80:	00004097          	auipc	ra,0x4
     f84:	59a080e7          	jalr	1434(ra) # 551a <exit>

0000000000000f88 <bigdir>:
{
     f88:	715d                	addi	sp,sp,-80
     f8a:	e486                	sd	ra,72(sp)
     f8c:	e0a2                	sd	s0,64(sp)
     f8e:	fc26                	sd	s1,56(sp)
     f90:	f84a                	sd	s2,48(sp)
     f92:	f44e                	sd	s3,40(sp)
     f94:	f052                	sd	s4,32(sp)
     f96:	ec56                	sd	s5,24(sp)
     f98:	e85a                	sd	s6,16(sp)
     f9a:	0880                	addi	s0,sp,80
     f9c:	89aa                	mv	s3,a0
  unlink("bd");
     f9e:	00005517          	auipc	a0,0x5
     fa2:	57250513          	addi	a0,a0,1394 # 6510 <malloc+0xbbe>
     fa6:	00004097          	auipc	ra,0x4
     faa:	5c4080e7          	jalr	1476(ra) # 556a <unlink>
  fd = open("bd", O_CREATE);
     fae:	20000593          	li	a1,512
     fb2:	00005517          	auipc	a0,0x5
     fb6:	55e50513          	addi	a0,a0,1374 # 6510 <malloc+0xbbe>
     fba:	00004097          	auipc	ra,0x4
     fbe:	5a0080e7          	jalr	1440(ra) # 555a <open>
  if(fd < 0){
     fc2:	0c054963          	bltz	a0,1094 <bigdir+0x10c>
  close(fd);
     fc6:	00004097          	auipc	ra,0x4
     fca:	57c080e7          	jalr	1404(ra) # 5542 <close>
  for(i = 0; i < N; i++){
     fce:	4901                	li	s2,0
    name[0] = 'x';
     fd0:	07800a93          	li	s5,120
    if(link("bd", name) != 0){
     fd4:	00005a17          	auipc	s4,0x5
     fd8:	53ca0a13          	addi	s4,s4,1340 # 6510 <malloc+0xbbe>
  for(i = 0; i < N; i++){
     fdc:	1f400b13          	li	s6,500
    name[0] = 'x';
     fe0:	fb540823          	sb	s5,-80(s0)
    name[1] = '0' + (i / 64);
     fe4:	41f9579b          	sraiw	a5,s2,0x1f
     fe8:	01a7d71b          	srliw	a4,a5,0x1a
     fec:	012707bb          	addw	a5,a4,s2
     ff0:	4067d69b          	sraiw	a3,a5,0x6
     ff4:	0306869b          	addiw	a3,a3,48
     ff8:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
     ffc:	03f7f793          	andi	a5,a5,63
    1000:	9f99                	subw	a5,a5,a4
    1002:	0307879b          	addiw	a5,a5,48
    1006:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    100a:	fa0409a3          	sb	zero,-77(s0)
    if(link("bd", name) != 0){
    100e:	fb040593          	addi	a1,s0,-80
    1012:	8552                	mv	a0,s4
    1014:	00004097          	auipc	ra,0x4
    1018:	566080e7          	jalr	1382(ra) # 557a <link>
    101c:	84aa                	mv	s1,a0
    101e:	e949                	bnez	a0,10b0 <bigdir+0x128>
  for(i = 0; i < N; i++){
    1020:	2905                	addiw	s2,s2,1
    1022:	fb691fe3          	bne	s2,s6,fe0 <bigdir+0x58>
  unlink("bd");
    1026:	00005517          	auipc	a0,0x5
    102a:	4ea50513          	addi	a0,a0,1258 # 6510 <malloc+0xbbe>
    102e:	00004097          	auipc	ra,0x4
    1032:	53c080e7          	jalr	1340(ra) # 556a <unlink>
    name[0] = 'x';
    1036:	07800913          	li	s2,120
  for(i = 0; i < N; i++){
    103a:	1f400a13          	li	s4,500
    name[0] = 'x';
    103e:	fb240823          	sb	s2,-80(s0)
    name[1] = '0' + (i / 64);
    1042:	41f4d79b          	sraiw	a5,s1,0x1f
    1046:	01a7d71b          	srliw	a4,a5,0x1a
    104a:	009707bb          	addw	a5,a4,s1
    104e:	4067d69b          	sraiw	a3,a5,0x6
    1052:	0306869b          	addiw	a3,a3,48
    1056:	fad408a3          	sb	a3,-79(s0)
    name[2] = '0' + (i % 64);
    105a:	03f7f793          	andi	a5,a5,63
    105e:	9f99                	subw	a5,a5,a4
    1060:	0307879b          	addiw	a5,a5,48
    1064:	faf40923          	sb	a5,-78(s0)
    name[3] = '\0';
    1068:	fa0409a3          	sb	zero,-77(s0)
    if(unlink(name) != 0){
    106c:	fb040513          	addi	a0,s0,-80
    1070:	00004097          	auipc	ra,0x4
    1074:	4fa080e7          	jalr	1274(ra) # 556a <unlink>
    1078:	ed21                	bnez	a0,10d0 <bigdir+0x148>
  for(i = 0; i < N; i++){
    107a:	2485                	addiw	s1,s1,1
    107c:	fd4491e3          	bne	s1,s4,103e <bigdir+0xb6>
}
    1080:	60a6                	ld	ra,72(sp)
    1082:	6406                	ld	s0,64(sp)
    1084:	74e2                	ld	s1,56(sp)
    1086:	7942                	ld	s2,48(sp)
    1088:	79a2                	ld	s3,40(sp)
    108a:	7a02                	ld	s4,32(sp)
    108c:	6ae2                	ld	s5,24(sp)
    108e:	6b42                	ld	s6,16(sp)
    1090:	6161                	addi	sp,sp,80
    1092:	8082                	ret
    printf("%s: bigdir create failed\n", s);
    1094:	85ce                	mv	a1,s3
    1096:	00005517          	auipc	a0,0x5
    109a:	48250513          	addi	a0,a0,1154 # 6518 <malloc+0xbc6>
    109e:	00004097          	auipc	ra,0x4
    10a2:	7f4080e7          	jalr	2036(ra) # 5892 <printf>
    exit(1);
    10a6:	4505                	li	a0,1
    10a8:	00004097          	auipc	ra,0x4
    10ac:	472080e7          	jalr	1138(ra) # 551a <exit>
      printf("%s: bigdir link(bd, %s) failed\n", s, name);
    10b0:	fb040613          	addi	a2,s0,-80
    10b4:	85ce                	mv	a1,s3
    10b6:	00005517          	auipc	a0,0x5
    10ba:	48250513          	addi	a0,a0,1154 # 6538 <malloc+0xbe6>
    10be:	00004097          	auipc	ra,0x4
    10c2:	7d4080e7          	jalr	2004(ra) # 5892 <printf>
      exit(1);
    10c6:	4505                	li	a0,1
    10c8:	00004097          	auipc	ra,0x4
    10cc:	452080e7          	jalr	1106(ra) # 551a <exit>
      printf("%s: bigdir unlink failed", s);
    10d0:	85ce                	mv	a1,s3
    10d2:	00005517          	auipc	a0,0x5
    10d6:	48650513          	addi	a0,a0,1158 # 6558 <malloc+0xc06>
    10da:	00004097          	auipc	ra,0x4
    10de:	7b8080e7          	jalr	1976(ra) # 5892 <printf>
      exit(1);
    10e2:	4505                	li	a0,1
    10e4:	00004097          	auipc	ra,0x4
    10e8:	436080e7          	jalr	1078(ra) # 551a <exit>

00000000000010ec <validatetest>:
{
    10ec:	7139                	addi	sp,sp,-64
    10ee:	fc06                	sd	ra,56(sp)
    10f0:	f822                	sd	s0,48(sp)
    10f2:	f426                	sd	s1,40(sp)
    10f4:	f04a                	sd	s2,32(sp)
    10f6:	ec4e                	sd	s3,24(sp)
    10f8:	e852                	sd	s4,16(sp)
    10fa:	e456                	sd	s5,8(sp)
    10fc:	e05a                	sd	s6,0(sp)
    10fe:	0080                	addi	s0,sp,64
    1100:	8b2a                	mv	s6,a0
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1102:	4481                	li	s1,0
    if(link("nosuchfile", (char*)p) != -1){
    1104:	00005997          	auipc	s3,0x5
    1108:	47498993          	addi	s3,s3,1140 # 6578 <malloc+0xc26>
    110c:	597d                	li	s2,-1
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    110e:	6a85                	lui	s5,0x1
    1110:	00114a37          	lui	s4,0x114
    if(link("nosuchfile", (char*)p) != -1){
    1114:	85a6                	mv	a1,s1
    1116:	854e                	mv	a0,s3
    1118:	00004097          	auipc	ra,0x4
    111c:	462080e7          	jalr	1122(ra) # 557a <link>
    1120:	01251f63          	bne	a0,s2,113e <validatetest+0x52>
  for(p = 0; p <= (uint)hi; p += PGSIZE){
    1124:	94d6                	add	s1,s1,s5
    1126:	ff4497e3          	bne	s1,s4,1114 <validatetest+0x28>
}
    112a:	70e2                	ld	ra,56(sp)
    112c:	7442                	ld	s0,48(sp)
    112e:	74a2                	ld	s1,40(sp)
    1130:	7902                	ld	s2,32(sp)
    1132:	69e2                	ld	s3,24(sp)
    1134:	6a42                	ld	s4,16(sp)
    1136:	6aa2                	ld	s5,8(sp)
    1138:	6b02                	ld	s6,0(sp)
    113a:	6121                	addi	sp,sp,64
    113c:	8082                	ret
      printf("%s: link should not succeed\n", s);
    113e:	85da                	mv	a1,s6
    1140:	00005517          	auipc	a0,0x5
    1144:	44850513          	addi	a0,a0,1096 # 6588 <malloc+0xc36>
    1148:	00004097          	auipc	ra,0x4
    114c:	74a080e7          	jalr	1866(ra) # 5892 <printf>
      exit(1);
    1150:	4505                	li	a0,1
    1152:	00004097          	auipc	ra,0x4
    1156:	3c8080e7          	jalr	968(ra) # 551a <exit>

000000000000115a <pgbug>:
// regression test. copyin(), copyout(), and copyinstr() used to cast
// the virtual page address to uint, which (with certain wild system
// call arguments) resulted in a kernel page faults.
void
pgbug(char *s)
{
    115a:	7179                	addi	sp,sp,-48
    115c:	f406                	sd	ra,40(sp)
    115e:	f022                	sd	s0,32(sp)
    1160:	ec26                	sd	s1,24(sp)
    1162:	1800                	addi	s0,sp,48
  char *argv[1];
  argv[0] = 0;
    1164:	fc043c23          	sd	zero,-40(s0)
  exec((char*)0xeaeb0b5b00002f5e, argv);
    1168:	00007797          	auipc	a5,0x7
    116c:	fd878793          	addi	a5,a5,-40 # 8140 <digits+0x20>
    1170:	6384                	ld	s1,0(a5)
    1172:	fd840593          	addi	a1,s0,-40
    1176:	8526                	mv	a0,s1
    1178:	00004097          	auipc	ra,0x4
    117c:	3da080e7          	jalr	986(ra) # 5552 <exec>

  pipe((int*)0xeaeb0b5b00002f5e);
    1180:	8526                	mv	a0,s1
    1182:	00004097          	auipc	ra,0x4
    1186:	3a8080e7          	jalr	936(ra) # 552a <pipe>

  exit(0);
    118a:	4501                	li	a0,0
    118c:	00004097          	auipc	ra,0x4
    1190:	38e080e7          	jalr	910(ra) # 551a <exit>

0000000000001194 <badarg>:

// regression test. test whether exec() leaks memory if one of the
// arguments is invalid. the test passes if the kernel doesn't panic.
void
badarg(char *s)
{
    1194:	7139                	addi	sp,sp,-64
    1196:	fc06                	sd	ra,56(sp)
    1198:	f822                	sd	s0,48(sp)
    119a:	f426                	sd	s1,40(sp)
    119c:	f04a                	sd	s2,32(sp)
    119e:	ec4e                	sd	s3,24(sp)
    11a0:	0080                	addi	s0,sp,64
    11a2:	64b1                	lui	s1,0xc
    11a4:	35048493          	addi	s1,s1,848 # c350 <buf+0x9d8>
  for(int i = 0; i < 50000; i++){
    char *argv[2];
    argv[0] = (char*)0xffffffff;
    11a8:	597d                	li	s2,-1
    11aa:	02095913          	srli	s2,s2,0x20
    argv[1] = 0;
    exec("echo", argv);
    11ae:	00005997          	auipc	s3,0x5
    11b2:	c8298993          	addi	s3,s3,-894 # 5e30 <malloc+0x4de>
    argv[0] = (char*)0xffffffff;
    11b6:	fd243023          	sd	s2,-64(s0)
    argv[1] = 0;
    11ba:	fc043423          	sd	zero,-56(s0)
    exec("echo", argv);
    11be:	fc040593          	addi	a1,s0,-64
    11c2:	854e                	mv	a0,s3
    11c4:	00004097          	auipc	ra,0x4
    11c8:	38e080e7          	jalr	910(ra) # 5552 <exec>
  for(int i = 0; i < 50000; i++){
    11cc:	34fd                	addiw	s1,s1,-1
    11ce:	f4e5                	bnez	s1,11b6 <badarg+0x22>
  }
  
  exit(0);
    11d0:	4501                	li	a0,0
    11d2:	00004097          	auipc	ra,0x4
    11d6:	348080e7          	jalr	840(ra) # 551a <exit>

00000000000011da <copyinstr2>:
{
    11da:	7155                	addi	sp,sp,-208
    11dc:	e586                	sd	ra,200(sp)
    11de:	e1a2                	sd	s0,192(sp)
    11e0:	0980                	addi	s0,sp,208
  for(int i = 0; i < MAXPATH; i++)
    11e2:	f6840793          	addi	a5,s0,-152
    11e6:	fe840693          	addi	a3,s0,-24
    b[i] = 'x';
    11ea:	07800713          	li	a4,120
    11ee:	00e78023          	sb	a4,0(a5)
  for(int i = 0; i < MAXPATH; i++)
    11f2:	0785                	addi	a5,a5,1
    11f4:	fed79de3          	bne	a5,a3,11ee <copyinstr2+0x14>
  b[MAXPATH] = '\0';
    11f8:	fe040423          	sb	zero,-24(s0)
  int ret = unlink(b);
    11fc:	f6840513          	addi	a0,s0,-152
    1200:	00004097          	auipc	ra,0x4
    1204:	36a080e7          	jalr	874(ra) # 556a <unlink>
  if(ret != -1){
    1208:	57fd                	li	a5,-1
    120a:	0ef51063          	bne	a0,a5,12ea <copyinstr2+0x110>
  int fd = open(b, O_CREATE | O_WRONLY);
    120e:	20100593          	li	a1,513
    1212:	f6840513          	addi	a0,s0,-152
    1216:	00004097          	auipc	ra,0x4
    121a:	344080e7          	jalr	836(ra) # 555a <open>
  if(fd != -1){
    121e:	57fd                	li	a5,-1
    1220:	0ef51563          	bne	a0,a5,130a <copyinstr2+0x130>
  ret = link(b, b);
    1224:	f6840593          	addi	a1,s0,-152
    1228:	852e                	mv	a0,a1
    122a:	00004097          	auipc	ra,0x4
    122e:	350080e7          	jalr	848(ra) # 557a <link>
  if(ret != -1){
    1232:	57fd                	li	a5,-1
    1234:	0ef51b63          	bne	a0,a5,132a <copyinstr2+0x150>
  char *args[] = { "xx", 0 };
    1238:	00006797          	auipc	a5,0x6
    123c:	51878793          	addi	a5,a5,1304 # 7750 <malloc+0x1dfe>
    1240:	f4f43c23          	sd	a5,-168(s0)
    1244:	f6043023          	sd	zero,-160(s0)
  ret = exec(b, args);
    1248:	f5840593          	addi	a1,s0,-168
    124c:	f6840513          	addi	a0,s0,-152
    1250:	00004097          	auipc	ra,0x4
    1254:	302080e7          	jalr	770(ra) # 5552 <exec>
  if(ret != -1){
    1258:	57fd                	li	a5,-1
    125a:	0ef51963          	bne	a0,a5,134c <copyinstr2+0x172>
  int pid = fork();
    125e:	00004097          	auipc	ra,0x4
    1262:	2b4080e7          	jalr	692(ra) # 5512 <fork>
  if(pid < 0){
    1266:	10054363          	bltz	a0,136c <copyinstr2+0x192>
  if(pid == 0){
    126a:	12051463          	bnez	a0,1392 <copyinstr2+0x1b8>
    126e:	00007797          	auipc	a5,0x7
    1272:	ff278793          	addi	a5,a5,-14 # 8260 <big.1285>
    1276:	00008697          	auipc	a3,0x8
    127a:	fea68693          	addi	a3,a3,-22 # 9260 <__global_pointer$+0x920>
      big[i] = 'x';
    127e:	07800713          	li	a4,120
    1282:	00e78023          	sb	a4,0(a5)
    for(int i = 0; i < PGSIZE; i++)
    1286:	0785                	addi	a5,a5,1
    1288:	fed79de3          	bne	a5,a3,1282 <copyinstr2+0xa8>
    big[PGSIZE] = '\0';
    128c:	00008797          	auipc	a5,0x8
    1290:	fc078a23          	sb	zero,-44(a5) # 9260 <__global_pointer$+0x920>
    char *args2[] = { big, big, big, 0 };
    1294:	00004797          	auipc	a5,0x4
    1298:	7a478793          	addi	a5,a5,1956 # 5a38 <malloc+0xe6>
    129c:	6390                	ld	a2,0(a5)
    129e:	6794                	ld	a3,8(a5)
    12a0:	6b98                	ld	a4,16(a5)
    12a2:	6f9c                	ld	a5,24(a5)
    12a4:	f2c43823          	sd	a2,-208(s0)
    12a8:	f2d43c23          	sd	a3,-200(s0)
    12ac:	f4e43023          	sd	a4,-192(s0)
    12b0:	f4f43423          	sd	a5,-184(s0)
    ret = exec("echo", args2);
    12b4:	f3040593          	addi	a1,s0,-208
    12b8:	00005517          	auipc	a0,0x5
    12bc:	b7850513          	addi	a0,a0,-1160 # 5e30 <malloc+0x4de>
    12c0:	00004097          	auipc	ra,0x4
    12c4:	292080e7          	jalr	658(ra) # 5552 <exec>
    if(ret != -1){
    12c8:	57fd                	li	a5,-1
    12ca:	0af50e63          	beq	a0,a5,1386 <copyinstr2+0x1ac>
      printf("exec(echo, BIG) returned %d, not -1\n", fd);
    12ce:	55fd                	li	a1,-1
    12d0:	00005517          	auipc	a0,0x5
    12d4:	36050513          	addi	a0,a0,864 # 6630 <malloc+0xcde>
    12d8:	00004097          	auipc	ra,0x4
    12dc:	5ba080e7          	jalr	1466(ra) # 5892 <printf>
      exit(1);
    12e0:	4505                	li	a0,1
    12e2:	00004097          	auipc	ra,0x4
    12e6:	238080e7          	jalr	568(ra) # 551a <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    12ea:	862a                	mv	a2,a0
    12ec:	f6840593          	addi	a1,s0,-152
    12f0:	00005517          	auipc	a0,0x5
    12f4:	2b850513          	addi	a0,a0,696 # 65a8 <malloc+0xc56>
    12f8:	00004097          	auipc	ra,0x4
    12fc:	59a080e7          	jalr	1434(ra) # 5892 <printf>
    exit(1);
    1300:	4505                	li	a0,1
    1302:	00004097          	auipc	ra,0x4
    1306:	218080e7          	jalr	536(ra) # 551a <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    130a:	862a                	mv	a2,a0
    130c:	f6840593          	addi	a1,s0,-152
    1310:	00005517          	auipc	a0,0x5
    1314:	2b850513          	addi	a0,a0,696 # 65c8 <malloc+0xc76>
    1318:	00004097          	auipc	ra,0x4
    131c:	57a080e7          	jalr	1402(ra) # 5892 <printf>
    exit(1);
    1320:	4505                	li	a0,1
    1322:	00004097          	auipc	ra,0x4
    1326:	1f8080e7          	jalr	504(ra) # 551a <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    132a:	86aa                	mv	a3,a0
    132c:	f6840613          	addi	a2,s0,-152
    1330:	85b2                	mv	a1,a2
    1332:	00005517          	auipc	a0,0x5
    1336:	2b650513          	addi	a0,a0,694 # 65e8 <malloc+0xc96>
    133a:	00004097          	auipc	ra,0x4
    133e:	558080e7          	jalr	1368(ra) # 5892 <printf>
    exit(1);
    1342:	4505                	li	a0,1
    1344:	00004097          	auipc	ra,0x4
    1348:	1d6080e7          	jalr	470(ra) # 551a <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    134c:	567d                	li	a2,-1
    134e:	f6840593          	addi	a1,s0,-152
    1352:	00005517          	auipc	a0,0x5
    1356:	2be50513          	addi	a0,a0,702 # 6610 <malloc+0xcbe>
    135a:	00004097          	auipc	ra,0x4
    135e:	538080e7          	jalr	1336(ra) # 5892 <printf>
    exit(1);
    1362:	4505                	li	a0,1
    1364:	00004097          	auipc	ra,0x4
    1368:	1b6080e7          	jalr	438(ra) # 551a <exit>
    printf("fork failed\n");
    136c:	00005517          	auipc	a0,0x5
    1370:	70c50513          	addi	a0,a0,1804 # 6a78 <malloc+0x1126>
    1374:	00004097          	auipc	ra,0x4
    1378:	51e080e7          	jalr	1310(ra) # 5892 <printf>
    exit(1);
    137c:	4505                	li	a0,1
    137e:	00004097          	auipc	ra,0x4
    1382:	19c080e7          	jalr	412(ra) # 551a <exit>
    exit(747); // OK
    1386:	2eb00513          	li	a0,747
    138a:	00004097          	auipc	ra,0x4
    138e:	190080e7          	jalr	400(ra) # 551a <exit>
  int st = 0;
    1392:	f4042a23          	sw	zero,-172(s0)
  wait(&st);
    1396:	f5440513          	addi	a0,s0,-172
    139a:	00004097          	auipc	ra,0x4
    139e:	188080e7          	jalr	392(ra) # 5522 <wait>
  if(st != 747){
    13a2:	f5442703          	lw	a4,-172(s0)
    13a6:	2eb00793          	li	a5,747
    13aa:	00f71663          	bne	a4,a5,13b6 <copyinstr2+0x1dc>
}
    13ae:	60ae                	ld	ra,200(sp)
    13b0:	640e                	ld	s0,192(sp)
    13b2:	6169                	addi	sp,sp,208
    13b4:	8082                	ret
    printf("exec(echo, BIG) succeeded, should have failed\n");
    13b6:	00005517          	auipc	a0,0x5
    13ba:	2a250513          	addi	a0,a0,674 # 6658 <malloc+0xd06>
    13be:	00004097          	auipc	ra,0x4
    13c2:	4d4080e7          	jalr	1236(ra) # 5892 <printf>
    exit(1);
    13c6:	4505                	li	a0,1
    13c8:	00004097          	auipc	ra,0x4
    13cc:	152080e7          	jalr	338(ra) # 551a <exit>

00000000000013d0 <truncate3>:
{
    13d0:	7159                	addi	sp,sp,-112
    13d2:	f486                	sd	ra,104(sp)
    13d4:	f0a2                	sd	s0,96(sp)
    13d6:	eca6                	sd	s1,88(sp)
    13d8:	e8ca                	sd	s2,80(sp)
    13da:	e4ce                	sd	s3,72(sp)
    13dc:	e0d2                	sd	s4,64(sp)
    13de:	fc56                	sd	s5,56(sp)
    13e0:	1880                	addi	s0,sp,112
    13e2:	8a2a                	mv	s4,a0
  close(open("truncfile", O_CREATE|O_TRUNC|O_WRONLY));
    13e4:	60100593          	li	a1,1537
    13e8:	00005517          	auipc	a0,0x5
    13ec:	aa050513          	addi	a0,a0,-1376 # 5e88 <malloc+0x536>
    13f0:	00004097          	auipc	ra,0x4
    13f4:	16a080e7          	jalr	362(ra) # 555a <open>
    13f8:	00004097          	auipc	ra,0x4
    13fc:	14a080e7          	jalr	330(ra) # 5542 <close>
  pid = fork();
    1400:	00004097          	auipc	ra,0x4
    1404:	112080e7          	jalr	274(ra) # 5512 <fork>
  if(pid < 0){
    1408:	08054063          	bltz	a0,1488 <truncate3+0xb8>
  if(pid == 0){
    140c:	e969                	bnez	a0,14de <truncate3+0x10e>
    140e:	06400913          	li	s2,100
      int fd = open("truncfile", O_WRONLY);
    1412:	00005997          	auipc	s3,0x5
    1416:	a7698993          	addi	s3,s3,-1418 # 5e88 <malloc+0x536>
      int n = write(fd, "1234567890", 10);
    141a:	00005a97          	auipc	s5,0x5
    141e:	29ea8a93          	addi	s5,s5,670 # 66b8 <malloc+0xd66>
      int fd = open("truncfile", O_WRONLY);
    1422:	4585                	li	a1,1
    1424:	854e                	mv	a0,s3
    1426:	00004097          	auipc	ra,0x4
    142a:	134080e7          	jalr	308(ra) # 555a <open>
    142e:	84aa                	mv	s1,a0
      if(fd < 0){
    1430:	06054a63          	bltz	a0,14a4 <truncate3+0xd4>
      int n = write(fd, "1234567890", 10);
    1434:	4629                	li	a2,10
    1436:	85d6                	mv	a1,s5
    1438:	00004097          	auipc	ra,0x4
    143c:	102080e7          	jalr	258(ra) # 553a <write>
      if(n != 10){
    1440:	47a9                	li	a5,10
    1442:	06f51f63          	bne	a0,a5,14c0 <truncate3+0xf0>
      close(fd);
    1446:	8526                	mv	a0,s1
    1448:	00004097          	auipc	ra,0x4
    144c:	0fa080e7          	jalr	250(ra) # 5542 <close>
      fd = open("truncfile", O_RDONLY);
    1450:	4581                	li	a1,0
    1452:	854e                	mv	a0,s3
    1454:	00004097          	auipc	ra,0x4
    1458:	106080e7          	jalr	262(ra) # 555a <open>
    145c:	84aa                	mv	s1,a0
      read(fd, buf, sizeof(buf));
    145e:	02000613          	li	a2,32
    1462:	f9840593          	addi	a1,s0,-104
    1466:	00004097          	auipc	ra,0x4
    146a:	0cc080e7          	jalr	204(ra) # 5532 <read>
      close(fd);
    146e:	8526                	mv	a0,s1
    1470:	00004097          	auipc	ra,0x4
    1474:	0d2080e7          	jalr	210(ra) # 5542 <close>
    for(int i = 0; i < 100; i++){
    1478:	397d                	addiw	s2,s2,-1
    147a:	fa0914e3          	bnez	s2,1422 <truncate3+0x52>
    exit(0);
    147e:	4501                	li	a0,0
    1480:	00004097          	auipc	ra,0x4
    1484:	09a080e7          	jalr	154(ra) # 551a <exit>
    printf("%s: fork failed\n", s);
    1488:	85d2                	mv	a1,s4
    148a:	00005517          	auipc	a0,0x5
    148e:	1fe50513          	addi	a0,a0,510 # 6688 <malloc+0xd36>
    1492:	00004097          	auipc	ra,0x4
    1496:	400080e7          	jalr	1024(ra) # 5892 <printf>
    exit(1);
    149a:	4505                	li	a0,1
    149c:	00004097          	auipc	ra,0x4
    14a0:	07e080e7          	jalr	126(ra) # 551a <exit>
        printf("%s: open failed\n", s);
    14a4:	85d2                	mv	a1,s4
    14a6:	00005517          	auipc	a0,0x5
    14aa:	1fa50513          	addi	a0,a0,506 # 66a0 <malloc+0xd4e>
    14ae:	00004097          	auipc	ra,0x4
    14b2:	3e4080e7          	jalr	996(ra) # 5892 <printf>
        exit(1);
    14b6:	4505                	li	a0,1
    14b8:	00004097          	auipc	ra,0x4
    14bc:	062080e7          	jalr	98(ra) # 551a <exit>
        printf("%s: write got %d, expected 10\n", s, n);
    14c0:	862a                	mv	a2,a0
    14c2:	85d2                	mv	a1,s4
    14c4:	00005517          	auipc	a0,0x5
    14c8:	20450513          	addi	a0,a0,516 # 66c8 <malloc+0xd76>
    14cc:	00004097          	auipc	ra,0x4
    14d0:	3c6080e7          	jalr	966(ra) # 5892 <printf>
        exit(1);
    14d4:	4505                	li	a0,1
    14d6:	00004097          	auipc	ra,0x4
    14da:	044080e7          	jalr	68(ra) # 551a <exit>
    14de:	09600913          	li	s2,150
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14e2:	00005997          	auipc	s3,0x5
    14e6:	9a698993          	addi	s3,s3,-1626 # 5e88 <malloc+0x536>
    int n = write(fd, "xxx", 3);
    14ea:	00005a97          	auipc	s5,0x5
    14ee:	1fea8a93          	addi	s5,s5,510 # 66e8 <malloc+0xd96>
    int fd = open("truncfile", O_CREATE|O_WRONLY|O_TRUNC);
    14f2:	60100593          	li	a1,1537
    14f6:	854e                	mv	a0,s3
    14f8:	00004097          	auipc	ra,0x4
    14fc:	062080e7          	jalr	98(ra) # 555a <open>
    1500:	84aa                	mv	s1,a0
    if(fd < 0){
    1502:	04054763          	bltz	a0,1550 <truncate3+0x180>
    int n = write(fd, "xxx", 3);
    1506:	460d                	li	a2,3
    1508:	85d6                	mv	a1,s5
    150a:	00004097          	auipc	ra,0x4
    150e:	030080e7          	jalr	48(ra) # 553a <write>
    if(n != 3){
    1512:	478d                	li	a5,3
    1514:	04f51c63          	bne	a0,a5,156c <truncate3+0x19c>
    close(fd);
    1518:	8526                	mv	a0,s1
    151a:	00004097          	auipc	ra,0x4
    151e:	028080e7          	jalr	40(ra) # 5542 <close>
  for(int i = 0; i < 150; i++){
    1522:	397d                	addiw	s2,s2,-1
    1524:	fc0917e3          	bnez	s2,14f2 <truncate3+0x122>
  wait(&xstatus);
    1528:	fbc40513          	addi	a0,s0,-68
    152c:	00004097          	auipc	ra,0x4
    1530:	ff6080e7          	jalr	-10(ra) # 5522 <wait>
  unlink("truncfile");
    1534:	00005517          	auipc	a0,0x5
    1538:	95450513          	addi	a0,a0,-1708 # 5e88 <malloc+0x536>
    153c:	00004097          	auipc	ra,0x4
    1540:	02e080e7          	jalr	46(ra) # 556a <unlink>
  exit(xstatus);
    1544:	fbc42503          	lw	a0,-68(s0)
    1548:	00004097          	auipc	ra,0x4
    154c:	fd2080e7          	jalr	-46(ra) # 551a <exit>
      printf("%s: open failed\n", s);
    1550:	85d2                	mv	a1,s4
    1552:	00005517          	auipc	a0,0x5
    1556:	14e50513          	addi	a0,a0,334 # 66a0 <malloc+0xd4e>
    155a:	00004097          	auipc	ra,0x4
    155e:	338080e7          	jalr	824(ra) # 5892 <printf>
      exit(1);
    1562:	4505                	li	a0,1
    1564:	00004097          	auipc	ra,0x4
    1568:	fb6080e7          	jalr	-74(ra) # 551a <exit>
      printf("%s: write got %d, expected 3\n", s, n);
    156c:	862a                	mv	a2,a0
    156e:	85d2                	mv	a1,s4
    1570:	00005517          	auipc	a0,0x5
    1574:	18050513          	addi	a0,a0,384 # 66f0 <malloc+0xd9e>
    1578:	00004097          	auipc	ra,0x4
    157c:	31a080e7          	jalr	794(ra) # 5892 <printf>
      exit(1);
    1580:	4505                	li	a0,1
    1582:	00004097          	auipc	ra,0x4
    1586:	f98080e7          	jalr	-104(ra) # 551a <exit>

000000000000158a <exectest>:
{
    158a:	715d                	addi	sp,sp,-80
    158c:	e486                	sd	ra,72(sp)
    158e:	e0a2                	sd	s0,64(sp)
    1590:	fc26                	sd	s1,56(sp)
    1592:	f84a                	sd	s2,48(sp)
    1594:	0880                	addi	s0,sp,80
    1596:	892a                	mv	s2,a0
  char *echoargv[] = { "echo", "OK", 0 };
    1598:	00005797          	auipc	a5,0x5
    159c:	89878793          	addi	a5,a5,-1896 # 5e30 <malloc+0x4de>
    15a0:	fcf43023          	sd	a5,-64(s0)
    15a4:	00005797          	auipc	a5,0x5
    15a8:	16c78793          	addi	a5,a5,364 # 6710 <malloc+0xdbe>
    15ac:	fcf43423          	sd	a5,-56(s0)
    15b0:	fc043823          	sd	zero,-48(s0)
  unlink("echo-ok");
    15b4:	00005517          	auipc	a0,0x5
    15b8:	16450513          	addi	a0,a0,356 # 6718 <malloc+0xdc6>
    15bc:	00004097          	auipc	ra,0x4
    15c0:	fae080e7          	jalr	-82(ra) # 556a <unlink>
  pid = fork();
    15c4:	00004097          	auipc	ra,0x4
    15c8:	f4e080e7          	jalr	-178(ra) # 5512 <fork>
  if(pid < 0) {
    15cc:	04054663          	bltz	a0,1618 <exectest+0x8e>
    15d0:	84aa                	mv	s1,a0
  if(pid == 0) {
    15d2:	e959                	bnez	a0,1668 <exectest+0xde>
    close(1);
    15d4:	4505                	li	a0,1
    15d6:	00004097          	auipc	ra,0x4
    15da:	f6c080e7          	jalr	-148(ra) # 5542 <close>
    fd = open("echo-ok", O_CREATE|O_WRONLY);
    15de:	20100593          	li	a1,513
    15e2:	00005517          	auipc	a0,0x5
    15e6:	13650513          	addi	a0,a0,310 # 6718 <malloc+0xdc6>
    15ea:	00004097          	auipc	ra,0x4
    15ee:	f70080e7          	jalr	-144(ra) # 555a <open>
    if(fd < 0) {
    15f2:	04054163          	bltz	a0,1634 <exectest+0xaa>
    if(fd != 1) {
    15f6:	4785                	li	a5,1
    15f8:	04f50c63          	beq	a0,a5,1650 <exectest+0xc6>
      printf("%s: wrong fd\n", s);
    15fc:	85ca                	mv	a1,s2
    15fe:	00005517          	auipc	a0,0x5
    1602:	13a50513          	addi	a0,a0,314 # 6738 <malloc+0xde6>
    1606:	00004097          	auipc	ra,0x4
    160a:	28c080e7          	jalr	652(ra) # 5892 <printf>
      exit(1);
    160e:	4505                	li	a0,1
    1610:	00004097          	auipc	ra,0x4
    1614:	f0a080e7          	jalr	-246(ra) # 551a <exit>
     printf("%s: fork failed\n", s);
    1618:	85ca                	mv	a1,s2
    161a:	00005517          	auipc	a0,0x5
    161e:	06e50513          	addi	a0,a0,110 # 6688 <malloc+0xd36>
    1622:	00004097          	auipc	ra,0x4
    1626:	270080e7          	jalr	624(ra) # 5892 <printf>
     exit(1);
    162a:	4505                	li	a0,1
    162c:	00004097          	auipc	ra,0x4
    1630:	eee080e7          	jalr	-274(ra) # 551a <exit>
      printf("%s: create failed\n", s);
    1634:	85ca                	mv	a1,s2
    1636:	00005517          	auipc	a0,0x5
    163a:	0ea50513          	addi	a0,a0,234 # 6720 <malloc+0xdce>
    163e:	00004097          	auipc	ra,0x4
    1642:	254080e7          	jalr	596(ra) # 5892 <printf>
      exit(1);
    1646:	4505                	li	a0,1
    1648:	00004097          	auipc	ra,0x4
    164c:	ed2080e7          	jalr	-302(ra) # 551a <exit>
    if(exec("echo", echoargv) < 0){
    1650:	fc040593          	addi	a1,s0,-64
    1654:	00004517          	auipc	a0,0x4
    1658:	7dc50513          	addi	a0,a0,2012 # 5e30 <malloc+0x4de>
    165c:	00004097          	auipc	ra,0x4
    1660:	ef6080e7          	jalr	-266(ra) # 5552 <exec>
    1664:	02054163          	bltz	a0,1686 <exectest+0xfc>
  if (wait(&xstatus) != pid) {
    1668:	fdc40513          	addi	a0,s0,-36
    166c:	00004097          	auipc	ra,0x4
    1670:	eb6080e7          	jalr	-330(ra) # 5522 <wait>
    1674:	02951763          	bne	a0,s1,16a2 <exectest+0x118>
  if(xstatus != 0)
    1678:	fdc42503          	lw	a0,-36(s0)
    167c:	cd0d                	beqz	a0,16b6 <exectest+0x12c>
    exit(xstatus);
    167e:	00004097          	auipc	ra,0x4
    1682:	e9c080e7          	jalr	-356(ra) # 551a <exit>
      printf("%s: exec echo failed\n", s);
    1686:	85ca                	mv	a1,s2
    1688:	00005517          	auipc	a0,0x5
    168c:	0c050513          	addi	a0,a0,192 # 6748 <malloc+0xdf6>
    1690:	00004097          	auipc	ra,0x4
    1694:	202080e7          	jalr	514(ra) # 5892 <printf>
      exit(1);
    1698:	4505                	li	a0,1
    169a:	00004097          	auipc	ra,0x4
    169e:	e80080e7          	jalr	-384(ra) # 551a <exit>
    printf("%s: wait failed!\n", s);
    16a2:	85ca                	mv	a1,s2
    16a4:	00005517          	auipc	a0,0x5
    16a8:	0bc50513          	addi	a0,a0,188 # 6760 <malloc+0xe0e>
    16ac:	00004097          	auipc	ra,0x4
    16b0:	1e6080e7          	jalr	486(ra) # 5892 <printf>
    16b4:	b7d1                	j	1678 <exectest+0xee>
  fd = open("echo-ok", O_RDONLY);
    16b6:	4581                	li	a1,0
    16b8:	00005517          	auipc	a0,0x5
    16bc:	06050513          	addi	a0,a0,96 # 6718 <malloc+0xdc6>
    16c0:	00004097          	auipc	ra,0x4
    16c4:	e9a080e7          	jalr	-358(ra) # 555a <open>
  if(fd < 0) {
    16c8:	02054a63          	bltz	a0,16fc <exectest+0x172>
  if (read(fd, buf, 2) != 2) {
    16cc:	4609                	li	a2,2
    16ce:	fb840593          	addi	a1,s0,-72
    16d2:	00004097          	auipc	ra,0x4
    16d6:	e60080e7          	jalr	-416(ra) # 5532 <read>
    16da:	4789                	li	a5,2
    16dc:	02f50e63          	beq	a0,a5,1718 <exectest+0x18e>
    printf("%s: read failed\n", s);
    16e0:	85ca                	mv	a1,s2
    16e2:	00005517          	auipc	a0,0x5
    16e6:	aee50513          	addi	a0,a0,-1298 # 61d0 <malloc+0x87e>
    16ea:	00004097          	auipc	ra,0x4
    16ee:	1a8080e7          	jalr	424(ra) # 5892 <printf>
    exit(1);
    16f2:	4505                	li	a0,1
    16f4:	00004097          	auipc	ra,0x4
    16f8:	e26080e7          	jalr	-474(ra) # 551a <exit>
    printf("%s: open failed\n", s);
    16fc:	85ca                	mv	a1,s2
    16fe:	00005517          	auipc	a0,0x5
    1702:	fa250513          	addi	a0,a0,-94 # 66a0 <malloc+0xd4e>
    1706:	00004097          	auipc	ra,0x4
    170a:	18c080e7          	jalr	396(ra) # 5892 <printf>
    exit(1);
    170e:	4505                	li	a0,1
    1710:	00004097          	auipc	ra,0x4
    1714:	e0a080e7          	jalr	-502(ra) # 551a <exit>
  unlink("echo-ok");
    1718:	00005517          	auipc	a0,0x5
    171c:	00050513          	mv	a0,a0
    1720:	00004097          	auipc	ra,0x4
    1724:	e4a080e7          	jalr	-438(ra) # 556a <unlink>
  if(buf[0] == 'O' && buf[1] == 'K')
    1728:	fb844703          	lbu	a4,-72(s0)
    172c:	04f00793          	li	a5,79
    1730:	00f71863          	bne	a4,a5,1740 <exectest+0x1b6>
    1734:	fb944703          	lbu	a4,-71(s0)
    1738:	04b00793          	li	a5,75
    173c:	02f70063          	beq	a4,a5,175c <exectest+0x1d2>
    printf("%s: wrong output\n", s);
    1740:	85ca                	mv	a1,s2
    1742:	00005517          	auipc	a0,0x5
    1746:	03650513          	addi	a0,a0,54 # 6778 <malloc+0xe26>
    174a:	00004097          	auipc	ra,0x4
    174e:	148080e7          	jalr	328(ra) # 5892 <printf>
    exit(1);
    1752:	4505                	li	a0,1
    1754:	00004097          	auipc	ra,0x4
    1758:	dc6080e7          	jalr	-570(ra) # 551a <exit>
    exit(0);
    175c:	4501                	li	a0,0
    175e:	00004097          	auipc	ra,0x4
    1762:	dbc080e7          	jalr	-580(ra) # 551a <exit>

0000000000001766 <pipe1>:
{
    1766:	715d                	addi	sp,sp,-80
    1768:	e486                	sd	ra,72(sp)
    176a:	e0a2                	sd	s0,64(sp)
    176c:	fc26                	sd	s1,56(sp)
    176e:	f84a                	sd	s2,48(sp)
    1770:	f44e                	sd	s3,40(sp)
    1772:	f052                	sd	s4,32(sp)
    1774:	ec56                	sd	s5,24(sp)
    1776:	e85a                	sd	s6,16(sp)
    1778:	0880                	addi	s0,sp,80
    177a:	89aa                	mv	s3,a0
  if(pipe(fds) != 0){
    177c:	fb840513          	addi	a0,s0,-72
    1780:	00004097          	auipc	ra,0x4
    1784:	daa080e7          	jalr	-598(ra) # 552a <pipe>
    1788:	e935                	bnez	a0,17fc <pipe1+0x96>
    178a:	84aa                	mv	s1,a0
  pid = fork();
    178c:	00004097          	auipc	ra,0x4
    1790:	d86080e7          	jalr	-634(ra) # 5512 <fork>
  if(pid == 0){
    1794:	c151                	beqz	a0,1818 <pipe1+0xb2>
  } else if(pid > 0){
    1796:	18a05963          	blez	a0,1928 <pipe1+0x1c2>
    close(fds[1]);
    179a:	fbc42503          	lw	a0,-68(s0)
    179e:	00004097          	auipc	ra,0x4
    17a2:	da4080e7          	jalr	-604(ra) # 5542 <close>
    total = 0;
    17a6:	8aa6                	mv	s5,s1
    cc = 1;
    17a8:	4a05                	li	s4,1
    while((n = read(fds[0], buf, cc)) > 0){
    17aa:	0000a917          	auipc	s2,0xa
    17ae:	1ce90913          	addi	s2,s2,462 # b978 <buf>
      if(cc > sizeof(buf))
    17b2:	6b0d                	lui	s6,0x3
    while((n = read(fds[0], buf, cc)) > 0){
    17b4:	8652                	mv	a2,s4
    17b6:	85ca                	mv	a1,s2
    17b8:	fb842503          	lw	a0,-72(s0)
    17bc:	00004097          	auipc	ra,0x4
    17c0:	d76080e7          	jalr	-650(ra) # 5532 <read>
    17c4:	10a05d63          	blez	a0,18de <pipe1+0x178>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17c8:	0014879b          	addiw	a5,s1,1
    17cc:	00094683          	lbu	a3,0(s2)
    17d0:	0ff4f713          	andi	a4,s1,255
    17d4:	0ce69863          	bne	a3,a4,18a4 <pipe1+0x13e>
    17d8:	0000a717          	auipc	a4,0xa
    17dc:	1a170713          	addi	a4,a4,417 # b979 <buf+0x1>
    17e0:	9ca9                	addw	s1,s1,a0
      for(i = 0; i < n; i++){
    17e2:	0e978463          	beq	a5,s1,18ca <pipe1+0x164>
        if((buf[i] & 0xff) != (seq++ & 0xff)){
    17e6:	00074683          	lbu	a3,0(a4)
    17ea:	0017861b          	addiw	a2,a5,1
    17ee:	0705                	addi	a4,a4,1
    17f0:	0ff7f793          	andi	a5,a5,255
    17f4:	0af69863          	bne	a3,a5,18a4 <pipe1+0x13e>
    17f8:	87b2                	mv	a5,a2
    17fa:	b7e5                	j	17e2 <pipe1+0x7c>
    printf("%s: pipe() failed\n", s);
    17fc:	85ce                	mv	a1,s3
    17fe:	00005517          	auipc	a0,0x5
    1802:	f9250513          	addi	a0,a0,-110 # 6790 <malloc+0xe3e>
    1806:	00004097          	auipc	ra,0x4
    180a:	08c080e7          	jalr	140(ra) # 5892 <printf>
    exit(1);
    180e:	4505                	li	a0,1
    1810:	00004097          	auipc	ra,0x4
    1814:	d0a080e7          	jalr	-758(ra) # 551a <exit>
    close(fds[0]);
    1818:	fb842503          	lw	a0,-72(s0)
    181c:	00004097          	auipc	ra,0x4
    1820:	d26080e7          	jalr	-730(ra) # 5542 <close>
    for(n = 0; n < N; n++){
    1824:	0000aa97          	auipc	s5,0xa
    1828:	154a8a93          	addi	s5,s5,340 # b978 <buf>
    182c:	0ffaf793          	andi	a5,s5,255
    1830:	40f004b3          	neg	s1,a5
    1834:	0ff4f493          	andi	s1,s1,255
    1838:	02d00a13          	li	s4,45
    183c:	40fa0a3b          	subw	s4,s4,a5
    1840:	0ffa7a13          	andi	s4,s4,255
    1844:	409a8913          	addi	s2,s5,1033
      if(write(fds[1], buf, SZ) != SZ){
    1848:	8b56                	mv	s6,s5
{
    184a:	87d6                	mv	a5,s5
        buf[i] = seq++;
    184c:	0097873b          	addw	a4,a5,s1
    1850:	00e78023          	sb	a4,0(a5)
      for(i = 0; i < SZ; i++)
    1854:	0785                	addi	a5,a5,1
    1856:	fef91be3          	bne	s2,a5,184c <pipe1+0xe6>
      if(write(fds[1], buf, SZ) != SZ){
    185a:	40900613          	li	a2,1033
    185e:	85da                	mv	a1,s6
    1860:	fbc42503          	lw	a0,-68(s0)
    1864:	00004097          	auipc	ra,0x4
    1868:	cd6080e7          	jalr	-810(ra) # 553a <write>
    186c:	40900793          	li	a5,1033
    1870:	00f51c63          	bne	a0,a5,1888 <pipe1+0x122>
    for(n = 0; n < N; n++){
    1874:	24a5                	addiw	s1,s1,9
    1876:	0ff4f493          	andi	s1,s1,255
    187a:	fd4498e3          	bne	s1,s4,184a <pipe1+0xe4>
    exit(0);
    187e:	4501                	li	a0,0
    1880:	00004097          	auipc	ra,0x4
    1884:	c9a080e7          	jalr	-870(ra) # 551a <exit>
        printf("%s: pipe1 oops 1\n", s);
    1888:	85ce                	mv	a1,s3
    188a:	00005517          	auipc	a0,0x5
    188e:	f1e50513          	addi	a0,a0,-226 # 67a8 <malloc+0xe56>
    1892:	00004097          	auipc	ra,0x4
    1896:	000080e7          	jalr	ra # 5892 <printf>
        exit(1);
    189a:	4505                	li	a0,1
    189c:	00004097          	auipc	ra,0x4
    18a0:	c7e080e7          	jalr	-898(ra) # 551a <exit>
          printf("%s: pipe1 oops 2\n", s);
    18a4:	85ce                	mv	a1,s3
    18a6:	00005517          	auipc	a0,0x5
    18aa:	f1a50513          	addi	a0,a0,-230 # 67c0 <malloc+0xe6e>
    18ae:	00004097          	auipc	ra,0x4
    18b2:	fe4080e7          	jalr	-28(ra) # 5892 <printf>
}
    18b6:	60a6                	ld	ra,72(sp)
    18b8:	6406                	ld	s0,64(sp)
    18ba:	74e2                	ld	s1,56(sp)
    18bc:	7942                	ld	s2,48(sp)
    18be:	79a2                	ld	s3,40(sp)
    18c0:	7a02                	ld	s4,32(sp)
    18c2:	6ae2                	ld	s5,24(sp)
    18c4:	6b42                	ld	s6,16(sp)
    18c6:	6161                	addi	sp,sp,80
    18c8:	8082                	ret
      total += n;
    18ca:	00aa8abb          	addw	s5,s5,a0
      cc = cc * 2;
    18ce:	001a179b          	slliw	a5,s4,0x1
    18d2:	00078a1b          	sext.w	s4,a5
      if(cc > sizeof(buf))
    18d6:	ed4b7fe3          	bleu	s4,s6,17b4 <pipe1+0x4e>
        cc = sizeof(buf);
    18da:	8a5a                	mv	s4,s6
    18dc:	bde1                	j	17b4 <pipe1+0x4e>
    if(total != N * SZ){
    18de:	6785                	lui	a5,0x1
    18e0:	42d78793          	addi	a5,a5,1069 # 142d <truncate3+0x5d>
    18e4:	02fa8063          	beq	s5,a5,1904 <pipe1+0x19e>
      printf("%s: pipe1 oops 3 total %d\n", total);
    18e8:	85d6                	mv	a1,s5
    18ea:	00005517          	auipc	a0,0x5
    18ee:	eee50513          	addi	a0,a0,-274 # 67d8 <malloc+0xe86>
    18f2:	00004097          	auipc	ra,0x4
    18f6:	fa0080e7          	jalr	-96(ra) # 5892 <printf>
      exit(1);
    18fa:	4505                	li	a0,1
    18fc:	00004097          	auipc	ra,0x4
    1900:	c1e080e7          	jalr	-994(ra) # 551a <exit>
    close(fds[0]);
    1904:	fb842503          	lw	a0,-72(s0)
    1908:	00004097          	auipc	ra,0x4
    190c:	c3a080e7          	jalr	-966(ra) # 5542 <close>
    wait(&xstatus);
    1910:	fb440513          	addi	a0,s0,-76
    1914:	00004097          	auipc	ra,0x4
    1918:	c0e080e7          	jalr	-1010(ra) # 5522 <wait>
    exit(xstatus);
    191c:	fb442503          	lw	a0,-76(s0)
    1920:	00004097          	auipc	ra,0x4
    1924:	bfa080e7          	jalr	-1030(ra) # 551a <exit>
    printf("%s: fork() failed\n", s);
    1928:	85ce                	mv	a1,s3
    192a:	00005517          	auipc	a0,0x5
    192e:	ece50513          	addi	a0,a0,-306 # 67f8 <malloc+0xea6>
    1932:	00004097          	auipc	ra,0x4
    1936:	f60080e7          	jalr	-160(ra) # 5892 <printf>
    exit(1);
    193a:	4505                	li	a0,1
    193c:	00004097          	auipc	ra,0x4
    1940:	bde080e7          	jalr	-1058(ra) # 551a <exit>

0000000000001944 <exitwait>:
{
    1944:	7139                	addi	sp,sp,-64
    1946:	fc06                	sd	ra,56(sp)
    1948:	f822                	sd	s0,48(sp)
    194a:	f426                	sd	s1,40(sp)
    194c:	f04a                	sd	s2,32(sp)
    194e:	ec4e                	sd	s3,24(sp)
    1950:	e852                	sd	s4,16(sp)
    1952:	0080                	addi	s0,sp,64
    1954:	8a2a                	mv	s4,a0
  for(i = 0; i < 100; i++){
    1956:	4481                	li	s1,0
    1958:	06400993          	li	s3,100
    pid = fork();
    195c:	00004097          	auipc	ra,0x4
    1960:	bb6080e7          	jalr	-1098(ra) # 5512 <fork>
    1964:	892a                	mv	s2,a0
    if(pid < 0){
    1966:	02054a63          	bltz	a0,199a <exitwait+0x56>
    if(pid){
    196a:	c151                	beqz	a0,19ee <exitwait+0xaa>
      if(wait(&xstate) != pid){
    196c:	fcc40513          	addi	a0,s0,-52
    1970:	00004097          	auipc	ra,0x4
    1974:	bb2080e7          	jalr	-1102(ra) # 5522 <wait>
    1978:	03251f63          	bne	a0,s2,19b6 <exitwait+0x72>
      if(i != xstate) {
    197c:	fcc42783          	lw	a5,-52(s0)
    1980:	04979963          	bne	a5,s1,19d2 <exitwait+0x8e>
  for(i = 0; i < 100; i++){
    1984:	2485                	addiw	s1,s1,1
    1986:	fd349be3          	bne	s1,s3,195c <exitwait+0x18>
}
    198a:	70e2                	ld	ra,56(sp)
    198c:	7442                	ld	s0,48(sp)
    198e:	74a2                	ld	s1,40(sp)
    1990:	7902                	ld	s2,32(sp)
    1992:	69e2                	ld	s3,24(sp)
    1994:	6a42                	ld	s4,16(sp)
    1996:	6121                	addi	sp,sp,64
    1998:	8082                	ret
      printf("%s: fork failed\n", s);
    199a:	85d2                	mv	a1,s4
    199c:	00005517          	auipc	a0,0x5
    19a0:	cec50513          	addi	a0,a0,-788 # 6688 <malloc+0xd36>
    19a4:	00004097          	auipc	ra,0x4
    19a8:	eee080e7          	jalr	-274(ra) # 5892 <printf>
      exit(1);
    19ac:	4505                	li	a0,1
    19ae:	00004097          	auipc	ra,0x4
    19b2:	b6c080e7          	jalr	-1172(ra) # 551a <exit>
        printf("%s: wait wrong pid\n", s);
    19b6:	85d2                	mv	a1,s4
    19b8:	00005517          	auipc	a0,0x5
    19bc:	e5850513          	addi	a0,a0,-424 # 6810 <malloc+0xebe>
    19c0:	00004097          	auipc	ra,0x4
    19c4:	ed2080e7          	jalr	-302(ra) # 5892 <printf>
        exit(1);
    19c8:	4505                	li	a0,1
    19ca:	00004097          	auipc	ra,0x4
    19ce:	b50080e7          	jalr	-1200(ra) # 551a <exit>
        printf("%s: wait wrong exit status\n", s);
    19d2:	85d2                	mv	a1,s4
    19d4:	00005517          	auipc	a0,0x5
    19d8:	e5450513          	addi	a0,a0,-428 # 6828 <malloc+0xed6>
    19dc:	00004097          	auipc	ra,0x4
    19e0:	eb6080e7          	jalr	-330(ra) # 5892 <printf>
        exit(1);
    19e4:	4505                	li	a0,1
    19e6:	00004097          	auipc	ra,0x4
    19ea:	b34080e7          	jalr	-1228(ra) # 551a <exit>
      exit(i);
    19ee:	8526                	mv	a0,s1
    19f0:	00004097          	auipc	ra,0x4
    19f4:	b2a080e7          	jalr	-1238(ra) # 551a <exit>

00000000000019f8 <twochildren>:
{
    19f8:	1101                	addi	sp,sp,-32
    19fa:	ec06                	sd	ra,24(sp)
    19fc:	e822                	sd	s0,16(sp)
    19fe:	e426                	sd	s1,8(sp)
    1a00:	e04a                	sd	s2,0(sp)
    1a02:	1000                	addi	s0,sp,32
    1a04:	892a                	mv	s2,a0
    1a06:	3e800493          	li	s1,1000
    int pid1 = fork();
    1a0a:	00004097          	auipc	ra,0x4
    1a0e:	b08080e7          	jalr	-1272(ra) # 5512 <fork>
    if(pid1 < 0){
    1a12:	02054c63          	bltz	a0,1a4a <twochildren+0x52>
    if(pid1 == 0){
    1a16:	c921                	beqz	a0,1a66 <twochildren+0x6e>
      int pid2 = fork();
    1a18:	00004097          	auipc	ra,0x4
    1a1c:	afa080e7          	jalr	-1286(ra) # 5512 <fork>
      if(pid2 < 0){
    1a20:	04054763          	bltz	a0,1a6e <twochildren+0x76>
      if(pid2 == 0){
    1a24:	c13d                	beqz	a0,1a8a <twochildren+0x92>
        wait(0);
    1a26:	4501                	li	a0,0
    1a28:	00004097          	auipc	ra,0x4
    1a2c:	afa080e7          	jalr	-1286(ra) # 5522 <wait>
        wait(0);
    1a30:	4501                	li	a0,0
    1a32:	00004097          	auipc	ra,0x4
    1a36:	af0080e7          	jalr	-1296(ra) # 5522 <wait>
  for(int i = 0; i < 1000; i++){
    1a3a:	34fd                	addiw	s1,s1,-1
    1a3c:	f4f9                	bnez	s1,1a0a <twochildren+0x12>
}
    1a3e:	60e2                	ld	ra,24(sp)
    1a40:	6442                	ld	s0,16(sp)
    1a42:	64a2                	ld	s1,8(sp)
    1a44:	6902                	ld	s2,0(sp)
    1a46:	6105                	addi	sp,sp,32
    1a48:	8082                	ret
      printf("%s: fork failed\n", s);
    1a4a:	85ca                	mv	a1,s2
    1a4c:	00005517          	auipc	a0,0x5
    1a50:	c3c50513          	addi	a0,a0,-964 # 6688 <malloc+0xd36>
    1a54:	00004097          	auipc	ra,0x4
    1a58:	e3e080e7          	jalr	-450(ra) # 5892 <printf>
      exit(1);
    1a5c:	4505                	li	a0,1
    1a5e:	00004097          	auipc	ra,0x4
    1a62:	abc080e7          	jalr	-1348(ra) # 551a <exit>
      exit(0);
    1a66:	00004097          	auipc	ra,0x4
    1a6a:	ab4080e7          	jalr	-1356(ra) # 551a <exit>
        printf("%s: fork failed\n", s);
    1a6e:	85ca                	mv	a1,s2
    1a70:	00005517          	auipc	a0,0x5
    1a74:	c1850513          	addi	a0,a0,-1000 # 6688 <malloc+0xd36>
    1a78:	00004097          	auipc	ra,0x4
    1a7c:	e1a080e7          	jalr	-486(ra) # 5892 <printf>
        exit(1);
    1a80:	4505                	li	a0,1
    1a82:	00004097          	auipc	ra,0x4
    1a86:	a98080e7          	jalr	-1384(ra) # 551a <exit>
        exit(0);
    1a8a:	00004097          	auipc	ra,0x4
    1a8e:	a90080e7          	jalr	-1392(ra) # 551a <exit>

0000000000001a92 <forkfork>:
{
    1a92:	7179                	addi	sp,sp,-48
    1a94:	f406                	sd	ra,40(sp)
    1a96:	f022                	sd	s0,32(sp)
    1a98:	ec26                	sd	s1,24(sp)
    1a9a:	1800                	addi	s0,sp,48
    1a9c:	84aa                	mv	s1,a0
    int pid = fork();
    1a9e:	00004097          	auipc	ra,0x4
    1aa2:	a74080e7          	jalr	-1420(ra) # 5512 <fork>
    if(pid < 0){
    1aa6:	04054163          	bltz	a0,1ae8 <forkfork+0x56>
    if(pid == 0){
    1aaa:	cd29                	beqz	a0,1b04 <forkfork+0x72>
    int pid = fork();
    1aac:	00004097          	auipc	ra,0x4
    1ab0:	a66080e7          	jalr	-1434(ra) # 5512 <fork>
    if(pid < 0){
    1ab4:	02054a63          	bltz	a0,1ae8 <forkfork+0x56>
    if(pid == 0){
    1ab8:	c531                	beqz	a0,1b04 <forkfork+0x72>
    wait(&xstatus);
    1aba:	fdc40513          	addi	a0,s0,-36
    1abe:	00004097          	auipc	ra,0x4
    1ac2:	a64080e7          	jalr	-1436(ra) # 5522 <wait>
    if(xstatus != 0) {
    1ac6:	fdc42783          	lw	a5,-36(s0)
    1aca:	ebbd                	bnez	a5,1b40 <forkfork+0xae>
    wait(&xstatus);
    1acc:	fdc40513          	addi	a0,s0,-36
    1ad0:	00004097          	auipc	ra,0x4
    1ad4:	a52080e7          	jalr	-1454(ra) # 5522 <wait>
    if(xstatus != 0) {
    1ad8:	fdc42783          	lw	a5,-36(s0)
    1adc:	e3b5                	bnez	a5,1b40 <forkfork+0xae>
}
    1ade:	70a2                	ld	ra,40(sp)
    1ae0:	7402                	ld	s0,32(sp)
    1ae2:	64e2                	ld	s1,24(sp)
    1ae4:	6145                	addi	sp,sp,48
    1ae6:	8082                	ret
      printf("%s: fork failed", s);
    1ae8:	85a6                	mv	a1,s1
    1aea:	00005517          	auipc	a0,0x5
    1aee:	d5e50513          	addi	a0,a0,-674 # 6848 <malloc+0xef6>
    1af2:	00004097          	auipc	ra,0x4
    1af6:	da0080e7          	jalr	-608(ra) # 5892 <printf>
      exit(1);
    1afa:	4505                	li	a0,1
    1afc:	00004097          	auipc	ra,0x4
    1b00:	a1e080e7          	jalr	-1506(ra) # 551a <exit>
{
    1b04:	0c800493          	li	s1,200
        int pid1 = fork();
    1b08:	00004097          	auipc	ra,0x4
    1b0c:	a0a080e7          	jalr	-1526(ra) # 5512 <fork>
        if(pid1 < 0){
    1b10:	00054f63          	bltz	a0,1b2e <forkfork+0x9c>
        if(pid1 == 0){
    1b14:	c115                	beqz	a0,1b38 <forkfork+0xa6>
        wait(0);
    1b16:	4501                	li	a0,0
    1b18:	00004097          	auipc	ra,0x4
    1b1c:	a0a080e7          	jalr	-1526(ra) # 5522 <wait>
      for(int j = 0; j < 200; j++){
    1b20:	34fd                	addiw	s1,s1,-1
    1b22:	f0fd                	bnez	s1,1b08 <forkfork+0x76>
      exit(0);
    1b24:	4501                	li	a0,0
    1b26:	00004097          	auipc	ra,0x4
    1b2a:	9f4080e7          	jalr	-1548(ra) # 551a <exit>
          exit(1);
    1b2e:	4505                	li	a0,1
    1b30:	00004097          	auipc	ra,0x4
    1b34:	9ea080e7          	jalr	-1558(ra) # 551a <exit>
          exit(0);
    1b38:	00004097          	auipc	ra,0x4
    1b3c:	9e2080e7          	jalr	-1566(ra) # 551a <exit>
      printf("%s: fork in child failed", s);
    1b40:	85a6                	mv	a1,s1
    1b42:	00005517          	auipc	a0,0x5
    1b46:	d1650513          	addi	a0,a0,-746 # 6858 <malloc+0xf06>
    1b4a:	00004097          	auipc	ra,0x4
    1b4e:	d48080e7          	jalr	-696(ra) # 5892 <printf>
      exit(1);
    1b52:	4505                	li	a0,1
    1b54:	00004097          	auipc	ra,0x4
    1b58:	9c6080e7          	jalr	-1594(ra) # 551a <exit>

0000000000001b5c <reparent2>:
{
    1b5c:	1101                	addi	sp,sp,-32
    1b5e:	ec06                	sd	ra,24(sp)
    1b60:	e822                	sd	s0,16(sp)
    1b62:	e426                	sd	s1,8(sp)
    1b64:	1000                	addi	s0,sp,32
    1b66:	32000493          	li	s1,800
    int pid1 = fork();
    1b6a:	00004097          	auipc	ra,0x4
    1b6e:	9a8080e7          	jalr	-1624(ra) # 5512 <fork>
    if(pid1 < 0){
    1b72:	00054f63          	bltz	a0,1b90 <reparent2+0x34>
    if(pid1 == 0){
    1b76:	c915                	beqz	a0,1baa <reparent2+0x4e>
    wait(0);
    1b78:	4501                	li	a0,0
    1b7a:	00004097          	auipc	ra,0x4
    1b7e:	9a8080e7          	jalr	-1624(ra) # 5522 <wait>
  for(int i = 0; i < 800; i++){
    1b82:	34fd                	addiw	s1,s1,-1
    1b84:	f0fd                	bnez	s1,1b6a <reparent2+0xe>
  exit(0);
    1b86:	4501                	li	a0,0
    1b88:	00004097          	auipc	ra,0x4
    1b8c:	992080e7          	jalr	-1646(ra) # 551a <exit>
      printf("fork failed\n");
    1b90:	00005517          	auipc	a0,0x5
    1b94:	ee850513          	addi	a0,a0,-280 # 6a78 <malloc+0x1126>
    1b98:	00004097          	auipc	ra,0x4
    1b9c:	cfa080e7          	jalr	-774(ra) # 5892 <printf>
      exit(1);
    1ba0:	4505                	li	a0,1
    1ba2:	00004097          	auipc	ra,0x4
    1ba6:	978080e7          	jalr	-1672(ra) # 551a <exit>
      fork();
    1baa:	00004097          	auipc	ra,0x4
    1bae:	968080e7          	jalr	-1688(ra) # 5512 <fork>
      fork();
    1bb2:	00004097          	auipc	ra,0x4
    1bb6:	960080e7          	jalr	-1696(ra) # 5512 <fork>
      exit(0);
    1bba:	4501                	li	a0,0
    1bbc:	00004097          	auipc	ra,0x4
    1bc0:	95e080e7          	jalr	-1698(ra) # 551a <exit>

0000000000001bc4 <createdelete>:
{
    1bc4:	7175                	addi	sp,sp,-144
    1bc6:	e506                	sd	ra,136(sp)
    1bc8:	e122                	sd	s0,128(sp)
    1bca:	fca6                	sd	s1,120(sp)
    1bcc:	f8ca                	sd	s2,112(sp)
    1bce:	f4ce                	sd	s3,104(sp)
    1bd0:	f0d2                	sd	s4,96(sp)
    1bd2:	ecd6                	sd	s5,88(sp)
    1bd4:	e8da                	sd	s6,80(sp)
    1bd6:	e4de                	sd	s7,72(sp)
    1bd8:	e0e2                	sd	s8,64(sp)
    1bda:	fc66                	sd	s9,56(sp)
    1bdc:	0900                	addi	s0,sp,144
    1bde:	8caa                	mv	s9,a0
  for(pi = 0; pi < NCHILD; pi++){
    1be0:	4901                	li	s2,0
    1be2:	4991                	li	s3,4
    pid = fork();
    1be4:	00004097          	auipc	ra,0x4
    1be8:	92e080e7          	jalr	-1746(ra) # 5512 <fork>
    1bec:	84aa                	mv	s1,a0
    if(pid < 0){
    1bee:	02054f63          	bltz	a0,1c2c <createdelete+0x68>
    if(pid == 0){
    1bf2:	c939                	beqz	a0,1c48 <createdelete+0x84>
  for(pi = 0; pi < NCHILD; pi++){
    1bf4:	2905                	addiw	s2,s2,1
    1bf6:	ff3917e3          	bne	s2,s3,1be4 <createdelete+0x20>
    1bfa:	4491                	li	s1,4
    wait(&xstatus);
    1bfc:	f7c40513          	addi	a0,s0,-132
    1c00:	00004097          	auipc	ra,0x4
    1c04:	922080e7          	jalr	-1758(ra) # 5522 <wait>
    if(xstatus != 0)
    1c08:	f7c42903          	lw	s2,-132(s0)
    1c0c:	0e091263          	bnez	s2,1cf0 <createdelete+0x12c>
  for(pi = 0; pi < NCHILD; pi++){
    1c10:	34fd                	addiw	s1,s1,-1
    1c12:	f4ed                	bnez	s1,1bfc <createdelete+0x38>
  name[0] = name[1] = name[2] = 0;
    1c14:	f8040123          	sb	zero,-126(s0)
    1c18:	03000993          	li	s3,48
    1c1c:	5a7d                	li	s4,-1
    1c1e:	07000c13          	li	s8,112
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1c22:	4b21                	li	s6,8
      if((i == 0 || i >= N/2) && fd < 0){
    1c24:	4ba5                	li	s7,9
    for(pi = 0; pi < NCHILD; pi++){
    1c26:	07400a93          	li	s5,116
    1c2a:	a29d                	j	1d90 <createdelete+0x1cc>
      printf("fork failed\n", s);
    1c2c:	85e6                	mv	a1,s9
    1c2e:	00005517          	auipc	a0,0x5
    1c32:	e4a50513          	addi	a0,a0,-438 # 6a78 <malloc+0x1126>
    1c36:	00004097          	auipc	ra,0x4
    1c3a:	c5c080e7          	jalr	-932(ra) # 5892 <printf>
      exit(1);
    1c3e:	4505                	li	a0,1
    1c40:	00004097          	auipc	ra,0x4
    1c44:	8da080e7          	jalr	-1830(ra) # 551a <exit>
      name[0] = 'p' + pi;
    1c48:	0709091b          	addiw	s2,s2,112
    1c4c:	f9240023          	sb	s2,-128(s0)
      name[2] = '\0';
    1c50:	f8040123          	sb	zero,-126(s0)
      for(i = 0; i < N; i++){
    1c54:	4951                	li	s2,20
    1c56:	a015                	j	1c7a <createdelete+0xb6>
          printf("%s: create failed\n", s);
    1c58:	85e6                	mv	a1,s9
    1c5a:	00005517          	auipc	a0,0x5
    1c5e:	ac650513          	addi	a0,a0,-1338 # 6720 <malloc+0xdce>
    1c62:	00004097          	auipc	ra,0x4
    1c66:	c30080e7          	jalr	-976(ra) # 5892 <printf>
          exit(1);
    1c6a:	4505                	li	a0,1
    1c6c:	00004097          	auipc	ra,0x4
    1c70:	8ae080e7          	jalr	-1874(ra) # 551a <exit>
      for(i = 0; i < N; i++){
    1c74:	2485                	addiw	s1,s1,1
    1c76:	07248863          	beq	s1,s2,1ce6 <createdelete+0x122>
        name[1] = '0' + i;
    1c7a:	0304879b          	addiw	a5,s1,48
    1c7e:	f8f400a3          	sb	a5,-127(s0)
        fd = open(name, O_CREATE | O_RDWR);
    1c82:	20200593          	li	a1,514
    1c86:	f8040513          	addi	a0,s0,-128
    1c8a:	00004097          	auipc	ra,0x4
    1c8e:	8d0080e7          	jalr	-1840(ra) # 555a <open>
        if(fd < 0){
    1c92:	fc0543e3          	bltz	a0,1c58 <createdelete+0x94>
        close(fd);
    1c96:	00004097          	auipc	ra,0x4
    1c9a:	8ac080e7          	jalr	-1876(ra) # 5542 <close>
        if(i > 0 && (i % 2 ) == 0){
    1c9e:	fc905be3          	blez	s1,1c74 <createdelete+0xb0>
    1ca2:	0014f793          	andi	a5,s1,1
    1ca6:	f7f9                	bnez	a5,1c74 <createdelete+0xb0>
          name[1] = '0' + (i / 2);
    1ca8:	01f4d79b          	srliw	a5,s1,0x1f
    1cac:	9fa5                	addw	a5,a5,s1
    1cae:	4017d79b          	sraiw	a5,a5,0x1
    1cb2:	0307879b          	addiw	a5,a5,48
    1cb6:	f8f400a3          	sb	a5,-127(s0)
          if(unlink(name) < 0){
    1cba:	f8040513          	addi	a0,s0,-128
    1cbe:	00004097          	auipc	ra,0x4
    1cc2:	8ac080e7          	jalr	-1876(ra) # 556a <unlink>
    1cc6:	fa0557e3          	bgez	a0,1c74 <createdelete+0xb0>
            printf("%s: unlink failed\n", s);
    1cca:	85e6                	mv	a1,s9
    1ccc:	00005517          	auipc	a0,0x5
    1cd0:	bac50513          	addi	a0,a0,-1108 # 6878 <malloc+0xf26>
    1cd4:	00004097          	auipc	ra,0x4
    1cd8:	bbe080e7          	jalr	-1090(ra) # 5892 <printf>
            exit(1);
    1cdc:	4505                	li	a0,1
    1cde:	00004097          	auipc	ra,0x4
    1ce2:	83c080e7          	jalr	-1988(ra) # 551a <exit>
      exit(0);
    1ce6:	4501                	li	a0,0
    1ce8:	00004097          	auipc	ra,0x4
    1cec:	832080e7          	jalr	-1998(ra) # 551a <exit>
      exit(1);
    1cf0:	4505                	li	a0,1
    1cf2:	00004097          	auipc	ra,0x4
    1cf6:	828080e7          	jalr	-2008(ra) # 551a <exit>
        printf("%s: oops createdelete %s didn't exist\n", s, name);
    1cfa:	f8040613          	addi	a2,s0,-128
    1cfe:	85e6                	mv	a1,s9
    1d00:	00005517          	auipc	a0,0x5
    1d04:	b9050513          	addi	a0,a0,-1136 # 6890 <malloc+0xf3e>
    1d08:	00004097          	auipc	ra,0x4
    1d0c:	b8a080e7          	jalr	-1142(ra) # 5892 <printf>
        exit(1);
    1d10:	4505                	li	a0,1
    1d12:	00004097          	auipc	ra,0x4
    1d16:	808080e7          	jalr	-2040(ra) # 551a <exit>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d1a:	054b7163          	bleu	s4,s6,1d5c <createdelete+0x198>
      if(fd >= 0)
    1d1e:	02055a63          	bgez	a0,1d52 <createdelete+0x18e>
    for(pi = 0; pi < NCHILD; pi++){
    1d22:	2485                	addiw	s1,s1,1
    1d24:	0ff4f493          	andi	s1,s1,255
    1d28:	05548c63          	beq	s1,s5,1d80 <createdelete+0x1bc>
      name[0] = 'p' + pi;
    1d2c:	f8940023          	sb	s1,-128(s0)
      name[1] = '0' + i;
    1d30:	f93400a3          	sb	s3,-127(s0)
      fd = open(name, 0);
    1d34:	4581                	li	a1,0
    1d36:	f8040513          	addi	a0,s0,-128
    1d3a:	00004097          	auipc	ra,0x4
    1d3e:	820080e7          	jalr	-2016(ra) # 555a <open>
      if((i == 0 || i >= N/2) && fd < 0){
    1d42:	00090463          	beqz	s2,1d4a <createdelete+0x186>
    1d46:	fd2bdae3          	ble	s2,s7,1d1a <createdelete+0x156>
    1d4a:	fa0548e3          	bltz	a0,1cfa <createdelete+0x136>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d4e:	014b7963          	bleu	s4,s6,1d60 <createdelete+0x19c>
        close(fd);
    1d52:	00003097          	auipc	ra,0x3
    1d56:	7f0080e7          	jalr	2032(ra) # 5542 <close>
    1d5a:	b7e1                	j	1d22 <createdelete+0x15e>
      } else if((i >= 1 && i < N/2) && fd >= 0){
    1d5c:	fc0543e3          	bltz	a0,1d22 <createdelete+0x15e>
        printf("%s: oops createdelete %s did exist\n", s, name);
    1d60:	f8040613          	addi	a2,s0,-128
    1d64:	85e6                	mv	a1,s9
    1d66:	00005517          	auipc	a0,0x5
    1d6a:	b5250513          	addi	a0,a0,-1198 # 68b8 <malloc+0xf66>
    1d6e:	00004097          	auipc	ra,0x4
    1d72:	b24080e7          	jalr	-1244(ra) # 5892 <printf>
        exit(1);
    1d76:	4505                	li	a0,1
    1d78:	00003097          	auipc	ra,0x3
    1d7c:	7a2080e7          	jalr	1954(ra) # 551a <exit>
  for(i = 0; i < N; i++){
    1d80:	2905                	addiw	s2,s2,1
    1d82:	2a05                	addiw	s4,s4,1
    1d84:	2985                	addiw	s3,s3,1
    1d86:	0ff9f993          	andi	s3,s3,255
    1d8a:	47d1                	li	a5,20
    1d8c:	02f90a63          	beq	s2,a5,1dc0 <createdelete+0x1fc>
    for(pi = 0; pi < NCHILD; pi++){
    1d90:	84e2                	mv	s1,s8
    1d92:	bf69                	j	1d2c <createdelete+0x168>
  for(i = 0; i < N; i++){
    1d94:	2905                	addiw	s2,s2,1
    1d96:	0ff97913          	andi	s2,s2,255
    1d9a:	2985                	addiw	s3,s3,1
    1d9c:	0ff9f993          	andi	s3,s3,255
    1da0:	03490863          	beq	s2,s4,1dd0 <createdelete+0x20c>
  name[0] = name[1] = name[2] = 0;
    1da4:	84d6                	mv	s1,s5
      name[0] = 'p' + i;
    1da6:	f9240023          	sb	s2,-128(s0)
      name[1] = '0' + i;
    1daa:	f93400a3          	sb	s3,-127(s0)
      unlink(name);
    1dae:	f8040513          	addi	a0,s0,-128
    1db2:	00003097          	auipc	ra,0x3
    1db6:	7b8080e7          	jalr	1976(ra) # 556a <unlink>
    for(pi = 0; pi < NCHILD; pi++){
    1dba:	34fd                	addiw	s1,s1,-1
    1dbc:	f4ed                	bnez	s1,1da6 <createdelete+0x1e2>
    1dbe:	bfd9                	j	1d94 <createdelete+0x1d0>
    1dc0:	03000993          	li	s3,48
    1dc4:	07000913          	li	s2,112
  name[0] = name[1] = name[2] = 0;
    1dc8:	4a91                	li	s5,4
  for(i = 0; i < N; i++){
    1dca:	08400a13          	li	s4,132
    1dce:	bfd9                	j	1da4 <createdelete+0x1e0>
}
    1dd0:	60aa                	ld	ra,136(sp)
    1dd2:	640a                	ld	s0,128(sp)
    1dd4:	74e6                	ld	s1,120(sp)
    1dd6:	7946                	ld	s2,112(sp)
    1dd8:	79a6                	ld	s3,104(sp)
    1dda:	7a06                	ld	s4,96(sp)
    1ddc:	6ae6                	ld	s5,88(sp)
    1dde:	6b46                	ld	s6,80(sp)
    1de0:	6ba6                	ld	s7,72(sp)
    1de2:	6c06                	ld	s8,64(sp)
    1de4:	7ce2                	ld	s9,56(sp)
    1de6:	6149                	addi	sp,sp,144
    1de8:	8082                	ret

0000000000001dea <linkunlink>:
{
    1dea:	711d                	addi	sp,sp,-96
    1dec:	ec86                	sd	ra,88(sp)
    1dee:	e8a2                	sd	s0,80(sp)
    1df0:	e4a6                	sd	s1,72(sp)
    1df2:	e0ca                	sd	s2,64(sp)
    1df4:	fc4e                	sd	s3,56(sp)
    1df6:	f852                	sd	s4,48(sp)
    1df8:	f456                	sd	s5,40(sp)
    1dfa:	f05a                	sd	s6,32(sp)
    1dfc:	ec5e                	sd	s7,24(sp)
    1dfe:	e862                	sd	s8,16(sp)
    1e00:	e466                	sd	s9,8(sp)
    1e02:	1080                	addi	s0,sp,96
    1e04:	84aa                	mv	s1,a0
  unlink("x");
    1e06:	00004517          	auipc	a0,0x4
    1e0a:	09a50513          	addi	a0,a0,154 # 5ea0 <malloc+0x54e>
    1e0e:	00003097          	auipc	ra,0x3
    1e12:	75c080e7          	jalr	1884(ra) # 556a <unlink>
  pid = fork();
    1e16:	00003097          	auipc	ra,0x3
    1e1a:	6fc080e7          	jalr	1788(ra) # 5512 <fork>
  if(pid < 0){
    1e1e:	02054b63          	bltz	a0,1e54 <linkunlink+0x6a>
    1e22:	8c2a                	mv	s8,a0
  unsigned int x = (pid ? 1 : 97);
    1e24:	4c85                	li	s9,1
    1e26:	e119                	bnez	a0,1e2c <linkunlink+0x42>
    1e28:	06100c93          	li	s9,97
    1e2c:	06400493          	li	s1,100
    x = x * 1103515245 + 12345;
    1e30:	41c659b7          	lui	s3,0x41c65
    1e34:	e6d9899b          	addiw	s3,s3,-403
    1e38:	690d                	lui	s2,0x3
    1e3a:	0399091b          	addiw	s2,s2,57
    if((x % 3) == 0){
    1e3e:	4a0d                	li	s4,3
    } else if((x % 3) == 1){
    1e40:	4b05                	li	s6,1
      unlink("x");
    1e42:	00004a97          	auipc	s5,0x4
    1e46:	05ea8a93          	addi	s5,s5,94 # 5ea0 <malloc+0x54e>
      link("cat", "x");
    1e4a:	00005b97          	auipc	s7,0x5
    1e4e:	a96b8b93          	addi	s7,s7,-1386 # 68e0 <malloc+0xf8e>
    1e52:	a091                	j	1e96 <linkunlink+0xac>
    printf("%s: fork failed\n", s);
    1e54:	85a6                	mv	a1,s1
    1e56:	00005517          	auipc	a0,0x5
    1e5a:	83250513          	addi	a0,a0,-1998 # 6688 <malloc+0xd36>
    1e5e:	00004097          	auipc	ra,0x4
    1e62:	a34080e7          	jalr	-1484(ra) # 5892 <printf>
    exit(1);
    1e66:	4505                	li	a0,1
    1e68:	00003097          	auipc	ra,0x3
    1e6c:	6b2080e7          	jalr	1714(ra) # 551a <exit>
      close(open("x", O_RDWR | O_CREATE));
    1e70:	20200593          	li	a1,514
    1e74:	8556                	mv	a0,s5
    1e76:	00003097          	auipc	ra,0x3
    1e7a:	6e4080e7          	jalr	1764(ra) # 555a <open>
    1e7e:	00003097          	auipc	ra,0x3
    1e82:	6c4080e7          	jalr	1732(ra) # 5542 <close>
    1e86:	a031                	j	1e92 <linkunlink+0xa8>
      unlink("x");
    1e88:	8556                	mv	a0,s5
    1e8a:	00003097          	auipc	ra,0x3
    1e8e:	6e0080e7          	jalr	1760(ra) # 556a <unlink>
  for(i = 0; i < 100; i++){
    1e92:	34fd                	addiw	s1,s1,-1
    1e94:	c09d                	beqz	s1,1eba <linkunlink+0xd0>
    x = x * 1103515245 + 12345;
    1e96:	033c87bb          	mulw	a5,s9,s3
    1e9a:	012787bb          	addw	a5,a5,s2
    1e9e:	00078c9b          	sext.w	s9,a5
    if((x % 3) == 0){
    1ea2:	0347f7bb          	remuw	a5,a5,s4
    1ea6:	d7e9                	beqz	a5,1e70 <linkunlink+0x86>
    } else if((x % 3) == 1){
    1ea8:	ff6790e3          	bne	a5,s6,1e88 <linkunlink+0x9e>
      link("cat", "x");
    1eac:	85d6                	mv	a1,s5
    1eae:	855e                	mv	a0,s7
    1eb0:	00003097          	auipc	ra,0x3
    1eb4:	6ca080e7          	jalr	1738(ra) # 557a <link>
    1eb8:	bfe9                	j	1e92 <linkunlink+0xa8>
  if(pid)
    1eba:	020c0463          	beqz	s8,1ee2 <linkunlink+0xf8>
    wait(0);
    1ebe:	4501                	li	a0,0
    1ec0:	00003097          	auipc	ra,0x3
    1ec4:	662080e7          	jalr	1634(ra) # 5522 <wait>
}
    1ec8:	60e6                	ld	ra,88(sp)
    1eca:	6446                	ld	s0,80(sp)
    1ecc:	64a6                	ld	s1,72(sp)
    1ece:	6906                	ld	s2,64(sp)
    1ed0:	79e2                	ld	s3,56(sp)
    1ed2:	7a42                	ld	s4,48(sp)
    1ed4:	7aa2                	ld	s5,40(sp)
    1ed6:	7b02                	ld	s6,32(sp)
    1ed8:	6be2                	ld	s7,24(sp)
    1eda:	6c42                	ld	s8,16(sp)
    1edc:	6ca2                	ld	s9,8(sp)
    1ede:	6125                	addi	sp,sp,96
    1ee0:	8082                	ret
    exit(0);
    1ee2:	4501                	li	a0,0
    1ee4:	00003097          	auipc	ra,0x3
    1ee8:	636080e7          	jalr	1590(ra) # 551a <exit>

0000000000001eec <forktest>:
{
    1eec:	7179                	addi	sp,sp,-48
    1eee:	f406                	sd	ra,40(sp)
    1ef0:	f022                	sd	s0,32(sp)
    1ef2:	ec26                	sd	s1,24(sp)
    1ef4:	e84a                	sd	s2,16(sp)
    1ef6:	e44e                	sd	s3,8(sp)
    1ef8:	1800                	addi	s0,sp,48
    1efa:	89aa                	mv	s3,a0
  for(n=0; n<N; n++){
    1efc:	4481                	li	s1,0
    1efe:	3e800913          	li	s2,1000
    pid = fork();
    1f02:	00003097          	auipc	ra,0x3
    1f06:	610080e7          	jalr	1552(ra) # 5512 <fork>
    if(pid < 0)
    1f0a:	02054863          	bltz	a0,1f3a <forktest+0x4e>
    if(pid == 0)
    1f0e:	c115                	beqz	a0,1f32 <forktest+0x46>
  for(n=0; n<N; n++){
    1f10:	2485                	addiw	s1,s1,1
    1f12:	ff2498e3          	bne	s1,s2,1f02 <forktest+0x16>
    printf("%s: fork claimed to work 1000 times!\n", s);
    1f16:	85ce                	mv	a1,s3
    1f18:	00005517          	auipc	a0,0x5
    1f1c:	9e850513          	addi	a0,a0,-1560 # 6900 <malloc+0xfae>
    1f20:	00004097          	auipc	ra,0x4
    1f24:	972080e7          	jalr	-1678(ra) # 5892 <printf>
    exit(1);
    1f28:	4505                	li	a0,1
    1f2a:	00003097          	auipc	ra,0x3
    1f2e:	5f0080e7          	jalr	1520(ra) # 551a <exit>
      exit(0);
    1f32:	00003097          	auipc	ra,0x3
    1f36:	5e8080e7          	jalr	1512(ra) # 551a <exit>
  if (n == 0) {
    1f3a:	cc9d                	beqz	s1,1f78 <forktest+0x8c>
  if(n == N){
    1f3c:	3e800793          	li	a5,1000
    1f40:	fcf48be3          	beq	s1,a5,1f16 <forktest+0x2a>
  for(; n > 0; n--){
    1f44:	00905b63          	blez	s1,1f5a <forktest+0x6e>
    if(wait(0) < 0){
    1f48:	4501                	li	a0,0
    1f4a:	00003097          	auipc	ra,0x3
    1f4e:	5d8080e7          	jalr	1496(ra) # 5522 <wait>
    1f52:	04054163          	bltz	a0,1f94 <forktest+0xa8>
  for(; n > 0; n--){
    1f56:	34fd                	addiw	s1,s1,-1
    1f58:	f8e5                	bnez	s1,1f48 <forktest+0x5c>
  if(wait(0) != -1){
    1f5a:	4501                	li	a0,0
    1f5c:	00003097          	auipc	ra,0x3
    1f60:	5c6080e7          	jalr	1478(ra) # 5522 <wait>
    1f64:	57fd                	li	a5,-1
    1f66:	04f51563          	bne	a0,a5,1fb0 <forktest+0xc4>
}
    1f6a:	70a2                	ld	ra,40(sp)
    1f6c:	7402                	ld	s0,32(sp)
    1f6e:	64e2                	ld	s1,24(sp)
    1f70:	6942                	ld	s2,16(sp)
    1f72:	69a2                	ld	s3,8(sp)
    1f74:	6145                	addi	sp,sp,48
    1f76:	8082                	ret
    printf("%s: no fork at all!\n", s);
    1f78:	85ce                	mv	a1,s3
    1f7a:	00005517          	auipc	a0,0x5
    1f7e:	96e50513          	addi	a0,a0,-1682 # 68e8 <malloc+0xf96>
    1f82:	00004097          	auipc	ra,0x4
    1f86:	910080e7          	jalr	-1776(ra) # 5892 <printf>
    exit(1);
    1f8a:	4505                	li	a0,1
    1f8c:	00003097          	auipc	ra,0x3
    1f90:	58e080e7          	jalr	1422(ra) # 551a <exit>
      printf("%s: wait stopped early\n", s);
    1f94:	85ce                	mv	a1,s3
    1f96:	00005517          	auipc	a0,0x5
    1f9a:	99250513          	addi	a0,a0,-1646 # 6928 <malloc+0xfd6>
    1f9e:	00004097          	auipc	ra,0x4
    1fa2:	8f4080e7          	jalr	-1804(ra) # 5892 <printf>
      exit(1);
    1fa6:	4505                	li	a0,1
    1fa8:	00003097          	auipc	ra,0x3
    1fac:	572080e7          	jalr	1394(ra) # 551a <exit>
    printf("%s: wait got too many\n", s);
    1fb0:	85ce                	mv	a1,s3
    1fb2:	00005517          	auipc	a0,0x5
    1fb6:	98e50513          	addi	a0,a0,-1650 # 6940 <malloc+0xfee>
    1fba:	00004097          	auipc	ra,0x4
    1fbe:	8d8080e7          	jalr	-1832(ra) # 5892 <printf>
    exit(1);
    1fc2:	4505                	li	a0,1
    1fc4:	00003097          	auipc	ra,0x3
    1fc8:	556080e7          	jalr	1366(ra) # 551a <exit>

0000000000001fcc <kernmem>:
{
    1fcc:	715d                	addi	sp,sp,-80
    1fce:	e486                	sd	ra,72(sp)
    1fd0:	e0a2                	sd	s0,64(sp)
    1fd2:	fc26                	sd	s1,56(sp)
    1fd4:	f84a                	sd	s2,48(sp)
    1fd6:	f44e                	sd	s3,40(sp)
    1fd8:	f052                	sd	s4,32(sp)
    1fda:	ec56                	sd	s5,24(sp)
    1fdc:	0880                	addi	s0,sp,80
    1fde:	8aaa                	mv	s5,a0
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fe0:	4485                	li	s1,1
    1fe2:	04fe                	slli	s1,s1,0x1f
    if(xstatus != -1)  // did kernel kill child?
    1fe4:	5a7d                	li	s4,-1
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    1fe6:	69b1                	lui	s3,0xc
    1fe8:	35098993          	addi	s3,s3,848 # c350 <buf+0x9d8>
    1fec:	1003d937          	lui	s2,0x1003d
    1ff0:	090e                	slli	s2,s2,0x3
    1ff2:	48090913          	addi	s2,s2,1152 # 1003d480 <_end+0x1002eaf8>
    pid = fork();
    1ff6:	00003097          	auipc	ra,0x3
    1ffa:	51c080e7          	jalr	1308(ra) # 5512 <fork>
    if(pid < 0){
    1ffe:	02054963          	bltz	a0,2030 <kernmem+0x64>
    if(pid == 0){
    2002:	c529                	beqz	a0,204c <kernmem+0x80>
    wait(&xstatus);
    2004:	fbc40513          	addi	a0,s0,-68
    2008:	00003097          	auipc	ra,0x3
    200c:	51a080e7          	jalr	1306(ra) # 5522 <wait>
    if(xstatus != -1)  // did kernel kill child?
    2010:	fbc42783          	lw	a5,-68(s0)
    2014:	05479d63          	bne	a5,s4,206e <kernmem+0xa2>
  for(a = (char*)(KERNBASE); a < (char*) (KERNBASE+2000000); a += 50000){
    2018:	94ce                	add	s1,s1,s3
    201a:	fd249ee3          	bne	s1,s2,1ff6 <kernmem+0x2a>
}
    201e:	60a6                	ld	ra,72(sp)
    2020:	6406                	ld	s0,64(sp)
    2022:	74e2                	ld	s1,56(sp)
    2024:	7942                	ld	s2,48(sp)
    2026:	79a2                	ld	s3,40(sp)
    2028:	7a02                	ld	s4,32(sp)
    202a:	6ae2                	ld	s5,24(sp)
    202c:	6161                	addi	sp,sp,80
    202e:	8082                	ret
      printf("%s: fork failed\n", s);
    2030:	85d6                	mv	a1,s5
    2032:	00004517          	auipc	a0,0x4
    2036:	65650513          	addi	a0,a0,1622 # 6688 <malloc+0xd36>
    203a:	00004097          	auipc	ra,0x4
    203e:	858080e7          	jalr	-1960(ra) # 5892 <printf>
      exit(1);
    2042:	4505                	li	a0,1
    2044:	00003097          	auipc	ra,0x3
    2048:	4d6080e7          	jalr	1238(ra) # 551a <exit>
      printf("%s: oops could read %x = %x\n", s, a, *a);
    204c:	0004c683          	lbu	a3,0(s1)
    2050:	8626                	mv	a2,s1
    2052:	85d6                	mv	a1,s5
    2054:	00005517          	auipc	a0,0x5
    2058:	90450513          	addi	a0,a0,-1788 # 6958 <malloc+0x1006>
    205c:	00004097          	auipc	ra,0x4
    2060:	836080e7          	jalr	-1994(ra) # 5892 <printf>
      exit(1);
    2064:	4505                	li	a0,1
    2066:	00003097          	auipc	ra,0x3
    206a:	4b4080e7          	jalr	1204(ra) # 551a <exit>
      exit(1);
    206e:	4505                	li	a0,1
    2070:	00003097          	auipc	ra,0x3
    2074:	4aa080e7          	jalr	1194(ra) # 551a <exit>

0000000000002078 <bigargtest>:
{
    2078:	7179                	addi	sp,sp,-48
    207a:	f406                	sd	ra,40(sp)
    207c:	f022                	sd	s0,32(sp)
    207e:	ec26                	sd	s1,24(sp)
    2080:	1800                	addi	s0,sp,48
    2082:	84aa                	mv	s1,a0
  unlink("bigarg-ok");
    2084:	00005517          	auipc	a0,0x5
    2088:	8f450513          	addi	a0,a0,-1804 # 6978 <malloc+0x1026>
    208c:	00003097          	auipc	ra,0x3
    2090:	4de080e7          	jalr	1246(ra) # 556a <unlink>
  pid = fork();
    2094:	00003097          	auipc	ra,0x3
    2098:	47e080e7          	jalr	1150(ra) # 5512 <fork>
  if(pid == 0){
    209c:	c121                	beqz	a0,20dc <bigargtest+0x64>
  } else if(pid < 0){
    209e:	0a054063          	bltz	a0,213e <bigargtest+0xc6>
  wait(&xstatus);
    20a2:	fdc40513          	addi	a0,s0,-36
    20a6:	00003097          	auipc	ra,0x3
    20aa:	47c080e7          	jalr	1148(ra) # 5522 <wait>
  if(xstatus != 0)
    20ae:	fdc42503          	lw	a0,-36(s0)
    20b2:	e545                	bnez	a0,215a <bigargtest+0xe2>
  fd = open("bigarg-ok", 0);
    20b4:	4581                	li	a1,0
    20b6:	00005517          	auipc	a0,0x5
    20ba:	8c250513          	addi	a0,a0,-1854 # 6978 <malloc+0x1026>
    20be:	00003097          	auipc	ra,0x3
    20c2:	49c080e7          	jalr	1180(ra) # 555a <open>
  if(fd < 0){
    20c6:	08054e63          	bltz	a0,2162 <bigargtest+0xea>
  close(fd);
    20ca:	00003097          	auipc	ra,0x3
    20ce:	478080e7          	jalr	1144(ra) # 5542 <close>
}
    20d2:	70a2                	ld	ra,40(sp)
    20d4:	7402                	ld	s0,32(sp)
    20d6:	64e2                	ld	s1,24(sp)
    20d8:	6145                	addi	sp,sp,48
    20da:	8082                	ret
    20dc:	00006797          	auipc	a5,0x6
    20e0:	08478793          	addi	a5,a5,132 # 8160 <args.1827>
    20e4:	00006697          	auipc	a3,0x6
    20e8:	17468693          	addi	a3,a3,372 # 8258 <args.1827+0xf8>
      args[i] = "bigargs test: failed\n                                                                                                                                                                                                       ";
    20ec:	00005717          	auipc	a4,0x5
    20f0:	89c70713          	addi	a4,a4,-1892 # 6988 <malloc+0x1036>
    20f4:	e398                	sd	a4,0(a5)
    for(i = 0; i < MAXARG-1; i++)
    20f6:	07a1                	addi	a5,a5,8
    20f8:	fed79ee3          	bne	a5,a3,20f4 <bigargtest+0x7c>
    args[MAXARG-1] = 0;
    20fc:	00006597          	auipc	a1,0x6
    2100:	06458593          	addi	a1,a1,100 # 8160 <args.1827>
    2104:	0e05bc23          	sd	zero,248(a1)
    exec("echo", args);
    2108:	00004517          	auipc	a0,0x4
    210c:	d2850513          	addi	a0,a0,-728 # 5e30 <malloc+0x4de>
    2110:	00003097          	auipc	ra,0x3
    2114:	442080e7          	jalr	1090(ra) # 5552 <exec>
    fd = open("bigarg-ok", O_CREATE);
    2118:	20000593          	li	a1,512
    211c:	00005517          	auipc	a0,0x5
    2120:	85c50513          	addi	a0,a0,-1956 # 6978 <malloc+0x1026>
    2124:	00003097          	auipc	ra,0x3
    2128:	436080e7          	jalr	1078(ra) # 555a <open>
    close(fd);
    212c:	00003097          	auipc	ra,0x3
    2130:	416080e7          	jalr	1046(ra) # 5542 <close>
    exit(0);
    2134:	4501                	li	a0,0
    2136:	00003097          	auipc	ra,0x3
    213a:	3e4080e7          	jalr	996(ra) # 551a <exit>
    printf("%s: bigargtest: fork failed\n", s);
    213e:	85a6                	mv	a1,s1
    2140:	00005517          	auipc	a0,0x5
    2144:	92850513          	addi	a0,a0,-1752 # 6a68 <malloc+0x1116>
    2148:	00003097          	auipc	ra,0x3
    214c:	74a080e7          	jalr	1866(ra) # 5892 <printf>
    exit(1);
    2150:	4505                	li	a0,1
    2152:	00003097          	auipc	ra,0x3
    2156:	3c8080e7          	jalr	968(ra) # 551a <exit>
    exit(xstatus);
    215a:	00003097          	auipc	ra,0x3
    215e:	3c0080e7          	jalr	960(ra) # 551a <exit>
    printf("%s: bigarg test failed!\n", s);
    2162:	85a6                	mv	a1,s1
    2164:	00005517          	auipc	a0,0x5
    2168:	92450513          	addi	a0,a0,-1756 # 6a88 <malloc+0x1136>
    216c:	00003097          	auipc	ra,0x3
    2170:	726080e7          	jalr	1830(ra) # 5892 <printf>
    exit(1);
    2174:	4505                	li	a0,1
    2176:	00003097          	auipc	ra,0x3
    217a:	3a4080e7          	jalr	932(ra) # 551a <exit>

000000000000217e <stacktest>:
{
    217e:	7179                	addi	sp,sp,-48
    2180:	f406                	sd	ra,40(sp)
    2182:	f022                	sd	s0,32(sp)
    2184:	ec26                	sd	s1,24(sp)
    2186:	1800                	addi	s0,sp,48
    2188:	84aa                	mv	s1,a0
  pid = fork();
    218a:	00003097          	auipc	ra,0x3
    218e:	388080e7          	jalr	904(ra) # 5512 <fork>
  if(pid == 0) {
    2192:	c115                	beqz	a0,21b6 <stacktest+0x38>
  } else if(pid < 0){
    2194:	04054463          	bltz	a0,21dc <stacktest+0x5e>
  wait(&xstatus);
    2198:	fdc40513          	addi	a0,s0,-36
    219c:	00003097          	auipc	ra,0x3
    21a0:	386080e7          	jalr	902(ra) # 5522 <wait>
  if(xstatus == -1)  // kernel killed child?
    21a4:	fdc42503          	lw	a0,-36(s0)
    21a8:	57fd                	li	a5,-1
    21aa:	04f50763          	beq	a0,a5,21f8 <stacktest+0x7a>
    exit(xstatus);
    21ae:	00003097          	auipc	ra,0x3
    21b2:	36c080e7          	jalr	876(ra) # 551a <exit>

static inline uint64
r_sp()
{
  uint64 x;
  asm volatile("mv %0, sp" : "=r" (x) );
    21b6:	870a                	mv	a4,sp
    printf("%s: stacktest: read below stack %p\n", s, *sp);
    21b8:	77fd                	lui	a5,0xfffff
    21ba:	97ba                	add	a5,a5,a4
    21bc:	0007c603          	lbu	a2,0(a5) # fffffffffffff000 <_end+0xffffffffffff0678>
    21c0:	85a6                	mv	a1,s1
    21c2:	00005517          	auipc	a0,0x5
    21c6:	8e650513          	addi	a0,a0,-1818 # 6aa8 <malloc+0x1156>
    21ca:	00003097          	auipc	ra,0x3
    21ce:	6c8080e7          	jalr	1736(ra) # 5892 <printf>
    exit(1);
    21d2:	4505                	li	a0,1
    21d4:	00003097          	auipc	ra,0x3
    21d8:	346080e7          	jalr	838(ra) # 551a <exit>
    printf("%s: fork failed\n", s);
    21dc:	85a6                	mv	a1,s1
    21de:	00004517          	auipc	a0,0x4
    21e2:	4aa50513          	addi	a0,a0,1194 # 6688 <malloc+0xd36>
    21e6:	00003097          	auipc	ra,0x3
    21ea:	6ac080e7          	jalr	1708(ra) # 5892 <printf>
    exit(1);
    21ee:	4505                	li	a0,1
    21f0:	00003097          	auipc	ra,0x3
    21f4:	32a080e7          	jalr	810(ra) # 551a <exit>
    exit(0);
    21f8:	4501                	li	a0,0
    21fa:	00003097          	auipc	ra,0x3
    21fe:	320080e7          	jalr	800(ra) # 551a <exit>

0000000000002202 <copyinstr3>:
{
    2202:	7179                	addi	sp,sp,-48
    2204:	f406                	sd	ra,40(sp)
    2206:	f022                	sd	s0,32(sp)
    2208:	ec26                	sd	s1,24(sp)
    220a:	1800                	addi	s0,sp,48
  sbrk(8192);
    220c:	6509                	lui	a0,0x2
    220e:	00003097          	auipc	ra,0x3
    2212:	394080e7          	jalr	916(ra) # 55a2 <sbrk>
  uint64 top = (uint64) sbrk(0);
    2216:	4501                	li	a0,0
    2218:	00003097          	auipc	ra,0x3
    221c:	38a080e7          	jalr	906(ra) # 55a2 <sbrk>
  if((top % PGSIZE) != 0){
    2220:	6785                	lui	a5,0x1
    2222:	17fd                	addi	a5,a5,-1
    2224:	8fe9                	and	a5,a5,a0
    2226:	e3d1                	bnez	a5,22aa <copyinstr3+0xa8>
  top = (uint64) sbrk(0);
    2228:	4501                	li	a0,0
    222a:	00003097          	auipc	ra,0x3
    222e:	378080e7          	jalr	888(ra) # 55a2 <sbrk>
  if(top % PGSIZE){
    2232:	6785                	lui	a5,0x1
    2234:	17fd                	addi	a5,a5,-1
    2236:	8fe9                	and	a5,a5,a0
    2238:	e7c1                	bnez	a5,22c0 <copyinstr3+0xbe>
  char *b = (char *) (top - 1);
    223a:	fff50493          	addi	s1,a0,-1 # 1fff <kernmem+0x33>
  *b = 'x';
    223e:	07800793          	li	a5,120
    2242:	fef50fa3          	sb	a5,-1(a0)
  int ret = unlink(b);
    2246:	8526                	mv	a0,s1
    2248:	00003097          	auipc	ra,0x3
    224c:	322080e7          	jalr	802(ra) # 556a <unlink>
  if(ret != -1){
    2250:	57fd                	li	a5,-1
    2252:	08f51463          	bne	a0,a5,22da <copyinstr3+0xd8>
  int fd = open(b, O_CREATE | O_WRONLY);
    2256:	20100593          	li	a1,513
    225a:	8526                	mv	a0,s1
    225c:	00003097          	auipc	ra,0x3
    2260:	2fe080e7          	jalr	766(ra) # 555a <open>
  if(fd != -1){
    2264:	57fd                	li	a5,-1
    2266:	08f51963          	bne	a0,a5,22f8 <copyinstr3+0xf6>
  ret = link(b, b);
    226a:	85a6                	mv	a1,s1
    226c:	8526                	mv	a0,s1
    226e:	00003097          	auipc	ra,0x3
    2272:	30c080e7          	jalr	780(ra) # 557a <link>
  if(ret != -1){
    2276:	57fd                	li	a5,-1
    2278:	08f51f63          	bne	a0,a5,2316 <copyinstr3+0x114>
  char *args[] = { "xx", 0 };
    227c:	00005797          	auipc	a5,0x5
    2280:	4d478793          	addi	a5,a5,1236 # 7750 <malloc+0x1dfe>
    2284:	fcf43823          	sd	a5,-48(s0)
    2288:	fc043c23          	sd	zero,-40(s0)
  ret = exec(b, args);
    228c:	fd040593          	addi	a1,s0,-48
    2290:	8526                	mv	a0,s1
    2292:	00003097          	auipc	ra,0x3
    2296:	2c0080e7          	jalr	704(ra) # 5552 <exec>
  if(ret != -1){
    229a:	57fd                	li	a5,-1
    229c:	08f51d63          	bne	a0,a5,2336 <copyinstr3+0x134>
}
    22a0:	70a2                	ld	ra,40(sp)
    22a2:	7402                	ld	s0,32(sp)
    22a4:	64e2                	ld	s1,24(sp)
    22a6:	6145                	addi	sp,sp,48
    22a8:	8082                	ret
    sbrk(PGSIZE - (top % PGSIZE));
    22aa:	6785                	lui	a5,0x1
    22ac:	17fd                	addi	a5,a5,-1
    22ae:	8d7d                	and	a0,a0,a5
    22b0:	6785                	lui	a5,0x1
    22b2:	40a7853b          	subw	a0,a5,a0
    22b6:	00003097          	auipc	ra,0x3
    22ba:	2ec080e7          	jalr	748(ra) # 55a2 <sbrk>
    22be:	b7ad                	j	2228 <copyinstr3+0x26>
    printf("oops\n");
    22c0:	00005517          	auipc	a0,0x5
    22c4:	81050513          	addi	a0,a0,-2032 # 6ad0 <malloc+0x117e>
    22c8:	00003097          	auipc	ra,0x3
    22cc:	5ca080e7          	jalr	1482(ra) # 5892 <printf>
    exit(1);
    22d0:	4505                	li	a0,1
    22d2:	00003097          	auipc	ra,0x3
    22d6:	248080e7          	jalr	584(ra) # 551a <exit>
    printf("unlink(%s) returned %d, not -1\n", b, ret);
    22da:	862a                	mv	a2,a0
    22dc:	85a6                	mv	a1,s1
    22de:	00004517          	auipc	a0,0x4
    22e2:	2ca50513          	addi	a0,a0,714 # 65a8 <malloc+0xc56>
    22e6:	00003097          	auipc	ra,0x3
    22ea:	5ac080e7          	jalr	1452(ra) # 5892 <printf>
    exit(1);
    22ee:	4505                	li	a0,1
    22f0:	00003097          	auipc	ra,0x3
    22f4:	22a080e7          	jalr	554(ra) # 551a <exit>
    printf("open(%s) returned %d, not -1\n", b, fd);
    22f8:	862a                	mv	a2,a0
    22fa:	85a6                	mv	a1,s1
    22fc:	00004517          	auipc	a0,0x4
    2300:	2cc50513          	addi	a0,a0,716 # 65c8 <malloc+0xc76>
    2304:	00003097          	auipc	ra,0x3
    2308:	58e080e7          	jalr	1422(ra) # 5892 <printf>
    exit(1);
    230c:	4505                	li	a0,1
    230e:	00003097          	auipc	ra,0x3
    2312:	20c080e7          	jalr	524(ra) # 551a <exit>
    printf("link(%s, %s) returned %d, not -1\n", b, b, ret);
    2316:	86aa                	mv	a3,a0
    2318:	8626                	mv	a2,s1
    231a:	85a6                	mv	a1,s1
    231c:	00004517          	auipc	a0,0x4
    2320:	2cc50513          	addi	a0,a0,716 # 65e8 <malloc+0xc96>
    2324:	00003097          	auipc	ra,0x3
    2328:	56e080e7          	jalr	1390(ra) # 5892 <printf>
    exit(1);
    232c:	4505                	li	a0,1
    232e:	00003097          	auipc	ra,0x3
    2332:	1ec080e7          	jalr	492(ra) # 551a <exit>
    printf("exec(%s) returned %d, not -1\n", b, fd);
    2336:	567d                	li	a2,-1
    2338:	85a6                	mv	a1,s1
    233a:	00004517          	auipc	a0,0x4
    233e:	2d650513          	addi	a0,a0,726 # 6610 <malloc+0xcbe>
    2342:	00003097          	auipc	ra,0x3
    2346:	550080e7          	jalr	1360(ra) # 5892 <printf>
    exit(1);
    234a:	4505                	li	a0,1
    234c:	00003097          	auipc	ra,0x3
    2350:	1ce080e7          	jalr	462(ra) # 551a <exit>

0000000000002354 <rwsbrk>:
{
    2354:	1101                	addi	sp,sp,-32
    2356:	ec06                	sd	ra,24(sp)
    2358:	e822                	sd	s0,16(sp)
    235a:	e426                	sd	s1,8(sp)
    235c:	e04a                	sd	s2,0(sp)
    235e:	1000                	addi	s0,sp,32
  uint64 a = (uint64) sbrk(8192);
    2360:	6509                	lui	a0,0x2
    2362:	00003097          	auipc	ra,0x3
    2366:	240080e7          	jalr	576(ra) # 55a2 <sbrk>
  if(a == 0xffffffffffffffffLL) {
    236a:	57fd                	li	a5,-1
    236c:	06f50263          	beq	a0,a5,23d0 <rwsbrk+0x7c>
    2370:	84aa                	mv	s1,a0
  if ((uint64) sbrk(-8192) ==  0xffffffffffffffffLL) {
    2372:	7579                	lui	a0,0xffffe
    2374:	00003097          	auipc	ra,0x3
    2378:	22e080e7          	jalr	558(ra) # 55a2 <sbrk>
    237c:	57fd                	li	a5,-1
    237e:	06f50663          	beq	a0,a5,23ea <rwsbrk+0x96>
  fd = open("rwsbrk", O_CREATE|O_WRONLY);
    2382:	20100593          	li	a1,513
    2386:	00004517          	auipc	a0,0x4
    238a:	78a50513          	addi	a0,a0,1930 # 6b10 <malloc+0x11be>
    238e:	00003097          	auipc	ra,0x3
    2392:	1cc080e7          	jalr	460(ra) # 555a <open>
    2396:	892a                	mv	s2,a0
  if(fd < 0){
    2398:	06054663          	bltz	a0,2404 <rwsbrk+0xb0>
  n = write(fd, (void*)(a+4096), 1024);
    239c:	6785                	lui	a5,0x1
    239e:	94be                	add	s1,s1,a5
    23a0:	40000613          	li	a2,1024
    23a4:	85a6                	mv	a1,s1
    23a6:	00003097          	auipc	ra,0x3
    23aa:	194080e7          	jalr	404(ra) # 553a <write>
  if(n >= 0){
    23ae:	06054863          	bltz	a0,241e <rwsbrk+0xca>
    printf("write(fd, %p, 1024) returned %d, not -1\n", a+4096, n);
    23b2:	862a                	mv	a2,a0
    23b4:	85a6                	mv	a1,s1
    23b6:	00004517          	auipc	a0,0x4
    23ba:	77a50513          	addi	a0,a0,1914 # 6b30 <malloc+0x11de>
    23be:	00003097          	auipc	ra,0x3
    23c2:	4d4080e7          	jalr	1236(ra) # 5892 <printf>
    exit(1);
    23c6:	4505                	li	a0,1
    23c8:	00003097          	auipc	ra,0x3
    23cc:	152080e7          	jalr	338(ra) # 551a <exit>
    printf("sbrk(rwsbrk) failed\n");
    23d0:	00004517          	auipc	a0,0x4
    23d4:	70850513          	addi	a0,a0,1800 # 6ad8 <malloc+0x1186>
    23d8:	00003097          	auipc	ra,0x3
    23dc:	4ba080e7          	jalr	1210(ra) # 5892 <printf>
    exit(1);
    23e0:	4505                	li	a0,1
    23e2:	00003097          	auipc	ra,0x3
    23e6:	138080e7          	jalr	312(ra) # 551a <exit>
    printf("sbrk(rwsbrk) shrink failed\n");
    23ea:	00004517          	auipc	a0,0x4
    23ee:	70650513          	addi	a0,a0,1798 # 6af0 <malloc+0x119e>
    23f2:	00003097          	auipc	ra,0x3
    23f6:	4a0080e7          	jalr	1184(ra) # 5892 <printf>
    exit(1);
    23fa:	4505                	li	a0,1
    23fc:	00003097          	auipc	ra,0x3
    2400:	11e080e7          	jalr	286(ra) # 551a <exit>
    printf("open(rwsbrk) failed\n");
    2404:	00004517          	auipc	a0,0x4
    2408:	71450513          	addi	a0,a0,1812 # 6b18 <malloc+0x11c6>
    240c:	00003097          	auipc	ra,0x3
    2410:	486080e7          	jalr	1158(ra) # 5892 <printf>
    exit(1);
    2414:	4505                	li	a0,1
    2416:	00003097          	auipc	ra,0x3
    241a:	104080e7          	jalr	260(ra) # 551a <exit>
  close(fd);
    241e:	854a                	mv	a0,s2
    2420:	00003097          	auipc	ra,0x3
    2424:	122080e7          	jalr	290(ra) # 5542 <close>
  unlink("rwsbrk");
    2428:	00004517          	auipc	a0,0x4
    242c:	6e850513          	addi	a0,a0,1768 # 6b10 <malloc+0x11be>
    2430:	00003097          	auipc	ra,0x3
    2434:	13a080e7          	jalr	314(ra) # 556a <unlink>
  fd = open("README", O_RDONLY);
    2438:	4581                	li	a1,0
    243a:	00004517          	auipc	a0,0x4
    243e:	b9e50513          	addi	a0,a0,-1122 # 5fd8 <malloc+0x686>
    2442:	00003097          	auipc	ra,0x3
    2446:	118080e7          	jalr	280(ra) # 555a <open>
    244a:	892a                	mv	s2,a0
  if(fd < 0){
    244c:	02054963          	bltz	a0,247e <rwsbrk+0x12a>
  n = read(fd, (void*)(a+4096), 10);
    2450:	4629                	li	a2,10
    2452:	85a6                	mv	a1,s1
    2454:	00003097          	auipc	ra,0x3
    2458:	0de080e7          	jalr	222(ra) # 5532 <read>
  if(n >= 0){
    245c:	02054e63          	bltz	a0,2498 <rwsbrk+0x144>
    printf("read(fd, %p, 10) returned %d, not -1\n", a+4096, n);
    2460:	862a                	mv	a2,a0
    2462:	85a6                	mv	a1,s1
    2464:	00004517          	auipc	a0,0x4
    2468:	6fc50513          	addi	a0,a0,1788 # 6b60 <malloc+0x120e>
    246c:	00003097          	auipc	ra,0x3
    2470:	426080e7          	jalr	1062(ra) # 5892 <printf>
    exit(1);
    2474:	4505                	li	a0,1
    2476:	00003097          	auipc	ra,0x3
    247a:	0a4080e7          	jalr	164(ra) # 551a <exit>
    printf("open(rwsbrk) failed\n");
    247e:	00004517          	auipc	a0,0x4
    2482:	69a50513          	addi	a0,a0,1690 # 6b18 <malloc+0x11c6>
    2486:	00003097          	auipc	ra,0x3
    248a:	40c080e7          	jalr	1036(ra) # 5892 <printf>
    exit(1);
    248e:	4505                	li	a0,1
    2490:	00003097          	auipc	ra,0x3
    2494:	08a080e7          	jalr	138(ra) # 551a <exit>
  close(fd);
    2498:	854a                	mv	a0,s2
    249a:	00003097          	auipc	ra,0x3
    249e:	0a8080e7          	jalr	168(ra) # 5542 <close>
  exit(0);
    24a2:	4501                	li	a0,0
    24a4:	00003097          	auipc	ra,0x3
    24a8:	076080e7          	jalr	118(ra) # 551a <exit>

00000000000024ac <sbrkbasic>:
{
    24ac:	715d                	addi	sp,sp,-80
    24ae:	e486                	sd	ra,72(sp)
    24b0:	e0a2                	sd	s0,64(sp)
    24b2:	fc26                	sd	s1,56(sp)
    24b4:	f84a                	sd	s2,48(sp)
    24b6:	f44e                	sd	s3,40(sp)
    24b8:	f052                	sd	s4,32(sp)
    24ba:	ec56                	sd	s5,24(sp)
    24bc:	0880                	addi	s0,sp,80
    24be:	8aaa                	mv	s5,a0
  pid = fork();
    24c0:	00003097          	auipc	ra,0x3
    24c4:	052080e7          	jalr	82(ra) # 5512 <fork>
  if(pid < 0){
    24c8:	02054c63          	bltz	a0,2500 <sbrkbasic+0x54>
  if(pid == 0){
    24cc:	ed21                	bnez	a0,2524 <sbrkbasic+0x78>
    a = sbrk(TOOMUCH);
    24ce:	40000537          	lui	a0,0x40000
    24d2:	00003097          	auipc	ra,0x3
    24d6:	0d0080e7          	jalr	208(ra) # 55a2 <sbrk>
    if(a == (char*)0xffffffffffffffffL){
    24da:	57fd                	li	a5,-1
    24dc:	02f50f63          	beq	a0,a5,251a <sbrkbasic+0x6e>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24e0:	400007b7          	lui	a5,0x40000
    24e4:	97aa                	add	a5,a5,a0
      *b = 99;
    24e6:	06300693          	li	a3,99
    for(b = a; b < a+TOOMUCH; b += 4096){
    24ea:	6705                	lui	a4,0x1
      *b = 99;
    24ec:	00d50023          	sb	a3,0(a0) # 40000000 <_end+0x3fff1678>
    for(b = a; b < a+TOOMUCH; b += 4096){
    24f0:	953a                	add	a0,a0,a4
    24f2:	fef51de3          	bne	a0,a5,24ec <sbrkbasic+0x40>
    exit(1);
    24f6:	4505                	li	a0,1
    24f8:	00003097          	auipc	ra,0x3
    24fc:	022080e7          	jalr	34(ra) # 551a <exit>
    printf("fork failed in sbrkbasic\n");
    2500:	00004517          	auipc	a0,0x4
    2504:	68850513          	addi	a0,a0,1672 # 6b88 <malloc+0x1236>
    2508:	00003097          	auipc	ra,0x3
    250c:	38a080e7          	jalr	906(ra) # 5892 <printf>
    exit(1);
    2510:	4505                	li	a0,1
    2512:	00003097          	auipc	ra,0x3
    2516:	008080e7          	jalr	8(ra) # 551a <exit>
      exit(0);
    251a:	4501                	li	a0,0
    251c:	00003097          	auipc	ra,0x3
    2520:	ffe080e7          	jalr	-2(ra) # 551a <exit>
  wait(&xstatus);
    2524:	fbc40513          	addi	a0,s0,-68
    2528:	00003097          	auipc	ra,0x3
    252c:	ffa080e7          	jalr	-6(ra) # 5522 <wait>
  if(xstatus == 1){
    2530:	fbc42703          	lw	a4,-68(s0)
    2534:	4785                	li	a5,1
    2536:	00f70e63          	beq	a4,a5,2552 <sbrkbasic+0xa6>
  a = sbrk(0);
    253a:	4501                	li	a0,0
    253c:	00003097          	auipc	ra,0x3
    2540:	066080e7          	jalr	102(ra) # 55a2 <sbrk>
    2544:	84aa                	mv	s1,a0
  for(i = 0; i < 5000; i++){
    2546:	4901                	li	s2,0
    *b = 1;
    2548:	4a05                	li	s4,1
  for(i = 0; i < 5000; i++){
    254a:	6985                	lui	s3,0x1
    254c:	38898993          	addi	s3,s3,904 # 1388 <copyinstr2+0x1ae>
    2550:	a005                	j	2570 <sbrkbasic+0xc4>
    printf("%s: too much memory allocated!\n", s);
    2552:	85d6                	mv	a1,s5
    2554:	00004517          	auipc	a0,0x4
    2558:	65450513          	addi	a0,a0,1620 # 6ba8 <malloc+0x1256>
    255c:	00003097          	auipc	ra,0x3
    2560:	336080e7          	jalr	822(ra) # 5892 <printf>
    exit(1);
    2564:	4505                	li	a0,1
    2566:	00003097          	auipc	ra,0x3
    256a:	fb4080e7          	jalr	-76(ra) # 551a <exit>
    a = b + 1;
    256e:	84be                	mv	s1,a5
    b = sbrk(1);
    2570:	4505                	li	a0,1
    2572:	00003097          	auipc	ra,0x3
    2576:	030080e7          	jalr	48(ra) # 55a2 <sbrk>
    if(b != a){
    257a:	04951b63          	bne	a0,s1,25d0 <sbrkbasic+0x124>
    *b = 1;
    257e:	01448023          	sb	s4,0(s1)
    a = b + 1;
    2582:	00148793          	addi	a5,s1,1
  for(i = 0; i < 5000; i++){
    2586:	2905                	addiw	s2,s2,1
    2588:	ff3913e3          	bne	s2,s3,256e <sbrkbasic+0xc2>
  pid = fork();
    258c:	00003097          	auipc	ra,0x3
    2590:	f86080e7          	jalr	-122(ra) # 5512 <fork>
    2594:	892a                	mv	s2,a0
  if(pid < 0){
    2596:	04054d63          	bltz	a0,25f0 <sbrkbasic+0x144>
  c = sbrk(1);
    259a:	4505                	li	a0,1
    259c:	00003097          	auipc	ra,0x3
    25a0:	006080e7          	jalr	6(ra) # 55a2 <sbrk>
  c = sbrk(1);
    25a4:	4505                	li	a0,1
    25a6:	00003097          	auipc	ra,0x3
    25aa:	ffc080e7          	jalr	-4(ra) # 55a2 <sbrk>
  if(c != a + 1){
    25ae:	0489                	addi	s1,s1,2
    25b0:	04a48e63          	beq	s1,a0,260c <sbrkbasic+0x160>
    printf("%s: sbrk test failed post-fork\n", s);
    25b4:	85d6                	mv	a1,s5
    25b6:	00004517          	auipc	a0,0x4
    25ba:	65250513          	addi	a0,a0,1618 # 6c08 <malloc+0x12b6>
    25be:	00003097          	auipc	ra,0x3
    25c2:	2d4080e7          	jalr	724(ra) # 5892 <printf>
    exit(1);
    25c6:	4505                	li	a0,1
    25c8:	00003097          	auipc	ra,0x3
    25cc:	f52080e7          	jalr	-174(ra) # 551a <exit>
      printf("%s: sbrk test failed %d %x %x\n", i, a, b);
    25d0:	86aa                	mv	a3,a0
    25d2:	8626                	mv	a2,s1
    25d4:	85ca                	mv	a1,s2
    25d6:	00004517          	auipc	a0,0x4
    25da:	5f250513          	addi	a0,a0,1522 # 6bc8 <malloc+0x1276>
    25de:	00003097          	auipc	ra,0x3
    25e2:	2b4080e7          	jalr	692(ra) # 5892 <printf>
      exit(1);
    25e6:	4505                	li	a0,1
    25e8:	00003097          	auipc	ra,0x3
    25ec:	f32080e7          	jalr	-206(ra) # 551a <exit>
    printf("%s: sbrk test fork failed\n", s);
    25f0:	85d6                	mv	a1,s5
    25f2:	00004517          	auipc	a0,0x4
    25f6:	5f650513          	addi	a0,a0,1526 # 6be8 <malloc+0x1296>
    25fa:	00003097          	auipc	ra,0x3
    25fe:	298080e7          	jalr	664(ra) # 5892 <printf>
    exit(1);
    2602:	4505                	li	a0,1
    2604:	00003097          	auipc	ra,0x3
    2608:	f16080e7          	jalr	-234(ra) # 551a <exit>
  if(pid == 0)
    260c:	00091763          	bnez	s2,261a <sbrkbasic+0x16e>
    exit(0);
    2610:	4501                	li	a0,0
    2612:	00003097          	auipc	ra,0x3
    2616:	f08080e7          	jalr	-248(ra) # 551a <exit>
  wait(&xstatus);
    261a:	fbc40513          	addi	a0,s0,-68
    261e:	00003097          	auipc	ra,0x3
    2622:	f04080e7          	jalr	-252(ra) # 5522 <wait>
  exit(xstatus);
    2626:	fbc42503          	lw	a0,-68(s0)
    262a:	00003097          	auipc	ra,0x3
    262e:	ef0080e7          	jalr	-272(ra) # 551a <exit>

0000000000002632 <sbrkmuch>:
{
    2632:	7179                	addi	sp,sp,-48
    2634:	f406                	sd	ra,40(sp)
    2636:	f022                	sd	s0,32(sp)
    2638:	ec26                	sd	s1,24(sp)
    263a:	e84a                	sd	s2,16(sp)
    263c:	e44e                	sd	s3,8(sp)
    263e:	e052                	sd	s4,0(sp)
    2640:	1800                	addi	s0,sp,48
    2642:	89aa                	mv	s3,a0
  oldbrk = sbrk(0);
    2644:	4501                	li	a0,0
    2646:	00003097          	auipc	ra,0x3
    264a:	f5c080e7          	jalr	-164(ra) # 55a2 <sbrk>
    264e:	892a                	mv	s2,a0
  a = sbrk(0);
    2650:	4501                	li	a0,0
    2652:	00003097          	auipc	ra,0x3
    2656:	f50080e7          	jalr	-176(ra) # 55a2 <sbrk>
    265a:	84aa                	mv	s1,a0
  p = sbrk(amt);
    265c:	06400537          	lui	a0,0x6400
    2660:	9d05                	subw	a0,a0,s1
    2662:	00003097          	auipc	ra,0x3
    2666:	f40080e7          	jalr	-192(ra) # 55a2 <sbrk>
  if (p != a) {
    266a:	0ca49763          	bne	s1,a0,2738 <sbrkmuch+0x106>
  char *eee = sbrk(0);
    266e:	4501                	li	a0,0
    2670:	00003097          	auipc	ra,0x3
    2674:	f32080e7          	jalr	-206(ra) # 55a2 <sbrk>
  for(char *pp = a; pp < eee; pp += 4096)
    2678:	00a4f963          	bleu	a0,s1,268a <sbrkmuch+0x58>
    *pp = 1;
    267c:	4705                	li	a4,1
  for(char *pp = a; pp < eee; pp += 4096)
    267e:	6785                	lui	a5,0x1
    *pp = 1;
    2680:	00e48023          	sb	a4,0(s1)
  for(char *pp = a; pp < eee; pp += 4096)
    2684:	94be                	add	s1,s1,a5
    2686:	fea4ede3          	bltu	s1,a0,2680 <sbrkmuch+0x4e>
  *lastaddr = 99;
    268a:	064007b7          	lui	a5,0x6400
    268e:	06300713          	li	a4,99
    2692:	fee78fa3          	sb	a4,-1(a5) # 63fffff <_end+0x63f1677>
  a = sbrk(0);
    2696:	4501                	li	a0,0
    2698:	00003097          	auipc	ra,0x3
    269c:	f0a080e7          	jalr	-246(ra) # 55a2 <sbrk>
    26a0:	84aa                	mv	s1,a0
  c = sbrk(-PGSIZE);
    26a2:	757d                	lui	a0,0xfffff
    26a4:	00003097          	auipc	ra,0x3
    26a8:	efe080e7          	jalr	-258(ra) # 55a2 <sbrk>
  if(c == (char*)0xffffffffffffffffL){
    26ac:	57fd                	li	a5,-1
    26ae:	0af50363          	beq	a0,a5,2754 <sbrkmuch+0x122>
  c = sbrk(0);
    26b2:	4501                	li	a0,0
    26b4:	00003097          	auipc	ra,0x3
    26b8:	eee080e7          	jalr	-274(ra) # 55a2 <sbrk>
  if(c != a - PGSIZE){
    26bc:	77fd                	lui	a5,0xfffff
    26be:	97a6                	add	a5,a5,s1
    26c0:	0af51863          	bne	a0,a5,2770 <sbrkmuch+0x13e>
  a = sbrk(0);
    26c4:	4501                	li	a0,0
    26c6:	00003097          	auipc	ra,0x3
    26ca:	edc080e7          	jalr	-292(ra) # 55a2 <sbrk>
    26ce:	84aa                	mv	s1,a0
  c = sbrk(PGSIZE);
    26d0:	6505                	lui	a0,0x1
    26d2:	00003097          	auipc	ra,0x3
    26d6:	ed0080e7          	jalr	-304(ra) # 55a2 <sbrk>
    26da:	8a2a                	mv	s4,a0
  if(c != a || sbrk(0) != a + PGSIZE){
    26dc:	0aa49a63          	bne	s1,a0,2790 <sbrkmuch+0x15e>
    26e0:	4501                	li	a0,0
    26e2:	00003097          	auipc	ra,0x3
    26e6:	ec0080e7          	jalr	-320(ra) # 55a2 <sbrk>
    26ea:	6785                	lui	a5,0x1
    26ec:	97a6                	add	a5,a5,s1
    26ee:	0af51163          	bne	a0,a5,2790 <sbrkmuch+0x15e>
  if(*lastaddr == 99){
    26f2:	064007b7          	lui	a5,0x6400
    26f6:	fff7c703          	lbu	a4,-1(a5) # 63fffff <_end+0x63f1677>
    26fa:	06300793          	li	a5,99
    26fe:	0af70963          	beq	a4,a5,27b0 <sbrkmuch+0x17e>
  a = sbrk(0);
    2702:	4501                	li	a0,0
    2704:	00003097          	auipc	ra,0x3
    2708:	e9e080e7          	jalr	-354(ra) # 55a2 <sbrk>
    270c:	84aa                	mv	s1,a0
  c = sbrk(-(sbrk(0) - oldbrk));
    270e:	4501                	li	a0,0
    2710:	00003097          	auipc	ra,0x3
    2714:	e92080e7          	jalr	-366(ra) # 55a2 <sbrk>
    2718:	40a9053b          	subw	a0,s2,a0
    271c:	00003097          	auipc	ra,0x3
    2720:	e86080e7          	jalr	-378(ra) # 55a2 <sbrk>
  if(c != a){
    2724:	0aa49463          	bne	s1,a0,27cc <sbrkmuch+0x19a>
}
    2728:	70a2                	ld	ra,40(sp)
    272a:	7402                	ld	s0,32(sp)
    272c:	64e2                	ld	s1,24(sp)
    272e:	6942                	ld	s2,16(sp)
    2730:	69a2                	ld	s3,8(sp)
    2732:	6a02                	ld	s4,0(sp)
    2734:	6145                	addi	sp,sp,48
    2736:	8082                	ret
    printf("%s: sbrk test failed to grow big address space; enough phys mem?\n", s);
    2738:	85ce                	mv	a1,s3
    273a:	00004517          	auipc	a0,0x4
    273e:	4ee50513          	addi	a0,a0,1262 # 6c28 <malloc+0x12d6>
    2742:	00003097          	auipc	ra,0x3
    2746:	150080e7          	jalr	336(ra) # 5892 <printf>
    exit(1);
    274a:	4505                	li	a0,1
    274c:	00003097          	auipc	ra,0x3
    2750:	dce080e7          	jalr	-562(ra) # 551a <exit>
    printf("%s: sbrk could not deallocate\n", s);
    2754:	85ce                	mv	a1,s3
    2756:	00004517          	auipc	a0,0x4
    275a:	51a50513          	addi	a0,a0,1306 # 6c70 <malloc+0x131e>
    275e:	00003097          	auipc	ra,0x3
    2762:	134080e7          	jalr	308(ra) # 5892 <printf>
    exit(1);
    2766:	4505                	li	a0,1
    2768:	00003097          	auipc	ra,0x3
    276c:	db2080e7          	jalr	-590(ra) # 551a <exit>
    printf("%s: sbrk deallocation produced wrong address, a %x c %x\n", s, a, c);
    2770:	86aa                	mv	a3,a0
    2772:	8626                	mv	a2,s1
    2774:	85ce                	mv	a1,s3
    2776:	00004517          	auipc	a0,0x4
    277a:	51a50513          	addi	a0,a0,1306 # 6c90 <malloc+0x133e>
    277e:	00003097          	auipc	ra,0x3
    2782:	114080e7          	jalr	276(ra) # 5892 <printf>
    exit(1);
    2786:	4505                	li	a0,1
    2788:	00003097          	auipc	ra,0x3
    278c:	d92080e7          	jalr	-622(ra) # 551a <exit>
    printf("%s: sbrk re-allocation failed, a %x c %x\n", s, a, c);
    2790:	86d2                	mv	a3,s4
    2792:	8626                	mv	a2,s1
    2794:	85ce                	mv	a1,s3
    2796:	00004517          	auipc	a0,0x4
    279a:	53a50513          	addi	a0,a0,1338 # 6cd0 <malloc+0x137e>
    279e:	00003097          	auipc	ra,0x3
    27a2:	0f4080e7          	jalr	244(ra) # 5892 <printf>
    exit(1);
    27a6:	4505                	li	a0,1
    27a8:	00003097          	auipc	ra,0x3
    27ac:	d72080e7          	jalr	-654(ra) # 551a <exit>
    printf("%s: sbrk de-allocation didn't really deallocate\n", s);
    27b0:	85ce                	mv	a1,s3
    27b2:	00004517          	auipc	a0,0x4
    27b6:	54e50513          	addi	a0,a0,1358 # 6d00 <malloc+0x13ae>
    27ba:	00003097          	auipc	ra,0x3
    27be:	0d8080e7          	jalr	216(ra) # 5892 <printf>
    exit(1);
    27c2:	4505                	li	a0,1
    27c4:	00003097          	auipc	ra,0x3
    27c8:	d56080e7          	jalr	-682(ra) # 551a <exit>
    printf("%s: sbrk downsize failed, a %x c %x\n", s, a, c);
    27cc:	86aa                	mv	a3,a0
    27ce:	8626                	mv	a2,s1
    27d0:	85ce                	mv	a1,s3
    27d2:	00004517          	auipc	a0,0x4
    27d6:	56650513          	addi	a0,a0,1382 # 6d38 <malloc+0x13e6>
    27da:	00003097          	auipc	ra,0x3
    27de:	0b8080e7          	jalr	184(ra) # 5892 <printf>
    exit(1);
    27e2:	4505                	li	a0,1
    27e4:	00003097          	auipc	ra,0x3
    27e8:	d36080e7          	jalr	-714(ra) # 551a <exit>

00000000000027ec <sbrkarg>:
{
    27ec:	7179                	addi	sp,sp,-48
    27ee:	f406                	sd	ra,40(sp)
    27f0:	f022                	sd	s0,32(sp)
    27f2:	ec26                	sd	s1,24(sp)
    27f4:	e84a                	sd	s2,16(sp)
    27f6:	e44e                	sd	s3,8(sp)
    27f8:	1800                	addi	s0,sp,48
    27fa:	89aa                	mv	s3,a0
  a = sbrk(PGSIZE);
    27fc:	6505                	lui	a0,0x1
    27fe:	00003097          	auipc	ra,0x3
    2802:	da4080e7          	jalr	-604(ra) # 55a2 <sbrk>
    2806:	892a                	mv	s2,a0
  fd = open("sbrk", O_CREATE|O_WRONLY);
    2808:	20100593          	li	a1,513
    280c:	00004517          	auipc	a0,0x4
    2810:	55450513          	addi	a0,a0,1364 # 6d60 <malloc+0x140e>
    2814:	00003097          	auipc	ra,0x3
    2818:	d46080e7          	jalr	-698(ra) # 555a <open>
    281c:	84aa                	mv	s1,a0
  unlink("sbrk");
    281e:	00004517          	auipc	a0,0x4
    2822:	54250513          	addi	a0,a0,1346 # 6d60 <malloc+0x140e>
    2826:	00003097          	auipc	ra,0x3
    282a:	d44080e7          	jalr	-700(ra) # 556a <unlink>
  if(fd < 0)  {
    282e:	0404c163          	bltz	s1,2870 <sbrkarg+0x84>
  if ((n = write(fd, a, PGSIZE)) < 0) {
    2832:	6605                	lui	a2,0x1
    2834:	85ca                	mv	a1,s2
    2836:	8526                	mv	a0,s1
    2838:	00003097          	auipc	ra,0x3
    283c:	d02080e7          	jalr	-766(ra) # 553a <write>
    2840:	04054663          	bltz	a0,288c <sbrkarg+0xa0>
  close(fd);
    2844:	8526                	mv	a0,s1
    2846:	00003097          	auipc	ra,0x3
    284a:	cfc080e7          	jalr	-772(ra) # 5542 <close>
  a = sbrk(PGSIZE);
    284e:	6505                	lui	a0,0x1
    2850:	00003097          	auipc	ra,0x3
    2854:	d52080e7          	jalr	-686(ra) # 55a2 <sbrk>
  if(pipe((int *) a) != 0){
    2858:	00003097          	auipc	ra,0x3
    285c:	cd2080e7          	jalr	-814(ra) # 552a <pipe>
    2860:	e521                	bnez	a0,28a8 <sbrkarg+0xbc>
}
    2862:	70a2                	ld	ra,40(sp)
    2864:	7402                	ld	s0,32(sp)
    2866:	64e2                	ld	s1,24(sp)
    2868:	6942                	ld	s2,16(sp)
    286a:	69a2                	ld	s3,8(sp)
    286c:	6145                	addi	sp,sp,48
    286e:	8082                	ret
    printf("%s: open sbrk failed\n", s);
    2870:	85ce                	mv	a1,s3
    2872:	00004517          	auipc	a0,0x4
    2876:	4f650513          	addi	a0,a0,1270 # 6d68 <malloc+0x1416>
    287a:	00003097          	auipc	ra,0x3
    287e:	018080e7          	jalr	24(ra) # 5892 <printf>
    exit(1);
    2882:	4505                	li	a0,1
    2884:	00003097          	auipc	ra,0x3
    2888:	c96080e7          	jalr	-874(ra) # 551a <exit>
    printf("%s: write sbrk failed\n", s);
    288c:	85ce                	mv	a1,s3
    288e:	00004517          	auipc	a0,0x4
    2892:	4f250513          	addi	a0,a0,1266 # 6d80 <malloc+0x142e>
    2896:	00003097          	auipc	ra,0x3
    289a:	ffc080e7          	jalr	-4(ra) # 5892 <printf>
    exit(1);
    289e:	4505                	li	a0,1
    28a0:	00003097          	auipc	ra,0x3
    28a4:	c7a080e7          	jalr	-902(ra) # 551a <exit>
    printf("%s: pipe() failed\n", s);
    28a8:	85ce                	mv	a1,s3
    28aa:	00004517          	auipc	a0,0x4
    28ae:	ee650513          	addi	a0,a0,-282 # 6790 <malloc+0xe3e>
    28b2:	00003097          	auipc	ra,0x3
    28b6:	fe0080e7          	jalr	-32(ra) # 5892 <printf>
    exit(1);
    28ba:	4505                	li	a0,1
    28bc:	00003097          	auipc	ra,0x3
    28c0:	c5e080e7          	jalr	-930(ra) # 551a <exit>

00000000000028c4 <argptest>:
{
    28c4:	1101                	addi	sp,sp,-32
    28c6:	ec06                	sd	ra,24(sp)
    28c8:	e822                	sd	s0,16(sp)
    28ca:	e426                	sd	s1,8(sp)
    28cc:	e04a                	sd	s2,0(sp)
    28ce:	1000                	addi	s0,sp,32
    28d0:	892a                	mv	s2,a0
  fd = open("init", O_RDONLY);
    28d2:	4581                	li	a1,0
    28d4:	00004517          	auipc	a0,0x4
    28d8:	4c450513          	addi	a0,a0,1220 # 6d98 <malloc+0x1446>
    28dc:	00003097          	auipc	ra,0x3
    28e0:	c7e080e7          	jalr	-898(ra) # 555a <open>
  if (fd < 0) {
    28e4:	02054b63          	bltz	a0,291a <argptest+0x56>
    28e8:	84aa                	mv	s1,a0
  read(fd, sbrk(0) - 1, -1);
    28ea:	4501                	li	a0,0
    28ec:	00003097          	auipc	ra,0x3
    28f0:	cb6080e7          	jalr	-842(ra) # 55a2 <sbrk>
    28f4:	567d                	li	a2,-1
    28f6:	fff50593          	addi	a1,a0,-1
    28fa:	8526                	mv	a0,s1
    28fc:	00003097          	auipc	ra,0x3
    2900:	c36080e7          	jalr	-970(ra) # 5532 <read>
  close(fd);
    2904:	8526                	mv	a0,s1
    2906:	00003097          	auipc	ra,0x3
    290a:	c3c080e7          	jalr	-964(ra) # 5542 <close>
}
    290e:	60e2                	ld	ra,24(sp)
    2910:	6442                	ld	s0,16(sp)
    2912:	64a2                	ld	s1,8(sp)
    2914:	6902                	ld	s2,0(sp)
    2916:	6105                	addi	sp,sp,32
    2918:	8082                	ret
    printf("%s: open failed\n", s);
    291a:	85ca                	mv	a1,s2
    291c:	00004517          	auipc	a0,0x4
    2920:	d8450513          	addi	a0,a0,-636 # 66a0 <malloc+0xd4e>
    2924:	00003097          	auipc	ra,0x3
    2928:	f6e080e7          	jalr	-146(ra) # 5892 <printf>
    exit(1);
    292c:	4505                	li	a0,1
    292e:	00003097          	auipc	ra,0x3
    2932:	bec080e7          	jalr	-1044(ra) # 551a <exit>

0000000000002936 <sbrkbugs>:
{
    2936:	1141                	addi	sp,sp,-16
    2938:	e406                	sd	ra,8(sp)
    293a:	e022                	sd	s0,0(sp)
    293c:	0800                	addi	s0,sp,16
  int pid = fork();
    293e:	00003097          	auipc	ra,0x3
    2942:	bd4080e7          	jalr	-1068(ra) # 5512 <fork>
  if(pid < 0){
    2946:	02054363          	bltz	a0,296c <sbrkbugs+0x36>
  if(pid == 0){
    294a:	ed15                	bnez	a0,2986 <sbrkbugs+0x50>
    int sz = (uint64) sbrk(0);
    294c:	00003097          	auipc	ra,0x3
    2950:	c56080e7          	jalr	-938(ra) # 55a2 <sbrk>
    sbrk(-sz);
    2954:	40a0053b          	negw	a0,a0
    2958:	2501                	sext.w	a0,a0
    295a:	00003097          	auipc	ra,0x3
    295e:	c48080e7          	jalr	-952(ra) # 55a2 <sbrk>
    exit(0);
    2962:	4501                	li	a0,0
    2964:	00003097          	auipc	ra,0x3
    2968:	bb6080e7          	jalr	-1098(ra) # 551a <exit>
    printf("fork failed\n");
    296c:	00004517          	auipc	a0,0x4
    2970:	10c50513          	addi	a0,a0,268 # 6a78 <malloc+0x1126>
    2974:	00003097          	auipc	ra,0x3
    2978:	f1e080e7          	jalr	-226(ra) # 5892 <printf>
    exit(1);
    297c:	4505                	li	a0,1
    297e:	00003097          	auipc	ra,0x3
    2982:	b9c080e7          	jalr	-1124(ra) # 551a <exit>
  wait(0);
    2986:	4501                	li	a0,0
    2988:	00003097          	auipc	ra,0x3
    298c:	b9a080e7          	jalr	-1126(ra) # 5522 <wait>
  pid = fork();
    2990:	00003097          	auipc	ra,0x3
    2994:	b82080e7          	jalr	-1150(ra) # 5512 <fork>
  if(pid < 0){
    2998:	02054563          	bltz	a0,29c2 <sbrkbugs+0x8c>
  if(pid == 0){
    299c:	e121                	bnez	a0,29dc <sbrkbugs+0xa6>
    int sz = (uint64) sbrk(0);
    299e:	00003097          	auipc	ra,0x3
    29a2:	c04080e7          	jalr	-1020(ra) # 55a2 <sbrk>
    sbrk(-(sz - 3500));
    29a6:	6785                	lui	a5,0x1
    29a8:	dac7879b          	addiw	a5,a5,-596
    29ac:	40a7853b          	subw	a0,a5,a0
    29b0:	00003097          	auipc	ra,0x3
    29b4:	bf2080e7          	jalr	-1038(ra) # 55a2 <sbrk>
    exit(0);
    29b8:	4501                	li	a0,0
    29ba:	00003097          	auipc	ra,0x3
    29be:	b60080e7          	jalr	-1184(ra) # 551a <exit>
    printf("fork failed\n");
    29c2:	00004517          	auipc	a0,0x4
    29c6:	0b650513          	addi	a0,a0,182 # 6a78 <malloc+0x1126>
    29ca:	00003097          	auipc	ra,0x3
    29ce:	ec8080e7          	jalr	-312(ra) # 5892 <printf>
    exit(1);
    29d2:	4505                	li	a0,1
    29d4:	00003097          	auipc	ra,0x3
    29d8:	b46080e7          	jalr	-1210(ra) # 551a <exit>
  wait(0);
    29dc:	4501                	li	a0,0
    29de:	00003097          	auipc	ra,0x3
    29e2:	b44080e7          	jalr	-1212(ra) # 5522 <wait>
  pid = fork();
    29e6:	00003097          	auipc	ra,0x3
    29ea:	b2c080e7          	jalr	-1236(ra) # 5512 <fork>
  if(pid < 0){
    29ee:	02054a63          	bltz	a0,2a22 <sbrkbugs+0xec>
  if(pid == 0){
    29f2:	e529                	bnez	a0,2a3c <sbrkbugs+0x106>
    sbrk((10*4096 + 2048) - (uint64)sbrk(0));
    29f4:	00003097          	auipc	ra,0x3
    29f8:	bae080e7          	jalr	-1106(ra) # 55a2 <sbrk>
    29fc:	67ad                	lui	a5,0xb
    29fe:	8007879b          	addiw	a5,a5,-2048
    2a02:	40a7853b          	subw	a0,a5,a0
    2a06:	00003097          	auipc	ra,0x3
    2a0a:	b9c080e7          	jalr	-1124(ra) # 55a2 <sbrk>
    sbrk(-10);
    2a0e:	5559                	li	a0,-10
    2a10:	00003097          	auipc	ra,0x3
    2a14:	b92080e7          	jalr	-1134(ra) # 55a2 <sbrk>
    exit(0);
    2a18:	4501                	li	a0,0
    2a1a:	00003097          	auipc	ra,0x3
    2a1e:	b00080e7          	jalr	-1280(ra) # 551a <exit>
    printf("fork failed\n");
    2a22:	00004517          	auipc	a0,0x4
    2a26:	05650513          	addi	a0,a0,86 # 6a78 <malloc+0x1126>
    2a2a:	00003097          	auipc	ra,0x3
    2a2e:	e68080e7          	jalr	-408(ra) # 5892 <printf>
    exit(1);
    2a32:	4505                	li	a0,1
    2a34:	00003097          	auipc	ra,0x3
    2a38:	ae6080e7          	jalr	-1306(ra) # 551a <exit>
  wait(0);
    2a3c:	4501                	li	a0,0
    2a3e:	00003097          	auipc	ra,0x3
    2a42:	ae4080e7          	jalr	-1308(ra) # 5522 <wait>
  exit(0);
    2a46:	4501                	li	a0,0
    2a48:	00003097          	auipc	ra,0x3
    2a4c:	ad2080e7          	jalr	-1326(ra) # 551a <exit>

0000000000002a50 <execout>:
// test the exec() code that cleans up if it runs out
// of memory. it's really a test that such a condition
// doesn't cause a panic.
void
execout(char *s)
{
    2a50:	715d                	addi	sp,sp,-80
    2a52:	e486                	sd	ra,72(sp)
    2a54:	e0a2                	sd	s0,64(sp)
    2a56:	fc26                	sd	s1,56(sp)
    2a58:	f84a                	sd	s2,48(sp)
    2a5a:	f44e                	sd	s3,40(sp)
    2a5c:	f052                	sd	s4,32(sp)
    2a5e:	0880                	addi	s0,sp,80
  for(int avail = 0; avail < 15; avail++){
    2a60:	4901                	li	s2,0
    2a62:	49bd                	li	s3,15
    int pid = fork();
    2a64:	00003097          	auipc	ra,0x3
    2a68:	aae080e7          	jalr	-1362(ra) # 5512 <fork>
    2a6c:	84aa                	mv	s1,a0
    if(pid < 0){
    2a6e:	02054063          	bltz	a0,2a8e <execout+0x3e>
      printf("fork failed\n");
      exit(1);
    } else if(pid == 0){
    2a72:	c91d                	beqz	a0,2aa8 <execout+0x58>
      close(1);
      char *args[] = { "echo", "x", 0 };
      exec("echo", args);
      exit(0);
    } else {
      wait((int*)0);
    2a74:	4501                	li	a0,0
    2a76:	00003097          	auipc	ra,0x3
    2a7a:	aac080e7          	jalr	-1364(ra) # 5522 <wait>
  for(int avail = 0; avail < 15; avail++){
    2a7e:	2905                	addiw	s2,s2,1
    2a80:	ff3912e3          	bne	s2,s3,2a64 <execout+0x14>
    }
  }

  exit(0);
    2a84:	4501                	li	a0,0
    2a86:	00003097          	auipc	ra,0x3
    2a8a:	a94080e7          	jalr	-1388(ra) # 551a <exit>
      printf("fork failed\n");
    2a8e:	00004517          	auipc	a0,0x4
    2a92:	fea50513          	addi	a0,a0,-22 # 6a78 <malloc+0x1126>
    2a96:	00003097          	auipc	ra,0x3
    2a9a:	dfc080e7          	jalr	-516(ra) # 5892 <printf>
      exit(1);
    2a9e:	4505                	li	a0,1
    2aa0:	00003097          	auipc	ra,0x3
    2aa4:	a7a080e7          	jalr	-1414(ra) # 551a <exit>
        if(a == 0xffffffffffffffffLL)
    2aa8:	59fd                	li	s3,-1
        *(char*)(a + 4096 - 1) = 1;
    2aaa:	4a05                	li	s4,1
        uint64 a = (uint64) sbrk(4096);
    2aac:	6505                	lui	a0,0x1
    2aae:	00003097          	auipc	ra,0x3
    2ab2:	af4080e7          	jalr	-1292(ra) # 55a2 <sbrk>
        if(a == 0xffffffffffffffffLL)
    2ab6:	01350763          	beq	a0,s3,2ac4 <execout+0x74>
        *(char*)(a + 4096 - 1) = 1;
    2aba:	6785                	lui	a5,0x1
    2abc:	97aa                	add	a5,a5,a0
    2abe:	ff478fa3          	sb	s4,-1(a5) # fff <bigdir+0x77>
      while(1){
    2ac2:	b7ed                	j	2aac <execout+0x5c>
      for(int i = 0; i < avail; i++)
    2ac4:	01205a63          	blez	s2,2ad8 <execout+0x88>
        sbrk(-4096);
    2ac8:	757d                	lui	a0,0xfffff
    2aca:	00003097          	auipc	ra,0x3
    2ace:	ad8080e7          	jalr	-1320(ra) # 55a2 <sbrk>
      for(int i = 0; i < avail; i++)
    2ad2:	2485                	addiw	s1,s1,1
    2ad4:	ff249ae3          	bne	s1,s2,2ac8 <execout+0x78>
      close(1);
    2ad8:	4505                	li	a0,1
    2ada:	00003097          	auipc	ra,0x3
    2ade:	a68080e7          	jalr	-1432(ra) # 5542 <close>
      char *args[] = { "echo", "x", 0 };
    2ae2:	00003517          	auipc	a0,0x3
    2ae6:	34e50513          	addi	a0,a0,846 # 5e30 <malloc+0x4de>
    2aea:	faa43c23          	sd	a0,-72(s0)
    2aee:	00003797          	auipc	a5,0x3
    2af2:	3b278793          	addi	a5,a5,946 # 5ea0 <malloc+0x54e>
    2af6:	fcf43023          	sd	a5,-64(s0)
    2afa:	fc043423          	sd	zero,-56(s0)
      exec("echo", args);
    2afe:	fb840593          	addi	a1,s0,-72
    2b02:	00003097          	auipc	ra,0x3
    2b06:	a50080e7          	jalr	-1456(ra) # 5552 <exec>
      exit(0);
    2b0a:	4501                	li	a0,0
    2b0c:	00003097          	auipc	ra,0x3
    2b10:	a0e080e7          	jalr	-1522(ra) # 551a <exit>

0000000000002b14 <fourteen>:
{
    2b14:	1101                	addi	sp,sp,-32
    2b16:	ec06                	sd	ra,24(sp)
    2b18:	e822                	sd	s0,16(sp)
    2b1a:	e426                	sd	s1,8(sp)
    2b1c:	1000                	addi	s0,sp,32
    2b1e:	84aa                	mv	s1,a0
  if(mkdir("12345678901234") != 0){
    2b20:	00004517          	auipc	a0,0x4
    2b24:	45050513          	addi	a0,a0,1104 # 6f70 <malloc+0x161e>
    2b28:	00003097          	auipc	ra,0x3
    2b2c:	a5a080e7          	jalr	-1446(ra) # 5582 <mkdir>
    2b30:	e165                	bnez	a0,2c10 <fourteen+0xfc>
  if(mkdir("12345678901234/123456789012345") != 0){
    2b32:	00004517          	auipc	a0,0x4
    2b36:	29650513          	addi	a0,a0,662 # 6dc8 <malloc+0x1476>
    2b3a:	00003097          	auipc	ra,0x3
    2b3e:	a48080e7          	jalr	-1464(ra) # 5582 <mkdir>
    2b42:	e56d                	bnez	a0,2c2c <fourteen+0x118>
  fd = open("123456789012345/123456789012345/123456789012345", O_CREATE);
    2b44:	20000593          	li	a1,512
    2b48:	00004517          	auipc	a0,0x4
    2b4c:	2d850513          	addi	a0,a0,728 # 6e20 <malloc+0x14ce>
    2b50:	00003097          	auipc	ra,0x3
    2b54:	a0a080e7          	jalr	-1526(ra) # 555a <open>
  if(fd < 0){
    2b58:	0e054863          	bltz	a0,2c48 <fourteen+0x134>
  close(fd);
    2b5c:	00003097          	auipc	ra,0x3
    2b60:	9e6080e7          	jalr	-1562(ra) # 5542 <close>
  fd = open("12345678901234/12345678901234/12345678901234", 0);
    2b64:	4581                	li	a1,0
    2b66:	00004517          	auipc	a0,0x4
    2b6a:	33250513          	addi	a0,a0,818 # 6e98 <malloc+0x1546>
    2b6e:	00003097          	auipc	ra,0x3
    2b72:	9ec080e7          	jalr	-1556(ra) # 555a <open>
  if(fd < 0){
    2b76:	0e054763          	bltz	a0,2c64 <fourteen+0x150>
  close(fd);
    2b7a:	00003097          	auipc	ra,0x3
    2b7e:	9c8080e7          	jalr	-1592(ra) # 5542 <close>
  if(mkdir("12345678901234/12345678901234") == 0){
    2b82:	00004517          	auipc	a0,0x4
    2b86:	38650513          	addi	a0,a0,902 # 6f08 <malloc+0x15b6>
    2b8a:	00003097          	auipc	ra,0x3
    2b8e:	9f8080e7          	jalr	-1544(ra) # 5582 <mkdir>
    2b92:	c57d                	beqz	a0,2c80 <fourteen+0x16c>
  if(mkdir("123456789012345/12345678901234") == 0){
    2b94:	00004517          	auipc	a0,0x4
    2b98:	3cc50513          	addi	a0,a0,972 # 6f60 <malloc+0x160e>
    2b9c:	00003097          	auipc	ra,0x3
    2ba0:	9e6080e7          	jalr	-1562(ra) # 5582 <mkdir>
    2ba4:	cd65                	beqz	a0,2c9c <fourteen+0x188>
  unlink("123456789012345/12345678901234");
    2ba6:	00004517          	auipc	a0,0x4
    2baa:	3ba50513          	addi	a0,a0,954 # 6f60 <malloc+0x160e>
    2bae:	00003097          	auipc	ra,0x3
    2bb2:	9bc080e7          	jalr	-1604(ra) # 556a <unlink>
  unlink("12345678901234/12345678901234");
    2bb6:	00004517          	auipc	a0,0x4
    2bba:	35250513          	addi	a0,a0,850 # 6f08 <malloc+0x15b6>
    2bbe:	00003097          	auipc	ra,0x3
    2bc2:	9ac080e7          	jalr	-1620(ra) # 556a <unlink>
  unlink("12345678901234/12345678901234/12345678901234");
    2bc6:	00004517          	auipc	a0,0x4
    2bca:	2d250513          	addi	a0,a0,722 # 6e98 <malloc+0x1546>
    2bce:	00003097          	auipc	ra,0x3
    2bd2:	99c080e7          	jalr	-1636(ra) # 556a <unlink>
  unlink("123456789012345/123456789012345/123456789012345");
    2bd6:	00004517          	auipc	a0,0x4
    2bda:	24a50513          	addi	a0,a0,586 # 6e20 <malloc+0x14ce>
    2bde:	00003097          	auipc	ra,0x3
    2be2:	98c080e7          	jalr	-1652(ra) # 556a <unlink>
  unlink("12345678901234/123456789012345");
    2be6:	00004517          	auipc	a0,0x4
    2bea:	1e250513          	addi	a0,a0,482 # 6dc8 <malloc+0x1476>
    2bee:	00003097          	auipc	ra,0x3
    2bf2:	97c080e7          	jalr	-1668(ra) # 556a <unlink>
  unlink("12345678901234");
    2bf6:	00004517          	auipc	a0,0x4
    2bfa:	37a50513          	addi	a0,a0,890 # 6f70 <malloc+0x161e>
    2bfe:	00003097          	auipc	ra,0x3
    2c02:	96c080e7          	jalr	-1684(ra) # 556a <unlink>
}
    2c06:	60e2                	ld	ra,24(sp)
    2c08:	6442                	ld	s0,16(sp)
    2c0a:	64a2                	ld	s1,8(sp)
    2c0c:	6105                	addi	sp,sp,32
    2c0e:	8082                	ret
    printf("%s: mkdir 12345678901234 failed\n", s);
    2c10:	85a6                	mv	a1,s1
    2c12:	00004517          	auipc	a0,0x4
    2c16:	18e50513          	addi	a0,a0,398 # 6da0 <malloc+0x144e>
    2c1a:	00003097          	auipc	ra,0x3
    2c1e:	c78080e7          	jalr	-904(ra) # 5892 <printf>
    exit(1);
    2c22:	4505                	li	a0,1
    2c24:	00003097          	auipc	ra,0x3
    2c28:	8f6080e7          	jalr	-1802(ra) # 551a <exit>
    printf("%s: mkdir 12345678901234/123456789012345 failed\n", s);
    2c2c:	85a6                	mv	a1,s1
    2c2e:	00004517          	auipc	a0,0x4
    2c32:	1ba50513          	addi	a0,a0,442 # 6de8 <malloc+0x1496>
    2c36:	00003097          	auipc	ra,0x3
    2c3a:	c5c080e7          	jalr	-932(ra) # 5892 <printf>
    exit(1);
    2c3e:	4505                	li	a0,1
    2c40:	00003097          	auipc	ra,0x3
    2c44:	8da080e7          	jalr	-1830(ra) # 551a <exit>
    printf("%s: create 123456789012345/123456789012345/123456789012345 failed\n", s);
    2c48:	85a6                	mv	a1,s1
    2c4a:	00004517          	auipc	a0,0x4
    2c4e:	20650513          	addi	a0,a0,518 # 6e50 <malloc+0x14fe>
    2c52:	00003097          	auipc	ra,0x3
    2c56:	c40080e7          	jalr	-960(ra) # 5892 <printf>
    exit(1);
    2c5a:	4505                	li	a0,1
    2c5c:	00003097          	auipc	ra,0x3
    2c60:	8be080e7          	jalr	-1858(ra) # 551a <exit>
    printf("%s: open 12345678901234/12345678901234/12345678901234 failed\n", s);
    2c64:	85a6                	mv	a1,s1
    2c66:	00004517          	auipc	a0,0x4
    2c6a:	26250513          	addi	a0,a0,610 # 6ec8 <malloc+0x1576>
    2c6e:	00003097          	auipc	ra,0x3
    2c72:	c24080e7          	jalr	-988(ra) # 5892 <printf>
    exit(1);
    2c76:	4505                	li	a0,1
    2c78:	00003097          	auipc	ra,0x3
    2c7c:	8a2080e7          	jalr	-1886(ra) # 551a <exit>
    printf("%s: mkdir 12345678901234/12345678901234 succeeded!\n", s);
    2c80:	85a6                	mv	a1,s1
    2c82:	00004517          	auipc	a0,0x4
    2c86:	2a650513          	addi	a0,a0,678 # 6f28 <malloc+0x15d6>
    2c8a:	00003097          	auipc	ra,0x3
    2c8e:	c08080e7          	jalr	-1016(ra) # 5892 <printf>
    exit(1);
    2c92:	4505                	li	a0,1
    2c94:	00003097          	auipc	ra,0x3
    2c98:	886080e7          	jalr	-1914(ra) # 551a <exit>
    printf("%s: mkdir 12345678901234/123456789012345 succeeded!\n", s);
    2c9c:	85a6                	mv	a1,s1
    2c9e:	00004517          	auipc	a0,0x4
    2ca2:	2e250513          	addi	a0,a0,738 # 6f80 <malloc+0x162e>
    2ca6:	00003097          	auipc	ra,0x3
    2caa:	bec080e7          	jalr	-1044(ra) # 5892 <printf>
    exit(1);
    2cae:	4505                	li	a0,1
    2cb0:	00003097          	auipc	ra,0x3
    2cb4:	86a080e7          	jalr	-1942(ra) # 551a <exit>

0000000000002cb8 <iputtest>:
{
    2cb8:	1101                	addi	sp,sp,-32
    2cba:	ec06                	sd	ra,24(sp)
    2cbc:	e822                	sd	s0,16(sp)
    2cbe:	e426                	sd	s1,8(sp)
    2cc0:	1000                	addi	s0,sp,32
    2cc2:	84aa                	mv	s1,a0
  if(mkdir("iputdir") < 0){
    2cc4:	00004517          	auipc	a0,0x4
    2cc8:	2f450513          	addi	a0,a0,756 # 6fb8 <malloc+0x1666>
    2ccc:	00003097          	auipc	ra,0x3
    2cd0:	8b6080e7          	jalr	-1866(ra) # 5582 <mkdir>
    2cd4:	04054563          	bltz	a0,2d1e <iputtest+0x66>
  if(chdir("iputdir") < 0){
    2cd8:	00004517          	auipc	a0,0x4
    2cdc:	2e050513          	addi	a0,a0,736 # 6fb8 <malloc+0x1666>
    2ce0:	00003097          	auipc	ra,0x3
    2ce4:	8aa080e7          	jalr	-1878(ra) # 558a <chdir>
    2ce8:	04054963          	bltz	a0,2d3a <iputtest+0x82>
  if(unlink("../iputdir") < 0){
    2cec:	00004517          	auipc	a0,0x4
    2cf0:	30c50513          	addi	a0,a0,780 # 6ff8 <malloc+0x16a6>
    2cf4:	00003097          	auipc	ra,0x3
    2cf8:	876080e7          	jalr	-1930(ra) # 556a <unlink>
    2cfc:	04054d63          	bltz	a0,2d56 <iputtest+0x9e>
  if(chdir("/") < 0){
    2d00:	00004517          	auipc	a0,0x4
    2d04:	32850513          	addi	a0,a0,808 # 7028 <malloc+0x16d6>
    2d08:	00003097          	auipc	ra,0x3
    2d0c:	882080e7          	jalr	-1918(ra) # 558a <chdir>
    2d10:	06054163          	bltz	a0,2d72 <iputtest+0xba>
}
    2d14:	60e2                	ld	ra,24(sp)
    2d16:	6442                	ld	s0,16(sp)
    2d18:	64a2                	ld	s1,8(sp)
    2d1a:	6105                	addi	sp,sp,32
    2d1c:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2d1e:	85a6                	mv	a1,s1
    2d20:	00004517          	auipc	a0,0x4
    2d24:	2a050513          	addi	a0,a0,672 # 6fc0 <malloc+0x166e>
    2d28:	00003097          	auipc	ra,0x3
    2d2c:	b6a080e7          	jalr	-1174(ra) # 5892 <printf>
    exit(1);
    2d30:	4505                	li	a0,1
    2d32:	00002097          	auipc	ra,0x2
    2d36:	7e8080e7          	jalr	2024(ra) # 551a <exit>
    printf("%s: chdir iputdir failed\n", s);
    2d3a:	85a6                	mv	a1,s1
    2d3c:	00004517          	auipc	a0,0x4
    2d40:	29c50513          	addi	a0,a0,668 # 6fd8 <malloc+0x1686>
    2d44:	00003097          	auipc	ra,0x3
    2d48:	b4e080e7          	jalr	-1202(ra) # 5892 <printf>
    exit(1);
    2d4c:	4505                	li	a0,1
    2d4e:	00002097          	auipc	ra,0x2
    2d52:	7cc080e7          	jalr	1996(ra) # 551a <exit>
    printf("%s: unlink ../iputdir failed\n", s);
    2d56:	85a6                	mv	a1,s1
    2d58:	00004517          	auipc	a0,0x4
    2d5c:	2b050513          	addi	a0,a0,688 # 7008 <malloc+0x16b6>
    2d60:	00003097          	auipc	ra,0x3
    2d64:	b32080e7          	jalr	-1230(ra) # 5892 <printf>
    exit(1);
    2d68:	4505                	li	a0,1
    2d6a:	00002097          	auipc	ra,0x2
    2d6e:	7b0080e7          	jalr	1968(ra) # 551a <exit>
    printf("%s: chdir / failed\n", s);
    2d72:	85a6                	mv	a1,s1
    2d74:	00004517          	auipc	a0,0x4
    2d78:	2bc50513          	addi	a0,a0,700 # 7030 <malloc+0x16de>
    2d7c:	00003097          	auipc	ra,0x3
    2d80:	b16080e7          	jalr	-1258(ra) # 5892 <printf>
    exit(1);
    2d84:	4505                	li	a0,1
    2d86:	00002097          	auipc	ra,0x2
    2d8a:	794080e7          	jalr	1940(ra) # 551a <exit>

0000000000002d8e <exitiputtest>:
{
    2d8e:	7179                	addi	sp,sp,-48
    2d90:	f406                	sd	ra,40(sp)
    2d92:	f022                	sd	s0,32(sp)
    2d94:	ec26                	sd	s1,24(sp)
    2d96:	1800                	addi	s0,sp,48
    2d98:	84aa                	mv	s1,a0
  pid = fork();
    2d9a:	00002097          	auipc	ra,0x2
    2d9e:	778080e7          	jalr	1912(ra) # 5512 <fork>
  if(pid < 0){
    2da2:	04054663          	bltz	a0,2dee <exitiputtest+0x60>
  if(pid == 0){
    2da6:	ed45                	bnez	a0,2e5e <exitiputtest+0xd0>
    if(mkdir("iputdir") < 0){
    2da8:	00004517          	auipc	a0,0x4
    2dac:	21050513          	addi	a0,a0,528 # 6fb8 <malloc+0x1666>
    2db0:	00002097          	auipc	ra,0x2
    2db4:	7d2080e7          	jalr	2002(ra) # 5582 <mkdir>
    2db8:	04054963          	bltz	a0,2e0a <exitiputtest+0x7c>
    if(chdir("iputdir") < 0){
    2dbc:	00004517          	auipc	a0,0x4
    2dc0:	1fc50513          	addi	a0,a0,508 # 6fb8 <malloc+0x1666>
    2dc4:	00002097          	auipc	ra,0x2
    2dc8:	7c6080e7          	jalr	1990(ra) # 558a <chdir>
    2dcc:	04054d63          	bltz	a0,2e26 <exitiputtest+0x98>
    if(unlink("../iputdir") < 0){
    2dd0:	00004517          	auipc	a0,0x4
    2dd4:	22850513          	addi	a0,a0,552 # 6ff8 <malloc+0x16a6>
    2dd8:	00002097          	auipc	ra,0x2
    2ddc:	792080e7          	jalr	1938(ra) # 556a <unlink>
    2de0:	06054163          	bltz	a0,2e42 <exitiputtest+0xb4>
    exit(0);
    2de4:	4501                	li	a0,0
    2de6:	00002097          	auipc	ra,0x2
    2dea:	734080e7          	jalr	1844(ra) # 551a <exit>
    printf("%s: fork failed\n", s);
    2dee:	85a6                	mv	a1,s1
    2df0:	00004517          	auipc	a0,0x4
    2df4:	89850513          	addi	a0,a0,-1896 # 6688 <malloc+0xd36>
    2df8:	00003097          	auipc	ra,0x3
    2dfc:	a9a080e7          	jalr	-1382(ra) # 5892 <printf>
    exit(1);
    2e00:	4505                	li	a0,1
    2e02:	00002097          	auipc	ra,0x2
    2e06:	718080e7          	jalr	1816(ra) # 551a <exit>
      printf("%s: mkdir failed\n", s);
    2e0a:	85a6                	mv	a1,s1
    2e0c:	00004517          	auipc	a0,0x4
    2e10:	1b450513          	addi	a0,a0,436 # 6fc0 <malloc+0x166e>
    2e14:	00003097          	auipc	ra,0x3
    2e18:	a7e080e7          	jalr	-1410(ra) # 5892 <printf>
      exit(1);
    2e1c:	4505                	li	a0,1
    2e1e:	00002097          	auipc	ra,0x2
    2e22:	6fc080e7          	jalr	1788(ra) # 551a <exit>
      printf("%s: child chdir failed\n", s);
    2e26:	85a6                	mv	a1,s1
    2e28:	00004517          	auipc	a0,0x4
    2e2c:	22050513          	addi	a0,a0,544 # 7048 <malloc+0x16f6>
    2e30:	00003097          	auipc	ra,0x3
    2e34:	a62080e7          	jalr	-1438(ra) # 5892 <printf>
      exit(1);
    2e38:	4505                	li	a0,1
    2e3a:	00002097          	auipc	ra,0x2
    2e3e:	6e0080e7          	jalr	1760(ra) # 551a <exit>
      printf("%s: unlink ../iputdir failed\n", s);
    2e42:	85a6                	mv	a1,s1
    2e44:	00004517          	auipc	a0,0x4
    2e48:	1c450513          	addi	a0,a0,452 # 7008 <malloc+0x16b6>
    2e4c:	00003097          	auipc	ra,0x3
    2e50:	a46080e7          	jalr	-1466(ra) # 5892 <printf>
      exit(1);
    2e54:	4505                	li	a0,1
    2e56:	00002097          	auipc	ra,0x2
    2e5a:	6c4080e7          	jalr	1732(ra) # 551a <exit>
  wait(&xstatus);
    2e5e:	fdc40513          	addi	a0,s0,-36
    2e62:	00002097          	auipc	ra,0x2
    2e66:	6c0080e7          	jalr	1728(ra) # 5522 <wait>
  exit(xstatus);
    2e6a:	fdc42503          	lw	a0,-36(s0)
    2e6e:	00002097          	auipc	ra,0x2
    2e72:	6ac080e7          	jalr	1708(ra) # 551a <exit>

0000000000002e76 <dirtest>:
{
    2e76:	1101                	addi	sp,sp,-32
    2e78:	ec06                	sd	ra,24(sp)
    2e7a:	e822                	sd	s0,16(sp)
    2e7c:	e426                	sd	s1,8(sp)
    2e7e:	1000                	addi	s0,sp,32
    2e80:	84aa                	mv	s1,a0
  if(mkdir("dir0") < 0){
    2e82:	00004517          	auipc	a0,0x4
    2e86:	1de50513          	addi	a0,a0,478 # 7060 <malloc+0x170e>
    2e8a:	00002097          	auipc	ra,0x2
    2e8e:	6f8080e7          	jalr	1784(ra) # 5582 <mkdir>
    2e92:	04054563          	bltz	a0,2edc <dirtest+0x66>
  if(chdir("dir0") < 0){
    2e96:	00004517          	auipc	a0,0x4
    2e9a:	1ca50513          	addi	a0,a0,458 # 7060 <malloc+0x170e>
    2e9e:	00002097          	auipc	ra,0x2
    2ea2:	6ec080e7          	jalr	1772(ra) # 558a <chdir>
    2ea6:	04054963          	bltz	a0,2ef8 <dirtest+0x82>
  if(chdir("..") < 0){
    2eaa:	00004517          	auipc	a0,0x4
    2eae:	1d650513          	addi	a0,a0,470 # 7080 <malloc+0x172e>
    2eb2:	00002097          	auipc	ra,0x2
    2eb6:	6d8080e7          	jalr	1752(ra) # 558a <chdir>
    2eba:	04054d63          	bltz	a0,2f14 <dirtest+0x9e>
  if(unlink("dir0") < 0){
    2ebe:	00004517          	auipc	a0,0x4
    2ec2:	1a250513          	addi	a0,a0,418 # 7060 <malloc+0x170e>
    2ec6:	00002097          	auipc	ra,0x2
    2eca:	6a4080e7          	jalr	1700(ra) # 556a <unlink>
    2ece:	06054163          	bltz	a0,2f30 <dirtest+0xba>
}
    2ed2:	60e2                	ld	ra,24(sp)
    2ed4:	6442                	ld	s0,16(sp)
    2ed6:	64a2                	ld	s1,8(sp)
    2ed8:	6105                	addi	sp,sp,32
    2eda:	8082                	ret
    printf("%s: mkdir failed\n", s);
    2edc:	85a6                	mv	a1,s1
    2ede:	00004517          	auipc	a0,0x4
    2ee2:	0e250513          	addi	a0,a0,226 # 6fc0 <malloc+0x166e>
    2ee6:	00003097          	auipc	ra,0x3
    2eea:	9ac080e7          	jalr	-1620(ra) # 5892 <printf>
    exit(1);
    2eee:	4505                	li	a0,1
    2ef0:	00002097          	auipc	ra,0x2
    2ef4:	62a080e7          	jalr	1578(ra) # 551a <exit>
    printf("%s: chdir dir0 failed\n", s);
    2ef8:	85a6                	mv	a1,s1
    2efa:	00004517          	auipc	a0,0x4
    2efe:	16e50513          	addi	a0,a0,366 # 7068 <malloc+0x1716>
    2f02:	00003097          	auipc	ra,0x3
    2f06:	990080e7          	jalr	-1648(ra) # 5892 <printf>
    exit(1);
    2f0a:	4505                	li	a0,1
    2f0c:	00002097          	auipc	ra,0x2
    2f10:	60e080e7          	jalr	1550(ra) # 551a <exit>
    printf("%s: chdir .. failed\n", s);
    2f14:	85a6                	mv	a1,s1
    2f16:	00004517          	auipc	a0,0x4
    2f1a:	17250513          	addi	a0,a0,370 # 7088 <malloc+0x1736>
    2f1e:	00003097          	auipc	ra,0x3
    2f22:	974080e7          	jalr	-1676(ra) # 5892 <printf>
    exit(1);
    2f26:	4505                	li	a0,1
    2f28:	00002097          	auipc	ra,0x2
    2f2c:	5f2080e7          	jalr	1522(ra) # 551a <exit>
    printf("%s: unlink dir0 failed\n", s);
    2f30:	85a6                	mv	a1,s1
    2f32:	00004517          	auipc	a0,0x4
    2f36:	16e50513          	addi	a0,a0,366 # 70a0 <malloc+0x174e>
    2f3a:	00003097          	auipc	ra,0x3
    2f3e:	958080e7          	jalr	-1704(ra) # 5892 <printf>
    exit(1);
    2f42:	4505                	li	a0,1
    2f44:	00002097          	auipc	ra,0x2
    2f48:	5d6080e7          	jalr	1494(ra) # 551a <exit>

0000000000002f4c <subdir>:
{
    2f4c:	1101                	addi	sp,sp,-32
    2f4e:	ec06                	sd	ra,24(sp)
    2f50:	e822                	sd	s0,16(sp)
    2f52:	e426                	sd	s1,8(sp)
    2f54:	e04a                	sd	s2,0(sp)
    2f56:	1000                	addi	s0,sp,32
    2f58:	892a                	mv	s2,a0
  unlink("ff");
    2f5a:	00004517          	auipc	a0,0x4
    2f5e:	28e50513          	addi	a0,a0,654 # 71e8 <malloc+0x1896>
    2f62:	00002097          	auipc	ra,0x2
    2f66:	608080e7          	jalr	1544(ra) # 556a <unlink>
  if(mkdir("dd") != 0){
    2f6a:	00004517          	auipc	a0,0x4
    2f6e:	14e50513          	addi	a0,a0,334 # 70b8 <malloc+0x1766>
    2f72:	00002097          	auipc	ra,0x2
    2f76:	610080e7          	jalr	1552(ra) # 5582 <mkdir>
    2f7a:	38051663          	bnez	a0,3306 <subdir+0x3ba>
  fd = open("dd/ff", O_CREATE | O_RDWR);
    2f7e:	20200593          	li	a1,514
    2f82:	00004517          	auipc	a0,0x4
    2f86:	15650513          	addi	a0,a0,342 # 70d8 <malloc+0x1786>
    2f8a:	00002097          	auipc	ra,0x2
    2f8e:	5d0080e7          	jalr	1488(ra) # 555a <open>
    2f92:	84aa                	mv	s1,a0
  if(fd < 0){
    2f94:	38054763          	bltz	a0,3322 <subdir+0x3d6>
  write(fd, "ff", 2);
    2f98:	4609                	li	a2,2
    2f9a:	00004597          	auipc	a1,0x4
    2f9e:	24e58593          	addi	a1,a1,590 # 71e8 <malloc+0x1896>
    2fa2:	00002097          	auipc	ra,0x2
    2fa6:	598080e7          	jalr	1432(ra) # 553a <write>
  close(fd);
    2faa:	8526                	mv	a0,s1
    2fac:	00002097          	auipc	ra,0x2
    2fb0:	596080e7          	jalr	1430(ra) # 5542 <close>
  if(unlink("dd") >= 0){
    2fb4:	00004517          	auipc	a0,0x4
    2fb8:	10450513          	addi	a0,a0,260 # 70b8 <malloc+0x1766>
    2fbc:	00002097          	auipc	ra,0x2
    2fc0:	5ae080e7          	jalr	1454(ra) # 556a <unlink>
    2fc4:	36055d63          	bgez	a0,333e <subdir+0x3f2>
  if(mkdir("/dd/dd") != 0){
    2fc8:	00004517          	auipc	a0,0x4
    2fcc:	16850513          	addi	a0,a0,360 # 7130 <malloc+0x17de>
    2fd0:	00002097          	auipc	ra,0x2
    2fd4:	5b2080e7          	jalr	1458(ra) # 5582 <mkdir>
    2fd8:	38051163          	bnez	a0,335a <subdir+0x40e>
  fd = open("dd/dd/ff", O_CREATE | O_RDWR);
    2fdc:	20200593          	li	a1,514
    2fe0:	00004517          	auipc	a0,0x4
    2fe4:	17850513          	addi	a0,a0,376 # 7158 <malloc+0x1806>
    2fe8:	00002097          	auipc	ra,0x2
    2fec:	572080e7          	jalr	1394(ra) # 555a <open>
    2ff0:	84aa                	mv	s1,a0
  if(fd < 0){
    2ff2:	38054263          	bltz	a0,3376 <subdir+0x42a>
  write(fd, "FF", 2);
    2ff6:	4609                	li	a2,2
    2ff8:	00004597          	auipc	a1,0x4
    2ffc:	19058593          	addi	a1,a1,400 # 7188 <malloc+0x1836>
    3000:	00002097          	auipc	ra,0x2
    3004:	53a080e7          	jalr	1338(ra) # 553a <write>
  close(fd);
    3008:	8526                	mv	a0,s1
    300a:	00002097          	auipc	ra,0x2
    300e:	538080e7          	jalr	1336(ra) # 5542 <close>
  fd = open("dd/dd/../ff", 0);
    3012:	4581                	li	a1,0
    3014:	00004517          	auipc	a0,0x4
    3018:	17c50513          	addi	a0,a0,380 # 7190 <malloc+0x183e>
    301c:	00002097          	auipc	ra,0x2
    3020:	53e080e7          	jalr	1342(ra) # 555a <open>
    3024:	84aa                	mv	s1,a0
  if(fd < 0){
    3026:	36054663          	bltz	a0,3392 <subdir+0x446>
  cc = read(fd, buf, sizeof(buf));
    302a:	660d                	lui	a2,0x3
    302c:	00009597          	auipc	a1,0x9
    3030:	94c58593          	addi	a1,a1,-1716 # b978 <buf>
    3034:	00002097          	auipc	ra,0x2
    3038:	4fe080e7          	jalr	1278(ra) # 5532 <read>
  if(cc != 2 || buf[0] != 'f'){
    303c:	4789                	li	a5,2
    303e:	36f51863          	bne	a0,a5,33ae <subdir+0x462>
    3042:	00009717          	auipc	a4,0x9
    3046:	93674703          	lbu	a4,-1738(a4) # b978 <buf>
    304a:	06600793          	li	a5,102
    304e:	36f71063          	bne	a4,a5,33ae <subdir+0x462>
  close(fd);
    3052:	8526                	mv	a0,s1
    3054:	00002097          	auipc	ra,0x2
    3058:	4ee080e7          	jalr	1262(ra) # 5542 <close>
  if(link("dd/dd/ff", "dd/dd/ffff") != 0){
    305c:	00004597          	auipc	a1,0x4
    3060:	18458593          	addi	a1,a1,388 # 71e0 <malloc+0x188e>
    3064:	00004517          	auipc	a0,0x4
    3068:	0f450513          	addi	a0,a0,244 # 7158 <malloc+0x1806>
    306c:	00002097          	auipc	ra,0x2
    3070:	50e080e7          	jalr	1294(ra) # 557a <link>
    3074:	34051b63          	bnez	a0,33ca <subdir+0x47e>
  if(unlink("dd/dd/ff") != 0){
    3078:	00004517          	auipc	a0,0x4
    307c:	0e050513          	addi	a0,a0,224 # 7158 <malloc+0x1806>
    3080:	00002097          	auipc	ra,0x2
    3084:	4ea080e7          	jalr	1258(ra) # 556a <unlink>
    3088:	34051f63          	bnez	a0,33e6 <subdir+0x49a>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    308c:	4581                	li	a1,0
    308e:	00004517          	auipc	a0,0x4
    3092:	0ca50513          	addi	a0,a0,202 # 7158 <malloc+0x1806>
    3096:	00002097          	auipc	ra,0x2
    309a:	4c4080e7          	jalr	1220(ra) # 555a <open>
    309e:	36055263          	bgez	a0,3402 <subdir+0x4b6>
  if(chdir("dd") != 0){
    30a2:	00004517          	auipc	a0,0x4
    30a6:	01650513          	addi	a0,a0,22 # 70b8 <malloc+0x1766>
    30aa:	00002097          	auipc	ra,0x2
    30ae:	4e0080e7          	jalr	1248(ra) # 558a <chdir>
    30b2:	36051663          	bnez	a0,341e <subdir+0x4d2>
  if(chdir("dd/../../dd") != 0){
    30b6:	00004517          	auipc	a0,0x4
    30ba:	1c250513          	addi	a0,a0,450 # 7278 <malloc+0x1926>
    30be:	00002097          	auipc	ra,0x2
    30c2:	4cc080e7          	jalr	1228(ra) # 558a <chdir>
    30c6:	36051a63          	bnez	a0,343a <subdir+0x4ee>
  if(chdir("dd/../../../dd") != 0){
    30ca:	00004517          	auipc	a0,0x4
    30ce:	1de50513          	addi	a0,a0,478 # 72a8 <malloc+0x1956>
    30d2:	00002097          	auipc	ra,0x2
    30d6:	4b8080e7          	jalr	1208(ra) # 558a <chdir>
    30da:	36051e63          	bnez	a0,3456 <subdir+0x50a>
  if(chdir("./..") != 0){
    30de:	00004517          	auipc	a0,0x4
    30e2:	1fa50513          	addi	a0,a0,506 # 72d8 <malloc+0x1986>
    30e6:	00002097          	auipc	ra,0x2
    30ea:	4a4080e7          	jalr	1188(ra) # 558a <chdir>
    30ee:	38051263          	bnez	a0,3472 <subdir+0x526>
  fd = open("dd/dd/ffff", 0);
    30f2:	4581                	li	a1,0
    30f4:	00004517          	auipc	a0,0x4
    30f8:	0ec50513          	addi	a0,a0,236 # 71e0 <malloc+0x188e>
    30fc:	00002097          	auipc	ra,0x2
    3100:	45e080e7          	jalr	1118(ra) # 555a <open>
    3104:	84aa                	mv	s1,a0
  if(fd < 0){
    3106:	38054463          	bltz	a0,348e <subdir+0x542>
  if(read(fd, buf, sizeof(buf)) != 2){
    310a:	660d                	lui	a2,0x3
    310c:	00009597          	auipc	a1,0x9
    3110:	86c58593          	addi	a1,a1,-1940 # b978 <buf>
    3114:	00002097          	auipc	ra,0x2
    3118:	41e080e7          	jalr	1054(ra) # 5532 <read>
    311c:	4789                	li	a5,2
    311e:	38f51663          	bne	a0,a5,34aa <subdir+0x55e>
  close(fd);
    3122:	8526                	mv	a0,s1
    3124:	00002097          	auipc	ra,0x2
    3128:	41e080e7          	jalr	1054(ra) # 5542 <close>
  if(open("dd/dd/ff", O_RDONLY) >= 0){
    312c:	4581                	li	a1,0
    312e:	00004517          	auipc	a0,0x4
    3132:	02a50513          	addi	a0,a0,42 # 7158 <malloc+0x1806>
    3136:	00002097          	auipc	ra,0x2
    313a:	424080e7          	jalr	1060(ra) # 555a <open>
    313e:	38055463          	bgez	a0,34c6 <subdir+0x57a>
  if(open("dd/ff/ff", O_CREATE|O_RDWR) >= 0){
    3142:	20200593          	li	a1,514
    3146:	00004517          	auipc	a0,0x4
    314a:	22250513          	addi	a0,a0,546 # 7368 <malloc+0x1a16>
    314e:	00002097          	auipc	ra,0x2
    3152:	40c080e7          	jalr	1036(ra) # 555a <open>
    3156:	38055663          	bgez	a0,34e2 <subdir+0x596>
  if(open("dd/xx/ff", O_CREATE|O_RDWR) >= 0){
    315a:	20200593          	li	a1,514
    315e:	00004517          	auipc	a0,0x4
    3162:	23a50513          	addi	a0,a0,570 # 7398 <malloc+0x1a46>
    3166:	00002097          	auipc	ra,0x2
    316a:	3f4080e7          	jalr	1012(ra) # 555a <open>
    316e:	38055863          	bgez	a0,34fe <subdir+0x5b2>
  if(open("dd", O_CREATE) >= 0){
    3172:	20000593          	li	a1,512
    3176:	00004517          	auipc	a0,0x4
    317a:	f4250513          	addi	a0,a0,-190 # 70b8 <malloc+0x1766>
    317e:	00002097          	auipc	ra,0x2
    3182:	3dc080e7          	jalr	988(ra) # 555a <open>
    3186:	38055a63          	bgez	a0,351a <subdir+0x5ce>
  if(open("dd", O_RDWR) >= 0){
    318a:	4589                	li	a1,2
    318c:	00004517          	auipc	a0,0x4
    3190:	f2c50513          	addi	a0,a0,-212 # 70b8 <malloc+0x1766>
    3194:	00002097          	auipc	ra,0x2
    3198:	3c6080e7          	jalr	966(ra) # 555a <open>
    319c:	38055d63          	bgez	a0,3536 <subdir+0x5ea>
  if(open("dd", O_WRONLY) >= 0){
    31a0:	4585                	li	a1,1
    31a2:	00004517          	auipc	a0,0x4
    31a6:	f1650513          	addi	a0,a0,-234 # 70b8 <malloc+0x1766>
    31aa:	00002097          	auipc	ra,0x2
    31ae:	3b0080e7          	jalr	944(ra) # 555a <open>
    31b2:	3a055063          	bgez	a0,3552 <subdir+0x606>
  if(link("dd/ff/ff", "dd/dd/xx") == 0){
    31b6:	00004597          	auipc	a1,0x4
    31ba:	27258593          	addi	a1,a1,626 # 7428 <malloc+0x1ad6>
    31be:	00004517          	auipc	a0,0x4
    31c2:	1aa50513          	addi	a0,a0,426 # 7368 <malloc+0x1a16>
    31c6:	00002097          	auipc	ra,0x2
    31ca:	3b4080e7          	jalr	948(ra) # 557a <link>
    31ce:	3a050063          	beqz	a0,356e <subdir+0x622>
  if(link("dd/xx/ff", "dd/dd/xx") == 0){
    31d2:	00004597          	auipc	a1,0x4
    31d6:	25658593          	addi	a1,a1,598 # 7428 <malloc+0x1ad6>
    31da:	00004517          	auipc	a0,0x4
    31de:	1be50513          	addi	a0,a0,446 # 7398 <malloc+0x1a46>
    31e2:	00002097          	auipc	ra,0x2
    31e6:	398080e7          	jalr	920(ra) # 557a <link>
    31ea:	3a050063          	beqz	a0,358a <subdir+0x63e>
  if(link("dd/ff", "dd/dd/ffff") == 0){
    31ee:	00004597          	auipc	a1,0x4
    31f2:	ff258593          	addi	a1,a1,-14 # 71e0 <malloc+0x188e>
    31f6:	00004517          	auipc	a0,0x4
    31fa:	ee250513          	addi	a0,a0,-286 # 70d8 <malloc+0x1786>
    31fe:	00002097          	auipc	ra,0x2
    3202:	37c080e7          	jalr	892(ra) # 557a <link>
    3206:	3a050063          	beqz	a0,35a6 <subdir+0x65a>
  if(mkdir("dd/ff/ff") == 0){
    320a:	00004517          	auipc	a0,0x4
    320e:	15e50513          	addi	a0,a0,350 # 7368 <malloc+0x1a16>
    3212:	00002097          	auipc	ra,0x2
    3216:	370080e7          	jalr	880(ra) # 5582 <mkdir>
    321a:	3a050463          	beqz	a0,35c2 <subdir+0x676>
  if(mkdir("dd/xx/ff") == 0){
    321e:	00004517          	auipc	a0,0x4
    3222:	17a50513          	addi	a0,a0,378 # 7398 <malloc+0x1a46>
    3226:	00002097          	auipc	ra,0x2
    322a:	35c080e7          	jalr	860(ra) # 5582 <mkdir>
    322e:	3a050863          	beqz	a0,35de <subdir+0x692>
  if(mkdir("dd/dd/ffff") == 0){
    3232:	00004517          	auipc	a0,0x4
    3236:	fae50513          	addi	a0,a0,-82 # 71e0 <malloc+0x188e>
    323a:	00002097          	auipc	ra,0x2
    323e:	348080e7          	jalr	840(ra) # 5582 <mkdir>
    3242:	3a050c63          	beqz	a0,35fa <subdir+0x6ae>
  if(unlink("dd/xx/ff") == 0){
    3246:	00004517          	auipc	a0,0x4
    324a:	15250513          	addi	a0,a0,338 # 7398 <malloc+0x1a46>
    324e:	00002097          	auipc	ra,0x2
    3252:	31c080e7          	jalr	796(ra) # 556a <unlink>
    3256:	3c050063          	beqz	a0,3616 <subdir+0x6ca>
  if(unlink("dd/ff/ff") == 0){
    325a:	00004517          	auipc	a0,0x4
    325e:	10e50513          	addi	a0,a0,270 # 7368 <malloc+0x1a16>
    3262:	00002097          	auipc	ra,0x2
    3266:	308080e7          	jalr	776(ra) # 556a <unlink>
    326a:	3c050463          	beqz	a0,3632 <subdir+0x6e6>
  if(chdir("dd/ff") == 0){
    326e:	00004517          	auipc	a0,0x4
    3272:	e6a50513          	addi	a0,a0,-406 # 70d8 <malloc+0x1786>
    3276:	00002097          	auipc	ra,0x2
    327a:	314080e7          	jalr	788(ra) # 558a <chdir>
    327e:	3c050863          	beqz	a0,364e <subdir+0x702>
  if(chdir("dd/xx") == 0){
    3282:	00004517          	auipc	a0,0x4
    3286:	2f650513          	addi	a0,a0,758 # 7578 <malloc+0x1c26>
    328a:	00002097          	auipc	ra,0x2
    328e:	300080e7          	jalr	768(ra) # 558a <chdir>
    3292:	3c050c63          	beqz	a0,366a <subdir+0x71e>
  if(unlink("dd/dd/ffff") != 0){
    3296:	00004517          	auipc	a0,0x4
    329a:	f4a50513          	addi	a0,a0,-182 # 71e0 <malloc+0x188e>
    329e:	00002097          	auipc	ra,0x2
    32a2:	2cc080e7          	jalr	716(ra) # 556a <unlink>
    32a6:	3e051063          	bnez	a0,3686 <subdir+0x73a>
  if(unlink("dd/ff") != 0){
    32aa:	00004517          	auipc	a0,0x4
    32ae:	e2e50513          	addi	a0,a0,-466 # 70d8 <malloc+0x1786>
    32b2:	00002097          	auipc	ra,0x2
    32b6:	2b8080e7          	jalr	696(ra) # 556a <unlink>
    32ba:	3e051463          	bnez	a0,36a2 <subdir+0x756>
  if(unlink("dd") == 0){
    32be:	00004517          	auipc	a0,0x4
    32c2:	dfa50513          	addi	a0,a0,-518 # 70b8 <malloc+0x1766>
    32c6:	00002097          	auipc	ra,0x2
    32ca:	2a4080e7          	jalr	676(ra) # 556a <unlink>
    32ce:	3e050863          	beqz	a0,36be <subdir+0x772>
  if(unlink("dd/dd") < 0){
    32d2:	00004517          	auipc	a0,0x4
    32d6:	31650513          	addi	a0,a0,790 # 75e8 <malloc+0x1c96>
    32da:	00002097          	auipc	ra,0x2
    32de:	290080e7          	jalr	656(ra) # 556a <unlink>
    32e2:	3e054c63          	bltz	a0,36da <subdir+0x78e>
  if(unlink("dd") < 0){
    32e6:	00004517          	auipc	a0,0x4
    32ea:	dd250513          	addi	a0,a0,-558 # 70b8 <malloc+0x1766>
    32ee:	00002097          	auipc	ra,0x2
    32f2:	27c080e7          	jalr	636(ra) # 556a <unlink>
    32f6:	40054063          	bltz	a0,36f6 <subdir+0x7aa>
}
    32fa:	60e2                	ld	ra,24(sp)
    32fc:	6442                	ld	s0,16(sp)
    32fe:	64a2                	ld	s1,8(sp)
    3300:	6902                	ld	s2,0(sp)
    3302:	6105                	addi	sp,sp,32
    3304:	8082                	ret
    printf("%s: mkdir dd failed\n", s);
    3306:	85ca                	mv	a1,s2
    3308:	00004517          	auipc	a0,0x4
    330c:	db850513          	addi	a0,a0,-584 # 70c0 <malloc+0x176e>
    3310:	00002097          	auipc	ra,0x2
    3314:	582080e7          	jalr	1410(ra) # 5892 <printf>
    exit(1);
    3318:	4505                	li	a0,1
    331a:	00002097          	auipc	ra,0x2
    331e:	200080e7          	jalr	512(ra) # 551a <exit>
    printf("%s: create dd/ff failed\n", s);
    3322:	85ca                	mv	a1,s2
    3324:	00004517          	auipc	a0,0x4
    3328:	dbc50513          	addi	a0,a0,-580 # 70e0 <malloc+0x178e>
    332c:	00002097          	auipc	ra,0x2
    3330:	566080e7          	jalr	1382(ra) # 5892 <printf>
    exit(1);
    3334:	4505                	li	a0,1
    3336:	00002097          	auipc	ra,0x2
    333a:	1e4080e7          	jalr	484(ra) # 551a <exit>
    printf("%s: unlink dd (non-empty dir) succeeded!\n", s);
    333e:	85ca                	mv	a1,s2
    3340:	00004517          	auipc	a0,0x4
    3344:	dc050513          	addi	a0,a0,-576 # 7100 <malloc+0x17ae>
    3348:	00002097          	auipc	ra,0x2
    334c:	54a080e7          	jalr	1354(ra) # 5892 <printf>
    exit(1);
    3350:	4505                	li	a0,1
    3352:	00002097          	auipc	ra,0x2
    3356:	1c8080e7          	jalr	456(ra) # 551a <exit>
    printf("subdir mkdir dd/dd failed\n", s);
    335a:	85ca                	mv	a1,s2
    335c:	00004517          	auipc	a0,0x4
    3360:	ddc50513          	addi	a0,a0,-548 # 7138 <malloc+0x17e6>
    3364:	00002097          	auipc	ra,0x2
    3368:	52e080e7          	jalr	1326(ra) # 5892 <printf>
    exit(1);
    336c:	4505                	li	a0,1
    336e:	00002097          	auipc	ra,0x2
    3372:	1ac080e7          	jalr	428(ra) # 551a <exit>
    printf("%s: create dd/dd/ff failed\n", s);
    3376:	85ca                	mv	a1,s2
    3378:	00004517          	auipc	a0,0x4
    337c:	df050513          	addi	a0,a0,-528 # 7168 <malloc+0x1816>
    3380:	00002097          	auipc	ra,0x2
    3384:	512080e7          	jalr	1298(ra) # 5892 <printf>
    exit(1);
    3388:	4505                	li	a0,1
    338a:	00002097          	auipc	ra,0x2
    338e:	190080e7          	jalr	400(ra) # 551a <exit>
    printf("%s: open dd/dd/../ff failed\n", s);
    3392:	85ca                	mv	a1,s2
    3394:	00004517          	auipc	a0,0x4
    3398:	e0c50513          	addi	a0,a0,-500 # 71a0 <malloc+0x184e>
    339c:	00002097          	auipc	ra,0x2
    33a0:	4f6080e7          	jalr	1270(ra) # 5892 <printf>
    exit(1);
    33a4:	4505                	li	a0,1
    33a6:	00002097          	auipc	ra,0x2
    33aa:	174080e7          	jalr	372(ra) # 551a <exit>
    printf("%s: dd/dd/../ff wrong content\n", s);
    33ae:	85ca                	mv	a1,s2
    33b0:	00004517          	auipc	a0,0x4
    33b4:	e1050513          	addi	a0,a0,-496 # 71c0 <malloc+0x186e>
    33b8:	00002097          	auipc	ra,0x2
    33bc:	4da080e7          	jalr	1242(ra) # 5892 <printf>
    exit(1);
    33c0:	4505                	li	a0,1
    33c2:	00002097          	auipc	ra,0x2
    33c6:	158080e7          	jalr	344(ra) # 551a <exit>
    printf("link dd/dd/ff dd/dd/ffff failed\n", s);
    33ca:	85ca                	mv	a1,s2
    33cc:	00004517          	auipc	a0,0x4
    33d0:	e2450513          	addi	a0,a0,-476 # 71f0 <malloc+0x189e>
    33d4:	00002097          	auipc	ra,0x2
    33d8:	4be080e7          	jalr	1214(ra) # 5892 <printf>
    exit(1);
    33dc:	4505                	li	a0,1
    33de:	00002097          	auipc	ra,0x2
    33e2:	13c080e7          	jalr	316(ra) # 551a <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    33e6:	85ca                	mv	a1,s2
    33e8:	00004517          	auipc	a0,0x4
    33ec:	e3050513          	addi	a0,a0,-464 # 7218 <malloc+0x18c6>
    33f0:	00002097          	auipc	ra,0x2
    33f4:	4a2080e7          	jalr	1186(ra) # 5892 <printf>
    exit(1);
    33f8:	4505                	li	a0,1
    33fa:	00002097          	auipc	ra,0x2
    33fe:	120080e7          	jalr	288(ra) # 551a <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded\n", s);
    3402:	85ca                	mv	a1,s2
    3404:	00004517          	auipc	a0,0x4
    3408:	e3450513          	addi	a0,a0,-460 # 7238 <malloc+0x18e6>
    340c:	00002097          	auipc	ra,0x2
    3410:	486080e7          	jalr	1158(ra) # 5892 <printf>
    exit(1);
    3414:	4505                	li	a0,1
    3416:	00002097          	auipc	ra,0x2
    341a:	104080e7          	jalr	260(ra) # 551a <exit>
    printf("%s: chdir dd failed\n", s);
    341e:	85ca                	mv	a1,s2
    3420:	00004517          	auipc	a0,0x4
    3424:	e4050513          	addi	a0,a0,-448 # 7260 <malloc+0x190e>
    3428:	00002097          	auipc	ra,0x2
    342c:	46a080e7          	jalr	1130(ra) # 5892 <printf>
    exit(1);
    3430:	4505                	li	a0,1
    3432:	00002097          	auipc	ra,0x2
    3436:	0e8080e7          	jalr	232(ra) # 551a <exit>
    printf("%s: chdir dd/../../dd failed\n", s);
    343a:	85ca                	mv	a1,s2
    343c:	00004517          	auipc	a0,0x4
    3440:	e4c50513          	addi	a0,a0,-436 # 7288 <malloc+0x1936>
    3444:	00002097          	auipc	ra,0x2
    3448:	44e080e7          	jalr	1102(ra) # 5892 <printf>
    exit(1);
    344c:	4505                	li	a0,1
    344e:	00002097          	auipc	ra,0x2
    3452:	0cc080e7          	jalr	204(ra) # 551a <exit>
    printf("chdir dd/../../dd failed\n", s);
    3456:	85ca                	mv	a1,s2
    3458:	00004517          	auipc	a0,0x4
    345c:	e6050513          	addi	a0,a0,-416 # 72b8 <malloc+0x1966>
    3460:	00002097          	auipc	ra,0x2
    3464:	432080e7          	jalr	1074(ra) # 5892 <printf>
    exit(1);
    3468:	4505                	li	a0,1
    346a:	00002097          	auipc	ra,0x2
    346e:	0b0080e7          	jalr	176(ra) # 551a <exit>
    printf("%s: chdir ./.. failed\n", s);
    3472:	85ca                	mv	a1,s2
    3474:	00004517          	auipc	a0,0x4
    3478:	e6c50513          	addi	a0,a0,-404 # 72e0 <malloc+0x198e>
    347c:	00002097          	auipc	ra,0x2
    3480:	416080e7          	jalr	1046(ra) # 5892 <printf>
    exit(1);
    3484:	4505                	li	a0,1
    3486:	00002097          	auipc	ra,0x2
    348a:	094080e7          	jalr	148(ra) # 551a <exit>
    printf("%s: open dd/dd/ffff failed\n", s);
    348e:	85ca                	mv	a1,s2
    3490:	00004517          	auipc	a0,0x4
    3494:	e6850513          	addi	a0,a0,-408 # 72f8 <malloc+0x19a6>
    3498:	00002097          	auipc	ra,0x2
    349c:	3fa080e7          	jalr	1018(ra) # 5892 <printf>
    exit(1);
    34a0:	4505                	li	a0,1
    34a2:	00002097          	auipc	ra,0x2
    34a6:	078080e7          	jalr	120(ra) # 551a <exit>
    printf("%s: read dd/dd/ffff wrong len\n", s);
    34aa:	85ca                	mv	a1,s2
    34ac:	00004517          	auipc	a0,0x4
    34b0:	e6c50513          	addi	a0,a0,-404 # 7318 <malloc+0x19c6>
    34b4:	00002097          	auipc	ra,0x2
    34b8:	3de080e7          	jalr	990(ra) # 5892 <printf>
    exit(1);
    34bc:	4505                	li	a0,1
    34be:	00002097          	auipc	ra,0x2
    34c2:	05c080e7          	jalr	92(ra) # 551a <exit>
    printf("%s: open (unlinked) dd/dd/ff succeeded!\n", s);
    34c6:	85ca                	mv	a1,s2
    34c8:	00004517          	auipc	a0,0x4
    34cc:	e7050513          	addi	a0,a0,-400 # 7338 <malloc+0x19e6>
    34d0:	00002097          	auipc	ra,0x2
    34d4:	3c2080e7          	jalr	962(ra) # 5892 <printf>
    exit(1);
    34d8:	4505                	li	a0,1
    34da:	00002097          	auipc	ra,0x2
    34de:	040080e7          	jalr	64(ra) # 551a <exit>
    printf("%s: create dd/ff/ff succeeded!\n", s);
    34e2:	85ca                	mv	a1,s2
    34e4:	00004517          	auipc	a0,0x4
    34e8:	e9450513          	addi	a0,a0,-364 # 7378 <malloc+0x1a26>
    34ec:	00002097          	auipc	ra,0x2
    34f0:	3a6080e7          	jalr	934(ra) # 5892 <printf>
    exit(1);
    34f4:	4505                	li	a0,1
    34f6:	00002097          	auipc	ra,0x2
    34fa:	024080e7          	jalr	36(ra) # 551a <exit>
    printf("%s: create dd/xx/ff succeeded!\n", s);
    34fe:	85ca                	mv	a1,s2
    3500:	00004517          	auipc	a0,0x4
    3504:	ea850513          	addi	a0,a0,-344 # 73a8 <malloc+0x1a56>
    3508:	00002097          	auipc	ra,0x2
    350c:	38a080e7          	jalr	906(ra) # 5892 <printf>
    exit(1);
    3510:	4505                	li	a0,1
    3512:	00002097          	auipc	ra,0x2
    3516:	008080e7          	jalr	8(ra) # 551a <exit>
    printf("%s: create dd succeeded!\n", s);
    351a:	85ca                	mv	a1,s2
    351c:	00004517          	auipc	a0,0x4
    3520:	eac50513          	addi	a0,a0,-340 # 73c8 <malloc+0x1a76>
    3524:	00002097          	auipc	ra,0x2
    3528:	36e080e7          	jalr	878(ra) # 5892 <printf>
    exit(1);
    352c:	4505                	li	a0,1
    352e:	00002097          	auipc	ra,0x2
    3532:	fec080e7          	jalr	-20(ra) # 551a <exit>
    printf("%s: open dd rdwr succeeded!\n", s);
    3536:	85ca                	mv	a1,s2
    3538:	00004517          	auipc	a0,0x4
    353c:	eb050513          	addi	a0,a0,-336 # 73e8 <malloc+0x1a96>
    3540:	00002097          	auipc	ra,0x2
    3544:	352080e7          	jalr	850(ra) # 5892 <printf>
    exit(1);
    3548:	4505                	li	a0,1
    354a:	00002097          	auipc	ra,0x2
    354e:	fd0080e7          	jalr	-48(ra) # 551a <exit>
    printf("%s: open dd wronly succeeded!\n", s);
    3552:	85ca                	mv	a1,s2
    3554:	00004517          	auipc	a0,0x4
    3558:	eb450513          	addi	a0,a0,-332 # 7408 <malloc+0x1ab6>
    355c:	00002097          	auipc	ra,0x2
    3560:	336080e7          	jalr	822(ra) # 5892 <printf>
    exit(1);
    3564:	4505                	li	a0,1
    3566:	00002097          	auipc	ra,0x2
    356a:	fb4080e7          	jalr	-76(ra) # 551a <exit>
    printf("%s: link dd/ff/ff dd/dd/xx succeeded!\n", s);
    356e:	85ca                	mv	a1,s2
    3570:	00004517          	auipc	a0,0x4
    3574:	ec850513          	addi	a0,a0,-312 # 7438 <malloc+0x1ae6>
    3578:	00002097          	auipc	ra,0x2
    357c:	31a080e7          	jalr	794(ra) # 5892 <printf>
    exit(1);
    3580:	4505                	li	a0,1
    3582:	00002097          	auipc	ra,0x2
    3586:	f98080e7          	jalr	-104(ra) # 551a <exit>
    printf("%s: link dd/xx/ff dd/dd/xx succeeded!\n", s);
    358a:	85ca                	mv	a1,s2
    358c:	00004517          	auipc	a0,0x4
    3590:	ed450513          	addi	a0,a0,-300 # 7460 <malloc+0x1b0e>
    3594:	00002097          	auipc	ra,0x2
    3598:	2fe080e7          	jalr	766(ra) # 5892 <printf>
    exit(1);
    359c:	4505                	li	a0,1
    359e:	00002097          	auipc	ra,0x2
    35a2:	f7c080e7          	jalr	-132(ra) # 551a <exit>
    printf("%s: link dd/ff dd/dd/ffff succeeded!\n", s);
    35a6:	85ca                	mv	a1,s2
    35a8:	00004517          	auipc	a0,0x4
    35ac:	ee050513          	addi	a0,a0,-288 # 7488 <malloc+0x1b36>
    35b0:	00002097          	auipc	ra,0x2
    35b4:	2e2080e7          	jalr	738(ra) # 5892 <printf>
    exit(1);
    35b8:	4505                	li	a0,1
    35ba:	00002097          	auipc	ra,0x2
    35be:	f60080e7          	jalr	-160(ra) # 551a <exit>
    printf("%s: mkdir dd/ff/ff succeeded!\n", s);
    35c2:	85ca                	mv	a1,s2
    35c4:	00004517          	auipc	a0,0x4
    35c8:	eec50513          	addi	a0,a0,-276 # 74b0 <malloc+0x1b5e>
    35cc:	00002097          	auipc	ra,0x2
    35d0:	2c6080e7          	jalr	710(ra) # 5892 <printf>
    exit(1);
    35d4:	4505                	li	a0,1
    35d6:	00002097          	auipc	ra,0x2
    35da:	f44080e7          	jalr	-188(ra) # 551a <exit>
    printf("%s: mkdir dd/xx/ff succeeded!\n", s);
    35de:	85ca                	mv	a1,s2
    35e0:	00004517          	auipc	a0,0x4
    35e4:	ef050513          	addi	a0,a0,-272 # 74d0 <malloc+0x1b7e>
    35e8:	00002097          	auipc	ra,0x2
    35ec:	2aa080e7          	jalr	682(ra) # 5892 <printf>
    exit(1);
    35f0:	4505                	li	a0,1
    35f2:	00002097          	auipc	ra,0x2
    35f6:	f28080e7          	jalr	-216(ra) # 551a <exit>
    printf("%s: mkdir dd/dd/ffff succeeded!\n", s);
    35fa:	85ca                	mv	a1,s2
    35fc:	00004517          	auipc	a0,0x4
    3600:	ef450513          	addi	a0,a0,-268 # 74f0 <malloc+0x1b9e>
    3604:	00002097          	auipc	ra,0x2
    3608:	28e080e7          	jalr	654(ra) # 5892 <printf>
    exit(1);
    360c:	4505                	li	a0,1
    360e:	00002097          	auipc	ra,0x2
    3612:	f0c080e7          	jalr	-244(ra) # 551a <exit>
    printf("%s: unlink dd/xx/ff succeeded!\n", s);
    3616:	85ca                	mv	a1,s2
    3618:	00004517          	auipc	a0,0x4
    361c:	f0050513          	addi	a0,a0,-256 # 7518 <malloc+0x1bc6>
    3620:	00002097          	auipc	ra,0x2
    3624:	272080e7          	jalr	626(ra) # 5892 <printf>
    exit(1);
    3628:	4505                	li	a0,1
    362a:	00002097          	auipc	ra,0x2
    362e:	ef0080e7          	jalr	-272(ra) # 551a <exit>
    printf("%s: unlink dd/ff/ff succeeded!\n", s);
    3632:	85ca                	mv	a1,s2
    3634:	00004517          	auipc	a0,0x4
    3638:	f0450513          	addi	a0,a0,-252 # 7538 <malloc+0x1be6>
    363c:	00002097          	auipc	ra,0x2
    3640:	256080e7          	jalr	598(ra) # 5892 <printf>
    exit(1);
    3644:	4505                	li	a0,1
    3646:	00002097          	auipc	ra,0x2
    364a:	ed4080e7          	jalr	-300(ra) # 551a <exit>
    printf("%s: chdir dd/ff succeeded!\n", s);
    364e:	85ca                	mv	a1,s2
    3650:	00004517          	auipc	a0,0x4
    3654:	f0850513          	addi	a0,a0,-248 # 7558 <malloc+0x1c06>
    3658:	00002097          	auipc	ra,0x2
    365c:	23a080e7          	jalr	570(ra) # 5892 <printf>
    exit(1);
    3660:	4505                	li	a0,1
    3662:	00002097          	auipc	ra,0x2
    3666:	eb8080e7          	jalr	-328(ra) # 551a <exit>
    printf("%s: chdir dd/xx succeeded!\n", s);
    366a:	85ca                	mv	a1,s2
    366c:	00004517          	auipc	a0,0x4
    3670:	f1450513          	addi	a0,a0,-236 # 7580 <malloc+0x1c2e>
    3674:	00002097          	auipc	ra,0x2
    3678:	21e080e7          	jalr	542(ra) # 5892 <printf>
    exit(1);
    367c:	4505                	li	a0,1
    367e:	00002097          	auipc	ra,0x2
    3682:	e9c080e7          	jalr	-356(ra) # 551a <exit>
    printf("%s: unlink dd/dd/ff failed\n", s);
    3686:	85ca                	mv	a1,s2
    3688:	00004517          	auipc	a0,0x4
    368c:	b9050513          	addi	a0,a0,-1136 # 7218 <malloc+0x18c6>
    3690:	00002097          	auipc	ra,0x2
    3694:	202080e7          	jalr	514(ra) # 5892 <printf>
    exit(1);
    3698:	4505                	li	a0,1
    369a:	00002097          	auipc	ra,0x2
    369e:	e80080e7          	jalr	-384(ra) # 551a <exit>
    printf("%s: unlink dd/ff failed\n", s);
    36a2:	85ca                	mv	a1,s2
    36a4:	00004517          	auipc	a0,0x4
    36a8:	efc50513          	addi	a0,a0,-260 # 75a0 <malloc+0x1c4e>
    36ac:	00002097          	auipc	ra,0x2
    36b0:	1e6080e7          	jalr	486(ra) # 5892 <printf>
    exit(1);
    36b4:	4505                	li	a0,1
    36b6:	00002097          	auipc	ra,0x2
    36ba:	e64080e7          	jalr	-412(ra) # 551a <exit>
    printf("%s: unlink non-empty dd succeeded!\n", s);
    36be:	85ca                	mv	a1,s2
    36c0:	00004517          	auipc	a0,0x4
    36c4:	f0050513          	addi	a0,a0,-256 # 75c0 <malloc+0x1c6e>
    36c8:	00002097          	auipc	ra,0x2
    36cc:	1ca080e7          	jalr	458(ra) # 5892 <printf>
    exit(1);
    36d0:	4505                	li	a0,1
    36d2:	00002097          	auipc	ra,0x2
    36d6:	e48080e7          	jalr	-440(ra) # 551a <exit>
    printf("%s: unlink dd/dd failed\n", s);
    36da:	85ca                	mv	a1,s2
    36dc:	00004517          	auipc	a0,0x4
    36e0:	f1450513          	addi	a0,a0,-236 # 75f0 <malloc+0x1c9e>
    36e4:	00002097          	auipc	ra,0x2
    36e8:	1ae080e7          	jalr	430(ra) # 5892 <printf>
    exit(1);
    36ec:	4505                	li	a0,1
    36ee:	00002097          	auipc	ra,0x2
    36f2:	e2c080e7          	jalr	-468(ra) # 551a <exit>
    printf("%s: unlink dd failed\n", s);
    36f6:	85ca                	mv	a1,s2
    36f8:	00004517          	auipc	a0,0x4
    36fc:	f1850513          	addi	a0,a0,-232 # 7610 <malloc+0x1cbe>
    3700:	00002097          	auipc	ra,0x2
    3704:	192080e7          	jalr	402(ra) # 5892 <printf>
    exit(1);
    3708:	4505                	li	a0,1
    370a:	00002097          	auipc	ra,0x2
    370e:	e10080e7          	jalr	-496(ra) # 551a <exit>

0000000000003712 <rmdot>:
{
    3712:	1101                	addi	sp,sp,-32
    3714:	ec06                	sd	ra,24(sp)
    3716:	e822                	sd	s0,16(sp)
    3718:	e426                	sd	s1,8(sp)
    371a:	1000                	addi	s0,sp,32
    371c:	84aa                	mv	s1,a0
  if(mkdir("dots") != 0){
    371e:	00004517          	auipc	a0,0x4
    3722:	f0a50513          	addi	a0,a0,-246 # 7628 <malloc+0x1cd6>
    3726:	00002097          	auipc	ra,0x2
    372a:	e5c080e7          	jalr	-420(ra) # 5582 <mkdir>
    372e:	e549                	bnez	a0,37b8 <rmdot+0xa6>
  if(chdir("dots") != 0){
    3730:	00004517          	auipc	a0,0x4
    3734:	ef850513          	addi	a0,a0,-264 # 7628 <malloc+0x1cd6>
    3738:	00002097          	auipc	ra,0x2
    373c:	e52080e7          	jalr	-430(ra) # 558a <chdir>
    3740:	e951                	bnez	a0,37d4 <rmdot+0xc2>
  if(unlink(".") == 0){
    3742:	00003517          	auipc	a0,0x3
    3746:	da650513          	addi	a0,a0,-602 # 64e8 <malloc+0xb96>
    374a:	00002097          	auipc	ra,0x2
    374e:	e20080e7          	jalr	-480(ra) # 556a <unlink>
    3752:	cd59                	beqz	a0,37f0 <rmdot+0xde>
  if(unlink("..") == 0){
    3754:	00004517          	auipc	a0,0x4
    3758:	92c50513          	addi	a0,a0,-1748 # 7080 <malloc+0x172e>
    375c:	00002097          	auipc	ra,0x2
    3760:	e0e080e7          	jalr	-498(ra) # 556a <unlink>
    3764:	c545                	beqz	a0,380c <rmdot+0xfa>
  if(chdir("/") != 0){
    3766:	00004517          	auipc	a0,0x4
    376a:	8c250513          	addi	a0,a0,-1854 # 7028 <malloc+0x16d6>
    376e:	00002097          	auipc	ra,0x2
    3772:	e1c080e7          	jalr	-484(ra) # 558a <chdir>
    3776:	e94d                	bnez	a0,3828 <rmdot+0x116>
  if(unlink("dots/.") == 0){
    3778:	00004517          	auipc	a0,0x4
    377c:	f1850513          	addi	a0,a0,-232 # 7690 <malloc+0x1d3e>
    3780:	00002097          	auipc	ra,0x2
    3784:	dea080e7          	jalr	-534(ra) # 556a <unlink>
    3788:	cd55                	beqz	a0,3844 <rmdot+0x132>
  if(unlink("dots/..") == 0){
    378a:	00004517          	auipc	a0,0x4
    378e:	f2e50513          	addi	a0,a0,-210 # 76b8 <malloc+0x1d66>
    3792:	00002097          	auipc	ra,0x2
    3796:	dd8080e7          	jalr	-552(ra) # 556a <unlink>
    379a:	c179                	beqz	a0,3860 <rmdot+0x14e>
  if(unlink("dots") != 0){
    379c:	00004517          	auipc	a0,0x4
    37a0:	e8c50513          	addi	a0,a0,-372 # 7628 <malloc+0x1cd6>
    37a4:	00002097          	auipc	ra,0x2
    37a8:	dc6080e7          	jalr	-570(ra) # 556a <unlink>
    37ac:	e961                	bnez	a0,387c <rmdot+0x16a>
}
    37ae:	60e2                	ld	ra,24(sp)
    37b0:	6442                	ld	s0,16(sp)
    37b2:	64a2                	ld	s1,8(sp)
    37b4:	6105                	addi	sp,sp,32
    37b6:	8082                	ret
    printf("%s: mkdir dots failed\n", s);
    37b8:	85a6                	mv	a1,s1
    37ba:	00004517          	auipc	a0,0x4
    37be:	e7650513          	addi	a0,a0,-394 # 7630 <malloc+0x1cde>
    37c2:	00002097          	auipc	ra,0x2
    37c6:	0d0080e7          	jalr	208(ra) # 5892 <printf>
    exit(1);
    37ca:	4505                	li	a0,1
    37cc:	00002097          	auipc	ra,0x2
    37d0:	d4e080e7          	jalr	-690(ra) # 551a <exit>
    printf("%s: chdir dots failed\n", s);
    37d4:	85a6                	mv	a1,s1
    37d6:	00004517          	auipc	a0,0x4
    37da:	e7250513          	addi	a0,a0,-398 # 7648 <malloc+0x1cf6>
    37de:	00002097          	auipc	ra,0x2
    37e2:	0b4080e7          	jalr	180(ra) # 5892 <printf>
    exit(1);
    37e6:	4505                	li	a0,1
    37e8:	00002097          	auipc	ra,0x2
    37ec:	d32080e7          	jalr	-718(ra) # 551a <exit>
    printf("%s: rm . worked!\n", s);
    37f0:	85a6                	mv	a1,s1
    37f2:	00004517          	auipc	a0,0x4
    37f6:	e6e50513          	addi	a0,a0,-402 # 7660 <malloc+0x1d0e>
    37fa:	00002097          	auipc	ra,0x2
    37fe:	098080e7          	jalr	152(ra) # 5892 <printf>
    exit(1);
    3802:	4505                	li	a0,1
    3804:	00002097          	auipc	ra,0x2
    3808:	d16080e7          	jalr	-746(ra) # 551a <exit>
    printf("%s: rm .. worked!\n", s);
    380c:	85a6                	mv	a1,s1
    380e:	00004517          	auipc	a0,0x4
    3812:	e6a50513          	addi	a0,a0,-406 # 7678 <malloc+0x1d26>
    3816:	00002097          	auipc	ra,0x2
    381a:	07c080e7          	jalr	124(ra) # 5892 <printf>
    exit(1);
    381e:	4505                	li	a0,1
    3820:	00002097          	auipc	ra,0x2
    3824:	cfa080e7          	jalr	-774(ra) # 551a <exit>
    printf("%s: chdir / failed\n", s);
    3828:	85a6                	mv	a1,s1
    382a:	00004517          	auipc	a0,0x4
    382e:	80650513          	addi	a0,a0,-2042 # 7030 <malloc+0x16de>
    3832:	00002097          	auipc	ra,0x2
    3836:	060080e7          	jalr	96(ra) # 5892 <printf>
    exit(1);
    383a:	4505                	li	a0,1
    383c:	00002097          	auipc	ra,0x2
    3840:	cde080e7          	jalr	-802(ra) # 551a <exit>
    printf("%s: unlink dots/. worked!\n", s);
    3844:	85a6                	mv	a1,s1
    3846:	00004517          	auipc	a0,0x4
    384a:	e5250513          	addi	a0,a0,-430 # 7698 <malloc+0x1d46>
    384e:	00002097          	auipc	ra,0x2
    3852:	044080e7          	jalr	68(ra) # 5892 <printf>
    exit(1);
    3856:	4505                	li	a0,1
    3858:	00002097          	auipc	ra,0x2
    385c:	cc2080e7          	jalr	-830(ra) # 551a <exit>
    printf("%s: unlink dots/.. worked!\n", s);
    3860:	85a6                	mv	a1,s1
    3862:	00004517          	auipc	a0,0x4
    3866:	e5e50513          	addi	a0,a0,-418 # 76c0 <malloc+0x1d6e>
    386a:	00002097          	auipc	ra,0x2
    386e:	028080e7          	jalr	40(ra) # 5892 <printf>
    exit(1);
    3872:	4505                	li	a0,1
    3874:	00002097          	auipc	ra,0x2
    3878:	ca6080e7          	jalr	-858(ra) # 551a <exit>
    printf("%s: unlink dots failed!\n", s);
    387c:	85a6                	mv	a1,s1
    387e:	00004517          	auipc	a0,0x4
    3882:	e6250513          	addi	a0,a0,-414 # 76e0 <malloc+0x1d8e>
    3886:	00002097          	auipc	ra,0x2
    388a:	00c080e7          	jalr	12(ra) # 5892 <printf>
    exit(1);
    388e:	4505                	li	a0,1
    3890:	00002097          	auipc	ra,0x2
    3894:	c8a080e7          	jalr	-886(ra) # 551a <exit>

0000000000003898 <dirfile>:
{
    3898:	1101                	addi	sp,sp,-32
    389a:	ec06                	sd	ra,24(sp)
    389c:	e822                	sd	s0,16(sp)
    389e:	e426                	sd	s1,8(sp)
    38a0:	e04a                	sd	s2,0(sp)
    38a2:	1000                	addi	s0,sp,32
    38a4:	892a                	mv	s2,a0
  fd = open("dirfile", O_CREATE);
    38a6:	20000593          	li	a1,512
    38aa:	00004517          	auipc	a0,0x4
    38ae:	e5650513          	addi	a0,a0,-426 # 7700 <malloc+0x1dae>
    38b2:	00002097          	auipc	ra,0x2
    38b6:	ca8080e7          	jalr	-856(ra) # 555a <open>
  if(fd < 0){
    38ba:	0e054d63          	bltz	a0,39b4 <dirfile+0x11c>
  close(fd);
    38be:	00002097          	auipc	ra,0x2
    38c2:	c84080e7          	jalr	-892(ra) # 5542 <close>
  if(chdir("dirfile") == 0){
    38c6:	00004517          	auipc	a0,0x4
    38ca:	e3a50513          	addi	a0,a0,-454 # 7700 <malloc+0x1dae>
    38ce:	00002097          	auipc	ra,0x2
    38d2:	cbc080e7          	jalr	-836(ra) # 558a <chdir>
    38d6:	cd6d                	beqz	a0,39d0 <dirfile+0x138>
  fd = open("dirfile/xx", 0);
    38d8:	4581                	li	a1,0
    38da:	00004517          	auipc	a0,0x4
    38de:	e6e50513          	addi	a0,a0,-402 # 7748 <malloc+0x1df6>
    38e2:	00002097          	auipc	ra,0x2
    38e6:	c78080e7          	jalr	-904(ra) # 555a <open>
  if(fd >= 0){
    38ea:	10055163          	bgez	a0,39ec <dirfile+0x154>
  fd = open("dirfile/xx", O_CREATE);
    38ee:	20000593          	li	a1,512
    38f2:	00004517          	auipc	a0,0x4
    38f6:	e5650513          	addi	a0,a0,-426 # 7748 <malloc+0x1df6>
    38fa:	00002097          	auipc	ra,0x2
    38fe:	c60080e7          	jalr	-928(ra) # 555a <open>
  if(fd >= 0){
    3902:	10055363          	bgez	a0,3a08 <dirfile+0x170>
  if(mkdir("dirfile/xx") == 0){
    3906:	00004517          	auipc	a0,0x4
    390a:	e4250513          	addi	a0,a0,-446 # 7748 <malloc+0x1df6>
    390e:	00002097          	auipc	ra,0x2
    3912:	c74080e7          	jalr	-908(ra) # 5582 <mkdir>
    3916:	10050763          	beqz	a0,3a24 <dirfile+0x18c>
  if(unlink("dirfile/xx") == 0){
    391a:	00004517          	auipc	a0,0x4
    391e:	e2e50513          	addi	a0,a0,-466 # 7748 <malloc+0x1df6>
    3922:	00002097          	auipc	ra,0x2
    3926:	c48080e7          	jalr	-952(ra) # 556a <unlink>
    392a:	10050b63          	beqz	a0,3a40 <dirfile+0x1a8>
  if(link("README", "dirfile/xx") == 0){
    392e:	00004597          	auipc	a1,0x4
    3932:	e1a58593          	addi	a1,a1,-486 # 7748 <malloc+0x1df6>
    3936:	00002517          	auipc	a0,0x2
    393a:	6a250513          	addi	a0,a0,1698 # 5fd8 <malloc+0x686>
    393e:	00002097          	auipc	ra,0x2
    3942:	c3c080e7          	jalr	-964(ra) # 557a <link>
    3946:	10050b63          	beqz	a0,3a5c <dirfile+0x1c4>
  if(unlink("dirfile") != 0){
    394a:	00004517          	auipc	a0,0x4
    394e:	db650513          	addi	a0,a0,-586 # 7700 <malloc+0x1dae>
    3952:	00002097          	auipc	ra,0x2
    3956:	c18080e7          	jalr	-1000(ra) # 556a <unlink>
    395a:	10051f63          	bnez	a0,3a78 <dirfile+0x1e0>
  fd = open(".", O_RDWR);
    395e:	4589                	li	a1,2
    3960:	00003517          	auipc	a0,0x3
    3964:	b8850513          	addi	a0,a0,-1144 # 64e8 <malloc+0xb96>
    3968:	00002097          	auipc	ra,0x2
    396c:	bf2080e7          	jalr	-1038(ra) # 555a <open>
  if(fd >= 0){
    3970:	12055263          	bgez	a0,3a94 <dirfile+0x1fc>
  fd = open(".", 0);
    3974:	4581                	li	a1,0
    3976:	00003517          	auipc	a0,0x3
    397a:	b7250513          	addi	a0,a0,-1166 # 64e8 <malloc+0xb96>
    397e:	00002097          	auipc	ra,0x2
    3982:	bdc080e7          	jalr	-1060(ra) # 555a <open>
    3986:	84aa                	mv	s1,a0
  if(write(fd, "x", 1) > 0){
    3988:	4605                	li	a2,1
    398a:	00002597          	auipc	a1,0x2
    398e:	51658593          	addi	a1,a1,1302 # 5ea0 <malloc+0x54e>
    3992:	00002097          	auipc	ra,0x2
    3996:	ba8080e7          	jalr	-1112(ra) # 553a <write>
    399a:	10a04b63          	bgtz	a0,3ab0 <dirfile+0x218>
  close(fd);
    399e:	8526                	mv	a0,s1
    39a0:	00002097          	auipc	ra,0x2
    39a4:	ba2080e7          	jalr	-1118(ra) # 5542 <close>
}
    39a8:	60e2                	ld	ra,24(sp)
    39aa:	6442                	ld	s0,16(sp)
    39ac:	64a2                	ld	s1,8(sp)
    39ae:	6902                	ld	s2,0(sp)
    39b0:	6105                	addi	sp,sp,32
    39b2:	8082                	ret
    printf("%s: create dirfile failed\n", s);
    39b4:	85ca                	mv	a1,s2
    39b6:	00004517          	auipc	a0,0x4
    39ba:	d5250513          	addi	a0,a0,-686 # 7708 <malloc+0x1db6>
    39be:	00002097          	auipc	ra,0x2
    39c2:	ed4080e7          	jalr	-300(ra) # 5892 <printf>
    exit(1);
    39c6:	4505                	li	a0,1
    39c8:	00002097          	auipc	ra,0x2
    39cc:	b52080e7          	jalr	-1198(ra) # 551a <exit>
    printf("%s: chdir dirfile succeeded!\n", s);
    39d0:	85ca                	mv	a1,s2
    39d2:	00004517          	auipc	a0,0x4
    39d6:	d5650513          	addi	a0,a0,-682 # 7728 <malloc+0x1dd6>
    39da:	00002097          	auipc	ra,0x2
    39de:	eb8080e7          	jalr	-328(ra) # 5892 <printf>
    exit(1);
    39e2:	4505                	li	a0,1
    39e4:	00002097          	auipc	ra,0x2
    39e8:	b36080e7          	jalr	-1226(ra) # 551a <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    39ec:	85ca                	mv	a1,s2
    39ee:	00004517          	auipc	a0,0x4
    39f2:	d6a50513          	addi	a0,a0,-662 # 7758 <malloc+0x1e06>
    39f6:	00002097          	auipc	ra,0x2
    39fa:	e9c080e7          	jalr	-356(ra) # 5892 <printf>
    exit(1);
    39fe:	4505                	li	a0,1
    3a00:	00002097          	auipc	ra,0x2
    3a04:	b1a080e7          	jalr	-1254(ra) # 551a <exit>
    printf("%s: create dirfile/xx succeeded!\n", s);
    3a08:	85ca                	mv	a1,s2
    3a0a:	00004517          	auipc	a0,0x4
    3a0e:	d4e50513          	addi	a0,a0,-690 # 7758 <malloc+0x1e06>
    3a12:	00002097          	auipc	ra,0x2
    3a16:	e80080e7          	jalr	-384(ra) # 5892 <printf>
    exit(1);
    3a1a:	4505                	li	a0,1
    3a1c:	00002097          	auipc	ra,0x2
    3a20:	afe080e7          	jalr	-1282(ra) # 551a <exit>
    printf("%s: mkdir dirfile/xx succeeded!\n", s);
    3a24:	85ca                	mv	a1,s2
    3a26:	00004517          	auipc	a0,0x4
    3a2a:	d5a50513          	addi	a0,a0,-678 # 7780 <malloc+0x1e2e>
    3a2e:	00002097          	auipc	ra,0x2
    3a32:	e64080e7          	jalr	-412(ra) # 5892 <printf>
    exit(1);
    3a36:	4505                	li	a0,1
    3a38:	00002097          	auipc	ra,0x2
    3a3c:	ae2080e7          	jalr	-1310(ra) # 551a <exit>
    printf("%s: unlink dirfile/xx succeeded!\n", s);
    3a40:	85ca                	mv	a1,s2
    3a42:	00004517          	auipc	a0,0x4
    3a46:	d6650513          	addi	a0,a0,-666 # 77a8 <malloc+0x1e56>
    3a4a:	00002097          	auipc	ra,0x2
    3a4e:	e48080e7          	jalr	-440(ra) # 5892 <printf>
    exit(1);
    3a52:	4505                	li	a0,1
    3a54:	00002097          	auipc	ra,0x2
    3a58:	ac6080e7          	jalr	-1338(ra) # 551a <exit>
    printf("%s: link to dirfile/xx succeeded!\n", s);
    3a5c:	85ca                	mv	a1,s2
    3a5e:	00004517          	auipc	a0,0x4
    3a62:	d7250513          	addi	a0,a0,-654 # 77d0 <malloc+0x1e7e>
    3a66:	00002097          	auipc	ra,0x2
    3a6a:	e2c080e7          	jalr	-468(ra) # 5892 <printf>
    exit(1);
    3a6e:	4505                	li	a0,1
    3a70:	00002097          	auipc	ra,0x2
    3a74:	aaa080e7          	jalr	-1366(ra) # 551a <exit>
    printf("%s: unlink dirfile failed!\n", s);
    3a78:	85ca                	mv	a1,s2
    3a7a:	00004517          	auipc	a0,0x4
    3a7e:	d7e50513          	addi	a0,a0,-642 # 77f8 <malloc+0x1ea6>
    3a82:	00002097          	auipc	ra,0x2
    3a86:	e10080e7          	jalr	-496(ra) # 5892 <printf>
    exit(1);
    3a8a:	4505                	li	a0,1
    3a8c:	00002097          	auipc	ra,0x2
    3a90:	a8e080e7          	jalr	-1394(ra) # 551a <exit>
    printf("%s: open . for writing succeeded!\n", s);
    3a94:	85ca                	mv	a1,s2
    3a96:	00004517          	auipc	a0,0x4
    3a9a:	d8250513          	addi	a0,a0,-638 # 7818 <malloc+0x1ec6>
    3a9e:	00002097          	auipc	ra,0x2
    3aa2:	df4080e7          	jalr	-524(ra) # 5892 <printf>
    exit(1);
    3aa6:	4505                	li	a0,1
    3aa8:	00002097          	auipc	ra,0x2
    3aac:	a72080e7          	jalr	-1422(ra) # 551a <exit>
    printf("%s: write . succeeded!\n", s);
    3ab0:	85ca                	mv	a1,s2
    3ab2:	00004517          	auipc	a0,0x4
    3ab6:	d8e50513          	addi	a0,a0,-626 # 7840 <malloc+0x1eee>
    3aba:	00002097          	auipc	ra,0x2
    3abe:	dd8080e7          	jalr	-552(ra) # 5892 <printf>
    exit(1);
    3ac2:	4505                	li	a0,1
    3ac4:	00002097          	auipc	ra,0x2
    3ac8:	a56080e7          	jalr	-1450(ra) # 551a <exit>

0000000000003acc <iref>:
{
    3acc:	7139                	addi	sp,sp,-64
    3ace:	fc06                	sd	ra,56(sp)
    3ad0:	f822                	sd	s0,48(sp)
    3ad2:	f426                	sd	s1,40(sp)
    3ad4:	f04a                	sd	s2,32(sp)
    3ad6:	ec4e                	sd	s3,24(sp)
    3ad8:	e852                	sd	s4,16(sp)
    3ada:	e456                	sd	s5,8(sp)
    3adc:	e05a                	sd	s6,0(sp)
    3ade:	0080                	addi	s0,sp,64
    3ae0:	8b2a                	mv	s6,a0
    3ae2:	03300913          	li	s2,51
    if(mkdir("irefd") != 0){
    3ae6:	00004a17          	auipc	s4,0x4
    3aea:	d72a0a13          	addi	s4,s4,-654 # 7858 <malloc+0x1f06>
    mkdir("");
    3aee:	00004497          	auipc	s1,0x4
    3af2:	87248493          	addi	s1,s1,-1934 # 7360 <malloc+0x1a0e>
    link("README", "");
    3af6:	00002a97          	auipc	s5,0x2
    3afa:	4e2a8a93          	addi	s5,s5,1250 # 5fd8 <malloc+0x686>
    fd = open("xx", O_CREATE);
    3afe:	00004997          	auipc	s3,0x4
    3b02:	c5298993          	addi	s3,s3,-942 # 7750 <malloc+0x1dfe>
    3b06:	a891                	j	3b5a <iref+0x8e>
      printf("%s: mkdir irefd failed\n", s);
    3b08:	85da                	mv	a1,s6
    3b0a:	00004517          	auipc	a0,0x4
    3b0e:	d5650513          	addi	a0,a0,-682 # 7860 <malloc+0x1f0e>
    3b12:	00002097          	auipc	ra,0x2
    3b16:	d80080e7          	jalr	-640(ra) # 5892 <printf>
      exit(1);
    3b1a:	4505                	li	a0,1
    3b1c:	00002097          	auipc	ra,0x2
    3b20:	9fe080e7          	jalr	-1538(ra) # 551a <exit>
      printf("%s: chdir irefd failed\n", s);
    3b24:	85da                	mv	a1,s6
    3b26:	00004517          	auipc	a0,0x4
    3b2a:	d5250513          	addi	a0,a0,-686 # 7878 <malloc+0x1f26>
    3b2e:	00002097          	auipc	ra,0x2
    3b32:	d64080e7          	jalr	-668(ra) # 5892 <printf>
      exit(1);
    3b36:	4505                	li	a0,1
    3b38:	00002097          	auipc	ra,0x2
    3b3c:	9e2080e7          	jalr	-1566(ra) # 551a <exit>
      close(fd);
    3b40:	00002097          	auipc	ra,0x2
    3b44:	a02080e7          	jalr	-1534(ra) # 5542 <close>
    3b48:	a889                	j	3b9a <iref+0xce>
    unlink("xx");
    3b4a:	854e                	mv	a0,s3
    3b4c:	00002097          	auipc	ra,0x2
    3b50:	a1e080e7          	jalr	-1506(ra) # 556a <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3b54:	397d                	addiw	s2,s2,-1
    3b56:	06090063          	beqz	s2,3bb6 <iref+0xea>
    if(mkdir("irefd") != 0){
    3b5a:	8552                	mv	a0,s4
    3b5c:	00002097          	auipc	ra,0x2
    3b60:	a26080e7          	jalr	-1498(ra) # 5582 <mkdir>
    3b64:	f155                	bnez	a0,3b08 <iref+0x3c>
    if(chdir("irefd") != 0){
    3b66:	8552                	mv	a0,s4
    3b68:	00002097          	auipc	ra,0x2
    3b6c:	a22080e7          	jalr	-1502(ra) # 558a <chdir>
    3b70:	f955                	bnez	a0,3b24 <iref+0x58>
    mkdir("");
    3b72:	8526                	mv	a0,s1
    3b74:	00002097          	auipc	ra,0x2
    3b78:	a0e080e7          	jalr	-1522(ra) # 5582 <mkdir>
    link("README", "");
    3b7c:	85a6                	mv	a1,s1
    3b7e:	8556                	mv	a0,s5
    3b80:	00002097          	auipc	ra,0x2
    3b84:	9fa080e7          	jalr	-1542(ra) # 557a <link>
    fd = open("", O_CREATE);
    3b88:	20000593          	li	a1,512
    3b8c:	8526                	mv	a0,s1
    3b8e:	00002097          	auipc	ra,0x2
    3b92:	9cc080e7          	jalr	-1588(ra) # 555a <open>
    if(fd >= 0)
    3b96:	fa0555e3          	bgez	a0,3b40 <iref+0x74>
    fd = open("xx", O_CREATE);
    3b9a:	20000593          	li	a1,512
    3b9e:	854e                	mv	a0,s3
    3ba0:	00002097          	auipc	ra,0x2
    3ba4:	9ba080e7          	jalr	-1606(ra) # 555a <open>
    if(fd >= 0)
    3ba8:	fa0541e3          	bltz	a0,3b4a <iref+0x7e>
      close(fd);
    3bac:	00002097          	auipc	ra,0x2
    3bb0:	996080e7          	jalr	-1642(ra) # 5542 <close>
    3bb4:	bf59                	j	3b4a <iref+0x7e>
    3bb6:	03300493          	li	s1,51
    chdir("..");
    3bba:	00003997          	auipc	s3,0x3
    3bbe:	4c698993          	addi	s3,s3,1222 # 7080 <malloc+0x172e>
    unlink("irefd");
    3bc2:	00004917          	auipc	s2,0x4
    3bc6:	c9690913          	addi	s2,s2,-874 # 7858 <malloc+0x1f06>
    chdir("..");
    3bca:	854e                	mv	a0,s3
    3bcc:	00002097          	auipc	ra,0x2
    3bd0:	9be080e7          	jalr	-1602(ra) # 558a <chdir>
    unlink("irefd");
    3bd4:	854a                	mv	a0,s2
    3bd6:	00002097          	auipc	ra,0x2
    3bda:	994080e7          	jalr	-1644(ra) # 556a <unlink>
  for(i = 0; i < NINODE + 1; i++){
    3bde:	34fd                	addiw	s1,s1,-1
    3be0:	f4ed                	bnez	s1,3bca <iref+0xfe>
  chdir("/");
    3be2:	00003517          	auipc	a0,0x3
    3be6:	44650513          	addi	a0,a0,1094 # 7028 <malloc+0x16d6>
    3bea:	00002097          	auipc	ra,0x2
    3bee:	9a0080e7          	jalr	-1632(ra) # 558a <chdir>
}
    3bf2:	70e2                	ld	ra,56(sp)
    3bf4:	7442                	ld	s0,48(sp)
    3bf6:	74a2                	ld	s1,40(sp)
    3bf8:	7902                	ld	s2,32(sp)
    3bfa:	69e2                	ld	s3,24(sp)
    3bfc:	6a42                	ld	s4,16(sp)
    3bfe:	6aa2                	ld	s5,8(sp)
    3c00:	6b02                	ld	s6,0(sp)
    3c02:	6121                	addi	sp,sp,64
    3c04:	8082                	ret

0000000000003c06 <openiputtest>:
{
    3c06:	7179                	addi	sp,sp,-48
    3c08:	f406                	sd	ra,40(sp)
    3c0a:	f022                	sd	s0,32(sp)
    3c0c:	ec26                	sd	s1,24(sp)
    3c0e:	1800                	addi	s0,sp,48
    3c10:	84aa                	mv	s1,a0
  if(mkdir("oidir") < 0){
    3c12:	00004517          	auipc	a0,0x4
    3c16:	c7e50513          	addi	a0,a0,-898 # 7890 <malloc+0x1f3e>
    3c1a:	00002097          	auipc	ra,0x2
    3c1e:	968080e7          	jalr	-1688(ra) # 5582 <mkdir>
    3c22:	04054263          	bltz	a0,3c66 <openiputtest+0x60>
  pid = fork();
    3c26:	00002097          	auipc	ra,0x2
    3c2a:	8ec080e7          	jalr	-1812(ra) # 5512 <fork>
  if(pid < 0){
    3c2e:	04054a63          	bltz	a0,3c82 <openiputtest+0x7c>
  if(pid == 0){
    3c32:	e93d                	bnez	a0,3ca8 <openiputtest+0xa2>
    int fd = open("oidir", O_RDWR);
    3c34:	4589                	li	a1,2
    3c36:	00004517          	auipc	a0,0x4
    3c3a:	c5a50513          	addi	a0,a0,-934 # 7890 <malloc+0x1f3e>
    3c3e:	00002097          	auipc	ra,0x2
    3c42:	91c080e7          	jalr	-1764(ra) # 555a <open>
    if(fd >= 0){
    3c46:	04054c63          	bltz	a0,3c9e <openiputtest+0x98>
      printf("%s: open directory for write succeeded\n", s);
    3c4a:	85a6                	mv	a1,s1
    3c4c:	00004517          	auipc	a0,0x4
    3c50:	c6450513          	addi	a0,a0,-924 # 78b0 <malloc+0x1f5e>
    3c54:	00002097          	auipc	ra,0x2
    3c58:	c3e080e7          	jalr	-962(ra) # 5892 <printf>
      exit(1);
    3c5c:	4505                	li	a0,1
    3c5e:	00002097          	auipc	ra,0x2
    3c62:	8bc080e7          	jalr	-1860(ra) # 551a <exit>
    printf("%s: mkdir oidir failed\n", s);
    3c66:	85a6                	mv	a1,s1
    3c68:	00004517          	auipc	a0,0x4
    3c6c:	c3050513          	addi	a0,a0,-976 # 7898 <malloc+0x1f46>
    3c70:	00002097          	auipc	ra,0x2
    3c74:	c22080e7          	jalr	-990(ra) # 5892 <printf>
    exit(1);
    3c78:	4505                	li	a0,1
    3c7a:	00002097          	auipc	ra,0x2
    3c7e:	8a0080e7          	jalr	-1888(ra) # 551a <exit>
    printf("%s: fork failed\n", s);
    3c82:	85a6                	mv	a1,s1
    3c84:	00003517          	auipc	a0,0x3
    3c88:	a0450513          	addi	a0,a0,-1532 # 6688 <malloc+0xd36>
    3c8c:	00002097          	auipc	ra,0x2
    3c90:	c06080e7          	jalr	-1018(ra) # 5892 <printf>
    exit(1);
    3c94:	4505                	li	a0,1
    3c96:	00002097          	auipc	ra,0x2
    3c9a:	884080e7          	jalr	-1916(ra) # 551a <exit>
    exit(0);
    3c9e:	4501                	li	a0,0
    3ca0:	00002097          	auipc	ra,0x2
    3ca4:	87a080e7          	jalr	-1926(ra) # 551a <exit>
  sleep(1);
    3ca8:	4505                	li	a0,1
    3caa:	00002097          	auipc	ra,0x2
    3cae:	900080e7          	jalr	-1792(ra) # 55aa <sleep>
  if(unlink("oidir") != 0){
    3cb2:	00004517          	auipc	a0,0x4
    3cb6:	bde50513          	addi	a0,a0,-1058 # 7890 <malloc+0x1f3e>
    3cba:	00002097          	auipc	ra,0x2
    3cbe:	8b0080e7          	jalr	-1872(ra) # 556a <unlink>
    3cc2:	cd19                	beqz	a0,3ce0 <openiputtest+0xda>
    printf("%s: unlink failed\n", s);
    3cc4:	85a6                	mv	a1,s1
    3cc6:	00003517          	auipc	a0,0x3
    3cca:	bb250513          	addi	a0,a0,-1102 # 6878 <malloc+0xf26>
    3cce:	00002097          	auipc	ra,0x2
    3cd2:	bc4080e7          	jalr	-1084(ra) # 5892 <printf>
    exit(1);
    3cd6:	4505                	li	a0,1
    3cd8:	00002097          	auipc	ra,0x2
    3cdc:	842080e7          	jalr	-1982(ra) # 551a <exit>
  wait(&xstatus);
    3ce0:	fdc40513          	addi	a0,s0,-36
    3ce4:	00002097          	auipc	ra,0x2
    3ce8:	83e080e7          	jalr	-1986(ra) # 5522 <wait>
  exit(xstatus);
    3cec:	fdc42503          	lw	a0,-36(s0)
    3cf0:	00002097          	auipc	ra,0x2
    3cf4:	82a080e7          	jalr	-2006(ra) # 551a <exit>

0000000000003cf8 <forkforkfork>:
{
    3cf8:	1101                	addi	sp,sp,-32
    3cfa:	ec06                	sd	ra,24(sp)
    3cfc:	e822                	sd	s0,16(sp)
    3cfe:	e426                	sd	s1,8(sp)
    3d00:	1000                	addi	s0,sp,32
    3d02:	84aa                	mv	s1,a0
  unlink("stopforking");
    3d04:	00004517          	auipc	a0,0x4
    3d08:	bd450513          	addi	a0,a0,-1068 # 78d8 <malloc+0x1f86>
    3d0c:	00002097          	auipc	ra,0x2
    3d10:	85e080e7          	jalr	-1954(ra) # 556a <unlink>
  int pid = fork();
    3d14:	00001097          	auipc	ra,0x1
    3d18:	7fe080e7          	jalr	2046(ra) # 5512 <fork>
  if(pid < 0){
    3d1c:	04054563          	bltz	a0,3d66 <forkforkfork+0x6e>
  if(pid == 0){
    3d20:	c12d                	beqz	a0,3d82 <forkforkfork+0x8a>
  sleep(20); // two seconds
    3d22:	4551                	li	a0,20
    3d24:	00002097          	auipc	ra,0x2
    3d28:	886080e7          	jalr	-1914(ra) # 55aa <sleep>
  close(open("stopforking", O_CREATE|O_RDWR));
    3d2c:	20200593          	li	a1,514
    3d30:	00004517          	auipc	a0,0x4
    3d34:	ba850513          	addi	a0,a0,-1112 # 78d8 <malloc+0x1f86>
    3d38:	00002097          	auipc	ra,0x2
    3d3c:	822080e7          	jalr	-2014(ra) # 555a <open>
    3d40:	00002097          	auipc	ra,0x2
    3d44:	802080e7          	jalr	-2046(ra) # 5542 <close>
  wait(0);
    3d48:	4501                	li	a0,0
    3d4a:	00001097          	auipc	ra,0x1
    3d4e:	7d8080e7          	jalr	2008(ra) # 5522 <wait>
  sleep(10); // one second
    3d52:	4529                	li	a0,10
    3d54:	00002097          	auipc	ra,0x2
    3d58:	856080e7          	jalr	-1962(ra) # 55aa <sleep>
}
    3d5c:	60e2                	ld	ra,24(sp)
    3d5e:	6442                	ld	s0,16(sp)
    3d60:	64a2                	ld	s1,8(sp)
    3d62:	6105                	addi	sp,sp,32
    3d64:	8082                	ret
    printf("%s: fork failed", s);
    3d66:	85a6                	mv	a1,s1
    3d68:	00003517          	auipc	a0,0x3
    3d6c:	ae050513          	addi	a0,a0,-1312 # 6848 <malloc+0xef6>
    3d70:	00002097          	auipc	ra,0x2
    3d74:	b22080e7          	jalr	-1246(ra) # 5892 <printf>
    exit(1);
    3d78:	4505                	li	a0,1
    3d7a:	00001097          	auipc	ra,0x1
    3d7e:	7a0080e7          	jalr	1952(ra) # 551a <exit>
      int fd = open("stopforking", 0);
    3d82:	00004497          	auipc	s1,0x4
    3d86:	b5648493          	addi	s1,s1,-1194 # 78d8 <malloc+0x1f86>
    3d8a:	4581                	li	a1,0
    3d8c:	8526                	mv	a0,s1
    3d8e:	00001097          	auipc	ra,0x1
    3d92:	7cc080e7          	jalr	1996(ra) # 555a <open>
      if(fd >= 0){
    3d96:	02055463          	bgez	a0,3dbe <forkforkfork+0xc6>
      if(fork() < 0){
    3d9a:	00001097          	auipc	ra,0x1
    3d9e:	778080e7          	jalr	1912(ra) # 5512 <fork>
    3da2:	fe0554e3          	bgez	a0,3d8a <forkforkfork+0x92>
        close(open("stopforking", O_CREATE|O_RDWR));
    3da6:	20200593          	li	a1,514
    3daa:	8526                	mv	a0,s1
    3dac:	00001097          	auipc	ra,0x1
    3db0:	7ae080e7          	jalr	1966(ra) # 555a <open>
    3db4:	00001097          	auipc	ra,0x1
    3db8:	78e080e7          	jalr	1934(ra) # 5542 <close>
    3dbc:	b7f9                	j	3d8a <forkforkfork+0x92>
        exit(0);
    3dbe:	4501                	li	a0,0
    3dc0:	00001097          	auipc	ra,0x1
    3dc4:	75a080e7          	jalr	1882(ra) # 551a <exit>

0000000000003dc8 <preempt>:
{
    3dc8:	7139                	addi	sp,sp,-64
    3dca:	fc06                	sd	ra,56(sp)
    3dcc:	f822                	sd	s0,48(sp)
    3dce:	f426                	sd	s1,40(sp)
    3dd0:	f04a                	sd	s2,32(sp)
    3dd2:	ec4e                	sd	s3,24(sp)
    3dd4:	e852                	sd	s4,16(sp)
    3dd6:	0080                	addi	s0,sp,64
    3dd8:	8a2a                	mv	s4,a0
  pid1 = fork();
    3dda:	00001097          	auipc	ra,0x1
    3dde:	738080e7          	jalr	1848(ra) # 5512 <fork>
  if(pid1 < 0) {
    3de2:	00054563          	bltz	a0,3dec <preempt+0x24>
    3de6:	89aa                	mv	s3,a0
  if(pid1 == 0)
    3de8:	e105                	bnez	a0,3e08 <preempt+0x40>
    for(;;)
    3dea:	a001                	j	3dea <preempt+0x22>
    printf("%s: fork failed", s);
    3dec:	85d2                	mv	a1,s4
    3dee:	00003517          	auipc	a0,0x3
    3df2:	a5a50513          	addi	a0,a0,-1446 # 6848 <malloc+0xef6>
    3df6:	00002097          	auipc	ra,0x2
    3dfa:	a9c080e7          	jalr	-1380(ra) # 5892 <printf>
    exit(1);
    3dfe:	4505                	li	a0,1
    3e00:	00001097          	auipc	ra,0x1
    3e04:	71a080e7          	jalr	1818(ra) # 551a <exit>
  pid2 = fork();
    3e08:	00001097          	auipc	ra,0x1
    3e0c:	70a080e7          	jalr	1802(ra) # 5512 <fork>
    3e10:	892a                	mv	s2,a0
  if(pid2 < 0) {
    3e12:	00054463          	bltz	a0,3e1a <preempt+0x52>
  if(pid2 == 0)
    3e16:	e105                	bnez	a0,3e36 <preempt+0x6e>
    for(;;)
    3e18:	a001                	j	3e18 <preempt+0x50>
    printf("%s: fork failed\n", s);
    3e1a:	85d2                	mv	a1,s4
    3e1c:	00003517          	auipc	a0,0x3
    3e20:	86c50513          	addi	a0,a0,-1940 # 6688 <malloc+0xd36>
    3e24:	00002097          	auipc	ra,0x2
    3e28:	a6e080e7          	jalr	-1426(ra) # 5892 <printf>
    exit(1);
    3e2c:	4505                	li	a0,1
    3e2e:	00001097          	auipc	ra,0x1
    3e32:	6ec080e7          	jalr	1772(ra) # 551a <exit>
  pipe(pfds);
    3e36:	fc840513          	addi	a0,s0,-56
    3e3a:	00001097          	auipc	ra,0x1
    3e3e:	6f0080e7          	jalr	1776(ra) # 552a <pipe>
  pid3 = fork();
    3e42:	00001097          	auipc	ra,0x1
    3e46:	6d0080e7          	jalr	1744(ra) # 5512 <fork>
    3e4a:	84aa                	mv	s1,a0
  if(pid3 < 0) {
    3e4c:	02054e63          	bltz	a0,3e88 <preempt+0xc0>
  if(pid3 == 0){
    3e50:	e525                	bnez	a0,3eb8 <preempt+0xf0>
    close(pfds[0]);
    3e52:	fc842503          	lw	a0,-56(s0)
    3e56:	00001097          	auipc	ra,0x1
    3e5a:	6ec080e7          	jalr	1772(ra) # 5542 <close>
    if(write(pfds[1], "x", 1) != 1)
    3e5e:	4605                	li	a2,1
    3e60:	00002597          	auipc	a1,0x2
    3e64:	04058593          	addi	a1,a1,64 # 5ea0 <malloc+0x54e>
    3e68:	fcc42503          	lw	a0,-52(s0)
    3e6c:	00001097          	auipc	ra,0x1
    3e70:	6ce080e7          	jalr	1742(ra) # 553a <write>
    3e74:	4785                	li	a5,1
    3e76:	02f51763          	bne	a0,a5,3ea4 <preempt+0xdc>
    close(pfds[1]);
    3e7a:	fcc42503          	lw	a0,-52(s0)
    3e7e:	00001097          	auipc	ra,0x1
    3e82:	6c4080e7          	jalr	1732(ra) # 5542 <close>
    for(;;)
    3e86:	a001                	j	3e86 <preempt+0xbe>
     printf("%s: fork failed\n", s);
    3e88:	85d2                	mv	a1,s4
    3e8a:	00002517          	auipc	a0,0x2
    3e8e:	7fe50513          	addi	a0,a0,2046 # 6688 <malloc+0xd36>
    3e92:	00002097          	auipc	ra,0x2
    3e96:	a00080e7          	jalr	-1536(ra) # 5892 <printf>
     exit(1);
    3e9a:	4505                	li	a0,1
    3e9c:	00001097          	auipc	ra,0x1
    3ea0:	67e080e7          	jalr	1662(ra) # 551a <exit>
      printf("%s: preempt write error", s);
    3ea4:	85d2                	mv	a1,s4
    3ea6:	00004517          	auipc	a0,0x4
    3eaa:	a4250513          	addi	a0,a0,-1470 # 78e8 <malloc+0x1f96>
    3eae:	00002097          	auipc	ra,0x2
    3eb2:	9e4080e7          	jalr	-1564(ra) # 5892 <printf>
    3eb6:	b7d1                	j	3e7a <preempt+0xb2>
  close(pfds[1]);
    3eb8:	fcc42503          	lw	a0,-52(s0)
    3ebc:	00001097          	auipc	ra,0x1
    3ec0:	686080e7          	jalr	1670(ra) # 5542 <close>
  if(read(pfds[0], buf, sizeof(buf)) != 1){
    3ec4:	660d                	lui	a2,0x3
    3ec6:	00008597          	auipc	a1,0x8
    3eca:	ab258593          	addi	a1,a1,-1358 # b978 <buf>
    3ece:	fc842503          	lw	a0,-56(s0)
    3ed2:	00001097          	auipc	ra,0x1
    3ed6:	660080e7          	jalr	1632(ra) # 5532 <read>
    3eda:	4785                	li	a5,1
    3edc:	02f50363          	beq	a0,a5,3f02 <preempt+0x13a>
    printf("%s: preempt read error", s);
    3ee0:	85d2                	mv	a1,s4
    3ee2:	00004517          	auipc	a0,0x4
    3ee6:	a1e50513          	addi	a0,a0,-1506 # 7900 <malloc+0x1fae>
    3eea:	00002097          	auipc	ra,0x2
    3eee:	9a8080e7          	jalr	-1624(ra) # 5892 <printf>
}
    3ef2:	70e2                	ld	ra,56(sp)
    3ef4:	7442                	ld	s0,48(sp)
    3ef6:	74a2                	ld	s1,40(sp)
    3ef8:	7902                	ld	s2,32(sp)
    3efa:	69e2                	ld	s3,24(sp)
    3efc:	6a42                	ld	s4,16(sp)
    3efe:	6121                	addi	sp,sp,64
    3f00:	8082                	ret
  close(pfds[0]);
    3f02:	fc842503          	lw	a0,-56(s0)
    3f06:	00001097          	auipc	ra,0x1
    3f0a:	63c080e7          	jalr	1596(ra) # 5542 <close>
  printf("kill... ");
    3f0e:	00004517          	auipc	a0,0x4
    3f12:	a0a50513          	addi	a0,a0,-1526 # 7918 <malloc+0x1fc6>
    3f16:	00002097          	auipc	ra,0x2
    3f1a:	97c080e7          	jalr	-1668(ra) # 5892 <printf>
  kill(pid1);
    3f1e:	854e                	mv	a0,s3
    3f20:	00001097          	auipc	ra,0x1
    3f24:	62a080e7          	jalr	1578(ra) # 554a <kill>
  kill(pid2);
    3f28:	854a                	mv	a0,s2
    3f2a:	00001097          	auipc	ra,0x1
    3f2e:	620080e7          	jalr	1568(ra) # 554a <kill>
  kill(pid3);
    3f32:	8526                	mv	a0,s1
    3f34:	00001097          	auipc	ra,0x1
    3f38:	616080e7          	jalr	1558(ra) # 554a <kill>
  printf("wait... ");
    3f3c:	00004517          	auipc	a0,0x4
    3f40:	9ec50513          	addi	a0,a0,-1556 # 7928 <malloc+0x1fd6>
    3f44:	00002097          	auipc	ra,0x2
    3f48:	94e080e7          	jalr	-1714(ra) # 5892 <printf>
  wait(0);
    3f4c:	4501                	li	a0,0
    3f4e:	00001097          	auipc	ra,0x1
    3f52:	5d4080e7          	jalr	1492(ra) # 5522 <wait>
  wait(0);
    3f56:	4501                	li	a0,0
    3f58:	00001097          	auipc	ra,0x1
    3f5c:	5ca080e7          	jalr	1482(ra) # 5522 <wait>
  wait(0);
    3f60:	4501                	li	a0,0
    3f62:	00001097          	auipc	ra,0x1
    3f66:	5c0080e7          	jalr	1472(ra) # 5522 <wait>
    3f6a:	b761                	j	3ef2 <preempt+0x12a>

0000000000003f6c <sbrkfail>:
{
    3f6c:	7119                	addi	sp,sp,-128
    3f6e:	fc86                	sd	ra,120(sp)
    3f70:	f8a2                	sd	s0,112(sp)
    3f72:	f4a6                	sd	s1,104(sp)
    3f74:	f0ca                	sd	s2,96(sp)
    3f76:	ecce                	sd	s3,88(sp)
    3f78:	e8d2                	sd	s4,80(sp)
    3f7a:	e4d6                	sd	s5,72(sp)
    3f7c:	0100                	addi	s0,sp,128
    3f7e:	8aaa                	mv	s5,a0
  if(pipe(fds) != 0){
    3f80:	fb040513          	addi	a0,s0,-80
    3f84:	00001097          	auipc	ra,0x1
    3f88:	5a6080e7          	jalr	1446(ra) # 552a <pipe>
    3f8c:	e901                	bnez	a0,3f9c <sbrkfail+0x30>
    3f8e:	f8040493          	addi	s1,s0,-128
    3f92:	fa840993          	addi	s3,s0,-88
    3f96:	8926                	mv	s2,s1
    if(pids[i] != -1)
    3f98:	5a7d                	li	s4,-1
    3f9a:	a085                	j	3ffa <sbrkfail+0x8e>
    printf("%s: pipe() failed\n", s);
    3f9c:	85d6                	mv	a1,s5
    3f9e:	00002517          	auipc	a0,0x2
    3fa2:	7f250513          	addi	a0,a0,2034 # 6790 <malloc+0xe3e>
    3fa6:	00002097          	auipc	ra,0x2
    3faa:	8ec080e7          	jalr	-1812(ra) # 5892 <printf>
    exit(1);
    3fae:	4505                	li	a0,1
    3fb0:	00001097          	auipc	ra,0x1
    3fb4:	56a080e7          	jalr	1386(ra) # 551a <exit>
      sbrk(BIG - (uint64)sbrk(0));
    3fb8:	00001097          	auipc	ra,0x1
    3fbc:	5ea080e7          	jalr	1514(ra) # 55a2 <sbrk>
    3fc0:	064007b7          	lui	a5,0x6400
    3fc4:	40a7853b          	subw	a0,a5,a0
    3fc8:	00001097          	auipc	ra,0x1
    3fcc:	5da080e7          	jalr	1498(ra) # 55a2 <sbrk>
      write(fds[1], "x", 1);
    3fd0:	4605                	li	a2,1
    3fd2:	00002597          	auipc	a1,0x2
    3fd6:	ece58593          	addi	a1,a1,-306 # 5ea0 <malloc+0x54e>
    3fda:	fb442503          	lw	a0,-76(s0)
    3fde:	00001097          	auipc	ra,0x1
    3fe2:	55c080e7          	jalr	1372(ra) # 553a <write>
      for(;;) sleep(1000);
    3fe6:	3e800513          	li	a0,1000
    3fea:	00001097          	auipc	ra,0x1
    3fee:	5c0080e7          	jalr	1472(ra) # 55aa <sleep>
    3ff2:	bfd5                	j	3fe6 <sbrkfail+0x7a>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    3ff4:	0911                	addi	s2,s2,4
    3ff6:	03390563          	beq	s2,s3,4020 <sbrkfail+0xb4>
    if((pids[i] = fork()) == 0){
    3ffa:	00001097          	auipc	ra,0x1
    3ffe:	518080e7          	jalr	1304(ra) # 5512 <fork>
    4002:	00a92023          	sw	a0,0(s2)
    4006:	d94d                	beqz	a0,3fb8 <sbrkfail+0x4c>
    if(pids[i] != -1)
    4008:	ff4506e3          	beq	a0,s4,3ff4 <sbrkfail+0x88>
      read(fds[0], &scratch, 1);
    400c:	4605                	li	a2,1
    400e:	faf40593          	addi	a1,s0,-81
    4012:	fb042503          	lw	a0,-80(s0)
    4016:	00001097          	auipc	ra,0x1
    401a:	51c080e7          	jalr	1308(ra) # 5532 <read>
    401e:	bfd9                	j	3ff4 <sbrkfail+0x88>
  c = sbrk(PGSIZE);
    4020:	6505                	lui	a0,0x1
    4022:	00001097          	auipc	ra,0x1
    4026:	580080e7          	jalr	1408(ra) # 55a2 <sbrk>
    402a:	892a                	mv	s2,a0
    if(pids[i] == -1)
    402c:	5a7d                	li	s4,-1
    402e:	a021                	j	4036 <sbrkfail+0xca>
  for(i = 0; i < sizeof(pids)/sizeof(pids[0]); i++){
    4030:	0491                	addi	s1,s1,4
    4032:	01348f63          	beq	s1,s3,4050 <sbrkfail+0xe4>
    if(pids[i] == -1)
    4036:	4088                	lw	a0,0(s1)
    4038:	ff450ce3          	beq	a0,s4,4030 <sbrkfail+0xc4>
    kill(pids[i]);
    403c:	00001097          	auipc	ra,0x1
    4040:	50e080e7          	jalr	1294(ra) # 554a <kill>
    wait(0);
    4044:	4501                	li	a0,0
    4046:	00001097          	auipc	ra,0x1
    404a:	4dc080e7          	jalr	1244(ra) # 5522 <wait>
    404e:	b7cd                	j	4030 <sbrkfail+0xc4>
  if(c == (char*)0xffffffffffffffffL){
    4050:	57fd                	li	a5,-1
    4052:	04f90163          	beq	s2,a5,4094 <sbrkfail+0x128>
  pid = fork();
    4056:	00001097          	auipc	ra,0x1
    405a:	4bc080e7          	jalr	1212(ra) # 5512 <fork>
    405e:	84aa                	mv	s1,a0
  if(pid < 0){
    4060:	04054863          	bltz	a0,40b0 <sbrkfail+0x144>
  if(pid == 0){
    4064:	c525                	beqz	a0,40cc <sbrkfail+0x160>
  wait(&xstatus);
    4066:	fbc40513          	addi	a0,s0,-68
    406a:	00001097          	auipc	ra,0x1
    406e:	4b8080e7          	jalr	1208(ra) # 5522 <wait>
  if(xstatus != -1 && xstatus != 2)
    4072:	fbc42783          	lw	a5,-68(s0)
    4076:	577d                	li	a4,-1
    4078:	00e78563          	beq	a5,a4,4082 <sbrkfail+0x116>
    407c:	4709                	li	a4,2
    407e:	08e79d63          	bne	a5,a4,4118 <sbrkfail+0x1ac>
}
    4082:	70e6                	ld	ra,120(sp)
    4084:	7446                	ld	s0,112(sp)
    4086:	74a6                	ld	s1,104(sp)
    4088:	7906                	ld	s2,96(sp)
    408a:	69e6                	ld	s3,88(sp)
    408c:	6a46                	ld	s4,80(sp)
    408e:	6aa6                	ld	s5,72(sp)
    4090:	6109                	addi	sp,sp,128
    4092:	8082                	ret
    printf("%s: failed sbrk leaked memory\n", s);
    4094:	85d6                	mv	a1,s5
    4096:	00004517          	auipc	a0,0x4
    409a:	8a250513          	addi	a0,a0,-1886 # 7938 <malloc+0x1fe6>
    409e:	00001097          	auipc	ra,0x1
    40a2:	7f4080e7          	jalr	2036(ra) # 5892 <printf>
    exit(1);
    40a6:	4505                	li	a0,1
    40a8:	00001097          	auipc	ra,0x1
    40ac:	472080e7          	jalr	1138(ra) # 551a <exit>
    printf("%s: fork failed\n", s);
    40b0:	85d6                	mv	a1,s5
    40b2:	00002517          	auipc	a0,0x2
    40b6:	5d650513          	addi	a0,a0,1494 # 6688 <malloc+0xd36>
    40ba:	00001097          	auipc	ra,0x1
    40be:	7d8080e7          	jalr	2008(ra) # 5892 <printf>
    exit(1);
    40c2:	4505                	li	a0,1
    40c4:	00001097          	auipc	ra,0x1
    40c8:	456080e7          	jalr	1110(ra) # 551a <exit>
    a = sbrk(0);
    40cc:	4501                	li	a0,0
    40ce:	00001097          	auipc	ra,0x1
    40d2:	4d4080e7          	jalr	1236(ra) # 55a2 <sbrk>
    40d6:	892a                	mv	s2,a0
    sbrk(10*BIG);
    40d8:	3e800537          	lui	a0,0x3e800
    40dc:	00001097          	auipc	ra,0x1
    40e0:	4c6080e7          	jalr	1222(ra) # 55a2 <sbrk>
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    40e4:	874a                	mv	a4,s2
    40e6:	3e8007b7          	lui	a5,0x3e800
    40ea:	97ca                	add	a5,a5,s2
    40ec:	6685                	lui	a3,0x1
      n += *(a+i);
    40ee:	00074603          	lbu	a2,0(a4)
    40f2:	9cb1                	addw	s1,s1,a2
    for (i = 0; i < 10*BIG; i += PGSIZE) {
    40f4:	9736                	add	a4,a4,a3
    40f6:	fee79ce3          	bne	a5,a4,40ee <sbrkfail+0x182>
    printf("%s: allocate a lot of memory succeeded %d\n", s, n);
    40fa:	8626                	mv	a2,s1
    40fc:	85d6                	mv	a1,s5
    40fe:	00004517          	auipc	a0,0x4
    4102:	85a50513          	addi	a0,a0,-1958 # 7958 <malloc+0x2006>
    4106:	00001097          	auipc	ra,0x1
    410a:	78c080e7          	jalr	1932(ra) # 5892 <printf>
    exit(1);
    410e:	4505                	li	a0,1
    4110:	00001097          	auipc	ra,0x1
    4114:	40a080e7          	jalr	1034(ra) # 551a <exit>
    exit(1);
    4118:	4505                	li	a0,1
    411a:	00001097          	auipc	ra,0x1
    411e:	400080e7          	jalr	1024(ra) # 551a <exit>

0000000000004122 <reparent>:
{
    4122:	7179                	addi	sp,sp,-48
    4124:	f406                	sd	ra,40(sp)
    4126:	f022                	sd	s0,32(sp)
    4128:	ec26                	sd	s1,24(sp)
    412a:	e84a                	sd	s2,16(sp)
    412c:	e44e                	sd	s3,8(sp)
    412e:	e052                	sd	s4,0(sp)
    4130:	1800                	addi	s0,sp,48
    4132:	89aa                	mv	s3,a0
  int master_pid = getpid();
    4134:	00001097          	auipc	ra,0x1
    4138:	466080e7          	jalr	1126(ra) # 559a <getpid>
    413c:	8a2a                	mv	s4,a0
    413e:	0c800913          	li	s2,200
    int pid = fork();
    4142:	00001097          	auipc	ra,0x1
    4146:	3d0080e7          	jalr	976(ra) # 5512 <fork>
    414a:	84aa                	mv	s1,a0
    if(pid < 0){
    414c:	02054263          	bltz	a0,4170 <reparent+0x4e>
    if(pid){
    4150:	cd21                	beqz	a0,41a8 <reparent+0x86>
      if(wait(0) != pid){
    4152:	4501                	li	a0,0
    4154:	00001097          	auipc	ra,0x1
    4158:	3ce080e7          	jalr	974(ra) # 5522 <wait>
    415c:	02951863          	bne	a0,s1,418c <reparent+0x6a>
  for(int i = 0; i < 200; i++){
    4160:	397d                	addiw	s2,s2,-1
    4162:	fe0910e3          	bnez	s2,4142 <reparent+0x20>
  exit(0);
    4166:	4501                	li	a0,0
    4168:	00001097          	auipc	ra,0x1
    416c:	3b2080e7          	jalr	946(ra) # 551a <exit>
      printf("%s: fork failed\n", s);
    4170:	85ce                	mv	a1,s3
    4172:	00002517          	auipc	a0,0x2
    4176:	51650513          	addi	a0,a0,1302 # 6688 <malloc+0xd36>
    417a:	00001097          	auipc	ra,0x1
    417e:	718080e7          	jalr	1816(ra) # 5892 <printf>
      exit(1);
    4182:	4505                	li	a0,1
    4184:	00001097          	auipc	ra,0x1
    4188:	396080e7          	jalr	918(ra) # 551a <exit>
        printf("%s: wait wrong pid\n", s);
    418c:	85ce                	mv	a1,s3
    418e:	00002517          	auipc	a0,0x2
    4192:	68250513          	addi	a0,a0,1666 # 6810 <malloc+0xebe>
    4196:	00001097          	auipc	ra,0x1
    419a:	6fc080e7          	jalr	1788(ra) # 5892 <printf>
        exit(1);
    419e:	4505                	li	a0,1
    41a0:	00001097          	auipc	ra,0x1
    41a4:	37a080e7          	jalr	890(ra) # 551a <exit>
      int pid2 = fork();
    41a8:	00001097          	auipc	ra,0x1
    41ac:	36a080e7          	jalr	874(ra) # 5512 <fork>
      if(pid2 < 0){
    41b0:	00054763          	bltz	a0,41be <reparent+0x9c>
      exit(0);
    41b4:	4501                	li	a0,0
    41b6:	00001097          	auipc	ra,0x1
    41ba:	364080e7          	jalr	868(ra) # 551a <exit>
        kill(master_pid);
    41be:	8552                	mv	a0,s4
    41c0:	00001097          	auipc	ra,0x1
    41c4:	38a080e7          	jalr	906(ra) # 554a <kill>
        exit(1);
    41c8:	4505                	li	a0,1
    41ca:	00001097          	auipc	ra,0x1
    41ce:	350080e7          	jalr	848(ra) # 551a <exit>

00000000000041d2 <mem>:
{
    41d2:	7139                	addi	sp,sp,-64
    41d4:	fc06                	sd	ra,56(sp)
    41d6:	f822                	sd	s0,48(sp)
    41d8:	f426                	sd	s1,40(sp)
    41da:	f04a                	sd	s2,32(sp)
    41dc:	ec4e                	sd	s3,24(sp)
    41de:	0080                	addi	s0,sp,64
    41e0:	89aa                	mv	s3,a0
  if((pid = fork()) == 0){
    41e2:	00001097          	auipc	ra,0x1
    41e6:	330080e7          	jalr	816(ra) # 5512 <fork>
    m1 = 0;
    41ea:	4481                	li	s1,0
    while((m2 = malloc(10001)) != 0){
    41ec:	6909                	lui	s2,0x2
    41ee:	71190913          	addi	s2,s2,1809 # 2711 <sbrkmuch+0xdf>
  if((pid = fork()) == 0){
    41f2:	e135                	bnez	a0,4256 <mem+0x84>
    while((m2 = malloc(10001)) != 0){
    41f4:	854a                	mv	a0,s2
    41f6:	00001097          	auipc	ra,0x1
    41fa:	75c080e7          	jalr	1884(ra) # 5952 <malloc>
    41fe:	c501                	beqz	a0,4206 <mem+0x34>
      *(char**)m2 = m1;
    4200:	e104                	sd	s1,0(a0)
      m1 = m2;
    4202:	84aa                	mv	s1,a0
    4204:	bfc5                	j	41f4 <mem+0x22>
    while(m1){
    4206:	c899                	beqz	s1,421c <mem+0x4a>
      m2 = *(char**)m1;
    4208:	0004b903          	ld	s2,0(s1)
      free(m1);
    420c:	8526                	mv	a0,s1
    420e:	00001097          	auipc	ra,0x1
    4212:	6ba080e7          	jalr	1722(ra) # 58c8 <free>
      m1 = m2;
    4216:	84ca                	mv	s1,s2
    while(m1){
    4218:	fe0918e3          	bnez	s2,4208 <mem+0x36>
    m1 = malloc(1024*20);
    421c:	6515                	lui	a0,0x5
    421e:	00001097          	auipc	ra,0x1
    4222:	734080e7          	jalr	1844(ra) # 5952 <malloc>
    if(m1 == 0){
    4226:	c911                	beqz	a0,423a <mem+0x68>
    free(m1);
    4228:	00001097          	auipc	ra,0x1
    422c:	6a0080e7          	jalr	1696(ra) # 58c8 <free>
    exit(0);
    4230:	4501                	li	a0,0
    4232:	00001097          	auipc	ra,0x1
    4236:	2e8080e7          	jalr	744(ra) # 551a <exit>
      printf("couldn't allocate mem?!!\n", s);
    423a:	85ce                	mv	a1,s3
    423c:	00003517          	auipc	a0,0x3
    4240:	74c50513          	addi	a0,a0,1868 # 7988 <malloc+0x2036>
    4244:	00001097          	auipc	ra,0x1
    4248:	64e080e7          	jalr	1614(ra) # 5892 <printf>
      exit(1);
    424c:	4505                	li	a0,1
    424e:	00001097          	auipc	ra,0x1
    4252:	2cc080e7          	jalr	716(ra) # 551a <exit>
    wait(&xstatus);
    4256:	fcc40513          	addi	a0,s0,-52
    425a:	00001097          	auipc	ra,0x1
    425e:	2c8080e7          	jalr	712(ra) # 5522 <wait>
    if(xstatus == -1){
    4262:	fcc42503          	lw	a0,-52(s0)
    4266:	57fd                	li	a5,-1
    4268:	00f50663          	beq	a0,a5,4274 <mem+0xa2>
    exit(xstatus);
    426c:	00001097          	auipc	ra,0x1
    4270:	2ae080e7          	jalr	686(ra) # 551a <exit>
      exit(0);
    4274:	4501                	li	a0,0
    4276:	00001097          	auipc	ra,0x1
    427a:	2a4080e7          	jalr	676(ra) # 551a <exit>

000000000000427e <sharedfd>:
{
    427e:	7159                	addi	sp,sp,-112
    4280:	f486                	sd	ra,104(sp)
    4282:	f0a2                	sd	s0,96(sp)
    4284:	eca6                	sd	s1,88(sp)
    4286:	e8ca                	sd	s2,80(sp)
    4288:	e4ce                	sd	s3,72(sp)
    428a:	e0d2                	sd	s4,64(sp)
    428c:	fc56                	sd	s5,56(sp)
    428e:	f85a                	sd	s6,48(sp)
    4290:	f45e                	sd	s7,40(sp)
    4292:	1880                	addi	s0,sp,112
    4294:	89aa                	mv	s3,a0
  unlink("sharedfd");
    4296:	00003517          	auipc	a0,0x3
    429a:	71250513          	addi	a0,a0,1810 # 79a8 <malloc+0x2056>
    429e:	00001097          	auipc	ra,0x1
    42a2:	2cc080e7          	jalr	716(ra) # 556a <unlink>
  fd = open("sharedfd", O_CREATE|O_RDWR);
    42a6:	20200593          	li	a1,514
    42aa:	00003517          	auipc	a0,0x3
    42ae:	6fe50513          	addi	a0,a0,1790 # 79a8 <malloc+0x2056>
    42b2:	00001097          	auipc	ra,0x1
    42b6:	2a8080e7          	jalr	680(ra) # 555a <open>
  if(fd < 0){
    42ba:	04054a63          	bltz	a0,430e <sharedfd+0x90>
    42be:	892a                	mv	s2,a0
  pid = fork();
    42c0:	00001097          	auipc	ra,0x1
    42c4:	252080e7          	jalr	594(ra) # 5512 <fork>
    42c8:	8a2a                	mv	s4,a0
  memset(buf, pid==0?'c':'p', sizeof(buf));
    42ca:	06300593          	li	a1,99
    42ce:	c119                	beqz	a0,42d4 <sharedfd+0x56>
    42d0:	07000593          	li	a1,112
    42d4:	4629                	li	a2,10
    42d6:	fa040513          	addi	a0,s0,-96
    42da:	00001097          	auipc	ra,0x1
    42de:	02a080e7          	jalr	42(ra) # 5304 <memset>
    42e2:	3e800493          	li	s1,1000
    if(write(fd, buf, sizeof(buf)) != sizeof(buf)){
    42e6:	4629                	li	a2,10
    42e8:	fa040593          	addi	a1,s0,-96
    42ec:	854a                	mv	a0,s2
    42ee:	00001097          	auipc	ra,0x1
    42f2:	24c080e7          	jalr	588(ra) # 553a <write>
    42f6:	47a9                	li	a5,10
    42f8:	02f51963          	bne	a0,a5,432a <sharedfd+0xac>
  for(i = 0; i < N; i++){
    42fc:	34fd                	addiw	s1,s1,-1
    42fe:	f4e5                	bnez	s1,42e6 <sharedfd+0x68>
  if(pid == 0) {
    4300:	040a1363          	bnez	s4,4346 <sharedfd+0xc8>
    exit(0);
    4304:	4501                	li	a0,0
    4306:	00001097          	auipc	ra,0x1
    430a:	214080e7          	jalr	532(ra) # 551a <exit>
    printf("%s: cannot open sharedfd for writing", s);
    430e:	85ce                	mv	a1,s3
    4310:	00003517          	auipc	a0,0x3
    4314:	6a850513          	addi	a0,a0,1704 # 79b8 <malloc+0x2066>
    4318:	00001097          	auipc	ra,0x1
    431c:	57a080e7          	jalr	1402(ra) # 5892 <printf>
    exit(1);
    4320:	4505                	li	a0,1
    4322:	00001097          	auipc	ra,0x1
    4326:	1f8080e7          	jalr	504(ra) # 551a <exit>
      printf("%s: write sharedfd failed\n", s);
    432a:	85ce                	mv	a1,s3
    432c:	00003517          	auipc	a0,0x3
    4330:	6b450513          	addi	a0,a0,1716 # 79e0 <malloc+0x208e>
    4334:	00001097          	auipc	ra,0x1
    4338:	55e080e7          	jalr	1374(ra) # 5892 <printf>
      exit(1);
    433c:	4505                	li	a0,1
    433e:	00001097          	auipc	ra,0x1
    4342:	1dc080e7          	jalr	476(ra) # 551a <exit>
    wait(&xstatus);
    4346:	f9c40513          	addi	a0,s0,-100
    434a:	00001097          	auipc	ra,0x1
    434e:	1d8080e7          	jalr	472(ra) # 5522 <wait>
    if(xstatus != 0)
    4352:	f9c42a03          	lw	s4,-100(s0)
    4356:	000a0763          	beqz	s4,4364 <sharedfd+0xe6>
      exit(xstatus);
    435a:	8552                	mv	a0,s4
    435c:	00001097          	auipc	ra,0x1
    4360:	1be080e7          	jalr	446(ra) # 551a <exit>
  close(fd);
    4364:	854a                	mv	a0,s2
    4366:	00001097          	auipc	ra,0x1
    436a:	1dc080e7          	jalr	476(ra) # 5542 <close>
  fd = open("sharedfd", 0);
    436e:	4581                	li	a1,0
    4370:	00003517          	auipc	a0,0x3
    4374:	63850513          	addi	a0,a0,1592 # 79a8 <malloc+0x2056>
    4378:	00001097          	auipc	ra,0x1
    437c:	1e2080e7          	jalr	482(ra) # 555a <open>
    4380:	8baa                	mv	s7,a0
  nc = np = 0;
    4382:	8ad2                	mv	s5,s4
  if(fd < 0){
    4384:	02054563          	bltz	a0,43ae <sharedfd+0x130>
    4388:	faa40913          	addi	s2,s0,-86
      if(buf[i] == 'c')
    438c:	06300493          	li	s1,99
      if(buf[i] == 'p')
    4390:	07000b13          	li	s6,112
  while((n = read(fd, buf, sizeof(buf))) > 0){
    4394:	4629                	li	a2,10
    4396:	fa040593          	addi	a1,s0,-96
    439a:	855e                	mv	a0,s7
    439c:	00001097          	auipc	ra,0x1
    43a0:	196080e7          	jalr	406(ra) # 5532 <read>
    43a4:	02a05f63          	blez	a0,43e2 <sharedfd+0x164>
    43a8:	fa040793          	addi	a5,s0,-96
    43ac:	a01d                	j	43d2 <sharedfd+0x154>
    printf("%s: cannot open sharedfd for reading\n", s);
    43ae:	85ce                	mv	a1,s3
    43b0:	00003517          	auipc	a0,0x3
    43b4:	65050513          	addi	a0,a0,1616 # 7a00 <malloc+0x20ae>
    43b8:	00001097          	auipc	ra,0x1
    43bc:	4da080e7          	jalr	1242(ra) # 5892 <printf>
    exit(1);
    43c0:	4505                	li	a0,1
    43c2:	00001097          	auipc	ra,0x1
    43c6:	158080e7          	jalr	344(ra) # 551a <exit>
        nc++;
    43ca:	2a05                	addiw	s4,s4,1
    for(i = 0; i < sizeof(buf); i++){
    43cc:	0785                	addi	a5,a5,1
    43ce:	fd2783e3          	beq	a5,s2,4394 <sharedfd+0x116>
      if(buf[i] == 'c')
    43d2:	0007c703          	lbu	a4,0(a5) # 3e800000 <_end+0x3e7f1678>
    43d6:	fe970ae3          	beq	a4,s1,43ca <sharedfd+0x14c>
      if(buf[i] == 'p')
    43da:	ff6719e3          	bne	a4,s6,43cc <sharedfd+0x14e>
        np++;
    43de:	2a85                	addiw	s5,s5,1
    43e0:	b7f5                	j	43cc <sharedfd+0x14e>
  close(fd);
    43e2:	855e                	mv	a0,s7
    43e4:	00001097          	auipc	ra,0x1
    43e8:	15e080e7          	jalr	350(ra) # 5542 <close>
  unlink("sharedfd");
    43ec:	00003517          	auipc	a0,0x3
    43f0:	5bc50513          	addi	a0,a0,1468 # 79a8 <malloc+0x2056>
    43f4:	00001097          	auipc	ra,0x1
    43f8:	176080e7          	jalr	374(ra) # 556a <unlink>
  if(nc == N*SZ && np == N*SZ){
    43fc:	6789                	lui	a5,0x2
    43fe:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0xde>
    4402:	00fa1763          	bne	s4,a5,4410 <sharedfd+0x192>
    4406:	6789                	lui	a5,0x2
    4408:	71078793          	addi	a5,a5,1808 # 2710 <sbrkmuch+0xde>
    440c:	02fa8063          	beq	s5,a5,442c <sharedfd+0x1ae>
    printf("%s: nc/np test fails\n", s);
    4410:	85ce                	mv	a1,s3
    4412:	00003517          	auipc	a0,0x3
    4416:	61650513          	addi	a0,a0,1558 # 7a28 <malloc+0x20d6>
    441a:	00001097          	auipc	ra,0x1
    441e:	478080e7          	jalr	1144(ra) # 5892 <printf>
    exit(1);
    4422:	4505                	li	a0,1
    4424:	00001097          	auipc	ra,0x1
    4428:	0f6080e7          	jalr	246(ra) # 551a <exit>
    exit(0);
    442c:	4501                	li	a0,0
    442e:	00001097          	auipc	ra,0x1
    4432:	0ec080e7          	jalr	236(ra) # 551a <exit>

0000000000004436 <fourfiles>:
{
    4436:	7135                	addi	sp,sp,-160
    4438:	ed06                	sd	ra,152(sp)
    443a:	e922                	sd	s0,144(sp)
    443c:	e526                	sd	s1,136(sp)
    443e:	e14a                	sd	s2,128(sp)
    4440:	fcce                	sd	s3,120(sp)
    4442:	f8d2                	sd	s4,112(sp)
    4444:	f4d6                	sd	s5,104(sp)
    4446:	f0da                	sd	s6,96(sp)
    4448:	ecde                	sd	s7,88(sp)
    444a:	e8e2                	sd	s8,80(sp)
    444c:	e4e6                	sd	s9,72(sp)
    444e:	e0ea                	sd	s10,64(sp)
    4450:	fc6e                	sd	s11,56(sp)
    4452:	1100                	addi	s0,sp,160
    4454:	8d2a                	mv	s10,a0
  char *names[] = { "f0", "f1", "f2", "f3" };
    4456:	00003797          	auipc	a5,0x3
    445a:	5ea78793          	addi	a5,a5,1514 # 7a40 <malloc+0x20ee>
    445e:	f6f43823          	sd	a5,-144(s0)
    4462:	00003797          	auipc	a5,0x3
    4466:	5e678793          	addi	a5,a5,1510 # 7a48 <malloc+0x20f6>
    446a:	f6f43c23          	sd	a5,-136(s0)
    446e:	00003797          	auipc	a5,0x3
    4472:	5e278793          	addi	a5,a5,1506 # 7a50 <malloc+0x20fe>
    4476:	f8f43023          	sd	a5,-128(s0)
    447a:	00003797          	auipc	a5,0x3
    447e:	5de78793          	addi	a5,a5,1502 # 7a58 <malloc+0x2106>
    4482:	f8f43423          	sd	a5,-120(s0)
  for(pi = 0; pi < NCHILD; pi++){
    4486:	f7040b13          	addi	s6,s0,-144
  char *names[] = { "f0", "f1", "f2", "f3" };
    448a:	895a                	mv	s2,s6
  for(pi = 0; pi < NCHILD; pi++){
    448c:	4481                	li	s1,0
    448e:	4a11                	li	s4,4
    fname = names[pi];
    4490:	00093983          	ld	s3,0(s2)
    unlink(fname);
    4494:	854e                	mv	a0,s3
    4496:	00001097          	auipc	ra,0x1
    449a:	0d4080e7          	jalr	212(ra) # 556a <unlink>
    pid = fork();
    449e:	00001097          	auipc	ra,0x1
    44a2:	074080e7          	jalr	116(ra) # 5512 <fork>
    if(pid < 0){
    44a6:	04054063          	bltz	a0,44e6 <fourfiles+0xb0>
    if(pid == 0){
    44aa:	cd21                	beqz	a0,4502 <fourfiles+0xcc>
  for(pi = 0; pi < NCHILD; pi++){
    44ac:	2485                	addiw	s1,s1,1
    44ae:	0921                	addi	s2,s2,8
    44b0:	ff4490e3          	bne	s1,s4,4490 <fourfiles+0x5a>
    44b4:	4491                	li	s1,4
    wait(&xstatus);
    44b6:	f6c40513          	addi	a0,s0,-148
    44ba:	00001097          	auipc	ra,0x1
    44be:	068080e7          	jalr	104(ra) # 5522 <wait>
    if(xstatus != 0)
    44c2:	f6c42503          	lw	a0,-148(s0)
    44c6:	e961                	bnez	a0,4596 <fourfiles+0x160>
  for(pi = 0; pi < NCHILD; pi++){
    44c8:	34fd                	addiw	s1,s1,-1
    44ca:	f4f5                	bnez	s1,44b6 <fourfiles+0x80>
    44cc:	03000a93          	li	s5,48
    total = 0;
    44d0:	8daa                	mv	s11,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    44d2:	00007997          	auipc	s3,0x7
    44d6:	4a698993          	addi	s3,s3,1190 # b978 <buf>
    if(total != N*SZ){
    44da:	6c05                	lui	s8,0x1
    44dc:	770c0c13          	addi	s8,s8,1904 # 1770 <pipe1+0xa>
  for(i = 0; i < NCHILD; i++){
    44e0:	03400c93          	li	s9,52
    44e4:	aa15                	j	4618 <fourfiles+0x1e2>
      printf("fork failed\n", s);
    44e6:	85ea                	mv	a1,s10
    44e8:	00002517          	auipc	a0,0x2
    44ec:	59050513          	addi	a0,a0,1424 # 6a78 <malloc+0x1126>
    44f0:	00001097          	auipc	ra,0x1
    44f4:	3a2080e7          	jalr	930(ra) # 5892 <printf>
      exit(1);
    44f8:	4505                	li	a0,1
    44fa:	00001097          	auipc	ra,0x1
    44fe:	020080e7          	jalr	32(ra) # 551a <exit>
      fd = open(fname, O_CREATE | O_RDWR);
    4502:	20200593          	li	a1,514
    4506:	854e                	mv	a0,s3
    4508:	00001097          	auipc	ra,0x1
    450c:	052080e7          	jalr	82(ra) # 555a <open>
    4510:	892a                	mv	s2,a0
      if(fd < 0){
    4512:	04054663          	bltz	a0,455e <fourfiles+0x128>
      memset(buf, '0'+pi, SZ);
    4516:	1f400613          	li	a2,500
    451a:	0304859b          	addiw	a1,s1,48
    451e:	00007517          	auipc	a0,0x7
    4522:	45a50513          	addi	a0,a0,1114 # b978 <buf>
    4526:	00001097          	auipc	ra,0x1
    452a:	dde080e7          	jalr	-546(ra) # 5304 <memset>
    452e:	44b1                	li	s1,12
        if((n = write(fd, buf, SZ)) != SZ){
    4530:	00007997          	auipc	s3,0x7
    4534:	44898993          	addi	s3,s3,1096 # b978 <buf>
    4538:	1f400613          	li	a2,500
    453c:	85ce                	mv	a1,s3
    453e:	854a                	mv	a0,s2
    4540:	00001097          	auipc	ra,0x1
    4544:	ffa080e7          	jalr	-6(ra) # 553a <write>
    4548:	1f400793          	li	a5,500
    454c:	02f51763          	bne	a0,a5,457a <fourfiles+0x144>
      for(i = 0; i < N; i++){
    4550:	34fd                	addiw	s1,s1,-1
    4552:	f0fd                	bnez	s1,4538 <fourfiles+0x102>
      exit(0);
    4554:	4501                	li	a0,0
    4556:	00001097          	auipc	ra,0x1
    455a:	fc4080e7          	jalr	-60(ra) # 551a <exit>
        printf("create failed\n", s);
    455e:	85ea                	mv	a1,s10
    4560:	00003517          	auipc	a0,0x3
    4564:	50050513          	addi	a0,a0,1280 # 7a60 <malloc+0x210e>
    4568:	00001097          	auipc	ra,0x1
    456c:	32a080e7          	jalr	810(ra) # 5892 <printf>
        exit(1);
    4570:	4505                	li	a0,1
    4572:	00001097          	auipc	ra,0x1
    4576:	fa8080e7          	jalr	-88(ra) # 551a <exit>
          printf("write failed %d\n", n);
    457a:	85aa                	mv	a1,a0
    457c:	00003517          	auipc	a0,0x3
    4580:	4f450513          	addi	a0,a0,1268 # 7a70 <malloc+0x211e>
    4584:	00001097          	auipc	ra,0x1
    4588:	30e080e7          	jalr	782(ra) # 5892 <printf>
          exit(1);
    458c:	4505                	li	a0,1
    458e:	00001097          	auipc	ra,0x1
    4592:	f8c080e7          	jalr	-116(ra) # 551a <exit>
      exit(xstatus);
    4596:	00001097          	auipc	ra,0x1
    459a:	f84080e7          	jalr	-124(ra) # 551a <exit>
      total += n;
    459e:	00a9093b          	addw	s2,s2,a0
    while((n = read(fd, buf, sizeof(buf))) > 0){
    45a2:	660d                	lui	a2,0x3
    45a4:	85ce                	mv	a1,s3
    45a6:	8552                	mv	a0,s4
    45a8:	00001097          	auipc	ra,0x1
    45ac:	f8a080e7          	jalr	-118(ra) # 5532 <read>
    45b0:	04a05463          	blez	a0,45f8 <fourfiles+0x1c2>
        if(buf[j] != '0'+i){
    45b4:	0009c783          	lbu	a5,0(s3)
    45b8:	02979263          	bne	a5,s1,45dc <fourfiles+0x1a6>
    45bc:	00007797          	auipc	a5,0x7
    45c0:	3bd78793          	addi	a5,a5,957 # b979 <buf+0x1>
    45c4:	fff5069b          	addiw	a3,a0,-1
    45c8:	1682                	slli	a3,a3,0x20
    45ca:	9281                	srli	a3,a3,0x20
    45cc:	96be                	add	a3,a3,a5
      for(j = 0; j < n; j++){
    45ce:	fcd788e3          	beq	a5,a3,459e <fourfiles+0x168>
        if(buf[j] != '0'+i){
    45d2:	0007c703          	lbu	a4,0(a5)
    45d6:	0785                	addi	a5,a5,1
    45d8:	fe970be3          	beq	a4,s1,45ce <fourfiles+0x198>
          printf("wrong char\n", s);
    45dc:	85ea                	mv	a1,s10
    45de:	00003517          	auipc	a0,0x3
    45e2:	4aa50513          	addi	a0,a0,1194 # 7a88 <malloc+0x2136>
    45e6:	00001097          	auipc	ra,0x1
    45ea:	2ac080e7          	jalr	684(ra) # 5892 <printf>
          exit(1);
    45ee:	4505                	li	a0,1
    45f0:	00001097          	auipc	ra,0x1
    45f4:	f2a080e7          	jalr	-214(ra) # 551a <exit>
    close(fd);
    45f8:	8552                	mv	a0,s4
    45fa:	00001097          	auipc	ra,0x1
    45fe:	f48080e7          	jalr	-184(ra) # 5542 <close>
    if(total != N*SZ){
    4602:	03891863          	bne	s2,s8,4632 <fourfiles+0x1fc>
    unlink(fname);
    4606:	855e                	mv	a0,s7
    4608:	00001097          	auipc	ra,0x1
    460c:	f62080e7          	jalr	-158(ra) # 556a <unlink>
  for(i = 0; i < NCHILD; i++){
    4610:	0b21                	addi	s6,s6,8
    4612:	2a85                	addiw	s5,s5,1
    4614:	039a8d63          	beq	s5,s9,464e <fourfiles+0x218>
    fname = names[i];
    4618:	000b3b83          	ld	s7,0(s6) # 3000 <subdir+0xb4>
    fd = open(fname, 0);
    461c:	4581                	li	a1,0
    461e:	855e                	mv	a0,s7
    4620:	00001097          	auipc	ra,0x1
    4624:	f3a080e7          	jalr	-198(ra) # 555a <open>
    4628:	8a2a                	mv	s4,a0
    total = 0;
    462a:	896e                	mv	s2,s11
    462c:	000a849b          	sext.w	s1,s5
    while((n = read(fd, buf, sizeof(buf))) > 0){
    4630:	bf8d                	j	45a2 <fourfiles+0x16c>
      printf("wrong length %d\n", total);
    4632:	85ca                	mv	a1,s2
    4634:	00003517          	auipc	a0,0x3
    4638:	46450513          	addi	a0,a0,1124 # 7a98 <malloc+0x2146>
    463c:	00001097          	auipc	ra,0x1
    4640:	256080e7          	jalr	598(ra) # 5892 <printf>
      exit(1);
    4644:	4505                	li	a0,1
    4646:	00001097          	auipc	ra,0x1
    464a:	ed4080e7          	jalr	-300(ra) # 551a <exit>
}
    464e:	60ea                	ld	ra,152(sp)
    4650:	644a                	ld	s0,144(sp)
    4652:	64aa                	ld	s1,136(sp)
    4654:	690a                	ld	s2,128(sp)
    4656:	79e6                	ld	s3,120(sp)
    4658:	7a46                	ld	s4,112(sp)
    465a:	7aa6                	ld	s5,104(sp)
    465c:	7b06                	ld	s6,96(sp)
    465e:	6be6                	ld	s7,88(sp)
    4660:	6c46                	ld	s8,80(sp)
    4662:	6ca6                	ld	s9,72(sp)
    4664:	6d06                	ld	s10,64(sp)
    4666:	7de2                	ld	s11,56(sp)
    4668:	610d                	addi	sp,sp,160
    466a:	8082                	ret

000000000000466c <concreate>:
{
    466c:	7135                	addi	sp,sp,-160
    466e:	ed06                	sd	ra,152(sp)
    4670:	e922                	sd	s0,144(sp)
    4672:	e526                	sd	s1,136(sp)
    4674:	e14a                	sd	s2,128(sp)
    4676:	fcce                	sd	s3,120(sp)
    4678:	f8d2                	sd	s4,112(sp)
    467a:	f4d6                	sd	s5,104(sp)
    467c:	f0da                	sd	s6,96(sp)
    467e:	ecde                	sd	s7,88(sp)
    4680:	1100                	addi	s0,sp,160
    4682:	89aa                	mv	s3,a0
  file[0] = 'C';
    4684:	04300793          	li	a5,67
    4688:	faf40423          	sb	a5,-88(s0)
  file[2] = '\0';
    468c:	fa040523          	sb	zero,-86(s0)
  for(i = 0; i < N; i++){
    4690:	4901                	li	s2,0
    if(pid && (i % 3) == 1){
    4692:	4b0d                	li	s6,3
    4694:	4a85                	li	s5,1
      link("C0", file);
    4696:	00003b97          	auipc	s7,0x3
    469a:	41ab8b93          	addi	s7,s7,1050 # 7ab0 <malloc+0x215e>
  for(i = 0; i < N; i++){
    469e:	02800a13          	li	s4,40
    46a2:	acc1                	j	4972 <concreate+0x306>
      link("C0", file);
    46a4:	fa840593          	addi	a1,s0,-88
    46a8:	855e                	mv	a0,s7
    46aa:	00001097          	auipc	ra,0x1
    46ae:	ed0080e7          	jalr	-304(ra) # 557a <link>
    if(pid == 0) {
    46b2:	a45d                	j	4958 <concreate+0x2ec>
    } else if(pid == 0 && (i % 5) == 1){
    46b4:	4795                	li	a5,5
    46b6:	02f9693b          	remw	s2,s2,a5
    46ba:	4785                	li	a5,1
    46bc:	02f90b63          	beq	s2,a5,46f2 <concreate+0x86>
      fd = open(file, O_CREATE | O_RDWR);
    46c0:	20200593          	li	a1,514
    46c4:	fa840513          	addi	a0,s0,-88
    46c8:	00001097          	auipc	ra,0x1
    46cc:	e92080e7          	jalr	-366(ra) # 555a <open>
      if(fd < 0){
    46d0:	26055b63          	bgez	a0,4946 <concreate+0x2da>
        printf("concreate create %s failed\n", file);
    46d4:	fa840593          	addi	a1,s0,-88
    46d8:	00003517          	auipc	a0,0x3
    46dc:	3e050513          	addi	a0,a0,992 # 7ab8 <malloc+0x2166>
    46e0:	00001097          	auipc	ra,0x1
    46e4:	1b2080e7          	jalr	434(ra) # 5892 <printf>
        exit(1);
    46e8:	4505                	li	a0,1
    46ea:	00001097          	auipc	ra,0x1
    46ee:	e30080e7          	jalr	-464(ra) # 551a <exit>
      link("C0", file);
    46f2:	fa840593          	addi	a1,s0,-88
    46f6:	00003517          	auipc	a0,0x3
    46fa:	3ba50513          	addi	a0,a0,954 # 7ab0 <malloc+0x215e>
    46fe:	00001097          	auipc	ra,0x1
    4702:	e7c080e7          	jalr	-388(ra) # 557a <link>
      exit(0);
    4706:	4501                	li	a0,0
    4708:	00001097          	auipc	ra,0x1
    470c:	e12080e7          	jalr	-494(ra) # 551a <exit>
        exit(1);
    4710:	4505                	li	a0,1
    4712:	00001097          	auipc	ra,0x1
    4716:	e08080e7          	jalr	-504(ra) # 551a <exit>
  memset(fa, 0, sizeof(fa));
    471a:	02800613          	li	a2,40
    471e:	4581                	li	a1,0
    4720:	f8040513          	addi	a0,s0,-128
    4724:	00001097          	auipc	ra,0x1
    4728:	be0080e7          	jalr	-1056(ra) # 5304 <memset>
  fd = open(".", 0);
    472c:	4581                	li	a1,0
    472e:	00002517          	auipc	a0,0x2
    4732:	dba50513          	addi	a0,a0,-582 # 64e8 <malloc+0xb96>
    4736:	00001097          	auipc	ra,0x1
    473a:	e24080e7          	jalr	-476(ra) # 555a <open>
    473e:	892a                	mv	s2,a0
  n = 0;
    4740:	8aa6                	mv	s5,s1
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4742:	04300a13          	li	s4,67
      if(i < 0 || i >= sizeof(fa)){
    4746:	02700b13          	li	s6,39
      fa[i] = 1;
    474a:	4b85                	li	s7,1
  while(read(fd, &de, sizeof(de)) > 0){
    474c:	4641                	li	a2,16
    474e:	f7040593          	addi	a1,s0,-144
    4752:	854a                	mv	a0,s2
    4754:	00001097          	auipc	ra,0x1
    4758:	dde080e7          	jalr	-546(ra) # 5532 <read>
    475c:	08a05163          	blez	a0,47de <concreate+0x172>
    if(de.inum == 0)
    4760:	f7045783          	lhu	a5,-144(s0)
    4764:	d7e5                	beqz	a5,474c <concreate+0xe0>
    if(de.name[0] == 'C' && de.name[2] == '\0'){
    4766:	f7244783          	lbu	a5,-142(s0)
    476a:	ff4791e3          	bne	a5,s4,474c <concreate+0xe0>
    476e:	f7444783          	lbu	a5,-140(s0)
    4772:	ffe9                	bnez	a5,474c <concreate+0xe0>
      i = de.name[1] - '0';
    4774:	f7344783          	lbu	a5,-141(s0)
    4778:	fd07879b          	addiw	a5,a5,-48
    477c:	0007871b          	sext.w	a4,a5
      if(i < 0 || i >= sizeof(fa)){
    4780:	00eb6f63          	bltu	s6,a4,479e <concreate+0x132>
      if(fa[i]){
    4784:	fb040793          	addi	a5,s0,-80
    4788:	97ba                	add	a5,a5,a4
    478a:	fd07c783          	lbu	a5,-48(a5)
    478e:	eb85                	bnez	a5,47be <concreate+0x152>
      fa[i] = 1;
    4790:	fb040793          	addi	a5,s0,-80
    4794:	973e                	add	a4,a4,a5
    4796:	fd770823          	sb	s7,-48(a4)
      n++;
    479a:	2a85                	addiw	s5,s5,1
    479c:	bf45                	j	474c <concreate+0xe0>
        printf("%s: concreate weird file %s\n", s, de.name);
    479e:	f7240613          	addi	a2,s0,-142
    47a2:	85ce                	mv	a1,s3
    47a4:	00003517          	auipc	a0,0x3
    47a8:	33450513          	addi	a0,a0,820 # 7ad8 <malloc+0x2186>
    47ac:	00001097          	auipc	ra,0x1
    47b0:	0e6080e7          	jalr	230(ra) # 5892 <printf>
        exit(1);
    47b4:	4505                	li	a0,1
    47b6:	00001097          	auipc	ra,0x1
    47ba:	d64080e7          	jalr	-668(ra) # 551a <exit>
        printf("%s: concreate duplicate file %s\n", s, de.name);
    47be:	f7240613          	addi	a2,s0,-142
    47c2:	85ce                	mv	a1,s3
    47c4:	00003517          	auipc	a0,0x3
    47c8:	33450513          	addi	a0,a0,820 # 7af8 <malloc+0x21a6>
    47cc:	00001097          	auipc	ra,0x1
    47d0:	0c6080e7          	jalr	198(ra) # 5892 <printf>
        exit(1);
    47d4:	4505                	li	a0,1
    47d6:	00001097          	auipc	ra,0x1
    47da:	d44080e7          	jalr	-700(ra) # 551a <exit>
  close(fd);
    47de:	854a                	mv	a0,s2
    47e0:	00001097          	auipc	ra,0x1
    47e4:	d62080e7          	jalr	-670(ra) # 5542 <close>
  if(n != N){
    47e8:	02800793          	li	a5,40
    47ec:	00fa9763          	bne	s5,a5,47fa <concreate+0x18e>
    if(((i % 3) == 0 && pid == 0) ||
    47f0:	4a8d                	li	s5,3
    47f2:	4b05                	li	s6,1
  for(i = 0; i < N; i++){
    47f4:	02800a13          	li	s4,40
    47f8:	a8c9                	j	48ca <concreate+0x25e>
    printf("%s: concreate not enough files in directory listing\n", s);
    47fa:	85ce                	mv	a1,s3
    47fc:	00003517          	auipc	a0,0x3
    4800:	32450513          	addi	a0,a0,804 # 7b20 <malloc+0x21ce>
    4804:	00001097          	auipc	ra,0x1
    4808:	08e080e7          	jalr	142(ra) # 5892 <printf>
    exit(1);
    480c:	4505                	li	a0,1
    480e:	00001097          	auipc	ra,0x1
    4812:	d0c080e7          	jalr	-756(ra) # 551a <exit>
      printf("%s: fork failed\n", s);
    4816:	85ce                	mv	a1,s3
    4818:	00002517          	auipc	a0,0x2
    481c:	e7050513          	addi	a0,a0,-400 # 6688 <malloc+0xd36>
    4820:	00001097          	auipc	ra,0x1
    4824:	072080e7          	jalr	114(ra) # 5892 <printf>
      exit(1);
    4828:	4505                	li	a0,1
    482a:	00001097          	auipc	ra,0x1
    482e:	cf0080e7          	jalr	-784(ra) # 551a <exit>
      close(open(file, 0));
    4832:	4581                	li	a1,0
    4834:	fa840513          	addi	a0,s0,-88
    4838:	00001097          	auipc	ra,0x1
    483c:	d22080e7          	jalr	-734(ra) # 555a <open>
    4840:	00001097          	auipc	ra,0x1
    4844:	d02080e7          	jalr	-766(ra) # 5542 <close>
      close(open(file, 0));
    4848:	4581                	li	a1,0
    484a:	fa840513          	addi	a0,s0,-88
    484e:	00001097          	auipc	ra,0x1
    4852:	d0c080e7          	jalr	-756(ra) # 555a <open>
    4856:	00001097          	auipc	ra,0x1
    485a:	cec080e7          	jalr	-788(ra) # 5542 <close>
      close(open(file, 0));
    485e:	4581                	li	a1,0
    4860:	fa840513          	addi	a0,s0,-88
    4864:	00001097          	auipc	ra,0x1
    4868:	cf6080e7          	jalr	-778(ra) # 555a <open>
    486c:	00001097          	auipc	ra,0x1
    4870:	cd6080e7          	jalr	-810(ra) # 5542 <close>
      close(open(file, 0));
    4874:	4581                	li	a1,0
    4876:	fa840513          	addi	a0,s0,-88
    487a:	00001097          	auipc	ra,0x1
    487e:	ce0080e7          	jalr	-800(ra) # 555a <open>
    4882:	00001097          	auipc	ra,0x1
    4886:	cc0080e7          	jalr	-832(ra) # 5542 <close>
      close(open(file, 0));
    488a:	4581                	li	a1,0
    488c:	fa840513          	addi	a0,s0,-88
    4890:	00001097          	auipc	ra,0x1
    4894:	cca080e7          	jalr	-822(ra) # 555a <open>
    4898:	00001097          	auipc	ra,0x1
    489c:	caa080e7          	jalr	-854(ra) # 5542 <close>
      close(open(file, 0));
    48a0:	4581                	li	a1,0
    48a2:	fa840513          	addi	a0,s0,-88
    48a6:	00001097          	auipc	ra,0x1
    48aa:	cb4080e7          	jalr	-844(ra) # 555a <open>
    48ae:	00001097          	auipc	ra,0x1
    48b2:	c94080e7          	jalr	-876(ra) # 5542 <close>
    if(pid == 0)
    48b6:	08090363          	beqz	s2,493c <concreate+0x2d0>
      wait(0);
    48ba:	4501                	li	a0,0
    48bc:	00001097          	auipc	ra,0x1
    48c0:	c66080e7          	jalr	-922(ra) # 5522 <wait>
  for(i = 0; i < N; i++){
    48c4:	2485                	addiw	s1,s1,1
    48c6:	0f448563          	beq	s1,s4,49b0 <concreate+0x344>
    file[1] = '0' + i;
    48ca:	0304879b          	addiw	a5,s1,48
    48ce:	faf404a3          	sb	a5,-87(s0)
    pid = fork();
    48d2:	00001097          	auipc	ra,0x1
    48d6:	c40080e7          	jalr	-960(ra) # 5512 <fork>
    48da:	892a                	mv	s2,a0
    if(pid < 0){
    48dc:	f2054de3          	bltz	a0,4816 <concreate+0x1aa>
    if(((i % 3) == 0 && pid == 0) ||
    48e0:	0354e73b          	remw	a4,s1,s5
    48e4:	00a767b3          	or	a5,a4,a0
    48e8:	2781                	sext.w	a5,a5
    48ea:	d7a1                	beqz	a5,4832 <concreate+0x1c6>
    48ec:	01671363          	bne	a4,s6,48f2 <concreate+0x286>
       ((i % 3) == 1 && pid != 0)){
    48f0:	f129                	bnez	a0,4832 <concreate+0x1c6>
      unlink(file);
    48f2:	fa840513          	addi	a0,s0,-88
    48f6:	00001097          	auipc	ra,0x1
    48fa:	c74080e7          	jalr	-908(ra) # 556a <unlink>
      unlink(file);
    48fe:	fa840513          	addi	a0,s0,-88
    4902:	00001097          	auipc	ra,0x1
    4906:	c68080e7          	jalr	-920(ra) # 556a <unlink>
      unlink(file);
    490a:	fa840513          	addi	a0,s0,-88
    490e:	00001097          	auipc	ra,0x1
    4912:	c5c080e7          	jalr	-932(ra) # 556a <unlink>
      unlink(file);
    4916:	fa840513          	addi	a0,s0,-88
    491a:	00001097          	auipc	ra,0x1
    491e:	c50080e7          	jalr	-944(ra) # 556a <unlink>
      unlink(file);
    4922:	fa840513          	addi	a0,s0,-88
    4926:	00001097          	auipc	ra,0x1
    492a:	c44080e7          	jalr	-956(ra) # 556a <unlink>
      unlink(file);
    492e:	fa840513          	addi	a0,s0,-88
    4932:	00001097          	auipc	ra,0x1
    4936:	c38080e7          	jalr	-968(ra) # 556a <unlink>
    493a:	bfb5                	j	48b6 <concreate+0x24a>
      exit(0);
    493c:	4501                	li	a0,0
    493e:	00001097          	auipc	ra,0x1
    4942:	bdc080e7          	jalr	-1060(ra) # 551a <exit>
      close(fd);
    4946:	00001097          	auipc	ra,0x1
    494a:	bfc080e7          	jalr	-1028(ra) # 5542 <close>
    if(pid == 0) {
    494e:	bb65                	j	4706 <concreate+0x9a>
      close(fd);
    4950:	00001097          	auipc	ra,0x1
    4954:	bf2080e7          	jalr	-1038(ra) # 5542 <close>
      wait(&xstatus);
    4958:	f6c40513          	addi	a0,s0,-148
    495c:	00001097          	auipc	ra,0x1
    4960:	bc6080e7          	jalr	-1082(ra) # 5522 <wait>
      if(xstatus != 0)
    4964:	f6c42483          	lw	s1,-148(s0)
    4968:	da0494e3          	bnez	s1,4710 <concreate+0xa4>
  for(i = 0; i < N; i++){
    496c:	2905                	addiw	s2,s2,1
    496e:	db4906e3          	beq	s2,s4,471a <concreate+0xae>
    file[1] = '0' + i;
    4972:	0309079b          	addiw	a5,s2,48
    4976:	faf404a3          	sb	a5,-87(s0)
    unlink(file);
    497a:	fa840513          	addi	a0,s0,-88
    497e:	00001097          	auipc	ra,0x1
    4982:	bec080e7          	jalr	-1044(ra) # 556a <unlink>
    pid = fork();
    4986:	00001097          	auipc	ra,0x1
    498a:	b8c080e7          	jalr	-1140(ra) # 5512 <fork>
    if(pid && (i % 3) == 1){
    498e:	d20503e3          	beqz	a0,46b4 <concreate+0x48>
    4992:	036967bb          	remw	a5,s2,s6
    4996:	d15787e3          	beq	a5,s5,46a4 <concreate+0x38>
      fd = open(file, O_CREATE | O_RDWR);
    499a:	20200593          	li	a1,514
    499e:	fa840513          	addi	a0,s0,-88
    49a2:	00001097          	auipc	ra,0x1
    49a6:	bb8080e7          	jalr	-1096(ra) # 555a <open>
      if(fd < 0){
    49aa:	fa0553e3          	bgez	a0,4950 <concreate+0x2e4>
    49ae:	b31d                	j	46d4 <concreate+0x68>
}
    49b0:	60ea                	ld	ra,152(sp)
    49b2:	644a                	ld	s0,144(sp)
    49b4:	64aa                	ld	s1,136(sp)
    49b6:	690a                	ld	s2,128(sp)
    49b8:	79e6                	ld	s3,120(sp)
    49ba:	7a46                	ld	s4,112(sp)
    49bc:	7aa6                	ld	s5,104(sp)
    49be:	7b06                	ld	s6,96(sp)
    49c0:	6be6                	ld	s7,88(sp)
    49c2:	610d                	addi	sp,sp,160
    49c4:	8082                	ret

00000000000049c6 <bigfile>:
{
    49c6:	7139                	addi	sp,sp,-64
    49c8:	fc06                	sd	ra,56(sp)
    49ca:	f822                	sd	s0,48(sp)
    49cc:	f426                	sd	s1,40(sp)
    49ce:	f04a                	sd	s2,32(sp)
    49d0:	ec4e                	sd	s3,24(sp)
    49d2:	e852                	sd	s4,16(sp)
    49d4:	e456                	sd	s5,8(sp)
    49d6:	0080                	addi	s0,sp,64
    49d8:	8aaa                	mv	s5,a0
  unlink("bigfile.dat");
    49da:	00003517          	auipc	a0,0x3
    49de:	17e50513          	addi	a0,a0,382 # 7b58 <malloc+0x2206>
    49e2:	00001097          	auipc	ra,0x1
    49e6:	b88080e7          	jalr	-1144(ra) # 556a <unlink>
  fd = open("bigfile.dat", O_CREATE | O_RDWR);
    49ea:	20200593          	li	a1,514
    49ee:	00003517          	auipc	a0,0x3
    49f2:	16a50513          	addi	a0,a0,362 # 7b58 <malloc+0x2206>
    49f6:	00001097          	auipc	ra,0x1
    49fa:	b64080e7          	jalr	-1180(ra) # 555a <open>
    49fe:	89aa                	mv	s3,a0
  for(i = 0; i < N; i++){
    4a00:	4481                	li	s1,0
    memset(buf, i, SZ);
    4a02:	00007917          	auipc	s2,0x7
    4a06:	f7690913          	addi	s2,s2,-138 # b978 <buf>
  for(i = 0; i < N; i++){
    4a0a:	4a51                	li	s4,20
  if(fd < 0){
    4a0c:	0a054063          	bltz	a0,4aac <bigfile+0xe6>
    memset(buf, i, SZ);
    4a10:	25800613          	li	a2,600
    4a14:	85a6                	mv	a1,s1
    4a16:	854a                	mv	a0,s2
    4a18:	00001097          	auipc	ra,0x1
    4a1c:	8ec080e7          	jalr	-1812(ra) # 5304 <memset>
    if(write(fd, buf, SZ) != SZ){
    4a20:	25800613          	li	a2,600
    4a24:	85ca                	mv	a1,s2
    4a26:	854e                	mv	a0,s3
    4a28:	00001097          	auipc	ra,0x1
    4a2c:	b12080e7          	jalr	-1262(ra) # 553a <write>
    4a30:	25800793          	li	a5,600
    4a34:	08f51a63          	bne	a0,a5,4ac8 <bigfile+0x102>
  for(i = 0; i < N; i++){
    4a38:	2485                	addiw	s1,s1,1
    4a3a:	fd449be3          	bne	s1,s4,4a10 <bigfile+0x4a>
  close(fd);
    4a3e:	854e                	mv	a0,s3
    4a40:	00001097          	auipc	ra,0x1
    4a44:	b02080e7          	jalr	-1278(ra) # 5542 <close>
  fd = open("bigfile.dat", 0);
    4a48:	4581                	li	a1,0
    4a4a:	00003517          	auipc	a0,0x3
    4a4e:	10e50513          	addi	a0,a0,270 # 7b58 <malloc+0x2206>
    4a52:	00001097          	auipc	ra,0x1
    4a56:	b08080e7          	jalr	-1272(ra) # 555a <open>
    4a5a:	8a2a                	mv	s4,a0
  total = 0;
    4a5c:	4981                	li	s3,0
  for(i = 0; ; i++){
    4a5e:	4481                	li	s1,0
    cc = read(fd, buf, SZ/2);
    4a60:	00007917          	auipc	s2,0x7
    4a64:	f1890913          	addi	s2,s2,-232 # b978 <buf>
  if(fd < 0){
    4a68:	06054e63          	bltz	a0,4ae4 <bigfile+0x11e>
    cc = read(fd, buf, SZ/2);
    4a6c:	12c00613          	li	a2,300
    4a70:	85ca                	mv	a1,s2
    4a72:	8552                	mv	a0,s4
    4a74:	00001097          	auipc	ra,0x1
    4a78:	abe080e7          	jalr	-1346(ra) # 5532 <read>
    if(cc < 0){
    4a7c:	08054263          	bltz	a0,4b00 <bigfile+0x13a>
    if(cc == 0)
    4a80:	c971                	beqz	a0,4b54 <bigfile+0x18e>
    if(cc != SZ/2){
    4a82:	12c00793          	li	a5,300
    4a86:	08f51b63          	bne	a0,a5,4b1c <bigfile+0x156>
    if(buf[0] != i/2 || buf[SZ/2-1] != i/2){
    4a8a:	01f4d79b          	srliw	a5,s1,0x1f
    4a8e:	9fa5                	addw	a5,a5,s1
    4a90:	4017d79b          	sraiw	a5,a5,0x1
    4a94:	00094703          	lbu	a4,0(s2)
    4a98:	0af71063          	bne	a4,a5,4b38 <bigfile+0x172>
    4a9c:	12b94703          	lbu	a4,299(s2)
    4aa0:	08f71c63          	bne	a4,a5,4b38 <bigfile+0x172>
    total += cc;
    4aa4:	12c9899b          	addiw	s3,s3,300
  for(i = 0; ; i++){
    4aa8:	2485                	addiw	s1,s1,1
    cc = read(fd, buf, SZ/2);
    4aaa:	b7c9                	j	4a6c <bigfile+0xa6>
    printf("%s: cannot create bigfile", s);
    4aac:	85d6                	mv	a1,s5
    4aae:	00003517          	auipc	a0,0x3
    4ab2:	0ba50513          	addi	a0,a0,186 # 7b68 <malloc+0x2216>
    4ab6:	00001097          	auipc	ra,0x1
    4aba:	ddc080e7          	jalr	-548(ra) # 5892 <printf>
    exit(1);
    4abe:	4505                	li	a0,1
    4ac0:	00001097          	auipc	ra,0x1
    4ac4:	a5a080e7          	jalr	-1446(ra) # 551a <exit>
      printf("%s: write bigfile failed\n", s);
    4ac8:	85d6                	mv	a1,s5
    4aca:	00003517          	auipc	a0,0x3
    4ace:	0be50513          	addi	a0,a0,190 # 7b88 <malloc+0x2236>
    4ad2:	00001097          	auipc	ra,0x1
    4ad6:	dc0080e7          	jalr	-576(ra) # 5892 <printf>
      exit(1);
    4ada:	4505                	li	a0,1
    4adc:	00001097          	auipc	ra,0x1
    4ae0:	a3e080e7          	jalr	-1474(ra) # 551a <exit>
    printf("%s: cannot open bigfile\n", s);
    4ae4:	85d6                	mv	a1,s5
    4ae6:	00003517          	auipc	a0,0x3
    4aea:	0c250513          	addi	a0,a0,194 # 7ba8 <malloc+0x2256>
    4aee:	00001097          	auipc	ra,0x1
    4af2:	da4080e7          	jalr	-604(ra) # 5892 <printf>
    exit(1);
    4af6:	4505                	li	a0,1
    4af8:	00001097          	auipc	ra,0x1
    4afc:	a22080e7          	jalr	-1502(ra) # 551a <exit>
      printf("%s: read bigfile failed\n", s);
    4b00:	85d6                	mv	a1,s5
    4b02:	00003517          	auipc	a0,0x3
    4b06:	0c650513          	addi	a0,a0,198 # 7bc8 <malloc+0x2276>
    4b0a:	00001097          	auipc	ra,0x1
    4b0e:	d88080e7          	jalr	-632(ra) # 5892 <printf>
      exit(1);
    4b12:	4505                	li	a0,1
    4b14:	00001097          	auipc	ra,0x1
    4b18:	a06080e7          	jalr	-1530(ra) # 551a <exit>
      printf("%s: short read bigfile\n", s);
    4b1c:	85d6                	mv	a1,s5
    4b1e:	00003517          	auipc	a0,0x3
    4b22:	0ca50513          	addi	a0,a0,202 # 7be8 <malloc+0x2296>
    4b26:	00001097          	auipc	ra,0x1
    4b2a:	d6c080e7          	jalr	-660(ra) # 5892 <printf>
      exit(1);
    4b2e:	4505                	li	a0,1
    4b30:	00001097          	auipc	ra,0x1
    4b34:	9ea080e7          	jalr	-1558(ra) # 551a <exit>
      printf("%s: read bigfile wrong data\n", s);
    4b38:	85d6                	mv	a1,s5
    4b3a:	00003517          	auipc	a0,0x3
    4b3e:	0c650513          	addi	a0,a0,198 # 7c00 <malloc+0x22ae>
    4b42:	00001097          	auipc	ra,0x1
    4b46:	d50080e7          	jalr	-688(ra) # 5892 <printf>
      exit(1);
    4b4a:	4505                	li	a0,1
    4b4c:	00001097          	auipc	ra,0x1
    4b50:	9ce080e7          	jalr	-1586(ra) # 551a <exit>
  close(fd);
    4b54:	8552                	mv	a0,s4
    4b56:	00001097          	auipc	ra,0x1
    4b5a:	9ec080e7          	jalr	-1556(ra) # 5542 <close>
  if(total != N*SZ){
    4b5e:	678d                	lui	a5,0x3
    4b60:	ee078793          	addi	a5,a5,-288 # 2ee0 <dirtest+0x6a>
    4b64:	02f99363          	bne	s3,a5,4b8a <bigfile+0x1c4>
  unlink("bigfile.dat");
    4b68:	00003517          	auipc	a0,0x3
    4b6c:	ff050513          	addi	a0,a0,-16 # 7b58 <malloc+0x2206>
    4b70:	00001097          	auipc	ra,0x1
    4b74:	9fa080e7          	jalr	-1542(ra) # 556a <unlink>
}
    4b78:	70e2                	ld	ra,56(sp)
    4b7a:	7442                	ld	s0,48(sp)
    4b7c:	74a2                	ld	s1,40(sp)
    4b7e:	7902                	ld	s2,32(sp)
    4b80:	69e2                	ld	s3,24(sp)
    4b82:	6a42                	ld	s4,16(sp)
    4b84:	6aa2                	ld	s5,8(sp)
    4b86:	6121                	addi	sp,sp,64
    4b88:	8082                	ret
    printf("%s: read bigfile wrong total\n", s);
    4b8a:	85d6                	mv	a1,s5
    4b8c:	00003517          	auipc	a0,0x3
    4b90:	09450513          	addi	a0,a0,148 # 7c20 <malloc+0x22ce>
    4b94:	00001097          	auipc	ra,0x1
    4b98:	cfe080e7          	jalr	-770(ra) # 5892 <printf>
    exit(1);
    4b9c:	4505                	li	a0,1
    4b9e:	00001097          	auipc	ra,0x1
    4ba2:	97c080e7          	jalr	-1668(ra) # 551a <exit>

0000000000004ba6 <fsfull>:
{
    4ba6:	7171                	addi	sp,sp,-176
    4ba8:	f506                	sd	ra,168(sp)
    4baa:	f122                	sd	s0,160(sp)
    4bac:	ed26                	sd	s1,152(sp)
    4bae:	e94a                	sd	s2,144(sp)
    4bb0:	e54e                	sd	s3,136(sp)
    4bb2:	e152                	sd	s4,128(sp)
    4bb4:	fcd6                	sd	s5,120(sp)
    4bb6:	f8da                	sd	s6,112(sp)
    4bb8:	f4de                	sd	s7,104(sp)
    4bba:	f0e2                	sd	s8,96(sp)
    4bbc:	ece6                	sd	s9,88(sp)
    4bbe:	e8ea                	sd	s10,80(sp)
    4bc0:	e4ee                	sd	s11,72(sp)
    4bc2:	1900                	addi	s0,sp,176
  printf("fsfull test\n");
    4bc4:	00003517          	auipc	a0,0x3
    4bc8:	07c50513          	addi	a0,a0,124 # 7c40 <malloc+0x22ee>
    4bcc:	00001097          	auipc	ra,0x1
    4bd0:	cc6080e7          	jalr	-826(ra) # 5892 <printf>
  for(nfiles = 0; ; nfiles++){
    4bd4:	4481                	li	s1,0
    name[0] = 'f';
    4bd6:	06600d13          	li	s10,102
    name[1] = '0' + nfiles / 1000;
    4bda:	3e800c13          	li	s8,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4bde:	06400b93          	li	s7,100
    name[3] = '0' + (nfiles % 100) / 10;
    4be2:	4b29                	li	s6,10
    printf("writing %s\n", name);
    4be4:	00003c97          	auipc	s9,0x3
    4be8:	06cc8c93          	addi	s9,s9,108 # 7c50 <malloc+0x22fe>
    int total = 0;
    4bec:	4d81                	li	s11,0
      int cc = write(fd, buf, BSIZE);
    4bee:	00007a17          	auipc	s4,0x7
    4bf2:	d8aa0a13          	addi	s4,s4,-630 # b978 <buf>
    name[0] = 'f';
    4bf6:	f5a40823          	sb	s10,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4bfa:	0384c7bb          	divw	a5,s1,s8
    4bfe:	0307879b          	addiw	a5,a5,48
    4c02:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c06:	0384e7bb          	remw	a5,s1,s8
    4c0a:	0377c7bb          	divw	a5,a5,s7
    4c0e:	0307879b          	addiw	a5,a5,48
    4c12:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4c16:	0374e7bb          	remw	a5,s1,s7
    4c1a:	0367c7bb          	divw	a5,a5,s6
    4c1e:	0307879b          	addiw	a5,a5,48
    4c22:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4c26:	0364e7bb          	remw	a5,s1,s6
    4c2a:	0307879b          	addiw	a5,a5,48
    4c2e:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4c32:	f4040aa3          	sb	zero,-171(s0)
    printf("writing %s\n", name);
    4c36:	f5040593          	addi	a1,s0,-176
    4c3a:	8566                	mv	a0,s9
    4c3c:	00001097          	auipc	ra,0x1
    4c40:	c56080e7          	jalr	-938(ra) # 5892 <printf>
    int fd = open(name, O_CREATE|O_RDWR);
    4c44:	20200593          	li	a1,514
    4c48:	f5040513          	addi	a0,s0,-176
    4c4c:	00001097          	auipc	ra,0x1
    4c50:	90e080e7          	jalr	-1778(ra) # 555a <open>
    4c54:	89aa                	mv	s3,a0
    if(fd < 0){
    4c56:	0a055663          	bgez	a0,4d02 <fsfull+0x15c>
      printf("open %s failed\n", name);
    4c5a:	f5040593          	addi	a1,s0,-176
    4c5e:	00003517          	auipc	a0,0x3
    4c62:	00250513          	addi	a0,a0,2 # 7c60 <malloc+0x230e>
    4c66:	00001097          	auipc	ra,0x1
    4c6a:	c2c080e7          	jalr	-980(ra) # 5892 <printf>
  while(nfiles >= 0){
    4c6e:	0604c363          	bltz	s1,4cd4 <fsfull+0x12e>
    name[0] = 'f';
    4c72:	06600b13          	li	s6,102
    name[1] = '0' + nfiles / 1000;
    4c76:	3e800a13          	li	s4,1000
    name[2] = '0' + (nfiles % 1000) / 100;
    4c7a:	06400993          	li	s3,100
    name[3] = '0' + (nfiles % 100) / 10;
    4c7e:	4929                	li	s2,10
  while(nfiles >= 0){
    4c80:	5afd                	li	s5,-1
    name[0] = 'f';
    4c82:	f5640823          	sb	s6,-176(s0)
    name[1] = '0' + nfiles / 1000;
    4c86:	0344c7bb          	divw	a5,s1,s4
    4c8a:	0307879b          	addiw	a5,a5,48
    4c8e:	f4f408a3          	sb	a5,-175(s0)
    name[2] = '0' + (nfiles % 1000) / 100;
    4c92:	0344e7bb          	remw	a5,s1,s4
    4c96:	0337c7bb          	divw	a5,a5,s3
    4c9a:	0307879b          	addiw	a5,a5,48
    4c9e:	f4f40923          	sb	a5,-174(s0)
    name[3] = '0' + (nfiles % 100) / 10;
    4ca2:	0334e7bb          	remw	a5,s1,s3
    4ca6:	0327c7bb          	divw	a5,a5,s2
    4caa:	0307879b          	addiw	a5,a5,48
    4cae:	f4f409a3          	sb	a5,-173(s0)
    name[4] = '0' + (nfiles % 10);
    4cb2:	0324e7bb          	remw	a5,s1,s2
    4cb6:	0307879b          	addiw	a5,a5,48
    4cba:	f4f40a23          	sb	a5,-172(s0)
    name[5] = '\0';
    4cbe:	f4040aa3          	sb	zero,-171(s0)
    unlink(name);
    4cc2:	f5040513          	addi	a0,s0,-176
    4cc6:	00001097          	auipc	ra,0x1
    4cca:	8a4080e7          	jalr	-1884(ra) # 556a <unlink>
    nfiles--;
    4cce:	34fd                	addiw	s1,s1,-1
  while(nfiles >= 0){
    4cd0:	fb5499e3          	bne	s1,s5,4c82 <fsfull+0xdc>
  printf("fsfull test finished\n");
    4cd4:	00003517          	auipc	a0,0x3
    4cd8:	fac50513          	addi	a0,a0,-84 # 7c80 <malloc+0x232e>
    4cdc:	00001097          	auipc	ra,0x1
    4ce0:	bb6080e7          	jalr	-1098(ra) # 5892 <printf>
}
    4ce4:	70aa                	ld	ra,168(sp)
    4ce6:	740a                	ld	s0,160(sp)
    4ce8:	64ea                	ld	s1,152(sp)
    4cea:	694a                	ld	s2,144(sp)
    4cec:	69aa                	ld	s3,136(sp)
    4cee:	6a0a                	ld	s4,128(sp)
    4cf0:	7ae6                	ld	s5,120(sp)
    4cf2:	7b46                	ld	s6,112(sp)
    4cf4:	7ba6                	ld	s7,104(sp)
    4cf6:	7c06                	ld	s8,96(sp)
    4cf8:	6ce6                	ld	s9,88(sp)
    4cfa:	6d46                	ld	s10,80(sp)
    4cfc:	6da6                	ld	s11,72(sp)
    4cfe:	614d                	addi	sp,sp,176
    4d00:	8082                	ret
    int total = 0;
    4d02:	896e                	mv	s2,s11
      if(cc < BSIZE)
    4d04:	3ff00a93          	li	s5,1023
      int cc = write(fd, buf, BSIZE);
    4d08:	40000613          	li	a2,1024
    4d0c:	85d2                	mv	a1,s4
    4d0e:	854e                	mv	a0,s3
    4d10:	00001097          	auipc	ra,0x1
    4d14:	82a080e7          	jalr	-2006(ra) # 553a <write>
      if(cc < BSIZE)
    4d18:	00aad563          	ble	a0,s5,4d22 <fsfull+0x17c>
      total += cc;
    4d1c:	00a9093b          	addw	s2,s2,a0
    while(1){
    4d20:	b7e5                	j	4d08 <fsfull+0x162>
    printf("wrote %d bytes\n", total);
    4d22:	85ca                	mv	a1,s2
    4d24:	00003517          	auipc	a0,0x3
    4d28:	f4c50513          	addi	a0,a0,-180 # 7c70 <malloc+0x231e>
    4d2c:	00001097          	auipc	ra,0x1
    4d30:	b66080e7          	jalr	-1178(ra) # 5892 <printf>
    close(fd);
    4d34:	854e                	mv	a0,s3
    4d36:	00001097          	auipc	ra,0x1
    4d3a:	80c080e7          	jalr	-2036(ra) # 5542 <close>
    if(total == 0)
    4d3e:	f20908e3          	beqz	s2,4c6e <fsfull+0xc8>
  for(nfiles = 0; ; nfiles++){
    4d42:	2485                	addiw	s1,s1,1
    4d44:	bd4d                	j	4bf6 <fsfull+0x50>

0000000000004d46 <rand>:
{
    4d46:	1141                	addi	sp,sp,-16
    4d48:	e422                	sd	s0,8(sp)
    4d4a:	0800                	addi	s0,sp,16
  randstate = randstate * 1664525 + 1013904223;
    4d4c:	00003717          	auipc	a4,0x3
    4d50:	3fc70713          	addi	a4,a4,1020 # 8148 <randstate>
    4d54:	6308                	ld	a0,0(a4)
    4d56:	001967b7          	lui	a5,0x196
    4d5a:	60d78793          	addi	a5,a5,1549 # 19660d <_end+0x187c85>
    4d5e:	02f50533          	mul	a0,a0,a5
    4d62:	3c6ef7b7          	lui	a5,0x3c6ef
    4d66:	35f78793          	addi	a5,a5,863 # 3c6ef35f <_end+0x3c6e09d7>
    4d6a:	953e                	add	a0,a0,a5
    4d6c:	e308                	sd	a0,0(a4)
}
    4d6e:	2501                	sext.w	a0,a0
    4d70:	6422                	ld	s0,8(sp)
    4d72:	0141                	addi	sp,sp,16
    4d74:	8082                	ret

0000000000004d76 <badwrite>:
{
    4d76:	7179                	addi	sp,sp,-48
    4d78:	f406                	sd	ra,40(sp)
    4d7a:	f022                	sd	s0,32(sp)
    4d7c:	ec26                	sd	s1,24(sp)
    4d7e:	e84a                	sd	s2,16(sp)
    4d80:	e44e                	sd	s3,8(sp)
    4d82:	e052                	sd	s4,0(sp)
    4d84:	1800                	addi	s0,sp,48
  unlink("junk");
    4d86:	00003517          	auipc	a0,0x3
    4d8a:	f1250513          	addi	a0,a0,-238 # 7c98 <malloc+0x2346>
    4d8e:	00000097          	auipc	ra,0x0
    4d92:	7dc080e7          	jalr	2012(ra) # 556a <unlink>
    4d96:	25800913          	li	s2,600
    int fd = open("junk", O_CREATE|O_WRONLY);
    4d9a:	00003997          	auipc	s3,0x3
    4d9e:	efe98993          	addi	s3,s3,-258 # 7c98 <malloc+0x2346>
    write(fd, (char*)0xffffffffffL, 1);
    4da2:	5a7d                	li	s4,-1
    4da4:	018a5a13          	srli	s4,s4,0x18
    int fd = open("junk", O_CREATE|O_WRONLY);
    4da8:	20100593          	li	a1,513
    4dac:	854e                	mv	a0,s3
    4dae:	00000097          	auipc	ra,0x0
    4db2:	7ac080e7          	jalr	1964(ra) # 555a <open>
    4db6:	84aa                	mv	s1,a0
    if(fd < 0){
    4db8:	06054b63          	bltz	a0,4e2e <badwrite+0xb8>
    write(fd, (char*)0xffffffffffL, 1);
    4dbc:	4605                	li	a2,1
    4dbe:	85d2                	mv	a1,s4
    4dc0:	00000097          	auipc	ra,0x0
    4dc4:	77a080e7          	jalr	1914(ra) # 553a <write>
    close(fd);
    4dc8:	8526                	mv	a0,s1
    4dca:	00000097          	auipc	ra,0x0
    4dce:	778080e7          	jalr	1912(ra) # 5542 <close>
    unlink("junk");
    4dd2:	854e                	mv	a0,s3
    4dd4:	00000097          	auipc	ra,0x0
    4dd8:	796080e7          	jalr	1942(ra) # 556a <unlink>
  for(int i = 0; i < assumed_free; i++){
    4ddc:	397d                	addiw	s2,s2,-1
    4dde:	fc0915e3          	bnez	s2,4da8 <badwrite+0x32>
  int fd = open("junk", O_CREATE|O_WRONLY);
    4de2:	20100593          	li	a1,513
    4de6:	00003517          	auipc	a0,0x3
    4dea:	eb250513          	addi	a0,a0,-334 # 7c98 <malloc+0x2346>
    4dee:	00000097          	auipc	ra,0x0
    4df2:	76c080e7          	jalr	1900(ra) # 555a <open>
    4df6:	84aa                	mv	s1,a0
  if(fd < 0){
    4df8:	04054863          	bltz	a0,4e48 <badwrite+0xd2>
  if(write(fd, "x", 1) != 1){
    4dfc:	4605                	li	a2,1
    4dfe:	00001597          	auipc	a1,0x1
    4e02:	0a258593          	addi	a1,a1,162 # 5ea0 <malloc+0x54e>
    4e06:	00000097          	auipc	ra,0x0
    4e0a:	734080e7          	jalr	1844(ra) # 553a <write>
    4e0e:	4785                	li	a5,1
    4e10:	04f50963          	beq	a0,a5,4e62 <badwrite+0xec>
    printf("write failed\n");
    4e14:	00003517          	auipc	a0,0x3
    4e18:	ea450513          	addi	a0,a0,-348 # 7cb8 <malloc+0x2366>
    4e1c:	00001097          	auipc	ra,0x1
    4e20:	a76080e7          	jalr	-1418(ra) # 5892 <printf>
    exit(1);
    4e24:	4505                	li	a0,1
    4e26:	00000097          	auipc	ra,0x0
    4e2a:	6f4080e7          	jalr	1780(ra) # 551a <exit>
      printf("open junk failed\n");
    4e2e:	00003517          	auipc	a0,0x3
    4e32:	e7250513          	addi	a0,a0,-398 # 7ca0 <malloc+0x234e>
    4e36:	00001097          	auipc	ra,0x1
    4e3a:	a5c080e7          	jalr	-1444(ra) # 5892 <printf>
      exit(1);
    4e3e:	4505                	li	a0,1
    4e40:	00000097          	auipc	ra,0x0
    4e44:	6da080e7          	jalr	1754(ra) # 551a <exit>
    printf("open junk failed\n");
    4e48:	00003517          	auipc	a0,0x3
    4e4c:	e5850513          	addi	a0,a0,-424 # 7ca0 <malloc+0x234e>
    4e50:	00001097          	auipc	ra,0x1
    4e54:	a42080e7          	jalr	-1470(ra) # 5892 <printf>
    exit(1);
    4e58:	4505                	li	a0,1
    4e5a:	00000097          	auipc	ra,0x0
    4e5e:	6c0080e7          	jalr	1728(ra) # 551a <exit>
  close(fd);
    4e62:	8526                	mv	a0,s1
    4e64:	00000097          	auipc	ra,0x0
    4e68:	6de080e7          	jalr	1758(ra) # 5542 <close>
  unlink("junk");
    4e6c:	00003517          	auipc	a0,0x3
    4e70:	e2c50513          	addi	a0,a0,-468 # 7c98 <malloc+0x2346>
    4e74:	00000097          	auipc	ra,0x0
    4e78:	6f6080e7          	jalr	1782(ra) # 556a <unlink>
  exit(0);
    4e7c:	4501                	li	a0,0
    4e7e:	00000097          	auipc	ra,0x0
    4e82:	69c080e7          	jalr	1692(ra) # 551a <exit>

0000000000004e86 <countfree>:
// because out of memory with lazy allocation results in the process
// taking a fault and being killed, fork and report back.
//
int
countfree()
{
    4e86:	7139                	addi	sp,sp,-64
    4e88:	fc06                	sd	ra,56(sp)
    4e8a:	f822                	sd	s0,48(sp)
    4e8c:	f426                	sd	s1,40(sp)
    4e8e:	f04a                	sd	s2,32(sp)
    4e90:	ec4e                	sd	s3,24(sp)
    4e92:	0080                	addi	s0,sp,64
  int fds[2];

  if(pipe(fds) < 0){
    4e94:	fc840513          	addi	a0,s0,-56
    4e98:	00000097          	auipc	ra,0x0
    4e9c:	692080e7          	jalr	1682(ra) # 552a <pipe>
    4ea0:	06054863          	bltz	a0,4f10 <countfree+0x8a>
    printf("pipe() failed in countfree()\n");
    exit(1);
  }
  
  int pid = fork();
    4ea4:	00000097          	auipc	ra,0x0
    4ea8:	66e080e7          	jalr	1646(ra) # 5512 <fork>

  if(pid < 0){
    4eac:	06054f63          	bltz	a0,4f2a <countfree+0xa4>
    printf("fork failed in countfree()\n");
    exit(1);
  }

  if(pid == 0){
    4eb0:	ed59                	bnez	a0,4f4e <countfree+0xc8>
    close(fds[0]);
    4eb2:	fc842503          	lw	a0,-56(s0)
    4eb6:	00000097          	auipc	ra,0x0
    4eba:	68c080e7          	jalr	1676(ra) # 5542 <close>
    
    while(1){
      uint64 a = (uint64) sbrk(4096);
      if(a == 0xffffffffffffffff){
    4ebe:	54fd                	li	s1,-1
        break;
      }

      // modify the memory to make sure it's really allocated.
      *(char *)(a + 4096 - 1) = 1;
    4ec0:	4985                	li	s3,1

      // report back one more page.
      if(write(fds[1], "x", 1) != 1){
    4ec2:	00001917          	auipc	s2,0x1
    4ec6:	fde90913          	addi	s2,s2,-34 # 5ea0 <malloc+0x54e>
      uint64 a = (uint64) sbrk(4096);
    4eca:	6505                	lui	a0,0x1
    4ecc:	00000097          	auipc	ra,0x0
    4ed0:	6d6080e7          	jalr	1750(ra) # 55a2 <sbrk>
      if(a == 0xffffffffffffffff){
    4ed4:	06950863          	beq	a0,s1,4f44 <countfree+0xbe>
      *(char *)(a + 4096 - 1) = 1;
    4ed8:	6785                	lui	a5,0x1
    4eda:	97aa                	add	a5,a5,a0
    4edc:	ff378fa3          	sb	s3,-1(a5) # fff <bigdir+0x77>
      if(write(fds[1], "x", 1) != 1){
    4ee0:	4605                	li	a2,1
    4ee2:	85ca                	mv	a1,s2
    4ee4:	fcc42503          	lw	a0,-52(s0)
    4ee8:	00000097          	auipc	ra,0x0
    4eec:	652080e7          	jalr	1618(ra) # 553a <write>
    4ef0:	4785                	li	a5,1
    4ef2:	fcf50ce3          	beq	a0,a5,4eca <countfree+0x44>
        printf("write() failed in countfree()\n");
    4ef6:	00003517          	auipc	a0,0x3
    4efa:	e1250513          	addi	a0,a0,-494 # 7d08 <malloc+0x23b6>
    4efe:	00001097          	auipc	ra,0x1
    4f02:	994080e7          	jalr	-1644(ra) # 5892 <printf>
        exit(1);
    4f06:	4505                	li	a0,1
    4f08:	00000097          	auipc	ra,0x0
    4f0c:	612080e7          	jalr	1554(ra) # 551a <exit>
    printf("pipe() failed in countfree()\n");
    4f10:	00003517          	auipc	a0,0x3
    4f14:	db850513          	addi	a0,a0,-584 # 7cc8 <malloc+0x2376>
    4f18:	00001097          	auipc	ra,0x1
    4f1c:	97a080e7          	jalr	-1670(ra) # 5892 <printf>
    exit(1);
    4f20:	4505                	li	a0,1
    4f22:	00000097          	auipc	ra,0x0
    4f26:	5f8080e7          	jalr	1528(ra) # 551a <exit>
    printf("fork failed in countfree()\n");
    4f2a:	00003517          	auipc	a0,0x3
    4f2e:	dbe50513          	addi	a0,a0,-578 # 7ce8 <malloc+0x2396>
    4f32:	00001097          	auipc	ra,0x1
    4f36:	960080e7          	jalr	-1696(ra) # 5892 <printf>
    exit(1);
    4f3a:	4505                	li	a0,1
    4f3c:	00000097          	auipc	ra,0x0
    4f40:	5de080e7          	jalr	1502(ra) # 551a <exit>
      }
    }

    exit(0);
    4f44:	4501                	li	a0,0
    4f46:	00000097          	auipc	ra,0x0
    4f4a:	5d4080e7          	jalr	1492(ra) # 551a <exit>
  }

  close(fds[1]);
    4f4e:	fcc42503          	lw	a0,-52(s0)
    4f52:	00000097          	auipc	ra,0x0
    4f56:	5f0080e7          	jalr	1520(ra) # 5542 <close>

  int n = 0;
    4f5a:	4481                	li	s1,0
    4f5c:	a839                	j	4f7a <countfree+0xf4>
  while(1){
    char c;
    int cc = read(fds[0], &c, 1);
    if(cc < 0){
      printf("read() failed in countfree()\n");
    4f5e:	00003517          	auipc	a0,0x3
    4f62:	dca50513          	addi	a0,a0,-566 # 7d28 <malloc+0x23d6>
    4f66:	00001097          	auipc	ra,0x1
    4f6a:	92c080e7          	jalr	-1748(ra) # 5892 <printf>
      exit(1);
    4f6e:	4505                	li	a0,1
    4f70:	00000097          	auipc	ra,0x0
    4f74:	5aa080e7          	jalr	1450(ra) # 551a <exit>
    }
    if(cc == 0)
      break;
    n += 1;
    4f78:	2485                	addiw	s1,s1,1
    int cc = read(fds[0], &c, 1);
    4f7a:	4605                	li	a2,1
    4f7c:	fc740593          	addi	a1,s0,-57
    4f80:	fc842503          	lw	a0,-56(s0)
    4f84:	00000097          	auipc	ra,0x0
    4f88:	5ae080e7          	jalr	1454(ra) # 5532 <read>
    if(cc < 0){
    4f8c:	fc0549e3          	bltz	a0,4f5e <countfree+0xd8>
    if(cc == 0)
    4f90:	f565                	bnez	a0,4f78 <countfree+0xf2>
  }

  close(fds[0]);
    4f92:	fc842503          	lw	a0,-56(s0)
    4f96:	00000097          	auipc	ra,0x0
    4f9a:	5ac080e7          	jalr	1452(ra) # 5542 <close>
  wait((int*)0);
    4f9e:	4501                	li	a0,0
    4fa0:	00000097          	auipc	ra,0x0
    4fa4:	582080e7          	jalr	1410(ra) # 5522 <wait>
  
  return n;
}
    4fa8:	8526                	mv	a0,s1
    4faa:	70e2                	ld	ra,56(sp)
    4fac:	7442                	ld	s0,48(sp)
    4fae:	74a2                	ld	s1,40(sp)
    4fb0:	7902                	ld	s2,32(sp)
    4fb2:	69e2                	ld	s3,24(sp)
    4fb4:	6121                	addi	sp,sp,64
    4fb6:	8082                	ret

0000000000004fb8 <run>:

// run each test in its own process. run returns 1 if child's exit()
// indicates success.
int
run(void f(char *), char *s) {
    4fb8:	7179                	addi	sp,sp,-48
    4fba:	f406                	sd	ra,40(sp)
    4fbc:	f022                	sd	s0,32(sp)
    4fbe:	ec26                	sd	s1,24(sp)
    4fc0:	e84a                	sd	s2,16(sp)
    4fc2:	1800                	addi	s0,sp,48
    4fc4:	84aa                	mv	s1,a0
    4fc6:	892e                	mv	s2,a1
  int pid;
  int xstatus;

  printf("test %s: ", s);
    4fc8:	00003517          	auipc	a0,0x3
    4fcc:	d8050513          	addi	a0,a0,-640 # 7d48 <malloc+0x23f6>
    4fd0:	00001097          	auipc	ra,0x1
    4fd4:	8c2080e7          	jalr	-1854(ra) # 5892 <printf>
  if((pid = fork()) < 0) {
    4fd8:	00000097          	auipc	ra,0x0
    4fdc:	53a080e7          	jalr	1338(ra) # 5512 <fork>
    4fe0:	02054e63          	bltz	a0,501c <run+0x64>
    printf("runtest: fork error\n");
    exit(1);
  }
  if(pid == 0) {
    4fe4:	c929                	beqz	a0,5036 <run+0x7e>
    f(s);
    exit(0);
  } else {
    wait(&xstatus);
    4fe6:	fdc40513          	addi	a0,s0,-36
    4fea:	00000097          	auipc	ra,0x0
    4fee:	538080e7          	jalr	1336(ra) # 5522 <wait>
    if(xstatus != 0) 
    4ff2:	fdc42783          	lw	a5,-36(s0)
    4ff6:	c7b9                	beqz	a5,5044 <run+0x8c>
      printf("FAILED\n");
    4ff8:	00003517          	auipc	a0,0x3
    4ffc:	d7850513          	addi	a0,a0,-648 # 7d70 <malloc+0x241e>
    5000:	00001097          	auipc	ra,0x1
    5004:	892080e7          	jalr	-1902(ra) # 5892 <printf>
    else
      printf("OK\n");
    return xstatus == 0;
    5008:	fdc42503          	lw	a0,-36(s0)
  }
}
    500c:	00153513          	seqz	a0,a0
    5010:	70a2                	ld	ra,40(sp)
    5012:	7402                	ld	s0,32(sp)
    5014:	64e2                	ld	s1,24(sp)
    5016:	6942                	ld	s2,16(sp)
    5018:	6145                	addi	sp,sp,48
    501a:	8082                	ret
    printf("runtest: fork error\n");
    501c:	00003517          	auipc	a0,0x3
    5020:	d3c50513          	addi	a0,a0,-708 # 7d58 <malloc+0x2406>
    5024:	00001097          	auipc	ra,0x1
    5028:	86e080e7          	jalr	-1938(ra) # 5892 <printf>
    exit(1);
    502c:	4505                	li	a0,1
    502e:	00000097          	auipc	ra,0x0
    5032:	4ec080e7          	jalr	1260(ra) # 551a <exit>
    f(s);
    5036:	854a                	mv	a0,s2
    5038:	9482                	jalr	s1
    exit(0);
    503a:	4501                	li	a0,0
    503c:	00000097          	auipc	ra,0x0
    5040:	4de080e7          	jalr	1246(ra) # 551a <exit>
      printf("OK\n");
    5044:	00003517          	auipc	a0,0x3
    5048:	d3450513          	addi	a0,a0,-716 # 7d78 <malloc+0x2426>
    504c:	00001097          	auipc	ra,0x1
    5050:	846080e7          	jalr	-1978(ra) # 5892 <printf>
    5054:	bf55                	j	5008 <run+0x50>

0000000000005056 <main>:

int
main(int argc, char *argv[])
{
    5056:	c2010113          	addi	sp,sp,-992
    505a:	3c113c23          	sd	ra,984(sp)
    505e:	3c813823          	sd	s0,976(sp)
    5062:	3c913423          	sd	s1,968(sp)
    5066:	3d213023          	sd	s2,960(sp)
    506a:	3b313c23          	sd	s3,952(sp)
    506e:	3b413823          	sd	s4,944(sp)
    5072:	3b513423          	sd	s5,936(sp)
    5076:	3b613023          	sd	s6,928(sp)
    507a:	1780                	addi	s0,sp,992
    507c:	89aa                	mv	s3,a0
  int continuous = 0;
  char *justone = 0;

  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    507e:	4789                	li	a5,2
    5080:	08f50863          	beq	a0,a5,5110 <main+0xba>
    continuous = 1;
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    continuous = 2;
  } else if(argc == 2 && argv[1][0] != '-'){
    justone = argv[1];
  } else if(argc > 1){
    5084:	4785                	li	a5,1
    5086:	0ca7c363          	blt	a5,a0,514c <main+0xf6>
  char *justone = 0;
    508a:	4981                	li	s3,0
  }
  
  struct test {
    void (*f)(char *);
    char *s;
  } tests[] = {
    508c:	00001797          	auipc	a5,0x1
    5090:	9cc78793          	addi	a5,a5,-1588 # 5a58 <malloc+0x106>
    5094:	c2040713          	addi	a4,s0,-992
    5098:	00001817          	auipc	a6,0x1
    509c:	d6080813          	addi	a6,a6,-672 # 5df8 <malloc+0x4a6>
    50a0:	6388                	ld	a0,0(a5)
    50a2:	678c                	ld	a1,8(a5)
    50a4:	6b90                	ld	a2,16(a5)
    50a6:	6f94                	ld	a3,24(a5)
    50a8:	e308                	sd	a0,0(a4)
    50aa:	e70c                	sd	a1,8(a4)
    50ac:	eb10                	sd	a2,16(a4)
    50ae:	ef14                	sd	a3,24(a4)
    50b0:	02078793          	addi	a5,a5,32
    50b4:	02070713          	addi	a4,a4,32
    50b8:	ff0794e3          	bne	a5,a6,50a0 <main+0x4a>
          exit(1);
      }
    }
  }

  printf("usertests starting\n");
    50bc:	00003517          	auipc	a0,0x3
    50c0:	d7450513          	addi	a0,a0,-652 # 7e30 <malloc+0x24de>
    50c4:	00000097          	auipc	ra,0x0
    50c8:	7ce080e7          	jalr	1998(ra) # 5892 <printf>
  int free0 = countfree();
    50cc:	00000097          	auipc	ra,0x0
    50d0:	dba080e7          	jalr	-582(ra) # 4e86 <countfree>
    50d4:	8b2a                	mv	s6,a0
  int free1 = 0;
  int fail = 0;
  for (struct test *t = tests; t->s != 0; t++) {
    50d6:	c2843903          	ld	s2,-984(s0)
    50da:	c2040493          	addi	s1,s0,-992
  int fail = 0;
    50de:	4a01                	li	s4,0
    if((justone == 0) || strcmp(t->s, justone) == 0) {
      if(!run(t->f, t->s))
        fail = 1;
    50e0:	4a85                	li	s5,1
  for (struct test *t = tests; t->s != 0; t++) {
    50e2:	0a091a63          	bnez	s2,5196 <main+0x140>
  }

  if(fail){
    printf("SOME TESTS FAILED\n");
    exit(1);
  } else if((free1 = countfree()) < free0){
    50e6:	00000097          	auipc	ra,0x0
    50ea:	da0080e7          	jalr	-608(ra) # 4e86 <countfree>
    50ee:	85aa                	mv	a1,a0
    50f0:	0f655463          	ble	s6,a0,51d8 <main+0x182>
    printf("FAILED -- lost some free pages %d (out of %d)\n", free1, free0);
    50f4:	865a                	mv	a2,s6
    50f6:	00003517          	auipc	a0,0x3
    50fa:	cf250513          	addi	a0,a0,-782 # 7de8 <malloc+0x2496>
    50fe:	00000097          	auipc	ra,0x0
    5102:	794080e7          	jalr	1940(ra) # 5892 <printf>
    exit(1);
    5106:	4505                	li	a0,1
    5108:	00000097          	auipc	ra,0x0
    510c:	412080e7          	jalr	1042(ra) # 551a <exit>
    5110:	84ae                	mv	s1,a1
  if(argc == 2 && strcmp(argv[1], "-c") == 0){
    5112:	00003597          	auipc	a1,0x3
    5116:	c6e58593          	addi	a1,a1,-914 # 7d80 <malloc+0x242e>
    511a:	6488                	ld	a0,8(s1)
    511c:	00000097          	auipc	ra,0x0
    5120:	18a080e7          	jalr	394(ra) # 52a6 <strcmp>
    5124:	10050863          	beqz	a0,5234 <main+0x1de>
  } else if(argc == 2 && strcmp(argv[1], "-C") == 0){
    5128:	00003597          	auipc	a1,0x3
    512c:	d4058593          	addi	a1,a1,-704 # 7e68 <malloc+0x2516>
    5130:	6488                	ld	a0,8(s1)
    5132:	00000097          	auipc	ra,0x0
    5136:	174080e7          	jalr	372(ra) # 52a6 <strcmp>
    513a:	cd75                	beqz	a0,5236 <main+0x1e0>
  } else if(argc == 2 && argv[1][0] != '-'){
    513c:	0084b983          	ld	s3,8(s1)
    5140:	0009c703          	lbu	a4,0(s3)
    5144:	02d00793          	li	a5,45
    5148:	f4f712e3          	bne	a4,a5,508c <main+0x36>
    printf("Usage: usertests [-c] [testname]\n");
    514c:	00003517          	auipc	a0,0x3
    5150:	c3c50513          	addi	a0,a0,-964 # 7d88 <malloc+0x2436>
    5154:	00000097          	auipc	ra,0x0
    5158:	73e080e7          	jalr	1854(ra) # 5892 <printf>
    exit(1);
    515c:	4505                	li	a0,1
    515e:	00000097          	auipc	ra,0x0
    5162:	3bc080e7          	jalr	956(ra) # 551a <exit>
          exit(1);
    5166:	4505                	li	a0,1
    5168:	00000097          	auipc	ra,0x0
    516c:	3b2080e7          	jalr	946(ra) # 551a <exit>
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5170:	40a905bb          	subw	a1,s2,a0
    5174:	855a                	mv	a0,s6
    5176:	00000097          	auipc	ra,0x0
    517a:	71c080e7          	jalr	1820(ra) # 5892 <printf>
        if(continuous != 2)
    517e:	09498763          	beq	s3,s4,520c <main+0x1b6>
          exit(1);
    5182:	4505                	li	a0,1
    5184:	00000097          	auipc	ra,0x0
    5188:	396080e7          	jalr	918(ra) # 551a <exit>
  for (struct test *t = tests; t->s != 0; t++) {
    518c:	04c1                	addi	s1,s1,16
    518e:	0084b903          	ld	s2,8(s1)
    5192:	02090463          	beqz	s2,51ba <main+0x164>
    if((justone == 0) || strcmp(t->s, justone) == 0) {
    5196:	00098963          	beqz	s3,51a8 <main+0x152>
    519a:	85ce                	mv	a1,s3
    519c:	854a                	mv	a0,s2
    519e:	00000097          	auipc	ra,0x0
    51a2:	108080e7          	jalr	264(ra) # 52a6 <strcmp>
    51a6:	f17d                	bnez	a0,518c <main+0x136>
      if(!run(t->f, t->s))
    51a8:	85ca                	mv	a1,s2
    51aa:	6088                	ld	a0,0(s1)
    51ac:	00000097          	auipc	ra,0x0
    51b0:	e0c080e7          	jalr	-500(ra) # 4fb8 <run>
    51b4:	fd61                	bnez	a0,518c <main+0x136>
        fail = 1;
    51b6:	8a56                	mv	s4,s5
    51b8:	bfd1                	j	518c <main+0x136>
  if(fail){
    51ba:	f20a06e3          	beqz	s4,50e6 <main+0x90>
    printf("SOME TESTS FAILED\n");
    51be:	00003517          	auipc	a0,0x3
    51c2:	c1250513          	addi	a0,a0,-1006 # 7dd0 <malloc+0x247e>
    51c6:	00000097          	auipc	ra,0x0
    51ca:	6cc080e7          	jalr	1740(ra) # 5892 <printf>
    exit(1);
    51ce:	4505                	li	a0,1
    51d0:	00000097          	auipc	ra,0x0
    51d4:	34a080e7          	jalr	842(ra) # 551a <exit>
  } else {
    printf("ALL TESTS PASSED\n");
    51d8:	00003517          	auipc	a0,0x3
    51dc:	c4050513          	addi	a0,a0,-960 # 7e18 <malloc+0x24c6>
    51e0:	00000097          	auipc	ra,0x0
    51e4:	6b2080e7          	jalr	1714(ra) # 5892 <printf>
    exit(0);
    51e8:	4501                	li	a0,0
    51ea:	00000097          	auipc	ra,0x0
    51ee:	330080e7          	jalr	816(ra) # 551a <exit>
        printf("SOME TESTS FAILED\n");
    51f2:	8556                	mv	a0,s5
    51f4:	00000097          	auipc	ra,0x0
    51f8:	69e080e7          	jalr	1694(ra) # 5892 <printf>
        if(continuous != 2)
    51fc:	f74995e3          	bne	s3,s4,5166 <main+0x110>
      int free1 = countfree();
    5200:	00000097          	auipc	ra,0x0
    5204:	c86080e7          	jalr	-890(ra) # 4e86 <countfree>
      if(free1 < free0){
    5208:	f72544e3          	blt	a0,s2,5170 <main+0x11a>
      int free0 = countfree();
    520c:	00000097          	auipc	ra,0x0
    5210:	c7a080e7          	jalr	-902(ra) # 4e86 <countfree>
    5214:	892a                	mv	s2,a0
      for (struct test *t = tests; t->s != 0; t++) {
    5216:	c2843583          	ld	a1,-984(s0)
    521a:	d1fd                	beqz	a1,5200 <main+0x1aa>
    521c:	c2040493          	addi	s1,s0,-992
        if(!run(t->f, t->s)){
    5220:	6088                	ld	a0,0(s1)
    5222:	00000097          	auipc	ra,0x0
    5226:	d96080e7          	jalr	-618(ra) # 4fb8 <run>
    522a:	d561                	beqz	a0,51f2 <main+0x19c>
      for (struct test *t = tests; t->s != 0; t++) {
    522c:	04c1                	addi	s1,s1,16
    522e:	648c                	ld	a1,8(s1)
    5230:	f9e5                	bnez	a1,5220 <main+0x1ca>
    5232:	b7f9                	j	5200 <main+0x1aa>
    continuous = 1;
    5234:	4985                	li	s3,1
  } tests[] = {
    5236:	00001797          	auipc	a5,0x1
    523a:	82278793          	addi	a5,a5,-2014 # 5a58 <malloc+0x106>
    523e:	c2040713          	addi	a4,s0,-992
    5242:	00001817          	auipc	a6,0x1
    5246:	bb680813          	addi	a6,a6,-1098 # 5df8 <malloc+0x4a6>
    524a:	6388                	ld	a0,0(a5)
    524c:	678c                	ld	a1,8(a5)
    524e:	6b90                	ld	a2,16(a5)
    5250:	6f94                	ld	a3,24(a5)
    5252:	e308                	sd	a0,0(a4)
    5254:	e70c                	sd	a1,8(a4)
    5256:	eb10                	sd	a2,16(a4)
    5258:	ef14                	sd	a3,24(a4)
    525a:	02078793          	addi	a5,a5,32
    525e:	02070713          	addi	a4,a4,32
    5262:	ff0794e3          	bne	a5,a6,524a <main+0x1f4>
    printf("continuous usertests starting\n");
    5266:	00003517          	auipc	a0,0x3
    526a:	be250513          	addi	a0,a0,-1054 # 7e48 <malloc+0x24f6>
    526e:	00000097          	auipc	ra,0x0
    5272:	624080e7          	jalr	1572(ra) # 5892 <printf>
        printf("SOME TESTS FAILED\n");
    5276:	00003a97          	auipc	s5,0x3
    527a:	b5aa8a93          	addi	s5,s5,-1190 # 7dd0 <malloc+0x247e>
        if(continuous != 2)
    527e:	4a09                	li	s4,2
        printf("FAILED -- lost %d free pages\n", free0 - free1);
    5280:	00003b17          	auipc	s6,0x3
    5284:	b30b0b13          	addi	s6,s6,-1232 # 7db0 <malloc+0x245e>
    5288:	b751                	j	520c <main+0x1b6>

000000000000528a <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
    528a:	1141                	addi	sp,sp,-16
    528c:	e422                	sd	s0,8(sp)
    528e:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
    5290:	87aa                	mv	a5,a0
    5292:	0585                	addi	a1,a1,1
    5294:	0785                	addi	a5,a5,1
    5296:	fff5c703          	lbu	a4,-1(a1)
    529a:	fee78fa3          	sb	a4,-1(a5)
    529e:	fb75                	bnez	a4,5292 <strcpy+0x8>
    ;
  return os;
}
    52a0:	6422                	ld	s0,8(sp)
    52a2:	0141                	addi	sp,sp,16
    52a4:	8082                	ret

00000000000052a6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
    52a6:	1141                	addi	sp,sp,-16
    52a8:	e422                	sd	s0,8(sp)
    52aa:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
    52ac:	00054783          	lbu	a5,0(a0)
    52b0:	cf91                	beqz	a5,52cc <strcmp+0x26>
    52b2:	0005c703          	lbu	a4,0(a1)
    52b6:	00f71b63          	bne	a4,a5,52cc <strcmp+0x26>
    p++, q++;
    52ba:	0505                	addi	a0,a0,1
    52bc:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
    52be:	00054783          	lbu	a5,0(a0)
    52c2:	c789                	beqz	a5,52cc <strcmp+0x26>
    52c4:	0005c703          	lbu	a4,0(a1)
    52c8:	fef709e3          	beq	a4,a5,52ba <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
    52cc:	0005c503          	lbu	a0,0(a1)
}
    52d0:	40a7853b          	subw	a0,a5,a0
    52d4:	6422                	ld	s0,8(sp)
    52d6:	0141                	addi	sp,sp,16
    52d8:	8082                	ret

00000000000052da <strlen>:

uint
strlen(const char *s)
{
    52da:	1141                	addi	sp,sp,-16
    52dc:	e422                	sd	s0,8(sp)
    52de:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    52e0:	00054783          	lbu	a5,0(a0)
    52e4:	cf91                	beqz	a5,5300 <strlen+0x26>
    52e6:	0505                	addi	a0,a0,1
    52e8:	87aa                	mv	a5,a0
    52ea:	4685                	li	a3,1
    52ec:	9e89                	subw	a3,a3,a0
    52ee:	00f6853b          	addw	a0,a3,a5
    52f2:	0785                	addi	a5,a5,1
    52f4:	fff7c703          	lbu	a4,-1(a5)
    52f8:	fb7d                	bnez	a4,52ee <strlen+0x14>
    ;
  return n;
}
    52fa:	6422                	ld	s0,8(sp)
    52fc:	0141                	addi	sp,sp,16
    52fe:	8082                	ret
  for(n = 0; s[n]; n++)
    5300:	4501                	li	a0,0
    5302:	bfe5                	j	52fa <strlen+0x20>

0000000000005304 <memset>:

void*
memset(void *dst, int c, uint n)
{
    5304:	1141                	addi	sp,sp,-16
    5306:	e422                	sd	s0,8(sp)
    5308:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    530a:	ce09                	beqz	a2,5324 <memset+0x20>
    530c:	87aa                	mv	a5,a0
    530e:	fff6071b          	addiw	a4,a2,-1
    5312:	1702                	slli	a4,a4,0x20
    5314:	9301                	srli	a4,a4,0x20
    5316:	0705                	addi	a4,a4,1
    5318:	972a                	add	a4,a4,a0
    cdst[i] = c;
    531a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    531e:	0785                	addi	a5,a5,1
    5320:	fee79de3          	bne	a5,a4,531a <memset+0x16>
  }
  return dst;
}
    5324:	6422                	ld	s0,8(sp)
    5326:	0141                	addi	sp,sp,16
    5328:	8082                	ret

000000000000532a <strchr>:

char*
strchr(const char *s, char c)
{
    532a:	1141                	addi	sp,sp,-16
    532c:	e422                	sd	s0,8(sp)
    532e:	0800                	addi	s0,sp,16
  for(; *s; s++)
    5330:	00054783          	lbu	a5,0(a0)
    5334:	cf91                	beqz	a5,5350 <strchr+0x26>
    if(*s == c)
    5336:	00f58a63          	beq	a1,a5,534a <strchr+0x20>
  for(; *s; s++)
    533a:	0505                	addi	a0,a0,1
    533c:	00054783          	lbu	a5,0(a0)
    5340:	c781                	beqz	a5,5348 <strchr+0x1e>
    if(*s == c)
    5342:	feb79ce3          	bne	a5,a1,533a <strchr+0x10>
    5346:	a011                	j	534a <strchr+0x20>
      return (char*)s;
  return 0;
    5348:	4501                	li	a0,0
}
    534a:	6422                	ld	s0,8(sp)
    534c:	0141                	addi	sp,sp,16
    534e:	8082                	ret
  return 0;
    5350:	4501                	li	a0,0
    5352:	bfe5                	j	534a <strchr+0x20>

0000000000005354 <gets>:

char*
gets(char *buf, int max)
{
    5354:	711d                	addi	sp,sp,-96
    5356:	ec86                	sd	ra,88(sp)
    5358:	e8a2                	sd	s0,80(sp)
    535a:	e4a6                	sd	s1,72(sp)
    535c:	e0ca                	sd	s2,64(sp)
    535e:	fc4e                	sd	s3,56(sp)
    5360:	f852                	sd	s4,48(sp)
    5362:	f456                	sd	s5,40(sp)
    5364:	f05a                	sd	s6,32(sp)
    5366:	ec5e                	sd	s7,24(sp)
    5368:	1080                	addi	s0,sp,96
    536a:	8baa                	mv	s7,a0
    536c:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
    536e:	892a                	mv	s2,a0
    5370:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
    5372:	4aa9                	li	s5,10
    5374:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
    5376:	0019849b          	addiw	s1,s3,1
    537a:	0344d863          	ble	s4,s1,53aa <gets+0x56>
    cc = read(0, &c, 1);
    537e:	4605                	li	a2,1
    5380:	faf40593          	addi	a1,s0,-81
    5384:	4501                	li	a0,0
    5386:	00000097          	auipc	ra,0x0
    538a:	1ac080e7          	jalr	428(ra) # 5532 <read>
    if(cc < 1)
    538e:	00a05e63          	blez	a0,53aa <gets+0x56>
    buf[i++] = c;
    5392:	faf44783          	lbu	a5,-81(s0)
    5396:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
    539a:	01578763          	beq	a5,s5,53a8 <gets+0x54>
    539e:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
    53a0:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
    53a2:	fd679ae3          	bne	a5,s6,5376 <gets+0x22>
    53a6:	a011                	j	53aa <gets+0x56>
  for(i=0; i+1 < max; ){
    53a8:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
    53aa:	99de                	add	s3,s3,s7
    53ac:	00098023          	sb	zero,0(s3)
  return buf;
}
    53b0:	855e                	mv	a0,s7
    53b2:	60e6                	ld	ra,88(sp)
    53b4:	6446                	ld	s0,80(sp)
    53b6:	64a6                	ld	s1,72(sp)
    53b8:	6906                	ld	s2,64(sp)
    53ba:	79e2                	ld	s3,56(sp)
    53bc:	7a42                	ld	s4,48(sp)
    53be:	7aa2                	ld	s5,40(sp)
    53c0:	7b02                	ld	s6,32(sp)
    53c2:	6be2                	ld	s7,24(sp)
    53c4:	6125                	addi	sp,sp,96
    53c6:	8082                	ret

00000000000053c8 <stat>:

int
stat(const char *n, struct stat *st)
{
    53c8:	1101                	addi	sp,sp,-32
    53ca:	ec06                	sd	ra,24(sp)
    53cc:	e822                	sd	s0,16(sp)
    53ce:	e426                	sd	s1,8(sp)
    53d0:	e04a                	sd	s2,0(sp)
    53d2:	1000                	addi	s0,sp,32
    53d4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
    53d6:	4581                	li	a1,0
    53d8:	00000097          	auipc	ra,0x0
    53dc:	182080e7          	jalr	386(ra) # 555a <open>
  if(fd < 0)
    53e0:	02054563          	bltz	a0,540a <stat+0x42>
    53e4:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
    53e6:	85ca                	mv	a1,s2
    53e8:	00000097          	auipc	ra,0x0
    53ec:	18a080e7          	jalr	394(ra) # 5572 <fstat>
    53f0:	892a                	mv	s2,a0
  close(fd);
    53f2:	8526                	mv	a0,s1
    53f4:	00000097          	auipc	ra,0x0
    53f8:	14e080e7          	jalr	334(ra) # 5542 <close>
  return r;
}
    53fc:	854a                	mv	a0,s2
    53fe:	60e2                	ld	ra,24(sp)
    5400:	6442                	ld	s0,16(sp)
    5402:	64a2                	ld	s1,8(sp)
    5404:	6902                	ld	s2,0(sp)
    5406:	6105                	addi	sp,sp,32
    5408:	8082                	ret
    return -1;
    540a:	597d                	li	s2,-1
    540c:	bfc5                	j	53fc <stat+0x34>

000000000000540e <atoi>:

int
atoi(const char *s)
{
    540e:	1141                	addi	sp,sp,-16
    5410:	e422                	sd	s0,8(sp)
    5412:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
    5414:	00054683          	lbu	a3,0(a0)
    5418:	fd06879b          	addiw	a5,a3,-48
    541c:	0ff7f793          	andi	a5,a5,255
    5420:	4725                	li	a4,9
    5422:	02f76963          	bltu	a4,a5,5454 <atoi+0x46>
    5426:	862a                	mv	a2,a0
  n = 0;
    5428:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
    542a:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
    542c:	0605                	addi	a2,a2,1
    542e:	0025179b          	slliw	a5,a0,0x2
    5432:	9fa9                	addw	a5,a5,a0
    5434:	0017979b          	slliw	a5,a5,0x1
    5438:	9fb5                	addw	a5,a5,a3
    543a:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
    543e:	00064683          	lbu	a3,0(a2) # 3000 <subdir+0xb4>
    5442:	fd06871b          	addiw	a4,a3,-48
    5446:	0ff77713          	andi	a4,a4,255
    544a:	fee5f1e3          	bleu	a4,a1,542c <atoi+0x1e>
  return n;
}
    544e:	6422                	ld	s0,8(sp)
    5450:	0141                	addi	sp,sp,16
    5452:	8082                	ret
  n = 0;
    5454:	4501                	li	a0,0
    5456:	bfe5                	j	544e <atoi+0x40>

0000000000005458 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
    5458:	1141                	addi	sp,sp,-16
    545a:	e422                	sd	s0,8(sp)
    545c:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
    545e:	02b57663          	bleu	a1,a0,548a <memmove+0x32>
    while(n-- > 0)
    5462:	02c05163          	blez	a2,5484 <memmove+0x2c>
    5466:	fff6079b          	addiw	a5,a2,-1
    546a:	1782                	slli	a5,a5,0x20
    546c:	9381                	srli	a5,a5,0x20
    546e:	0785                	addi	a5,a5,1
    5470:	97aa                	add	a5,a5,a0
  dst = vdst;
    5472:	872a                	mv	a4,a0
      *dst++ = *src++;
    5474:	0585                	addi	a1,a1,1
    5476:	0705                	addi	a4,a4,1
    5478:	fff5c683          	lbu	a3,-1(a1)
    547c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    5480:	fee79ae3          	bne	a5,a4,5474 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
    5484:	6422                	ld	s0,8(sp)
    5486:	0141                	addi	sp,sp,16
    5488:	8082                	ret
    dst += n;
    548a:	00c50733          	add	a4,a0,a2
    src += n;
    548e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
    5490:	fec05ae3          	blez	a2,5484 <memmove+0x2c>
    5494:	fff6079b          	addiw	a5,a2,-1
    5498:	1782                	slli	a5,a5,0x20
    549a:	9381                	srli	a5,a5,0x20
    549c:	fff7c793          	not	a5,a5
    54a0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
    54a2:	15fd                	addi	a1,a1,-1
    54a4:	177d                	addi	a4,a4,-1
    54a6:	0005c683          	lbu	a3,0(a1)
    54aa:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    54ae:	fef71ae3          	bne	a4,a5,54a2 <memmove+0x4a>
    54b2:	bfc9                	j	5484 <memmove+0x2c>

00000000000054b4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
    54b4:	1141                	addi	sp,sp,-16
    54b6:	e422                	sd	s0,8(sp)
    54b8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
    54ba:	ce15                	beqz	a2,54f6 <memcmp+0x42>
    54bc:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
    54c0:	00054783          	lbu	a5,0(a0)
    54c4:	0005c703          	lbu	a4,0(a1)
    54c8:	02e79063          	bne	a5,a4,54e8 <memcmp+0x34>
    54cc:	1682                	slli	a3,a3,0x20
    54ce:	9281                	srli	a3,a3,0x20
    54d0:	0685                	addi	a3,a3,1
    54d2:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
    54d4:	0505                	addi	a0,a0,1
    p2++;
    54d6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
    54d8:	00d50d63          	beq	a0,a3,54f2 <memcmp+0x3e>
    if (*p1 != *p2) {
    54dc:	00054783          	lbu	a5,0(a0)
    54e0:	0005c703          	lbu	a4,0(a1)
    54e4:	fee788e3          	beq	a5,a4,54d4 <memcmp+0x20>
      return *p1 - *p2;
    54e8:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
    54ec:	6422                	ld	s0,8(sp)
    54ee:	0141                	addi	sp,sp,16
    54f0:	8082                	ret
  return 0;
    54f2:	4501                	li	a0,0
    54f4:	bfe5                	j	54ec <memcmp+0x38>
    54f6:	4501                	li	a0,0
    54f8:	bfd5                	j	54ec <memcmp+0x38>

00000000000054fa <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
    54fa:	1141                	addi	sp,sp,-16
    54fc:	e406                	sd	ra,8(sp)
    54fe:	e022                	sd	s0,0(sp)
    5500:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    5502:	00000097          	auipc	ra,0x0
    5506:	f56080e7          	jalr	-170(ra) # 5458 <memmove>
}
    550a:	60a2                	ld	ra,8(sp)
    550c:	6402                	ld	s0,0(sp)
    550e:	0141                	addi	sp,sp,16
    5510:	8082                	ret

0000000000005512 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
    5512:	4885                	li	a7,1
 ecall
    5514:	00000073          	ecall
 ret
    5518:	8082                	ret

000000000000551a <exit>:
.global exit
exit:
 li a7, SYS_exit
    551a:	4889                	li	a7,2
 ecall
    551c:	00000073          	ecall
 ret
    5520:	8082                	ret

0000000000005522 <wait>:
.global wait
wait:
 li a7, SYS_wait
    5522:	488d                	li	a7,3
 ecall
    5524:	00000073          	ecall
 ret
    5528:	8082                	ret

000000000000552a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
    552a:	4891                	li	a7,4
 ecall
    552c:	00000073          	ecall
 ret
    5530:	8082                	ret

0000000000005532 <read>:
.global read
read:
 li a7, SYS_read
    5532:	4895                	li	a7,5
 ecall
    5534:	00000073          	ecall
 ret
    5538:	8082                	ret

000000000000553a <write>:
.global write
write:
 li a7, SYS_write
    553a:	48c1                	li	a7,16
 ecall
    553c:	00000073          	ecall
 ret
    5540:	8082                	ret

0000000000005542 <close>:
.global close
close:
 li a7, SYS_close
    5542:	48d5                	li	a7,21
 ecall
    5544:	00000073          	ecall
 ret
    5548:	8082                	ret

000000000000554a <kill>:
.global kill
kill:
 li a7, SYS_kill
    554a:	4899                	li	a7,6
 ecall
    554c:	00000073          	ecall
 ret
    5550:	8082                	ret

0000000000005552 <exec>:
.global exec
exec:
 li a7, SYS_exec
    5552:	489d                	li	a7,7
 ecall
    5554:	00000073          	ecall
 ret
    5558:	8082                	ret

000000000000555a <open>:
.global open
open:
 li a7, SYS_open
    555a:	48bd                	li	a7,15
 ecall
    555c:	00000073          	ecall
 ret
    5560:	8082                	ret

0000000000005562 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
    5562:	48c5                	li	a7,17
 ecall
    5564:	00000073          	ecall
 ret
    5568:	8082                	ret

000000000000556a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
    556a:	48c9                	li	a7,18
 ecall
    556c:	00000073          	ecall
 ret
    5570:	8082                	ret

0000000000005572 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
    5572:	48a1                	li	a7,8
 ecall
    5574:	00000073          	ecall
 ret
    5578:	8082                	ret

000000000000557a <link>:
.global link
link:
 li a7, SYS_link
    557a:	48cd                	li	a7,19
 ecall
    557c:	00000073          	ecall
 ret
    5580:	8082                	ret

0000000000005582 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
    5582:	48d1                	li	a7,20
 ecall
    5584:	00000073          	ecall
 ret
    5588:	8082                	ret

000000000000558a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
    558a:	48a5                	li	a7,9
 ecall
    558c:	00000073          	ecall
 ret
    5590:	8082                	ret

0000000000005592 <dup>:
.global dup
dup:
 li a7, SYS_dup
    5592:	48a9                	li	a7,10
 ecall
    5594:	00000073          	ecall
 ret
    5598:	8082                	ret

000000000000559a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
    559a:	48ad                	li	a7,11
 ecall
    559c:	00000073          	ecall
 ret
    55a0:	8082                	ret

00000000000055a2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
    55a2:	48b1                	li	a7,12
 ecall
    55a4:	00000073          	ecall
 ret
    55a8:	8082                	ret

00000000000055aa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
    55aa:	48b5                	li	a7,13
 ecall
    55ac:	00000073          	ecall
 ret
    55b0:	8082                	ret

00000000000055b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
    55b2:	48b9                	li	a7,14
 ecall
    55b4:	00000073          	ecall
 ret
    55b8:	8082                	ret

00000000000055ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
    55ba:	1101                	addi	sp,sp,-32
    55bc:	ec06                	sd	ra,24(sp)
    55be:	e822                	sd	s0,16(sp)
    55c0:	1000                	addi	s0,sp,32
    55c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
    55c6:	4605                	li	a2,1
    55c8:	fef40593          	addi	a1,s0,-17
    55cc:	00000097          	auipc	ra,0x0
    55d0:	f6e080e7          	jalr	-146(ra) # 553a <write>
}
    55d4:	60e2                	ld	ra,24(sp)
    55d6:	6442                	ld	s0,16(sp)
    55d8:	6105                	addi	sp,sp,32
    55da:	8082                	ret

00000000000055dc <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
    55dc:	7139                	addi	sp,sp,-64
    55de:	fc06                	sd	ra,56(sp)
    55e0:	f822                	sd	s0,48(sp)
    55e2:	f426                	sd	s1,40(sp)
    55e4:	f04a                	sd	s2,32(sp)
    55e6:	ec4e                	sd	s3,24(sp)
    55e8:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
    55ea:	c299                	beqz	a3,55f0 <printint+0x14>
    55ec:	0005cd63          	bltz	a1,5606 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
    55f0:	2581                	sext.w	a1,a1
  neg = 0;
    55f2:	4301                	li	t1,0
    55f4:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
    55f8:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
    55fa:	2601                	sext.w	a2,a2
    55fc:	00003897          	auipc	a7,0x3
    5600:	b2488893          	addi	a7,a7,-1244 # 8120 <digits>
    5604:	a801                	j	5614 <printint+0x38>
    x = -xx;
    5606:	40b005bb          	negw	a1,a1
    560a:	2581                	sext.w	a1,a1
    neg = 1;
    560c:	4305                	li	t1,1
    x = -xx;
    560e:	b7dd                	j	55f4 <printint+0x18>
  }while((x /= base) != 0);
    5610:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
    5612:	8836                	mv	a6,a3
    5614:	0018069b          	addiw	a3,a6,1
    5618:	02c5f7bb          	remuw	a5,a1,a2
    561c:	1782                	slli	a5,a5,0x20
    561e:	9381                	srli	a5,a5,0x20
    5620:	97c6                	add	a5,a5,a7
    5622:	0007c783          	lbu	a5,0(a5)
    5626:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
    562a:	0705                	addi	a4,a4,1
    562c:	02c5d7bb          	divuw	a5,a1,a2
    5630:	fec5f0e3          	bleu	a2,a1,5610 <printint+0x34>
  if(neg)
    5634:	00030b63          	beqz	t1,564a <printint+0x6e>
    buf[i++] = '-';
    5638:	fd040793          	addi	a5,s0,-48
    563c:	96be                	add	a3,a3,a5
    563e:	02d00793          	li	a5,45
    5642:	fef68823          	sb	a5,-16(a3) # ff0 <bigdir+0x68>
    5646:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
    564a:	02d05963          	blez	a3,567c <printint+0xa0>
    564e:	89aa                	mv	s3,a0
    5650:	fc040793          	addi	a5,s0,-64
    5654:	00d784b3          	add	s1,a5,a3
    5658:	fff78913          	addi	s2,a5,-1
    565c:	9936                	add	s2,s2,a3
    565e:	36fd                	addiw	a3,a3,-1
    5660:	1682                	slli	a3,a3,0x20
    5662:	9281                	srli	a3,a3,0x20
    5664:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
    5668:	fff4c583          	lbu	a1,-1(s1)
    566c:	854e                	mv	a0,s3
    566e:	00000097          	auipc	ra,0x0
    5672:	f4c080e7          	jalr	-180(ra) # 55ba <putc>
  while(--i >= 0)
    5676:	14fd                	addi	s1,s1,-1
    5678:	ff2498e3          	bne	s1,s2,5668 <printint+0x8c>
}
    567c:	70e2                	ld	ra,56(sp)
    567e:	7442                	ld	s0,48(sp)
    5680:	74a2                	ld	s1,40(sp)
    5682:	7902                	ld	s2,32(sp)
    5684:	69e2                	ld	s3,24(sp)
    5686:	6121                	addi	sp,sp,64
    5688:	8082                	ret

000000000000568a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
    568a:	7119                	addi	sp,sp,-128
    568c:	fc86                	sd	ra,120(sp)
    568e:	f8a2                	sd	s0,112(sp)
    5690:	f4a6                	sd	s1,104(sp)
    5692:	f0ca                	sd	s2,96(sp)
    5694:	ecce                	sd	s3,88(sp)
    5696:	e8d2                	sd	s4,80(sp)
    5698:	e4d6                	sd	s5,72(sp)
    569a:	e0da                	sd	s6,64(sp)
    569c:	fc5e                	sd	s7,56(sp)
    569e:	f862                	sd	s8,48(sp)
    56a0:	f466                	sd	s9,40(sp)
    56a2:	f06a                	sd	s10,32(sp)
    56a4:	ec6e                	sd	s11,24(sp)
    56a6:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
    56a8:	0005c483          	lbu	s1,0(a1)
    56ac:	18048d63          	beqz	s1,5846 <vprintf+0x1bc>
    56b0:	8aaa                	mv	s5,a0
    56b2:	8b32                	mv	s6,a2
    56b4:	00158913          	addi	s2,a1,1
  state = 0;
    56b8:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
    56ba:	02500a13          	li	s4,37
      if(c == 'd'){
    56be:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
    56c2:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
    56c6:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
    56ca:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    56ce:	00003b97          	auipc	s7,0x3
    56d2:	a52b8b93          	addi	s7,s7,-1454 # 8120 <digits>
    56d6:	a839                	j	56f4 <vprintf+0x6a>
        putc(fd, c);
    56d8:	85a6                	mv	a1,s1
    56da:	8556                	mv	a0,s5
    56dc:	00000097          	auipc	ra,0x0
    56e0:	ede080e7          	jalr	-290(ra) # 55ba <putc>
    56e4:	a019                	j	56ea <vprintf+0x60>
    } else if(state == '%'){
    56e6:	01498f63          	beq	s3,s4,5704 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
    56ea:	0905                	addi	s2,s2,1
    56ec:	fff94483          	lbu	s1,-1(s2)
    56f0:	14048b63          	beqz	s1,5846 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
    56f4:	0004879b          	sext.w	a5,s1
    if(state == 0){
    56f8:	fe0997e3          	bnez	s3,56e6 <vprintf+0x5c>
      if(c == '%'){
    56fc:	fd479ee3          	bne	a5,s4,56d8 <vprintf+0x4e>
        state = '%';
    5700:	89be                	mv	s3,a5
    5702:	b7e5                	j	56ea <vprintf+0x60>
      if(c == 'd'){
    5704:	05878063          	beq	a5,s8,5744 <vprintf+0xba>
      } else if(c == 'l') {
    5708:	05978c63          	beq	a5,s9,5760 <vprintf+0xd6>
      } else if(c == 'x') {
    570c:	07a78863          	beq	a5,s10,577c <vprintf+0xf2>
      } else if(c == 'p') {
    5710:	09b78463          	beq	a5,s11,5798 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
    5714:	07300713          	li	a4,115
    5718:	0ce78563          	beq	a5,a4,57e2 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
    571c:	06300713          	li	a4,99
    5720:	0ee78c63          	beq	a5,a4,5818 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
    5724:	11478663          	beq	a5,s4,5830 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
    5728:	85d2                	mv	a1,s4
    572a:	8556                	mv	a0,s5
    572c:	00000097          	auipc	ra,0x0
    5730:	e8e080e7          	jalr	-370(ra) # 55ba <putc>
        putc(fd, c);
    5734:	85a6                	mv	a1,s1
    5736:	8556                	mv	a0,s5
    5738:	00000097          	auipc	ra,0x0
    573c:	e82080e7          	jalr	-382(ra) # 55ba <putc>
      }
      state = 0;
    5740:	4981                	li	s3,0
    5742:	b765                	j	56ea <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
    5744:	008b0493          	addi	s1,s6,8
    5748:	4685                	li	a3,1
    574a:	4629                	li	a2,10
    574c:	000b2583          	lw	a1,0(s6)
    5750:	8556                	mv	a0,s5
    5752:	00000097          	auipc	ra,0x0
    5756:	e8a080e7          	jalr	-374(ra) # 55dc <printint>
    575a:	8b26                	mv	s6,s1
      state = 0;
    575c:	4981                	li	s3,0
    575e:	b771                	j	56ea <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
    5760:	008b0493          	addi	s1,s6,8
    5764:	4681                	li	a3,0
    5766:	4629                	li	a2,10
    5768:	000b2583          	lw	a1,0(s6)
    576c:	8556                	mv	a0,s5
    576e:	00000097          	auipc	ra,0x0
    5772:	e6e080e7          	jalr	-402(ra) # 55dc <printint>
    5776:	8b26                	mv	s6,s1
      state = 0;
    5778:	4981                	li	s3,0
    577a:	bf85                	j	56ea <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
    577c:	008b0493          	addi	s1,s6,8
    5780:	4681                	li	a3,0
    5782:	4641                	li	a2,16
    5784:	000b2583          	lw	a1,0(s6)
    5788:	8556                	mv	a0,s5
    578a:	00000097          	auipc	ra,0x0
    578e:	e52080e7          	jalr	-430(ra) # 55dc <printint>
    5792:	8b26                	mv	s6,s1
      state = 0;
    5794:	4981                	li	s3,0
    5796:	bf91                	j	56ea <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
    5798:	008b0793          	addi	a5,s6,8
    579c:	f8f43423          	sd	a5,-120(s0)
    57a0:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
    57a4:	03000593          	li	a1,48
    57a8:	8556                	mv	a0,s5
    57aa:	00000097          	auipc	ra,0x0
    57ae:	e10080e7          	jalr	-496(ra) # 55ba <putc>
  putc(fd, 'x');
    57b2:	85ea                	mv	a1,s10
    57b4:	8556                	mv	a0,s5
    57b6:	00000097          	auipc	ra,0x0
    57ba:	e04080e7          	jalr	-508(ra) # 55ba <putc>
    57be:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
    57c0:	03c9d793          	srli	a5,s3,0x3c
    57c4:	97de                	add	a5,a5,s7
    57c6:	0007c583          	lbu	a1,0(a5)
    57ca:	8556                	mv	a0,s5
    57cc:	00000097          	auipc	ra,0x0
    57d0:	dee080e7          	jalr	-530(ra) # 55ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    57d4:	0992                	slli	s3,s3,0x4
    57d6:	34fd                	addiw	s1,s1,-1
    57d8:	f4e5                	bnez	s1,57c0 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
    57da:	f8843b03          	ld	s6,-120(s0)
      state = 0;
    57de:	4981                	li	s3,0
    57e0:	b729                	j	56ea <vprintf+0x60>
        s = va_arg(ap, char*);
    57e2:	008b0993          	addi	s3,s6,8
    57e6:	000b3483          	ld	s1,0(s6)
        if(s == 0)
    57ea:	c085                	beqz	s1,580a <vprintf+0x180>
        while(*s != 0){
    57ec:	0004c583          	lbu	a1,0(s1)
    57f0:	c9a1                	beqz	a1,5840 <vprintf+0x1b6>
          putc(fd, *s);
    57f2:	8556                	mv	a0,s5
    57f4:	00000097          	auipc	ra,0x0
    57f8:	dc6080e7          	jalr	-570(ra) # 55ba <putc>
          s++;
    57fc:	0485                	addi	s1,s1,1
        while(*s != 0){
    57fe:	0004c583          	lbu	a1,0(s1)
    5802:	f9e5                	bnez	a1,57f2 <vprintf+0x168>
        s = va_arg(ap, char*);
    5804:	8b4e                	mv	s6,s3
      state = 0;
    5806:	4981                	li	s3,0
    5808:	b5cd                	j	56ea <vprintf+0x60>
          s = "(null)";
    580a:	00003497          	auipc	s1,0x3
    580e:	92e48493          	addi	s1,s1,-1746 # 8138 <digits+0x18>
        while(*s != 0){
    5812:	02800593          	li	a1,40
    5816:	bff1                	j	57f2 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
    5818:	008b0493          	addi	s1,s6,8
    581c:	000b4583          	lbu	a1,0(s6)
    5820:	8556                	mv	a0,s5
    5822:	00000097          	auipc	ra,0x0
    5826:	d98080e7          	jalr	-616(ra) # 55ba <putc>
    582a:	8b26                	mv	s6,s1
      state = 0;
    582c:	4981                	li	s3,0
    582e:	bd75                	j	56ea <vprintf+0x60>
        putc(fd, c);
    5830:	85d2                	mv	a1,s4
    5832:	8556                	mv	a0,s5
    5834:	00000097          	auipc	ra,0x0
    5838:	d86080e7          	jalr	-634(ra) # 55ba <putc>
      state = 0;
    583c:	4981                	li	s3,0
    583e:	b575                	j	56ea <vprintf+0x60>
        s = va_arg(ap, char*);
    5840:	8b4e                	mv	s6,s3
      state = 0;
    5842:	4981                	li	s3,0
    5844:	b55d                	j	56ea <vprintf+0x60>
    }
  }
}
    5846:	70e6                	ld	ra,120(sp)
    5848:	7446                	ld	s0,112(sp)
    584a:	74a6                	ld	s1,104(sp)
    584c:	7906                	ld	s2,96(sp)
    584e:	69e6                	ld	s3,88(sp)
    5850:	6a46                	ld	s4,80(sp)
    5852:	6aa6                	ld	s5,72(sp)
    5854:	6b06                	ld	s6,64(sp)
    5856:	7be2                	ld	s7,56(sp)
    5858:	7c42                	ld	s8,48(sp)
    585a:	7ca2                	ld	s9,40(sp)
    585c:	7d02                	ld	s10,32(sp)
    585e:	6de2                	ld	s11,24(sp)
    5860:	6109                	addi	sp,sp,128
    5862:	8082                	ret

0000000000005864 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
    5864:	715d                	addi	sp,sp,-80
    5866:	ec06                	sd	ra,24(sp)
    5868:	e822                	sd	s0,16(sp)
    586a:	1000                	addi	s0,sp,32
    586c:	e010                	sd	a2,0(s0)
    586e:	e414                	sd	a3,8(s0)
    5870:	e818                	sd	a4,16(s0)
    5872:	ec1c                	sd	a5,24(s0)
    5874:	03043023          	sd	a6,32(s0)
    5878:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
    587c:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
    5880:	8622                	mv	a2,s0
    5882:	00000097          	auipc	ra,0x0
    5886:	e08080e7          	jalr	-504(ra) # 568a <vprintf>
}
    588a:	60e2                	ld	ra,24(sp)
    588c:	6442                	ld	s0,16(sp)
    588e:	6161                	addi	sp,sp,80
    5890:	8082                	ret

0000000000005892 <printf>:

void
printf(const char *fmt, ...)
{
    5892:	711d                	addi	sp,sp,-96
    5894:	ec06                	sd	ra,24(sp)
    5896:	e822                	sd	s0,16(sp)
    5898:	1000                	addi	s0,sp,32
    589a:	e40c                	sd	a1,8(s0)
    589c:	e810                	sd	a2,16(s0)
    589e:	ec14                	sd	a3,24(s0)
    58a0:	f018                	sd	a4,32(s0)
    58a2:	f41c                	sd	a5,40(s0)
    58a4:	03043823          	sd	a6,48(s0)
    58a8:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
    58ac:	00840613          	addi	a2,s0,8
    58b0:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
    58b4:	85aa                	mv	a1,a0
    58b6:	4505                	li	a0,1
    58b8:	00000097          	auipc	ra,0x0
    58bc:	dd2080e7          	jalr	-558(ra) # 568a <vprintf>
}
    58c0:	60e2                	ld	ra,24(sp)
    58c2:	6442                	ld	s0,16(sp)
    58c4:	6125                	addi	sp,sp,96
    58c6:	8082                	ret

00000000000058c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
    58c8:	1141                	addi	sp,sp,-16
    58ca:	e422                	sd	s0,8(sp)
    58cc:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
    58ce:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    58d2:	00003797          	auipc	a5,0x3
    58d6:	88678793          	addi	a5,a5,-1914 # 8158 <freep>
    58da:	639c                	ld	a5,0(a5)
    58dc:	a805                	j	590c <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
    58de:	4618                	lw	a4,8(a2)
    58e0:	9db9                	addw	a1,a1,a4
    58e2:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
    58e6:	6398                	ld	a4,0(a5)
    58e8:	6318                	ld	a4,0(a4)
    58ea:	fee53823          	sd	a4,-16(a0)
    58ee:	a091                	j	5932 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
    58f0:	ff852703          	lw	a4,-8(a0)
    58f4:	9e39                	addw	a2,a2,a4
    58f6:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
    58f8:	ff053703          	ld	a4,-16(a0)
    58fc:	e398                	sd	a4,0(a5)
    58fe:	a099                	j	5944 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5900:	6398                	ld	a4,0(a5)
    5902:	00e7e463          	bltu	a5,a4,590a <free+0x42>
    5906:	00e6ea63          	bltu	a3,a4,591a <free+0x52>
{
    590a:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
    590c:	fed7fae3          	bleu	a3,a5,5900 <free+0x38>
    5910:	6398                	ld	a4,0(a5)
    5912:	00e6e463          	bltu	a3,a4,591a <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
    5916:	fee7eae3          	bltu	a5,a4,590a <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
    591a:	ff852583          	lw	a1,-8(a0)
    591e:	6390                	ld	a2,0(a5)
    5920:	02059713          	slli	a4,a1,0x20
    5924:	9301                	srli	a4,a4,0x20
    5926:	0712                	slli	a4,a4,0x4
    5928:	9736                	add	a4,a4,a3
    592a:	fae60ae3          	beq	a2,a4,58de <free+0x16>
    bp->s.ptr = p->s.ptr;
    592e:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
    5932:	4790                	lw	a2,8(a5)
    5934:	02061713          	slli	a4,a2,0x20
    5938:	9301                	srli	a4,a4,0x20
    593a:	0712                	slli	a4,a4,0x4
    593c:	973e                	add	a4,a4,a5
    593e:	fae689e3          	beq	a3,a4,58f0 <free+0x28>
  } else
    p->s.ptr = bp;
    5942:	e394                	sd	a3,0(a5)
  freep = p;
    5944:	00003717          	auipc	a4,0x3
    5948:	80f73a23          	sd	a5,-2028(a4) # 8158 <freep>
}
    594c:	6422                	ld	s0,8(sp)
    594e:	0141                	addi	sp,sp,16
    5950:	8082                	ret

0000000000005952 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    5952:	7139                	addi	sp,sp,-64
    5954:	fc06                	sd	ra,56(sp)
    5956:	f822                	sd	s0,48(sp)
    5958:	f426                	sd	s1,40(sp)
    595a:	f04a                	sd	s2,32(sp)
    595c:	ec4e                	sd	s3,24(sp)
    595e:	e852                	sd	s4,16(sp)
    5960:	e456                	sd	s5,8(sp)
    5962:	e05a                	sd	s6,0(sp)
    5964:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    5966:	02051993          	slli	s3,a0,0x20
    596a:	0209d993          	srli	s3,s3,0x20
    596e:	09bd                	addi	s3,s3,15
    5970:	0049d993          	srli	s3,s3,0x4
    5974:	2985                	addiw	s3,s3,1
    5976:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
    597a:	00002797          	auipc	a5,0x2
    597e:	7de78793          	addi	a5,a5,2014 # 8158 <freep>
    5982:	6388                	ld	a0,0(a5)
    5984:	c515                	beqz	a0,59b0 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5986:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5988:	4798                	lw	a4,8(a5)
    598a:	03277f63          	bleu	s2,a4,59c8 <malloc+0x76>
    598e:	8a4e                	mv	s4,s3
    5990:	0009871b          	sext.w	a4,s3
    5994:	6685                	lui	a3,0x1
    5996:	00d77363          	bleu	a3,a4,599c <malloc+0x4a>
    599a:	6a05                	lui	s4,0x1
    599c:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
    59a0:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    59a4:	00002497          	auipc	s1,0x2
    59a8:	7b448493          	addi	s1,s1,1972 # 8158 <freep>
  if(p == (char*)-1)
    59ac:	5b7d                	li	s6,-1
    59ae:	a885                	j	5a1e <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
    59b0:	00009797          	auipc	a5,0x9
    59b4:	fc878793          	addi	a5,a5,-56 # e978 <base>
    59b8:	00002717          	auipc	a4,0x2
    59bc:	7af73023          	sd	a5,1952(a4) # 8158 <freep>
    59c0:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    59c2:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    59c6:	b7e1                	j	598e <malloc+0x3c>
      if(p->s.size == nunits)
    59c8:	02e90b63          	beq	s2,a4,59fe <malloc+0xac>
        p->s.size -= nunits;
    59cc:	4137073b          	subw	a4,a4,s3
    59d0:	c798                	sw	a4,8(a5)
        p += p->s.size;
    59d2:	1702                	slli	a4,a4,0x20
    59d4:	9301                	srli	a4,a4,0x20
    59d6:	0712                	slli	a4,a4,0x4
    59d8:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    59da:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    59de:	00002717          	auipc	a4,0x2
    59e2:	76a73d23          	sd	a0,1914(a4) # 8158 <freep>
      return (void*)(p + 1);
    59e6:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    59ea:	70e2                	ld	ra,56(sp)
    59ec:	7442                	ld	s0,48(sp)
    59ee:	74a2                	ld	s1,40(sp)
    59f0:	7902                	ld	s2,32(sp)
    59f2:	69e2                	ld	s3,24(sp)
    59f4:	6a42                	ld	s4,16(sp)
    59f6:	6aa2                	ld	s5,8(sp)
    59f8:	6b02                	ld	s6,0(sp)
    59fa:	6121                	addi	sp,sp,64
    59fc:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    59fe:	6398                	ld	a4,0(a5)
    5a00:	e118                	sd	a4,0(a0)
    5a02:	bff1                	j	59de <malloc+0x8c>
  hp->s.size = nu;
    5a04:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
    5a08:	0541                	addi	a0,a0,16
    5a0a:	00000097          	auipc	ra,0x0
    5a0e:	ebe080e7          	jalr	-322(ra) # 58c8 <free>
  return freep;
    5a12:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    5a14:	d979                	beqz	a0,59ea <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    5a16:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    5a18:	4798                	lw	a4,8(a5)
    5a1a:	fb2777e3          	bleu	s2,a4,59c8 <malloc+0x76>
    if(p == freep)
    5a1e:	6098                	ld	a4,0(s1)
    5a20:	853e                	mv	a0,a5
    5a22:	fef71ae3          	bne	a4,a5,5a16 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
    5a26:	8552                	mv	a0,s4
    5a28:	00000097          	auipc	ra,0x0
    5a2c:	b7a080e7          	jalr	-1158(ra) # 55a2 <sbrk>
  if(p == (char*)-1)
    5a30:	fd651ae3          	bne	a0,s6,5a04 <malloc+0xb2>
        return 0;
    5a34:	4501                	li	a0,0
    5a36:	bf55                	j	59ea <malloc+0x98>
