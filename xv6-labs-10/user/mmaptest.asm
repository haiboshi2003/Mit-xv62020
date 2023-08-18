
user/_mmaptest：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <err>:

char *testname = "???";

void
err(char *why)
{
       0:	1101                	addi	sp,sp,-32
       2:	ec06                	sd	ra,24(sp)
       4:	e822                	sd	s0,16(sp)
       6:	e426                	sd	s1,8(sp)
       8:	e04a                	sd	s2,0(sp)
       a:	1000                	addi	s0,sp,32
       c:	892a                	mv	s2,a0
  printf("mmaptest: %s failed: %s, pid=%d\n", testname, why, getpid());
       e:	00001797          	auipc	a5,0x1
      12:	5b278793          	addi	a5,a5,1458 # 15c0 <testname>
      16:	6384                	ld	s1,0(a5)
      18:	00001097          	auipc	ra,0x1
      1c:	c2a080e7          	jalr	-982(ra) # c42 <getpid>
      20:	86aa                	mv	a3,a0
      22:	864a                	mv	a2,s2
      24:	85a6                	mv	a1,s1
      26:	00001517          	auipc	a0,0x1
      2a:	0ca50513          	addi	a0,a0,202 # 10f0 <malloc+0xe6>
      2e:	00001097          	auipc	ra,0x1
      32:	f1c080e7          	jalr	-228(ra) # f4a <printf>
  exit(1);
      36:	4505                	li	a0,1
      38:	00001097          	auipc	ra,0x1
      3c:	b8a080e7          	jalr	-1142(ra) # bc2 <exit>

0000000000000040 <_v1>:
//
// check the content of the two mapped pages.
//
void
_v1(char *p)
{
      40:	1141                	addi	sp,sp,-16
      42:	e406                	sd	ra,8(sp)
      44:	e022                	sd	s0,0(sp)
      46:	0800                	addi	s0,sp,16
      48:	4781                	li	a5,0
  int i;
  for (i = 0; i < PGSIZE*2; i++) {
    if (i < PGSIZE + (PGSIZE/2)) {
      4a:	6685                	lui	a3,0x1
      4c:	7ff68693          	addi	a3,a3,2047 # 17ff <buf+0x22f>
  for (i = 0; i < PGSIZE*2; i++) {
      50:	6889                	lui	a7,0x2
      if (p[i] != 'A') {
      52:	04100813          	li	a6,65
      56:	a811                	j	6a <_v1+0x2a>
        printf("mismatch at %d, wanted 'A', got 0x%x\n", i, p[i]);
        err("v1 mismatch (1)");
      }
    } else {
      if (p[i] != 0) {
      58:	00f50633          	add	a2,a0,a5
      5c:	00064603          	lbu	a2,0(a2)
      60:	e221                	bnez	a2,a0 <_v1+0x60>
  for (i = 0; i < PGSIZE*2; i++) {
      62:	2705                	addiw	a4,a4,1
      64:	05175e63          	ble	a7,a4,c0 <_v1+0x80>
      68:	0785                	addi	a5,a5,1
      6a:	0007871b          	sext.w	a4,a5
      6e:	85ba                	mv	a1,a4
    if (i < PGSIZE + (PGSIZE/2)) {
      70:	fee6c4e3          	blt	a3,a4,58 <_v1+0x18>
      if (p[i] != 'A') {
      74:	00f50733          	add	a4,a0,a5
      78:	00074603          	lbu	a2,0(a4)
      7c:	ff0606e3          	beq	a2,a6,68 <_v1+0x28>
        printf("mismatch at %d, wanted 'A', got 0x%x\n", i, p[i]);
      80:	00001517          	auipc	a0,0x1
      84:	09850513          	addi	a0,a0,152 # 1118 <malloc+0x10e>
      88:	00001097          	auipc	ra,0x1
      8c:	ec2080e7          	jalr	-318(ra) # f4a <printf>
        err("v1 mismatch (1)");
      90:	00001517          	auipc	a0,0x1
      94:	0b050513          	addi	a0,a0,176 # 1140 <malloc+0x136>
      98:	00000097          	auipc	ra,0x0
      9c:	f68080e7          	jalr	-152(ra) # 0 <err>
        printf("mismatch at %d, wanted zero, got 0x%x\n", i, p[i]);
      a0:	00001517          	auipc	a0,0x1
      a4:	0b050513          	addi	a0,a0,176 # 1150 <malloc+0x146>
      a8:	00001097          	auipc	ra,0x1
      ac:	ea2080e7          	jalr	-350(ra) # f4a <printf>
        err("v1 mismatch (2)");
      b0:	00001517          	auipc	a0,0x1
      b4:	0c850513          	addi	a0,a0,200 # 1178 <malloc+0x16e>
      b8:	00000097          	auipc	ra,0x0
      bc:	f48080e7          	jalr	-184(ra) # 0 <err>
      }
    }
  }
}
      c0:	60a2                	ld	ra,8(sp)
      c2:	6402                	ld	s0,0(sp)
      c4:	0141                	addi	sp,sp,16
      c6:	8082                	ret

00000000000000c8 <makefile>:
// create a file to be mapped, containing
// 1.5 pages of 'A' and half a page of zeros.
//
void
makefile(const char *f)
{
      c8:	7179                	addi	sp,sp,-48
      ca:	f406                	sd	ra,40(sp)
      cc:	f022                	sd	s0,32(sp)
      ce:	ec26                	sd	s1,24(sp)
      d0:	e84a                	sd	s2,16(sp)
      d2:	e44e                	sd	s3,8(sp)
      d4:	1800                	addi	s0,sp,48
      d6:	84aa                	mv	s1,a0
  int i;
  int n = PGSIZE/BSIZE;

  unlink(f);
      d8:	00001097          	auipc	ra,0x1
      dc:	b3a080e7          	jalr	-1222(ra) # c12 <unlink>
  int fd = open(f, O_WRONLY | O_CREATE);
      e0:	20100593          	li	a1,513
      e4:	8526                	mv	a0,s1
      e6:	00001097          	auipc	ra,0x1
      ea:	b1c080e7          	jalr	-1252(ra) # c02 <open>
  if (fd == -1)
      ee:	57fd                	li	a5,-1
      f0:	06f50163          	beq	a0,a5,152 <makefile+0x8a>
      f4:	892a                	mv	s2,a0
    err("open");
  memset(buf, 'A', BSIZE);
      f6:	40000613          	li	a2,1024
      fa:	04100593          	li	a1,65
      fe:	00001517          	auipc	a0,0x1
     102:	4d250513          	addi	a0,a0,1234 # 15d0 <buf>
     106:	00001097          	auipc	ra,0x1
     10a:	8a6080e7          	jalr	-1882(ra) # 9ac <memset>
     10e:	4499                	li	s1,6
  // write 1.5 page
  for (i = 0; i < n + n/2; i++) {
    if (write(fd, buf, BSIZE) != BSIZE)
     110:	00001997          	auipc	s3,0x1
     114:	4c098993          	addi	s3,s3,1216 # 15d0 <buf>
     118:	40000613          	li	a2,1024
     11c:	85ce                	mv	a1,s3
     11e:	854a                	mv	a0,s2
     120:	00001097          	auipc	ra,0x1
     124:	ac2080e7          	jalr	-1342(ra) # be2 <write>
     128:	40000793          	li	a5,1024
     12c:	02f51b63          	bne	a0,a5,162 <makefile+0x9a>
  for (i = 0; i < n + n/2; i++) {
     130:	34fd                	addiw	s1,s1,-1
     132:	f0fd                	bnez	s1,118 <makefile+0x50>
      err("write 0 makefile");
  }
  if (close(fd) == -1)
     134:	854a                	mv	a0,s2
     136:	00001097          	auipc	ra,0x1
     13a:	ab4080e7          	jalr	-1356(ra) # bea <close>
     13e:	57fd                	li	a5,-1
     140:	02f50963          	beq	a0,a5,172 <makefile+0xaa>
    err("close");
}
     144:	70a2                	ld	ra,40(sp)
     146:	7402                	ld	s0,32(sp)
     148:	64e2                	ld	s1,24(sp)
     14a:	6942                	ld	s2,16(sp)
     14c:	69a2                	ld	s3,8(sp)
     14e:	6145                	addi	sp,sp,48
     150:	8082                	ret
    err("open");
     152:	00001517          	auipc	a0,0x1
     156:	03650513          	addi	a0,a0,54 # 1188 <malloc+0x17e>
     15a:	00000097          	auipc	ra,0x0
     15e:	ea6080e7          	jalr	-346(ra) # 0 <err>
      err("write 0 makefile");
     162:	00001517          	auipc	a0,0x1
     166:	02e50513          	addi	a0,a0,46 # 1190 <malloc+0x186>
     16a:	00000097          	auipc	ra,0x0
     16e:	e96080e7          	jalr	-362(ra) # 0 <err>
    err("close");
     172:	00001517          	auipc	a0,0x1
     176:	03650513          	addi	a0,a0,54 # 11a8 <malloc+0x19e>
     17a:	00000097          	auipc	ra,0x0
     17e:	e86080e7          	jalr	-378(ra) # 0 <err>

0000000000000182 <mmap_test>:

void
mmap_test(void)
{
     182:	7139                	addi	sp,sp,-64
     184:	fc06                	sd	ra,56(sp)
     186:	f822                	sd	s0,48(sp)
     188:	f426                	sd	s1,40(sp)
     18a:	f04a                	sd	s2,32(sp)
     18c:	ec4e                	sd	s3,24(sp)
     18e:	e852                	sd	s4,16(sp)
     190:	0080                	addi	s0,sp,64
  int fd;
  int i;
  const char * const f = "mmap.dur";
  printf("mmap_test starting\n");
     192:	00001517          	auipc	a0,0x1
     196:	01e50513          	addi	a0,a0,30 # 11b0 <malloc+0x1a6>
     19a:	00001097          	auipc	ra,0x1
     19e:	db0080e7          	jalr	-592(ra) # f4a <printf>
  testname = "mmap_test";
     1a2:	00001797          	auipc	a5,0x1
     1a6:	02678793          	addi	a5,a5,38 # 11c8 <malloc+0x1be>
     1aa:	00001717          	auipc	a4,0x1
     1ae:	40f73b23          	sd	a5,1046(a4) # 15c0 <testname>
  //
  // create a file with known content, map it into memory, check that
  // the mapped memory has the same bytes as originally written to the
  // file.
  //
  makefile(f);
     1b2:	00001517          	auipc	a0,0x1
     1b6:	02650513          	addi	a0,a0,38 # 11d8 <malloc+0x1ce>
     1ba:	00000097          	auipc	ra,0x0
     1be:	f0e080e7          	jalr	-242(ra) # c8 <makefile>
  if ((fd = open(f, O_RDONLY)) == -1)
     1c2:	4581                	li	a1,0
     1c4:	00001517          	auipc	a0,0x1
     1c8:	01450513          	addi	a0,a0,20 # 11d8 <malloc+0x1ce>
     1cc:	00001097          	auipc	ra,0x1
     1d0:	a36080e7          	jalr	-1482(ra) # c02 <open>
     1d4:	57fd                	li	a5,-1
     1d6:	3ef50663          	beq	a0,a5,5c2 <mmap_test+0x440>
     1da:	892a                	mv	s2,a0
    err("open");

  printf("test mmap f\n");
     1dc:	00001517          	auipc	a0,0x1
     1e0:	00c50513          	addi	a0,a0,12 # 11e8 <malloc+0x1de>
     1e4:	00001097          	auipc	ra,0x1
     1e8:	d66080e7          	jalr	-666(ra) # f4a <printf>
  // same file (of course in this case updates are prohibited
  // due to PROT_READ). the fifth argument is the file descriptor
  // of the file to be mapped. the last argument is the starting
  // offset in the file.
  //
  char *p = mmap(0, PGSIZE*2, PROT_READ, MAP_PRIVATE, fd, 0);
     1ec:	4781                	li	a5,0
     1ee:	874a                	mv	a4,s2
     1f0:	4689                	li	a3,2
     1f2:	4605                	li	a2,1
     1f4:	6589                	lui	a1,0x2
     1f6:	4501                	li	a0,0
     1f8:	00001097          	auipc	ra,0x1
     1fc:	a6a080e7          	jalr	-1430(ra) # c62 <mmap>
     200:	84aa                	mv	s1,a0
  if (p == MAP_FAILED)
     202:	57fd                	li	a5,-1
     204:	3cf50763          	beq	a0,a5,5d2 <mmap_test+0x450>
    err("mmap (1)");
  _v1(p);
     208:	00000097          	auipc	ra,0x0
     20c:	e38080e7          	jalr	-456(ra) # 40 <_v1>
  if (munmap(p, PGSIZE*2) == -1)
     210:	6589                	lui	a1,0x2
     212:	8526                	mv	a0,s1
     214:	00001097          	auipc	ra,0x1
     218:	a56080e7          	jalr	-1450(ra) # c6a <munmap>
     21c:	57fd                	li	a5,-1
     21e:	3cf50263          	beq	a0,a5,5e2 <mmap_test+0x460>
    err("munmap (1)");

  printf("test mmap f: OK\n");
     222:	00001517          	auipc	a0,0x1
     226:	ff650513          	addi	a0,a0,-10 # 1218 <malloc+0x20e>
     22a:	00001097          	auipc	ra,0x1
     22e:	d20080e7          	jalr	-736(ra) # f4a <printf>
    
  printf("test mmap private\n");
     232:	00001517          	auipc	a0,0x1
     236:	ffe50513          	addi	a0,a0,-2 # 1230 <malloc+0x226>
     23a:	00001097          	auipc	ra,0x1
     23e:	d10080e7          	jalr	-752(ra) # f4a <printf>
  // should be able to map file opened read-only with private writable
  // mapping
  p = mmap(0, PGSIZE*2, PROT_READ | PROT_WRITE, MAP_PRIVATE, fd, 0);
     242:	4781                	li	a5,0
     244:	874a                	mv	a4,s2
     246:	4689                	li	a3,2
     248:	460d                	li	a2,3
     24a:	6589                	lui	a1,0x2
     24c:	4501                	li	a0,0
     24e:	00001097          	auipc	ra,0x1
     252:	a14080e7          	jalr	-1516(ra) # c62 <mmap>
     256:	84aa                	mv	s1,a0
  if (p == MAP_FAILED)
     258:	57fd                	li	a5,-1
     25a:	38f50c63          	beq	a0,a5,5f2 <mmap_test+0x470>
    err("mmap (2)");
  if (close(fd) == -1)
     25e:	854a                	mv	a0,s2
     260:	00001097          	auipc	ra,0x1
     264:	98a080e7          	jalr	-1654(ra) # bea <close>
     268:	57fd                	li	a5,-1
     26a:	38f50c63          	beq	a0,a5,602 <mmap_test+0x480>
    err("close");
  _v1(p);
     26e:	8526                	mv	a0,s1
     270:	00000097          	auipc	ra,0x0
     274:	dd0080e7          	jalr	-560(ra) # 40 <_v1>
  for (i = 0; i < PGSIZE*2; i++)
     278:	87a6                	mv	a5,s1
     27a:	6709                	lui	a4,0x2
     27c:	9726                	add	a4,a4,s1
    p[i] = 'Z';
     27e:	05a00693          	li	a3,90
     282:	00d78023          	sb	a3,0(a5)
  for (i = 0; i < PGSIZE*2; i++)
     286:	0785                	addi	a5,a5,1
     288:	fef71de3          	bne	a4,a5,282 <mmap_test+0x100>
  if (munmap(p, PGSIZE*2) == -1)
     28c:	6589                	lui	a1,0x2
     28e:	8526                	mv	a0,s1
     290:	00001097          	auipc	ra,0x1
     294:	9da080e7          	jalr	-1574(ra) # c6a <munmap>
     298:	57fd                	li	a5,-1
     29a:	36f50c63          	beq	a0,a5,612 <mmap_test+0x490>
    err("munmap (2)");

  printf("test mmap private: OK\n");
     29e:	00001517          	auipc	a0,0x1
     2a2:	fca50513          	addi	a0,a0,-54 # 1268 <malloc+0x25e>
     2a6:	00001097          	auipc	ra,0x1
     2aa:	ca4080e7          	jalr	-860(ra) # f4a <printf>
    
  printf("test mmap read-only\n");
     2ae:	00001517          	auipc	a0,0x1
     2b2:	fd250513          	addi	a0,a0,-46 # 1280 <malloc+0x276>
     2b6:	00001097          	auipc	ra,0x1
     2ba:	c94080e7          	jalr	-876(ra) # f4a <printf>
    
  // check that mmap doesn't allow read/write mapping of a
  // file opened read-only.
  if ((fd = open(f, O_RDONLY)) == -1)
     2be:	4581                	li	a1,0
     2c0:	00001517          	auipc	a0,0x1
     2c4:	f1850513          	addi	a0,a0,-232 # 11d8 <malloc+0x1ce>
     2c8:	00001097          	auipc	ra,0x1
     2cc:	93a080e7          	jalr	-1734(ra) # c02 <open>
     2d0:	84aa                	mv	s1,a0
     2d2:	57fd                	li	a5,-1
     2d4:	34f50763          	beq	a0,a5,622 <mmap_test+0x4a0>
    err("open");
  p = mmap(0, PGSIZE*3, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
     2d8:	4781                	li	a5,0
     2da:	872a                	mv	a4,a0
     2dc:	4685                	li	a3,1
     2de:	460d                	li	a2,3
     2e0:	658d                	lui	a1,0x3
     2e2:	4501                	li	a0,0
     2e4:	00001097          	auipc	ra,0x1
     2e8:	97e080e7          	jalr	-1666(ra) # c62 <mmap>
  if (p != MAP_FAILED)
     2ec:	57fd                	li	a5,-1
     2ee:	34f51263          	bne	a0,a5,632 <mmap_test+0x4b0>
    err("mmap call should have failed");
  if (close(fd) == -1)
     2f2:	8526                	mv	a0,s1
     2f4:	00001097          	auipc	ra,0x1
     2f8:	8f6080e7          	jalr	-1802(ra) # bea <close>
     2fc:	57fd                	li	a5,-1
     2fe:	34f50263          	beq	a0,a5,642 <mmap_test+0x4c0>
    err("close");

  printf("test mmap read-only: OK\n");
     302:	00001517          	auipc	a0,0x1
     306:	fb650513          	addi	a0,a0,-74 # 12b8 <malloc+0x2ae>
     30a:	00001097          	auipc	ra,0x1
     30e:	c40080e7          	jalr	-960(ra) # f4a <printf>
    
  printf("test mmap read/write\n");
     312:	00001517          	auipc	a0,0x1
     316:	fc650513          	addi	a0,a0,-58 # 12d8 <malloc+0x2ce>
     31a:	00001097          	auipc	ra,0x1
     31e:	c30080e7          	jalr	-976(ra) # f4a <printf>
  
  // check that mmap does allow read/write mapping of a
  // file opened read/write.
  if ((fd = open(f, O_RDWR)) == -1)
     322:	4589                	li	a1,2
     324:	00001517          	auipc	a0,0x1
     328:	eb450513          	addi	a0,a0,-332 # 11d8 <malloc+0x1ce>
     32c:	00001097          	auipc	ra,0x1
     330:	8d6080e7          	jalr	-1834(ra) # c02 <open>
     334:	84aa                	mv	s1,a0
     336:	57fd                	li	a5,-1
     338:	30f50d63          	beq	a0,a5,652 <mmap_test+0x4d0>
    err("open");
  p = mmap(0, PGSIZE*3, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
     33c:	4781                	li	a5,0
     33e:	872a                	mv	a4,a0
     340:	4685                	li	a3,1
     342:	460d                	li	a2,3
     344:	658d                	lui	a1,0x3
     346:	4501                	li	a0,0
     348:	00001097          	auipc	ra,0x1
     34c:	91a080e7          	jalr	-1766(ra) # c62 <mmap>
     350:	8a2a                	mv	s4,a0
  if (p == MAP_FAILED)
     352:	57fd                	li	a5,-1
     354:	30f50763          	beq	a0,a5,662 <mmap_test+0x4e0>
    err("mmap (3)");
  if (close(fd) == -1)
     358:	8526                	mv	a0,s1
     35a:	00001097          	auipc	ra,0x1
     35e:	890080e7          	jalr	-1904(ra) # bea <close>
     362:	57fd                	li	a5,-1
     364:	30f50763          	beq	a0,a5,672 <mmap_test+0x4f0>
    err("close");

  // check that the mapping still works after close(fd).
  _v1(p);
     368:	8552                	mv	a0,s4
     36a:	00000097          	auipc	ra,0x0
     36e:	cd6080e7          	jalr	-810(ra) # 40 <_v1>

  // write the mapped memory.
  for (i = 0; i < PGSIZE*2; i++)
     372:	87d2                	mv	a5,s4
     374:	6709                	lui	a4,0x2
     376:	9752                	add	a4,a4,s4
    p[i] = 'Z';
     378:	05a00693          	li	a3,90
     37c:	00d78023          	sb	a3,0(a5)
  for (i = 0; i < PGSIZE*2; i++)
     380:	0785                	addi	a5,a5,1
     382:	fef71de3          	bne	a4,a5,37c <mmap_test+0x1fa>

  // unmap just the first two of three pages of mapped memory.
  if (munmap(p, PGSIZE*2) == -1)
     386:	6589                	lui	a1,0x2
     388:	8552                	mv	a0,s4
     38a:	00001097          	auipc	ra,0x1
     38e:	8e0080e7          	jalr	-1824(ra) # c6a <munmap>
     392:	57fd                	li	a5,-1
     394:	2ef50763          	beq	a0,a5,682 <mmap_test+0x500>
    err("munmap (3)");
  
  printf("test mmap read/write: OK\n");
     398:	00001517          	auipc	a0,0x1
     39c:	f7850513          	addi	a0,a0,-136 # 1310 <malloc+0x306>
     3a0:	00001097          	auipc	ra,0x1
     3a4:	baa080e7          	jalr	-1110(ra) # f4a <printf>
  
  printf("test mmap dirty\n");
     3a8:	00001517          	auipc	a0,0x1
     3ac:	f8850513          	addi	a0,a0,-120 # 1330 <malloc+0x326>
     3b0:	00001097          	auipc	ra,0x1
     3b4:	b9a080e7          	jalr	-1126(ra) # f4a <printf>
  
  // check that the writes to the mapped memory were
  // written to the file.
  if ((fd = open(f, O_RDWR)) == -1)
     3b8:	4589                	li	a1,2
     3ba:	00001517          	auipc	a0,0x1
     3be:	e1e50513          	addi	a0,a0,-482 # 11d8 <malloc+0x1ce>
     3c2:	00001097          	auipc	ra,0x1
     3c6:	840080e7          	jalr	-1984(ra) # c02 <open>
     3ca:	892a                	mv	s2,a0
     3cc:	57fd                	li	a5,-1
     3ce:	6489                	lui	s1,0x2
     3d0:	80048493          	addi	s1,s1,-2048 # 1800 <buf+0x230>
    err("open");
  for (i = 0; i < PGSIZE + (PGSIZE/2); i++){
    char b;
    if (read(fd, &b, 1) != 1)
      err("read (1)");
    if (b != 'Z')
     3d4:	05a00993          	li	s3,90
  if ((fd = open(f, O_RDWR)) == -1)
     3d8:	2af50d63          	beq	a0,a5,692 <mmap_test+0x510>
    if (read(fd, &b, 1) != 1)
     3dc:	4605                	li	a2,1
     3de:	fcf40593          	addi	a1,s0,-49
     3e2:	854a                	mv	a0,s2
     3e4:	00000097          	auipc	ra,0x0
     3e8:	7f6080e7          	jalr	2038(ra) # bda <read>
     3ec:	4785                	li	a5,1
     3ee:	2af51a63          	bne	a0,a5,6a2 <mmap_test+0x520>
    if (b != 'Z')
     3f2:	fcf44783          	lbu	a5,-49(s0)
     3f6:	2b379e63          	bne	a5,s3,6b2 <mmap_test+0x530>
  for (i = 0; i < PGSIZE + (PGSIZE/2); i++){
     3fa:	34fd                	addiw	s1,s1,-1
     3fc:	f0e5                	bnez	s1,3dc <mmap_test+0x25a>
      err("file does not contain modifications");
  }
  if (close(fd) == -1)
     3fe:	854a                	mv	a0,s2
     400:	00000097          	auipc	ra,0x0
     404:	7ea080e7          	jalr	2026(ra) # bea <close>
     408:	57fd                	li	a5,-1
     40a:	2af50c63          	beq	a0,a5,6c2 <mmap_test+0x540>
    err("close");

  printf("test mmap dirty: OK\n");
     40e:	00001517          	auipc	a0,0x1
     412:	f7250513          	addi	a0,a0,-142 # 1380 <malloc+0x376>
     416:	00001097          	auipc	ra,0x1
     41a:	b34080e7          	jalr	-1228(ra) # f4a <printf>

  printf("test not-mapped unmap\n");
     41e:	00001517          	auipc	a0,0x1
     422:	f7a50513          	addi	a0,a0,-134 # 1398 <malloc+0x38e>
     426:	00001097          	auipc	ra,0x1
     42a:	b24080e7          	jalr	-1244(ra) # f4a <printf>
  
  // unmap the rest of the mapped memory.
  if (munmap(p+PGSIZE*2, PGSIZE) == -1)
     42e:	6585                	lui	a1,0x1
     430:	6509                	lui	a0,0x2
     432:	9552                	add	a0,a0,s4
     434:	00001097          	auipc	ra,0x1
     438:	836080e7          	jalr	-1994(ra) # c6a <munmap>
     43c:	57fd                	li	a5,-1
     43e:	28f50a63          	beq	a0,a5,6d2 <mmap_test+0x550>
    err("munmap (4)");

  printf("test not-mapped unmap: OK\n");
     442:	00001517          	auipc	a0,0x1
     446:	f7e50513          	addi	a0,a0,-130 # 13c0 <malloc+0x3b6>
     44a:	00001097          	auipc	ra,0x1
     44e:	b00080e7          	jalr	-1280(ra) # f4a <printf>
    
  printf("test mmap two files\n");
     452:	00001517          	auipc	a0,0x1
     456:	f8e50513          	addi	a0,a0,-114 # 13e0 <malloc+0x3d6>
     45a:	00001097          	auipc	ra,0x1
     45e:	af0080e7          	jalr	-1296(ra) # f4a <printf>
  
  //
  // mmap two files at the same time.
  //
  int fd1;
  if((fd1 = open("mmap1", O_RDWR|O_CREATE)) < 0)
     462:	20200593          	li	a1,514
     466:	00001517          	auipc	a0,0x1
     46a:	f9250513          	addi	a0,a0,-110 # 13f8 <malloc+0x3ee>
     46e:	00000097          	auipc	ra,0x0
     472:	794080e7          	jalr	1940(ra) # c02 <open>
     476:	84aa                	mv	s1,a0
     478:	26054563          	bltz	a0,6e2 <mmap_test+0x560>
    err("open mmap1");
  if(write(fd1, "12345", 5) != 5)
     47c:	4615                	li	a2,5
     47e:	00001597          	auipc	a1,0x1
     482:	f9258593          	addi	a1,a1,-110 # 1410 <malloc+0x406>
     486:	00000097          	auipc	ra,0x0
     48a:	75c080e7          	jalr	1884(ra) # be2 <write>
     48e:	4795                	li	a5,5
     490:	26f51163          	bne	a0,a5,6f2 <mmap_test+0x570>
    err("write mmap1");
  char *p1 = mmap(0, PGSIZE, PROT_READ, MAP_PRIVATE, fd1, 0);
     494:	4781                	li	a5,0
     496:	8726                	mv	a4,s1
     498:	4689                	li	a3,2
     49a:	4605                	li	a2,1
     49c:	6585                	lui	a1,0x1
     49e:	4501                	li	a0,0
     4a0:	00000097          	auipc	ra,0x0
     4a4:	7c2080e7          	jalr	1986(ra) # c62 <mmap>
     4a8:	89aa                	mv	s3,a0
  if(p1 == MAP_FAILED)
     4aa:	57fd                	li	a5,-1
     4ac:	24f50b63          	beq	a0,a5,702 <mmap_test+0x580>
    err("mmap mmap1");
  close(fd1);
     4b0:	8526                	mv	a0,s1
     4b2:	00000097          	auipc	ra,0x0
     4b6:	738080e7          	jalr	1848(ra) # bea <close>
  unlink("mmap1");
     4ba:	00001517          	auipc	a0,0x1
     4be:	f3e50513          	addi	a0,a0,-194 # 13f8 <malloc+0x3ee>
     4c2:	00000097          	auipc	ra,0x0
     4c6:	750080e7          	jalr	1872(ra) # c12 <unlink>

  int fd2;
  if((fd2 = open("mmap2", O_RDWR|O_CREATE)) < 0)
     4ca:	20200593          	li	a1,514
     4ce:	00001517          	auipc	a0,0x1
     4d2:	f6a50513          	addi	a0,a0,-150 # 1438 <malloc+0x42e>
     4d6:	00000097          	auipc	ra,0x0
     4da:	72c080e7          	jalr	1836(ra) # c02 <open>
     4de:	892a                	mv	s2,a0
     4e0:	22054963          	bltz	a0,712 <mmap_test+0x590>
    err("open mmap2");
  if(write(fd2, "67890", 5) != 5)
     4e4:	4615                	li	a2,5
     4e6:	00001597          	auipc	a1,0x1
     4ea:	f6a58593          	addi	a1,a1,-150 # 1450 <malloc+0x446>
     4ee:	00000097          	auipc	ra,0x0
     4f2:	6f4080e7          	jalr	1780(ra) # be2 <write>
     4f6:	4795                	li	a5,5
     4f8:	22f51563          	bne	a0,a5,722 <mmap_test+0x5a0>
    err("write mmap2");
  char *p2 = mmap(0, PGSIZE, PROT_READ, MAP_PRIVATE, fd2, 0);
     4fc:	4781                	li	a5,0
     4fe:	874a                	mv	a4,s2
     500:	4689                	li	a3,2
     502:	4605                	li	a2,1
     504:	6585                	lui	a1,0x1
     506:	4501                	li	a0,0
     508:	00000097          	auipc	ra,0x0
     50c:	75a080e7          	jalr	1882(ra) # c62 <mmap>
     510:	84aa                	mv	s1,a0
  if(p2 == MAP_FAILED)
     512:	57fd                	li	a5,-1
     514:	20f50f63          	beq	a0,a5,732 <mmap_test+0x5b0>
    err("mmap mmap2");
  close(fd2);
     518:	854a                	mv	a0,s2
     51a:	00000097          	auipc	ra,0x0
     51e:	6d0080e7          	jalr	1744(ra) # bea <close>
  unlink("mmap2");
     522:	00001517          	auipc	a0,0x1
     526:	f1650513          	addi	a0,a0,-234 # 1438 <malloc+0x42e>
     52a:	00000097          	auipc	ra,0x0
     52e:	6e8080e7          	jalr	1768(ra) # c12 <unlink>

  if(memcmp(p1, "12345", 5) != 0)
     532:	4615                	li	a2,5
     534:	00001597          	auipc	a1,0x1
     538:	edc58593          	addi	a1,a1,-292 # 1410 <malloc+0x406>
     53c:	854e                	mv	a0,s3
     53e:	00000097          	auipc	ra,0x0
     542:	61e080e7          	jalr	1566(ra) # b5c <memcmp>
     546:	1e051e63          	bnez	a0,742 <mmap_test+0x5c0>
    err("mmap1 mismatch");
  if(memcmp(p2, "67890", 5) != 0)
     54a:	4615                	li	a2,5
     54c:	00001597          	auipc	a1,0x1
     550:	f0458593          	addi	a1,a1,-252 # 1450 <malloc+0x446>
     554:	8526                	mv	a0,s1
     556:	00000097          	auipc	ra,0x0
     55a:	606080e7          	jalr	1542(ra) # b5c <memcmp>
     55e:	1e051a63          	bnez	a0,752 <mmap_test+0x5d0>
    err("mmap2 mismatch");

  munmap(p1, PGSIZE);
     562:	6585                	lui	a1,0x1
     564:	854e                	mv	a0,s3
     566:	00000097          	auipc	ra,0x0
     56a:	704080e7          	jalr	1796(ra) # c6a <munmap>
  if(memcmp(p2, "67890", 5) != 0)
     56e:	4615                	li	a2,5
     570:	00001597          	auipc	a1,0x1
     574:	ee058593          	addi	a1,a1,-288 # 1450 <malloc+0x446>
     578:	8526                	mv	a0,s1
     57a:	00000097          	auipc	ra,0x0
     57e:	5e2080e7          	jalr	1506(ra) # b5c <memcmp>
     582:	1e051063          	bnez	a0,762 <mmap_test+0x5e0>
    err("mmap2 mismatch (2)");
  munmap(p2, PGSIZE);
     586:	6585                	lui	a1,0x1
     588:	8526                	mv	a0,s1
     58a:	00000097          	auipc	ra,0x0
     58e:	6e0080e7          	jalr	1760(ra) # c6a <munmap>
  
  printf("test mmap two files: OK\n");
     592:	00001517          	auipc	a0,0x1
     596:	f1e50513          	addi	a0,a0,-226 # 14b0 <malloc+0x4a6>
     59a:	00001097          	auipc	ra,0x1
     59e:	9b0080e7          	jalr	-1616(ra) # f4a <printf>
  
  printf("mmap_test: ALL OK\n");
     5a2:	00001517          	auipc	a0,0x1
     5a6:	f2e50513          	addi	a0,a0,-210 # 14d0 <malloc+0x4c6>
     5aa:	00001097          	auipc	ra,0x1
     5ae:	9a0080e7          	jalr	-1632(ra) # f4a <printf>
}
     5b2:	70e2                	ld	ra,56(sp)
     5b4:	7442                	ld	s0,48(sp)
     5b6:	74a2                	ld	s1,40(sp)
     5b8:	7902                	ld	s2,32(sp)
     5ba:	69e2                	ld	s3,24(sp)
     5bc:	6a42                	ld	s4,16(sp)
     5be:	6121                	addi	sp,sp,64
     5c0:	8082                	ret
    err("open");
     5c2:	00001517          	auipc	a0,0x1
     5c6:	bc650513          	addi	a0,a0,-1082 # 1188 <malloc+0x17e>
     5ca:	00000097          	auipc	ra,0x0
     5ce:	a36080e7          	jalr	-1482(ra) # 0 <err>
    err("mmap (1)");
     5d2:	00001517          	auipc	a0,0x1
     5d6:	c2650513          	addi	a0,a0,-986 # 11f8 <malloc+0x1ee>
     5da:	00000097          	auipc	ra,0x0
     5de:	a26080e7          	jalr	-1498(ra) # 0 <err>
    err("munmap (1)");
     5e2:	00001517          	auipc	a0,0x1
     5e6:	c2650513          	addi	a0,a0,-986 # 1208 <malloc+0x1fe>
     5ea:	00000097          	auipc	ra,0x0
     5ee:	a16080e7          	jalr	-1514(ra) # 0 <err>
    err("mmap (2)");
     5f2:	00001517          	auipc	a0,0x1
     5f6:	c5650513          	addi	a0,a0,-938 # 1248 <malloc+0x23e>
     5fa:	00000097          	auipc	ra,0x0
     5fe:	a06080e7          	jalr	-1530(ra) # 0 <err>
    err("close");
     602:	00001517          	auipc	a0,0x1
     606:	ba650513          	addi	a0,a0,-1114 # 11a8 <malloc+0x19e>
     60a:	00000097          	auipc	ra,0x0
     60e:	9f6080e7          	jalr	-1546(ra) # 0 <err>
    err("munmap (2)");
     612:	00001517          	auipc	a0,0x1
     616:	c4650513          	addi	a0,a0,-954 # 1258 <malloc+0x24e>
     61a:	00000097          	auipc	ra,0x0
     61e:	9e6080e7          	jalr	-1562(ra) # 0 <err>
    err("open");
     622:	00001517          	auipc	a0,0x1
     626:	b6650513          	addi	a0,a0,-1178 # 1188 <malloc+0x17e>
     62a:	00000097          	auipc	ra,0x0
     62e:	9d6080e7          	jalr	-1578(ra) # 0 <err>
    err("mmap call should have failed");
     632:	00001517          	auipc	a0,0x1
     636:	c6650513          	addi	a0,a0,-922 # 1298 <malloc+0x28e>
     63a:	00000097          	auipc	ra,0x0
     63e:	9c6080e7          	jalr	-1594(ra) # 0 <err>
    err("close");
     642:	00001517          	auipc	a0,0x1
     646:	b6650513          	addi	a0,a0,-1178 # 11a8 <malloc+0x19e>
     64a:	00000097          	auipc	ra,0x0
     64e:	9b6080e7          	jalr	-1610(ra) # 0 <err>
    err("open");
     652:	00001517          	auipc	a0,0x1
     656:	b3650513          	addi	a0,a0,-1226 # 1188 <malloc+0x17e>
     65a:	00000097          	auipc	ra,0x0
     65e:	9a6080e7          	jalr	-1626(ra) # 0 <err>
    err("mmap (3)");
     662:	00001517          	auipc	a0,0x1
     666:	c8e50513          	addi	a0,a0,-882 # 12f0 <malloc+0x2e6>
     66a:	00000097          	auipc	ra,0x0
     66e:	996080e7          	jalr	-1642(ra) # 0 <err>
    err("close");
     672:	00001517          	auipc	a0,0x1
     676:	b3650513          	addi	a0,a0,-1226 # 11a8 <malloc+0x19e>
     67a:	00000097          	auipc	ra,0x0
     67e:	986080e7          	jalr	-1658(ra) # 0 <err>
    err("munmap (3)");
     682:	00001517          	auipc	a0,0x1
     686:	c7e50513          	addi	a0,a0,-898 # 1300 <malloc+0x2f6>
     68a:	00000097          	auipc	ra,0x0
     68e:	976080e7          	jalr	-1674(ra) # 0 <err>
    err("open");
     692:	00001517          	auipc	a0,0x1
     696:	af650513          	addi	a0,a0,-1290 # 1188 <malloc+0x17e>
     69a:	00000097          	auipc	ra,0x0
     69e:	966080e7          	jalr	-1690(ra) # 0 <err>
      err("read (1)");
     6a2:	00001517          	auipc	a0,0x1
     6a6:	ca650513          	addi	a0,a0,-858 # 1348 <malloc+0x33e>
     6aa:	00000097          	auipc	ra,0x0
     6ae:	956080e7          	jalr	-1706(ra) # 0 <err>
      err("file does not contain modifications");
     6b2:	00001517          	auipc	a0,0x1
     6b6:	ca650513          	addi	a0,a0,-858 # 1358 <malloc+0x34e>
     6ba:	00000097          	auipc	ra,0x0
     6be:	946080e7          	jalr	-1722(ra) # 0 <err>
    err("close");
     6c2:	00001517          	auipc	a0,0x1
     6c6:	ae650513          	addi	a0,a0,-1306 # 11a8 <malloc+0x19e>
     6ca:	00000097          	auipc	ra,0x0
     6ce:	936080e7          	jalr	-1738(ra) # 0 <err>
    err("munmap (4)");
     6d2:	00001517          	auipc	a0,0x1
     6d6:	cde50513          	addi	a0,a0,-802 # 13b0 <malloc+0x3a6>
     6da:	00000097          	auipc	ra,0x0
     6de:	926080e7          	jalr	-1754(ra) # 0 <err>
    err("open mmap1");
     6e2:	00001517          	auipc	a0,0x1
     6e6:	d1e50513          	addi	a0,a0,-738 # 1400 <malloc+0x3f6>
     6ea:	00000097          	auipc	ra,0x0
     6ee:	916080e7          	jalr	-1770(ra) # 0 <err>
    err("write mmap1");
     6f2:	00001517          	auipc	a0,0x1
     6f6:	d2650513          	addi	a0,a0,-730 # 1418 <malloc+0x40e>
     6fa:	00000097          	auipc	ra,0x0
     6fe:	906080e7          	jalr	-1786(ra) # 0 <err>
    err("mmap mmap1");
     702:	00001517          	auipc	a0,0x1
     706:	d2650513          	addi	a0,a0,-730 # 1428 <malloc+0x41e>
     70a:	00000097          	auipc	ra,0x0
     70e:	8f6080e7          	jalr	-1802(ra) # 0 <err>
    err("open mmap2");
     712:	00001517          	auipc	a0,0x1
     716:	d2e50513          	addi	a0,a0,-722 # 1440 <malloc+0x436>
     71a:	00000097          	auipc	ra,0x0
     71e:	8e6080e7          	jalr	-1818(ra) # 0 <err>
    err("write mmap2");
     722:	00001517          	auipc	a0,0x1
     726:	d3650513          	addi	a0,a0,-714 # 1458 <malloc+0x44e>
     72a:	00000097          	auipc	ra,0x0
     72e:	8d6080e7          	jalr	-1834(ra) # 0 <err>
    err("mmap mmap2");
     732:	00001517          	auipc	a0,0x1
     736:	d3650513          	addi	a0,a0,-714 # 1468 <malloc+0x45e>
     73a:	00000097          	auipc	ra,0x0
     73e:	8c6080e7          	jalr	-1850(ra) # 0 <err>
    err("mmap1 mismatch");
     742:	00001517          	auipc	a0,0x1
     746:	d3650513          	addi	a0,a0,-714 # 1478 <malloc+0x46e>
     74a:	00000097          	auipc	ra,0x0
     74e:	8b6080e7          	jalr	-1866(ra) # 0 <err>
    err("mmap2 mismatch");
     752:	00001517          	auipc	a0,0x1
     756:	d3650513          	addi	a0,a0,-714 # 1488 <malloc+0x47e>
     75a:	00000097          	auipc	ra,0x0
     75e:	8a6080e7          	jalr	-1882(ra) # 0 <err>
    err("mmap2 mismatch (2)");
     762:	00001517          	auipc	a0,0x1
     766:	d3650513          	addi	a0,a0,-714 # 1498 <malloc+0x48e>
     76a:	00000097          	auipc	ra,0x0
     76e:	896080e7          	jalr	-1898(ra) # 0 <err>

0000000000000772 <fork_test>:
// mmap a file, then fork.
// check that the child sees the mapped file.
//
void
fork_test(void)
{
     772:	7179                	addi	sp,sp,-48
     774:	f406                	sd	ra,40(sp)
     776:	f022                	sd	s0,32(sp)
     778:	ec26                	sd	s1,24(sp)
     77a:	e84a                	sd	s2,16(sp)
     77c:	1800                	addi	s0,sp,48
  int fd;
  int pid;
  const char * const f = "mmap.dur";
  
  printf("fork_test starting\n");
     77e:	00001517          	auipc	a0,0x1
     782:	d6a50513          	addi	a0,a0,-662 # 14e8 <malloc+0x4de>
     786:	00000097          	auipc	ra,0x0
     78a:	7c4080e7          	jalr	1988(ra) # f4a <printf>
  testname = "fork_test";
     78e:	00001797          	auipc	a5,0x1
     792:	d7278793          	addi	a5,a5,-654 # 1500 <malloc+0x4f6>
     796:	00001717          	auipc	a4,0x1
     79a:	e2f73523          	sd	a5,-470(a4) # 15c0 <testname>
  
  // mmap the file twice.
  makefile(f);
     79e:	00001517          	auipc	a0,0x1
     7a2:	a3a50513          	addi	a0,a0,-1478 # 11d8 <malloc+0x1ce>
     7a6:	00000097          	auipc	ra,0x0
     7aa:	922080e7          	jalr	-1758(ra) # c8 <makefile>
  if ((fd = open(f, O_RDONLY)) == -1)
     7ae:	4581                	li	a1,0
     7b0:	00001517          	auipc	a0,0x1
     7b4:	a2850513          	addi	a0,a0,-1496 # 11d8 <malloc+0x1ce>
     7b8:	00000097          	auipc	ra,0x0
     7bc:	44a080e7          	jalr	1098(ra) # c02 <open>
     7c0:	57fd                	li	a5,-1
     7c2:	0af50a63          	beq	a0,a5,876 <fork_test+0x104>
     7c6:	84aa                	mv	s1,a0
    err("open");
  unlink(f);
     7c8:	00001517          	auipc	a0,0x1
     7cc:	a1050513          	addi	a0,a0,-1520 # 11d8 <malloc+0x1ce>
     7d0:	00000097          	auipc	ra,0x0
     7d4:	442080e7          	jalr	1090(ra) # c12 <unlink>
  char *p1 = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
     7d8:	4781                	li	a5,0
     7da:	8726                	mv	a4,s1
     7dc:	4685                	li	a3,1
     7de:	4605                	li	a2,1
     7e0:	6589                	lui	a1,0x2
     7e2:	4501                	li	a0,0
     7e4:	00000097          	auipc	ra,0x0
     7e8:	47e080e7          	jalr	1150(ra) # c62 <mmap>
     7ec:	892a                	mv	s2,a0
  if (p1 == MAP_FAILED)
     7ee:	57fd                	li	a5,-1
     7f0:	08f50b63          	beq	a0,a5,886 <fork_test+0x114>
    err("mmap (4)");
  char *p2 = mmap(0, PGSIZE*2, PROT_READ, MAP_SHARED, fd, 0);
     7f4:	4781                	li	a5,0
     7f6:	8726                	mv	a4,s1
     7f8:	4685                	li	a3,1
     7fa:	4605                	li	a2,1
     7fc:	6589                	lui	a1,0x2
     7fe:	4501                	li	a0,0
     800:	00000097          	auipc	ra,0x0
     804:	462080e7          	jalr	1122(ra) # c62 <mmap>
     808:	84aa                	mv	s1,a0
  if (p2 == MAP_FAILED)
     80a:	57fd                	li	a5,-1
     80c:	08f50563          	beq	a0,a5,896 <fork_test+0x124>
    err("mmap (5)");

  // read just 2nd page.
  if(*(p1+PGSIZE) != 'A')
     810:	6785                	lui	a5,0x1
     812:	97ca                	add	a5,a5,s2
     814:	0007c703          	lbu	a4,0(a5) # 1000 <free+0x80>
     818:	04100793          	li	a5,65
     81c:	08f71563          	bne	a4,a5,8a6 <fork_test+0x134>
    err("fork mismatch (1)");

  if((pid = fork()) < 0)
     820:	00000097          	auipc	ra,0x0
     824:	39a080e7          	jalr	922(ra) # bba <fork>
     828:	08054763          	bltz	a0,8b6 <fork_test+0x144>
    err("fork");
  if (pid == 0) {
     82c:	cd49                	beqz	a0,8c6 <fork_test+0x154>
    _v1(p1);
    munmap(p1, PGSIZE); // just the first page
    exit(0); // tell the parent that the mapping looks OK.
  }

  int status = -1;
     82e:	57fd                	li	a5,-1
     830:	fcf42e23          	sw	a5,-36(s0)
  wait(&status);
     834:	fdc40513          	addi	a0,s0,-36
     838:	00000097          	auipc	ra,0x0
     83c:	392080e7          	jalr	914(ra) # bca <wait>

  if(status != 0){
     840:	fdc42783          	lw	a5,-36(s0)
     844:	e3cd                	bnez	a5,8e6 <fork_test+0x174>
    printf("fork_test failed\n");
    exit(1);
  }

  // check that the parent's mappings are still there.
  _v1(p1);
     846:	854a                	mv	a0,s2
     848:	fffff097          	auipc	ra,0xfffff
     84c:	7f8080e7          	jalr	2040(ra) # 40 <_v1>
  _v1(p2);
     850:	8526                	mv	a0,s1
     852:	fffff097          	auipc	ra,0xfffff
     856:	7ee080e7          	jalr	2030(ra) # 40 <_v1>

  printf("fork_test OK\n");
     85a:	00001517          	auipc	a0,0x1
     85e:	d0e50513          	addi	a0,a0,-754 # 1568 <malloc+0x55e>
     862:	00000097          	auipc	ra,0x0
     866:	6e8080e7          	jalr	1768(ra) # f4a <printf>
}
     86a:	70a2                	ld	ra,40(sp)
     86c:	7402                	ld	s0,32(sp)
     86e:	64e2                	ld	s1,24(sp)
     870:	6942                	ld	s2,16(sp)
     872:	6145                	addi	sp,sp,48
     874:	8082                	ret
    err("open");
     876:	00001517          	auipc	a0,0x1
     87a:	91250513          	addi	a0,a0,-1774 # 1188 <malloc+0x17e>
     87e:	fffff097          	auipc	ra,0xfffff
     882:	782080e7          	jalr	1922(ra) # 0 <err>
    err("mmap (4)");
     886:	00001517          	auipc	a0,0x1
     88a:	c8a50513          	addi	a0,a0,-886 # 1510 <malloc+0x506>
     88e:	fffff097          	auipc	ra,0xfffff
     892:	772080e7          	jalr	1906(ra) # 0 <err>
    err("mmap (5)");
     896:	00001517          	auipc	a0,0x1
     89a:	c8a50513          	addi	a0,a0,-886 # 1520 <malloc+0x516>
     89e:	fffff097          	auipc	ra,0xfffff
     8a2:	762080e7          	jalr	1890(ra) # 0 <err>
    err("fork mismatch (1)");
     8a6:	00001517          	auipc	a0,0x1
     8aa:	c8a50513          	addi	a0,a0,-886 # 1530 <malloc+0x526>
     8ae:	fffff097          	auipc	ra,0xfffff
     8b2:	752080e7          	jalr	1874(ra) # 0 <err>
    err("fork");
     8b6:	00001517          	auipc	a0,0x1
     8ba:	c9250513          	addi	a0,a0,-878 # 1548 <malloc+0x53e>
     8be:	fffff097          	auipc	ra,0xfffff
     8c2:	742080e7          	jalr	1858(ra) # 0 <err>
    _v1(p1);
     8c6:	854a                	mv	a0,s2
     8c8:	fffff097          	auipc	ra,0xfffff
     8cc:	778080e7          	jalr	1912(ra) # 40 <_v1>
    munmap(p1, PGSIZE); // just the first page
     8d0:	6585                	lui	a1,0x1
     8d2:	854a                	mv	a0,s2
     8d4:	00000097          	auipc	ra,0x0
     8d8:	396080e7          	jalr	918(ra) # c6a <munmap>
    exit(0); // tell the parent that the mapping looks OK.
     8dc:	4501                	li	a0,0
     8de:	00000097          	auipc	ra,0x0
     8e2:	2e4080e7          	jalr	740(ra) # bc2 <exit>
    printf("fork_test failed\n");
     8e6:	00001517          	auipc	a0,0x1
     8ea:	c6a50513          	addi	a0,a0,-918 # 1550 <malloc+0x546>
     8ee:	00000097          	auipc	ra,0x0
     8f2:	65c080e7          	jalr	1628(ra) # f4a <printf>
    exit(1);
     8f6:	4505                	li	a0,1
     8f8:	00000097          	auipc	ra,0x0
     8fc:	2ca080e7          	jalr	714(ra) # bc2 <exit>

0000000000000900 <main>:
{
     900:	1141                	addi	sp,sp,-16
     902:	e406                	sd	ra,8(sp)
     904:	e022                	sd	s0,0(sp)
     906:	0800                	addi	s0,sp,16
  mmap_test();
     908:	00000097          	auipc	ra,0x0
     90c:	87a080e7          	jalr	-1926(ra) # 182 <mmap_test>
  fork_test();
     910:	00000097          	auipc	ra,0x0
     914:	e62080e7          	jalr	-414(ra) # 772 <fork_test>
  printf("mmaptest: all tests succeeded\n");
     918:	00001517          	auipc	a0,0x1
     91c:	c6050513          	addi	a0,a0,-928 # 1578 <malloc+0x56e>
     920:	00000097          	auipc	ra,0x0
     924:	62a080e7          	jalr	1578(ra) # f4a <printf>
  exit(0);
     928:	4501                	li	a0,0
     92a:	00000097          	auipc	ra,0x0
     92e:	298080e7          	jalr	664(ra) # bc2 <exit>

0000000000000932 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
     932:	1141                	addi	sp,sp,-16
     934:	e422                	sd	s0,8(sp)
     936:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
     938:	87aa                	mv	a5,a0
     93a:	0585                	addi	a1,a1,1
     93c:	0785                	addi	a5,a5,1
     93e:	fff5c703          	lbu	a4,-1(a1) # fff <free+0x7f>
     942:	fee78fa3          	sb	a4,-1(a5)
     946:	fb75                	bnez	a4,93a <strcpy+0x8>
    ;
  return os;
}
     948:	6422                	ld	s0,8(sp)
     94a:	0141                	addi	sp,sp,16
     94c:	8082                	ret

000000000000094e <strcmp>:

int
strcmp(const char *p, const char *q)
{
     94e:	1141                	addi	sp,sp,-16
     950:	e422                	sd	s0,8(sp)
     952:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
     954:	00054783          	lbu	a5,0(a0)
     958:	cf91                	beqz	a5,974 <strcmp+0x26>
     95a:	0005c703          	lbu	a4,0(a1)
     95e:	00f71b63          	bne	a4,a5,974 <strcmp+0x26>
    p++, q++;
     962:	0505                	addi	a0,a0,1
     964:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
     966:	00054783          	lbu	a5,0(a0)
     96a:	c789                	beqz	a5,974 <strcmp+0x26>
     96c:	0005c703          	lbu	a4,0(a1)
     970:	fef709e3          	beq	a4,a5,962 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
     974:	0005c503          	lbu	a0,0(a1)
}
     978:	40a7853b          	subw	a0,a5,a0
     97c:	6422                	ld	s0,8(sp)
     97e:	0141                	addi	sp,sp,16
     980:	8082                	ret

0000000000000982 <strlen>:

uint
strlen(const char *s)
{
     982:	1141                	addi	sp,sp,-16
     984:	e422                	sd	s0,8(sp)
     986:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
     988:	00054783          	lbu	a5,0(a0)
     98c:	cf91                	beqz	a5,9a8 <strlen+0x26>
     98e:	0505                	addi	a0,a0,1
     990:	87aa                	mv	a5,a0
     992:	4685                	li	a3,1
     994:	9e89                	subw	a3,a3,a0
     996:	00f6853b          	addw	a0,a3,a5
     99a:	0785                	addi	a5,a5,1
     99c:	fff7c703          	lbu	a4,-1(a5)
     9a0:	fb7d                	bnez	a4,996 <strlen+0x14>
    ;
  return n;
}
     9a2:	6422                	ld	s0,8(sp)
     9a4:	0141                	addi	sp,sp,16
     9a6:	8082                	ret
  for(n = 0; s[n]; n++)
     9a8:	4501                	li	a0,0
     9aa:	bfe5                	j	9a2 <strlen+0x20>

00000000000009ac <memset>:

void*
memset(void *dst, int c, uint n)
{
     9ac:	1141                	addi	sp,sp,-16
     9ae:	e422                	sd	s0,8(sp)
     9b0:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
     9b2:	ce09                	beqz	a2,9cc <memset+0x20>
     9b4:	87aa                	mv	a5,a0
     9b6:	fff6071b          	addiw	a4,a2,-1
     9ba:	1702                	slli	a4,a4,0x20
     9bc:	9301                	srli	a4,a4,0x20
     9be:	0705                	addi	a4,a4,1
     9c0:	972a                	add	a4,a4,a0
    cdst[i] = c;
     9c2:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
     9c6:	0785                	addi	a5,a5,1
     9c8:	fee79de3          	bne	a5,a4,9c2 <memset+0x16>
  }
  return dst;
}
     9cc:	6422                	ld	s0,8(sp)
     9ce:	0141                	addi	sp,sp,16
     9d0:	8082                	ret

00000000000009d2 <strchr>:

char*
strchr(const char *s, char c)
{
     9d2:	1141                	addi	sp,sp,-16
     9d4:	e422                	sd	s0,8(sp)
     9d6:	0800                	addi	s0,sp,16
  for(; *s; s++)
     9d8:	00054783          	lbu	a5,0(a0)
     9dc:	cf91                	beqz	a5,9f8 <strchr+0x26>
    if(*s == c)
     9de:	00f58a63          	beq	a1,a5,9f2 <strchr+0x20>
  for(; *s; s++)
     9e2:	0505                	addi	a0,a0,1
     9e4:	00054783          	lbu	a5,0(a0)
     9e8:	c781                	beqz	a5,9f0 <strchr+0x1e>
    if(*s == c)
     9ea:	feb79ce3          	bne	a5,a1,9e2 <strchr+0x10>
     9ee:	a011                	j	9f2 <strchr+0x20>
      return (char*)s;
  return 0;
     9f0:	4501                	li	a0,0
}
     9f2:	6422                	ld	s0,8(sp)
     9f4:	0141                	addi	sp,sp,16
     9f6:	8082                	ret
  return 0;
     9f8:	4501                	li	a0,0
     9fa:	bfe5                	j	9f2 <strchr+0x20>

00000000000009fc <gets>:

char*
gets(char *buf, int max)
{
     9fc:	711d                	addi	sp,sp,-96
     9fe:	ec86                	sd	ra,88(sp)
     a00:	e8a2                	sd	s0,80(sp)
     a02:	e4a6                	sd	s1,72(sp)
     a04:	e0ca                	sd	s2,64(sp)
     a06:	fc4e                	sd	s3,56(sp)
     a08:	f852                	sd	s4,48(sp)
     a0a:	f456                	sd	s5,40(sp)
     a0c:	f05a                	sd	s6,32(sp)
     a0e:	ec5e                	sd	s7,24(sp)
     a10:	1080                	addi	s0,sp,96
     a12:	8baa                	mv	s7,a0
     a14:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
     a16:	892a                	mv	s2,a0
     a18:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
     a1a:	4aa9                	li	s5,10
     a1c:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
     a1e:	0019849b          	addiw	s1,s3,1
     a22:	0344d863          	ble	s4,s1,a52 <gets+0x56>
    cc = read(0, &c, 1);
     a26:	4605                	li	a2,1
     a28:	faf40593          	addi	a1,s0,-81
     a2c:	4501                	li	a0,0
     a2e:	00000097          	auipc	ra,0x0
     a32:	1ac080e7          	jalr	428(ra) # bda <read>
    if(cc < 1)
     a36:	00a05e63          	blez	a0,a52 <gets+0x56>
    buf[i++] = c;
     a3a:	faf44783          	lbu	a5,-81(s0)
     a3e:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
     a42:	01578763          	beq	a5,s5,a50 <gets+0x54>
     a46:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
     a48:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
     a4a:	fd679ae3          	bne	a5,s6,a1e <gets+0x22>
     a4e:	a011                	j	a52 <gets+0x56>
  for(i=0; i+1 < max; ){
     a50:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
     a52:	99de                	add	s3,s3,s7
     a54:	00098023          	sb	zero,0(s3)
  return buf;
}
     a58:	855e                	mv	a0,s7
     a5a:	60e6                	ld	ra,88(sp)
     a5c:	6446                	ld	s0,80(sp)
     a5e:	64a6                	ld	s1,72(sp)
     a60:	6906                	ld	s2,64(sp)
     a62:	79e2                	ld	s3,56(sp)
     a64:	7a42                	ld	s4,48(sp)
     a66:	7aa2                	ld	s5,40(sp)
     a68:	7b02                	ld	s6,32(sp)
     a6a:	6be2                	ld	s7,24(sp)
     a6c:	6125                	addi	sp,sp,96
     a6e:	8082                	ret

0000000000000a70 <stat>:

int
stat(const char *n, struct stat *st)
{
     a70:	1101                	addi	sp,sp,-32
     a72:	ec06                	sd	ra,24(sp)
     a74:	e822                	sd	s0,16(sp)
     a76:	e426                	sd	s1,8(sp)
     a78:	e04a                	sd	s2,0(sp)
     a7a:	1000                	addi	s0,sp,32
     a7c:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
     a7e:	4581                	li	a1,0
     a80:	00000097          	auipc	ra,0x0
     a84:	182080e7          	jalr	386(ra) # c02 <open>
  if(fd < 0)
     a88:	02054563          	bltz	a0,ab2 <stat+0x42>
     a8c:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
     a8e:	85ca                	mv	a1,s2
     a90:	00000097          	auipc	ra,0x0
     a94:	18a080e7          	jalr	394(ra) # c1a <fstat>
     a98:	892a                	mv	s2,a0
  close(fd);
     a9a:	8526                	mv	a0,s1
     a9c:	00000097          	auipc	ra,0x0
     aa0:	14e080e7          	jalr	334(ra) # bea <close>
  return r;
}
     aa4:	854a                	mv	a0,s2
     aa6:	60e2                	ld	ra,24(sp)
     aa8:	6442                	ld	s0,16(sp)
     aaa:	64a2                	ld	s1,8(sp)
     aac:	6902                	ld	s2,0(sp)
     aae:	6105                	addi	sp,sp,32
     ab0:	8082                	ret
    return -1;
     ab2:	597d                	li	s2,-1
     ab4:	bfc5                	j	aa4 <stat+0x34>

0000000000000ab6 <atoi>:

int
atoi(const char *s)
{
     ab6:	1141                	addi	sp,sp,-16
     ab8:	e422                	sd	s0,8(sp)
     aba:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
     abc:	00054683          	lbu	a3,0(a0)
     ac0:	fd06879b          	addiw	a5,a3,-48
     ac4:	0ff7f793          	andi	a5,a5,255
     ac8:	4725                	li	a4,9
     aca:	02f76963          	bltu	a4,a5,afc <atoi+0x46>
     ace:	862a                	mv	a2,a0
  n = 0;
     ad0:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
     ad2:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
     ad4:	0605                	addi	a2,a2,1
     ad6:	0025179b          	slliw	a5,a0,0x2
     ada:	9fa9                	addw	a5,a5,a0
     adc:	0017979b          	slliw	a5,a5,0x1
     ae0:	9fb5                	addw	a5,a5,a3
     ae2:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
     ae6:	00064683          	lbu	a3,0(a2)
     aea:	fd06871b          	addiw	a4,a3,-48
     aee:	0ff77713          	andi	a4,a4,255
     af2:	fee5f1e3          	bleu	a4,a1,ad4 <atoi+0x1e>
  return n;
}
     af6:	6422                	ld	s0,8(sp)
     af8:	0141                	addi	sp,sp,16
     afa:	8082                	ret
  n = 0;
     afc:	4501                	li	a0,0
     afe:	bfe5                	j	af6 <atoi+0x40>

0000000000000b00 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
     b00:	1141                	addi	sp,sp,-16
     b02:	e422                	sd	s0,8(sp)
     b04:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
     b06:	02b57663          	bleu	a1,a0,b32 <memmove+0x32>
    while(n-- > 0)
     b0a:	02c05163          	blez	a2,b2c <memmove+0x2c>
     b0e:	fff6079b          	addiw	a5,a2,-1
     b12:	1782                	slli	a5,a5,0x20
     b14:	9381                	srli	a5,a5,0x20
     b16:	0785                	addi	a5,a5,1
     b18:	97aa                	add	a5,a5,a0
  dst = vdst;
     b1a:	872a                	mv	a4,a0
      *dst++ = *src++;
     b1c:	0585                	addi	a1,a1,1
     b1e:	0705                	addi	a4,a4,1
     b20:	fff5c683          	lbu	a3,-1(a1)
     b24:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
     b28:	fee79ae3          	bne	a5,a4,b1c <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
     b2c:	6422                	ld	s0,8(sp)
     b2e:	0141                	addi	sp,sp,16
     b30:	8082                	ret
    dst += n;
     b32:	00c50733          	add	a4,a0,a2
    src += n;
     b36:	95b2                	add	a1,a1,a2
    while(n-- > 0)
     b38:	fec05ae3          	blez	a2,b2c <memmove+0x2c>
     b3c:	fff6079b          	addiw	a5,a2,-1
     b40:	1782                	slli	a5,a5,0x20
     b42:	9381                	srli	a5,a5,0x20
     b44:	fff7c793          	not	a5,a5
     b48:	97ba                	add	a5,a5,a4
      *--dst = *--src;
     b4a:	15fd                	addi	a1,a1,-1
     b4c:	177d                	addi	a4,a4,-1
     b4e:	0005c683          	lbu	a3,0(a1)
     b52:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
     b56:	fef71ae3          	bne	a4,a5,b4a <memmove+0x4a>
     b5a:	bfc9                	j	b2c <memmove+0x2c>

0000000000000b5c <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
     b5c:	1141                	addi	sp,sp,-16
     b5e:	e422                	sd	s0,8(sp)
     b60:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
     b62:	ce15                	beqz	a2,b9e <memcmp+0x42>
     b64:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
     b68:	00054783          	lbu	a5,0(a0)
     b6c:	0005c703          	lbu	a4,0(a1)
     b70:	02e79063          	bne	a5,a4,b90 <memcmp+0x34>
     b74:	1682                	slli	a3,a3,0x20
     b76:	9281                	srli	a3,a3,0x20
     b78:	0685                	addi	a3,a3,1
     b7a:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
     b7c:	0505                	addi	a0,a0,1
    p2++;
     b7e:	0585                	addi	a1,a1,1
  while (n-- > 0) {
     b80:	00d50d63          	beq	a0,a3,b9a <memcmp+0x3e>
    if (*p1 != *p2) {
     b84:	00054783          	lbu	a5,0(a0)
     b88:	0005c703          	lbu	a4,0(a1)
     b8c:	fee788e3          	beq	a5,a4,b7c <memcmp+0x20>
      return *p1 - *p2;
     b90:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
     b94:	6422                	ld	s0,8(sp)
     b96:	0141                	addi	sp,sp,16
     b98:	8082                	ret
  return 0;
     b9a:	4501                	li	a0,0
     b9c:	bfe5                	j	b94 <memcmp+0x38>
     b9e:	4501                	li	a0,0
     ba0:	bfd5                	j	b94 <memcmp+0x38>

0000000000000ba2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
     ba2:	1141                	addi	sp,sp,-16
     ba4:	e406                	sd	ra,8(sp)
     ba6:	e022                	sd	s0,0(sp)
     ba8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
     baa:	00000097          	auipc	ra,0x0
     bae:	f56080e7          	jalr	-170(ra) # b00 <memmove>
}
     bb2:	60a2                	ld	ra,8(sp)
     bb4:	6402                	ld	s0,0(sp)
     bb6:	0141                	addi	sp,sp,16
     bb8:	8082                	ret

0000000000000bba <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
     bba:	4885                	li	a7,1
 ecall
     bbc:	00000073          	ecall
 ret
     bc0:	8082                	ret

0000000000000bc2 <exit>:
.global exit
exit:
 li a7, SYS_exit
     bc2:	4889                	li	a7,2
 ecall
     bc4:	00000073          	ecall
 ret
     bc8:	8082                	ret

0000000000000bca <wait>:
.global wait
wait:
 li a7, SYS_wait
     bca:	488d                	li	a7,3
 ecall
     bcc:	00000073          	ecall
 ret
     bd0:	8082                	ret

0000000000000bd2 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
     bd2:	4891                	li	a7,4
 ecall
     bd4:	00000073          	ecall
 ret
     bd8:	8082                	ret

0000000000000bda <read>:
.global read
read:
 li a7, SYS_read
     bda:	4895                	li	a7,5
 ecall
     bdc:	00000073          	ecall
 ret
     be0:	8082                	ret

0000000000000be2 <write>:
.global write
write:
 li a7, SYS_write
     be2:	48c1                	li	a7,16
 ecall
     be4:	00000073          	ecall
 ret
     be8:	8082                	ret

0000000000000bea <close>:
.global close
close:
 li a7, SYS_close
     bea:	48d5                	li	a7,21
 ecall
     bec:	00000073          	ecall
 ret
     bf0:	8082                	ret

0000000000000bf2 <kill>:
.global kill
kill:
 li a7, SYS_kill
     bf2:	4899                	li	a7,6
 ecall
     bf4:	00000073          	ecall
 ret
     bf8:	8082                	ret

0000000000000bfa <exec>:
.global exec
exec:
 li a7, SYS_exec
     bfa:	489d                	li	a7,7
 ecall
     bfc:	00000073          	ecall
 ret
     c00:	8082                	ret

0000000000000c02 <open>:
.global open
open:
 li a7, SYS_open
     c02:	48bd                	li	a7,15
 ecall
     c04:	00000073          	ecall
 ret
     c08:	8082                	ret

0000000000000c0a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
     c0a:	48c5                	li	a7,17
 ecall
     c0c:	00000073          	ecall
 ret
     c10:	8082                	ret

0000000000000c12 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
     c12:	48c9                	li	a7,18
 ecall
     c14:	00000073          	ecall
 ret
     c18:	8082                	ret

0000000000000c1a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
     c1a:	48a1                	li	a7,8
 ecall
     c1c:	00000073          	ecall
 ret
     c20:	8082                	ret

0000000000000c22 <link>:
.global link
link:
 li a7, SYS_link
     c22:	48cd                	li	a7,19
 ecall
     c24:	00000073          	ecall
 ret
     c28:	8082                	ret

0000000000000c2a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
     c2a:	48d1                	li	a7,20
 ecall
     c2c:	00000073          	ecall
 ret
     c30:	8082                	ret

0000000000000c32 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
     c32:	48a5                	li	a7,9
 ecall
     c34:	00000073          	ecall
 ret
     c38:	8082                	ret

0000000000000c3a <dup>:
.global dup
dup:
 li a7, SYS_dup
     c3a:	48a9                	li	a7,10
 ecall
     c3c:	00000073          	ecall
 ret
     c40:	8082                	ret

0000000000000c42 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
     c42:	48ad                	li	a7,11
 ecall
     c44:	00000073          	ecall
 ret
     c48:	8082                	ret

0000000000000c4a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
     c4a:	48b1                	li	a7,12
 ecall
     c4c:	00000073          	ecall
 ret
     c50:	8082                	ret

0000000000000c52 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
     c52:	48b5                	li	a7,13
 ecall
     c54:	00000073          	ecall
 ret
     c58:	8082                	ret

0000000000000c5a <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
     c5a:	48b9                	li	a7,14
 ecall
     c5c:	00000073          	ecall
 ret
     c60:	8082                	ret

0000000000000c62 <mmap>:
.global mmap
mmap:
 li a7, SYS_mmap
     c62:	48d9                	li	a7,22
 ecall
     c64:	00000073          	ecall
 ret
     c68:	8082                	ret

0000000000000c6a <munmap>:
.global munmap
munmap:
 li a7, SYS_munmap
     c6a:	48dd                	li	a7,23
 ecall
     c6c:	00000073          	ecall
 ret
     c70:	8082                	ret

0000000000000c72 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
     c72:	1101                	addi	sp,sp,-32
     c74:	ec06                	sd	ra,24(sp)
     c76:	e822                	sd	s0,16(sp)
     c78:	1000                	addi	s0,sp,32
     c7a:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
     c7e:	4605                	li	a2,1
     c80:	fef40593          	addi	a1,s0,-17
     c84:	00000097          	auipc	ra,0x0
     c88:	f5e080e7          	jalr	-162(ra) # be2 <write>
}
     c8c:	60e2                	ld	ra,24(sp)
     c8e:	6442                	ld	s0,16(sp)
     c90:	6105                	addi	sp,sp,32
     c92:	8082                	ret

0000000000000c94 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
     c94:	7139                	addi	sp,sp,-64
     c96:	fc06                	sd	ra,56(sp)
     c98:	f822                	sd	s0,48(sp)
     c9a:	f426                	sd	s1,40(sp)
     c9c:	f04a                	sd	s2,32(sp)
     c9e:	ec4e                	sd	s3,24(sp)
     ca0:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
     ca2:	c299                	beqz	a3,ca8 <printint+0x14>
     ca4:	0005cd63          	bltz	a1,cbe <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
     ca8:	2581                	sext.w	a1,a1
  neg = 0;
     caa:	4301                	li	t1,0
     cac:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
     cb0:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
     cb2:	2601                	sext.w	a2,a2
     cb4:	00001897          	auipc	a7,0x1
     cb8:	8ec88893          	addi	a7,a7,-1812 # 15a0 <digits>
     cbc:	a801                	j	ccc <printint+0x38>
    x = -xx;
     cbe:	40b005bb          	negw	a1,a1
     cc2:	2581                	sext.w	a1,a1
    neg = 1;
     cc4:	4305                	li	t1,1
    x = -xx;
     cc6:	b7dd                	j	cac <printint+0x18>
  }while((x /= base) != 0);
     cc8:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
     cca:	8836                	mv	a6,a3
     ccc:	0018069b          	addiw	a3,a6,1
     cd0:	02c5f7bb          	remuw	a5,a1,a2
     cd4:	1782                	slli	a5,a5,0x20
     cd6:	9381                	srli	a5,a5,0x20
     cd8:	97c6                	add	a5,a5,a7
     cda:	0007c783          	lbu	a5,0(a5)
     cde:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
     ce2:	0705                	addi	a4,a4,1
     ce4:	02c5d7bb          	divuw	a5,a1,a2
     ce8:	fec5f0e3          	bleu	a2,a1,cc8 <printint+0x34>
  if(neg)
     cec:	00030b63          	beqz	t1,d02 <printint+0x6e>
    buf[i++] = '-';
     cf0:	fd040793          	addi	a5,s0,-48
     cf4:	96be                	add	a3,a3,a5
     cf6:	02d00793          	li	a5,45
     cfa:	fef68823          	sb	a5,-16(a3)
     cfe:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
     d02:	02d05963          	blez	a3,d34 <printint+0xa0>
     d06:	89aa                	mv	s3,a0
     d08:	fc040793          	addi	a5,s0,-64
     d0c:	00d784b3          	add	s1,a5,a3
     d10:	fff78913          	addi	s2,a5,-1
     d14:	9936                	add	s2,s2,a3
     d16:	36fd                	addiw	a3,a3,-1
     d18:	1682                	slli	a3,a3,0x20
     d1a:	9281                	srli	a3,a3,0x20
     d1c:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
     d20:	fff4c583          	lbu	a1,-1(s1)
     d24:	854e                	mv	a0,s3
     d26:	00000097          	auipc	ra,0x0
     d2a:	f4c080e7          	jalr	-180(ra) # c72 <putc>
  while(--i >= 0)
     d2e:	14fd                	addi	s1,s1,-1
     d30:	ff2498e3          	bne	s1,s2,d20 <printint+0x8c>
}
     d34:	70e2                	ld	ra,56(sp)
     d36:	7442                	ld	s0,48(sp)
     d38:	74a2                	ld	s1,40(sp)
     d3a:	7902                	ld	s2,32(sp)
     d3c:	69e2                	ld	s3,24(sp)
     d3e:	6121                	addi	sp,sp,64
     d40:	8082                	ret

0000000000000d42 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
     d42:	7119                	addi	sp,sp,-128
     d44:	fc86                	sd	ra,120(sp)
     d46:	f8a2                	sd	s0,112(sp)
     d48:	f4a6                	sd	s1,104(sp)
     d4a:	f0ca                	sd	s2,96(sp)
     d4c:	ecce                	sd	s3,88(sp)
     d4e:	e8d2                	sd	s4,80(sp)
     d50:	e4d6                	sd	s5,72(sp)
     d52:	e0da                	sd	s6,64(sp)
     d54:	fc5e                	sd	s7,56(sp)
     d56:	f862                	sd	s8,48(sp)
     d58:	f466                	sd	s9,40(sp)
     d5a:	f06a                	sd	s10,32(sp)
     d5c:	ec6e                	sd	s11,24(sp)
     d5e:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
     d60:	0005c483          	lbu	s1,0(a1)
     d64:	18048d63          	beqz	s1,efe <vprintf+0x1bc>
     d68:	8aaa                	mv	s5,a0
     d6a:	8b32                	mv	s6,a2
     d6c:	00158913          	addi	s2,a1,1
  state = 0;
     d70:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
     d72:	02500a13          	li	s4,37
      if(c == 'd'){
     d76:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
     d7a:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
     d7e:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
     d82:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     d86:	00001b97          	auipc	s7,0x1
     d8a:	81ab8b93          	addi	s7,s7,-2022 # 15a0 <digits>
     d8e:	a839                	j	dac <vprintf+0x6a>
        putc(fd, c);
     d90:	85a6                	mv	a1,s1
     d92:	8556                	mv	a0,s5
     d94:	00000097          	auipc	ra,0x0
     d98:	ede080e7          	jalr	-290(ra) # c72 <putc>
     d9c:	a019                	j	da2 <vprintf+0x60>
    } else if(state == '%'){
     d9e:	01498f63          	beq	s3,s4,dbc <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
     da2:	0905                	addi	s2,s2,1
     da4:	fff94483          	lbu	s1,-1(s2)
     da8:	14048b63          	beqz	s1,efe <vprintf+0x1bc>
    c = fmt[i] & 0xff;
     dac:	0004879b          	sext.w	a5,s1
    if(state == 0){
     db0:	fe0997e3          	bnez	s3,d9e <vprintf+0x5c>
      if(c == '%'){
     db4:	fd479ee3          	bne	a5,s4,d90 <vprintf+0x4e>
        state = '%';
     db8:	89be                	mv	s3,a5
     dba:	b7e5                	j	da2 <vprintf+0x60>
      if(c == 'd'){
     dbc:	05878063          	beq	a5,s8,dfc <vprintf+0xba>
      } else if(c == 'l') {
     dc0:	05978c63          	beq	a5,s9,e18 <vprintf+0xd6>
      } else if(c == 'x') {
     dc4:	07a78863          	beq	a5,s10,e34 <vprintf+0xf2>
      } else if(c == 'p') {
     dc8:	09b78463          	beq	a5,s11,e50 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
     dcc:	07300713          	li	a4,115
     dd0:	0ce78563          	beq	a5,a4,e9a <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
     dd4:	06300713          	li	a4,99
     dd8:	0ee78c63          	beq	a5,a4,ed0 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
     ddc:	11478663          	beq	a5,s4,ee8 <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
     de0:	85d2                	mv	a1,s4
     de2:	8556                	mv	a0,s5
     de4:	00000097          	auipc	ra,0x0
     de8:	e8e080e7          	jalr	-370(ra) # c72 <putc>
        putc(fd, c);
     dec:	85a6                	mv	a1,s1
     dee:	8556                	mv	a0,s5
     df0:	00000097          	auipc	ra,0x0
     df4:	e82080e7          	jalr	-382(ra) # c72 <putc>
      }
      state = 0;
     df8:	4981                	li	s3,0
     dfa:	b765                	j	da2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
     dfc:	008b0493          	addi	s1,s6,8
     e00:	4685                	li	a3,1
     e02:	4629                	li	a2,10
     e04:	000b2583          	lw	a1,0(s6)
     e08:	8556                	mv	a0,s5
     e0a:	00000097          	auipc	ra,0x0
     e0e:	e8a080e7          	jalr	-374(ra) # c94 <printint>
     e12:	8b26                	mv	s6,s1
      state = 0;
     e14:	4981                	li	s3,0
     e16:	b771                	j	da2 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
     e18:	008b0493          	addi	s1,s6,8
     e1c:	4681                	li	a3,0
     e1e:	4629                	li	a2,10
     e20:	000b2583          	lw	a1,0(s6)
     e24:	8556                	mv	a0,s5
     e26:	00000097          	auipc	ra,0x0
     e2a:	e6e080e7          	jalr	-402(ra) # c94 <printint>
     e2e:	8b26                	mv	s6,s1
      state = 0;
     e30:	4981                	li	s3,0
     e32:	bf85                	j	da2 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
     e34:	008b0493          	addi	s1,s6,8
     e38:	4681                	li	a3,0
     e3a:	4641                	li	a2,16
     e3c:	000b2583          	lw	a1,0(s6)
     e40:	8556                	mv	a0,s5
     e42:	00000097          	auipc	ra,0x0
     e46:	e52080e7          	jalr	-430(ra) # c94 <printint>
     e4a:	8b26                	mv	s6,s1
      state = 0;
     e4c:	4981                	li	s3,0
     e4e:	bf91                	j	da2 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
     e50:	008b0793          	addi	a5,s6,8
     e54:	f8f43423          	sd	a5,-120(s0)
     e58:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
     e5c:	03000593          	li	a1,48
     e60:	8556                	mv	a0,s5
     e62:	00000097          	auipc	ra,0x0
     e66:	e10080e7          	jalr	-496(ra) # c72 <putc>
  putc(fd, 'x');
     e6a:	85ea                	mv	a1,s10
     e6c:	8556                	mv	a0,s5
     e6e:	00000097          	auipc	ra,0x0
     e72:	e04080e7          	jalr	-508(ra) # c72 <putc>
     e76:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
     e78:	03c9d793          	srli	a5,s3,0x3c
     e7c:	97de                	add	a5,a5,s7
     e7e:	0007c583          	lbu	a1,0(a5)
     e82:	8556                	mv	a0,s5
     e84:	00000097          	auipc	ra,0x0
     e88:	dee080e7          	jalr	-530(ra) # c72 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
     e8c:	0992                	slli	s3,s3,0x4
     e8e:	34fd                	addiw	s1,s1,-1
     e90:	f4e5                	bnez	s1,e78 <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
     e92:	f8843b03          	ld	s6,-120(s0)
      state = 0;
     e96:	4981                	li	s3,0
     e98:	b729                	j	da2 <vprintf+0x60>
        s = va_arg(ap, char*);
     e9a:	008b0993          	addi	s3,s6,8
     e9e:	000b3483          	ld	s1,0(s6)
        if(s == 0)
     ea2:	c085                	beqz	s1,ec2 <vprintf+0x180>
        while(*s != 0){
     ea4:	0004c583          	lbu	a1,0(s1)
     ea8:	c9a1                	beqz	a1,ef8 <vprintf+0x1b6>
          putc(fd, *s);
     eaa:	8556                	mv	a0,s5
     eac:	00000097          	auipc	ra,0x0
     eb0:	dc6080e7          	jalr	-570(ra) # c72 <putc>
          s++;
     eb4:	0485                	addi	s1,s1,1
        while(*s != 0){
     eb6:	0004c583          	lbu	a1,0(s1)
     eba:	f9e5                	bnez	a1,eaa <vprintf+0x168>
        s = va_arg(ap, char*);
     ebc:	8b4e                	mv	s6,s3
      state = 0;
     ebe:	4981                	li	s3,0
     ec0:	b5cd                	j	da2 <vprintf+0x60>
          s = "(null)";
     ec2:	00000497          	auipc	s1,0x0
     ec6:	6f648493          	addi	s1,s1,1782 # 15b8 <digits+0x18>
        while(*s != 0){
     eca:	02800593          	li	a1,40
     ece:	bff1                	j	eaa <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
     ed0:	008b0493          	addi	s1,s6,8
     ed4:	000b4583          	lbu	a1,0(s6)
     ed8:	8556                	mv	a0,s5
     eda:	00000097          	auipc	ra,0x0
     ede:	d98080e7          	jalr	-616(ra) # c72 <putc>
     ee2:	8b26                	mv	s6,s1
      state = 0;
     ee4:	4981                	li	s3,0
     ee6:	bd75                	j	da2 <vprintf+0x60>
        putc(fd, c);
     ee8:	85d2                	mv	a1,s4
     eea:	8556                	mv	a0,s5
     eec:	00000097          	auipc	ra,0x0
     ef0:	d86080e7          	jalr	-634(ra) # c72 <putc>
      state = 0;
     ef4:	4981                	li	s3,0
     ef6:	b575                	j	da2 <vprintf+0x60>
        s = va_arg(ap, char*);
     ef8:	8b4e                	mv	s6,s3
      state = 0;
     efa:	4981                	li	s3,0
     efc:	b55d                	j	da2 <vprintf+0x60>
    }
  }
}
     efe:	70e6                	ld	ra,120(sp)
     f00:	7446                	ld	s0,112(sp)
     f02:	74a6                	ld	s1,104(sp)
     f04:	7906                	ld	s2,96(sp)
     f06:	69e6                	ld	s3,88(sp)
     f08:	6a46                	ld	s4,80(sp)
     f0a:	6aa6                	ld	s5,72(sp)
     f0c:	6b06                	ld	s6,64(sp)
     f0e:	7be2                	ld	s7,56(sp)
     f10:	7c42                	ld	s8,48(sp)
     f12:	7ca2                	ld	s9,40(sp)
     f14:	7d02                	ld	s10,32(sp)
     f16:	6de2                	ld	s11,24(sp)
     f18:	6109                	addi	sp,sp,128
     f1a:	8082                	ret

0000000000000f1c <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
     f1c:	715d                	addi	sp,sp,-80
     f1e:	ec06                	sd	ra,24(sp)
     f20:	e822                	sd	s0,16(sp)
     f22:	1000                	addi	s0,sp,32
     f24:	e010                	sd	a2,0(s0)
     f26:	e414                	sd	a3,8(s0)
     f28:	e818                	sd	a4,16(s0)
     f2a:	ec1c                	sd	a5,24(s0)
     f2c:	03043023          	sd	a6,32(s0)
     f30:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
     f34:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
     f38:	8622                	mv	a2,s0
     f3a:	00000097          	auipc	ra,0x0
     f3e:	e08080e7          	jalr	-504(ra) # d42 <vprintf>
}
     f42:	60e2                	ld	ra,24(sp)
     f44:	6442                	ld	s0,16(sp)
     f46:	6161                	addi	sp,sp,80
     f48:	8082                	ret

0000000000000f4a <printf>:

void
printf(const char *fmt, ...)
{
     f4a:	711d                	addi	sp,sp,-96
     f4c:	ec06                	sd	ra,24(sp)
     f4e:	e822                	sd	s0,16(sp)
     f50:	1000                	addi	s0,sp,32
     f52:	e40c                	sd	a1,8(s0)
     f54:	e810                	sd	a2,16(s0)
     f56:	ec14                	sd	a3,24(s0)
     f58:	f018                	sd	a4,32(s0)
     f5a:	f41c                	sd	a5,40(s0)
     f5c:	03043823          	sd	a6,48(s0)
     f60:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
     f64:	00840613          	addi	a2,s0,8
     f68:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
     f6c:	85aa                	mv	a1,a0
     f6e:	4505                	li	a0,1
     f70:	00000097          	auipc	ra,0x0
     f74:	dd2080e7          	jalr	-558(ra) # d42 <vprintf>
}
     f78:	60e2                	ld	ra,24(sp)
     f7a:	6442                	ld	s0,16(sp)
     f7c:	6125                	addi	sp,sp,96
     f7e:	8082                	ret

0000000000000f80 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
     f80:	1141                	addi	sp,sp,-16
     f82:	e422                	sd	s0,8(sp)
     f84:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
     f86:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     f8a:	00000797          	auipc	a5,0x0
     f8e:	63e78793          	addi	a5,a5,1598 # 15c8 <_edata>
     f92:	639c                	ld	a5,0(a5)
     f94:	a805                	j	fc4 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
     f96:	4618                	lw	a4,8(a2)
     f98:	9db9                	addw	a1,a1,a4
     f9a:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
     f9e:	6398                	ld	a4,0(a5)
     fa0:	6318                	ld	a4,0(a4)
     fa2:	fee53823          	sd	a4,-16(a0)
     fa6:	a091                	j	fea <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
     fa8:	ff852703          	lw	a4,-8(a0)
     fac:	9e39                	addw	a2,a2,a4
     fae:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
     fb0:	ff053703          	ld	a4,-16(a0)
     fb4:	e398                	sd	a4,0(a5)
     fb6:	a099                	j	ffc <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fb8:	6398                	ld	a4,0(a5)
     fba:	00e7e463          	bltu	a5,a4,fc2 <free+0x42>
     fbe:	00e6ea63          	bltu	a3,a4,fd2 <free+0x52>
{
     fc2:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
     fc4:	fed7fae3          	bleu	a3,a5,fb8 <free+0x38>
     fc8:	6398                	ld	a4,0(a5)
     fca:	00e6e463          	bltu	a3,a4,fd2 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
     fce:	fee7eae3          	bltu	a5,a4,fc2 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
     fd2:	ff852583          	lw	a1,-8(a0)
     fd6:	6390                	ld	a2,0(a5)
     fd8:	02059713          	slli	a4,a1,0x20
     fdc:	9301                	srli	a4,a4,0x20
     fde:	0712                	slli	a4,a4,0x4
     fe0:	9736                	add	a4,a4,a3
     fe2:	fae60ae3          	beq	a2,a4,f96 <free+0x16>
    bp->s.ptr = p->s.ptr;
     fe6:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
     fea:	4790                	lw	a2,8(a5)
     fec:	02061713          	slli	a4,a2,0x20
     ff0:	9301                	srli	a4,a4,0x20
     ff2:	0712                	slli	a4,a4,0x4
     ff4:	973e                	add	a4,a4,a5
     ff6:	fae689e3          	beq	a3,a4,fa8 <free+0x28>
  } else
    p->s.ptr = bp;
     ffa:	e394                	sd	a3,0(a5)
  freep = p;
     ffc:	00000717          	auipc	a4,0x0
    1000:	5cf73623          	sd	a5,1484(a4) # 15c8 <_edata>
}
    1004:	6422                	ld	s0,8(sp)
    1006:	0141                	addi	sp,sp,16
    1008:	8082                	ret

000000000000100a <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
    100a:	7139                	addi	sp,sp,-64
    100c:	fc06                	sd	ra,56(sp)
    100e:	f822                	sd	s0,48(sp)
    1010:	f426                	sd	s1,40(sp)
    1012:	f04a                	sd	s2,32(sp)
    1014:	ec4e                	sd	s3,24(sp)
    1016:	e852                	sd	s4,16(sp)
    1018:	e456                	sd	s5,8(sp)
    101a:	e05a                	sd	s6,0(sp)
    101c:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
    101e:	02051993          	slli	s3,a0,0x20
    1022:	0209d993          	srli	s3,s3,0x20
    1026:	09bd                	addi	s3,s3,15
    1028:	0049d993          	srli	s3,s3,0x4
    102c:	2985                	addiw	s3,s3,1
    102e:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
    1032:	00000797          	auipc	a5,0x0
    1036:	59678793          	addi	a5,a5,1430 # 15c8 <_edata>
    103a:	6388                	ld	a0,0(a5)
    103c:	c515                	beqz	a0,1068 <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    103e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    1040:	4798                	lw	a4,8(a5)
    1042:	03277f63          	bleu	s2,a4,1080 <malloc+0x76>
    1046:	8a4e                	mv	s4,s3
    1048:	0009871b          	sext.w	a4,s3
    104c:	6685                	lui	a3,0x1
    104e:	00d77363          	bleu	a3,a4,1054 <malloc+0x4a>
    1052:	6a05                	lui	s4,0x1
    1054:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
    1058:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
    105c:	00000497          	auipc	s1,0x0
    1060:	56c48493          	addi	s1,s1,1388 # 15c8 <_edata>
  if(p == (char*)-1)
    1064:	5b7d                	li	s6,-1
    1066:	a885                	j	10d6 <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
    1068:	00001797          	auipc	a5,0x1
    106c:	96878793          	addi	a5,a5,-1688 # 19d0 <base>
    1070:	00000717          	auipc	a4,0x0
    1074:	54f73c23          	sd	a5,1368(a4) # 15c8 <_edata>
    1078:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
    107a:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
    107e:	b7e1                	j	1046 <malloc+0x3c>
      if(p->s.size == nunits)
    1080:	02e90b63          	beq	s2,a4,10b6 <malloc+0xac>
        p->s.size -= nunits;
    1084:	4137073b          	subw	a4,a4,s3
    1088:	c798                	sw	a4,8(a5)
        p += p->s.size;
    108a:	1702                	slli	a4,a4,0x20
    108c:	9301                	srli	a4,a4,0x20
    108e:	0712                	slli	a4,a4,0x4
    1090:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
    1092:	0137a423          	sw	s3,8(a5)
      freep = prevp;
    1096:	00000717          	auipc	a4,0x0
    109a:	52a73923          	sd	a0,1330(a4) # 15c8 <_edata>
      return (void*)(p + 1);
    109e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
    10a2:	70e2                	ld	ra,56(sp)
    10a4:	7442                	ld	s0,48(sp)
    10a6:	74a2                	ld	s1,40(sp)
    10a8:	7902                	ld	s2,32(sp)
    10aa:	69e2                	ld	s3,24(sp)
    10ac:	6a42                	ld	s4,16(sp)
    10ae:	6aa2                	ld	s5,8(sp)
    10b0:	6b02                	ld	s6,0(sp)
    10b2:	6121                	addi	sp,sp,64
    10b4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
    10b6:	6398                	ld	a4,0(a5)
    10b8:	e118                	sd	a4,0(a0)
    10ba:	bff1                	j	1096 <malloc+0x8c>
  hp->s.size = nu;
    10bc:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
    10c0:	0541                	addi	a0,a0,16
    10c2:	00000097          	auipc	ra,0x0
    10c6:	ebe080e7          	jalr	-322(ra) # f80 <free>
  return freep;
    10ca:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
    10cc:	d979                	beqz	a0,10a2 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
    10ce:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
    10d0:	4798                	lw	a4,8(a5)
    10d2:	fb2777e3          	bleu	s2,a4,1080 <malloc+0x76>
    if(p == freep)
    10d6:	6098                	ld	a4,0(s1)
    10d8:	853e                	mv	a0,a5
    10da:	fef71ae3          	bne	a4,a5,10ce <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
    10de:	8552                	mv	a0,s4
    10e0:	00000097          	auipc	ra,0x0
    10e4:	b6a080e7          	jalr	-1174(ra) # c4a <sbrk>
  if(p == (char*)-1)
    10e8:	fd651ae3          	bne	a0,s6,10bc <malloc+0xb2>
        return 0;
    10ec:	4501                	li	a0,0
    10ee:	bf55                	j	10a2 <malloc+0x98>
