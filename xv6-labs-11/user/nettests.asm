
user/_nettests：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <decode_qname>:
}

// Decode a DNS name
static void
decode_qname(char *qn)
{
   0:	1141                	addi	sp,sp,-16
   2:	e422                	sd	s0,8(sp)
   4:	0800                	addi	s0,sp,16
  while(*qn != '\0') {
   6:	00054783          	lbu	a5,0(a0)
   a:	cf8d                	beqz	a5,44 <decode_qname+0x44>
    int l = *qn;
   c:	2781                	sext.w	a5,a5
      break;
    for(int i = 0; i < l; i++) {
      *qn = *(qn+1);
      qn++;
    }
    *qn++ = '.';
   e:	02e00693          	li	a3,46
  12:	a811                	j	26 <decode_qname+0x26>
    for(int i = 0; i < l; i++) {
  14:	87aa                	mv	a5,a0
    *qn++ = '.';
  16:	00178513          	addi	a0,a5,1
  1a:	00d78023          	sb	a3,0(a5)
  while(*qn != '\0') {
  1e:	0017c783          	lbu	a5,1(a5)
  22:	c38d                	beqz	a5,44 <decode_qname+0x44>
    int l = *qn;
  24:	2781                	sext.w	a5,a5
    for(int i = 0; i < l; i++) {
  26:	fef057e3          	blez	a5,14 <decode_qname+0x14>
  2a:	37fd                	addiw	a5,a5,-1
  2c:	1782                	slli	a5,a5,0x20
  2e:	9381                	srli	a5,a5,0x20
  30:	0785                	addi	a5,a5,1
  32:	97aa                	add	a5,a5,a0
      *qn = *(qn+1);
  34:	00154703          	lbu	a4,1(a0)
  38:	00e50023          	sb	a4,0(a0)
      qn++;
  3c:	0505                	addi	a0,a0,1
    for(int i = 0; i < l; i++) {
  3e:	fef51be3          	bne	a0,a5,34 <decode_qname+0x34>
  42:	bfd1                	j	16 <decode_qname+0x16>
  }
}
  44:	6422                	ld	s0,8(sp)
  46:	0141                	addi	sp,sp,16
  48:	8082                	ret

000000000000004a <ping>:
{
  4a:	7171                	addi	sp,sp,-176
  4c:	f506                	sd	ra,168(sp)
  4e:	f122                	sd	s0,160(sp)
  50:	ed26                	sd	s1,152(sp)
  52:	e94a                	sd	s2,144(sp)
  54:	e54e                	sd	s3,136(sp)
  56:	e152                	sd	s4,128(sp)
  58:	1900                	addi	s0,sp,176
  5a:	8a32                	mv	s4,a2
  if((fd = connect(dst, sport, dport)) < 0){
  5c:	862e                	mv	a2,a1
  5e:	85aa                	mv	a1,a0
  60:	0a000537          	lui	a0,0xa000
  64:	20250513          	addi	a0,a0,514 # a000202 <__global_pointer$+0x9ffe88a>
  68:	00001097          	auipc	ra,0x1
  6c:	a18080e7          	jalr	-1512(ra) # a80 <connect>
  70:	08054563          	bltz	a0,fa <ping+0xb0>
  74:	89aa                	mv	s3,a0
  for(int i = 0; i < attempts; i++) {
  76:	4481                	li	s1,0
    if(write(fd, obuf, strlen(obuf)) < 0){
  78:	00001917          	auipc	s2,0x1
  7c:	ea890913          	addi	s2,s2,-344 # f20 <malloc+0x100>
  for(int i = 0; i < attempts; i++) {
  80:	03405463          	blez	s4,a8 <ping+0x5e>
    if(write(fd, obuf, strlen(obuf)) < 0){
  84:	854a                	mv	a0,s2
  86:	00000097          	auipc	ra,0x0
  8a:	71a080e7          	jalr	1818(ra) # 7a0 <strlen>
  8e:	0005061b          	sext.w	a2,a0
  92:	85ca                	mv	a1,s2
  94:	854e                	mv	a0,s3
  96:	00001097          	auipc	ra,0x1
  9a:	96a080e7          	jalr	-1686(ra) # a00 <write>
  9e:	06054c63          	bltz	a0,116 <ping+0xcc>
  for(int i = 0; i < attempts; i++) {
  a2:	2485                	addiw	s1,s1,1
  a4:	fe9a10e3          	bne	s4,s1,84 <ping+0x3a>
  int cc = read(fd, ibuf, sizeof(ibuf)-1);
  a8:	07f00613          	li	a2,127
  ac:	f5040593          	addi	a1,s0,-176
  b0:	854e                	mv	a0,s3
  b2:	00001097          	auipc	ra,0x1
  b6:	946080e7          	jalr	-1722(ra) # 9f8 <read>
  ba:	84aa                	mv	s1,a0
  if(cc < 0){
  bc:	06054b63          	bltz	a0,132 <ping+0xe8>
  close(fd);
  c0:	854e                	mv	a0,s3
  c2:	00001097          	auipc	ra,0x1
  c6:	946080e7          	jalr	-1722(ra) # a08 <close>
  ibuf[cc] = '\0';
  ca:	fd040793          	addi	a5,s0,-48
  ce:	94be                	add	s1,s1,a5
  d0:	f8048023          	sb	zero,-128(s1)
  if(strcmp(ibuf, "this is the host!") != 0){
  d4:	00001597          	auipc	a1,0x1
  d8:	e9458593          	addi	a1,a1,-364 # f68 <malloc+0x148>
  dc:	f5040513          	addi	a0,s0,-176
  e0:	00000097          	auipc	ra,0x0
  e4:	68c080e7          	jalr	1676(ra) # 76c <strcmp>
  e8:	e13d                	bnez	a0,14e <ping+0x104>
}
  ea:	70aa                	ld	ra,168(sp)
  ec:	740a                	ld	s0,160(sp)
  ee:	64ea                	ld	s1,152(sp)
  f0:	694a                	ld	s2,144(sp)
  f2:	69aa                	ld	s3,136(sp)
  f4:	6a0a                	ld	s4,128(sp)
  f6:	614d                	addi	sp,sp,176
  f8:	8082                	ret
    fprintf(2, "ping: connect() failed\n");
  fa:	00001597          	auipc	a1,0x1
  fe:	e0e58593          	addi	a1,a1,-498 # f08 <malloc+0xe8>
 102:	4509                	li	a0,2
 104:	00001097          	auipc	ra,0x1
 108:	c2e080e7          	jalr	-978(ra) # d32 <fprintf>
    exit(1);
 10c:	4505                	li	a0,1
 10e:	00001097          	auipc	ra,0x1
 112:	8d2080e7          	jalr	-1838(ra) # 9e0 <exit>
      fprintf(2, "ping: send() failed\n");
 116:	00001597          	auipc	a1,0x1
 11a:	e2258593          	addi	a1,a1,-478 # f38 <malloc+0x118>
 11e:	4509                	li	a0,2
 120:	00001097          	auipc	ra,0x1
 124:	c12080e7          	jalr	-1006(ra) # d32 <fprintf>
      exit(1);
 128:	4505                	li	a0,1
 12a:	00001097          	auipc	ra,0x1
 12e:	8b6080e7          	jalr	-1866(ra) # 9e0 <exit>
    fprintf(2, "ping: recv() failed\n");
 132:	00001597          	auipc	a1,0x1
 136:	e1e58593          	addi	a1,a1,-482 # f50 <malloc+0x130>
 13a:	4509                	li	a0,2
 13c:	00001097          	auipc	ra,0x1
 140:	bf6080e7          	jalr	-1034(ra) # d32 <fprintf>
    exit(1);
 144:	4505                	li	a0,1
 146:	00001097          	auipc	ra,0x1
 14a:	89a080e7          	jalr	-1894(ra) # 9e0 <exit>
    fprintf(2, "ping didn't receive correct payload\n");
 14e:	00001597          	auipc	a1,0x1
 152:	e3258593          	addi	a1,a1,-462 # f80 <malloc+0x160>
 156:	4509                	li	a0,2
 158:	00001097          	auipc	ra,0x1
 15c:	bda080e7          	jalr	-1062(ra) # d32 <fprintf>
    exit(1);
 160:	4505                	li	a0,1
 162:	00001097          	auipc	ra,0x1
 166:	87e080e7          	jalr	-1922(ra) # 9e0 <exit>

000000000000016a <dns>:
  }
}

static void
dns()
{
 16a:	7119                	addi	sp,sp,-128
 16c:	fc86                	sd	ra,120(sp)
 16e:	f8a2                	sd	s0,112(sp)
 170:	f4a6                	sd	s1,104(sp)
 172:	f0ca                	sd	s2,96(sp)
 174:	ecce                	sd	s3,88(sp)
 176:	e8d2                	sd	s4,80(sp)
 178:	e4d6                	sd	s5,72(sp)
 17a:	e0da                	sd	s6,64(sp)
 17c:	fc5e                	sd	s7,56(sp)
 17e:	f862                	sd	s8,48(sp)
 180:	f466                	sd	s9,40(sp)
 182:	f06a                	sd	s10,32(sp)
 184:	ec6e                	sd	s11,24(sp)
 186:	0100                	addi	s0,sp,128
 188:	83010113          	addi	sp,sp,-2000
  uint8 ibuf[N];
  uint32 dst;
  int fd;
  int len;

  memset(obuf, 0, N);
 18c:	3e800613          	li	a2,1000
 190:	4581                	li	a1,0
 192:	ba840513          	addi	a0,s0,-1112
 196:	00000097          	auipc	ra,0x0
 19a:	634080e7          	jalr	1588(ra) # 7ca <memset>
  memset(ibuf, 0, N);
 19e:	3e800613          	li	a2,1000
 1a2:	4581                	li	a1,0
 1a4:	77fd                	lui	a5,0xfffff
 1a6:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde48>
 1aa:	00f40533          	add	a0,s0,a5
 1ae:	00000097          	auipc	ra,0x0
 1b2:	61c080e7          	jalr	1564(ra) # 7ca <memset>
  
  // 8.8.8.8: google's name server
  dst = (8 << 24) | (8 << 16) | (8 << 8) | (8 << 0);

  if((fd = connect(dst, 10000, 53)) < 0){
 1b6:	03500613          	li	a2,53
 1ba:	6589                	lui	a1,0x2
 1bc:	71058593          	addi	a1,a1,1808 # 2710 <__global_pointer$+0xd98>
 1c0:	08081537          	lui	a0,0x8081
 1c4:	80850513          	addi	a0,a0,-2040 # 8080808 <__global_pointer$+0x807ee90>
 1c8:	00001097          	auipc	ra,0x1
 1cc:	8b8080e7          	jalr	-1864(ra) # a80 <connect>
 1d0:	02054d63          	bltz	a0,20a <dns+0xa0>
 1d4:	89aa                	mv	s3,a0
  hdr->id = htons(6828);
 1d6:	77ed                	lui	a5,0xffffb
 1d8:	c1a7879b          	addiw	a5,a5,-998
 1dc:	baf41423          	sh	a5,-1112(s0)
  hdr->rd = 1;
 1e0:	baa45783          	lhu	a5,-1110(s0)
 1e4:	0017e793          	ori	a5,a5,1
 1e8:	baf41523          	sh	a5,-1110(s0)
  hdr->qdcount = htons(1);
 1ec:	10000793          	li	a5,256
 1f0:	baf41623          	sh	a5,-1108(s0)
  for(char *c = host; c < host+strlen(host)+1; c++) {
 1f4:	00001497          	auipc	s1,0x1
 1f8:	db448493          	addi	s1,s1,-588 # fa8 <malloc+0x188>
  char *l = host; 
 1fc:	8a26                	mv	s4,s1
  hdr->qdcount = htons(1);
 1fe:	bb440913          	addi	s2,s0,-1100
  for(char *c = host; c < host+strlen(host)+1; c++) {
 202:	8aa6                	mv	s5,s1
    if(*c == '.') {
 204:	02e00b13          	li	s6,46
 208:	a01d                	j	22e <dns+0xc4>
    fprintf(2, "ping: connect() failed\n");
 20a:	00001597          	auipc	a1,0x1
 20e:	cfe58593          	addi	a1,a1,-770 # f08 <malloc+0xe8>
 212:	4509                	li	a0,2
 214:	00001097          	auipc	ra,0x1
 218:	b1e080e7          	jalr	-1250(ra) # d32 <fprintf>
    exit(1);
 21c:	4505                	li	a0,1
 21e:	00000097          	auipc	ra,0x0
 222:	7c2080e7          	jalr	1986(ra) # 9e0 <exit>
      *qn++ = (char) (c-l);
 226:	8936                	mv	s2,a3
      l = c+1; // skip .
 228:	00148a13          	addi	s4,s1,1
  for(char *c = host; c < host+strlen(host)+1; c++) {
 22c:	0485                	addi	s1,s1,1
 22e:	8556                	mv	a0,s5
 230:	00000097          	auipc	ra,0x0
 234:	570080e7          	jalr	1392(ra) # 7a0 <strlen>
 238:	1502                	slli	a0,a0,0x20
 23a:	9101                	srli	a0,a0,0x20
 23c:	0505                	addi	a0,a0,1
 23e:	9556                	add	a0,a0,s5
 240:	02a4fc63          	bleu	a0,s1,278 <dns+0x10e>
    if(*c == '.') {
 244:	0004c783          	lbu	a5,0(s1)
 248:	ff6792e3          	bne	a5,s6,22c <dns+0xc2>
      *qn++ = (char) (c-l);
 24c:	00190693          	addi	a3,s2,1
 250:	414487b3          	sub	a5,s1,s4
 254:	00f90023          	sb	a5,0(s2)
      for(char *d = l; d < c; d++) {
 258:	fc9a77e3          	bleu	s1,s4,226 <dns+0xbc>
 25c:	87d2                	mv	a5,s4
      *qn++ = (char) (c-l);
 25e:	8736                	mv	a4,a3
        *qn++ = *d;
 260:	0705                	addi	a4,a4,1
 262:	0007c603          	lbu	a2,0(a5) # ffffffffffffb000 <__global_pointer$+0xffffffffffff9688>
 266:	fec70fa3          	sb	a2,-1(a4)
      for(char *d = l; d < c; d++) {
 26a:	0785                	addi	a5,a5,1
 26c:	fef49ae3          	bne	s1,a5,260 <dns+0xf6>
 270:	41448933          	sub	s2,s1,s4
 274:	9936                	add	s2,s2,a3
 276:	bf4d                	j	228 <dns+0xbe>
  *qn = '\0';
 278:	00090023          	sb	zero,0(s2)
  len += strlen(qname) + 1;
 27c:	bb440513          	addi	a0,s0,-1100
 280:	00000097          	auipc	ra,0x0
 284:	520080e7          	jalr	1312(ra) # 7a0 <strlen>
 288:	0005049b          	sext.w	s1,a0
  struct dns_question *h = (struct dns_question *) (qname+strlen(qname)+1);
 28c:	bb440513          	addi	a0,s0,-1100
 290:	00000097          	auipc	ra,0x0
 294:	510080e7          	jalr	1296(ra) # 7a0 <strlen>
 298:	1502                	slli	a0,a0,0x20
 29a:	9101                	srli	a0,a0,0x20
 29c:	0505                	addi	a0,a0,1
 29e:	bb440793          	addi	a5,s0,-1100
 2a2:	953e                	add	a0,a0,a5
  h->qtype = htons(0x1);
 2a4:	00050023          	sb	zero,0(a0)
 2a8:	4785                	li	a5,1
 2aa:	00f500a3          	sb	a5,1(a0)
  h->qclass = htons(0x1);
 2ae:	00050123          	sb	zero,2(a0)
 2b2:	00f501a3          	sb	a5,3(a0)
  }

  len = dns_req(obuf);
  
  if(write(fd, obuf, len) < 0){
 2b6:	0114861b          	addiw	a2,s1,17
 2ba:	ba840593          	addi	a1,s0,-1112
 2be:	854e                	mv	a0,s3
 2c0:	00000097          	auipc	ra,0x0
 2c4:	740080e7          	jalr	1856(ra) # a00 <write>
 2c8:	10054c63          	bltz	a0,3e0 <dns+0x276>
    fprintf(2, "dns: send() failed\n");
    exit(1);
  }
  int cc = read(fd, ibuf, sizeof(ibuf));
 2cc:	3e800613          	li	a2,1000
 2d0:	77fd                	lui	a5,0xfffff
 2d2:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde48>
 2d6:	00f405b3          	add	a1,s0,a5
 2da:	854e                	mv	a0,s3
 2dc:	00000097          	auipc	ra,0x0
 2e0:	71c080e7          	jalr	1820(ra) # 9f8 <read>
 2e4:	8aaa                	mv	s5,a0
  if(cc < 0){
 2e6:	10054b63          	bltz	a0,3fc <dns+0x292>
  if(!hdr->qr) {
 2ea:	77fd                	lui	a5,0xfffff
 2ec:	7c278793          	addi	a5,a5,1986 # fffffffffffff7c2 <__global_pointer$+0xffffffffffffde4a>
 2f0:	97a2                	add	a5,a5,s0
 2f2:	00078783          	lb	a5,0(a5)
 2f6:	1207d163          	bgez	a5,418 <dns+0x2ae>
  if(hdr->id != htons(6828))
 2fa:	77fd                	lui	a5,0xfffff
 2fc:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde48>
 300:	97a2                	add	a5,a5,s0
 302:	0007d783          	lhu	a5,0(a5)
 306:	0007869b          	sext.w	a3,a5
 30a:	672d                	lui	a4,0xb
 30c:	c1a70713          	addi	a4,a4,-998 # ac1a <__global_pointer$+0x92a2>
 310:	10e69963          	bne	a3,a4,422 <dns+0x2b8>
  if(hdr->rcode != 0) {
 314:	777d                	lui	a4,0xfffff
 316:	7c370793          	addi	a5,a4,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffde4b>
 31a:	97a2                	add	a5,a5,s0
 31c:	0007c783          	lbu	a5,0(a5)
 320:	8bbd                	andi	a5,a5,15
 322:	12079063          	bnez	a5,442 <dns+0x2d8>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
 326:	7c470793          	addi	a5,a4,1988
 32a:	97a2                	add	a5,a5,s0
 32c:	0007d783          	lhu	a5,0(a5)
 330:	0087d713          	srli	a4,a5,0x8
 334:	0087979b          	slliw	a5,a5,0x8
 338:	0ff77713          	andi	a4,a4,255
 33c:	8fd9                	or	a5,a5,a4
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 33e:	17c2                	slli	a5,a5,0x30
 340:	93c1                	srli	a5,a5,0x30
 342:	4a01                	li	s4,0
  len = sizeof(struct dns);
 344:	44b1                	li	s1,12
  char *qname = 0;
 346:	4901                	li	s2,0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 348:	c7a1                	beqz	a5,390 <dns+0x226>
    char *qn = (char *) (ibuf+len);
 34a:	7b7d                	lui	s6,0xfffff
 34c:	7c0b0793          	addi	a5,s6,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde48>
 350:	97a2                	add	a5,a5,s0
 352:	00978933          	add	s2,a5,s1
    decode_qname(qn);
 356:	854a                	mv	a0,s2
 358:	00000097          	auipc	ra,0x0
 35c:	ca8080e7          	jalr	-856(ra) # 0 <decode_qname>
    len += strlen(qn)+1;
 360:	854a                	mv	a0,s2
 362:	00000097          	auipc	ra,0x0
 366:	43e080e7          	jalr	1086(ra) # 7a0 <strlen>
    len += sizeof(struct dns_question);
 36a:	2515                	addiw	a0,a0,5
 36c:	9ca9                	addw	s1,s1,a0
  for(int i =0; i < ntohs(hdr->qdcount); i++) {
 36e:	2a05                	addiw	s4,s4,1
 370:	7c4b0793          	addi	a5,s6,1988
 374:	97a2                	add	a5,a5,s0
 376:	0007d783          	lhu	a5,0(a5)
 37a:	0087d713          	srli	a4,a5,0x8
 37e:	0087979b          	slliw	a5,a5,0x8
 382:	0ff77713          	andi	a4,a4,255
 386:	8fd9                	or	a5,a5,a4
 388:	17c2                	slli	a5,a5,0x30
 38a:	93c1                	srli	a5,a5,0x30
 38c:	fafa4fe3          	blt	s4,a5,34a <dns+0x1e0>
 390:	77fd                	lui	a5,0xfffff
 392:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffde4e>
 396:	97a2                	add	a5,a5,s0
 398:	0007d783          	lhu	a5,0(a5)
 39c:	0087d713          	srli	a4,a5,0x8
 3a0:	0087979b          	slliw	a5,a5,0x8
 3a4:	0ff77713          	andi	a4,a4,255
 3a8:	8fd9                	or	a5,a5,a4
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 3aa:	17c2                	slli	a5,a5,0x30
 3ac:	93c1                	srli	a5,a5,0x30
 3ae:	22078b63          	beqz	a5,5e4 <dns+0x47a>
 3b2:	00001797          	auipc	a5,0x1
 3b6:	cd678793          	addi	a5,a5,-810 # 1088 <malloc+0x268>
 3ba:	00090363          	beqz	s2,3c0 <dns+0x256>
 3be:	87ca                	mv	a5,s2
 3c0:	777d                	lui	a4,0xfffff
 3c2:	7b870713          	addi	a4,a4,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffde40>
 3c6:	9722                	add	a4,a4,s0
 3c8:	e31c                	sd	a5,0(a4)
  int record = 0;
 3ca:	4b81                	li	s7,0
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 3cc:	4a01                	li	s4,0
    if((int) qn[0] > 63) {  // compression?
 3ce:	03f00d93          	li	s11,63
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 3d2:	4b05                	li	s6,1
 3d4:	4d11                	li	s10,4
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 3d6:	08000c93          	li	s9,128
 3da:	03400c13          	li	s8,52
 3de:	a8c1                	j	4ae <dns+0x344>
    fprintf(2, "dns: send() failed\n");
 3e0:	00001597          	auipc	a1,0x1
 3e4:	be058593          	addi	a1,a1,-1056 # fc0 <malloc+0x1a0>
 3e8:	4509                	li	a0,2
 3ea:	00001097          	auipc	ra,0x1
 3ee:	948080e7          	jalr	-1720(ra) # d32 <fprintf>
    exit(1);
 3f2:	4505                	li	a0,1
 3f4:	00000097          	auipc	ra,0x0
 3f8:	5ec080e7          	jalr	1516(ra) # 9e0 <exit>
    fprintf(2, "dns: recv() failed\n");
 3fc:	00001597          	auipc	a1,0x1
 400:	bdc58593          	addi	a1,a1,-1060 # fd8 <malloc+0x1b8>
 404:	4509                	li	a0,2
 406:	00001097          	auipc	ra,0x1
 40a:	92c080e7          	jalr	-1748(ra) # d32 <fprintf>
    exit(1);
 40e:	4505                	li	a0,1
 410:	00000097          	auipc	ra,0x0
 414:	5d0080e7          	jalr	1488(ra) # 9e0 <exit>
    exit(1);
 418:	4505                	li	a0,1
 41a:	00000097          	auipc	ra,0x0
 41e:	5c6080e7          	jalr	1478(ra) # 9e0 <exit>
 422:	0087d59b          	srliw	a1,a5,0x8
 426:	0087979b          	slliw	a5,a5,0x8
 42a:	8ddd                	or	a1,a1,a5
    printf("DNS wrong id: %d\n", ntohs(hdr->id));
 42c:	15c2                	slli	a1,a1,0x30
 42e:	91c1                	srli	a1,a1,0x30
 430:	00001517          	auipc	a0,0x1
 434:	bc050513          	addi	a0,a0,-1088 # ff0 <malloc+0x1d0>
 438:	00001097          	auipc	ra,0x1
 43c:	928080e7          	jalr	-1752(ra) # d60 <printf>
 440:	bdd1                	j	314 <dns+0x1aa>
    printf("DNS rcode error: %x\n", hdr->rcode);
 442:	77fd                	lui	a5,0xfffff
 444:	7c378793          	addi	a5,a5,1987 # fffffffffffff7c3 <__global_pointer$+0xffffffffffffde4b>
 448:	97a2                	add	a5,a5,s0
 44a:	0007c583          	lbu	a1,0(a5)
 44e:	89bd                	andi	a1,a1,15
 450:	00001517          	auipc	a0,0x1
 454:	bb850513          	addi	a0,a0,-1096 # 1008 <malloc+0x1e8>
 458:	00001097          	auipc	ra,0x1
 45c:	908080e7          	jalr	-1784(ra) # d60 <printf>
    exit(1);
 460:	4505                	li	a0,1
 462:	00000097          	auipc	ra,0x0
 466:	57e080e7          	jalr	1406(ra) # 9e0 <exit>
      decode_qname(qn);
 46a:	854a                	mv	a0,s2
 46c:	00000097          	auipc	ra,0x0
 470:	b94080e7          	jalr	-1132(ra) # 0 <decode_qname>
      len += strlen(qn)+1;
 474:	854a                	mv	a0,s2
 476:	00000097          	auipc	ra,0x0
 47a:	32a080e7          	jalr	810(ra) # 7a0 <strlen>
 47e:	2485                	addiw	s1,s1,1
 480:	9ca9                	addw	s1,s1,a0
 482:	a089                	j	4c4 <dns+0x35a>
      len += 4;
 484:	00e9049b          	addiw	s1,s2,14
      record = 1;
 488:	8bda                	mv	s7,s6
  for(int i = 0; i < ntohs(hdr->ancount); i++) {
 48a:	2a05                	addiw	s4,s4,1
 48c:	77fd                	lui	a5,0xfffff
 48e:	7c678793          	addi	a5,a5,1990 # fffffffffffff7c6 <__global_pointer$+0xffffffffffffde4e>
 492:	97a2                	add	a5,a5,s0
 494:	0007d783          	lhu	a5,0(a5)
 498:	0087d713          	srli	a4,a5,0x8
 49c:	0087979b          	slliw	a5,a5,0x8
 4a0:	0ff77713          	andi	a4,a4,255
 4a4:	8fd9                	or	a5,a5,a4
 4a6:	17c2                	slli	a5,a5,0x30
 4a8:	93c1                	srli	a5,a5,0x30
 4aa:	0efa5663          	ble	a5,s4,596 <dns+0x42c>
    char *qn = (char *) (ibuf+len);
 4ae:	77fd                	lui	a5,0xfffff
 4b0:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde48>
 4b4:	97a2                	add	a5,a5,s0
 4b6:	00978933          	add	s2,a5,s1
    if((int) qn[0] > 63) {  // compression?
 4ba:	00094783          	lbu	a5,0(s2)
 4be:	fafdf6e3          	bleu	a5,s11,46a <dns+0x300>
      len += 2;
 4c2:	2489                	addiw	s1,s1,2
    struct dns_data *d = (struct dns_data *) (ibuf+len);
 4c4:	77fd                	lui	a5,0xfffff
 4c6:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde48>
 4ca:	97a2                	add	a5,a5,s0
 4cc:	009786b3          	add	a3,a5,s1
    len += sizeof(struct dns_data);
 4d0:	0004891b          	sext.w	s2,s1
 4d4:	00a9049b          	addiw	s1,s2,10
    if(ntohs(d->type) == ARECORD && ntohs(d->len) == 4) {
 4d8:	0006c783          	lbu	a5,0(a3)
 4dc:	0016c703          	lbu	a4,1(a3)
 4e0:	0722                	slli	a4,a4,0x8
 4e2:	8fd9                	or	a5,a5,a4
 4e4:	8321                	srli	a4,a4,0x8
 4e6:	0087979b          	slliw	a5,a5,0x8
 4ea:	8fd9                	or	a5,a5,a4
 4ec:	17c2                	slli	a5,a5,0x30
 4ee:	93c1                	srli	a5,a5,0x30
 4f0:	f9679de3          	bne	a5,s6,48a <dns+0x320>
 4f4:	0086c783          	lbu	a5,8(a3)
 4f8:	0096c703          	lbu	a4,9(a3)
 4fc:	0722                	slli	a4,a4,0x8
 4fe:	8fd9                	or	a5,a5,a4
 500:	8321                	srli	a4,a4,0x8
 502:	0087979b          	slliw	a5,a5,0x8
 506:	8fd9                	or	a5,a5,a4
 508:	17c2                	slli	a5,a5,0x30
 50a:	93c1                	srli	a5,a5,0x30
 50c:	f7a79fe3          	bne	a5,s10,48a <dns+0x320>
      printf("DNS arecord for %s is ", qname ? qname : "" );
 510:	77fd                	lui	a5,0xfffff
 512:	7b878793          	addi	a5,a5,1976 # fffffffffffff7b8 <__global_pointer$+0xffffffffffffde40>
 516:	97a2                	add	a5,a5,s0
 518:	638c                	ld	a1,0(a5)
 51a:	00001517          	auipc	a0,0x1
 51e:	b0650513          	addi	a0,a0,-1274 # 1020 <malloc+0x200>
 522:	00001097          	auipc	ra,0x1
 526:	83e080e7          	jalr	-1986(ra) # d60 <printf>
      uint8 *ip = (ibuf+len);
 52a:	77fd                	lui	a5,0xfffff
 52c:	7c078793          	addi	a5,a5,1984 # fffffffffffff7c0 <__global_pointer$+0xffffffffffffde48>
 530:	97a2                	add	a5,a5,s0
 532:	94be                	add	s1,s1,a5
      printf("%d.%d.%d.%d\n", ip[0], ip[1], ip[2], ip[3]);
 534:	0034c703          	lbu	a4,3(s1)
 538:	0024c683          	lbu	a3,2(s1)
 53c:	0014c603          	lbu	a2,1(s1)
 540:	0004c583          	lbu	a1,0(s1)
 544:	00001517          	auipc	a0,0x1
 548:	af450513          	addi	a0,a0,-1292 # 1038 <malloc+0x218>
 54c:	00001097          	auipc	ra,0x1
 550:	814080e7          	jalr	-2028(ra) # d60 <printf>
      if(ip[0] != 128 || ip[1] != 52 || ip[2] != 129 || ip[3] != 126) {
 554:	0004c783          	lbu	a5,0(s1)
 558:	03979263          	bne	a5,s9,57c <dns+0x412>
 55c:	0014c783          	lbu	a5,1(s1)
 560:	01879e63          	bne	a5,s8,57c <dns+0x412>
 564:	0024c703          	lbu	a4,2(s1)
 568:	08100793          	li	a5,129
 56c:	00f71863          	bne	a4,a5,57c <dns+0x412>
 570:	0034c703          	lbu	a4,3(s1)
 574:	07e00793          	li	a5,126
 578:	f0f706e3          	beq	a4,a5,484 <dns+0x31a>
        printf("wrong ip address");
 57c:	00001517          	auipc	a0,0x1
 580:	acc50513          	addi	a0,a0,-1332 # 1048 <malloc+0x228>
 584:	00000097          	auipc	ra,0x0
 588:	7dc080e7          	jalr	2012(ra) # d60 <printf>
        exit(1);
 58c:	4505                	li	a0,1
 58e:	00000097          	auipc	ra,0x0
 592:	452080e7          	jalr	1106(ra) # 9e0 <exit>
  if(len != cc) {
 596:	049a9963          	bne	s5,s1,5e8 <dns+0x47e>
  if(!record) {
 59a:	020b8863          	beqz	s7,5ca <dns+0x460>
  }
  dns_rep(ibuf, cc);

  close(fd);
 59e:	854e                	mv	a0,s3
 5a0:	00000097          	auipc	ra,0x0
 5a4:	468080e7          	jalr	1128(ra) # a08 <close>
}  
 5a8:	7d010113          	addi	sp,sp,2000
 5ac:	70e6                	ld	ra,120(sp)
 5ae:	7446                	ld	s0,112(sp)
 5b0:	74a6                	ld	s1,104(sp)
 5b2:	7906                	ld	s2,96(sp)
 5b4:	69e6                	ld	s3,88(sp)
 5b6:	6a46                	ld	s4,80(sp)
 5b8:	6aa6                	ld	s5,72(sp)
 5ba:	6b06                	ld	s6,64(sp)
 5bc:	7be2                	ld	s7,56(sp)
 5be:	7c42                	ld	s8,48(sp)
 5c0:	7ca2                	ld	s9,40(sp)
 5c2:	7d02                	ld	s10,32(sp)
 5c4:	6de2                	ld	s11,24(sp)
 5c6:	6109                	addi	sp,sp,128
 5c8:	8082                	ret
    printf("Didn't receive an arecord\n");
 5ca:	00001517          	auipc	a0,0x1
 5ce:	ac650513          	addi	a0,a0,-1338 # 1090 <malloc+0x270>
 5d2:	00000097          	auipc	ra,0x0
 5d6:	78e080e7          	jalr	1934(ra) # d60 <printf>
    exit(1);
 5da:	4505                	li	a0,1
 5dc:	00000097          	auipc	ra,0x0
 5e0:	404080e7          	jalr	1028(ra) # 9e0 <exit>
  if(len != cc) {
 5e4:	fe9a83e3          	beq	s5,s1,5ca <dns+0x460>
    printf("Processed %d data bytes but received %d\n", len, cc);
 5e8:	8656                	mv	a2,s5
 5ea:	85a6                	mv	a1,s1
 5ec:	00001517          	auipc	a0,0x1
 5f0:	a7450513          	addi	a0,a0,-1420 # 1060 <malloc+0x240>
 5f4:	00000097          	auipc	ra,0x0
 5f8:	76c080e7          	jalr	1900(ra) # d60 <printf>
    exit(1);
 5fc:	4505                	li	a0,1
 5fe:	00000097          	auipc	ra,0x0
 602:	3e2080e7          	jalr	994(ra) # 9e0 <exit>

0000000000000606 <main>:

int
main(int argc, char *argv[])
{
 606:	7179                	addi	sp,sp,-48
 608:	f406                	sd	ra,40(sp)
 60a:	f022                	sd	s0,32(sp)
 60c:	ec26                	sd	s1,24(sp)
 60e:	e84a                	sd	s2,16(sp)
 610:	1800                	addi	s0,sp,48
  int i, ret;
  uint16 dport = NET_TESTS_PORT;

  printf("nettests running on port %d\n", dport);
 612:	6499                	lui	s1,0x6
 614:	5f348593          	addi	a1,s1,1523 # 65f3 <__global_pointer$+0x4c7b>
 618:	00001517          	auipc	a0,0x1
 61c:	a9850513          	addi	a0,a0,-1384 # 10b0 <malloc+0x290>
 620:	00000097          	auipc	ra,0x0
 624:	740080e7          	jalr	1856(ra) # d60 <printf>

  printf("testing ping: ");
 628:	00001517          	auipc	a0,0x1
 62c:	aa850513          	addi	a0,a0,-1368 # 10d0 <malloc+0x2b0>
 630:	00000097          	auipc	ra,0x0
 634:	730080e7          	jalr	1840(ra) # d60 <printf>
  ping(2000, dport, 1);
 638:	4605                	li	a2,1
 63a:	5f348593          	addi	a1,s1,1523
 63e:	7d000513          	li	a0,2000
 642:	00000097          	auipc	ra,0x0
 646:	a08080e7          	jalr	-1528(ra) # 4a <ping>
  printf("OK\n");
 64a:	00001517          	auipc	a0,0x1
 64e:	a9650513          	addi	a0,a0,-1386 # 10e0 <malloc+0x2c0>
 652:	00000097          	auipc	ra,0x0
 656:	70e080e7          	jalr	1806(ra) # d60 <printf>

  printf("testing single-process pings: ");
 65a:	00001517          	auipc	a0,0x1
 65e:	a8e50513          	addi	a0,a0,-1394 # 10e8 <malloc+0x2c8>
 662:	00000097          	auipc	ra,0x0
 666:	6fe080e7          	jalr	1790(ra) # d60 <printf>
 66a:	06400493          	li	s1,100
  for (i = 0; i < 100; i++)
    ping(2000, dport, 1);
 66e:	6919                	lui	s2,0x6
 670:	5f390913          	addi	s2,s2,1523 # 65f3 <__global_pointer$+0x4c7b>
 674:	4605                	li	a2,1
 676:	85ca                	mv	a1,s2
 678:	7d000513          	li	a0,2000
 67c:	00000097          	auipc	ra,0x0
 680:	9ce080e7          	jalr	-1586(ra) # 4a <ping>
  for (i = 0; i < 100; i++)
 684:	34fd                	addiw	s1,s1,-1
 686:	f4fd                	bnez	s1,674 <main+0x6e>
  printf("OK\n");
 688:	00001517          	auipc	a0,0x1
 68c:	a5850513          	addi	a0,a0,-1448 # 10e0 <malloc+0x2c0>
 690:	00000097          	auipc	ra,0x0
 694:	6d0080e7          	jalr	1744(ra) # d60 <printf>

  printf("testing multi-process pings: ");
 698:	00001517          	auipc	a0,0x1
 69c:	a7050513          	addi	a0,a0,-1424 # 1108 <malloc+0x2e8>
 6a0:	00000097          	auipc	ra,0x0
 6a4:	6c0080e7          	jalr	1728(ra) # d60 <printf>
  for (i = 0; i < 10; i++){
 6a8:	4929                	li	s2,10
    int pid = fork();
 6aa:	00000097          	auipc	ra,0x0
 6ae:	32e080e7          	jalr	814(ra) # 9d8 <fork>
    if (pid == 0){
 6b2:	c92d                	beqz	a0,724 <main+0x11e>
  for (i = 0; i < 10; i++){
 6b4:	2485                	addiw	s1,s1,1
 6b6:	ff249ae3          	bne	s1,s2,6aa <main+0xa4>
 6ba:	44a9                	li	s1,10
      ping(2000 + i + 1, dport, 1);
      exit(0);
    }
  }
  for (i = 0; i < 10; i++){
    wait(&ret);
 6bc:	fdc40513          	addi	a0,s0,-36
 6c0:	00000097          	auipc	ra,0x0
 6c4:	328080e7          	jalr	808(ra) # 9e8 <wait>
    if (ret != 0)
 6c8:	fdc42783          	lw	a5,-36(s0)
 6cc:	efad                	bnez	a5,746 <main+0x140>
  for (i = 0; i < 10; i++){
 6ce:	34fd                	addiw	s1,s1,-1
 6d0:	f4f5                	bnez	s1,6bc <main+0xb6>
      exit(1);
  }
  printf("OK\n");
 6d2:	00001517          	auipc	a0,0x1
 6d6:	a0e50513          	addi	a0,a0,-1522 # 10e0 <malloc+0x2c0>
 6da:	00000097          	auipc	ra,0x0
 6de:	686080e7          	jalr	1670(ra) # d60 <printf>
  
  printf("testing DNS\n");
 6e2:	00001517          	auipc	a0,0x1
 6e6:	a4650513          	addi	a0,a0,-1466 # 1128 <malloc+0x308>
 6ea:	00000097          	auipc	ra,0x0
 6ee:	676080e7          	jalr	1654(ra) # d60 <printf>
  dns();
 6f2:	00000097          	auipc	ra,0x0
 6f6:	a78080e7          	jalr	-1416(ra) # 16a <dns>
  printf("DNS OK\n");
 6fa:	00001517          	auipc	a0,0x1
 6fe:	a3e50513          	addi	a0,a0,-1474 # 1138 <malloc+0x318>
 702:	00000097          	auipc	ra,0x0
 706:	65e080e7          	jalr	1630(ra) # d60 <printf>
  
  printf("all tests passed.\n");
 70a:	00001517          	auipc	a0,0x1
 70e:	a3650513          	addi	a0,a0,-1482 # 1140 <malloc+0x320>
 712:	00000097          	auipc	ra,0x0
 716:	64e080e7          	jalr	1614(ra) # d60 <printf>
  exit(0);
 71a:	4501                	li	a0,0
 71c:	00000097          	auipc	ra,0x0
 720:	2c4080e7          	jalr	708(ra) # 9e0 <exit>
      ping(2000 + i + 1, dport, 1);
 724:	7d14851b          	addiw	a0,s1,2001
 728:	4605                	li	a2,1
 72a:	6599                	lui	a1,0x6
 72c:	5f358593          	addi	a1,a1,1523 # 65f3 <__global_pointer$+0x4c7b>
 730:	1542                	slli	a0,a0,0x30
 732:	9141                	srli	a0,a0,0x30
 734:	00000097          	auipc	ra,0x0
 738:	916080e7          	jalr	-1770(ra) # 4a <ping>
      exit(0);
 73c:	4501                	li	a0,0
 73e:	00000097          	auipc	ra,0x0
 742:	2a2080e7          	jalr	674(ra) # 9e0 <exit>
      exit(1);
 746:	4505                	li	a0,1
 748:	00000097          	auipc	ra,0x0
 74c:	298080e7          	jalr	664(ra) # 9e0 <exit>

0000000000000750 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 750:	1141                	addi	sp,sp,-16
 752:	e422                	sd	s0,8(sp)
 754:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 756:	87aa                	mv	a5,a0
 758:	0585                	addi	a1,a1,1
 75a:	0785                	addi	a5,a5,1
 75c:	fff5c703          	lbu	a4,-1(a1)
 760:	fee78fa3          	sb	a4,-1(a5)
 764:	fb75                	bnez	a4,758 <strcpy+0x8>
    ;
  return os;
}
 766:	6422                	ld	s0,8(sp)
 768:	0141                	addi	sp,sp,16
 76a:	8082                	ret

000000000000076c <strcmp>:

int
strcmp(const char *p, const char *q)
{
 76c:	1141                	addi	sp,sp,-16
 76e:	e422                	sd	s0,8(sp)
 770:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 772:	00054783          	lbu	a5,0(a0)
 776:	cf91                	beqz	a5,792 <strcmp+0x26>
 778:	0005c703          	lbu	a4,0(a1)
 77c:	00f71b63          	bne	a4,a5,792 <strcmp+0x26>
    p++, q++;
 780:	0505                	addi	a0,a0,1
 782:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 784:	00054783          	lbu	a5,0(a0)
 788:	c789                	beqz	a5,792 <strcmp+0x26>
 78a:	0005c703          	lbu	a4,0(a1)
 78e:	fef709e3          	beq	a4,a5,780 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 792:	0005c503          	lbu	a0,0(a1)
}
 796:	40a7853b          	subw	a0,a5,a0
 79a:	6422                	ld	s0,8(sp)
 79c:	0141                	addi	sp,sp,16
 79e:	8082                	ret

00000000000007a0 <strlen>:

uint
strlen(const char *s)
{
 7a0:	1141                	addi	sp,sp,-16
 7a2:	e422                	sd	s0,8(sp)
 7a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 7a6:	00054783          	lbu	a5,0(a0)
 7aa:	cf91                	beqz	a5,7c6 <strlen+0x26>
 7ac:	0505                	addi	a0,a0,1
 7ae:	87aa                	mv	a5,a0
 7b0:	4685                	li	a3,1
 7b2:	9e89                	subw	a3,a3,a0
 7b4:	00f6853b          	addw	a0,a3,a5
 7b8:	0785                	addi	a5,a5,1
 7ba:	fff7c703          	lbu	a4,-1(a5)
 7be:	fb7d                	bnez	a4,7b4 <strlen+0x14>
    ;
  return n;
}
 7c0:	6422                	ld	s0,8(sp)
 7c2:	0141                	addi	sp,sp,16
 7c4:	8082                	ret
  for(n = 0; s[n]; n++)
 7c6:	4501                	li	a0,0
 7c8:	bfe5                	j	7c0 <strlen+0x20>

00000000000007ca <memset>:

void*
memset(void *dst, int c, uint n)
{
 7ca:	1141                	addi	sp,sp,-16
 7cc:	e422                	sd	s0,8(sp)
 7ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 7d0:	ce09                	beqz	a2,7ea <memset+0x20>
 7d2:	87aa                	mv	a5,a0
 7d4:	fff6071b          	addiw	a4,a2,-1
 7d8:	1702                	slli	a4,a4,0x20
 7da:	9301                	srli	a4,a4,0x20
 7dc:	0705                	addi	a4,a4,1
 7de:	972a                	add	a4,a4,a0
    cdst[i] = c;
 7e0:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 7e4:	0785                	addi	a5,a5,1
 7e6:	fee79de3          	bne	a5,a4,7e0 <memset+0x16>
  }
  return dst;
}
 7ea:	6422                	ld	s0,8(sp)
 7ec:	0141                	addi	sp,sp,16
 7ee:	8082                	ret

00000000000007f0 <strchr>:

char*
strchr(const char *s, char c)
{
 7f0:	1141                	addi	sp,sp,-16
 7f2:	e422                	sd	s0,8(sp)
 7f4:	0800                	addi	s0,sp,16
  for(; *s; s++)
 7f6:	00054783          	lbu	a5,0(a0)
 7fa:	cf91                	beqz	a5,816 <strchr+0x26>
    if(*s == c)
 7fc:	00f58a63          	beq	a1,a5,810 <strchr+0x20>
  for(; *s; s++)
 800:	0505                	addi	a0,a0,1
 802:	00054783          	lbu	a5,0(a0)
 806:	c781                	beqz	a5,80e <strchr+0x1e>
    if(*s == c)
 808:	feb79ce3          	bne	a5,a1,800 <strchr+0x10>
 80c:	a011                	j	810 <strchr+0x20>
      return (char*)s;
  return 0;
 80e:	4501                	li	a0,0
}
 810:	6422                	ld	s0,8(sp)
 812:	0141                	addi	sp,sp,16
 814:	8082                	ret
  return 0;
 816:	4501                	li	a0,0
 818:	bfe5                	j	810 <strchr+0x20>

000000000000081a <gets>:

char*
gets(char *buf, int max)
{
 81a:	711d                	addi	sp,sp,-96
 81c:	ec86                	sd	ra,88(sp)
 81e:	e8a2                	sd	s0,80(sp)
 820:	e4a6                	sd	s1,72(sp)
 822:	e0ca                	sd	s2,64(sp)
 824:	fc4e                	sd	s3,56(sp)
 826:	f852                	sd	s4,48(sp)
 828:	f456                	sd	s5,40(sp)
 82a:	f05a                	sd	s6,32(sp)
 82c:	ec5e                	sd	s7,24(sp)
 82e:	1080                	addi	s0,sp,96
 830:	8baa                	mv	s7,a0
 832:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 834:	892a                	mv	s2,a0
 836:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 838:	4aa9                	li	s5,10
 83a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 83c:	0019849b          	addiw	s1,s3,1
 840:	0344d863          	ble	s4,s1,870 <gets+0x56>
    cc = read(0, &c, 1);
 844:	4605                	li	a2,1
 846:	faf40593          	addi	a1,s0,-81
 84a:	4501                	li	a0,0
 84c:	00000097          	auipc	ra,0x0
 850:	1ac080e7          	jalr	428(ra) # 9f8 <read>
    if(cc < 1)
 854:	00a05e63          	blez	a0,870 <gets+0x56>
    buf[i++] = c;
 858:	faf44783          	lbu	a5,-81(s0)
 85c:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 860:	01578763          	beq	a5,s5,86e <gets+0x54>
 864:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 866:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 868:	fd679ae3          	bne	a5,s6,83c <gets+0x22>
 86c:	a011                	j	870 <gets+0x56>
  for(i=0; i+1 < max; ){
 86e:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 870:	99de                	add	s3,s3,s7
 872:	00098023          	sb	zero,0(s3)
  return buf;
}
 876:	855e                	mv	a0,s7
 878:	60e6                	ld	ra,88(sp)
 87a:	6446                	ld	s0,80(sp)
 87c:	64a6                	ld	s1,72(sp)
 87e:	6906                	ld	s2,64(sp)
 880:	79e2                	ld	s3,56(sp)
 882:	7a42                	ld	s4,48(sp)
 884:	7aa2                	ld	s5,40(sp)
 886:	7b02                	ld	s6,32(sp)
 888:	6be2                	ld	s7,24(sp)
 88a:	6125                	addi	sp,sp,96
 88c:	8082                	ret

000000000000088e <stat>:

int
stat(const char *n, struct stat *st)
{
 88e:	1101                	addi	sp,sp,-32
 890:	ec06                	sd	ra,24(sp)
 892:	e822                	sd	s0,16(sp)
 894:	e426                	sd	s1,8(sp)
 896:	e04a                	sd	s2,0(sp)
 898:	1000                	addi	s0,sp,32
 89a:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 89c:	4581                	li	a1,0
 89e:	00000097          	auipc	ra,0x0
 8a2:	182080e7          	jalr	386(ra) # a20 <open>
  if(fd < 0)
 8a6:	02054563          	bltz	a0,8d0 <stat+0x42>
 8aa:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 8ac:	85ca                	mv	a1,s2
 8ae:	00000097          	auipc	ra,0x0
 8b2:	18a080e7          	jalr	394(ra) # a38 <fstat>
 8b6:	892a                	mv	s2,a0
  close(fd);
 8b8:	8526                	mv	a0,s1
 8ba:	00000097          	auipc	ra,0x0
 8be:	14e080e7          	jalr	334(ra) # a08 <close>
  return r;
}
 8c2:	854a                	mv	a0,s2
 8c4:	60e2                	ld	ra,24(sp)
 8c6:	6442                	ld	s0,16(sp)
 8c8:	64a2                	ld	s1,8(sp)
 8ca:	6902                	ld	s2,0(sp)
 8cc:	6105                	addi	sp,sp,32
 8ce:	8082                	ret
    return -1;
 8d0:	597d                	li	s2,-1
 8d2:	bfc5                	j	8c2 <stat+0x34>

00000000000008d4 <atoi>:

int
atoi(const char *s)
{
 8d4:	1141                	addi	sp,sp,-16
 8d6:	e422                	sd	s0,8(sp)
 8d8:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 8da:	00054683          	lbu	a3,0(a0)
 8de:	fd06879b          	addiw	a5,a3,-48
 8e2:	0ff7f793          	andi	a5,a5,255
 8e6:	4725                	li	a4,9
 8e8:	02f76963          	bltu	a4,a5,91a <atoi+0x46>
 8ec:	862a                	mv	a2,a0
  n = 0;
 8ee:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 8f0:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 8f2:	0605                	addi	a2,a2,1
 8f4:	0025179b          	slliw	a5,a0,0x2
 8f8:	9fa9                	addw	a5,a5,a0
 8fa:	0017979b          	slliw	a5,a5,0x1
 8fe:	9fb5                	addw	a5,a5,a3
 900:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 904:	00064683          	lbu	a3,0(a2)
 908:	fd06871b          	addiw	a4,a3,-48
 90c:	0ff77713          	andi	a4,a4,255
 910:	fee5f1e3          	bleu	a4,a1,8f2 <atoi+0x1e>
  return n;
}
 914:	6422                	ld	s0,8(sp)
 916:	0141                	addi	sp,sp,16
 918:	8082                	ret
  n = 0;
 91a:	4501                	li	a0,0
 91c:	bfe5                	j	914 <atoi+0x40>

000000000000091e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 91e:	1141                	addi	sp,sp,-16
 920:	e422                	sd	s0,8(sp)
 922:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 924:	02b57663          	bleu	a1,a0,950 <memmove+0x32>
    while(n-- > 0)
 928:	02c05163          	blez	a2,94a <memmove+0x2c>
 92c:	fff6079b          	addiw	a5,a2,-1
 930:	1782                	slli	a5,a5,0x20
 932:	9381                	srli	a5,a5,0x20
 934:	0785                	addi	a5,a5,1
 936:	97aa                	add	a5,a5,a0
  dst = vdst;
 938:	872a                	mv	a4,a0
      *dst++ = *src++;
 93a:	0585                	addi	a1,a1,1
 93c:	0705                	addi	a4,a4,1
 93e:	fff5c683          	lbu	a3,-1(a1)
 942:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 946:	fee79ae3          	bne	a5,a4,93a <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 94a:	6422                	ld	s0,8(sp)
 94c:	0141                	addi	sp,sp,16
 94e:	8082                	ret
    dst += n;
 950:	00c50733          	add	a4,a0,a2
    src += n;
 954:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 956:	fec05ae3          	blez	a2,94a <memmove+0x2c>
 95a:	fff6079b          	addiw	a5,a2,-1
 95e:	1782                	slli	a5,a5,0x20
 960:	9381                	srli	a5,a5,0x20
 962:	fff7c793          	not	a5,a5
 966:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 968:	15fd                	addi	a1,a1,-1
 96a:	177d                	addi	a4,a4,-1
 96c:	0005c683          	lbu	a3,0(a1)
 970:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 974:	fef71ae3          	bne	a4,a5,968 <memmove+0x4a>
 978:	bfc9                	j	94a <memmove+0x2c>

000000000000097a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 97a:	1141                	addi	sp,sp,-16
 97c:	e422                	sd	s0,8(sp)
 97e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 980:	ce15                	beqz	a2,9bc <memcmp+0x42>
 982:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 986:	00054783          	lbu	a5,0(a0)
 98a:	0005c703          	lbu	a4,0(a1)
 98e:	02e79063          	bne	a5,a4,9ae <memcmp+0x34>
 992:	1682                	slli	a3,a3,0x20
 994:	9281                	srli	a3,a3,0x20
 996:	0685                	addi	a3,a3,1
 998:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 99a:	0505                	addi	a0,a0,1
    p2++;
 99c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 99e:	00d50d63          	beq	a0,a3,9b8 <memcmp+0x3e>
    if (*p1 != *p2) {
 9a2:	00054783          	lbu	a5,0(a0)
 9a6:	0005c703          	lbu	a4,0(a1)
 9aa:	fee788e3          	beq	a5,a4,99a <memcmp+0x20>
      return *p1 - *p2;
 9ae:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 9b2:	6422                	ld	s0,8(sp)
 9b4:	0141                	addi	sp,sp,16
 9b6:	8082                	ret
  return 0;
 9b8:	4501                	li	a0,0
 9ba:	bfe5                	j	9b2 <memcmp+0x38>
 9bc:	4501                	li	a0,0
 9be:	bfd5                	j	9b2 <memcmp+0x38>

00000000000009c0 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 9c0:	1141                	addi	sp,sp,-16
 9c2:	e406                	sd	ra,8(sp)
 9c4:	e022                	sd	s0,0(sp)
 9c6:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 9c8:	00000097          	auipc	ra,0x0
 9cc:	f56080e7          	jalr	-170(ra) # 91e <memmove>
}
 9d0:	60a2                	ld	ra,8(sp)
 9d2:	6402                	ld	s0,0(sp)
 9d4:	0141                	addi	sp,sp,16
 9d6:	8082                	ret

00000000000009d8 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 9d8:	4885                	li	a7,1
 ecall
 9da:	00000073          	ecall
 ret
 9de:	8082                	ret

00000000000009e0 <exit>:
.global exit
exit:
 li a7, SYS_exit
 9e0:	4889                	li	a7,2
 ecall
 9e2:	00000073          	ecall
 ret
 9e6:	8082                	ret

00000000000009e8 <wait>:
.global wait
wait:
 li a7, SYS_wait
 9e8:	488d                	li	a7,3
 ecall
 9ea:	00000073          	ecall
 ret
 9ee:	8082                	ret

00000000000009f0 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 9f0:	4891                	li	a7,4
 ecall
 9f2:	00000073          	ecall
 ret
 9f6:	8082                	ret

00000000000009f8 <read>:
.global read
read:
 li a7, SYS_read
 9f8:	4895                	li	a7,5
 ecall
 9fa:	00000073          	ecall
 ret
 9fe:	8082                	ret

0000000000000a00 <write>:
.global write
write:
 li a7, SYS_write
 a00:	48c1                	li	a7,16
 ecall
 a02:	00000073          	ecall
 ret
 a06:	8082                	ret

0000000000000a08 <close>:
.global close
close:
 li a7, SYS_close
 a08:	48d5                	li	a7,21
 ecall
 a0a:	00000073          	ecall
 ret
 a0e:	8082                	ret

0000000000000a10 <kill>:
.global kill
kill:
 li a7, SYS_kill
 a10:	4899                	li	a7,6
 ecall
 a12:	00000073          	ecall
 ret
 a16:	8082                	ret

0000000000000a18 <exec>:
.global exec
exec:
 li a7, SYS_exec
 a18:	489d                	li	a7,7
 ecall
 a1a:	00000073          	ecall
 ret
 a1e:	8082                	ret

0000000000000a20 <open>:
.global open
open:
 li a7, SYS_open
 a20:	48bd                	li	a7,15
 ecall
 a22:	00000073          	ecall
 ret
 a26:	8082                	ret

0000000000000a28 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 a28:	48c5                	li	a7,17
 ecall
 a2a:	00000073          	ecall
 ret
 a2e:	8082                	ret

0000000000000a30 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 a30:	48c9                	li	a7,18
 ecall
 a32:	00000073          	ecall
 ret
 a36:	8082                	ret

0000000000000a38 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 a38:	48a1                	li	a7,8
 ecall
 a3a:	00000073          	ecall
 ret
 a3e:	8082                	ret

0000000000000a40 <link>:
.global link
link:
 li a7, SYS_link
 a40:	48cd                	li	a7,19
 ecall
 a42:	00000073          	ecall
 ret
 a46:	8082                	ret

0000000000000a48 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 a48:	48d1                	li	a7,20
 ecall
 a4a:	00000073          	ecall
 ret
 a4e:	8082                	ret

0000000000000a50 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 a50:	48a5                	li	a7,9
 ecall
 a52:	00000073          	ecall
 ret
 a56:	8082                	ret

0000000000000a58 <dup>:
.global dup
dup:
 li a7, SYS_dup
 a58:	48a9                	li	a7,10
 ecall
 a5a:	00000073          	ecall
 ret
 a5e:	8082                	ret

0000000000000a60 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 a60:	48ad                	li	a7,11
 ecall
 a62:	00000073          	ecall
 ret
 a66:	8082                	ret

0000000000000a68 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 a68:	48b1                	li	a7,12
 ecall
 a6a:	00000073          	ecall
 ret
 a6e:	8082                	ret

0000000000000a70 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 a70:	48b5                	li	a7,13
 ecall
 a72:	00000073          	ecall
 ret
 a76:	8082                	ret

0000000000000a78 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 a78:	48b9                	li	a7,14
 ecall
 a7a:	00000073          	ecall
 ret
 a7e:	8082                	ret

0000000000000a80 <connect>:
.global connect
connect:
 li a7, SYS_connect
 a80:	48f5                	li	a7,29
 ecall
 a82:	00000073          	ecall
 ret
 a86:	8082                	ret

0000000000000a88 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 a88:	1101                	addi	sp,sp,-32
 a8a:	ec06                	sd	ra,24(sp)
 a8c:	e822                	sd	s0,16(sp)
 a8e:	1000                	addi	s0,sp,32
 a90:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 a94:	4605                	li	a2,1
 a96:	fef40593          	addi	a1,s0,-17
 a9a:	00000097          	auipc	ra,0x0
 a9e:	f66080e7          	jalr	-154(ra) # a00 <write>
}
 aa2:	60e2                	ld	ra,24(sp)
 aa4:	6442                	ld	s0,16(sp)
 aa6:	6105                	addi	sp,sp,32
 aa8:	8082                	ret

0000000000000aaa <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 aaa:	7139                	addi	sp,sp,-64
 aac:	fc06                	sd	ra,56(sp)
 aae:	f822                	sd	s0,48(sp)
 ab0:	f426                	sd	s1,40(sp)
 ab2:	f04a                	sd	s2,32(sp)
 ab4:	ec4e                	sd	s3,24(sp)
 ab6:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 ab8:	c299                	beqz	a3,abe <printint+0x14>
 aba:	0005cd63          	bltz	a1,ad4 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 abe:	2581                	sext.w	a1,a1
  neg = 0;
 ac0:	4301                	li	t1,0
 ac2:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 ac6:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 ac8:	2601                	sext.w	a2,a2
 aca:	00000897          	auipc	a7,0x0
 ace:	68e88893          	addi	a7,a7,1678 # 1158 <digits>
 ad2:	a801                	j	ae2 <printint+0x38>
    x = -xx;
 ad4:	40b005bb          	negw	a1,a1
 ad8:	2581                	sext.w	a1,a1
    neg = 1;
 ada:	4305                	li	t1,1
    x = -xx;
 adc:	b7dd                	j	ac2 <printint+0x18>
  }while((x /= base) != 0);
 ade:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 ae0:	8836                	mv	a6,a3
 ae2:	0018069b          	addiw	a3,a6,1
 ae6:	02c5f7bb          	remuw	a5,a1,a2
 aea:	1782                	slli	a5,a5,0x20
 aec:	9381                	srli	a5,a5,0x20
 aee:	97c6                	add	a5,a5,a7
 af0:	0007c783          	lbu	a5,0(a5)
 af4:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 af8:	0705                	addi	a4,a4,1
 afa:	02c5d7bb          	divuw	a5,a1,a2
 afe:	fec5f0e3          	bleu	a2,a1,ade <printint+0x34>
  if(neg)
 b02:	00030b63          	beqz	t1,b18 <printint+0x6e>
    buf[i++] = '-';
 b06:	fd040793          	addi	a5,s0,-48
 b0a:	96be                	add	a3,a3,a5
 b0c:	02d00793          	li	a5,45
 b10:	fef68823          	sb	a5,-16(a3)
 b14:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 b18:	02d05963          	blez	a3,b4a <printint+0xa0>
 b1c:	89aa                	mv	s3,a0
 b1e:	fc040793          	addi	a5,s0,-64
 b22:	00d784b3          	add	s1,a5,a3
 b26:	fff78913          	addi	s2,a5,-1
 b2a:	9936                	add	s2,s2,a3
 b2c:	36fd                	addiw	a3,a3,-1
 b2e:	1682                	slli	a3,a3,0x20
 b30:	9281                	srli	a3,a3,0x20
 b32:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 b36:	fff4c583          	lbu	a1,-1(s1)
 b3a:	854e                	mv	a0,s3
 b3c:	00000097          	auipc	ra,0x0
 b40:	f4c080e7          	jalr	-180(ra) # a88 <putc>
  while(--i >= 0)
 b44:	14fd                	addi	s1,s1,-1
 b46:	ff2498e3          	bne	s1,s2,b36 <printint+0x8c>
}
 b4a:	70e2                	ld	ra,56(sp)
 b4c:	7442                	ld	s0,48(sp)
 b4e:	74a2                	ld	s1,40(sp)
 b50:	7902                	ld	s2,32(sp)
 b52:	69e2                	ld	s3,24(sp)
 b54:	6121                	addi	sp,sp,64
 b56:	8082                	ret

0000000000000b58 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 b58:	7119                	addi	sp,sp,-128
 b5a:	fc86                	sd	ra,120(sp)
 b5c:	f8a2                	sd	s0,112(sp)
 b5e:	f4a6                	sd	s1,104(sp)
 b60:	f0ca                	sd	s2,96(sp)
 b62:	ecce                	sd	s3,88(sp)
 b64:	e8d2                	sd	s4,80(sp)
 b66:	e4d6                	sd	s5,72(sp)
 b68:	e0da                	sd	s6,64(sp)
 b6a:	fc5e                	sd	s7,56(sp)
 b6c:	f862                	sd	s8,48(sp)
 b6e:	f466                	sd	s9,40(sp)
 b70:	f06a                	sd	s10,32(sp)
 b72:	ec6e                	sd	s11,24(sp)
 b74:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 b76:	0005c483          	lbu	s1,0(a1)
 b7a:	18048d63          	beqz	s1,d14 <vprintf+0x1bc>
 b7e:	8aaa                	mv	s5,a0
 b80:	8b32                	mv	s6,a2
 b82:	00158913          	addi	s2,a1,1
  state = 0;
 b86:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 b88:	02500a13          	li	s4,37
      if(c == 'd'){
 b8c:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 b90:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 b94:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 b98:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 b9c:	00000b97          	auipc	s7,0x0
 ba0:	5bcb8b93          	addi	s7,s7,1468 # 1158 <digits>
 ba4:	a839                	j	bc2 <vprintf+0x6a>
        putc(fd, c);
 ba6:	85a6                	mv	a1,s1
 ba8:	8556                	mv	a0,s5
 baa:	00000097          	auipc	ra,0x0
 bae:	ede080e7          	jalr	-290(ra) # a88 <putc>
 bb2:	a019                	j	bb8 <vprintf+0x60>
    } else if(state == '%'){
 bb4:	01498f63          	beq	s3,s4,bd2 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 bb8:	0905                	addi	s2,s2,1
 bba:	fff94483          	lbu	s1,-1(s2)
 bbe:	14048b63          	beqz	s1,d14 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 bc2:	0004879b          	sext.w	a5,s1
    if(state == 0){
 bc6:	fe0997e3          	bnez	s3,bb4 <vprintf+0x5c>
      if(c == '%'){
 bca:	fd479ee3          	bne	a5,s4,ba6 <vprintf+0x4e>
        state = '%';
 bce:	89be                	mv	s3,a5
 bd0:	b7e5                	j	bb8 <vprintf+0x60>
      if(c == 'd'){
 bd2:	05878063          	beq	a5,s8,c12 <vprintf+0xba>
      } else if(c == 'l') {
 bd6:	05978c63          	beq	a5,s9,c2e <vprintf+0xd6>
      } else if(c == 'x') {
 bda:	07a78863          	beq	a5,s10,c4a <vprintf+0xf2>
      } else if(c == 'p') {
 bde:	09b78463          	beq	a5,s11,c66 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 be2:	07300713          	li	a4,115
 be6:	0ce78563          	beq	a5,a4,cb0 <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 bea:	06300713          	li	a4,99
 bee:	0ee78c63          	beq	a5,a4,ce6 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 bf2:	11478663          	beq	a5,s4,cfe <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 bf6:	85d2                	mv	a1,s4
 bf8:	8556                	mv	a0,s5
 bfa:	00000097          	auipc	ra,0x0
 bfe:	e8e080e7          	jalr	-370(ra) # a88 <putc>
        putc(fd, c);
 c02:	85a6                	mv	a1,s1
 c04:	8556                	mv	a0,s5
 c06:	00000097          	auipc	ra,0x0
 c0a:	e82080e7          	jalr	-382(ra) # a88 <putc>
      }
      state = 0;
 c0e:	4981                	li	s3,0
 c10:	b765                	j	bb8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 c12:	008b0493          	addi	s1,s6,8
 c16:	4685                	li	a3,1
 c18:	4629                	li	a2,10
 c1a:	000b2583          	lw	a1,0(s6)
 c1e:	8556                	mv	a0,s5
 c20:	00000097          	auipc	ra,0x0
 c24:	e8a080e7          	jalr	-374(ra) # aaa <printint>
 c28:	8b26                	mv	s6,s1
      state = 0;
 c2a:	4981                	li	s3,0
 c2c:	b771                	j	bb8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 c2e:	008b0493          	addi	s1,s6,8
 c32:	4681                	li	a3,0
 c34:	4629                	li	a2,10
 c36:	000b2583          	lw	a1,0(s6)
 c3a:	8556                	mv	a0,s5
 c3c:	00000097          	auipc	ra,0x0
 c40:	e6e080e7          	jalr	-402(ra) # aaa <printint>
 c44:	8b26                	mv	s6,s1
      state = 0;
 c46:	4981                	li	s3,0
 c48:	bf85                	j	bb8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 c4a:	008b0493          	addi	s1,s6,8
 c4e:	4681                	li	a3,0
 c50:	4641                	li	a2,16
 c52:	000b2583          	lw	a1,0(s6)
 c56:	8556                	mv	a0,s5
 c58:	00000097          	auipc	ra,0x0
 c5c:	e52080e7          	jalr	-430(ra) # aaa <printint>
 c60:	8b26                	mv	s6,s1
      state = 0;
 c62:	4981                	li	s3,0
 c64:	bf91                	j	bb8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 c66:	008b0793          	addi	a5,s6,8
 c6a:	f8f43423          	sd	a5,-120(s0)
 c6e:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 c72:	03000593          	li	a1,48
 c76:	8556                	mv	a0,s5
 c78:	00000097          	auipc	ra,0x0
 c7c:	e10080e7          	jalr	-496(ra) # a88 <putc>
  putc(fd, 'x');
 c80:	85ea                	mv	a1,s10
 c82:	8556                	mv	a0,s5
 c84:	00000097          	auipc	ra,0x0
 c88:	e04080e7          	jalr	-508(ra) # a88 <putc>
 c8c:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 c8e:	03c9d793          	srli	a5,s3,0x3c
 c92:	97de                	add	a5,a5,s7
 c94:	0007c583          	lbu	a1,0(a5)
 c98:	8556                	mv	a0,s5
 c9a:	00000097          	auipc	ra,0x0
 c9e:	dee080e7          	jalr	-530(ra) # a88 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 ca2:	0992                	slli	s3,s3,0x4
 ca4:	34fd                	addiw	s1,s1,-1
 ca6:	f4e5                	bnez	s1,c8e <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 ca8:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 cac:	4981                	li	s3,0
 cae:	b729                	j	bb8 <vprintf+0x60>
        s = va_arg(ap, char*);
 cb0:	008b0993          	addi	s3,s6,8
 cb4:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 cb8:	c085                	beqz	s1,cd8 <vprintf+0x180>
        while(*s != 0){
 cba:	0004c583          	lbu	a1,0(s1)
 cbe:	c9a1                	beqz	a1,d0e <vprintf+0x1b6>
          putc(fd, *s);
 cc0:	8556                	mv	a0,s5
 cc2:	00000097          	auipc	ra,0x0
 cc6:	dc6080e7          	jalr	-570(ra) # a88 <putc>
          s++;
 cca:	0485                	addi	s1,s1,1
        while(*s != 0){
 ccc:	0004c583          	lbu	a1,0(s1)
 cd0:	f9e5                	bnez	a1,cc0 <vprintf+0x168>
        s = va_arg(ap, char*);
 cd2:	8b4e                	mv	s6,s3
      state = 0;
 cd4:	4981                	li	s3,0
 cd6:	b5cd                	j	bb8 <vprintf+0x60>
          s = "(null)";
 cd8:	00000497          	auipc	s1,0x0
 cdc:	49848493          	addi	s1,s1,1176 # 1170 <digits+0x18>
        while(*s != 0){
 ce0:	02800593          	li	a1,40
 ce4:	bff1                	j	cc0 <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 ce6:	008b0493          	addi	s1,s6,8
 cea:	000b4583          	lbu	a1,0(s6)
 cee:	8556                	mv	a0,s5
 cf0:	00000097          	auipc	ra,0x0
 cf4:	d98080e7          	jalr	-616(ra) # a88 <putc>
 cf8:	8b26                	mv	s6,s1
      state = 0;
 cfa:	4981                	li	s3,0
 cfc:	bd75                	j	bb8 <vprintf+0x60>
        putc(fd, c);
 cfe:	85d2                	mv	a1,s4
 d00:	8556                	mv	a0,s5
 d02:	00000097          	auipc	ra,0x0
 d06:	d86080e7          	jalr	-634(ra) # a88 <putc>
      state = 0;
 d0a:	4981                	li	s3,0
 d0c:	b575                	j	bb8 <vprintf+0x60>
        s = va_arg(ap, char*);
 d0e:	8b4e                	mv	s6,s3
      state = 0;
 d10:	4981                	li	s3,0
 d12:	b55d                	j	bb8 <vprintf+0x60>
    }
  }
}
 d14:	70e6                	ld	ra,120(sp)
 d16:	7446                	ld	s0,112(sp)
 d18:	74a6                	ld	s1,104(sp)
 d1a:	7906                	ld	s2,96(sp)
 d1c:	69e6                	ld	s3,88(sp)
 d1e:	6a46                	ld	s4,80(sp)
 d20:	6aa6                	ld	s5,72(sp)
 d22:	6b06                	ld	s6,64(sp)
 d24:	7be2                	ld	s7,56(sp)
 d26:	7c42                	ld	s8,48(sp)
 d28:	7ca2                	ld	s9,40(sp)
 d2a:	7d02                	ld	s10,32(sp)
 d2c:	6de2                	ld	s11,24(sp)
 d2e:	6109                	addi	sp,sp,128
 d30:	8082                	ret

0000000000000d32 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 d32:	715d                	addi	sp,sp,-80
 d34:	ec06                	sd	ra,24(sp)
 d36:	e822                	sd	s0,16(sp)
 d38:	1000                	addi	s0,sp,32
 d3a:	e010                	sd	a2,0(s0)
 d3c:	e414                	sd	a3,8(s0)
 d3e:	e818                	sd	a4,16(s0)
 d40:	ec1c                	sd	a5,24(s0)
 d42:	03043023          	sd	a6,32(s0)
 d46:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 d4a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 d4e:	8622                	mv	a2,s0
 d50:	00000097          	auipc	ra,0x0
 d54:	e08080e7          	jalr	-504(ra) # b58 <vprintf>
}
 d58:	60e2                	ld	ra,24(sp)
 d5a:	6442                	ld	s0,16(sp)
 d5c:	6161                	addi	sp,sp,80
 d5e:	8082                	ret

0000000000000d60 <printf>:

void
printf(const char *fmt, ...)
{
 d60:	711d                	addi	sp,sp,-96
 d62:	ec06                	sd	ra,24(sp)
 d64:	e822                	sd	s0,16(sp)
 d66:	1000                	addi	s0,sp,32
 d68:	e40c                	sd	a1,8(s0)
 d6a:	e810                	sd	a2,16(s0)
 d6c:	ec14                	sd	a3,24(s0)
 d6e:	f018                	sd	a4,32(s0)
 d70:	f41c                	sd	a5,40(s0)
 d72:	03043823          	sd	a6,48(s0)
 d76:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 d7a:	00840613          	addi	a2,s0,8
 d7e:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 d82:	85aa                	mv	a1,a0
 d84:	4505                	li	a0,1
 d86:	00000097          	auipc	ra,0x0
 d8a:	dd2080e7          	jalr	-558(ra) # b58 <vprintf>
}
 d8e:	60e2                	ld	ra,24(sp)
 d90:	6442                	ld	s0,16(sp)
 d92:	6125                	addi	sp,sp,96
 d94:	8082                	ret

0000000000000d96 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 d96:	1141                	addi	sp,sp,-16
 d98:	e422                	sd	s0,8(sp)
 d9a:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 d9c:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 da0:	00000797          	auipc	a5,0x0
 da4:	3d878793          	addi	a5,a5,984 # 1178 <__bss_start>
 da8:	639c                	ld	a5,0(a5)
 daa:	a805                	j	dda <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 dac:	4618                	lw	a4,8(a2)
 dae:	9db9                	addw	a1,a1,a4
 db0:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 db4:	6398                	ld	a4,0(a5)
 db6:	6318                	ld	a4,0(a4)
 db8:	fee53823          	sd	a4,-16(a0)
 dbc:	a091                	j	e00 <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 dbe:	ff852703          	lw	a4,-8(a0)
 dc2:	9e39                	addw	a2,a2,a4
 dc4:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 dc6:	ff053703          	ld	a4,-16(a0)
 dca:	e398                	sd	a4,0(a5)
 dcc:	a099                	j	e12 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 dce:	6398                	ld	a4,0(a5)
 dd0:	00e7e463          	bltu	a5,a4,dd8 <free+0x42>
 dd4:	00e6ea63          	bltu	a3,a4,de8 <free+0x52>
{
 dd8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 dda:	fed7fae3          	bleu	a3,a5,dce <free+0x38>
 dde:	6398                	ld	a4,0(a5)
 de0:	00e6e463          	bltu	a3,a4,de8 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 de4:	fee7eae3          	bltu	a5,a4,dd8 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 de8:	ff852583          	lw	a1,-8(a0)
 dec:	6390                	ld	a2,0(a5)
 dee:	02059713          	slli	a4,a1,0x20
 df2:	9301                	srli	a4,a4,0x20
 df4:	0712                	slli	a4,a4,0x4
 df6:	9736                	add	a4,a4,a3
 df8:	fae60ae3          	beq	a2,a4,dac <free+0x16>
    bp->s.ptr = p->s.ptr;
 dfc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 e00:	4790                	lw	a2,8(a5)
 e02:	02061713          	slli	a4,a2,0x20
 e06:	9301                	srli	a4,a4,0x20
 e08:	0712                	slli	a4,a4,0x4
 e0a:	973e                	add	a4,a4,a5
 e0c:	fae689e3          	beq	a3,a4,dbe <free+0x28>
  } else
    p->s.ptr = bp;
 e10:	e394                	sd	a3,0(a5)
  freep = p;
 e12:	00000717          	auipc	a4,0x0
 e16:	36f73323          	sd	a5,870(a4) # 1178 <__bss_start>
}
 e1a:	6422                	ld	s0,8(sp)
 e1c:	0141                	addi	sp,sp,16
 e1e:	8082                	ret

0000000000000e20 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 e20:	7139                	addi	sp,sp,-64
 e22:	fc06                	sd	ra,56(sp)
 e24:	f822                	sd	s0,48(sp)
 e26:	f426                	sd	s1,40(sp)
 e28:	f04a                	sd	s2,32(sp)
 e2a:	ec4e                	sd	s3,24(sp)
 e2c:	e852                	sd	s4,16(sp)
 e2e:	e456                	sd	s5,8(sp)
 e30:	e05a                	sd	s6,0(sp)
 e32:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 e34:	02051993          	slli	s3,a0,0x20
 e38:	0209d993          	srli	s3,s3,0x20
 e3c:	09bd                	addi	s3,s3,15
 e3e:	0049d993          	srli	s3,s3,0x4
 e42:	2985                	addiw	s3,s3,1
 e44:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 e48:	00000797          	auipc	a5,0x0
 e4c:	33078793          	addi	a5,a5,816 # 1178 <__bss_start>
 e50:	6388                	ld	a0,0(a5)
 e52:	c515                	beqz	a0,e7e <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 e54:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 e56:	4798                	lw	a4,8(a5)
 e58:	03277f63          	bleu	s2,a4,e96 <malloc+0x76>
 e5c:	8a4e                	mv	s4,s3
 e5e:	0009871b          	sext.w	a4,s3
 e62:	6685                	lui	a3,0x1
 e64:	00d77363          	bleu	a3,a4,e6a <malloc+0x4a>
 e68:	6a05                	lui	s4,0x1
 e6a:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 e6e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 e72:	00000497          	auipc	s1,0x0
 e76:	30648493          	addi	s1,s1,774 # 1178 <__bss_start>
  if(p == (char*)-1)
 e7a:	5b7d                	li	s6,-1
 e7c:	a885                	j	eec <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 e7e:	00000797          	auipc	a5,0x0
 e82:	30278793          	addi	a5,a5,770 # 1180 <base>
 e86:	00000717          	auipc	a4,0x0
 e8a:	2ef73923          	sd	a5,754(a4) # 1178 <__bss_start>
 e8e:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 e90:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 e94:	b7e1                	j	e5c <malloc+0x3c>
      if(p->s.size == nunits)
 e96:	02e90b63          	beq	s2,a4,ecc <malloc+0xac>
        p->s.size -= nunits;
 e9a:	4137073b          	subw	a4,a4,s3
 e9e:	c798                	sw	a4,8(a5)
        p += p->s.size;
 ea0:	1702                	slli	a4,a4,0x20
 ea2:	9301                	srli	a4,a4,0x20
 ea4:	0712                	slli	a4,a4,0x4
 ea6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 ea8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 eac:	00000717          	auipc	a4,0x0
 eb0:	2ca73623          	sd	a0,716(a4) # 1178 <__bss_start>
      return (void*)(p + 1);
 eb4:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 eb8:	70e2                	ld	ra,56(sp)
 eba:	7442                	ld	s0,48(sp)
 ebc:	74a2                	ld	s1,40(sp)
 ebe:	7902                	ld	s2,32(sp)
 ec0:	69e2                	ld	s3,24(sp)
 ec2:	6a42                	ld	s4,16(sp)
 ec4:	6aa2                	ld	s5,8(sp)
 ec6:	6b02                	ld	s6,0(sp)
 ec8:	6121                	addi	sp,sp,64
 eca:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 ecc:	6398                	ld	a4,0(a5)
 ece:	e118                	sd	a4,0(a0)
 ed0:	bff1                	j	eac <malloc+0x8c>
  hp->s.size = nu;
 ed2:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 ed6:	0541                	addi	a0,a0,16
 ed8:	00000097          	auipc	ra,0x0
 edc:	ebe080e7          	jalr	-322(ra) # d96 <free>
  return freep;
 ee0:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 ee2:	d979                	beqz	a0,eb8 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 ee4:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 ee6:	4798                	lw	a4,8(a5)
 ee8:	fb2777e3          	bleu	s2,a4,e96 <malloc+0x76>
    if(p == freep)
 eec:	6098                	ld	a4,0(s1)
 eee:	853e                	mv	a0,a5
 ef0:	fef71ae3          	bne	a4,a5,ee4 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 ef4:	8552                	mv	a0,s4
 ef6:	00000097          	auipc	ra,0x0
 efa:	b72080e7          	jalr	-1166(ra) # a68 <sbrk>
  if(p == (char*)-1)
 efe:	fd651ae3          	bne	a0,s6,ed2 <malloc+0xb2>
        return 0;
 f02:	4501                	li	a0,0
 f04:	bf55                	j	eb8 <malloc+0x98>
