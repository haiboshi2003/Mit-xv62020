
kernel/kernel：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	8d013103          	ld	sp,-1840(sp) # 800098d0 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	0a7060ef          	jal	ra,800068bc <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    8000001c:	1101                	addi	sp,sp,-32
    8000001e:	ec06                	sd	ra,24(sp)
    80000020:	e822                	sd	s0,16(sp)
    80000022:	e426                	sd	s1,8(sp)
    80000024:	e04a                	sd	s2,0(sp)
    80000026:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000028:	6785                	lui	a5,0x1
    8000002a:	17fd                	addi	a5,a5,-1
    8000002c:	8fe9                	and	a5,a5,a0
    8000002e:	ebb9                	bnez	a5,80000084 <kfree+0x68>
    80000030:	84aa                	mv	s1,a0
    80000032:	00027797          	auipc	a5,0x27
    80000036:	54e78793          	addi	a5,a5,1358 # 80027580 <end>
    8000003a:	04f56563          	bltu	a0,a5,80000084 <kfree+0x68>
    8000003e:	47c5                	li	a5,17
    80000040:	07ee                	slli	a5,a5,0x1b
    80000042:	04f57163          	bleu	a5,a0,80000084 <kfree+0x68>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000046:	6605                	lui	a2,0x1
    80000048:	4585                	li	a1,1
    8000004a:	00000097          	auipc	ra,0x0
    8000004e:	132080e7          	jalr	306(ra) # 8000017c <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000052:	0000a917          	auipc	s2,0xa
    80000056:	ffe90913          	addi	s2,s2,-2 # 8000a050 <kmem>
    8000005a:	854a                	mv	a0,s2
    8000005c:	00007097          	auipc	ra,0x7
    80000060:	298080e7          	jalr	664(ra) # 800072f4 <acquire>
  r->next = kmem.freelist;
    80000064:	01893783          	ld	a5,24(s2)
    80000068:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    8000006a:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    8000006e:	854a                	mv	a0,s2
    80000070:	00007097          	auipc	ra,0x7
    80000074:	338080e7          	jalr	824(ra) # 800073a8 <release>
}
    80000078:	60e2                	ld	ra,24(sp)
    8000007a:	6442                	ld	s0,16(sp)
    8000007c:	64a2                	ld	s1,8(sp)
    8000007e:	6902                	ld	s2,0(sp)
    80000080:	6105                	addi	sp,sp,32
    80000082:	8082                	ret
    panic("kfree");
    80000084:	00009517          	auipc	a0,0x9
    80000088:	f8c50513          	addi	a0,a0,-116 # 80009010 <etext+0x10>
    8000008c:	00007097          	auipc	ra,0x7
    80000090:	cfc080e7          	jalr	-772(ra) # 80006d88 <panic>

0000000080000094 <freerange>:
{
    80000094:	7179                	addi	sp,sp,-48
    80000096:	f406                	sd	ra,40(sp)
    80000098:	f022                	sd	s0,32(sp)
    8000009a:	ec26                	sd	s1,24(sp)
    8000009c:	e84a                	sd	s2,16(sp)
    8000009e:	e44e                	sd	s3,8(sp)
    800000a0:	e052                	sd	s4,0(sp)
    800000a2:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    800000a4:	6705                	lui	a4,0x1
    800000a6:	fff70793          	addi	a5,a4,-1 # fff <_entry-0x7ffff001>
    800000aa:	00f504b3          	add	s1,a0,a5
    800000ae:	77fd                	lui	a5,0xfffff
    800000b0:	8cfd                	and	s1,s1,a5
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000b2:	94ba                	add	s1,s1,a4
    800000b4:	0095ee63          	bltu	a1,s1,800000d0 <freerange+0x3c>
    800000b8:	892e                	mv	s2,a1
    kfree(p);
    800000ba:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000bc:	6985                	lui	s3,0x1
    kfree(p);
    800000be:	01448533          	add	a0,s1,s4
    800000c2:	00000097          	auipc	ra,0x0
    800000c6:	f5a080e7          	jalr	-166(ra) # 8000001c <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    800000ca:	94ce                	add	s1,s1,s3
    800000cc:	fe9979e3          	bleu	s1,s2,800000be <freerange+0x2a>
}
    800000d0:	70a2                	ld	ra,40(sp)
    800000d2:	7402                	ld	s0,32(sp)
    800000d4:	64e2                	ld	s1,24(sp)
    800000d6:	6942                	ld	s2,16(sp)
    800000d8:	69a2                	ld	s3,8(sp)
    800000da:	6a02                	ld	s4,0(sp)
    800000dc:	6145                	addi	sp,sp,48
    800000de:	8082                	ret

00000000800000e0 <kinit>:
{
    800000e0:	1141                	addi	sp,sp,-16
    800000e2:	e406                	sd	ra,8(sp)
    800000e4:	e022                	sd	s0,0(sp)
    800000e6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    800000e8:	00009597          	auipc	a1,0x9
    800000ec:	f3058593          	addi	a1,a1,-208 # 80009018 <etext+0x18>
    800000f0:	0000a517          	auipc	a0,0xa
    800000f4:	f6050513          	addi	a0,a0,-160 # 8000a050 <kmem>
    800000f8:	00007097          	auipc	ra,0x7
    800000fc:	16c080e7          	jalr	364(ra) # 80007264 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000100:	45c5                	li	a1,17
    80000102:	05ee                	slli	a1,a1,0x1b
    80000104:	00027517          	auipc	a0,0x27
    80000108:	47c50513          	addi	a0,a0,1148 # 80027580 <end>
    8000010c:	00000097          	auipc	ra,0x0
    80000110:	f88080e7          	jalr	-120(ra) # 80000094 <freerange>
}
    80000114:	60a2                	ld	ra,8(sp)
    80000116:	6402                	ld	s0,0(sp)
    80000118:	0141                	addi	sp,sp,16
    8000011a:	8082                	ret

000000008000011c <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    8000011c:	1101                	addi	sp,sp,-32
    8000011e:	ec06                	sd	ra,24(sp)
    80000120:	e822                	sd	s0,16(sp)
    80000122:	e426                	sd	s1,8(sp)
    80000124:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000126:	0000a497          	auipc	s1,0xa
    8000012a:	f2a48493          	addi	s1,s1,-214 # 8000a050 <kmem>
    8000012e:	8526                	mv	a0,s1
    80000130:	00007097          	auipc	ra,0x7
    80000134:	1c4080e7          	jalr	452(ra) # 800072f4 <acquire>
  r = kmem.freelist;
    80000138:	6c84                	ld	s1,24(s1)
  if(r)
    8000013a:	c885                	beqz	s1,8000016a <kalloc+0x4e>
    kmem.freelist = r->next;
    8000013c:	609c                	ld	a5,0(s1)
    8000013e:	0000a517          	auipc	a0,0xa
    80000142:	f1250513          	addi	a0,a0,-238 # 8000a050 <kmem>
    80000146:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000148:	00007097          	auipc	ra,0x7
    8000014c:	260080e7          	jalr	608(ra) # 800073a8 <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000150:	6605                	lui	a2,0x1
    80000152:	4595                	li	a1,5
    80000154:	8526                	mv	a0,s1
    80000156:	00000097          	auipc	ra,0x0
    8000015a:	026080e7          	jalr	38(ra) # 8000017c <memset>
  return (void*)r;
}
    8000015e:	8526                	mv	a0,s1
    80000160:	60e2                	ld	ra,24(sp)
    80000162:	6442                	ld	s0,16(sp)
    80000164:	64a2                	ld	s1,8(sp)
    80000166:	6105                	addi	sp,sp,32
    80000168:	8082                	ret
  release(&kmem.lock);
    8000016a:	0000a517          	auipc	a0,0xa
    8000016e:	ee650513          	addi	a0,a0,-282 # 8000a050 <kmem>
    80000172:	00007097          	auipc	ra,0x7
    80000176:	236080e7          	jalr	566(ra) # 800073a8 <release>
  if(r)
    8000017a:	b7d5                	j	8000015e <kalloc+0x42>

000000008000017c <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    8000017c:	1141                	addi	sp,sp,-16
    8000017e:	e422                	sd	s0,8(sp)
    80000180:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000182:	ce09                	beqz	a2,8000019c <memset+0x20>
    80000184:	87aa                	mv	a5,a0
    80000186:	fff6071b          	addiw	a4,a2,-1
    8000018a:	1702                	slli	a4,a4,0x20
    8000018c:	9301                	srli	a4,a4,0x20
    8000018e:	0705                	addi	a4,a4,1
    80000190:	972a                	add	a4,a4,a0
    cdst[i] = c;
    80000192:	00b78023          	sb	a1,0(a5) # fffffffffffff000 <end+0xffffffff7ffd7a80>
  for(i = 0; i < n; i++){
    80000196:	0785                	addi	a5,a5,1
    80000198:	fee79de3          	bne	a5,a4,80000192 <memset+0x16>
  }
  return dst;
}
    8000019c:	6422                	ld	s0,8(sp)
    8000019e:	0141                	addi	sp,sp,16
    800001a0:	8082                	ret

00000000800001a2 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    800001a2:	1141                	addi	sp,sp,-16
    800001a4:	e422                	sd	s0,8(sp)
    800001a6:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    800001a8:	ce15                	beqz	a2,800001e4 <memcmp+0x42>
    800001aa:	fff6069b          	addiw	a3,a2,-1
    if(*s1 != *s2)
    800001ae:	00054783          	lbu	a5,0(a0)
    800001b2:	0005c703          	lbu	a4,0(a1)
    800001b6:	02e79063          	bne	a5,a4,800001d6 <memcmp+0x34>
    800001ba:	1682                	slli	a3,a3,0x20
    800001bc:	9281                	srli	a3,a3,0x20
    800001be:	0685                	addi	a3,a3,1
    800001c0:	96aa                	add	a3,a3,a0
      return *s1 - *s2;
    s1++, s2++;
    800001c2:	0505                	addi	a0,a0,1
    800001c4:	0585                	addi	a1,a1,1
  while(n-- > 0){
    800001c6:	00d50d63          	beq	a0,a3,800001e0 <memcmp+0x3e>
    if(*s1 != *s2)
    800001ca:	00054783          	lbu	a5,0(a0)
    800001ce:	0005c703          	lbu	a4,0(a1)
    800001d2:	fee788e3          	beq	a5,a4,800001c2 <memcmp+0x20>
      return *s1 - *s2;
    800001d6:	40e7853b          	subw	a0,a5,a4
  }

  return 0;
}
    800001da:	6422                	ld	s0,8(sp)
    800001dc:	0141                	addi	sp,sp,16
    800001de:	8082                	ret
  return 0;
    800001e0:	4501                	li	a0,0
    800001e2:	bfe5                	j	800001da <memcmp+0x38>
    800001e4:	4501                	li	a0,0
    800001e6:	bfd5                	j	800001da <memcmp+0x38>

00000000800001e8 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    800001e8:	1141                	addi	sp,sp,-16
    800001ea:	e422                	sd	s0,8(sp)
    800001ec:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
    800001ee:	00a5f963          	bleu	a0,a1,80000200 <memmove+0x18>
    800001f2:	02061713          	slli	a4,a2,0x20
    800001f6:	9301                	srli	a4,a4,0x20
    800001f8:	00e587b3          	add	a5,a1,a4
    800001fc:	02f56563          	bltu	a0,a5,80000226 <memmove+0x3e>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000200:	fff6069b          	addiw	a3,a2,-1
    80000204:	ce11                	beqz	a2,80000220 <memmove+0x38>
    80000206:	1682                	slli	a3,a3,0x20
    80000208:	9281                	srli	a3,a3,0x20
    8000020a:	0685                	addi	a3,a3,1
    8000020c:	96ae                	add	a3,a3,a1
    8000020e:	87aa                	mv	a5,a0
      *d++ = *s++;
    80000210:	0585                	addi	a1,a1,1
    80000212:	0785                	addi	a5,a5,1
    80000214:	fff5c703          	lbu	a4,-1(a1)
    80000218:	fee78fa3          	sb	a4,-1(a5)
    while(n-- > 0)
    8000021c:	fed59ae3          	bne	a1,a3,80000210 <memmove+0x28>

  return dst;
}
    80000220:	6422                	ld	s0,8(sp)
    80000222:	0141                	addi	sp,sp,16
    80000224:	8082                	ret
    d += n;
    80000226:	972a                	add	a4,a4,a0
    while(n-- > 0)
    80000228:	fff6069b          	addiw	a3,a2,-1
    8000022c:	da75                	beqz	a2,80000220 <memmove+0x38>
    8000022e:	02069613          	slli	a2,a3,0x20
    80000232:	9201                	srli	a2,a2,0x20
    80000234:	fff64613          	not	a2,a2
    80000238:	963e                	add	a2,a2,a5
      *--d = *--s;
    8000023a:	17fd                	addi	a5,a5,-1
    8000023c:	177d                	addi	a4,a4,-1
    8000023e:	0007c683          	lbu	a3,0(a5)
    80000242:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
    80000246:	fef61ae3          	bne	a2,a5,8000023a <memmove+0x52>
    8000024a:	bfd9                	j	80000220 <memmove+0x38>

000000008000024c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    8000024c:	1141                	addi	sp,sp,-16
    8000024e:	e406                	sd	ra,8(sp)
    80000250:	e022                	sd	s0,0(sp)
    80000252:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000254:	00000097          	auipc	ra,0x0
    80000258:	f94080e7          	jalr	-108(ra) # 800001e8 <memmove>
}
    8000025c:	60a2                	ld	ra,8(sp)
    8000025e:	6402                	ld	s0,0(sp)
    80000260:	0141                	addi	sp,sp,16
    80000262:	8082                	ret

0000000080000264 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000264:	1141                	addi	sp,sp,-16
    80000266:	e422                	sd	s0,8(sp)
    80000268:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    8000026a:	c229                	beqz	a2,800002ac <strncmp+0x48>
    8000026c:	00054783          	lbu	a5,0(a0)
    80000270:	c795                	beqz	a5,8000029c <strncmp+0x38>
    80000272:	0005c703          	lbu	a4,0(a1)
    80000276:	02f71363          	bne	a4,a5,8000029c <strncmp+0x38>
    8000027a:	fff6071b          	addiw	a4,a2,-1
    8000027e:	1702                	slli	a4,a4,0x20
    80000280:	9301                	srli	a4,a4,0x20
    80000282:	0705                	addi	a4,a4,1
    80000284:	972a                	add	a4,a4,a0
    n--, p++, q++;
    80000286:	0505                	addi	a0,a0,1
    80000288:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    8000028a:	02e50363          	beq	a0,a4,800002b0 <strncmp+0x4c>
    8000028e:	00054783          	lbu	a5,0(a0)
    80000292:	c789                	beqz	a5,8000029c <strncmp+0x38>
    80000294:	0005c683          	lbu	a3,0(a1)
    80000298:	fef687e3          	beq	a3,a5,80000286 <strncmp+0x22>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
    8000029c:	00054503          	lbu	a0,0(a0)
    800002a0:	0005c783          	lbu	a5,0(a1)
    800002a4:	9d1d                	subw	a0,a0,a5
}
    800002a6:	6422                	ld	s0,8(sp)
    800002a8:	0141                	addi	sp,sp,16
    800002aa:	8082                	ret
    return 0;
    800002ac:	4501                	li	a0,0
    800002ae:	bfe5                	j	800002a6 <strncmp+0x42>
    800002b0:	4501                	li	a0,0
    800002b2:	bfd5                	j	800002a6 <strncmp+0x42>

00000000800002b4 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    800002b4:	1141                	addi	sp,sp,-16
    800002b6:	e422                	sd	s0,8(sp)
    800002b8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    800002ba:	872a                	mv	a4,a0
    800002bc:	a011                	j	800002c0 <strncpy+0xc>
    800002be:	8636                	mv	a2,a3
    800002c0:	fff6069b          	addiw	a3,a2,-1
    800002c4:	00c05963          	blez	a2,800002d6 <strncpy+0x22>
    800002c8:	0705                	addi	a4,a4,1
    800002ca:	0005c783          	lbu	a5,0(a1)
    800002ce:	fef70fa3          	sb	a5,-1(a4)
    800002d2:	0585                	addi	a1,a1,1
    800002d4:	f7ed                	bnez	a5,800002be <strncpy+0xa>
    ;
  while(n-- > 0)
    800002d6:	00d05c63          	blez	a3,800002ee <strncpy+0x3a>
    800002da:	86ba                	mv	a3,a4
    *s++ = 0;
    800002dc:	0685                	addi	a3,a3,1
    800002de:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    800002e2:	fff6c793          	not	a5,a3
    800002e6:	9fb9                	addw	a5,a5,a4
    800002e8:	9fb1                	addw	a5,a5,a2
    800002ea:	fef049e3          	bgtz	a5,800002dc <strncpy+0x28>
  return os;
}
    800002ee:	6422                	ld	s0,8(sp)
    800002f0:	0141                	addi	sp,sp,16
    800002f2:	8082                	ret

00000000800002f4 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    800002f4:	1141                	addi	sp,sp,-16
    800002f6:	e422                	sd	s0,8(sp)
    800002f8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    800002fa:	02c05363          	blez	a2,80000320 <safestrcpy+0x2c>
    800002fe:	fff6069b          	addiw	a3,a2,-1
    80000302:	1682                	slli	a3,a3,0x20
    80000304:	9281                	srli	a3,a3,0x20
    80000306:	96ae                	add	a3,a3,a1
    80000308:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    8000030a:	00d58963          	beq	a1,a3,8000031c <safestrcpy+0x28>
    8000030e:	0585                	addi	a1,a1,1
    80000310:	0785                	addi	a5,a5,1
    80000312:	fff5c703          	lbu	a4,-1(a1)
    80000316:	fee78fa3          	sb	a4,-1(a5)
    8000031a:	fb65                	bnez	a4,8000030a <safestrcpy+0x16>
    ;
  *s = 0;
    8000031c:	00078023          	sb	zero,0(a5)
  return os;
}
    80000320:	6422                	ld	s0,8(sp)
    80000322:	0141                	addi	sp,sp,16
    80000324:	8082                	ret

0000000080000326 <strlen>:

int
strlen(const char *s)
{
    80000326:	1141                	addi	sp,sp,-16
    80000328:	e422                	sd	s0,8(sp)
    8000032a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    8000032c:	00054783          	lbu	a5,0(a0)
    80000330:	cf91                	beqz	a5,8000034c <strlen+0x26>
    80000332:	0505                	addi	a0,a0,1
    80000334:	87aa                	mv	a5,a0
    80000336:	4685                	li	a3,1
    80000338:	9e89                	subw	a3,a3,a0
    8000033a:	00f6853b          	addw	a0,a3,a5
    8000033e:	0785                	addi	a5,a5,1
    80000340:	fff7c703          	lbu	a4,-1(a5)
    80000344:	fb7d                	bnez	a4,8000033a <strlen+0x14>
    ;
  return n;
}
    80000346:	6422                	ld	s0,8(sp)
    80000348:	0141                	addi	sp,sp,16
    8000034a:	8082                	ret
  for(n = 0; s[n]; n++)
    8000034c:	4501                	li	a0,0
    8000034e:	bfe5                	j	80000346 <strlen+0x20>

0000000080000350 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000350:	1101                	addi	sp,sp,-32
    80000352:	ec06                	sd	ra,24(sp)
    80000354:	e822                	sd	s0,16(sp)
    80000356:	e426                	sd	s1,8(sp)
    80000358:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    8000035a:	00001097          	auipc	ra,0x1
    8000035e:	b7a080e7          	jalr	-1158(ra) # 80000ed4 <cpuid>
    kcsaninit();
#endif
    __sync_synchronize();
    started = 1;
  } else {
    while(lockfree_read4((int *) &started) == 0)
    80000362:	0000a497          	auipc	s1,0xa
    80000366:	c9e48493          	addi	s1,s1,-866 # 8000a000 <started>
  if(cpuid() == 0){
    8000036a:	c531                	beqz	a0,800003b6 <main+0x66>
    while(lockfree_read4((int *) &started) == 0)
    8000036c:	8526                	mv	a0,s1
    8000036e:	00007097          	auipc	ra,0x7
    80000372:	098080e7          	jalr	152(ra) # 80007406 <lockfree_read4>
    80000376:	d97d                	beqz	a0,8000036c <main+0x1c>
      ;
    __sync_synchronize();
    80000378:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    8000037c:	00001097          	auipc	ra,0x1
    80000380:	b58080e7          	jalr	-1192(ra) # 80000ed4 <cpuid>
    80000384:	85aa                	mv	a1,a0
    80000386:	00009517          	auipc	a0,0x9
    8000038a:	cb250513          	addi	a0,a0,-846 # 80009038 <etext+0x38>
    8000038e:	00007097          	auipc	ra,0x7
    80000392:	a44080e7          	jalr	-1468(ra) # 80006dd2 <printf>
    kvminithart();    // turn on paging
    80000396:	00000097          	auipc	ra,0x0
    8000039a:	0e8080e7          	jalr	232(ra) # 8000047e <kvminithart>
    trapinithart();   // install kernel trap vector
    8000039e:	00001097          	auipc	ra,0x1
    800003a2:	7cc080e7          	jalr	1996(ra) # 80001b6a <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    800003a6:	00005097          	auipc	ra,0x5
    800003aa:	f1e080e7          	jalr	-226(ra) # 800052c4 <plicinithart>
  }

  scheduler();        
    800003ae:	00001097          	auipc	ra,0x1
    800003b2:	088080e7          	jalr	136(ra) # 80001436 <scheduler>
    consoleinit();
    800003b6:	00007097          	auipc	ra,0x7
    800003ba:	8e0080e7          	jalr	-1824(ra) # 80006c96 <consoleinit>
    printfinit();
    800003be:	00007097          	auipc	ra,0x7
    800003c2:	bfa080e7          	jalr	-1030(ra) # 80006fb8 <printfinit>
    printf("\n");
    800003c6:	00009517          	auipc	a0,0x9
    800003ca:	c8250513          	addi	a0,a0,-894 # 80009048 <etext+0x48>
    800003ce:	00007097          	auipc	ra,0x7
    800003d2:	a04080e7          	jalr	-1532(ra) # 80006dd2 <printf>
    printf("xv6 kernel is booting\n");
    800003d6:	00009517          	auipc	a0,0x9
    800003da:	c4a50513          	addi	a0,a0,-950 # 80009020 <etext+0x20>
    800003de:	00007097          	auipc	ra,0x7
    800003e2:	9f4080e7          	jalr	-1548(ra) # 80006dd2 <printf>
    printf("\n");
    800003e6:	00009517          	auipc	a0,0x9
    800003ea:	c6250513          	addi	a0,a0,-926 # 80009048 <etext+0x48>
    800003ee:	00007097          	auipc	ra,0x7
    800003f2:	9e4080e7          	jalr	-1564(ra) # 80006dd2 <printf>
    kinit();         // physical page allocator
    800003f6:	00000097          	auipc	ra,0x0
    800003fa:	cea080e7          	jalr	-790(ra) # 800000e0 <kinit>
    kvminit();       // create kernel page table
    800003fe:	00000097          	auipc	ra,0x0
    80000402:	350080e7          	jalr	848(ra) # 8000074e <kvminit>
    kvminithart();   // turn on paging
    80000406:	00000097          	auipc	ra,0x0
    8000040a:	078080e7          	jalr	120(ra) # 8000047e <kvminithart>
    procinit();      // process table
    8000040e:	00001097          	auipc	ra,0x1
    80000412:	a2e080e7          	jalr	-1490(ra) # 80000e3c <procinit>
    trapinit();      // trap vectors
    80000416:	00001097          	auipc	ra,0x1
    8000041a:	72c080e7          	jalr	1836(ra) # 80001b42 <trapinit>
    trapinithart();  // install kernel trap vector
    8000041e:	00001097          	auipc	ra,0x1
    80000422:	74c080e7          	jalr	1868(ra) # 80001b6a <trapinithart>
    plicinit();      // set up interrupt controller
    80000426:	00005097          	auipc	ra,0x5
    8000042a:	e74080e7          	jalr	-396(ra) # 8000529a <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    8000042e:	00005097          	auipc	ra,0x5
    80000432:	e96080e7          	jalr	-362(ra) # 800052c4 <plicinithart>
    binit();         // buffer cache
    80000436:	00002097          	auipc	ra,0x2
    8000043a:	eb4080e7          	jalr	-332(ra) # 800022ea <binit>
    iinit();         // inode cache
    8000043e:	00002097          	auipc	ra,0x2
    80000442:	586080e7          	jalr	1414(ra) # 800029c4 <iinit>
    fileinit();      // file table
    80000446:	00003097          	auipc	ra,0x3
    8000044a:	564080e7          	jalr	1380(ra) # 800039aa <fileinit>
    virtio_disk_init(); // emulated hard disk
    8000044e:	00005097          	auipc	ra,0x5
    80000452:	f9e080e7          	jalr	-98(ra) # 800053ec <virtio_disk_init>
    pci_init();
    80000456:	00006097          	auipc	ra,0x6
    8000045a:	368080e7          	jalr	872(ra) # 800067be <pci_init>
    sockinit();
    8000045e:	00006097          	auipc	ra,0x6
    80000462:	f4a080e7          	jalr	-182(ra) # 800063a8 <sockinit>
    userinit();      // first user process
    80000466:	00001097          	auipc	ra,0x1
    8000046a:	d66080e7          	jalr	-666(ra) # 800011cc <userinit>
    __sync_synchronize();
    8000046e:	0ff0000f          	fence
    started = 1;
    80000472:	4785                	li	a5,1
    80000474:	0000a717          	auipc	a4,0xa
    80000478:	b8f72623          	sw	a5,-1140(a4) # 8000a000 <started>
    8000047c:	bf0d                	j	800003ae <main+0x5e>

000000008000047e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    8000047e:	1141                	addi	sp,sp,-16
    80000480:	e422                	sd	s0,8(sp)
    80000482:	0800                	addi	s0,sp,16
  w_satp(MAKE_SATP(kernel_pagetable));
    80000484:	0000a797          	auipc	a5,0xa
    80000488:	b8478793          	addi	a5,a5,-1148 # 8000a008 <kernel_pagetable>
    8000048c:	639c                	ld	a5,0(a5)
    8000048e:	83b1                	srli	a5,a5,0xc
    80000490:	577d                	li	a4,-1
    80000492:	177e                	slli	a4,a4,0x3f
    80000494:	8fd9                	or	a5,a5,a4
// supervisor address translation and protection;
// holds the address of the page table.
static inline void 
w_satp(uint64 x)
{
  asm volatile("csrw satp, %0" : : "r" (x));
    80000496:	18079073          	csrw	satp,a5
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    8000049a:	12000073          	sfence.vma
  sfence_vma();
}
    8000049e:	6422                	ld	s0,8(sp)
    800004a0:	0141                	addi	sp,sp,16
    800004a2:	8082                	ret

00000000800004a4 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    800004a4:	7139                	addi	sp,sp,-64
    800004a6:	fc06                	sd	ra,56(sp)
    800004a8:	f822                	sd	s0,48(sp)
    800004aa:	f426                	sd	s1,40(sp)
    800004ac:	f04a                	sd	s2,32(sp)
    800004ae:	ec4e                	sd	s3,24(sp)
    800004b0:	e852                	sd	s4,16(sp)
    800004b2:	e456                	sd	s5,8(sp)
    800004b4:	e05a                	sd	s6,0(sp)
    800004b6:	0080                	addi	s0,sp,64
    800004b8:	84aa                	mv	s1,a0
    800004ba:	89ae                	mv	s3,a1
    800004bc:	8b32                	mv	s6,a2
  if(va >= MAXVA)
    800004be:	57fd                	li	a5,-1
    800004c0:	83e9                	srli	a5,a5,0x1a
    800004c2:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    800004c4:	4ab1                	li	s5,12
  if(va >= MAXVA)
    800004c6:	04b7f263          	bleu	a1,a5,8000050a <walk+0x66>
    panic("walk");
    800004ca:	00009517          	auipc	a0,0x9
    800004ce:	b8650513          	addi	a0,a0,-1146 # 80009050 <etext+0x50>
    800004d2:	00007097          	auipc	ra,0x7
    800004d6:	8b6080e7          	jalr	-1866(ra) # 80006d88 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    800004da:	060b0663          	beqz	s6,80000546 <walk+0xa2>
    800004de:	00000097          	auipc	ra,0x0
    800004e2:	c3e080e7          	jalr	-962(ra) # 8000011c <kalloc>
    800004e6:	84aa                	mv	s1,a0
    800004e8:	c529                	beqz	a0,80000532 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    800004ea:	6605                	lui	a2,0x1
    800004ec:	4581                	li	a1,0
    800004ee:	00000097          	auipc	ra,0x0
    800004f2:	c8e080e7          	jalr	-882(ra) # 8000017c <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    800004f6:	00c4d793          	srli	a5,s1,0xc
    800004fa:	07aa                	slli	a5,a5,0xa
    800004fc:	0017e793          	ori	a5,a5,1
    80000500:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000504:	3a5d                	addiw	s4,s4,-9
    80000506:	035a0063          	beq	s4,s5,80000526 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000050a:	0149d933          	srl	s2,s3,s4
    8000050e:	1ff97913          	andi	s2,s2,511
    80000512:	090e                	slli	s2,s2,0x3
    80000514:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000516:	00093483          	ld	s1,0(s2)
    8000051a:	0014f793          	andi	a5,s1,1
    8000051e:	dfd5                	beqz	a5,800004da <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000520:	80a9                	srli	s1,s1,0xa
    80000522:	04b2                	slli	s1,s1,0xc
    80000524:	b7c5                	j	80000504 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80000526:	00c9d513          	srli	a0,s3,0xc
    8000052a:	1ff57513          	andi	a0,a0,511
    8000052e:	050e                	slli	a0,a0,0x3
    80000530:	9526                	add	a0,a0,s1
}
    80000532:	70e2                	ld	ra,56(sp)
    80000534:	7442                	ld	s0,48(sp)
    80000536:	74a2                	ld	s1,40(sp)
    80000538:	7902                	ld	s2,32(sp)
    8000053a:	69e2                	ld	s3,24(sp)
    8000053c:	6a42                	ld	s4,16(sp)
    8000053e:	6aa2                	ld	s5,8(sp)
    80000540:	6b02                	ld	s6,0(sp)
    80000542:	6121                	addi	sp,sp,64
    80000544:	8082                	ret
        return 0;
    80000546:	4501                	li	a0,0
    80000548:	b7ed                	j	80000532 <walk+0x8e>

000000008000054a <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000054a:	57fd                	li	a5,-1
    8000054c:	83e9                	srli	a5,a5,0x1a
    8000054e:	00b7f463          	bleu	a1,a5,80000556 <walkaddr+0xc>
    return 0;
    80000552:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000554:	8082                	ret
{
    80000556:	1141                	addi	sp,sp,-16
    80000558:	e406                	sd	ra,8(sp)
    8000055a:	e022                	sd	s0,0(sp)
    8000055c:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    8000055e:	4601                	li	a2,0
    80000560:	00000097          	auipc	ra,0x0
    80000564:	f44080e7          	jalr	-188(ra) # 800004a4 <walk>
  if(pte == 0)
    80000568:	c105                	beqz	a0,80000588 <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000056a:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000056c:	0117f693          	andi	a3,a5,17
    80000570:	4745                	li	a4,17
    return 0;
    80000572:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000574:	00e68663          	beq	a3,a4,80000580 <walkaddr+0x36>
}
    80000578:	60a2                	ld	ra,8(sp)
    8000057a:	6402                	ld	s0,0(sp)
    8000057c:	0141                	addi	sp,sp,16
    8000057e:	8082                	ret
  pa = PTE2PA(*pte);
    80000580:	00a7d513          	srli	a0,a5,0xa
    80000584:	0532                	slli	a0,a0,0xc
  return pa;
    80000586:	bfcd                	j	80000578 <walkaddr+0x2e>
    return 0;
    80000588:	4501                	li	a0,0
    8000058a:	b7fd                	j	80000578 <walkaddr+0x2e>

000000008000058c <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000058c:	715d                	addi	sp,sp,-80
    8000058e:	e486                	sd	ra,72(sp)
    80000590:	e0a2                	sd	s0,64(sp)
    80000592:	fc26                	sd	s1,56(sp)
    80000594:	f84a                	sd	s2,48(sp)
    80000596:	f44e                	sd	s3,40(sp)
    80000598:	f052                	sd	s4,32(sp)
    8000059a:	ec56                	sd	s5,24(sp)
    8000059c:	e85a                	sd	s6,16(sp)
    8000059e:	e45e                	sd	s7,8(sp)
    800005a0:	0880                	addi	s0,sp,80
    800005a2:	8aaa                	mv	s5,a0
    800005a4:	8b3a                	mv	s6,a4
  uint64 a, last;
  pte_t *pte;

  a = PGROUNDDOWN(va);
    800005a6:	79fd                	lui	s3,0xfffff
    800005a8:	0135fa33          	and	s4,a1,s3
  last = PGROUNDDOWN(va + size - 1);
    800005ac:	167d                	addi	a2,a2,-1
    800005ae:	962e                	add	a2,a2,a1
    800005b0:	013679b3          	and	s3,a2,s3
  a = PGROUNDDOWN(va);
    800005b4:	8952                	mv	s2,s4
    800005b6:	41468a33          	sub	s4,a3,s4
    if(*pte & PTE_V)
      panic("remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800005ba:	6b85                	lui	s7,0x1
    800005bc:	a811                	j	800005d0 <mappages+0x44>
      panic("remap");
    800005be:	00009517          	auipc	a0,0x9
    800005c2:	a9a50513          	addi	a0,a0,-1382 # 80009058 <etext+0x58>
    800005c6:	00006097          	auipc	ra,0x6
    800005ca:	7c2080e7          	jalr	1986(ra) # 80006d88 <panic>
    a += PGSIZE;
    800005ce:	995e                	add	s2,s2,s7
  for(;;){
    800005d0:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800005d4:	4605                	li	a2,1
    800005d6:	85ca                	mv	a1,s2
    800005d8:	8556                	mv	a0,s5
    800005da:	00000097          	auipc	ra,0x0
    800005de:	eca080e7          	jalr	-310(ra) # 800004a4 <walk>
    800005e2:	cd19                	beqz	a0,80000600 <mappages+0x74>
    if(*pte & PTE_V)
    800005e4:	611c                	ld	a5,0(a0)
    800005e6:	8b85                	andi	a5,a5,1
    800005e8:	fbf9                	bnez	a5,800005be <mappages+0x32>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800005ea:	80b1                	srli	s1,s1,0xc
    800005ec:	04aa                	slli	s1,s1,0xa
    800005ee:	0164e4b3          	or	s1,s1,s6
    800005f2:	0014e493          	ori	s1,s1,1
    800005f6:	e104                	sd	s1,0(a0)
    if(a == last)
    800005f8:	fd391be3          	bne	s2,s3,800005ce <mappages+0x42>
    pa += PGSIZE;
  }
  return 0;
    800005fc:	4501                	li	a0,0
    800005fe:	a011                	j	80000602 <mappages+0x76>
      return -1;
    80000600:	557d                	li	a0,-1
}
    80000602:	60a6                	ld	ra,72(sp)
    80000604:	6406                	ld	s0,64(sp)
    80000606:	74e2                	ld	s1,56(sp)
    80000608:	7942                	ld	s2,48(sp)
    8000060a:	79a2                	ld	s3,40(sp)
    8000060c:	7a02                	ld	s4,32(sp)
    8000060e:	6ae2                	ld	s5,24(sp)
    80000610:	6b42                	ld	s6,16(sp)
    80000612:	6ba2                	ld	s7,8(sp)
    80000614:	6161                	addi	sp,sp,80
    80000616:	8082                	ret

0000000080000618 <kvmmap>:
{
    80000618:	1141                	addi	sp,sp,-16
    8000061a:	e406                	sd	ra,8(sp)
    8000061c:	e022                	sd	s0,0(sp)
    8000061e:	0800                	addi	s0,sp,16
    80000620:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80000622:	86b2                	mv	a3,a2
    80000624:	863e                	mv	a2,a5
    80000626:	00000097          	auipc	ra,0x0
    8000062a:	f66080e7          	jalr	-154(ra) # 8000058c <mappages>
    8000062e:	e509                	bnez	a0,80000638 <kvmmap+0x20>
}
    80000630:	60a2                	ld	ra,8(sp)
    80000632:	6402                	ld	s0,0(sp)
    80000634:	0141                	addi	sp,sp,16
    80000636:	8082                	ret
    panic("kvmmap");
    80000638:	00009517          	auipc	a0,0x9
    8000063c:	a2850513          	addi	a0,a0,-1496 # 80009060 <etext+0x60>
    80000640:	00006097          	auipc	ra,0x6
    80000644:	748080e7          	jalr	1864(ra) # 80006d88 <panic>

0000000080000648 <kvmmake>:
{
    80000648:	1101                	addi	sp,sp,-32
    8000064a:	ec06                	sd	ra,24(sp)
    8000064c:	e822                	sd	s0,16(sp)
    8000064e:	e426                	sd	s1,8(sp)
    80000650:	e04a                	sd	s2,0(sp)
    80000652:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    80000654:	00000097          	auipc	ra,0x0
    80000658:	ac8080e7          	jalr	-1336(ra) # 8000011c <kalloc>
    8000065c:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    8000065e:	6605                	lui	a2,0x1
    80000660:	4581                	li	a1,0
    80000662:	00000097          	auipc	ra,0x0
    80000666:	b1a080e7          	jalr	-1254(ra) # 8000017c <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    8000066a:	4719                	li	a4,6
    8000066c:	6685                	lui	a3,0x1
    8000066e:	10000637          	lui	a2,0x10000
    80000672:	100005b7          	lui	a1,0x10000
    80000676:	8526                	mv	a0,s1
    80000678:	00000097          	auipc	ra,0x0
    8000067c:	fa0080e7          	jalr	-96(ra) # 80000618 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80000680:	4719                	li	a4,6
    80000682:	6685                	lui	a3,0x1
    80000684:	10001637          	lui	a2,0x10001
    80000688:	100015b7          	lui	a1,0x10001
    8000068c:	8526                	mv	a0,s1
    8000068e:	00000097          	auipc	ra,0x0
    80000692:	f8a080e7          	jalr	-118(ra) # 80000618 <kvmmap>
  kvmmap(kpgtbl, 0x30000000L, 0x30000000L, 0x10000000, PTE_R | PTE_W);
    80000696:	4719                	li	a4,6
    80000698:	100006b7          	lui	a3,0x10000
    8000069c:	30000637          	lui	a2,0x30000
    800006a0:	300005b7          	lui	a1,0x30000
    800006a4:	8526                	mv	a0,s1
    800006a6:	00000097          	auipc	ra,0x0
    800006aa:	f72080e7          	jalr	-142(ra) # 80000618 <kvmmap>
  kvmmap(kpgtbl, 0x40000000L, 0x40000000L, 0x20000, PTE_R | PTE_W);
    800006ae:	4719                	li	a4,6
    800006b0:	000206b7          	lui	a3,0x20
    800006b4:	40000637          	lui	a2,0x40000
    800006b8:	400005b7          	lui	a1,0x40000
    800006bc:	8526                	mv	a0,s1
    800006be:	00000097          	auipc	ra,0x0
    800006c2:	f5a080e7          	jalr	-166(ra) # 80000618 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800006c6:	4719                	li	a4,6
    800006c8:	004006b7          	lui	a3,0x400
    800006cc:	0c000637          	lui	a2,0xc000
    800006d0:	0c0005b7          	lui	a1,0xc000
    800006d4:	8526                	mv	a0,s1
    800006d6:	00000097          	auipc	ra,0x0
    800006da:	f42080e7          	jalr	-190(ra) # 80000618 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800006de:	00009917          	auipc	s2,0x9
    800006e2:	92290913          	addi	s2,s2,-1758 # 80009000 <etext>
    800006e6:	4729                	li	a4,10
    800006e8:	80009697          	auipc	a3,0x80009
    800006ec:	91868693          	addi	a3,a3,-1768 # 9000 <_entry-0x7fff7000>
    800006f0:	4605                	li	a2,1
    800006f2:	067e                	slli	a2,a2,0x1f
    800006f4:	85b2                	mv	a1,a2
    800006f6:	8526                	mv	a0,s1
    800006f8:	00000097          	auipc	ra,0x0
    800006fc:	f20080e7          	jalr	-224(ra) # 80000618 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    80000700:	4719                	li	a4,6
    80000702:	46c5                	li	a3,17
    80000704:	06ee                	slli	a3,a3,0x1b
    80000706:	412686b3          	sub	a3,a3,s2
    8000070a:	864a                	mv	a2,s2
    8000070c:	85ca                	mv	a1,s2
    8000070e:	8526                	mv	a0,s1
    80000710:	00000097          	auipc	ra,0x0
    80000714:	f08080e7          	jalr	-248(ra) # 80000618 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80000718:	4729                	li	a4,10
    8000071a:	6685                	lui	a3,0x1
    8000071c:	00008617          	auipc	a2,0x8
    80000720:	8e460613          	addi	a2,a2,-1820 # 80008000 <_trampoline>
    80000724:	040005b7          	lui	a1,0x4000
    80000728:	15fd                	addi	a1,a1,-1
    8000072a:	05b2                	slli	a1,a1,0xc
    8000072c:	8526                	mv	a0,s1
    8000072e:	00000097          	auipc	ra,0x0
    80000732:	eea080e7          	jalr	-278(ra) # 80000618 <kvmmap>
  proc_mapstacks(kpgtbl);
    80000736:	8526                	mv	a0,s1
    80000738:	00000097          	auipc	ra,0x0
    8000073c:	66e080e7          	jalr	1646(ra) # 80000da6 <proc_mapstacks>
}
    80000740:	8526                	mv	a0,s1
    80000742:	60e2                	ld	ra,24(sp)
    80000744:	6442                	ld	s0,16(sp)
    80000746:	64a2                	ld	s1,8(sp)
    80000748:	6902                	ld	s2,0(sp)
    8000074a:	6105                	addi	sp,sp,32
    8000074c:	8082                	ret

000000008000074e <kvminit>:
{
    8000074e:	1141                	addi	sp,sp,-16
    80000750:	e406                	sd	ra,8(sp)
    80000752:	e022                	sd	s0,0(sp)
    80000754:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    80000756:	00000097          	auipc	ra,0x0
    8000075a:	ef2080e7          	jalr	-270(ra) # 80000648 <kvmmake>
    8000075e:	0000a797          	auipc	a5,0xa
    80000762:	8aa7b523          	sd	a0,-1878(a5) # 8000a008 <kernel_pagetable>
}
    80000766:	60a2                	ld	ra,8(sp)
    80000768:	6402                	ld	s0,0(sp)
    8000076a:	0141                	addi	sp,sp,16
    8000076c:	8082                	ret

000000008000076e <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    8000076e:	715d                	addi	sp,sp,-80
    80000770:	e486                	sd	ra,72(sp)
    80000772:	e0a2                	sd	s0,64(sp)
    80000774:	fc26                	sd	s1,56(sp)
    80000776:	f84a                	sd	s2,48(sp)
    80000778:	f44e                	sd	s3,40(sp)
    8000077a:	f052                	sd	s4,32(sp)
    8000077c:	ec56                	sd	s5,24(sp)
    8000077e:	e85a                	sd	s6,16(sp)
    80000780:	e45e                	sd	s7,8(sp)
    80000782:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    80000784:	6785                	lui	a5,0x1
    80000786:	17fd                	addi	a5,a5,-1
    80000788:	8fed                	and	a5,a5,a1
    8000078a:	e795                	bnez	a5,800007b6 <uvmunmap+0x48>
    8000078c:	8a2a                	mv	s4,a0
    8000078e:	84ae                	mv	s1,a1
    80000790:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80000792:	0632                	slli	a2,a2,0xc
    80000794:	00b609b3          	add	s3,a2,a1
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0) {
      printf("va=%p pte=%p\n", a, *pte);
      panic("uvmunmap: not mapped");
    }
    if(PTE_FLAGS(*pte) == PTE_V)
    80000798:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000079a:	6b05                	lui	s6,0x1
    8000079c:	0935e263          	bltu	a1,s3,80000820 <uvmunmap+0xb2>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    800007a0:	60a6                	ld	ra,72(sp)
    800007a2:	6406                	ld	s0,64(sp)
    800007a4:	74e2                	ld	s1,56(sp)
    800007a6:	7942                	ld	s2,48(sp)
    800007a8:	79a2                	ld	s3,40(sp)
    800007aa:	7a02                	ld	s4,32(sp)
    800007ac:	6ae2                	ld	s5,24(sp)
    800007ae:	6b42                	ld	s6,16(sp)
    800007b0:	6ba2                	ld	s7,8(sp)
    800007b2:	6161                	addi	sp,sp,80
    800007b4:	8082                	ret
    panic("uvmunmap: not aligned");
    800007b6:	00009517          	auipc	a0,0x9
    800007ba:	8b250513          	addi	a0,a0,-1870 # 80009068 <etext+0x68>
    800007be:	00006097          	auipc	ra,0x6
    800007c2:	5ca080e7          	jalr	1482(ra) # 80006d88 <panic>
      panic("uvmunmap: walk");
    800007c6:	00009517          	auipc	a0,0x9
    800007ca:	8ba50513          	addi	a0,a0,-1862 # 80009080 <etext+0x80>
    800007ce:	00006097          	auipc	ra,0x6
    800007d2:	5ba080e7          	jalr	1466(ra) # 80006d88 <panic>
      printf("va=%p pte=%p\n", a, *pte);
    800007d6:	862a                	mv	a2,a0
    800007d8:	85a6                	mv	a1,s1
    800007da:	00009517          	auipc	a0,0x9
    800007de:	8b650513          	addi	a0,a0,-1866 # 80009090 <etext+0x90>
    800007e2:	00006097          	auipc	ra,0x6
    800007e6:	5f0080e7          	jalr	1520(ra) # 80006dd2 <printf>
      panic("uvmunmap: not mapped");
    800007ea:	00009517          	auipc	a0,0x9
    800007ee:	8b650513          	addi	a0,a0,-1866 # 800090a0 <etext+0xa0>
    800007f2:	00006097          	auipc	ra,0x6
    800007f6:	596080e7          	jalr	1430(ra) # 80006d88 <panic>
      panic("uvmunmap: not a leaf");
    800007fa:	00009517          	auipc	a0,0x9
    800007fe:	8be50513          	addi	a0,a0,-1858 # 800090b8 <etext+0xb8>
    80000802:	00006097          	auipc	ra,0x6
    80000806:	586080e7          	jalr	1414(ra) # 80006d88 <panic>
      uint64 pa = PTE2PA(*pte);
    8000080a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000080c:	0532                	slli	a0,a0,0xc
    8000080e:	00000097          	auipc	ra,0x0
    80000812:	80e080e7          	jalr	-2034(ra) # 8000001c <kfree>
    *pte = 0;
    80000816:	00093023          	sd	zero,0(s2)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000081a:	94da                	add	s1,s1,s6
    8000081c:	f934f2e3          	bleu	s3,s1,800007a0 <uvmunmap+0x32>
    if((pte = walk(pagetable, a, 0)) == 0)
    80000820:	4601                	li	a2,0
    80000822:	85a6                	mv	a1,s1
    80000824:	8552                	mv	a0,s4
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	c7e080e7          	jalr	-898(ra) # 800004a4 <walk>
    8000082e:	892a                	mv	s2,a0
    80000830:	d959                	beqz	a0,800007c6 <uvmunmap+0x58>
    if((*pte & PTE_V) == 0) {
    80000832:	6108                	ld	a0,0(a0)
    80000834:	00157793          	andi	a5,a0,1
    80000838:	dfd9                	beqz	a5,800007d6 <uvmunmap+0x68>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000083a:	3ff57793          	andi	a5,a0,1023
    8000083e:	fb778ee3          	beq	a5,s7,800007fa <uvmunmap+0x8c>
    if(do_free){
    80000842:	fc0a8ae3          	beqz	s5,80000816 <uvmunmap+0xa8>
    80000846:	b7d1                	j	8000080a <uvmunmap+0x9c>

0000000080000848 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80000848:	1101                	addi	sp,sp,-32
    8000084a:	ec06                	sd	ra,24(sp)
    8000084c:	e822                	sd	s0,16(sp)
    8000084e:	e426                	sd	s1,8(sp)
    80000850:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80000852:	00000097          	auipc	ra,0x0
    80000856:	8ca080e7          	jalr	-1846(ra) # 8000011c <kalloc>
    8000085a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000085c:	c519                	beqz	a0,8000086a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000085e:	6605                	lui	a2,0x1
    80000860:	4581                	li	a1,0
    80000862:	00000097          	auipc	ra,0x0
    80000866:	91a080e7          	jalr	-1766(ra) # 8000017c <memset>
  return pagetable;
}
    8000086a:	8526                	mv	a0,s1
    8000086c:	60e2                	ld	ra,24(sp)
    8000086e:	6442                	ld	s0,16(sp)
    80000870:	64a2                	ld	s1,8(sp)
    80000872:	6105                	addi	sp,sp,32
    80000874:	8082                	ret

0000000080000876 <uvminit>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvminit(pagetable_t pagetable, uchar *src, uint sz)
{
    80000876:	7179                	addi	sp,sp,-48
    80000878:	f406                	sd	ra,40(sp)
    8000087a:	f022                	sd	s0,32(sp)
    8000087c:	ec26                	sd	s1,24(sp)
    8000087e:	e84a                	sd	s2,16(sp)
    80000880:	e44e                	sd	s3,8(sp)
    80000882:	e052                	sd	s4,0(sp)
    80000884:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80000886:	6785                	lui	a5,0x1
    80000888:	04f67863          	bleu	a5,a2,800008d8 <uvminit+0x62>
    8000088c:	8a2a                	mv	s4,a0
    8000088e:	89ae                	mv	s3,a1
    80000890:	84b2                	mv	s1,a2
    panic("inituvm: more than a page");
  mem = kalloc();
    80000892:	00000097          	auipc	ra,0x0
    80000896:	88a080e7          	jalr	-1910(ra) # 8000011c <kalloc>
    8000089a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000089c:	6605                	lui	a2,0x1
    8000089e:	4581                	li	a1,0
    800008a0:	00000097          	auipc	ra,0x0
    800008a4:	8dc080e7          	jalr	-1828(ra) # 8000017c <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800008a8:	4779                	li	a4,30
    800008aa:	86ca                	mv	a3,s2
    800008ac:	6605                	lui	a2,0x1
    800008ae:	4581                	li	a1,0
    800008b0:	8552                	mv	a0,s4
    800008b2:	00000097          	auipc	ra,0x0
    800008b6:	cda080e7          	jalr	-806(ra) # 8000058c <mappages>
  memmove(mem, src, sz);
    800008ba:	8626                	mv	a2,s1
    800008bc:	85ce                	mv	a1,s3
    800008be:	854a                	mv	a0,s2
    800008c0:	00000097          	auipc	ra,0x0
    800008c4:	928080e7          	jalr	-1752(ra) # 800001e8 <memmove>
}
    800008c8:	70a2                	ld	ra,40(sp)
    800008ca:	7402                	ld	s0,32(sp)
    800008cc:	64e2                	ld	s1,24(sp)
    800008ce:	6942                	ld	s2,16(sp)
    800008d0:	69a2                	ld	s3,8(sp)
    800008d2:	6a02                	ld	s4,0(sp)
    800008d4:	6145                	addi	sp,sp,48
    800008d6:	8082                	ret
    panic("inituvm: more than a page");
    800008d8:	00008517          	auipc	a0,0x8
    800008dc:	7f850513          	addi	a0,a0,2040 # 800090d0 <etext+0xd0>
    800008e0:	00006097          	auipc	ra,0x6
    800008e4:	4a8080e7          	jalr	1192(ra) # 80006d88 <panic>

00000000800008e8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800008e8:	1101                	addi	sp,sp,-32
    800008ea:	ec06                	sd	ra,24(sp)
    800008ec:	e822                	sd	s0,16(sp)
    800008ee:	e426                	sd	s1,8(sp)
    800008f0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800008f2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800008f4:	00b67d63          	bleu	a1,a2,8000090e <uvmdealloc+0x26>
    800008f8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800008fa:	6605                	lui	a2,0x1
    800008fc:	167d                	addi	a2,a2,-1
    800008fe:	00c487b3          	add	a5,s1,a2
    80000902:	777d                	lui	a4,0xfffff
    80000904:	8ff9                	and	a5,a5,a4
    80000906:	962e                	add	a2,a2,a1
    80000908:	8e79                	and	a2,a2,a4
    8000090a:	00c7e863          	bltu	a5,a2,8000091a <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    8000090e:	8526                	mv	a0,s1
    80000910:	60e2                	ld	ra,24(sp)
    80000912:	6442                	ld	s0,16(sp)
    80000914:	64a2                	ld	s1,8(sp)
    80000916:	6105                	addi	sp,sp,32
    80000918:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000091a:	8e1d                	sub	a2,a2,a5
    8000091c:	8231                	srli	a2,a2,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    8000091e:	4685                	li	a3,1
    80000920:	2601                	sext.w	a2,a2
    80000922:	85be                	mv	a1,a5
    80000924:	00000097          	auipc	ra,0x0
    80000928:	e4a080e7          	jalr	-438(ra) # 8000076e <uvmunmap>
    8000092c:	b7cd                	j	8000090e <uvmdealloc+0x26>

000000008000092e <uvmalloc>:
  if(newsz < oldsz)
    8000092e:	0ab66163          	bltu	a2,a1,800009d0 <uvmalloc+0xa2>
{
    80000932:	7139                	addi	sp,sp,-64
    80000934:	fc06                	sd	ra,56(sp)
    80000936:	f822                	sd	s0,48(sp)
    80000938:	f426                	sd	s1,40(sp)
    8000093a:	f04a                	sd	s2,32(sp)
    8000093c:	ec4e                	sd	s3,24(sp)
    8000093e:	e852                	sd	s4,16(sp)
    80000940:	e456                	sd	s5,8(sp)
    80000942:	0080                	addi	s0,sp,64
  oldsz = PGROUNDUP(oldsz);
    80000944:	6a05                	lui	s4,0x1
    80000946:	1a7d                	addi	s4,s4,-1
    80000948:	95d2                	add	a1,a1,s4
    8000094a:	7a7d                	lui	s4,0xfffff
    8000094c:	0145fa33          	and	s4,a1,s4
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000950:	08ca7263          	bleu	a2,s4,800009d4 <uvmalloc+0xa6>
    80000954:	89b2                	mv	s3,a2
    80000956:	8aaa                	mv	s5,a0
    80000958:	8952                	mv	s2,s4
    mem = kalloc();
    8000095a:	fffff097          	auipc	ra,0xfffff
    8000095e:	7c2080e7          	jalr	1986(ra) # 8000011c <kalloc>
    80000962:	84aa                	mv	s1,a0
    if(mem == 0){
    80000964:	c51d                	beqz	a0,80000992 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80000966:	6605                	lui	a2,0x1
    80000968:	4581                	li	a1,0
    8000096a:	00000097          	auipc	ra,0x0
    8000096e:	812080e7          	jalr	-2030(ra) # 8000017c <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_W|PTE_X|PTE_R|PTE_U) != 0){
    80000972:	4779                	li	a4,30
    80000974:	86a6                	mv	a3,s1
    80000976:	6605                	lui	a2,0x1
    80000978:	85ca                	mv	a1,s2
    8000097a:	8556                	mv	a0,s5
    8000097c:	00000097          	auipc	ra,0x0
    80000980:	c10080e7          	jalr	-1008(ra) # 8000058c <mappages>
    80000984:	e905                	bnez	a0,800009b4 <uvmalloc+0x86>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80000986:	6785                	lui	a5,0x1
    80000988:	993e                	add	s2,s2,a5
    8000098a:	fd3968e3          	bltu	s2,s3,8000095a <uvmalloc+0x2c>
  return newsz;
    8000098e:	854e                	mv	a0,s3
    80000990:	a809                	j	800009a2 <uvmalloc+0x74>
      uvmdealloc(pagetable, a, oldsz);
    80000992:	8652                	mv	a2,s4
    80000994:	85ca                	mv	a1,s2
    80000996:	8556                	mv	a0,s5
    80000998:	00000097          	auipc	ra,0x0
    8000099c:	f50080e7          	jalr	-176(ra) # 800008e8 <uvmdealloc>
      return 0;
    800009a0:	4501                	li	a0,0
}
    800009a2:	70e2                	ld	ra,56(sp)
    800009a4:	7442                	ld	s0,48(sp)
    800009a6:	74a2                	ld	s1,40(sp)
    800009a8:	7902                	ld	s2,32(sp)
    800009aa:	69e2                	ld	s3,24(sp)
    800009ac:	6a42                	ld	s4,16(sp)
    800009ae:	6aa2                	ld	s5,8(sp)
    800009b0:	6121                	addi	sp,sp,64
    800009b2:	8082                	ret
      kfree(mem);
    800009b4:	8526                	mv	a0,s1
    800009b6:	fffff097          	auipc	ra,0xfffff
    800009ba:	666080e7          	jalr	1638(ra) # 8000001c <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800009be:	8652                	mv	a2,s4
    800009c0:	85ca                	mv	a1,s2
    800009c2:	8556                	mv	a0,s5
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	f24080e7          	jalr	-220(ra) # 800008e8 <uvmdealloc>
      return 0;
    800009cc:	4501                	li	a0,0
    800009ce:	bfd1                	j	800009a2 <uvmalloc+0x74>
    return oldsz;
    800009d0:	852e                	mv	a0,a1
}
    800009d2:	8082                	ret
  return newsz;
    800009d4:	8532                	mv	a0,a2
    800009d6:	b7f1                	j	800009a2 <uvmalloc+0x74>

00000000800009d8 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800009d8:	7179                	addi	sp,sp,-48
    800009da:	f406                	sd	ra,40(sp)
    800009dc:	f022                	sd	s0,32(sp)
    800009de:	ec26                	sd	s1,24(sp)
    800009e0:	e84a                	sd	s2,16(sp)
    800009e2:	e44e                	sd	s3,8(sp)
    800009e4:	e052                	sd	s4,0(sp)
    800009e6:	1800                	addi	s0,sp,48
    800009e8:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800009ea:	84aa                	mv	s1,a0
    800009ec:	6905                	lui	s2,0x1
    800009ee:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800009f0:	4985                	li	s3,1
    800009f2:	a821                	j	80000a0a <freewalk+0x32>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800009f4:	8129                	srli	a0,a0,0xa
      freewalk((pagetable_t)child);
    800009f6:	0532                	slli	a0,a0,0xc
    800009f8:	00000097          	auipc	ra,0x0
    800009fc:	fe0080e7          	jalr	-32(ra) # 800009d8 <freewalk>
      pagetable[i] = 0;
    80000a00:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    80000a04:	04a1                	addi	s1,s1,8
    80000a06:	03248163          	beq	s1,s2,80000a28 <freewalk+0x50>
    pte_t pte = pagetable[i];
    80000a0a:	6088                	ld	a0,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80000a0c:	00f57793          	andi	a5,a0,15
    80000a10:	ff3782e3          	beq	a5,s3,800009f4 <freewalk+0x1c>
    } else if(pte & PTE_V){
    80000a14:	8905                	andi	a0,a0,1
    80000a16:	d57d                	beqz	a0,80000a04 <freewalk+0x2c>
      panic("freewalk: leaf");
    80000a18:	00008517          	auipc	a0,0x8
    80000a1c:	6d850513          	addi	a0,a0,1752 # 800090f0 <etext+0xf0>
    80000a20:	00006097          	auipc	ra,0x6
    80000a24:	368080e7          	jalr	872(ra) # 80006d88 <panic>
    }
  }
  kfree((void*)pagetable);
    80000a28:	8552                	mv	a0,s4
    80000a2a:	fffff097          	auipc	ra,0xfffff
    80000a2e:	5f2080e7          	jalr	1522(ra) # 8000001c <kfree>
}
    80000a32:	70a2                	ld	ra,40(sp)
    80000a34:	7402                	ld	s0,32(sp)
    80000a36:	64e2                	ld	s1,24(sp)
    80000a38:	6942                	ld	s2,16(sp)
    80000a3a:	69a2                	ld	s3,8(sp)
    80000a3c:	6a02                	ld	s4,0(sp)
    80000a3e:	6145                	addi	sp,sp,48
    80000a40:	8082                	ret

0000000080000a42 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	1000                	addi	s0,sp,32
    80000a4c:	84aa                	mv	s1,a0
  if(sz > 0)
    80000a4e:	e999                	bnez	a1,80000a64 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80000a50:	8526                	mv	a0,s1
    80000a52:	00000097          	auipc	ra,0x0
    80000a56:	f86080e7          	jalr	-122(ra) # 800009d8 <freewalk>
}
    80000a5a:	60e2                	ld	ra,24(sp)
    80000a5c:	6442                	ld	s0,16(sp)
    80000a5e:	64a2                	ld	s1,8(sp)
    80000a60:	6105                	addi	sp,sp,32
    80000a62:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80000a64:	6605                	lui	a2,0x1
    80000a66:	167d                	addi	a2,a2,-1
    80000a68:	962e                	add	a2,a2,a1
    80000a6a:	4685                	li	a3,1
    80000a6c:	8231                	srli	a2,a2,0xc
    80000a6e:	4581                	li	a1,0
    80000a70:	00000097          	auipc	ra,0x0
    80000a74:	cfe080e7          	jalr	-770(ra) # 8000076e <uvmunmap>
    80000a78:	bfe1                	j	80000a50 <uvmfree+0xe>

0000000080000a7a <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80000a7a:	c679                	beqz	a2,80000b48 <uvmcopy+0xce>
{
    80000a7c:	715d                	addi	sp,sp,-80
    80000a7e:	e486                	sd	ra,72(sp)
    80000a80:	e0a2                	sd	s0,64(sp)
    80000a82:	fc26                	sd	s1,56(sp)
    80000a84:	f84a                	sd	s2,48(sp)
    80000a86:	f44e                	sd	s3,40(sp)
    80000a88:	f052                	sd	s4,32(sp)
    80000a8a:	ec56                	sd	s5,24(sp)
    80000a8c:	e85a                	sd	s6,16(sp)
    80000a8e:	e45e                	sd	s7,8(sp)
    80000a90:	0880                	addi	s0,sp,80
    80000a92:	8ab2                	mv	s5,a2
    80000a94:	8b2e                	mv	s6,a1
    80000a96:	8baa                	mv	s7,a0
  for(i = 0; i < sz; i += PGSIZE){
    80000a98:	4901                	li	s2,0
    if((pte = walk(old, i, 0)) == 0)
    80000a9a:	4601                	li	a2,0
    80000a9c:	85ca                	mv	a1,s2
    80000a9e:	855e                	mv	a0,s7
    80000aa0:	00000097          	auipc	ra,0x0
    80000aa4:	a04080e7          	jalr	-1532(ra) # 800004a4 <walk>
    80000aa8:	c531                	beqz	a0,80000af4 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80000aaa:	6118                	ld	a4,0(a0)
    80000aac:	00177793          	andi	a5,a4,1
    80000ab0:	cbb1                	beqz	a5,80000b04 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    80000ab2:	00a75593          	srli	a1,a4,0xa
    80000ab6:	00c59993          	slli	s3,a1,0xc
    flags = PTE_FLAGS(*pte);
    80000aba:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    80000abe:	fffff097          	auipc	ra,0xfffff
    80000ac2:	65e080e7          	jalr	1630(ra) # 8000011c <kalloc>
    80000ac6:	8a2a                	mv	s4,a0
    80000ac8:	c939                	beqz	a0,80000b1e <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    80000aca:	6605                	lui	a2,0x1
    80000acc:	85ce                	mv	a1,s3
    80000ace:	fffff097          	auipc	ra,0xfffff
    80000ad2:	71a080e7          	jalr	1818(ra) # 800001e8 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    80000ad6:	8726                	mv	a4,s1
    80000ad8:	86d2                	mv	a3,s4
    80000ada:	6605                	lui	a2,0x1
    80000adc:	85ca                	mv	a1,s2
    80000ade:	855a                	mv	a0,s6
    80000ae0:	00000097          	auipc	ra,0x0
    80000ae4:	aac080e7          	jalr	-1364(ra) # 8000058c <mappages>
    80000ae8:	e515                	bnez	a0,80000b14 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    80000aea:	6785                	lui	a5,0x1
    80000aec:	993e                	add	s2,s2,a5
    80000aee:	fb5966e3          	bltu	s2,s5,80000a9a <uvmcopy+0x20>
    80000af2:	a081                	j	80000b32 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    80000af4:	00008517          	auipc	a0,0x8
    80000af8:	60c50513          	addi	a0,a0,1548 # 80009100 <etext+0x100>
    80000afc:	00006097          	auipc	ra,0x6
    80000b00:	28c080e7          	jalr	652(ra) # 80006d88 <panic>
      panic("uvmcopy: page not present");
    80000b04:	00008517          	auipc	a0,0x8
    80000b08:	61c50513          	addi	a0,a0,1564 # 80009120 <etext+0x120>
    80000b0c:	00006097          	auipc	ra,0x6
    80000b10:	27c080e7          	jalr	636(ra) # 80006d88 <panic>
      kfree(mem);
    80000b14:	8552                	mv	a0,s4
    80000b16:	fffff097          	auipc	ra,0xfffff
    80000b1a:	506080e7          	jalr	1286(ra) # 8000001c <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    80000b1e:	4685                	li	a3,1
    80000b20:	00c95613          	srli	a2,s2,0xc
    80000b24:	4581                	li	a1,0
    80000b26:	855a                	mv	a0,s6
    80000b28:	00000097          	auipc	ra,0x0
    80000b2c:	c46080e7          	jalr	-954(ra) # 8000076e <uvmunmap>
  return -1;
    80000b30:	557d                	li	a0,-1
}
    80000b32:	60a6                	ld	ra,72(sp)
    80000b34:	6406                	ld	s0,64(sp)
    80000b36:	74e2                	ld	s1,56(sp)
    80000b38:	7942                	ld	s2,48(sp)
    80000b3a:	79a2                	ld	s3,40(sp)
    80000b3c:	7a02                	ld	s4,32(sp)
    80000b3e:	6ae2                	ld	s5,24(sp)
    80000b40:	6b42                	ld	s6,16(sp)
    80000b42:	6ba2                	ld	s7,8(sp)
    80000b44:	6161                	addi	sp,sp,80
    80000b46:	8082                	ret
  return 0;
    80000b48:	4501                	li	a0,0
}
    80000b4a:	8082                	ret

0000000080000b4c <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80000b4c:	1141                	addi	sp,sp,-16
    80000b4e:	e406                	sd	ra,8(sp)
    80000b50:	e022                	sd	s0,0(sp)
    80000b52:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80000b54:	4601                	li	a2,0
    80000b56:	00000097          	auipc	ra,0x0
    80000b5a:	94e080e7          	jalr	-1714(ra) # 800004a4 <walk>
  if(pte == 0)
    80000b5e:	c901                	beqz	a0,80000b6e <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80000b60:	611c                	ld	a5,0(a0)
    80000b62:	9bbd                	andi	a5,a5,-17
    80000b64:	e11c                	sd	a5,0(a0)
}
    80000b66:	60a2                	ld	ra,8(sp)
    80000b68:	6402                	ld	s0,0(sp)
    80000b6a:	0141                	addi	sp,sp,16
    80000b6c:	8082                	ret
    panic("uvmclear");
    80000b6e:	00008517          	auipc	a0,0x8
    80000b72:	5d250513          	addi	a0,a0,1490 # 80009140 <etext+0x140>
    80000b76:	00006097          	auipc	ra,0x6
    80000b7a:	212080e7          	jalr	530(ra) # 80006d88 <panic>

0000000080000b7e <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80000b7e:	c6bd                	beqz	a3,80000bec <copyout+0x6e>
{
    80000b80:	715d                	addi	sp,sp,-80
    80000b82:	e486                	sd	ra,72(sp)
    80000b84:	e0a2                	sd	s0,64(sp)
    80000b86:	fc26                	sd	s1,56(sp)
    80000b88:	f84a                	sd	s2,48(sp)
    80000b8a:	f44e                	sd	s3,40(sp)
    80000b8c:	f052                	sd	s4,32(sp)
    80000b8e:	ec56                	sd	s5,24(sp)
    80000b90:	e85a                	sd	s6,16(sp)
    80000b92:	e45e                	sd	s7,8(sp)
    80000b94:	e062                	sd	s8,0(sp)
    80000b96:	0880                	addi	s0,sp,80
    80000b98:	8baa                	mv	s7,a0
    80000b9a:	8a2e                	mv	s4,a1
    80000b9c:	8ab2                	mv	s5,a2
    80000b9e:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    80000ba0:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80000ba2:	6b05                	lui	s6,0x1
    80000ba4:	a015                	j	80000bc8 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80000ba6:	9552                	add	a0,a0,s4
    80000ba8:	0004861b          	sext.w	a2,s1
    80000bac:	85d6                	mv	a1,s5
    80000bae:	41250533          	sub	a0,a0,s2
    80000bb2:	fffff097          	auipc	ra,0xfffff
    80000bb6:	636080e7          	jalr	1590(ra) # 800001e8 <memmove>

    len -= n;
    80000bba:	409989b3          	sub	s3,s3,s1
    src += n;
    80000bbe:	9aa6                	add	s5,s5,s1
    dstva = va0 + PGSIZE;
    80000bc0:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80000bc4:	02098263          	beqz	s3,80000be8 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    80000bc8:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80000bcc:	85ca                	mv	a1,s2
    80000bce:	855e                	mv	a0,s7
    80000bd0:	00000097          	auipc	ra,0x0
    80000bd4:	97a080e7          	jalr	-1670(ra) # 8000054a <walkaddr>
    if(pa0 == 0)
    80000bd8:	cd01                	beqz	a0,80000bf0 <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    80000bda:	414904b3          	sub	s1,s2,s4
    80000bde:	94da                	add	s1,s1,s6
    if(n > len)
    80000be0:	fc99f3e3          	bleu	s1,s3,80000ba6 <copyout+0x28>
    80000be4:	84ce                	mv	s1,s3
    80000be6:	b7c1                	j	80000ba6 <copyout+0x28>
  }
  return 0;
    80000be8:	4501                	li	a0,0
    80000bea:	a021                	j	80000bf2 <copyout+0x74>
    80000bec:	4501                	li	a0,0
}
    80000bee:	8082                	ret
      return -1;
    80000bf0:	557d                	li	a0,-1
}
    80000bf2:	60a6                	ld	ra,72(sp)
    80000bf4:	6406                	ld	s0,64(sp)
    80000bf6:	74e2                	ld	s1,56(sp)
    80000bf8:	7942                	ld	s2,48(sp)
    80000bfa:	79a2                	ld	s3,40(sp)
    80000bfc:	7a02                	ld	s4,32(sp)
    80000bfe:	6ae2                	ld	s5,24(sp)
    80000c00:	6b42                	ld	s6,16(sp)
    80000c02:	6ba2                	ld	s7,8(sp)
    80000c04:	6c02                	ld	s8,0(sp)
    80000c06:	6161                	addi	sp,sp,80
    80000c08:	8082                	ret

0000000080000c0a <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;
  
  while(len > 0){
    80000c0a:	caa5                	beqz	a3,80000c7a <copyin+0x70>
{
    80000c0c:	715d                	addi	sp,sp,-80
    80000c0e:	e486                	sd	ra,72(sp)
    80000c10:	e0a2                	sd	s0,64(sp)
    80000c12:	fc26                	sd	s1,56(sp)
    80000c14:	f84a                	sd	s2,48(sp)
    80000c16:	f44e                	sd	s3,40(sp)
    80000c18:	f052                	sd	s4,32(sp)
    80000c1a:	ec56                	sd	s5,24(sp)
    80000c1c:	e85a                	sd	s6,16(sp)
    80000c1e:	e45e                	sd	s7,8(sp)
    80000c20:	e062                	sd	s8,0(sp)
    80000c22:	0880                	addi	s0,sp,80
    80000c24:	8baa                	mv	s7,a0
    80000c26:	8aae                	mv	s5,a1
    80000c28:	8a32                	mv	s4,a2
    80000c2a:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    80000c2c:	7c7d                	lui	s8,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000c2e:	6b05                	lui	s6,0x1
    80000c30:	a01d                	j	80000c56 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80000c32:	014505b3          	add	a1,a0,s4
    80000c36:	0004861b          	sext.w	a2,s1
    80000c3a:	412585b3          	sub	a1,a1,s2
    80000c3e:	8556                	mv	a0,s5
    80000c40:	fffff097          	auipc	ra,0xfffff
    80000c44:	5a8080e7          	jalr	1448(ra) # 800001e8 <memmove>

    len -= n;
    80000c48:	409989b3          	sub	s3,s3,s1
    dst += n;
    80000c4c:	9aa6                	add	s5,s5,s1
    srcva = va0 + PGSIZE;
    80000c4e:	01690a33          	add	s4,s2,s6
  while(len > 0){
    80000c52:	02098263          	beqz	s3,80000c76 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80000c56:	018a7933          	and	s2,s4,s8
    pa0 = walkaddr(pagetable, va0);
    80000c5a:	85ca                	mv	a1,s2
    80000c5c:	855e                	mv	a0,s7
    80000c5e:	00000097          	auipc	ra,0x0
    80000c62:	8ec080e7          	jalr	-1812(ra) # 8000054a <walkaddr>
    if(pa0 == 0)
    80000c66:	cd01                	beqz	a0,80000c7e <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80000c68:	414904b3          	sub	s1,s2,s4
    80000c6c:	94da                	add	s1,s1,s6
    if(n > len)
    80000c6e:	fc99f2e3          	bleu	s1,s3,80000c32 <copyin+0x28>
    80000c72:	84ce                	mv	s1,s3
    80000c74:	bf7d                	j	80000c32 <copyin+0x28>
  }
  return 0;
    80000c76:	4501                	li	a0,0
    80000c78:	a021                	j	80000c80 <copyin+0x76>
    80000c7a:	4501                	li	a0,0
}
    80000c7c:	8082                	ret
      return -1;
    80000c7e:	557d                	li	a0,-1
}
    80000c80:	60a6                	ld	ra,72(sp)
    80000c82:	6406                	ld	s0,64(sp)
    80000c84:	74e2                	ld	s1,56(sp)
    80000c86:	7942                	ld	s2,48(sp)
    80000c88:	79a2                	ld	s3,40(sp)
    80000c8a:	7a02                	ld	s4,32(sp)
    80000c8c:	6ae2                	ld	s5,24(sp)
    80000c8e:	6b42                	ld	s6,16(sp)
    80000c90:	6ba2                	ld	s7,8(sp)
    80000c92:	6c02                	ld	s8,0(sp)
    80000c94:	6161                	addi	sp,sp,80
    80000c96:	8082                	ret

0000000080000c98 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80000c98:	ced5                	beqz	a3,80000d54 <copyinstr+0xbc>
{
    80000c9a:	715d                	addi	sp,sp,-80
    80000c9c:	e486                	sd	ra,72(sp)
    80000c9e:	e0a2                	sd	s0,64(sp)
    80000ca0:	fc26                	sd	s1,56(sp)
    80000ca2:	f84a                	sd	s2,48(sp)
    80000ca4:	f44e                	sd	s3,40(sp)
    80000ca6:	f052                	sd	s4,32(sp)
    80000ca8:	ec56                	sd	s5,24(sp)
    80000caa:	e85a                	sd	s6,16(sp)
    80000cac:	e45e                	sd	s7,8(sp)
    80000cae:	e062                	sd	s8,0(sp)
    80000cb0:	0880                	addi	s0,sp,80
    80000cb2:	8aaa                	mv	s5,a0
    80000cb4:	84ae                	mv	s1,a1
    80000cb6:	8c32                	mv	s8,a2
    80000cb8:	8bb6                	mv	s7,a3
    va0 = PGROUNDDOWN(srcva);
    80000cba:	7a7d                	lui	s4,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    80000cbc:	6985                	lui	s3,0x1
    80000cbe:	4b05                	li	s6,1
    80000cc0:	a801                	j	80000cd0 <copyinstr+0x38>
    if(n > max)
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
    80000cc2:	87a6                	mv	a5,s1
    80000cc4:	a085                	j	80000d24 <copyinstr+0x8c>
        *dst = *p;
      }
      --n;
      --max;
      p++;
      dst++;
    80000cc6:	84b2                	mv	s1,a2
    }

    srcva = va0 + PGSIZE;
    80000cc8:	01390c33          	add	s8,s2,s3
  while(got_null == 0 && max > 0){
    80000ccc:	080b8063          	beqz	s7,80000d4c <copyinstr+0xb4>
    va0 = PGROUNDDOWN(srcva);
    80000cd0:	014c7933          	and	s2,s8,s4
    pa0 = walkaddr(pagetable, va0);
    80000cd4:	85ca                	mv	a1,s2
    80000cd6:	8556                	mv	a0,s5
    80000cd8:	00000097          	auipc	ra,0x0
    80000cdc:	872080e7          	jalr	-1934(ra) # 8000054a <walkaddr>
    if(pa0 == 0)
    80000ce0:	c925                	beqz	a0,80000d50 <copyinstr+0xb8>
    n = PGSIZE - (srcva - va0);
    80000ce2:	41890633          	sub	a2,s2,s8
    80000ce6:	964e                	add	a2,a2,s3
    if(n > max)
    80000ce8:	00cbf363          	bleu	a2,s7,80000cee <copyinstr+0x56>
    80000cec:	865e                	mv	a2,s7
    char *p = (char *) (pa0 + (srcva - va0));
    80000cee:	9562                	add	a0,a0,s8
    80000cf0:	41250533          	sub	a0,a0,s2
    while(n > 0){
    80000cf4:	da71                	beqz	a2,80000cc8 <copyinstr+0x30>
      if(*p == '\0'){
    80000cf6:	00054703          	lbu	a4,0(a0)
    80000cfa:	d761                	beqz	a4,80000cc2 <copyinstr+0x2a>
    80000cfc:	9626                	add	a2,a2,s1
    80000cfe:	87a6                	mv	a5,s1
    80000d00:	1bfd                	addi	s7,s7,-1
    80000d02:	009b86b3          	add	a3,s7,s1
    80000d06:	409b04b3          	sub	s1,s6,s1
    80000d0a:	94aa                	add	s1,s1,a0
        *dst = *p;
    80000d0c:	00e78023          	sb	a4,0(a5) # 1000 <_entry-0x7ffff000>
      --max;
    80000d10:	40f68bb3          	sub	s7,a3,a5
      p++;
    80000d14:	00f48733          	add	a4,s1,a5
      dst++;
    80000d18:	0785                	addi	a5,a5,1
    while(n > 0){
    80000d1a:	faf606e3          	beq	a2,a5,80000cc6 <copyinstr+0x2e>
      if(*p == '\0'){
    80000d1e:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffd7a80>
    80000d22:	f76d                	bnez	a4,80000d0c <copyinstr+0x74>
        *dst = '\0';
    80000d24:	00078023          	sb	zero,0(a5)
    80000d28:	4785                	li	a5,1
  }
  if(got_null){
    80000d2a:	0017b513          	seqz	a0,a5
    80000d2e:	40a0053b          	negw	a0,a0
    80000d32:	2501                	sext.w	a0,a0
    return 0;
  } else {
    return -1;
  }
}
    80000d34:	60a6                	ld	ra,72(sp)
    80000d36:	6406                	ld	s0,64(sp)
    80000d38:	74e2                	ld	s1,56(sp)
    80000d3a:	7942                	ld	s2,48(sp)
    80000d3c:	79a2                	ld	s3,40(sp)
    80000d3e:	7a02                	ld	s4,32(sp)
    80000d40:	6ae2                	ld	s5,24(sp)
    80000d42:	6b42                	ld	s6,16(sp)
    80000d44:	6ba2                	ld	s7,8(sp)
    80000d46:	6c02                	ld	s8,0(sp)
    80000d48:	6161                	addi	sp,sp,80
    80000d4a:	8082                	ret
    80000d4c:	4781                	li	a5,0
    80000d4e:	bff1                	j	80000d2a <copyinstr+0x92>
      return -1;
    80000d50:	557d                	li	a0,-1
    80000d52:	b7cd                	j	80000d34 <copyinstr+0x9c>
  int got_null = 0;
    80000d54:	4781                	li	a5,0
  if(got_null){
    80000d56:	0017b513          	seqz	a0,a5
    80000d5a:	40a0053b          	negw	a0,a0
    80000d5e:	2501                	sext.w	a0,a0
}
    80000d60:	8082                	ret

0000000080000d62 <wakeup1>:

// Wake up p if it is sleeping in wait(); used by exit().
// Caller must hold p->lock.
static void
wakeup1(struct proc *p)
{
    80000d62:	1101                	addi	sp,sp,-32
    80000d64:	ec06                	sd	ra,24(sp)
    80000d66:	e822                	sd	s0,16(sp)
    80000d68:	e426                	sd	s1,8(sp)
    80000d6a:	1000                	addi	s0,sp,32
    80000d6c:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80000d6e:	00006097          	auipc	ra,0x6
    80000d72:	50c080e7          	jalr	1292(ra) # 8000727a <holding>
    80000d76:	c909                	beqz	a0,80000d88 <wakeup1+0x26>
    panic("wakeup1");
  if(p->chan == p && p->state == SLEEPING) {
    80000d78:	749c                	ld	a5,40(s1)
    80000d7a:	00978f63          	beq	a5,s1,80000d98 <wakeup1+0x36>
    p->state = RUNNABLE;
  }
}
    80000d7e:	60e2                	ld	ra,24(sp)
    80000d80:	6442                	ld	s0,16(sp)
    80000d82:	64a2                	ld	s1,8(sp)
    80000d84:	6105                	addi	sp,sp,32
    80000d86:	8082                	ret
    panic("wakeup1");
    80000d88:	00008517          	auipc	a0,0x8
    80000d8c:	3f050513          	addi	a0,a0,1008 # 80009178 <states.1780+0x28>
    80000d90:	00006097          	auipc	ra,0x6
    80000d94:	ff8080e7          	jalr	-8(ra) # 80006d88 <panic>
  if(p->chan == p && p->state == SLEEPING) {
    80000d98:	4c98                	lw	a4,24(s1)
    80000d9a:	4785                	li	a5,1
    80000d9c:	fef711e3          	bne	a4,a5,80000d7e <wakeup1+0x1c>
    p->state = RUNNABLE;
    80000da0:	4789                	li	a5,2
    80000da2:	cc9c                	sw	a5,24(s1)
}
    80000da4:	bfe9                	j	80000d7e <wakeup1+0x1c>

0000000080000da6 <proc_mapstacks>:
proc_mapstacks(pagetable_t kpgtbl) {
    80000da6:	7139                	addi	sp,sp,-64
    80000da8:	fc06                	sd	ra,56(sp)
    80000daa:	f822                	sd	s0,48(sp)
    80000dac:	f426                	sd	s1,40(sp)
    80000dae:	f04a                	sd	s2,32(sp)
    80000db0:	ec4e                	sd	s3,24(sp)
    80000db2:	e852                	sd	s4,16(sp)
    80000db4:	e456                	sd	s5,8(sp)
    80000db6:	e05a                	sd	s6,0(sp)
    80000db8:	0080                	addi	s0,sp,64
    80000dba:	8b2a                	mv	s6,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dbc:	00009497          	auipc	s1,0x9
    80000dc0:	6cc48493          	addi	s1,s1,1740 # 8000a488 <proc>
    uint64 va = KSTACK((int) (p - proc));
    80000dc4:	8aa6                	mv	s5,s1
    80000dc6:	00008a17          	auipc	s4,0x8
    80000dca:	23aa0a13          	addi	s4,s4,570 # 80009000 <etext>
    80000dce:	04000937          	lui	s2,0x4000
    80000dd2:	197d                	addi	s2,s2,-1
    80000dd4:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000dd6:	0000f997          	auipc	s3,0xf
    80000dda:	0b298993          	addi	s3,s3,178 # 8000fe88 <tickslock>
    char *pa = kalloc();
    80000dde:	fffff097          	auipc	ra,0xfffff
    80000de2:	33e080e7          	jalr	830(ra) # 8000011c <kalloc>
    80000de6:	862a                	mv	a2,a0
    if(pa == 0)
    80000de8:	c131                	beqz	a0,80000e2c <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    80000dea:	415485b3          	sub	a1,s1,s5
    80000dee:	858d                	srai	a1,a1,0x3
    80000df0:	000a3783          	ld	a5,0(s4)
    80000df4:	02f585b3          	mul	a1,a1,a5
    80000df8:	2585                	addiw	a1,a1,1
    80000dfa:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    80000dfe:	4719                	li	a4,6
    80000e00:	6685                	lui	a3,0x1
    80000e02:	40b905b3          	sub	a1,s2,a1
    80000e06:	855a                	mv	a0,s6
    80000e08:	00000097          	auipc	ra,0x0
    80000e0c:	810080e7          	jalr	-2032(ra) # 80000618 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e10:	16848493          	addi	s1,s1,360
    80000e14:	fd3495e3          	bne	s1,s3,80000dde <proc_mapstacks+0x38>
}
    80000e18:	70e2                	ld	ra,56(sp)
    80000e1a:	7442                	ld	s0,48(sp)
    80000e1c:	74a2                	ld	s1,40(sp)
    80000e1e:	7902                	ld	s2,32(sp)
    80000e20:	69e2                	ld	s3,24(sp)
    80000e22:	6a42                	ld	s4,16(sp)
    80000e24:	6aa2                	ld	s5,8(sp)
    80000e26:	6b02                	ld	s6,0(sp)
    80000e28:	6121                	addi	sp,sp,64
    80000e2a:	8082                	ret
      panic("kalloc");
    80000e2c:	00008517          	auipc	a0,0x8
    80000e30:	35450513          	addi	a0,a0,852 # 80009180 <states.1780+0x30>
    80000e34:	00006097          	auipc	ra,0x6
    80000e38:	f54080e7          	jalr	-172(ra) # 80006d88 <panic>

0000000080000e3c <procinit>:
{
    80000e3c:	7139                	addi	sp,sp,-64
    80000e3e:	fc06                	sd	ra,56(sp)
    80000e40:	f822                	sd	s0,48(sp)
    80000e42:	f426                	sd	s1,40(sp)
    80000e44:	f04a                	sd	s2,32(sp)
    80000e46:	ec4e                	sd	s3,24(sp)
    80000e48:	e852                	sd	s4,16(sp)
    80000e4a:	e456                	sd	s5,8(sp)
    80000e4c:	e05a                	sd	s6,0(sp)
    80000e4e:	0080                	addi	s0,sp,64
  initlock(&pid_lock, "nextpid");
    80000e50:	00008597          	auipc	a1,0x8
    80000e54:	33858593          	addi	a1,a1,824 # 80009188 <states.1780+0x38>
    80000e58:	00009517          	auipc	a0,0x9
    80000e5c:	21850513          	addi	a0,a0,536 # 8000a070 <pid_lock>
    80000e60:	00006097          	auipc	ra,0x6
    80000e64:	404080e7          	jalr	1028(ra) # 80007264 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e68:	00009497          	auipc	s1,0x9
    80000e6c:	62048493          	addi	s1,s1,1568 # 8000a488 <proc>
      initlock(&p->lock, "proc");
    80000e70:	00008b17          	auipc	s6,0x8
    80000e74:	320b0b13          	addi	s6,s6,800 # 80009190 <states.1780+0x40>
      p->kstack = KSTACK((int) (p - proc));
    80000e78:	8aa6                	mv	s5,s1
    80000e7a:	00008a17          	auipc	s4,0x8
    80000e7e:	186a0a13          	addi	s4,s4,390 # 80009000 <etext>
    80000e82:	04000937          	lui	s2,0x4000
    80000e86:	197d                	addi	s2,s2,-1
    80000e88:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80000e8a:	0000f997          	auipc	s3,0xf
    80000e8e:	ffe98993          	addi	s3,s3,-2 # 8000fe88 <tickslock>
      initlock(&p->lock, "proc");
    80000e92:	85da                	mv	a1,s6
    80000e94:	8526                	mv	a0,s1
    80000e96:	00006097          	auipc	ra,0x6
    80000e9a:	3ce080e7          	jalr	974(ra) # 80007264 <initlock>
      p->kstack = KSTACK((int) (p - proc));
    80000e9e:	415487b3          	sub	a5,s1,s5
    80000ea2:	878d                	srai	a5,a5,0x3
    80000ea4:	000a3703          	ld	a4,0(s4)
    80000ea8:	02e787b3          	mul	a5,a5,a4
    80000eac:	2785                	addiw	a5,a5,1
    80000eae:	00d7979b          	slliw	a5,a5,0xd
    80000eb2:	40f907b3          	sub	a5,s2,a5
    80000eb6:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80000eb8:	16848493          	addi	s1,s1,360
    80000ebc:	fd349be3          	bne	s1,s3,80000e92 <procinit+0x56>
}
    80000ec0:	70e2                	ld	ra,56(sp)
    80000ec2:	7442                	ld	s0,48(sp)
    80000ec4:	74a2                	ld	s1,40(sp)
    80000ec6:	7902                	ld	s2,32(sp)
    80000ec8:	69e2                	ld	s3,24(sp)
    80000eca:	6a42                	ld	s4,16(sp)
    80000ecc:	6aa2                	ld	s5,8(sp)
    80000ece:	6b02                	ld	s6,0(sp)
    80000ed0:	6121                	addi	sp,sp,64
    80000ed2:	8082                	ret

0000000080000ed4 <cpuid>:
{
    80000ed4:	1141                	addi	sp,sp,-16
    80000ed6:	e422                	sd	s0,8(sp)
    80000ed8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80000eda:	8512                	mv	a0,tp
}
    80000edc:	2501                	sext.w	a0,a0
    80000ede:	6422                	ld	s0,8(sp)
    80000ee0:	0141                	addi	sp,sp,16
    80000ee2:	8082                	ret

0000000080000ee4 <mycpu>:
mycpu(void) {
    80000ee4:	1141                	addi	sp,sp,-16
    80000ee6:	e422                	sd	s0,8(sp)
    80000ee8:	0800                	addi	s0,sp,16
    80000eea:	8792                	mv	a5,tp
  struct cpu *c = &cpus[id];
    80000eec:	2781                	sext.w	a5,a5
    80000eee:	079e                	slli	a5,a5,0x7
}
    80000ef0:	00009517          	auipc	a0,0x9
    80000ef4:	19850513          	addi	a0,a0,408 # 8000a088 <cpus>
    80000ef8:	953e                	add	a0,a0,a5
    80000efa:	6422                	ld	s0,8(sp)
    80000efc:	0141                	addi	sp,sp,16
    80000efe:	8082                	ret

0000000080000f00 <myproc>:
myproc(void) {
    80000f00:	1101                	addi	sp,sp,-32
    80000f02:	ec06                	sd	ra,24(sp)
    80000f04:	e822                	sd	s0,16(sp)
    80000f06:	e426                	sd	s1,8(sp)
    80000f08:	1000                	addi	s0,sp,32
  push_off();
    80000f0a:	00006097          	auipc	ra,0x6
    80000f0e:	39e080e7          	jalr	926(ra) # 800072a8 <push_off>
    80000f12:	8792                	mv	a5,tp
  struct proc *p = c->proc;
    80000f14:	2781                	sext.w	a5,a5
    80000f16:	079e                	slli	a5,a5,0x7
    80000f18:	00009717          	auipc	a4,0x9
    80000f1c:	15870713          	addi	a4,a4,344 # 8000a070 <pid_lock>
    80000f20:	97ba                	add	a5,a5,a4
    80000f22:	6f84                	ld	s1,24(a5)
  pop_off();
    80000f24:	00006097          	auipc	ra,0x6
    80000f28:	424080e7          	jalr	1060(ra) # 80007348 <pop_off>
}
    80000f2c:	8526                	mv	a0,s1
    80000f2e:	60e2                	ld	ra,24(sp)
    80000f30:	6442                	ld	s0,16(sp)
    80000f32:	64a2                	ld	s1,8(sp)
    80000f34:	6105                	addi	sp,sp,32
    80000f36:	8082                	ret

0000000080000f38 <forkret>:
{
    80000f38:	1141                	addi	sp,sp,-16
    80000f3a:	e406                	sd	ra,8(sp)
    80000f3c:	e022                	sd	s0,0(sp)
    80000f3e:	0800                	addi	s0,sp,16
  release(&myproc()->lock);
    80000f40:	00000097          	auipc	ra,0x0
    80000f44:	fc0080e7          	jalr	-64(ra) # 80000f00 <myproc>
    80000f48:	00006097          	auipc	ra,0x6
    80000f4c:	460080e7          	jalr	1120(ra) # 800073a8 <release>
  if (first) {
    80000f50:	00009797          	auipc	a5,0x9
    80000f54:	92078793          	addi	a5,a5,-1760 # 80009870 <first.1740>
    80000f58:	439c                	lw	a5,0(a5)
    80000f5a:	eb89                	bnez	a5,80000f6c <forkret+0x34>
  usertrapret();
    80000f5c:	00001097          	auipc	ra,0x1
    80000f60:	c26080e7          	jalr	-986(ra) # 80001b82 <usertrapret>
}
    80000f64:	60a2                	ld	ra,8(sp)
    80000f66:	6402                	ld	s0,0(sp)
    80000f68:	0141                	addi	sp,sp,16
    80000f6a:	8082                	ret
    first = 0;
    80000f6c:	00009797          	auipc	a5,0x9
    80000f70:	9007a223          	sw	zero,-1788(a5) # 80009870 <first.1740>
    fsinit(ROOTDEV);
    80000f74:	4505                	li	a0,1
    80000f76:	00002097          	auipc	ra,0x2
    80000f7a:	9d0080e7          	jalr	-1584(ra) # 80002946 <fsinit>
    80000f7e:	bff9                	j	80000f5c <forkret+0x24>

0000000080000f80 <allocpid>:
allocpid() {
    80000f80:	1101                	addi	sp,sp,-32
    80000f82:	ec06                	sd	ra,24(sp)
    80000f84:	e822                	sd	s0,16(sp)
    80000f86:	e426                	sd	s1,8(sp)
    80000f88:	e04a                	sd	s2,0(sp)
    80000f8a:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80000f8c:	00009917          	auipc	s2,0x9
    80000f90:	0e490913          	addi	s2,s2,228 # 8000a070 <pid_lock>
    80000f94:	854a                	mv	a0,s2
    80000f96:	00006097          	auipc	ra,0x6
    80000f9a:	35e080e7          	jalr	862(ra) # 800072f4 <acquire>
  pid = nextpid;
    80000f9e:	00009797          	auipc	a5,0x9
    80000fa2:	8d678793          	addi	a5,a5,-1834 # 80009874 <nextpid>
    80000fa6:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80000fa8:	0014871b          	addiw	a4,s1,1
    80000fac:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80000fae:	854a                	mv	a0,s2
    80000fb0:	00006097          	auipc	ra,0x6
    80000fb4:	3f8080e7          	jalr	1016(ra) # 800073a8 <release>
}
    80000fb8:	8526                	mv	a0,s1
    80000fba:	60e2                	ld	ra,24(sp)
    80000fbc:	6442                	ld	s0,16(sp)
    80000fbe:	64a2                	ld	s1,8(sp)
    80000fc0:	6902                	ld	s2,0(sp)
    80000fc2:	6105                	addi	sp,sp,32
    80000fc4:	8082                	ret

0000000080000fc6 <proc_pagetable>:
{
    80000fc6:	1101                	addi	sp,sp,-32
    80000fc8:	ec06                	sd	ra,24(sp)
    80000fca:	e822                	sd	s0,16(sp)
    80000fcc:	e426                	sd	s1,8(sp)
    80000fce:	e04a                	sd	s2,0(sp)
    80000fd0:	1000                	addi	s0,sp,32
    80000fd2:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80000fd4:	00000097          	auipc	ra,0x0
    80000fd8:	874080e7          	jalr	-1932(ra) # 80000848 <uvmcreate>
    80000fdc:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80000fde:	c121                	beqz	a0,8000101e <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80000fe0:	4729                	li	a4,10
    80000fe2:	00007697          	auipc	a3,0x7
    80000fe6:	01e68693          	addi	a3,a3,30 # 80008000 <_trampoline>
    80000fea:	6605                	lui	a2,0x1
    80000fec:	040005b7          	lui	a1,0x4000
    80000ff0:	15fd                	addi	a1,a1,-1
    80000ff2:	05b2                	slli	a1,a1,0xc
    80000ff4:	fffff097          	auipc	ra,0xfffff
    80000ff8:	598080e7          	jalr	1432(ra) # 8000058c <mappages>
    80000ffc:	02054863          	bltz	a0,8000102c <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001000:	4719                	li	a4,6
    80001002:	05893683          	ld	a3,88(s2)
    80001006:	6605                	lui	a2,0x1
    80001008:	020005b7          	lui	a1,0x2000
    8000100c:	15fd                	addi	a1,a1,-1
    8000100e:	05b6                	slli	a1,a1,0xd
    80001010:	8526                	mv	a0,s1
    80001012:	fffff097          	auipc	ra,0xfffff
    80001016:	57a080e7          	jalr	1402(ra) # 8000058c <mappages>
    8000101a:	02054163          	bltz	a0,8000103c <proc_pagetable+0x76>
}
    8000101e:	8526                	mv	a0,s1
    80001020:	60e2                	ld	ra,24(sp)
    80001022:	6442                	ld	s0,16(sp)
    80001024:	64a2                	ld	s1,8(sp)
    80001026:	6902                	ld	s2,0(sp)
    80001028:	6105                	addi	sp,sp,32
    8000102a:	8082                	ret
    uvmfree(pagetable, 0);
    8000102c:	4581                	li	a1,0
    8000102e:	8526                	mv	a0,s1
    80001030:	00000097          	auipc	ra,0x0
    80001034:	a12080e7          	jalr	-1518(ra) # 80000a42 <uvmfree>
    return 0;
    80001038:	4481                	li	s1,0
    8000103a:	b7d5                	j	8000101e <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    8000103c:	4681                	li	a3,0
    8000103e:	4605                	li	a2,1
    80001040:	040005b7          	lui	a1,0x4000
    80001044:	15fd                	addi	a1,a1,-1
    80001046:	05b2                	slli	a1,a1,0xc
    80001048:	8526                	mv	a0,s1
    8000104a:	fffff097          	auipc	ra,0xfffff
    8000104e:	724080e7          	jalr	1828(ra) # 8000076e <uvmunmap>
    uvmfree(pagetable, 0);
    80001052:	4581                	li	a1,0
    80001054:	8526                	mv	a0,s1
    80001056:	00000097          	auipc	ra,0x0
    8000105a:	9ec080e7          	jalr	-1556(ra) # 80000a42 <uvmfree>
    return 0;
    8000105e:	4481                	li	s1,0
    80001060:	bf7d                	j	8000101e <proc_pagetable+0x58>

0000000080001062 <proc_freepagetable>:
{
    80001062:	1101                	addi	sp,sp,-32
    80001064:	ec06                	sd	ra,24(sp)
    80001066:	e822                	sd	s0,16(sp)
    80001068:	e426                	sd	s1,8(sp)
    8000106a:	e04a                	sd	s2,0(sp)
    8000106c:	1000                	addi	s0,sp,32
    8000106e:	84aa                	mv	s1,a0
    80001070:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001072:	4681                	li	a3,0
    80001074:	4605                	li	a2,1
    80001076:	040005b7          	lui	a1,0x4000
    8000107a:	15fd                	addi	a1,a1,-1
    8000107c:	05b2                	slli	a1,a1,0xc
    8000107e:	fffff097          	auipc	ra,0xfffff
    80001082:	6f0080e7          	jalr	1776(ra) # 8000076e <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001086:	4681                	li	a3,0
    80001088:	4605                	li	a2,1
    8000108a:	020005b7          	lui	a1,0x2000
    8000108e:	15fd                	addi	a1,a1,-1
    80001090:	05b6                	slli	a1,a1,0xd
    80001092:	8526                	mv	a0,s1
    80001094:	fffff097          	auipc	ra,0xfffff
    80001098:	6da080e7          	jalr	1754(ra) # 8000076e <uvmunmap>
  uvmfree(pagetable, sz);
    8000109c:	85ca                	mv	a1,s2
    8000109e:	8526                	mv	a0,s1
    800010a0:	00000097          	auipc	ra,0x0
    800010a4:	9a2080e7          	jalr	-1630(ra) # 80000a42 <uvmfree>
}
    800010a8:	60e2                	ld	ra,24(sp)
    800010aa:	6442                	ld	s0,16(sp)
    800010ac:	64a2                	ld	s1,8(sp)
    800010ae:	6902                	ld	s2,0(sp)
    800010b0:	6105                	addi	sp,sp,32
    800010b2:	8082                	ret

00000000800010b4 <freeproc>:
{
    800010b4:	1101                	addi	sp,sp,-32
    800010b6:	ec06                	sd	ra,24(sp)
    800010b8:	e822                	sd	s0,16(sp)
    800010ba:	e426                	sd	s1,8(sp)
    800010bc:	1000                	addi	s0,sp,32
    800010be:	84aa                	mv	s1,a0
  if(p->trapframe)
    800010c0:	6d28                	ld	a0,88(a0)
    800010c2:	c509                	beqz	a0,800010cc <freeproc+0x18>
    kfree((void*)p->trapframe);
    800010c4:	fffff097          	auipc	ra,0xfffff
    800010c8:	f58080e7          	jalr	-168(ra) # 8000001c <kfree>
  p->trapframe = 0;
    800010cc:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    800010d0:	68a8                	ld	a0,80(s1)
    800010d2:	c511                	beqz	a0,800010de <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    800010d4:	64ac                	ld	a1,72(s1)
    800010d6:	00000097          	auipc	ra,0x0
    800010da:	f8c080e7          	jalr	-116(ra) # 80001062 <proc_freepagetable>
  p->pagetable = 0;
    800010de:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    800010e2:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    800010e6:	0204ac23          	sw	zero,56(s1)
  p->parent = 0;
    800010ea:	0204b023          	sd	zero,32(s1)
  p->name[0] = 0;
    800010ee:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    800010f2:	0204b423          	sd	zero,40(s1)
  p->killed = 0;
    800010f6:	0204a823          	sw	zero,48(s1)
  p->xstate = 0;
    800010fa:	0204aa23          	sw	zero,52(s1)
  p->state = UNUSED;
    800010fe:	0004ac23          	sw	zero,24(s1)
}
    80001102:	60e2                	ld	ra,24(sp)
    80001104:	6442                	ld	s0,16(sp)
    80001106:	64a2                	ld	s1,8(sp)
    80001108:	6105                	addi	sp,sp,32
    8000110a:	8082                	ret

000000008000110c <allocproc>:
{
    8000110c:	1101                	addi	sp,sp,-32
    8000110e:	ec06                	sd	ra,24(sp)
    80001110:	e822                	sd	s0,16(sp)
    80001112:	e426                	sd	s1,8(sp)
    80001114:	e04a                	sd	s2,0(sp)
    80001116:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001118:	00009497          	auipc	s1,0x9
    8000111c:	37048493          	addi	s1,s1,880 # 8000a488 <proc>
    80001120:	0000f917          	auipc	s2,0xf
    80001124:	d6890913          	addi	s2,s2,-664 # 8000fe88 <tickslock>
    acquire(&p->lock);
    80001128:	8526                	mv	a0,s1
    8000112a:	00006097          	auipc	ra,0x6
    8000112e:	1ca080e7          	jalr	458(ra) # 800072f4 <acquire>
    if(p->state == UNUSED) {
    80001132:	4c9c                	lw	a5,24(s1)
    80001134:	cf81                	beqz	a5,8000114c <allocproc+0x40>
      release(&p->lock);
    80001136:	8526                	mv	a0,s1
    80001138:	00006097          	auipc	ra,0x6
    8000113c:	270080e7          	jalr	624(ra) # 800073a8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001140:	16848493          	addi	s1,s1,360
    80001144:	ff2492e3          	bne	s1,s2,80001128 <allocproc+0x1c>
  return 0;
    80001148:	4481                	li	s1,0
    8000114a:	a0b9                	j	80001198 <allocproc+0x8c>
  p->pid = allocpid();
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	e34080e7          	jalr	-460(ra) # 80000f80 <allocpid>
    80001154:	dc88                	sw	a0,56(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001156:	fffff097          	auipc	ra,0xfffff
    8000115a:	fc6080e7          	jalr	-58(ra) # 8000011c <kalloc>
    8000115e:	892a                	mv	s2,a0
    80001160:	eca8                	sd	a0,88(s1)
    80001162:	c131                	beqz	a0,800011a6 <allocproc+0x9a>
  p->pagetable = proc_pagetable(p);
    80001164:	8526                	mv	a0,s1
    80001166:	00000097          	auipc	ra,0x0
    8000116a:	e60080e7          	jalr	-416(ra) # 80000fc6 <proc_pagetable>
    8000116e:	892a                	mv	s2,a0
    80001170:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001172:	c129                	beqz	a0,800011b4 <allocproc+0xa8>
  memset(&p->context, 0, sizeof(p->context));
    80001174:	07000613          	li	a2,112
    80001178:	4581                	li	a1,0
    8000117a:	06048513          	addi	a0,s1,96
    8000117e:	fffff097          	auipc	ra,0xfffff
    80001182:	ffe080e7          	jalr	-2(ra) # 8000017c <memset>
  p->context.ra = (uint64)forkret;
    80001186:	00000797          	auipc	a5,0x0
    8000118a:	db278793          	addi	a5,a5,-590 # 80000f38 <forkret>
    8000118e:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001190:	60bc                	ld	a5,64(s1)
    80001192:	6705                	lui	a4,0x1
    80001194:	97ba                	add	a5,a5,a4
    80001196:	f4bc                	sd	a5,104(s1)
}
    80001198:	8526                	mv	a0,s1
    8000119a:	60e2                	ld	ra,24(sp)
    8000119c:	6442                	ld	s0,16(sp)
    8000119e:	64a2                	ld	s1,8(sp)
    800011a0:	6902                	ld	s2,0(sp)
    800011a2:	6105                	addi	sp,sp,32
    800011a4:	8082                	ret
    release(&p->lock);
    800011a6:	8526                	mv	a0,s1
    800011a8:	00006097          	auipc	ra,0x6
    800011ac:	200080e7          	jalr	512(ra) # 800073a8 <release>
    return 0;
    800011b0:	84ca                	mv	s1,s2
    800011b2:	b7dd                	j	80001198 <allocproc+0x8c>
    freeproc(p);
    800011b4:	8526                	mv	a0,s1
    800011b6:	00000097          	auipc	ra,0x0
    800011ba:	efe080e7          	jalr	-258(ra) # 800010b4 <freeproc>
    release(&p->lock);
    800011be:	8526                	mv	a0,s1
    800011c0:	00006097          	auipc	ra,0x6
    800011c4:	1e8080e7          	jalr	488(ra) # 800073a8 <release>
    return 0;
    800011c8:	84ca                	mv	s1,s2
    800011ca:	b7f9                	j	80001198 <allocproc+0x8c>

00000000800011cc <userinit>:
{
    800011cc:	1101                	addi	sp,sp,-32
    800011ce:	ec06                	sd	ra,24(sp)
    800011d0:	e822                	sd	s0,16(sp)
    800011d2:	e426                	sd	s1,8(sp)
    800011d4:	1000                	addi	s0,sp,32
  p = allocproc();
    800011d6:	00000097          	auipc	ra,0x0
    800011da:	f36080e7          	jalr	-202(ra) # 8000110c <allocproc>
    800011de:	84aa                	mv	s1,a0
  initproc = p;
    800011e0:	00009797          	auipc	a5,0x9
    800011e4:	e2a7b823          	sd	a0,-464(a5) # 8000a010 <initproc>
  uvminit(p->pagetable, initcode, sizeof(initcode));
    800011e8:	03400613          	li	a2,52
    800011ec:	00008597          	auipc	a1,0x8
    800011f0:	6a458593          	addi	a1,a1,1700 # 80009890 <initcode>
    800011f4:	6928                	ld	a0,80(a0)
    800011f6:	fffff097          	auipc	ra,0xfffff
    800011fa:	680080e7          	jalr	1664(ra) # 80000876 <uvminit>
  p->sz = PGSIZE;
    800011fe:	6785                	lui	a5,0x1
    80001200:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001202:	6cb8                	ld	a4,88(s1)
    80001204:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001208:	6cb8                	ld	a4,88(s1)
    8000120a:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    8000120c:	4641                	li	a2,16
    8000120e:	00008597          	auipc	a1,0x8
    80001212:	f8a58593          	addi	a1,a1,-118 # 80009198 <states.1780+0x48>
    80001216:	15848513          	addi	a0,s1,344
    8000121a:	fffff097          	auipc	ra,0xfffff
    8000121e:	0da080e7          	jalr	218(ra) # 800002f4 <safestrcpy>
  p->cwd = namei("/");
    80001222:	00008517          	auipc	a0,0x8
    80001226:	f8650513          	addi	a0,a0,-122 # 800091a8 <states.1780+0x58>
    8000122a:	00002097          	auipc	ra,0x2
    8000122e:	156080e7          	jalr	342(ra) # 80003380 <namei>
    80001232:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001236:	4789                	li	a5,2
    80001238:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    8000123a:	8526                	mv	a0,s1
    8000123c:	00006097          	auipc	ra,0x6
    80001240:	16c080e7          	jalr	364(ra) # 800073a8 <release>
}
    80001244:	60e2                	ld	ra,24(sp)
    80001246:	6442                	ld	s0,16(sp)
    80001248:	64a2                	ld	s1,8(sp)
    8000124a:	6105                	addi	sp,sp,32
    8000124c:	8082                	ret

000000008000124e <growproc>:
{
    8000124e:	1101                	addi	sp,sp,-32
    80001250:	ec06                	sd	ra,24(sp)
    80001252:	e822                	sd	s0,16(sp)
    80001254:	e426                	sd	s1,8(sp)
    80001256:	e04a                	sd	s2,0(sp)
    80001258:	1000                	addi	s0,sp,32
    8000125a:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    8000125c:	00000097          	auipc	ra,0x0
    80001260:	ca4080e7          	jalr	-860(ra) # 80000f00 <myproc>
    80001264:	892a                	mv	s2,a0
  sz = p->sz;
    80001266:	652c                	ld	a1,72(a0)
    80001268:	0005851b          	sext.w	a0,a1
  if(n > 0){
    8000126c:	00904f63          	bgtz	s1,8000128a <growproc+0x3c>
  } else if(n < 0){
    80001270:	0204cd63          	bltz	s1,800012aa <growproc+0x5c>
  p->sz = sz;
    80001274:	1502                	slli	a0,a0,0x20
    80001276:	9101                	srli	a0,a0,0x20
    80001278:	04a93423          	sd	a0,72(s2)
  return 0;
    8000127c:	4501                	li	a0,0
}
    8000127e:	60e2                	ld	ra,24(sp)
    80001280:	6442                	ld	s0,16(sp)
    80001282:	64a2                	ld	s1,8(sp)
    80001284:	6902                	ld	s2,0(sp)
    80001286:	6105                	addi	sp,sp,32
    80001288:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n)) == 0) {
    8000128a:	00a4863b          	addw	a2,s1,a0
    8000128e:	1602                	slli	a2,a2,0x20
    80001290:	9201                	srli	a2,a2,0x20
    80001292:	1582                	slli	a1,a1,0x20
    80001294:	9181                	srli	a1,a1,0x20
    80001296:	05093503          	ld	a0,80(s2)
    8000129a:	fffff097          	auipc	ra,0xfffff
    8000129e:	694080e7          	jalr	1684(ra) # 8000092e <uvmalloc>
    800012a2:	2501                	sext.w	a0,a0
    800012a4:	f961                	bnez	a0,80001274 <growproc+0x26>
      return -1;
    800012a6:	557d                	li	a0,-1
    800012a8:	bfd9                	j	8000127e <growproc+0x30>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    800012aa:	00a4863b          	addw	a2,s1,a0
    800012ae:	1602                	slli	a2,a2,0x20
    800012b0:	9201                	srli	a2,a2,0x20
    800012b2:	1582                	slli	a1,a1,0x20
    800012b4:	9181                	srli	a1,a1,0x20
    800012b6:	05093503          	ld	a0,80(s2)
    800012ba:	fffff097          	auipc	ra,0xfffff
    800012be:	62e080e7          	jalr	1582(ra) # 800008e8 <uvmdealloc>
    800012c2:	2501                	sext.w	a0,a0
    800012c4:	bf45                	j	80001274 <growproc+0x26>

00000000800012c6 <fork>:
{
    800012c6:	7179                	addi	sp,sp,-48
    800012c8:	f406                	sd	ra,40(sp)
    800012ca:	f022                	sd	s0,32(sp)
    800012cc:	ec26                	sd	s1,24(sp)
    800012ce:	e84a                	sd	s2,16(sp)
    800012d0:	e44e                	sd	s3,8(sp)
    800012d2:	e052                	sd	s4,0(sp)
    800012d4:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    800012d6:	00000097          	auipc	ra,0x0
    800012da:	c2a080e7          	jalr	-982(ra) # 80000f00 <myproc>
    800012de:	892a                	mv	s2,a0
  if((np = allocproc()) == 0){
    800012e0:	00000097          	auipc	ra,0x0
    800012e4:	e2c080e7          	jalr	-468(ra) # 8000110c <allocproc>
    800012e8:	c175                	beqz	a0,800013cc <fork+0x106>
    800012ea:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    800012ec:	04893603          	ld	a2,72(s2)
    800012f0:	692c                	ld	a1,80(a0)
    800012f2:	05093503          	ld	a0,80(s2)
    800012f6:	fffff097          	auipc	ra,0xfffff
    800012fa:	784080e7          	jalr	1924(ra) # 80000a7a <uvmcopy>
    800012fe:	04054863          	bltz	a0,8000134e <fork+0x88>
  np->sz = p->sz;
    80001302:	04893783          	ld	a5,72(s2)
    80001306:	04f9b423          	sd	a5,72(s3)
  np->parent = p;
    8000130a:	0329b023          	sd	s2,32(s3)
  *(np->trapframe) = *(p->trapframe);
    8000130e:	05893683          	ld	a3,88(s2)
    80001312:	87b6                	mv	a5,a3
    80001314:	0589b703          	ld	a4,88(s3)
    80001318:	12068693          	addi	a3,a3,288
    8000131c:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001320:	6788                	ld	a0,8(a5)
    80001322:	6b8c                	ld	a1,16(a5)
    80001324:	6f90                	ld	a2,24(a5)
    80001326:	01073023          	sd	a6,0(a4)
    8000132a:	e708                	sd	a0,8(a4)
    8000132c:	eb0c                	sd	a1,16(a4)
    8000132e:	ef10                	sd	a2,24(a4)
    80001330:	02078793          	addi	a5,a5,32
    80001334:	02070713          	addi	a4,a4,32
    80001338:	fed792e3          	bne	a5,a3,8000131c <fork+0x56>
  np->trapframe->a0 = 0;
    8000133c:	0589b783          	ld	a5,88(s3)
    80001340:	0607b823          	sd	zero,112(a5)
    80001344:	0d000493          	li	s1,208
  for(i = 0; i < NOFILE; i++)
    80001348:	15000a13          	li	s4,336
    8000134c:	a03d                	j	8000137a <fork+0xb4>
    freeproc(np);
    8000134e:	854e                	mv	a0,s3
    80001350:	00000097          	auipc	ra,0x0
    80001354:	d64080e7          	jalr	-668(ra) # 800010b4 <freeproc>
    release(&np->lock);
    80001358:	854e                	mv	a0,s3
    8000135a:	00006097          	auipc	ra,0x6
    8000135e:	04e080e7          	jalr	78(ra) # 800073a8 <release>
    return -1;
    80001362:	54fd                	li	s1,-1
    80001364:	a899                	j	800013ba <fork+0xf4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001366:	00002097          	auipc	ra,0x2
    8000136a:	6ea080e7          	jalr	1770(ra) # 80003a50 <filedup>
    8000136e:	009987b3          	add	a5,s3,s1
    80001372:	e388                	sd	a0,0(a5)
  for(i = 0; i < NOFILE; i++)
    80001374:	04a1                	addi	s1,s1,8
    80001376:	01448763          	beq	s1,s4,80001384 <fork+0xbe>
    if(p->ofile[i])
    8000137a:	009907b3          	add	a5,s2,s1
    8000137e:	6388                	ld	a0,0(a5)
    80001380:	f17d                	bnez	a0,80001366 <fork+0xa0>
    80001382:	bfcd                	j	80001374 <fork+0xae>
  np->cwd = idup(p->cwd);
    80001384:	15093503          	ld	a0,336(s2)
    80001388:	00001097          	auipc	ra,0x1
    8000138c:	7fa080e7          	jalr	2042(ra) # 80002b82 <idup>
    80001390:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001394:	4641                	li	a2,16
    80001396:	15890593          	addi	a1,s2,344
    8000139a:	15898513          	addi	a0,s3,344
    8000139e:	fffff097          	auipc	ra,0xfffff
    800013a2:	f56080e7          	jalr	-170(ra) # 800002f4 <safestrcpy>
  pid = np->pid;
    800013a6:	0389a483          	lw	s1,56(s3)
  np->state = RUNNABLE;
    800013aa:	4789                	li	a5,2
    800013ac:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    800013b0:	854e                	mv	a0,s3
    800013b2:	00006097          	auipc	ra,0x6
    800013b6:	ff6080e7          	jalr	-10(ra) # 800073a8 <release>
}
    800013ba:	8526                	mv	a0,s1
    800013bc:	70a2                	ld	ra,40(sp)
    800013be:	7402                	ld	s0,32(sp)
    800013c0:	64e2                	ld	s1,24(sp)
    800013c2:	6942                	ld	s2,16(sp)
    800013c4:	69a2                	ld	s3,8(sp)
    800013c6:	6a02                	ld	s4,0(sp)
    800013c8:	6145                	addi	sp,sp,48
    800013ca:	8082                	ret
    return -1;
    800013cc:	54fd                	li	s1,-1
    800013ce:	b7f5                	j	800013ba <fork+0xf4>

00000000800013d0 <reparent>:
{
    800013d0:	7179                	addi	sp,sp,-48
    800013d2:	f406                	sd	ra,40(sp)
    800013d4:	f022                	sd	s0,32(sp)
    800013d6:	ec26                	sd	s1,24(sp)
    800013d8:	e84a                	sd	s2,16(sp)
    800013da:	e44e                	sd	s3,8(sp)
    800013dc:	e052                	sd	s4,0(sp)
    800013de:	1800                	addi	s0,sp,48
    800013e0:	89aa                	mv	s3,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800013e2:	00009497          	auipc	s1,0x9
    800013e6:	0a648493          	addi	s1,s1,166 # 8000a488 <proc>
      pp->parent = initproc;
    800013ea:	00009a17          	auipc	s4,0x9
    800013ee:	c26a0a13          	addi	s4,s4,-986 # 8000a010 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800013f2:	0000f917          	auipc	s2,0xf
    800013f6:	a9690913          	addi	s2,s2,-1386 # 8000fe88 <tickslock>
    800013fa:	a029                	j	80001404 <reparent+0x34>
    800013fc:	16848493          	addi	s1,s1,360
    80001400:	03248363          	beq	s1,s2,80001426 <reparent+0x56>
    if(pp->parent == p){
    80001404:	709c                	ld	a5,32(s1)
    80001406:	ff379be3          	bne	a5,s3,800013fc <reparent+0x2c>
      acquire(&pp->lock);
    8000140a:	8526                	mv	a0,s1
    8000140c:	00006097          	auipc	ra,0x6
    80001410:	ee8080e7          	jalr	-280(ra) # 800072f4 <acquire>
      pp->parent = initproc;
    80001414:	000a3783          	ld	a5,0(s4)
    80001418:	f09c                	sd	a5,32(s1)
      release(&pp->lock);
    8000141a:	8526                	mv	a0,s1
    8000141c:	00006097          	auipc	ra,0x6
    80001420:	f8c080e7          	jalr	-116(ra) # 800073a8 <release>
    80001424:	bfe1                	j	800013fc <reparent+0x2c>
}
    80001426:	70a2                	ld	ra,40(sp)
    80001428:	7402                	ld	s0,32(sp)
    8000142a:	64e2                	ld	s1,24(sp)
    8000142c:	6942                	ld	s2,16(sp)
    8000142e:	69a2                	ld	s3,8(sp)
    80001430:	6a02                	ld	s4,0(sp)
    80001432:	6145                	addi	sp,sp,48
    80001434:	8082                	ret

0000000080001436 <scheduler>:
{
    80001436:	711d                	addi	sp,sp,-96
    80001438:	ec86                	sd	ra,88(sp)
    8000143a:	e8a2                	sd	s0,80(sp)
    8000143c:	e4a6                	sd	s1,72(sp)
    8000143e:	e0ca                	sd	s2,64(sp)
    80001440:	fc4e                	sd	s3,56(sp)
    80001442:	f852                	sd	s4,48(sp)
    80001444:	f456                	sd	s5,40(sp)
    80001446:	f05a                	sd	s6,32(sp)
    80001448:	ec5e                	sd	s7,24(sp)
    8000144a:	e862                	sd	s8,16(sp)
    8000144c:	e466                	sd	s9,8(sp)
    8000144e:	1080                	addi	s0,sp,96
    80001450:	8792                	mv	a5,tp
  int id = r_tp();
    80001452:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001454:	00779c13          	slli	s8,a5,0x7
    80001458:	00009717          	auipc	a4,0x9
    8000145c:	c1870713          	addi	a4,a4,-1000 # 8000a070 <pid_lock>
    80001460:	9762                	add	a4,a4,s8
    80001462:	00073c23          	sd	zero,24(a4)
        swtch(&c->context, &p->context);
    80001466:	00009717          	auipc	a4,0x9
    8000146a:	c2a70713          	addi	a4,a4,-982 # 8000a090 <cpus+0x8>
    8000146e:	9c3a                	add	s8,s8,a4
      if(p->state == RUNNABLE) {
    80001470:	4a89                	li	s5,2
        c->proc = p;
    80001472:	079e                	slli	a5,a5,0x7
    80001474:	00009b17          	auipc	s6,0x9
    80001478:	bfcb0b13          	addi	s6,s6,-1028 # 8000a070 <pid_lock>
    8000147c:	9b3e                	add	s6,s6,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    8000147e:	0000fa17          	auipc	s4,0xf
    80001482:	a0aa0a13          	addi	s4,s4,-1526 # 8000fe88 <tickslock>
    int nproc = 0;
    80001486:	4c81                	li	s9,0
    80001488:	a8a1                	j	800014e0 <scheduler+0xaa>
        p->state = RUNNING;
    8000148a:	0174ac23          	sw	s7,24(s1)
        c->proc = p;
    8000148e:	009b3c23          	sd	s1,24(s6)
        swtch(&c->context, &p->context);
    80001492:	06048593          	addi	a1,s1,96
    80001496:	8562                	mv	a0,s8
    80001498:	00000097          	auipc	ra,0x0
    8000149c:	640080e7          	jalr	1600(ra) # 80001ad8 <swtch>
        c->proc = 0;
    800014a0:	000b3c23          	sd	zero,24(s6)
      release(&p->lock);
    800014a4:	8526                	mv	a0,s1
    800014a6:	00006097          	auipc	ra,0x6
    800014aa:	f02080e7          	jalr	-254(ra) # 800073a8 <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    800014ae:	16848493          	addi	s1,s1,360
    800014b2:	01448d63          	beq	s1,s4,800014cc <scheduler+0x96>
      acquire(&p->lock);
    800014b6:	8526                	mv	a0,s1
    800014b8:	00006097          	auipc	ra,0x6
    800014bc:	e3c080e7          	jalr	-452(ra) # 800072f4 <acquire>
      if(p->state != UNUSED) {
    800014c0:	4c9c                	lw	a5,24(s1)
    800014c2:	d3ed                	beqz	a5,800014a4 <scheduler+0x6e>
        nproc++;
    800014c4:	2985                	addiw	s3,s3,1
      if(p->state == RUNNABLE) {
    800014c6:	fd579fe3          	bne	a5,s5,800014a4 <scheduler+0x6e>
    800014ca:	b7c1                	j	8000148a <scheduler+0x54>
    if(nproc <= 2) {   // only init and sh exist
    800014cc:	013aca63          	blt	s5,s3,800014e0 <scheduler+0xaa>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800014d0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800014d4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800014d8:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    800014dc:	10500073          	wfi
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800014e0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800014e4:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800014e8:	10079073          	csrw	sstatus,a5
    int nproc = 0;
    800014ec:	89e6                	mv	s3,s9
    for(p = proc; p < &proc[NPROC]; p++) {
    800014ee:	00009497          	auipc	s1,0x9
    800014f2:	f9a48493          	addi	s1,s1,-102 # 8000a488 <proc>
        p->state = RUNNING;
    800014f6:	4b8d                	li	s7,3
    800014f8:	bf7d                	j	800014b6 <scheduler+0x80>

00000000800014fa <sched>:
{
    800014fa:	7179                	addi	sp,sp,-48
    800014fc:	f406                	sd	ra,40(sp)
    800014fe:	f022                	sd	s0,32(sp)
    80001500:	ec26                	sd	s1,24(sp)
    80001502:	e84a                	sd	s2,16(sp)
    80001504:	e44e                	sd	s3,8(sp)
    80001506:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001508:	00000097          	auipc	ra,0x0
    8000150c:	9f8080e7          	jalr	-1544(ra) # 80000f00 <myproc>
    80001510:	892a                	mv	s2,a0
  if(!holding(&p->lock))
    80001512:	00006097          	auipc	ra,0x6
    80001516:	d68080e7          	jalr	-664(ra) # 8000727a <holding>
    8000151a:	cd25                	beqz	a0,80001592 <sched+0x98>
  asm volatile("mv %0, tp" : "=r" (x) );
    8000151c:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    8000151e:	2781                	sext.w	a5,a5
    80001520:	079e                	slli	a5,a5,0x7
    80001522:	00009717          	auipc	a4,0x9
    80001526:	b4e70713          	addi	a4,a4,-1202 # 8000a070 <pid_lock>
    8000152a:	97ba                	add	a5,a5,a4
    8000152c:	0907a703          	lw	a4,144(a5)
    80001530:	4785                	li	a5,1
    80001532:	06f71863          	bne	a4,a5,800015a2 <sched+0xa8>
  if(p->state == RUNNING)
    80001536:	01892703          	lw	a4,24(s2)
    8000153a:	478d                	li	a5,3
    8000153c:	06f70b63          	beq	a4,a5,800015b2 <sched+0xb8>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001540:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001544:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001546:	efb5                	bnez	a5,800015c2 <sched+0xc8>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001548:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    8000154a:	00009497          	auipc	s1,0x9
    8000154e:	b2648493          	addi	s1,s1,-1242 # 8000a070 <pid_lock>
    80001552:	2781                	sext.w	a5,a5
    80001554:	079e                	slli	a5,a5,0x7
    80001556:	97a6                	add	a5,a5,s1
    80001558:	0947a983          	lw	s3,148(a5)
    8000155c:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    8000155e:	2781                	sext.w	a5,a5
    80001560:	079e                	slli	a5,a5,0x7
    80001562:	00009597          	auipc	a1,0x9
    80001566:	b2e58593          	addi	a1,a1,-1234 # 8000a090 <cpus+0x8>
    8000156a:	95be                	add	a1,a1,a5
    8000156c:	06090513          	addi	a0,s2,96
    80001570:	00000097          	auipc	ra,0x0
    80001574:	568080e7          	jalr	1384(ra) # 80001ad8 <swtch>
    80001578:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000157a:	2781                	sext.w	a5,a5
    8000157c:	079e                	slli	a5,a5,0x7
    8000157e:	97a6                	add	a5,a5,s1
    80001580:	0937aa23          	sw	s3,148(a5)
}
    80001584:	70a2                	ld	ra,40(sp)
    80001586:	7402                	ld	s0,32(sp)
    80001588:	64e2                	ld	s1,24(sp)
    8000158a:	6942                	ld	s2,16(sp)
    8000158c:	69a2                	ld	s3,8(sp)
    8000158e:	6145                	addi	sp,sp,48
    80001590:	8082                	ret
    panic("sched p->lock");
    80001592:	00008517          	auipc	a0,0x8
    80001596:	c1e50513          	addi	a0,a0,-994 # 800091b0 <states.1780+0x60>
    8000159a:	00005097          	auipc	ra,0x5
    8000159e:	7ee080e7          	jalr	2030(ra) # 80006d88 <panic>
    panic("sched locks");
    800015a2:	00008517          	auipc	a0,0x8
    800015a6:	c1e50513          	addi	a0,a0,-994 # 800091c0 <states.1780+0x70>
    800015aa:	00005097          	auipc	ra,0x5
    800015ae:	7de080e7          	jalr	2014(ra) # 80006d88 <panic>
    panic("sched running");
    800015b2:	00008517          	auipc	a0,0x8
    800015b6:	c1e50513          	addi	a0,a0,-994 # 800091d0 <states.1780+0x80>
    800015ba:	00005097          	auipc	ra,0x5
    800015be:	7ce080e7          	jalr	1998(ra) # 80006d88 <panic>
    panic("sched interruptible");
    800015c2:	00008517          	auipc	a0,0x8
    800015c6:	c1e50513          	addi	a0,a0,-994 # 800091e0 <states.1780+0x90>
    800015ca:	00005097          	auipc	ra,0x5
    800015ce:	7be080e7          	jalr	1982(ra) # 80006d88 <panic>

00000000800015d2 <exit>:
{
    800015d2:	7179                	addi	sp,sp,-48
    800015d4:	f406                	sd	ra,40(sp)
    800015d6:	f022                	sd	s0,32(sp)
    800015d8:	ec26                	sd	s1,24(sp)
    800015da:	e84a                	sd	s2,16(sp)
    800015dc:	e44e                	sd	s3,8(sp)
    800015de:	e052                	sd	s4,0(sp)
    800015e0:	1800                	addi	s0,sp,48
    800015e2:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800015e4:	00000097          	auipc	ra,0x0
    800015e8:	91c080e7          	jalr	-1764(ra) # 80000f00 <myproc>
    800015ec:	89aa                	mv	s3,a0
  if(p == initproc)
    800015ee:	00009797          	auipc	a5,0x9
    800015f2:	a2278793          	addi	a5,a5,-1502 # 8000a010 <initproc>
    800015f6:	639c                	ld	a5,0(a5)
    800015f8:	0d050493          	addi	s1,a0,208
    800015fc:	15050913          	addi	s2,a0,336
    80001600:	02a79363          	bne	a5,a0,80001626 <exit+0x54>
    panic("init exiting");
    80001604:	00008517          	auipc	a0,0x8
    80001608:	bf450513          	addi	a0,a0,-1036 # 800091f8 <states.1780+0xa8>
    8000160c:	00005097          	auipc	ra,0x5
    80001610:	77c080e7          	jalr	1916(ra) # 80006d88 <panic>
      fileclose(f);
    80001614:	00002097          	auipc	ra,0x2
    80001618:	48e080e7          	jalr	1166(ra) # 80003aa2 <fileclose>
      p->ofile[fd] = 0;
    8000161c:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80001620:	04a1                	addi	s1,s1,8
    80001622:	01248563          	beq	s1,s2,8000162c <exit+0x5a>
    if(p->ofile[fd]){
    80001626:	6088                	ld	a0,0(s1)
    80001628:	f575                	bnez	a0,80001614 <exit+0x42>
    8000162a:	bfdd                	j	80001620 <exit+0x4e>
  begin_op();
    8000162c:	00002097          	auipc	ra,0x2
    80001630:	f72080e7          	jalr	-142(ra) # 8000359e <begin_op>
  iput(p->cwd);
    80001634:	1509b503          	ld	a0,336(s3)
    80001638:	00001097          	auipc	ra,0x1
    8000163c:	744080e7          	jalr	1860(ra) # 80002d7c <iput>
  end_op();
    80001640:	00002097          	auipc	ra,0x2
    80001644:	fde080e7          	jalr	-34(ra) # 8000361e <end_op>
  p->cwd = 0;
    80001648:	1409b823          	sd	zero,336(s3)
  acquire(&initproc->lock);
    8000164c:	00009497          	auipc	s1,0x9
    80001650:	9c448493          	addi	s1,s1,-1596 # 8000a010 <initproc>
    80001654:	6088                	ld	a0,0(s1)
    80001656:	00006097          	auipc	ra,0x6
    8000165a:	c9e080e7          	jalr	-866(ra) # 800072f4 <acquire>
  wakeup1(initproc);
    8000165e:	6088                	ld	a0,0(s1)
    80001660:	fffff097          	auipc	ra,0xfffff
    80001664:	702080e7          	jalr	1794(ra) # 80000d62 <wakeup1>
  release(&initproc->lock);
    80001668:	6088                	ld	a0,0(s1)
    8000166a:	00006097          	auipc	ra,0x6
    8000166e:	d3e080e7          	jalr	-706(ra) # 800073a8 <release>
  acquire(&p->lock);
    80001672:	854e                	mv	a0,s3
    80001674:	00006097          	auipc	ra,0x6
    80001678:	c80080e7          	jalr	-896(ra) # 800072f4 <acquire>
  struct proc *original_parent = p->parent;
    8000167c:	0209b483          	ld	s1,32(s3)
  release(&p->lock);
    80001680:	854e                	mv	a0,s3
    80001682:	00006097          	auipc	ra,0x6
    80001686:	d26080e7          	jalr	-730(ra) # 800073a8 <release>
  acquire(&original_parent->lock);
    8000168a:	8526                	mv	a0,s1
    8000168c:	00006097          	auipc	ra,0x6
    80001690:	c68080e7          	jalr	-920(ra) # 800072f4 <acquire>
  acquire(&p->lock);
    80001694:	854e                	mv	a0,s3
    80001696:	00006097          	auipc	ra,0x6
    8000169a:	c5e080e7          	jalr	-930(ra) # 800072f4 <acquire>
  reparent(p);
    8000169e:	854e                	mv	a0,s3
    800016a0:	00000097          	auipc	ra,0x0
    800016a4:	d30080e7          	jalr	-720(ra) # 800013d0 <reparent>
  wakeup1(original_parent);
    800016a8:	8526                	mv	a0,s1
    800016aa:	fffff097          	auipc	ra,0xfffff
    800016ae:	6b8080e7          	jalr	1720(ra) # 80000d62 <wakeup1>
  p->xstate = status;
    800016b2:	0349aa23          	sw	s4,52(s3)
  p->state = ZOMBIE;
    800016b6:	4791                	li	a5,4
    800016b8:	00f9ac23          	sw	a5,24(s3)
  release(&original_parent->lock);
    800016bc:	8526                	mv	a0,s1
    800016be:	00006097          	auipc	ra,0x6
    800016c2:	cea080e7          	jalr	-790(ra) # 800073a8 <release>
  sched();
    800016c6:	00000097          	auipc	ra,0x0
    800016ca:	e34080e7          	jalr	-460(ra) # 800014fa <sched>
  panic("zombie exit");
    800016ce:	00008517          	auipc	a0,0x8
    800016d2:	b3a50513          	addi	a0,a0,-1222 # 80009208 <states.1780+0xb8>
    800016d6:	00005097          	auipc	ra,0x5
    800016da:	6b2080e7          	jalr	1714(ra) # 80006d88 <panic>

00000000800016de <yield>:
{
    800016de:	1101                	addi	sp,sp,-32
    800016e0:	ec06                	sd	ra,24(sp)
    800016e2:	e822                	sd	s0,16(sp)
    800016e4:	e426                	sd	s1,8(sp)
    800016e6:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    800016e8:	00000097          	auipc	ra,0x0
    800016ec:	818080e7          	jalr	-2024(ra) # 80000f00 <myproc>
    800016f0:	84aa                	mv	s1,a0
  acquire(&p->lock);
    800016f2:	00006097          	auipc	ra,0x6
    800016f6:	c02080e7          	jalr	-1022(ra) # 800072f4 <acquire>
  p->state = RUNNABLE;
    800016fa:	4789                	li	a5,2
    800016fc:	cc9c                	sw	a5,24(s1)
  sched();
    800016fe:	00000097          	auipc	ra,0x0
    80001702:	dfc080e7          	jalr	-516(ra) # 800014fa <sched>
  release(&p->lock);
    80001706:	8526                	mv	a0,s1
    80001708:	00006097          	auipc	ra,0x6
    8000170c:	ca0080e7          	jalr	-864(ra) # 800073a8 <release>
}
    80001710:	60e2                	ld	ra,24(sp)
    80001712:	6442                	ld	s0,16(sp)
    80001714:	64a2                	ld	s1,8(sp)
    80001716:	6105                	addi	sp,sp,32
    80001718:	8082                	ret

000000008000171a <sleep>:
{
    8000171a:	7179                	addi	sp,sp,-48
    8000171c:	f406                	sd	ra,40(sp)
    8000171e:	f022                	sd	s0,32(sp)
    80001720:	ec26                	sd	s1,24(sp)
    80001722:	e84a                	sd	s2,16(sp)
    80001724:	e44e                	sd	s3,8(sp)
    80001726:	1800                	addi	s0,sp,48
    80001728:	89aa                	mv	s3,a0
    8000172a:	892e                	mv	s2,a1
  struct proc *p = myproc();
    8000172c:	fffff097          	auipc	ra,0xfffff
    80001730:	7d4080e7          	jalr	2004(ra) # 80000f00 <myproc>
    80001734:	84aa                	mv	s1,a0
  if(lk != &p->lock){  //DOC: sleeplock0
    80001736:	05250663          	beq	a0,s2,80001782 <sleep+0x68>
    acquire(&p->lock);  //DOC: sleeplock1
    8000173a:	00006097          	auipc	ra,0x6
    8000173e:	bba080e7          	jalr	-1094(ra) # 800072f4 <acquire>
    release(lk);
    80001742:	854a                	mv	a0,s2
    80001744:	00006097          	auipc	ra,0x6
    80001748:	c64080e7          	jalr	-924(ra) # 800073a8 <release>
  p->chan = chan;
    8000174c:	0334b423          	sd	s3,40(s1)
  p->state = SLEEPING;
    80001750:	4785                	li	a5,1
    80001752:	cc9c                	sw	a5,24(s1)
  sched();
    80001754:	00000097          	auipc	ra,0x0
    80001758:	da6080e7          	jalr	-602(ra) # 800014fa <sched>
  p->chan = 0;
    8000175c:	0204b423          	sd	zero,40(s1)
    release(&p->lock);
    80001760:	8526                	mv	a0,s1
    80001762:	00006097          	auipc	ra,0x6
    80001766:	c46080e7          	jalr	-954(ra) # 800073a8 <release>
    acquire(lk);
    8000176a:	854a                	mv	a0,s2
    8000176c:	00006097          	auipc	ra,0x6
    80001770:	b88080e7          	jalr	-1144(ra) # 800072f4 <acquire>
}
    80001774:	70a2                	ld	ra,40(sp)
    80001776:	7402                	ld	s0,32(sp)
    80001778:	64e2                	ld	s1,24(sp)
    8000177a:	6942                	ld	s2,16(sp)
    8000177c:	69a2                	ld	s3,8(sp)
    8000177e:	6145                	addi	sp,sp,48
    80001780:	8082                	ret
  p->chan = chan;
    80001782:	03353423          	sd	s3,40(a0)
  p->state = SLEEPING;
    80001786:	4785                	li	a5,1
    80001788:	cd1c                	sw	a5,24(a0)
  sched();
    8000178a:	00000097          	auipc	ra,0x0
    8000178e:	d70080e7          	jalr	-656(ra) # 800014fa <sched>
  p->chan = 0;
    80001792:	0204b423          	sd	zero,40(s1)
  if(lk != &p->lock){
    80001796:	bff9                	j	80001774 <sleep+0x5a>

0000000080001798 <wait>:
{
    80001798:	715d                	addi	sp,sp,-80
    8000179a:	e486                	sd	ra,72(sp)
    8000179c:	e0a2                	sd	s0,64(sp)
    8000179e:	fc26                	sd	s1,56(sp)
    800017a0:	f84a                	sd	s2,48(sp)
    800017a2:	f44e                	sd	s3,40(sp)
    800017a4:	f052                	sd	s4,32(sp)
    800017a6:	ec56                	sd	s5,24(sp)
    800017a8:	e85a                	sd	s6,16(sp)
    800017aa:	e45e                	sd	s7,8(sp)
    800017ac:	e062                	sd	s8,0(sp)
    800017ae:	0880                	addi	s0,sp,80
    800017b0:	8baa                	mv	s7,a0
  struct proc *p = myproc();
    800017b2:	fffff097          	auipc	ra,0xfffff
    800017b6:	74e080e7          	jalr	1870(ra) # 80000f00 <myproc>
    800017ba:	892a                	mv	s2,a0
  acquire(&p->lock);
    800017bc:	8c2a                	mv	s8,a0
    800017be:	00006097          	auipc	ra,0x6
    800017c2:	b36080e7          	jalr	-1226(ra) # 800072f4 <acquire>
    havekids = 0;
    800017c6:	4b01                	li	s6,0
        if(np->state == ZOMBIE){
    800017c8:	4a11                	li	s4,4
    for(np = proc; np < &proc[NPROC]; np++){
    800017ca:	0000e997          	auipc	s3,0xe
    800017ce:	6be98993          	addi	s3,s3,1726 # 8000fe88 <tickslock>
        havekids = 1;
    800017d2:	4a85                	li	s5,1
    havekids = 0;
    800017d4:	875a                	mv	a4,s6
    for(np = proc; np < &proc[NPROC]; np++){
    800017d6:	00009497          	auipc	s1,0x9
    800017da:	cb248493          	addi	s1,s1,-846 # 8000a488 <proc>
    800017de:	a08d                	j	80001840 <wait+0xa8>
          pid = np->pid;
    800017e0:	0384a983          	lw	s3,56(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&np->xstate,
    800017e4:	000b8e63          	beqz	s7,80001800 <wait+0x68>
    800017e8:	4691                	li	a3,4
    800017ea:	03448613          	addi	a2,s1,52
    800017ee:	85de                	mv	a1,s7
    800017f0:	05093503          	ld	a0,80(s2)
    800017f4:	fffff097          	auipc	ra,0xfffff
    800017f8:	38a080e7          	jalr	906(ra) # 80000b7e <copyout>
    800017fc:	02054263          	bltz	a0,80001820 <wait+0x88>
          freeproc(np);
    80001800:	8526                	mv	a0,s1
    80001802:	00000097          	auipc	ra,0x0
    80001806:	8b2080e7          	jalr	-1870(ra) # 800010b4 <freeproc>
          release(&np->lock);
    8000180a:	8526                	mv	a0,s1
    8000180c:	00006097          	auipc	ra,0x6
    80001810:	b9c080e7          	jalr	-1124(ra) # 800073a8 <release>
          release(&p->lock);
    80001814:	854a                	mv	a0,s2
    80001816:	00006097          	auipc	ra,0x6
    8000181a:	b92080e7          	jalr	-1134(ra) # 800073a8 <release>
          return pid;
    8000181e:	a8a9                	j	80001878 <wait+0xe0>
            release(&np->lock);
    80001820:	8526                	mv	a0,s1
    80001822:	00006097          	auipc	ra,0x6
    80001826:	b86080e7          	jalr	-1146(ra) # 800073a8 <release>
            release(&p->lock);
    8000182a:	854a                	mv	a0,s2
    8000182c:	00006097          	auipc	ra,0x6
    80001830:	b7c080e7          	jalr	-1156(ra) # 800073a8 <release>
            return -1;
    80001834:	59fd                	li	s3,-1
    80001836:	a089                	j	80001878 <wait+0xe0>
    for(np = proc; np < &proc[NPROC]; np++){
    80001838:	16848493          	addi	s1,s1,360
    8000183c:	03348463          	beq	s1,s3,80001864 <wait+0xcc>
      if(np->parent == p){
    80001840:	709c                	ld	a5,32(s1)
    80001842:	ff279be3          	bne	a5,s2,80001838 <wait+0xa0>
        acquire(&np->lock);
    80001846:	8526                	mv	a0,s1
    80001848:	00006097          	auipc	ra,0x6
    8000184c:	aac080e7          	jalr	-1364(ra) # 800072f4 <acquire>
        if(np->state == ZOMBIE){
    80001850:	4c9c                	lw	a5,24(s1)
    80001852:	f94787e3          	beq	a5,s4,800017e0 <wait+0x48>
        release(&np->lock);
    80001856:	8526                	mv	a0,s1
    80001858:	00006097          	auipc	ra,0x6
    8000185c:	b50080e7          	jalr	-1200(ra) # 800073a8 <release>
        havekids = 1;
    80001860:	8756                	mv	a4,s5
    80001862:	bfd9                	j	80001838 <wait+0xa0>
    if(!havekids || p->killed){
    80001864:	c701                	beqz	a4,8000186c <wait+0xd4>
    80001866:	03092783          	lw	a5,48(s2)
    8000186a:	c785                	beqz	a5,80001892 <wait+0xfa>
      release(&p->lock);
    8000186c:	854a                	mv	a0,s2
    8000186e:	00006097          	auipc	ra,0x6
    80001872:	b3a080e7          	jalr	-1222(ra) # 800073a8 <release>
      return -1;
    80001876:	59fd                	li	s3,-1
}
    80001878:	854e                	mv	a0,s3
    8000187a:	60a6                	ld	ra,72(sp)
    8000187c:	6406                	ld	s0,64(sp)
    8000187e:	74e2                	ld	s1,56(sp)
    80001880:	7942                	ld	s2,48(sp)
    80001882:	79a2                	ld	s3,40(sp)
    80001884:	7a02                	ld	s4,32(sp)
    80001886:	6ae2                	ld	s5,24(sp)
    80001888:	6b42                	ld	s6,16(sp)
    8000188a:	6ba2                	ld	s7,8(sp)
    8000188c:	6c02                	ld	s8,0(sp)
    8000188e:	6161                	addi	sp,sp,80
    80001890:	8082                	ret
    sleep(p, &p->lock);  //DOC: wait-sleep
    80001892:	85e2                	mv	a1,s8
    80001894:	854a                	mv	a0,s2
    80001896:	00000097          	auipc	ra,0x0
    8000189a:	e84080e7          	jalr	-380(ra) # 8000171a <sleep>
    havekids = 0;
    8000189e:	bf1d                	j	800017d4 <wait+0x3c>

00000000800018a0 <wakeup>:
{
    800018a0:	7139                	addi	sp,sp,-64
    800018a2:	fc06                	sd	ra,56(sp)
    800018a4:	f822                	sd	s0,48(sp)
    800018a6:	f426                	sd	s1,40(sp)
    800018a8:	f04a                	sd	s2,32(sp)
    800018aa:	ec4e                	sd	s3,24(sp)
    800018ac:	e852                	sd	s4,16(sp)
    800018ae:	e456                	sd	s5,8(sp)
    800018b0:	0080                	addi	s0,sp,64
    800018b2:	8a2a                	mv	s4,a0
  for(p = proc; p < &proc[NPROC]; p++) {
    800018b4:	00009497          	auipc	s1,0x9
    800018b8:	bd448493          	addi	s1,s1,-1068 # 8000a488 <proc>
    if(p->state == SLEEPING && p->chan == chan) {
    800018bc:	4985                	li	s3,1
      p->state = RUNNABLE;
    800018be:	4a89                	li	s5,2
  for(p = proc; p < &proc[NPROC]; p++) {
    800018c0:	0000e917          	auipc	s2,0xe
    800018c4:	5c890913          	addi	s2,s2,1480 # 8000fe88 <tickslock>
    800018c8:	a821                	j	800018e0 <wakeup+0x40>
      p->state = RUNNABLE;
    800018ca:	0154ac23          	sw	s5,24(s1)
    release(&p->lock);
    800018ce:	8526                	mv	a0,s1
    800018d0:	00006097          	auipc	ra,0x6
    800018d4:	ad8080e7          	jalr	-1320(ra) # 800073a8 <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018d8:	16848493          	addi	s1,s1,360
    800018dc:	01248e63          	beq	s1,s2,800018f8 <wakeup+0x58>
    acquire(&p->lock);
    800018e0:	8526                	mv	a0,s1
    800018e2:	00006097          	auipc	ra,0x6
    800018e6:	a12080e7          	jalr	-1518(ra) # 800072f4 <acquire>
    if(p->state == SLEEPING && p->chan == chan) {
    800018ea:	4c9c                	lw	a5,24(s1)
    800018ec:	ff3791e3          	bne	a5,s3,800018ce <wakeup+0x2e>
    800018f0:	749c                	ld	a5,40(s1)
    800018f2:	fd479ee3          	bne	a5,s4,800018ce <wakeup+0x2e>
    800018f6:	bfd1                	j	800018ca <wakeup+0x2a>
}
    800018f8:	70e2                	ld	ra,56(sp)
    800018fa:	7442                	ld	s0,48(sp)
    800018fc:	74a2                	ld	s1,40(sp)
    800018fe:	7902                	ld	s2,32(sp)
    80001900:	69e2                	ld	s3,24(sp)
    80001902:	6a42                	ld	s4,16(sp)
    80001904:	6aa2                	ld	s5,8(sp)
    80001906:	6121                	addi	sp,sp,64
    80001908:	8082                	ret

000000008000190a <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    8000190a:	7179                	addi	sp,sp,-48
    8000190c:	f406                	sd	ra,40(sp)
    8000190e:	f022                	sd	s0,32(sp)
    80001910:	ec26                	sd	s1,24(sp)
    80001912:	e84a                	sd	s2,16(sp)
    80001914:	e44e                	sd	s3,8(sp)
    80001916:	1800                	addi	s0,sp,48
    80001918:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    8000191a:	00009497          	auipc	s1,0x9
    8000191e:	b6e48493          	addi	s1,s1,-1170 # 8000a488 <proc>
    80001922:	0000e997          	auipc	s3,0xe
    80001926:	56698993          	addi	s3,s3,1382 # 8000fe88 <tickslock>
    acquire(&p->lock);
    8000192a:	8526                	mv	a0,s1
    8000192c:	00006097          	auipc	ra,0x6
    80001930:	9c8080e7          	jalr	-1592(ra) # 800072f4 <acquire>
    if(p->pid == pid){
    80001934:	5c9c                	lw	a5,56(s1)
    80001936:	01278d63          	beq	a5,s2,80001950 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    8000193a:	8526                	mv	a0,s1
    8000193c:	00006097          	auipc	ra,0x6
    80001940:	a6c080e7          	jalr	-1428(ra) # 800073a8 <release>
  for(p = proc; p < &proc[NPROC]; p++){
    80001944:	16848493          	addi	s1,s1,360
    80001948:	ff3491e3          	bne	s1,s3,8000192a <kill+0x20>
  }
  return -1;
    8000194c:	557d                	li	a0,-1
    8000194e:	a829                	j	80001968 <kill+0x5e>
      p->killed = 1;
    80001950:	4785                	li	a5,1
    80001952:	d89c                	sw	a5,48(s1)
      if(p->state == SLEEPING){
    80001954:	4c98                	lw	a4,24(s1)
    80001956:	4785                	li	a5,1
    80001958:	00f70f63          	beq	a4,a5,80001976 <kill+0x6c>
      release(&p->lock);
    8000195c:	8526                	mv	a0,s1
    8000195e:	00006097          	auipc	ra,0x6
    80001962:	a4a080e7          	jalr	-1462(ra) # 800073a8 <release>
      return 0;
    80001966:	4501                	li	a0,0
}
    80001968:	70a2                	ld	ra,40(sp)
    8000196a:	7402                	ld	s0,32(sp)
    8000196c:	64e2                	ld	s1,24(sp)
    8000196e:	6942                	ld	s2,16(sp)
    80001970:	69a2                	ld	s3,8(sp)
    80001972:	6145                	addi	sp,sp,48
    80001974:	8082                	ret
        p->state = RUNNABLE;
    80001976:	4789                	li	a5,2
    80001978:	cc9c                	sw	a5,24(s1)
    8000197a:	b7cd                	j	8000195c <kill+0x52>

000000008000197c <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    8000197c:	7179                	addi	sp,sp,-48
    8000197e:	f406                	sd	ra,40(sp)
    80001980:	f022                	sd	s0,32(sp)
    80001982:	ec26                	sd	s1,24(sp)
    80001984:	e84a                	sd	s2,16(sp)
    80001986:	e44e                	sd	s3,8(sp)
    80001988:	e052                	sd	s4,0(sp)
    8000198a:	1800                	addi	s0,sp,48
    8000198c:	84aa                	mv	s1,a0
    8000198e:	892e                	mv	s2,a1
    80001990:	89b2                	mv	s3,a2
    80001992:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80001994:	fffff097          	auipc	ra,0xfffff
    80001998:	56c080e7          	jalr	1388(ra) # 80000f00 <myproc>
  if(user_dst){
    8000199c:	c08d                	beqz	s1,800019be <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    8000199e:	86d2                	mv	a3,s4
    800019a0:	864e                	mv	a2,s3
    800019a2:	85ca                	mv	a1,s2
    800019a4:	6928                	ld	a0,80(a0)
    800019a6:	fffff097          	auipc	ra,0xfffff
    800019aa:	1d8080e7          	jalr	472(ra) # 80000b7e <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800019ae:	70a2                	ld	ra,40(sp)
    800019b0:	7402                	ld	s0,32(sp)
    800019b2:	64e2                	ld	s1,24(sp)
    800019b4:	6942                	ld	s2,16(sp)
    800019b6:	69a2                	ld	s3,8(sp)
    800019b8:	6a02                	ld	s4,0(sp)
    800019ba:	6145                	addi	sp,sp,48
    800019bc:	8082                	ret
    memmove((char *)dst, src, len);
    800019be:	000a061b          	sext.w	a2,s4
    800019c2:	85ce                	mv	a1,s3
    800019c4:	854a                	mv	a0,s2
    800019c6:	fffff097          	auipc	ra,0xfffff
    800019ca:	822080e7          	jalr	-2014(ra) # 800001e8 <memmove>
    return 0;
    800019ce:	8526                	mv	a0,s1
    800019d0:	bff9                	j	800019ae <either_copyout+0x32>

00000000800019d2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800019d2:	7179                	addi	sp,sp,-48
    800019d4:	f406                	sd	ra,40(sp)
    800019d6:	f022                	sd	s0,32(sp)
    800019d8:	ec26                	sd	s1,24(sp)
    800019da:	e84a                	sd	s2,16(sp)
    800019dc:	e44e                	sd	s3,8(sp)
    800019de:	e052                	sd	s4,0(sp)
    800019e0:	1800                	addi	s0,sp,48
    800019e2:	892a                	mv	s2,a0
    800019e4:	84ae                	mv	s1,a1
    800019e6:	89b2                	mv	s3,a2
    800019e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800019ea:	fffff097          	auipc	ra,0xfffff
    800019ee:	516080e7          	jalr	1302(ra) # 80000f00 <myproc>
  if(user_src){
    800019f2:	c08d                	beqz	s1,80001a14 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    800019f4:	86d2                	mv	a3,s4
    800019f6:	864e                	mv	a2,s3
    800019f8:	85ca                	mv	a1,s2
    800019fa:	6928                	ld	a0,80(a0)
    800019fc:	fffff097          	auipc	ra,0xfffff
    80001a00:	20e080e7          	jalr	526(ra) # 80000c0a <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80001a04:	70a2                	ld	ra,40(sp)
    80001a06:	7402                	ld	s0,32(sp)
    80001a08:	64e2                	ld	s1,24(sp)
    80001a0a:	6942                	ld	s2,16(sp)
    80001a0c:	69a2                	ld	s3,8(sp)
    80001a0e:	6a02                	ld	s4,0(sp)
    80001a10:	6145                	addi	sp,sp,48
    80001a12:	8082                	ret
    memmove(dst, (char*)src, len);
    80001a14:	000a061b          	sext.w	a2,s4
    80001a18:	85ce                	mv	a1,s3
    80001a1a:	854a                	mv	a0,s2
    80001a1c:	ffffe097          	auipc	ra,0xffffe
    80001a20:	7cc080e7          	jalr	1996(ra) # 800001e8 <memmove>
    return 0;
    80001a24:	8526                	mv	a0,s1
    80001a26:	bff9                	j	80001a04 <either_copyin+0x32>

0000000080001a28 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80001a28:	715d                	addi	sp,sp,-80
    80001a2a:	e486                	sd	ra,72(sp)
    80001a2c:	e0a2                	sd	s0,64(sp)
    80001a2e:	fc26                	sd	s1,56(sp)
    80001a30:	f84a                	sd	s2,48(sp)
    80001a32:	f44e                	sd	s3,40(sp)
    80001a34:	f052                	sd	s4,32(sp)
    80001a36:	ec56                	sd	s5,24(sp)
    80001a38:	e85a                	sd	s6,16(sp)
    80001a3a:	e45e                	sd	s7,8(sp)
    80001a3c:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80001a3e:	00007517          	auipc	a0,0x7
    80001a42:	60a50513          	addi	a0,a0,1546 # 80009048 <etext+0x48>
    80001a46:	00005097          	auipc	ra,0x5
    80001a4a:	38c080e7          	jalr	908(ra) # 80006dd2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a4e:	00009497          	auipc	s1,0x9
    80001a52:	b9248493          	addi	s1,s1,-1134 # 8000a5e0 <proc+0x158>
    80001a56:	0000e917          	auipc	s2,0xe
    80001a5a:	58a90913          	addi	s2,s2,1418 # 8000ffe0 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a5e:	4b11                	li	s6,4
      state = states[p->state];
    else
      state = "???";
    80001a60:	00007997          	auipc	s3,0x7
    80001a64:	7b898993          	addi	s3,s3,1976 # 80009218 <states.1780+0xc8>
    printf("%d %s %s", p->pid, state, p->name);
    80001a68:	00007a97          	auipc	s5,0x7
    80001a6c:	7b8a8a93          	addi	s5,s5,1976 # 80009220 <states.1780+0xd0>
    printf("\n");
    80001a70:	00007a17          	auipc	s4,0x7
    80001a74:	5d8a0a13          	addi	s4,s4,1496 # 80009048 <etext+0x48>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001a78:	00007b97          	auipc	s7,0x7
    80001a7c:	6d8b8b93          	addi	s7,s7,1752 # 80009150 <states.1780>
    80001a80:	a015                	j	80001aa4 <procdump+0x7c>
    printf("%d %s %s", p->pid, state, p->name);
    80001a82:	86ba                	mv	a3,a4
    80001a84:	ee072583          	lw	a1,-288(a4)
    80001a88:	8556                	mv	a0,s5
    80001a8a:	00005097          	auipc	ra,0x5
    80001a8e:	348080e7          	jalr	840(ra) # 80006dd2 <printf>
    printf("\n");
    80001a92:	8552                	mv	a0,s4
    80001a94:	00005097          	auipc	ra,0x5
    80001a98:	33e080e7          	jalr	830(ra) # 80006dd2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80001a9c:	16848493          	addi	s1,s1,360
    80001aa0:	03248163          	beq	s1,s2,80001ac2 <procdump+0x9a>
    if(p->state == UNUSED)
    80001aa4:	8726                	mv	a4,s1
    80001aa6:	ec04a783          	lw	a5,-320(s1)
    80001aaa:	dbed                	beqz	a5,80001a9c <procdump+0x74>
      state = "???";
    80001aac:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80001aae:	fcfb6ae3          	bltu	s6,a5,80001a82 <procdump+0x5a>
    80001ab2:	1782                	slli	a5,a5,0x20
    80001ab4:	9381                	srli	a5,a5,0x20
    80001ab6:	078e                	slli	a5,a5,0x3
    80001ab8:	97de                	add	a5,a5,s7
    80001aba:	6390                	ld	a2,0(a5)
    80001abc:	f279                	bnez	a2,80001a82 <procdump+0x5a>
      state = "???";
    80001abe:	864e                	mv	a2,s3
    80001ac0:	b7c9                	j	80001a82 <procdump+0x5a>
  }
}
    80001ac2:	60a6                	ld	ra,72(sp)
    80001ac4:	6406                	ld	s0,64(sp)
    80001ac6:	74e2                	ld	s1,56(sp)
    80001ac8:	7942                	ld	s2,48(sp)
    80001aca:	79a2                	ld	s3,40(sp)
    80001acc:	7a02                	ld	s4,32(sp)
    80001ace:	6ae2                	ld	s5,24(sp)
    80001ad0:	6b42                	ld	s6,16(sp)
    80001ad2:	6ba2                	ld	s7,8(sp)
    80001ad4:	6161                	addi	sp,sp,80
    80001ad6:	8082                	ret

0000000080001ad8 <swtch>:
    80001ad8:	00153023          	sd	ra,0(a0)
    80001adc:	00253423          	sd	sp,8(a0)
    80001ae0:	e900                	sd	s0,16(a0)
    80001ae2:	ed04                	sd	s1,24(a0)
    80001ae4:	03253023          	sd	s2,32(a0)
    80001ae8:	03353423          	sd	s3,40(a0)
    80001aec:	03453823          	sd	s4,48(a0)
    80001af0:	03553c23          	sd	s5,56(a0)
    80001af4:	05653023          	sd	s6,64(a0)
    80001af8:	05753423          	sd	s7,72(a0)
    80001afc:	05853823          	sd	s8,80(a0)
    80001b00:	05953c23          	sd	s9,88(a0)
    80001b04:	07a53023          	sd	s10,96(a0)
    80001b08:	07b53423          	sd	s11,104(a0)
    80001b0c:	0005b083          	ld	ra,0(a1)
    80001b10:	0085b103          	ld	sp,8(a1)
    80001b14:	6980                	ld	s0,16(a1)
    80001b16:	6d84                	ld	s1,24(a1)
    80001b18:	0205b903          	ld	s2,32(a1)
    80001b1c:	0285b983          	ld	s3,40(a1)
    80001b20:	0305ba03          	ld	s4,48(a1)
    80001b24:	0385ba83          	ld	s5,56(a1)
    80001b28:	0405bb03          	ld	s6,64(a1)
    80001b2c:	0485bb83          	ld	s7,72(a1)
    80001b30:	0505bc03          	ld	s8,80(a1)
    80001b34:	0585bc83          	ld	s9,88(a1)
    80001b38:	0605bd03          	ld	s10,96(a1)
    80001b3c:	0685bd83          	ld	s11,104(a1)
    80001b40:	8082                	ret

0000000080001b42 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80001b42:	1141                	addi	sp,sp,-16
    80001b44:	e406                	sd	ra,8(sp)
    80001b46:	e022                	sd	s0,0(sp)
    80001b48:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80001b4a:	00007597          	auipc	a1,0x7
    80001b4e:	70e58593          	addi	a1,a1,1806 # 80009258 <states.1780+0x108>
    80001b52:	0000e517          	auipc	a0,0xe
    80001b56:	33650513          	addi	a0,a0,822 # 8000fe88 <tickslock>
    80001b5a:	00005097          	auipc	ra,0x5
    80001b5e:	70a080e7          	jalr	1802(ra) # 80007264 <initlock>
}
    80001b62:	60a2                	ld	ra,8(sp)
    80001b64:	6402                	ld	s0,0(sp)
    80001b66:	0141                	addi	sp,sp,16
    80001b68:	8082                	ret

0000000080001b6a <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80001b6a:	1141                	addi	sp,sp,-16
    80001b6c:	e422                	sd	s0,8(sp)
    80001b6e:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001b70:	00003797          	auipc	a5,0x3
    80001b74:	67078793          	addi	a5,a5,1648 # 800051e0 <kernelvec>
    80001b78:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80001b7c:	6422                	ld	s0,8(sp)
    80001b7e:	0141                	addi	sp,sp,16
    80001b80:	8082                	ret

0000000080001b82 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80001b82:	1141                	addi	sp,sp,-16
    80001b84:	e406                	sd	ra,8(sp)
    80001b86:	e022                	sd	s0,0(sp)
    80001b88:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    80001b8a:	fffff097          	auipc	ra,0xfffff
    80001b8e:	376080e7          	jalr	886(ra) # 80000f00 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001b92:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80001b96:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001b98:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to trampoline.S
  w_stvec(TRAMPOLINE + (uservec - trampoline));
    80001b9c:	00006617          	auipc	a2,0x6
    80001ba0:	46460613          	addi	a2,a2,1124 # 80008000 <_trampoline>
    80001ba4:	00006697          	auipc	a3,0x6
    80001ba8:	45c68693          	addi	a3,a3,1116 # 80008000 <_trampoline>
    80001bac:	8e91                	sub	a3,a3,a2
    80001bae:	040007b7          	lui	a5,0x4000
    80001bb2:	17fd                	addi	a5,a5,-1
    80001bb4:	07b2                	slli	a5,a5,0xc
    80001bb6:	96be                	add	a3,a3,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001bb8:	10569073          	csrw	stvec,a3

  // set up trapframe values that uservec will need when
  // the process next re-enters the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    80001bbc:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    80001bbe:	180026f3          	csrr	a3,satp
    80001bc2:	e314                	sd	a3,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    80001bc4:	6d38                	ld	a4,88(a0)
    80001bc6:	6134                	ld	a3,64(a0)
    80001bc8:	6585                	lui	a1,0x1
    80001bca:	96ae                	add	a3,a3,a1
    80001bcc:	e714                	sd	a3,8(a4)
  p->trapframe->kernel_trap = (uint64)usertrap;
    80001bce:	6d38                	ld	a4,88(a0)
    80001bd0:	00000697          	auipc	a3,0x0
    80001bd4:	14a68693          	addi	a3,a3,330 # 80001d1a <usertrap>
    80001bd8:	eb14                	sd	a3,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80001bda:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    80001bdc:	8692                	mv	a3,tp
    80001bde:	f314                	sd	a3,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001be0:	100026f3          	csrr	a3,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80001be4:	eff6f693          	andi	a3,a3,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80001be8:	0206e693          	ori	a3,a3,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001bec:	10069073          	csrw	sstatus,a3
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    80001bf0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001bf2:	6f18                	ld	a4,24(a4)
    80001bf4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80001bf8:	692c                	ld	a1,80(a0)
    80001bfa:	81b1                	srli	a1,a1,0xc

  // jump to trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 fn = TRAMPOLINE + (userret - trampoline);
    80001bfc:	00006717          	auipc	a4,0x6
    80001c00:	49470713          	addi	a4,a4,1172 # 80008090 <userret>
    80001c04:	8f11                	sub	a4,a4,a2
    80001c06:	97ba                	add	a5,a5,a4
  ((void (*)(uint64,uint64))fn)(TRAPFRAME, satp);
    80001c08:	577d                	li	a4,-1
    80001c0a:	177e                	slli	a4,a4,0x3f
    80001c0c:	8dd9                	or	a1,a1,a4
    80001c0e:	02000537          	lui	a0,0x2000
    80001c12:	157d                	addi	a0,a0,-1
    80001c14:	0536                	slli	a0,a0,0xd
    80001c16:	9782                	jalr	a5
}
    80001c18:	60a2                	ld	ra,8(sp)
    80001c1a:	6402                	ld	s0,0(sp)
    80001c1c:	0141                	addi	sp,sp,16
    80001c1e:	8082                	ret

0000000080001c20 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80001c20:	1101                	addi	sp,sp,-32
    80001c22:	ec06                	sd	ra,24(sp)
    80001c24:	e822                	sd	s0,16(sp)
    80001c26:	e426                	sd	s1,8(sp)
    80001c28:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80001c2a:	0000e497          	auipc	s1,0xe
    80001c2e:	25e48493          	addi	s1,s1,606 # 8000fe88 <tickslock>
    80001c32:	8526                	mv	a0,s1
    80001c34:	00005097          	auipc	ra,0x5
    80001c38:	6c0080e7          	jalr	1728(ra) # 800072f4 <acquire>
  ticks++;
    80001c3c:	00008517          	auipc	a0,0x8
    80001c40:	3dc50513          	addi	a0,a0,988 # 8000a018 <ticks>
    80001c44:	411c                	lw	a5,0(a0)
    80001c46:	2785                	addiw	a5,a5,1
    80001c48:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80001c4a:	00000097          	auipc	ra,0x0
    80001c4e:	c56080e7          	jalr	-938(ra) # 800018a0 <wakeup>
  release(&tickslock);
    80001c52:	8526                	mv	a0,s1
    80001c54:	00005097          	auipc	ra,0x5
    80001c58:	754080e7          	jalr	1876(ra) # 800073a8 <release>
}
    80001c5c:	60e2                	ld	ra,24(sp)
    80001c5e:	6442                	ld	s0,16(sp)
    80001c60:	64a2                	ld	s1,8(sp)
    80001c62:	6105                	addi	sp,sp,32
    80001c64:	8082                	ret

0000000080001c66 <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    80001c66:	1101                	addi	sp,sp,-32
    80001c68:	ec06                	sd	ra,24(sp)
    80001c6a:	e822                	sd	s0,16(sp)
    80001c6c:	e426                	sd	s1,8(sp)
    80001c6e:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001c70:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    80001c74:	00074d63          	bltz	a4,80001c8e <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    80001c78:	57fd                	li	a5,-1
    80001c7a:	17fe                	slli	a5,a5,0x3f
    80001c7c:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    80001c7e:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    80001c80:	06f70c63          	beq	a4,a5,80001cf8 <devintr+0x92>
  }
}
    80001c84:	60e2                	ld	ra,24(sp)
    80001c86:	6442                	ld	s0,16(sp)
    80001c88:	64a2                	ld	s1,8(sp)
    80001c8a:	6105                	addi	sp,sp,32
    80001c8c:	8082                	ret
     (scause & 0xff) == 9){
    80001c8e:	0ff77793          	andi	a5,a4,255
  if((scause & 0x8000000000000000L) &&
    80001c92:	46a5                	li	a3,9
    80001c94:	fed792e3          	bne	a5,a3,80001c78 <devintr+0x12>
    int irq = plic_claim();
    80001c98:	00003097          	auipc	ra,0x3
    80001c9c:	66a080e7          	jalr	1642(ra) # 80005302 <plic_claim>
    80001ca0:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    80001ca2:	47a9                	li	a5,10
    80001ca4:	02f50563          	beq	a0,a5,80001cce <devintr+0x68>
    } else if(irq == VIRTIO0_IRQ){
    80001ca8:	4785                	li	a5,1
    80001caa:	02f50d63          	beq	a0,a5,80001ce4 <devintr+0x7e>
    else if(irq == E1000_IRQ){
    80001cae:	02100793          	li	a5,33
    80001cb2:	02f50e63          	beq	a0,a5,80001cee <devintr+0x88>
    return 1;
    80001cb6:	4505                	li	a0,1
    else if(irq){
    80001cb8:	d4f1                	beqz	s1,80001c84 <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    80001cba:	85a6                	mv	a1,s1
    80001cbc:	00007517          	auipc	a0,0x7
    80001cc0:	5a450513          	addi	a0,a0,1444 # 80009260 <states.1780+0x110>
    80001cc4:	00005097          	auipc	ra,0x5
    80001cc8:	10e080e7          	jalr	270(ra) # 80006dd2 <printf>
    80001ccc:	a029                	j	80001cd6 <devintr+0x70>
      uartintr();
    80001cce:	00005097          	auipc	ra,0x5
    80001cd2:	546080e7          	jalr	1350(ra) # 80007214 <uartintr>
      plic_complete(irq);
    80001cd6:	8526                	mv	a0,s1
    80001cd8:	00003097          	auipc	ra,0x3
    80001cdc:	64e080e7          	jalr	1614(ra) # 80005326 <plic_complete>
    return 1;
    80001ce0:	4505                	li	a0,1
    80001ce2:	b74d                	j	80001c84 <devintr+0x1e>
      virtio_disk_intr();
    80001ce4:	00004097          	auipc	ra,0x4
    80001ce8:	b40080e7          	jalr	-1216(ra) # 80005824 <virtio_disk_intr>
    80001cec:	b7ed                	j	80001cd6 <devintr+0x70>
      e1000_intr();
    80001cee:	00004097          	auipc	ra,0x4
    80001cf2:	e82080e7          	jalr	-382(ra) # 80005b70 <e1000_intr>
    80001cf6:	b7c5                	j	80001cd6 <devintr+0x70>
    if(cpuid() == 0){
    80001cf8:	fffff097          	auipc	ra,0xfffff
    80001cfc:	1dc080e7          	jalr	476(ra) # 80000ed4 <cpuid>
    80001d00:	c901                	beqz	a0,80001d10 <devintr+0xaa>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80001d02:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    80001d06:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    80001d08:	14479073          	csrw	sip,a5
    return 2;
    80001d0c:	4509                	li	a0,2
    80001d0e:	bf9d                	j	80001c84 <devintr+0x1e>
      clockintr();
    80001d10:	00000097          	auipc	ra,0x0
    80001d14:	f10080e7          	jalr	-240(ra) # 80001c20 <clockintr>
    80001d18:	b7ed                	j	80001d02 <devintr+0x9c>

0000000080001d1a <usertrap>:
{
    80001d1a:	1101                	addi	sp,sp,-32
    80001d1c:	ec06                	sd	ra,24(sp)
    80001d1e:	e822                	sd	s0,16(sp)
    80001d20:	e426                	sd	s1,8(sp)
    80001d22:	e04a                	sd	s2,0(sp)
    80001d24:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d26:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    80001d2a:	1007f793          	andi	a5,a5,256
    80001d2e:	e3b9                	bnez	a5,80001d74 <usertrap+0x5a>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80001d30:	00003797          	auipc	a5,0x3
    80001d34:	4b078793          	addi	a5,a5,1200 # 800051e0 <kernelvec>
    80001d38:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80001d3c:	fffff097          	auipc	ra,0xfffff
    80001d40:	1c4080e7          	jalr	452(ra) # 80000f00 <myproc>
    80001d44:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    80001d46:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001d48:	14102773          	csrr	a4,sepc
    80001d4c:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001d4e:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80001d52:	47a1                	li	a5,8
    80001d54:	02f70863          	beq	a4,a5,80001d84 <usertrap+0x6a>
  } else if((which_dev = devintr()) != 0){
    80001d58:	00000097          	auipc	ra,0x0
    80001d5c:	f0e080e7          	jalr	-242(ra) # 80001c66 <devintr>
    80001d60:	892a                	mv	s2,a0
    80001d62:	c551                	beqz	a0,80001dee <usertrap+0xd4>
  if(lockfree_read4(&p->killed))
    80001d64:	03048513          	addi	a0,s1,48
    80001d68:	00005097          	auipc	ra,0x5
    80001d6c:	69e080e7          	jalr	1694(ra) # 80007406 <lockfree_read4>
    80001d70:	cd21                	beqz	a0,80001dc8 <usertrap+0xae>
    80001d72:	a0b1                	j	80001dbe <usertrap+0xa4>
    panic("usertrap: not from user mode");
    80001d74:	00007517          	auipc	a0,0x7
    80001d78:	50c50513          	addi	a0,a0,1292 # 80009280 <states.1780+0x130>
    80001d7c:	00005097          	auipc	ra,0x5
    80001d80:	00c080e7          	jalr	12(ra) # 80006d88 <panic>
    if(lockfree_read4(&p->killed))
    80001d84:	03050513          	addi	a0,a0,48
    80001d88:	00005097          	auipc	ra,0x5
    80001d8c:	67e080e7          	jalr	1662(ra) # 80007406 <lockfree_read4>
    80001d90:	e929                	bnez	a0,80001de2 <usertrap+0xc8>
    p->trapframe->epc += 4;
    80001d92:	6cb8                	ld	a4,88(s1)
    80001d94:	6f1c                	ld	a5,24(a4)
    80001d96:	0791                	addi	a5,a5,4
    80001d98:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001d9a:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001d9e:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001da2:	10079073          	csrw	sstatus,a5
    syscall();
    80001da6:	00000097          	auipc	ra,0x0
    80001daa:	2ce080e7          	jalr	718(ra) # 80002074 <syscall>
  if(lockfree_read4(&p->killed))
    80001dae:	03048513          	addi	a0,s1,48
    80001db2:	00005097          	auipc	ra,0x5
    80001db6:	654080e7          	jalr	1620(ra) # 80007406 <lockfree_read4>
    80001dba:	c911                	beqz	a0,80001dce <usertrap+0xb4>
    80001dbc:	4901                	li	s2,0
    exit(-1);
    80001dbe:	557d                	li	a0,-1
    80001dc0:	00000097          	auipc	ra,0x0
    80001dc4:	812080e7          	jalr	-2030(ra) # 800015d2 <exit>
  if(which_dev == 2)
    80001dc8:	4789                	li	a5,2
    80001dca:	04f90c63          	beq	s2,a5,80001e22 <usertrap+0x108>
  usertrapret();
    80001dce:	00000097          	auipc	ra,0x0
    80001dd2:	db4080e7          	jalr	-588(ra) # 80001b82 <usertrapret>
}
    80001dd6:	60e2                	ld	ra,24(sp)
    80001dd8:	6442                	ld	s0,16(sp)
    80001dda:	64a2                	ld	s1,8(sp)
    80001ddc:	6902                	ld	s2,0(sp)
    80001dde:	6105                	addi	sp,sp,32
    80001de0:	8082                	ret
      exit(-1);
    80001de2:	557d                	li	a0,-1
    80001de4:	fffff097          	auipc	ra,0xfffff
    80001de8:	7ee080e7          	jalr	2030(ra) # 800015d2 <exit>
    80001dec:	b75d                	j	80001d92 <usertrap+0x78>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001dee:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    80001df2:	5c90                	lw	a2,56(s1)
    80001df4:	00007517          	auipc	a0,0x7
    80001df8:	4ac50513          	addi	a0,a0,1196 # 800092a0 <states.1780+0x150>
    80001dfc:	00005097          	auipc	ra,0x5
    80001e00:	fd6080e7          	jalr	-42(ra) # 80006dd2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e04:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001e08:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001e0c:	00007517          	auipc	a0,0x7
    80001e10:	4c450513          	addi	a0,a0,1220 # 800092d0 <states.1780+0x180>
    80001e14:	00005097          	auipc	ra,0x5
    80001e18:	fbe080e7          	jalr	-66(ra) # 80006dd2 <printf>
    p->killed = 1;
    80001e1c:	4785                	li	a5,1
    80001e1e:	d89c                	sw	a5,48(s1)
    80001e20:	b779                	j	80001dae <usertrap+0x94>
    yield();
    80001e22:	00000097          	auipc	ra,0x0
    80001e26:	8bc080e7          	jalr	-1860(ra) # 800016de <yield>
    80001e2a:	b755                	j	80001dce <usertrap+0xb4>

0000000080001e2c <kerneltrap>:
{
    80001e2c:	7179                	addi	sp,sp,-48
    80001e2e:	f406                	sd	ra,40(sp)
    80001e30:	f022                	sd	s0,32(sp)
    80001e32:	ec26                	sd	s1,24(sp)
    80001e34:	e84a                	sd	s2,16(sp)
    80001e36:	e44e                	sd	s3,8(sp)
    80001e38:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001e3a:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e3e:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80001e42:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80001e46:	1004f793          	andi	a5,s1,256
    80001e4a:	cb85                	beqz	a5,80001e7a <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e4c:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e50:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80001e52:	ef85                	bnez	a5,80001e8a <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80001e54:	00000097          	auipc	ra,0x0
    80001e58:	e12080e7          	jalr	-494(ra) # 80001c66 <devintr>
    80001e5c:	cd1d                	beqz	a0,80001e9a <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001e5e:	4789                	li	a5,2
    80001e60:	06f50a63          	beq	a0,a5,80001ed4 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80001e64:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e68:	10049073          	csrw	sstatus,s1
}
    80001e6c:	70a2                	ld	ra,40(sp)
    80001e6e:	7402                	ld	s0,32(sp)
    80001e70:	64e2                	ld	s1,24(sp)
    80001e72:	6942                	ld	s2,16(sp)
    80001e74:	69a2                	ld	s3,8(sp)
    80001e76:	6145                	addi	sp,sp,48
    80001e78:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80001e7a:	00007517          	auipc	a0,0x7
    80001e7e:	47650513          	addi	a0,a0,1142 # 800092f0 <states.1780+0x1a0>
    80001e82:	00005097          	auipc	ra,0x5
    80001e86:	f06080e7          	jalr	-250(ra) # 80006d88 <panic>
    panic("kerneltrap: interrupts enabled");
    80001e8a:	00007517          	auipc	a0,0x7
    80001e8e:	48e50513          	addi	a0,a0,1166 # 80009318 <states.1780+0x1c8>
    80001e92:	00005097          	auipc	ra,0x5
    80001e96:	ef6080e7          	jalr	-266(ra) # 80006d88 <panic>
    printf("scause %p\n", scause);
    80001e9a:	85ce                	mv	a1,s3
    80001e9c:	00007517          	auipc	a0,0x7
    80001ea0:	49c50513          	addi	a0,a0,1180 # 80009338 <states.1780+0x1e8>
    80001ea4:	00005097          	auipc	ra,0x5
    80001ea8:	f2e080e7          	jalr	-210(ra) # 80006dd2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80001eac:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80001eb0:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80001eb4:	00007517          	auipc	a0,0x7
    80001eb8:	49450513          	addi	a0,a0,1172 # 80009348 <states.1780+0x1f8>
    80001ebc:	00005097          	auipc	ra,0x5
    80001ec0:	f16080e7          	jalr	-234(ra) # 80006dd2 <printf>
    panic("kerneltrap");
    80001ec4:	00007517          	auipc	a0,0x7
    80001ec8:	49c50513          	addi	a0,a0,1180 # 80009360 <states.1780+0x210>
    80001ecc:	00005097          	auipc	ra,0x5
    80001ed0:	ebc080e7          	jalr	-324(ra) # 80006d88 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80001ed4:	fffff097          	auipc	ra,0xfffff
    80001ed8:	02c080e7          	jalr	44(ra) # 80000f00 <myproc>
    80001edc:	d541                	beqz	a0,80001e64 <kerneltrap+0x38>
    80001ede:	fffff097          	auipc	ra,0xfffff
    80001ee2:	022080e7          	jalr	34(ra) # 80000f00 <myproc>
    80001ee6:	4d18                	lw	a4,24(a0)
    80001ee8:	478d                	li	a5,3
    80001eea:	f6f71de3          	bne	a4,a5,80001e64 <kerneltrap+0x38>
    yield();
    80001eee:	fffff097          	auipc	ra,0xfffff
    80001ef2:	7f0080e7          	jalr	2032(ra) # 800016de <yield>
    80001ef6:	b7bd                	j	80001e64 <kerneltrap+0x38>

0000000080001ef8 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80001ef8:	1101                	addi	sp,sp,-32
    80001efa:	ec06                	sd	ra,24(sp)
    80001efc:	e822                	sd	s0,16(sp)
    80001efe:	e426                	sd	s1,8(sp)
    80001f00:	1000                	addi	s0,sp,32
    80001f02:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80001f04:	fffff097          	auipc	ra,0xfffff
    80001f08:	ffc080e7          	jalr	-4(ra) # 80000f00 <myproc>
  switch (n) {
    80001f0c:	4795                	li	a5,5
    80001f0e:	0497e363          	bltu	a5,s1,80001f54 <argraw+0x5c>
    80001f12:	1482                	slli	s1,s1,0x20
    80001f14:	9081                	srli	s1,s1,0x20
    80001f16:	048a                	slli	s1,s1,0x2
    80001f18:	00007717          	auipc	a4,0x7
    80001f1c:	45870713          	addi	a4,a4,1112 # 80009370 <states.1780+0x220>
    80001f20:	94ba                	add	s1,s1,a4
    80001f22:	409c                	lw	a5,0(s1)
    80001f24:	97ba                	add	a5,a5,a4
    80001f26:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80001f28:	6d3c                	ld	a5,88(a0)
    80001f2a:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80001f2c:	60e2                	ld	ra,24(sp)
    80001f2e:	6442                	ld	s0,16(sp)
    80001f30:	64a2                	ld	s1,8(sp)
    80001f32:	6105                	addi	sp,sp,32
    80001f34:	8082                	ret
    return p->trapframe->a1;
    80001f36:	6d3c                	ld	a5,88(a0)
    80001f38:	7fa8                	ld	a0,120(a5)
    80001f3a:	bfcd                	j	80001f2c <argraw+0x34>
    return p->trapframe->a2;
    80001f3c:	6d3c                	ld	a5,88(a0)
    80001f3e:	63c8                	ld	a0,128(a5)
    80001f40:	b7f5                	j	80001f2c <argraw+0x34>
    return p->trapframe->a3;
    80001f42:	6d3c                	ld	a5,88(a0)
    80001f44:	67c8                	ld	a0,136(a5)
    80001f46:	b7dd                	j	80001f2c <argraw+0x34>
    return p->trapframe->a4;
    80001f48:	6d3c                	ld	a5,88(a0)
    80001f4a:	6bc8                	ld	a0,144(a5)
    80001f4c:	b7c5                	j	80001f2c <argraw+0x34>
    return p->trapframe->a5;
    80001f4e:	6d3c                	ld	a5,88(a0)
    80001f50:	6fc8                	ld	a0,152(a5)
    80001f52:	bfe9                	j	80001f2c <argraw+0x34>
  panic("argraw");
    80001f54:	00007517          	auipc	a0,0x7
    80001f58:	52450513          	addi	a0,a0,1316 # 80009478 <syscalls+0xf0>
    80001f5c:	00005097          	auipc	ra,0x5
    80001f60:	e2c080e7          	jalr	-468(ra) # 80006d88 <panic>

0000000080001f64 <fetchaddr>:
{
    80001f64:	1101                	addi	sp,sp,-32
    80001f66:	ec06                	sd	ra,24(sp)
    80001f68:	e822                	sd	s0,16(sp)
    80001f6a:	e426                	sd	s1,8(sp)
    80001f6c:	e04a                	sd	s2,0(sp)
    80001f6e:	1000                	addi	s0,sp,32
    80001f70:	84aa                	mv	s1,a0
    80001f72:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f74:	fffff097          	auipc	ra,0xfffff
    80001f78:	f8c080e7          	jalr	-116(ra) # 80000f00 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz)
    80001f7c:	653c                	ld	a5,72(a0)
    80001f7e:	02f4f963          	bleu	a5,s1,80001fb0 <fetchaddr+0x4c>
    80001f82:	00848713          	addi	a4,s1,8
    80001f86:	02e7e763          	bltu	a5,a4,80001fb4 <fetchaddr+0x50>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80001f8a:	46a1                	li	a3,8
    80001f8c:	8626                	mv	a2,s1
    80001f8e:	85ca                	mv	a1,s2
    80001f90:	6928                	ld	a0,80(a0)
    80001f92:	fffff097          	auipc	ra,0xfffff
    80001f96:	c78080e7          	jalr	-904(ra) # 80000c0a <copyin>
    80001f9a:	00a03533          	snez	a0,a0
    80001f9e:	40a0053b          	negw	a0,a0
    80001fa2:	2501                	sext.w	a0,a0
}
    80001fa4:	60e2                	ld	ra,24(sp)
    80001fa6:	6442                	ld	s0,16(sp)
    80001fa8:	64a2                	ld	s1,8(sp)
    80001faa:	6902                	ld	s2,0(sp)
    80001fac:	6105                	addi	sp,sp,32
    80001fae:	8082                	ret
    return -1;
    80001fb0:	557d                	li	a0,-1
    80001fb2:	bfcd                	j	80001fa4 <fetchaddr+0x40>
    80001fb4:	557d                	li	a0,-1
    80001fb6:	b7fd                	j	80001fa4 <fetchaddr+0x40>

0000000080001fb8 <fetchstr>:
{
    80001fb8:	7179                	addi	sp,sp,-48
    80001fba:	f406                	sd	ra,40(sp)
    80001fbc:	f022                	sd	s0,32(sp)
    80001fbe:	ec26                	sd	s1,24(sp)
    80001fc0:	e84a                	sd	s2,16(sp)
    80001fc2:	e44e                	sd	s3,8(sp)
    80001fc4:	1800                	addi	s0,sp,48
    80001fc6:	892a                	mv	s2,a0
    80001fc8:	84ae                	mv	s1,a1
    80001fca:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80001fcc:	fffff097          	auipc	ra,0xfffff
    80001fd0:	f34080e7          	jalr	-204(ra) # 80000f00 <myproc>
  int err = copyinstr(p->pagetable, buf, addr, max);
    80001fd4:	86ce                	mv	a3,s3
    80001fd6:	864a                	mv	a2,s2
    80001fd8:	85a6                	mv	a1,s1
    80001fda:	6928                	ld	a0,80(a0)
    80001fdc:	fffff097          	auipc	ra,0xfffff
    80001fe0:	cbc080e7          	jalr	-836(ra) # 80000c98 <copyinstr>
  if(err < 0)
    80001fe4:	00054763          	bltz	a0,80001ff2 <fetchstr+0x3a>
  return strlen(buf);
    80001fe8:	8526                	mv	a0,s1
    80001fea:	ffffe097          	auipc	ra,0xffffe
    80001fee:	33c080e7          	jalr	828(ra) # 80000326 <strlen>
}
    80001ff2:	70a2                	ld	ra,40(sp)
    80001ff4:	7402                	ld	s0,32(sp)
    80001ff6:	64e2                	ld	s1,24(sp)
    80001ff8:	6942                	ld	s2,16(sp)
    80001ffa:	69a2                	ld	s3,8(sp)
    80001ffc:	6145                	addi	sp,sp,48
    80001ffe:	8082                	ret

0000000080002000 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
    80002000:	1101                	addi	sp,sp,-32
    80002002:	ec06                	sd	ra,24(sp)
    80002004:	e822                	sd	s0,16(sp)
    80002006:	e426                	sd	s1,8(sp)
    80002008:	1000                	addi	s0,sp,32
    8000200a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000200c:	00000097          	auipc	ra,0x0
    80002010:	eec080e7          	jalr	-276(ra) # 80001ef8 <argraw>
    80002014:	c088                	sw	a0,0(s1)
  return 0;
}
    80002016:	4501                	li	a0,0
    80002018:	60e2                	ld	ra,24(sp)
    8000201a:	6442                	ld	s0,16(sp)
    8000201c:	64a2                	ld	s1,8(sp)
    8000201e:	6105                	addi	sp,sp,32
    80002020:	8082                	ret

0000000080002022 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
int
argaddr(int n, uint64 *ip)
{
    80002022:	1101                	addi	sp,sp,-32
    80002024:	ec06                	sd	ra,24(sp)
    80002026:	e822                	sd	s0,16(sp)
    80002028:	e426                	sd	s1,8(sp)
    8000202a:	1000                	addi	s0,sp,32
    8000202c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000202e:	00000097          	auipc	ra,0x0
    80002032:	eca080e7          	jalr	-310(ra) # 80001ef8 <argraw>
    80002036:	e088                	sd	a0,0(s1)
  return 0;
}
    80002038:	4501                	li	a0,0
    8000203a:	60e2                	ld	ra,24(sp)
    8000203c:	6442                	ld	s0,16(sp)
    8000203e:	64a2                	ld	s1,8(sp)
    80002040:	6105                	addi	sp,sp,32
    80002042:	8082                	ret

0000000080002044 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002044:	1101                	addi	sp,sp,-32
    80002046:	ec06                	sd	ra,24(sp)
    80002048:	e822                	sd	s0,16(sp)
    8000204a:	e426                	sd	s1,8(sp)
    8000204c:	e04a                	sd	s2,0(sp)
    8000204e:	1000                	addi	s0,sp,32
    80002050:	84ae                	mv	s1,a1
    80002052:	8932                	mv	s2,a2
  *ip = argraw(n);
    80002054:	00000097          	auipc	ra,0x0
    80002058:	ea4080e7          	jalr	-348(ra) # 80001ef8 <argraw>
  uint64 addr;
  if(argaddr(n, &addr) < 0)
    return -1;
  return fetchstr(addr, buf, max);
    8000205c:	864a                	mv	a2,s2
    8000205e:	85a6                	mv	a1,s1
    80002060:	00000097          	auipc	ra,0x0
    80002064:	f58080e7          	jalr	-168(ra) # 80001fb8 <fetchstr>
}
    80002068:	60e2                	ld	ra,24(sp)
    8000206a:	6442                	ld	s0,16(sp)
    8000206c:	64a2                	ld	s1,8(sp)
    8000206e:	6902                	ld	s2,0(sp)
    80002070:	6105                	addi	sp,sp,32
    80002072:	8082                	ret

0000000080002074 <syscall>:



void
syscall(void)
{
    80002074:	1101                	addi	sp,sp,-32
    80002076:	ec06                	sd	ra,24(sp)
    80002078:	e822                	sd	s0,16(sp)
    8000207a:	e426                	sd	s1,8(sp)
    8000207c:	e04a                	sd	s2,0(sp)
    8000207e:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002080:	fffff097          	auipc	ra,0xfffff
    80002084:	e80080e7          	jalr	-384(ra) # 80000f00 <myproc>
    80002088:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000208a:	05853903          	ld	s2,88(a0)
    8000208e:	0a893783          	ld	a5,168(s2)
    80002092:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002096:	37fd                	addiw	a5,a5,-1
    80002098:	4771                	li	a4,28
    8000209a:	00f76f63          	bltu	a4,a5,800020b8 <syscall+0x44>
    8000209e:	00369713          	slli	a4,a3,0x3
    800020a2:	00007797          	auipc	a5,0x7
    800020a6:	2e678793          	addi	a5,a5,742 # 80009388 <syscalls>
    800020aa:	97ba                	add	a5,a5,a4
    800020ac:	639c                	ld	a5,0(a5)
    800020ae:	c789                	beqz	a5,800020b8 <syscall+0x44>
    p->trapframe->a0 = syscalls[num]();
    800020b0:	9782                	jalr	a5
    800020b2:	06a93823          	sd	a0,112(s2)
    800020b6:	a839                	j	800020d4 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800020b8:	15848613          	addi	a2,s1,344
    800020bc:	5c8c                	lw	a1,56(s1)
    800020be:	00007517          	auipc	a0,0x7
    800020c2:	3c250513          	addi	a0,a0,962 # 80009480 <syscalls+0xf8>
    800020c6:	00005097          	auipc	ra,0x5
    800020ca:	d0c080e7          	jalr	-756(ra) # 80006dd2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800020ce:	6cbc                	ld	a5,88(s1)
    800020d0:	577d                	li	a4,-1
    800020d2:	fbb8                	sd	a4,112(a5)
  }
}
    800020d4:	60e2                	ld	ra,24(sp)
    800020d6:	6442                	ld	s0,16(sp)
    800020d8:	64a2                	ld	s1,8(sp)
    800020da:	6902                	ld	s2,0(sp)
    800020dc:	6105                	addi	sp,sp,32
    800020de:	8082                	ret

00000000800020e0 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800020e0:	1101                	addi	sp,sp,-32
    800020e2:	ec06                	sd	ra,24(sp)
    800020e4:	e822                	sd	s0,16(sp)
    800020e6:	1000                	addi	s0,sp,32
  int n;
  if(argint(0, &n) < 0)
    800020e8:	fec40593          	addi	a1,s0,-20
    800020ec:	4501                	li	a0,0
    800020ee:	00000097          	auipc	ra,0x0
    800020f2:	f12080e7          	jalr	-238(ra) # 80002000 <argint>
    return -1;
    800020f6:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800020f8:	00054963          	bltz	a0,8000210a <sys_exit+0x2a>
  exit(n);
    800020fc:	fec42503          	lw	a0,-20(s0)
    80002100:	fffff097          	auipc	ra,0xfffff
    80002104:	4d2080e7          	jalr	1234(ra) # 800015d2 <exit>
  return 0;  // not reached
    80002108:	4781                	li	a5,0
}
    8000210a:	853e                	mv	a0,a5
    8000210c:	60e2                	ld	ra,24(sp)
    8000210e:	6442                	ld	s0,16(sp)
    80002110:	6105                	addi	sp,sp,32
    80002112:	8082                	ret

0000000080002114 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002114:	1141                	addi	sp,sp,-16
    80002116:	e406                	sd	ra,8(sp)
    80002118:	e022                	sd	s0,0(sp)
    8000211a:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000211c:	fffff097          	auipc	ra,0xfffff
    80002120:	de4080e7          	jalr	-540(ra) # 80000f00 <myproc>
}
    80002124:	5d08                	lw	a0,56(a0)
    80002126:	60a2                	ld	ra,8(sp)
    80002128:	6402                	ld	s0,0(sp)
    8000212a:	0141                	addi	sp,sp,16
    8000212c:	8082                	ret

000000008000212e <sys_fork>:

uint64
sys_fork(void)
{
    8000212e:	1141                	addi	sp,sp,-16
    80002130:	e406                	sd	ra,8(sp)
    80002132:	e022                	sd	s0,0(sp)
    80002134:	0800                	addi	s0,sp,16
  return fork();
    80002136:	fffff097          	auipc	ra,0xfffff
    8000213a:	190080e7          	jalr	400(ra) # 800012c6 <fork>
}
    8000213e:	60a2                	ld	ra,8(sp)
    80002140:	6402                	ld	s0,0(sp)
    80002142:	0141                	addi	sp,sp,16
    80002144:	8082                	ret

0000000080002146 <sys_wait>:

uint64
sys_wait(void)
{
    80002146:	1101                	addi	sp,sp,-32
    80002148:	ec06                	sd	ra,24(sp)
    8000214a:	e822                	sd	s0,16(sp)
    8000214c:	1000                	addi	s0,sp,32
  uint64 p;
  if(argaddr(0, &p) < 0)
    8000214e:	fe840593          	addi	a1,s0,-24
    80002152:	4501                	li	a0,0
    80002154:	00000097          	auipc	ra,0x0
    80002158:	ece080e7          	jalr	-306(ra) # 80002022 <argaddr>
    return -1;
    8000215c:	57fd                	li	a5,-1
  if(argaddr(0, &p) < 0)
    8000215e:	00054963          	bltz	a0,80002170 <sys_wait+0x2a>
  return wait(p);
    80002162:	fe843503          	ld	a0,-24(s0)
    80002166:	fffff097          	auipc	ra,0xfffff
    8000216a:	632080e7          	jalr	1586(ra) # 80001798 <wait>
    8000216e:	87aa                	mv	a5,a0
}
    80002170:	853e                	mv	a0,a5
    80002172:	60e2                	ld	ra,24(sp)
    80002174:	6442                	ld	s0,16(sp)
    80002176:	6105                	addi	sp,sp,32
    80002178:	8082                	ret

000000008000217a <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000217a:	7179                	addi	sp,sp,-48
    8000217c:	f406                	sd	ra,40(sp)
    8000217e:	f022                	sd	s0,32(sp)
    80002180:	ec26                	sd	s1,24(sp)
    80002182:	1800                	addi	s0,sp,48
  int addr;
  int n;

  if(argint(0, &n) < 0)
    80002184:	fdc40593          	addi	a1,s0,-36
    80002188:	4501                	li	a0,0
    8000218a:	00000097          	auipc	ra,0x0
    8000218e:	e76080e7          	jalr	-394(ra) # 80002000 <argint>
    return -1;
    80002192:	54fd                	li	s1,-1
  if(argint(0, &n) < 0)
    80002194:	00054f63          	bltz	a0,800021b2 <sys_sbrk+0x38>
  addr = myproc()->sz;
    80002198:	fffff097          	auipc	ra,0xfffff
    8000219c:	d68080e7          	jalr	-664(ra) # 80000f00 <myproc>
    800021a0:	4524                	lw	s1,72(a0)
  if(growproc(n) < 0)
    800021a2:	fdc42503          	lw	a0,-36(s0)
    800021a6:	fffff097          	auipc	ra,0xfffff
    800021aa:	0a8080e7          	jalr	168(ra) # 8000124e <growproc>
    800021ae:	00054863          	bltz	a0,800021be <sys_sbrk+0x44>
    return -1;
  return addr;
}
    800021b2:	8526                	mv	a0,s1
    800021b4:	70a2                	ld	ra,40(sp)
    800021b6:	7402                	ld	s0,32(sp)
    800021b8:	64e2                	ld	s1,24(sp)
    800021ba:	6145                	addi	sp,sp,48
    800021bc:	8082                	ret
    return -1;
    800021be:	54fd                	li	s1,-1
    800021c0:	bfcd                	j	800021b2 <sys_sbrk+0x38>

00000000800021c2 <sys_sleep>:

uint64
sys_sleep(void)
{
    800021c2:	7139                	addi	sp,sp,-64
    800021c4:	fc06                	sd	ra,56(sp)
    800021c6:	f822                	sd	s0,48(sp)
    800021c8:	f426                	sd	s1,40(sp)
    800021ca:	f04a                	sd	s2,32(sp)
    800021cc:	ec4e                	sd	s3,24(sp)
    800021ce:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
    800021d0:	fcc40593          	addi	a1,s0,-52
    800021d4:	4501                	li	a0,0
    800021d6:	00000097          	auipc	ra,0x0
    800021da:	e2a080e7          	jalr	-470(ra) # 80002000 <argint>
    return -1;
    800021de:	57fd                	li	a5,-1
  if(argint(0, &n) < 0)
    800021e0:	06054763          	bltz	a0,8000224e <sys_sleep+0x8c>
  acquire(&tickslock);
    800021e4:	0000e517          	auipc	a0,0xe
    800021e8:	ca450513          	addi	a0,a0,-860 # 8000fe88 <tickslock>
    800021ec:	00005097          	auipc	ra,0x5
    800021f0:	108080e7          	jalr	264(ra) # 800072f4 <acquire>
  ticks0 = ticks;
    800021f4:	00008797          	auipc	a5,0x8
    800021f8:	e2478793          	addi	a5,a5,-476 # 8000a018 <ticks>
    800021fc:	0007a903          	lw	s2,0(a5)
  while(ticks - ticks0 < n){
    80002200:	fcc42783          	lw	a5,-52(s0)
    80002204:	cf85                	beqz	a5,8000223c <sys_sleep+0x7a>
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002206:	0000e997          	auipc	s3,0xe
    8000220a:	c8298993          	addi	s3,s3,-894 # 8000fe88 <tickslock>
    8000220e:	00008497          	auipc	s1,0x8
    80002212:	e0a48493          	addi	s1,s1,-502 # 8000a018 <ticks>
    if(myproc()->killed){
    80002216:	fffff097          	auipc	ra,0xfffff
    8000221a:	cea080e7          	jalr	-790(ra) # 80000f00 <myproc>
    8000221e:	591c                	lw	a5,48(a0)
    80002220:	ef9d                	bnez	a5,8000225e <sys_sleep+0x9c>
    sleep(&ticks, &tickslock);
    80002222:	85ce                	mv	a1,s3
    80002224:	8526                	mv	a0,s1
    80002226:	fffff097          	auipc	ra,0xfffff
    8000222a:	4f4080e7          	jalr	1268(ra) # 8000171a <sleep>
  while(ticks - ticks0 < n){
    8000222e:	409c                	lw	a5,0(s1)
    80002230:	412787bb          	subw	a5,a5,s2
    80002234:	fcc42703          	lw	a4,-52(s0)
    80002238:	fce7efe3          	bltu	a5,a4,80002216 <sys_sleep+0x54>
  }
  release(&tickslock);
    8000223c:	0000e517          	auipc	a0,0xe
    80002240:	c4c50513          	addi	a0,a0,-948 # 8000fe88 <tickslock>
    80002244:	00005097          	auipc	ra,0x5
    80002248:	164080e7          	jalr	356(ra) # 800073a8 <release>
  return 0;
    8000224c:	4781                	li	a5,0
}
    8000224e:	853e                	mv	a0,a5
    80002250:	70e2                	ld	ra,56(sp)
    80002252:	7442                	ld	s0,48(sp)
    80002254:	74a2                	ld	s1,40(sp)
    80002256:	7902                	ld	s2,32(sp)
    80002258:	69e2                	ld	s3,24(sp)
    8000225a:	6121                	addi	sp,sp,64
    8000225c:	8082                	ret
      release(&tickslock);
    8000225e:	0000e517          	auipc	a0,0xe
    80002262:	c2a50513          	addi	a0,a0,-982 # 8000fe88 <tickslock>
    80002266:	00005097          	auipc	ra,0x5
    8000226a:	142080e7          	jalr	322(ra) # 800073a8 <release>
      return -1;
    8000226e:	57fd                	li	a5,-1
    80002270:	bff9                	j	8000224e <sys_sleep+0x8c>

0000000080002272 <sys_kill>:

uint64
sys_kill(void)
{
    80002272:	1101                	addi	sp,sp,-32
    80002274:	ec06                	sd	ra,24(sp)
    80002276:	e822                	sd	s0,16(sp)
    80002278:	1000                	addi	s0,sp,32
  int pid;

  if(argint(0, &pid) < 0)
    8000227a:	fec40593          	addi	a1,s0,-20
    8000227e:	4501                	li	a0,0
    80002280:	00000097          	auipc	ra,0x0
    80002284:	d80080e7          	jalr	-640(ra) # 80002000 <argint>
    return -1;
    80002288:	57fd                	li	a5,-1
  if(argint(0, &pid) < 0)
    8000228a:	00054963          	bltz	a0,8000229c <sys_kill+0x2a>
  return kill(pid);
    8000228e:	fec42503          	lw	a0,-20(s0)
    80002292:	fffff097          	auipc	ra,0xfffff
    80002296:	678080e7          	jalr	1656(ra) # 8000190a <kill>
    8000229a:	87aa                	mv	a5,a0
}
    8000229c:	853e                	mv	a0,a5
    8000229e:	60e2                	ld	ra,24(sp)
    800022a0:	6442                	ld	s0,16(sp)
    800022a2:	6105                	addi	sp,sp,32
    800022a4:	8082                	ret

00000000800022a6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    800022a6:	1101                	addi	sp,sp,-32
    800022a8:	ec06                	sd	ra,24(sp)
    800022aa:	e822                	sd	s0,16(sp)
    800022ac:	e426                	sd	s1,8(sp)
    800022ae:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    800022b0:	0000e517          	auipc	a0,0xe
    800022b4:	bd850513          	addi	a0,a0,-1064 # 8000fe88 <tickslock>
    800022b8:	00005097          	auipc	ra,0x5
    800022bc:	03c080e7          	jalr	60(ra) # 800072f4 <acquire>
  xticks = ticks;
    800022c0:	00008797          	auipc	a5,0x8
    800022c4:	d5878793          	addi	a5,a5,-680 # 8000a018 <ticks>
    800022c8:	4384                	lw	s1,0(a5)
  release(&tickslock);
    800022ca:	0000e517          	auipc	a0,0xe
    800022ce:	bbe50513          	addi	a0,a0,-1090 # 8000fe88 <tickslock>
    800022d2:	00005097          	auipc	ra,0x5
    800022d6:	0d6080e7          	jalr	214(ra) # 800073a8 <release>
  return xticks;
}
    800022da:	02049513          	slli	a0,s1,0x20
    800022de:	9101                	srli	a0,a0,0x20
    800022e0:	60e2                	ld	ra,24(sp)
    800022e2:	6442                	ld	s0,16(sp)
    800022e4:	64a2                	ld	s1,8(sp)
    800022e6:	6105                	addi	sp,sp,32
    800022e8:	8082                	ret

00000000800022ea <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    800022ea:	7179                	addi	sp,sp,-48
    800022ec:	f406                	sd	ra,40(sp)
    800022ee:	f022                	sd	s0,32(sp)
    800022f0:	ec26                	sd	s1,24(sp)
    800022f2:	e84a                	sd	s2,16(sp)
    800022f4:	e44e                	sd	s3,8(sp)
    800022f6:	e052                	sd	s4,0(sp)
    800022f8:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    800022fa:	00007597          	auipc	a1,0x7
    800022fe:	1a658593          	addi	a1,a1,422 # 800094a0 <syscalls+0x118>
    80002302:	0000e517          	auipc	a0,0xe
    80002306:	b9e50513          	addi	a0,a0,-1122 # 8000fea0 <bcache>
    8000230a:	00005097          	auipc	ra,0x5
    8000230e:	f5a080e7          	jalr	-166(ra) # 80007264 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002312:	00016797          	auipc	a5,0x16
    80002316:	b8e78793          	addi	a5,a5,-1138 # 80017ea0 <bcache+0x8000>
    8000231a:	00016717          	auipc	a4,0x16
    8000231e:	dee70713          	addi	a4,a4,-530 # 80018108 <bcache+0x8268>
    80002322:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002326:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    8000232a:	0000e497          	auipc	s1,0xe
    8000232e:	b8e48493          	addi	s1,s1,-1138 # 8000feb8 <bcache+0x18>
    b->next = bcache.head.next;
    80002332:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002334:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002336:	00007a17          	auipc	s4,0x7
    8000233a:	172a0a13          	addi	s4,s4,370 # 800094a8 <syscalls+0x120>
    b->next = bcache.head.next;
    8000233e:	2b893783          	ld	a5,696(s2)
    80002342:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002344:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002348:	85d2                	mv	a1,s4
    8000234a:	01048513          	addi	a0,s1,16
    8000234e:	00001097          	auipc	ra,0x1
    80002352:	532080e7          	jalr	1330(ra) # 80003880 <initsleeplock>
    bcache.head.next->prev = b;
    80002356:	2b893783          	ld	a5,696(s2)
    8000235a:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    8000235c:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002360:	45848493          	addi	s1,s1,1112
    80002364:	fd349de3          	bne	s1,s3,8000233e <binit+0x54>
  }
}
    80002368:	70a2                	ld	ra,40(sp)
    8000236a:	7402                	ld	s0,32(sp)
    8000236c:	64e2                	ld	s1,24(sp)
    8000236e:	6942                	ld	s2,16(sp)
    80002370:	69a2                	ld	s3,8(sp)
    80002372:	6a02                	ld	s4,0(sp)
    80002374:	6145                	addi	sp,sp,48
    80002376:	8082                	ret

0000000080002378 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002378:	7179                	addi	sp,sp,-48
    8000237a:	f406                	sd	ra,40(sp)
    8000237c:	f022                	sd	s0,32(sp)
    8000237e:	ec26                	sd	s1,24(sp)
    80002380:	e84a                	sd	s2,16(sp)
    80002382:	e44e                	sd	s3,8(sp)
    80002384:	1800                	addi	s0,sp,48
    80002386:	89aa                	mv	s3,a0
    80002388:	892e                	mv	s2,a1
  acquire(&bcache.lock);
    8000238a:	0000e517          	auipc	a0,0xe
    8000238e:	b1650513          	addi	a0,a0,-1258 # 8000fea0 <bcache>
    80002392:	00005097          	auipc	ra,0x5
    80002396:	f62080e7          	jalr	-158(ra) # 800072f4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    8000239a:	00016797          	auipc	a5,0x16
    8000239e:	b0678793          	addi	a5,a5,-1274 # 80017ea0 <bcache+0x8000>
    800023a2:	2b87b483          	ld	s1,696(a5)
    800023a6:	00016797          	auipc	a5,0x16
    800023aa:	d6278793          	addi	a5,a5,-670 # 80018108 <bcache+0x8268>
    800023ae:	02f48f63          	beq	s1,a5,800023ec <bread+0x74>
    800023b2:	873e                	mv	a4,a5
    800023b4:	a021                	j	800023bc <bread+0x44>
    800023b6:	68a4                	ld	s1,80(s1)
    800023b8:	02e48a63          	beq	s1,a4,800023ec <bread+0x74>
    if(b->dev == dev && b->blockno == blockno){
    800023bc:	449c                	lw	a5,8(s1)
    800023be:	ff379ce3          	bne	a5,s3,800023b6 <bread+0x3e>
    800023c2:	44dc                	lw	a5,12(s1)
    800023c4:	ff2799e3          	bne	a5,s2,800023b6 <bread+0x3e>
      b->refcnt++;
    800023c8:	40bc                	lw	a5,64(s1)
    800023ca:	2785                	addiw	a5,a5,1
    800023cc:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800023ce:	0000e517          	auipc	a0,0xe
    800023d2:	ad250513          	addi	a0,a0,-1326 # 8000fea0 <bcache>
    800023d6:	00005097          	auipc	ra,0x5
    800023da:	fd2080e7          	jalr	-46(ra) # 800073a8 <release>
      acquiresleep(&b->lock);
    800023de:	01048513          	addi	a0,s1,16
    800023e2:	00001097          	auipc	ra,0x1
    800023e6:	4d8080e7          	jalr	1240(ra) # 800038ba <acquiresleep>
      return b;
    800023ea:	a8b1                	j	80002446 <bread+0xce>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    800023ec:	00016797          	auipc	a5,0x16
    800023f0:	ab478793          	addi	a5,a5,-1356 # 80017ea0 <bcache+0x8000>
    800023f4:	2b07b483          	ld	s1,688(a5)
    800023f8:	00016797          	auipc	a5,0x16
    800023fc:	d1078793          	addi	a5,a5,-752 # 80018108 <bcache+0x8268>
    80002400:	04f48d63          	beq	s1,a5,8000245a <bread+0xe2>
    if(b->refcnt == 0) {
    80002404:	40bc                	lw	a5,64(s1)
    80002406:	cb91                	beqz	a5,8000241a <bread+0xa2>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002408:	00016717          	auipc	a4,0x16
    8000240c:	d0070713          	addi	a4,a4,-768 # 80018108 <bcache+0x8268>
    80002410:	64a4                	ld	s1,72(s1)
    80002412:	04e48463          	beq	s1,a4,8000245a <bread+0xe2>
    if(b->refcnt == 0) {
    80002416:	40bc                	lw	a5,64(s1)
    80002418:	ffe5                	bnez	a5,80002410 <bread+0x98>
      b->dev = dev;
    8000241a:	0134a423          	sw	s3,8(s1)
      b->blockno = blockno;
    8000241e:	0124a623          	sw	s2,12(s1)
      b->valid = 0;
    80002422:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002426:	4785                	li	a5,1
    80002428:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    8000242a:	0000e517          	auipc	a0,0xe
    8000242e:	a7650513          	addi	a0,a0,-1418 # 8000fea0 <bcache>
    80002432:	00005097          	auipc	ra,0x5
    80002436:	f76080e7          	jalr	-138(ra) # 800073a8 <release>
      acquiresleep(&b->lock);
    8000243a:	01048513          	addi	a0,s1,16
    8000243e:	00001097          	auipc	ra,0x1
    80002442:	47c080e7          	jalr	1148(ra) # 800038ba <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002446:	409c                	lw	a5,0(s1)
    80002448:	c38d                	beqz	a5,8000246a <bread+0xf2>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    8000244a:	8526                	mv	a0,s1
    8000244c:	70a2                	ld	ra,40(sp)
    8000244e:	7402                	ld	s0,32(sp)
    80002450:	64e2                	ld	s1,24(sp)
    80002452:	6942                	ld	s2,16(sp)
    80002454:	69a2                	ld	s3,8(sp)
    80002456:	6145                	addi	sp,sp,48
    80002458:	8082                	ret
  panic("bget: no buffers");
    8000245a:	00007517          	auipc	a0,0x7
    8000245e:	05650513          	addi	a0,a0,86 # 800094b0 <syscalls+0x128>
    80002462:	00005097          	auipc	ra,0x5
    80002466:	926080e7          	jalr	-1754(ra) # 80006d88 <panic>
    virtio_disk_rw(b, 0);
    8000246a:	4581                	li	a1,0
    8000246c:	8526                	mv	a0,s1
    8000246e:	00003097          	auipc	ra,0x3
    80002472:	0c2080e7          	jalr	194(ra) # 80005530 <virtio_disk_rw>
    b->valid = 1;
    80002476:	4785                	li	a5,1
    80002478:	c09c                	sw	a5,0(s1)
  return b;
    8000247a:	bfc1                	j	8000244a <bread+0xd2>

000000008000247c <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    8000247c:	1101                	addi	sp,sp,-32
    8000247e:	ec06                	sd	ra,24(sp)
    80002480:	e822                	sd	s0,16(sp)
    80002482:	e426                	sd	s1,8(sp)
    80002484:	1000                	addi	s0,sp,32
    80002486:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002488:	0541                	addi	a0,a0,16
    8000248a:	00001097          	auipc	ra,0x1
    8000248e:	4ca080e7          	jalr	1226(ra) # 80003954 <holdingsleep>
    80002492:	cd01                	beqz	a0,800024aa <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002494:	4585                	li	a1,1
    80002496:	8526                	mv	a0,s1
    80002498:	00003097          	auipc	ra,0x3
    8000249c:	098080e7          	jalr	152(ra) # 80005530 <virtio_disk_rw>
}
    800024a0:	60e2                	ld	ra,24(sp)
    800024a2:	6442                	ld	s0,16(sp)
    800024a4:	64a2                	ld	s1,8(sp)
    800024a6:	6105                	addi	sp,sp,32
    800024a8:	8082                	ret
    panic("bwrite");
    800024aa:	00007517          	auipc	a0,0x7
    800024ae:	01e50513          	addi	a0,a0,30 # 800094c8 <syscalls+0x140>
    800024b2:	00005097          	auipc	ra,0x5
    800024b6:	8d6080e7          	jalr	-1834(ra) # 80006d88 <panic>

00000000800024ba <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    800024ba:	1101                	addi	sp,sp,-32
    800024bc:	ec06                	sd	ra,24(sp)
    800024be:	e822                	sd	s0,16(sp)
    800024c0:	e426                	sd	s1,8(sp)
    800024c2:	e04a                	sd	s2,0(sp)
    800024c4:	1000                	addi	s0,sp,32
    800024c6:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    800024c8:	01050913          	addi	s2,a0,16
    800024cc:	854a                	mv	a0,s2
    800024ce:	00001097          	auipc	ra,0x1
    800024d2:	486080e7          	jalr	1158(ra) # 80003954 <holdingsleep>
    800024d6:	c92d                	beqz	a0,80002548 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    800024d8:	854a                	mv	a0,s2
    800024da:	00001097          	auipc	ra,0x1
    800024de:	436080e7          	jalr	1078(ra) # 80003910 <releasesleep>

  acquire(&bcache.lock);
    800024e2:	0000e517          	auipc	a0,0xe
    800024e6:	9be50513          	addi	a0,a0,-1602 # 8000fea0 <bcache>
    800024ea:	00005097          	auipc	ra,0x5
    800024ee:	e0a080e7          	jalr	-502(ra) # 800072f4 <acquire>
  b->refcnt--;
    800024f2:	40bc                	lw	a5,64(s1)
    800024f4:	37fd                	addiw	a5,a5,-1
    800024f6:	0007871b          	sext.w	a4,a5
    800024fa:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    800024fc:	eb05                	bnez	a4,8000252c <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    800024fe:	68bc                	ld	a5,80(s1)
    80002500:	64b8                	ld	a4,72(s1)
    80002502:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80002504:	64bc                	ld	a5,72(s1)
    80002506:	68b8                	ld	a4,80(s1)
    80002508:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    8000250a:	00016797          	auipc	a5,0x16
    8000250e:	99678793          	addi	a5,a5,-1642 # 80017ea0 <bcache+0x8000>
    80002512:	2b87b703          	ld	a4,696(a5)
    80002516:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002518:	00016717          	auipc	a4,0x16
    8000251c:	bf070713          	addi	a4,a4,-1040 # 80018108 <bcache+0x8268>
    80002520:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002522:	2b87b703          	ld	a4,696(a5)
    80002526:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002528:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    8000252c:	0000e517          	auipc	a0,0xe
    80002530:	97450513          	addi	a0,a0,-1676 # 8000fea0 <bcache>
    80002534:	00005097          	auipc	ra,0x5
    80002538:	e74080e7          	jalr	-396(ra) # 800073a8 <release>
}
    8000253c:	60e2                	ld	ra,24(sp)
    8000253e:	6442                	ld	s0,16(sp)
    80002540:	64a2                	ld	s1,8(sp)
    80002542:	6902                	ld	s2,0(sp)
    80002544:	6105                	addi	sp,sp,32
    80002546:	8082                	ret
    panic("brelse");
    80002548:	00007517          	auipc	a0,0x7
    8000254c:	f8850513          	addi	a0,a0,-120 # 800094d0 <syscalls+0x148>
    80002550:	00005097          	auipc	ra,0x5
    80002554:	838080e7          	jalr	-1992(ra) # 80006d88 <panic>

0000000080002558 <bpin>:

void
bpin(struct buf *b) {
    80002558:	1101                	addi	sp,sp,-32
    8000255a:	ec06                	sd	ra,24(sp)
    8000255c:	e822                	sd	s0,16(sp)
    8000255e:	e426                	sd	s1,8(sp)
    80002560:	1000                	addi	s0,sp,32
    80002562:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002564:	0000e517          	auipc	a0,0xe
    80002568:	93c50513          	addi	a0,a0,-1732 # 8000fea0 <bcache>
    8000256c:	00005097          	auipc	ra,0x5
    80002570:	d88080e7          	jalr	-632(ra) # 800072f4 <acquire>
  b->refcnt++;
    80002574:	40bc                	lw	a5,64(s1)
    80002576:	2785                	addiw	a5,a5,1
    80002578:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    8000257a:	0000e517          	auipc	a0,0xe
    8000257e:	92650513          	addi	a0,a0,-1754 # 8000fea0 <bcache>
    80002582:	00005097          	auipc	ra,0x5
    80002586:	e26080e7          	jalr	-474(ra) # 800073a8 <release>
}
    8000258a:	60e2                	ld	ra,24(sp)
    8000258c:	6442                	ld	s0,16(sp)
    8000258e:	64a2                	ld	s1,8(sp)
    80002590:	6105                	addi	sp,sp,32
    80002592:	8082                	ret

0000000080002594 <bunpin>:

void
bunpin(struct buf *b) {
    80002594:	1101                	addi	sp,sp,-32
    80002596:	ec06                	sd	ra,24(sp)
    80002598:	e822                	sd	s0,16(sp)
    8000259a:	e426                	sd	s1,8(sp)
    8000259c:	1000                	addi	s0,sp,32
    8000259e:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800025a0:	0000e517          	auipc	a0,0xe
    800025a4:	90050513          	addi	a0,a0,-1792 # 8000fea0 <bcache>
    800025a8:	00005097          	auipc	ra,0x5
    800025ac:	d4c080e7          	jalr	-692(ra) # 800072f4 <acquire>
  b->refcnt--;
    800025b0:	40bc                	lw	a5,64(s1)
    800025b2:	37fd                	addiw	a5,a5,-1
    800025b4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800025b6:	0000e517          	auipc	a0,0xe
    800025ba:	8ea50513          	addi	a0,a0,-1814 # 8000fea0 <bcache>
    800025be:	00005097          	auipc	ra,0x5
    800025c2:	dea080e7          	jalr	-534(ra) # 800073a8 <release>
}
    800025c6:	60e2                	ld	ra,24(sp)
    800025c8:	6442                	ld	s0,16(sp)
    800025ca:	64a2                	ld	s1,8(sp)
    800025cc:	6105                	addi	sp,sp,32
    800025ce:	8082                	ret

00000000800025d0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    800025d0:	1101                	addi	sp,sp,-32
    800025d2:	ec06                	sd	ra,24(sp)
    800025d4:	e822                	sd	s0,16(sp)
    800025d6:	e426                	sd	s1,8(sp)
    800025d8:	e04a                	sd	s2,0(sp)
    800025da:	1000                	addi	s0,sp,32
    800025dc:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    800025de:	00d5d59b          	srliw	a1,a1,0xd
    800025e2:	00016797          	auipc	a5,0x16
    800025e6:	f7e78793          	addi	a5,a5,-130 # 80018560 <sb>
    800025ea:	4fdc                	lw	a5,28(a5)
    800025ec:	9dbd                	addw	a1,a1,a5
    800025ee:	00000097          	auipc	ra,0x0
    800025f2:	d8a080e7          	jalr	-630(ra) # 80002378 <bread>
  bi = b % BPB;
    800025f6:	2481                	sext.w	s1,s1
  m = 1 << (bi % 8);
    800025f8:	0074f793          	andi	a5,s1,7
    800025fc:	4705                	li	a4,1
    800025fe:	00f7173b          	sllw	a4,a4,a5
  bi = b % BPB;
    80002602:	6789                	lui	a5,0x2
    80002604:	17fd                	addi	a5,a5,-1
    80002606:	8cfd                	and	s1,s1,a5
  if((bp->data[bi/8] & m) == 0)
    80002608:	41f4d79b          	sraiw	a5,s1,0x1f
    8000260c:	01d7d79b          	srliw	a5,a5,0x1d
    80002610:	9fa5                	addw	a5,a5,s1
    80002612:	4037d79b          	sraiw	a5,a5,0x3
    80002616:	00f506b3          	add	a3,a0,a5
    8000261a:	0586c683          	lbu	a3,88(a3)
    8000261e:	00d77633          	and	a2,a4,a3
    80002622:	c61d                	beqz	a2,80002650 <bfree+0x80>
    80002624:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002626:	97aa                	add	a5,a5,a0
    80002628:	fff74713          	not	a4,a4
    8000262c:	8f75                	and	a4,a4,a3
    8000262e:	04e78c23          	sb	a4,88(a5) # 2058 <_entry-0x7fffdfa8>
  log_write(bp);
    80002632:	00001097          	auipc	ra,0x1
    80002636:	14a080e7          	jalr	330(ra) # 8000377c <log_write>
  brelse(bp);
    8000263a:	854a                	mv	a0,s2
    8000263c:	00000097          	auipc	ra,0x0
    80002640:	e7e080e7          	jalr	-386(ra) # 800024ba <brelse>
}
    80002644:	60e2                	ld	ra,24(sp)
    80002646:	6442                	ld	s0,16(sp)
    80002648:	64a2                	ld	s1,8(sp)
    8000264a:	6902                	ld	s2,0(sp)
    8000264c:	6105                	addi	sp,sp,32
    8000264e:	8082                	ret
    panic("freeing free block");
    80002650:	00007517          	auipc	a0,0x7
    80002654:	e8850513          	addi	a0,a0,-376 # 800094d8 <syscalls+0x150>
    80002658:	00004097          	auipc	ra,0x4
    8000265c:	730080e7          	jalr	1840(ra) # 80006d88 <panic>

0000000080002660 <balloc>:
{
    80002660:	711d                	addi	sp,sp,-96
    80002662:	ec86                	sd	ra,88(sp)
    80002664:	e8a2                	sd	s0,80(sp)
    80002666:	e4a6                	sd	s1,72(sp)
    80002668:	e0ca                	sd	s2,64(sp)
    8000266a:	fc4e                	sd	s3,56(sp)
    8000266c:	f852                	sd	s4,48(sp)
    8000266e:	f456                	sd	s5,40(sp)
    80002670:	f05a                	sd	s6,32(sp)
    80002672:	ec5e                	sd	s7,24(sp)
    80002674:	e862                	sd	s8,16(sp)
    80002676:	e466                	sd	s9,8(sp)
    80002678:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    8000267a:	00016797          	auipc	a5,0x16
    8000267e:	ee678793          	addi	a5,a5,-282 # 80018560 <sb>
    80002682:	43dc                	lw	a5,4(a5)
    80002684:	10078e63          	beqz	a5,800027a0 <balloc+0x140>
    80002688:	8baa                	mv	s7,a0
    8000268a:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    8000268c:	00016b17          	auipc	s6,0x16
    80002690:	ed4b0b13          	addi	s6,s6,-300 # 80018560 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002694:	4c05                	li	s8,1
      m = 1 << (bi % 8);
    80002696:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002698:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    8000269a:	6c89                	lui	s9,0x2
    8000269c:	a079                	j	8000272a <balloc+0xca>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000269e:	8942                	mv	s2,a6
      m = 1 << (bi % 8);
    800026a0:	4705                	li	a4,1
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800026a2:	4681                	li	a3,0
        bp->data[bi/8] |= m;  // Mark block in use.
    800026a4:	96a6                	add	a3,a3,s1
    800026a6:	8f51                	or	a4,a4,a2
    800026a8:	04e68c23          	sb	a4,88(a3)
        log_write(bp);
    800026ac:	8526                	mv	a0,s1
    800026ae:	00001097          	auipc	ra,0x1
    800026b2:	0ce080e7          	jalr	206(ra) # 8000377c <log_write>
        brelse(bp);
    800026b6:	8526                	mv	a0,s1
    800026b8:	00000097          	auipc	ra,0x0
    800026bc:	e02080e7          	jalr	-510(ra) # 800024ba <brelse>
  bp = bread(dev, bno);
    800026c0:	85ca                	mv	a1,s2
    800026c2:	855e                	mv	a0,s7
    800026c4:	00000097          	auipc	ra,0x0
    800026c8:	cb4080e7          	jalr	-844(ra) # 80002378 <bread>
    800026cc:	84aa                	mv	s1,a0
  memset(bp->data, 0, BSIZE);
    800026ce:	40000613          	li	a2,1024
    800026d2:	4581                	li	a1,0
    800026d4:	05850513          	addi	a0,a0,88
    800026d8:	ffffe097          	auipc	ra,0xffffe
    800026dc:	aa4080e7          	jalr	-1372(ra) # 8000017c <memset>
  log_write(bp);
    800026e0:	8526                	mv	a0,s1
    800026e2:	00001097          	auipc	ra,0x1
    800026e6:	09a080e7          	jalr	154(ra) # 8000377c <log_write>
  brelse(bp);
    800026ea:	8526                	mv	a0,s1
    800026ec:	00000097          	auipc	ra,0x0
    800026f0:	dce080e7          	jalr	-562(ra) # 800024ba <brelse>
}
    800026f4:	854a                	mv	a0,s2
    800026f6:	60e6                	ld	ra,88(sp)
    800026f8:	6446                	ld	s0,80(sp)
    800026fa:	64a6                	ld	s1,72(sp)
    800026fc:	6906                	ld	s2,64(sp)
    800026fe:	79e2                	ld	s3,56(sp)
    80002700:	7a42                	ld	s4,48(sp)
    80002702:	7aa2                	ld	s5,40(sp)
    80002704:	7b02                	ld	s6,32(sp)
    80002706:	6be2                	ld	s7,24(sp)
    80002708:	6c42                	ld	s8,16(sp)
    8000270a:	6ca2                	ld	s9,8(sp)
    8000270c:	6125                	addi	sp,sp,96
    8000270e:	8082                	ret
    brelse(bp);
    80002710:	8526                	mv	a0,s1
    80002712:	00000097          	auipc	ra,0x0
    80002716:	da8080e7          	jalr	-600(ra) # 800024ba <brelse>
  for(b = 0; b < sb.size; b += BPB){
    8000271a:	015c87bb          	addw	a5,s9,s5
    8000271e:	00078a9b          	sext.w	s5,a5
    80002722:	004b2703          	lw	a4,4(s6)
    80002726:	06eafd63          	bleu	a4,s5,800027a0 <balloc+0x140>
    bp = bread(dev, BBLOCK(b, sb));
    8000272a:	41fad79b          	sraiw	a5,s5,0x1f
    8000272e:	0137d79b          	srliw	a5,a5,0x13
    80002732:	015787bb          	addw	a5,a5,s5
    80002736:	40d7d79b          	sraiw	a5,a5,0xd
    8000273a:	01cb2583          	lw	a1,28(s6)
    8000273e:	9dbd                	addw	a1,a1,a5
    80002740:	855e                	mv	a0,s7
    80002742:	00000097          	auipc	ra,0x0
    80002746:	c36080e7          	jalr	-970(ra) # 80002378 <bread>
    8000274a:	84aa                	mv	s1,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    8000274c:	000a881b          	sext.w	a6,s5
    80002750:	004b2503          	lw	a0,4(s6)
    80002754:	faa87ee3          	bleu	a0,a6,80002710 <balloc+0xb0>
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002758:	0584c603          	lbu	a2,88(s1)
    8000275c:	00167793          	andi	a5,a2,1
    80002760:	df9d                	beqz	a5,8000269e <balloc+0x3e>
    80002762:	4105053b          	subw	a0,a0,a6
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002766:	87e2                	mv	a5,s8
    80002768:	0107893b          	addw	s2,a5,a6
    8000276c:	faa782e3          	beq	a5,a0,80002710 <balloc+0xb0>
      m = 1 << (bi % 8);
    80002770:	41f7d71b          	sraiw	a4,a5,0x1f
    80002774:	01d7561b          	srliw	a2,a4,0x1d
    80002778:	00f606bb          	addw	a3,a2,a5
    8000277c:	0076f713          	andi	a4,a3,7
    80002780:	9f11                	subw	a4,a4,a2
    80002782:	00e9973b          	sllw	a4,s3,a4
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002786:	4036d69b          	sraiw	a3,a3,0x3
    8000278a:	00d48633          	add	a2,s1,a3
    8000278e:	05864603          	lbu	a2,88(a2)
    80002792:	00c775b3          	and	a1,a4,a2
    80002796:	d599                	beqz	a1,800026a4 <balloc+0x44>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002798:	2785                	addiw	a5,a5,1
    8000279a:	fd4797e3          	bne	a5,s4,80002768 <balloc+0x108>
    8000279e:	bf8d                	j	80002710 <balloc+0xb0>
  panic("balloc: out of blocks");
    800027a0:	00007517          	auipc	a0,0x7
    800027a4:	d5050513          	addi	a0,a0,-688 # 800094f0 <syscalls+0x168>
    800027a8:	00004097          	auipc	ra,0x4
    800027ac:	5e0080e7          	jalr	1504(ra) # 80006d88 <panic>

00000000800027b0 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
    800027b0:	7179                	addi	sp,sp,-48
    800027b2:	f406                	sd	ra,40(sp)
    800027b4:	f022                	sd	s0,32(sp)
    800027b6:	ec26                	sd	s1,24(sp)
    800027b8:	e84a                	sd	s2,16(sp)
    800027ba:	e44e                	sd	s3,8(sp)
    800027bc:	e052                	sd	s4,0(sp)
    800027be:	1800                	addi	s0,sp,48
    800027c0:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    800027c2:	47ad                	li	a5,11
    800027c4:	04b7fe63          	bleu	a1,a5,80002820 <bmap+0x70>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
    800027c8:	ff45849b          	addiw	s1,a1,-12
    800027cc:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    800027d0:	0ff00793          	li	a5,255
    800027d4:	0ae7e363          	bltu	a5,a4,8000287a <bmap+0xca>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
    800027d8:	08052583          	lw	a1,128(a0)
    800027dc:	c5ad                	beqz	a1,80002846 <bmap+0x96>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
    800027de:	0009a503          	lw	a0,0(s3)
    800027e2:	00000097          	auipc	ra,0x0
    800027e6:	b96080e7          	jalr	-1130(ra) # 80002378 <bread>
    800027ea:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    800027ec:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    800027f0:	02049593          	slli	a1,s1,0x20
    800027f4:	9181                	srli	a1,a1,0x20
    800027f6:	058a                	slli	a1,a1,0x2
    800027f8:	00b784b3          	add	s1,a5,a1
    800027fc:	0004a903          	lw	s2,0(s1)
    80002800:	04090d63          	beqz	s2,8000285a <bmap+0xaa>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
    80002804:	8552                	mv	a0,s4
    80002806:	00000097          	auipc	ra,0x0
    8000280a:	cb4080e7          	jalr	-844(ra) # 800024ba <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000280e:	854a                	mv	a0,s2
    80002810:	70a2                	ld	ra,40(sp)
    80002812:	7402                	ld	s0,32(sp)
    80002814:	64e2                	ld	s1,24(sp)
    80002816:	6942                	ld	s2,16(sp)
    80002818:	69a2                	ld	s3,8(sp)
    8000281a:	6a02                	ld	s4,0(sp)
    8000281c:	6145                	addi	sp,sp,48
    8000281e:	8082                	ret
    if((addr = ip->addrs[bn]) == 0)
    80002820:	02059493          	slli	s1,a1,0x20
    80002824:	9081                	srli	s1,s1,0x20
    80002826:	048a                	slli	s1,s1,0x2
    80002828:	94aa                	add	s1,s1,a0
    8000282a:	0504a903          	lw	s2,80(s1)
    8000282e:	fe0910e3          	bnez	s2,8000280e <bmap+0x5e>
      ip->addrs[bn] = addr = balloc(ip->dev);
    80002832:	4108                	lw	a0,0(a0)
    80002834:	00000097          	auipc	ra,0x0
    80002838:	e2c080e7          	jalr	-468(ra) # 80002660 <balloc>
    8000283c:	0005091b          	sext.w	s2,a0
    80002840:	0524a823          	sw	s2,80(s1)
    80002844:	b7e9                	j	8000280e <bmap+0x5e>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    80002846:	4108                	lw	a0,0(a0)
    80002848:	00000097          	auipc	ra,0x0
    8000284c:	e18080e7          	jalr	-488(ra) # 80002660 <balloc>
    80002850:	0005059b          	sext.w	a1,a0
    80002854:	08b9a023          	sw	a1,128(s3)
    80002858:	b759                	j	800027de <bmap+0x2e>
      a[bn] = addr = balloc(ip->dev);
    8000285a:	0009a503          	lw	a0,0(s3)
    8000285e:	00000097          	auipc	ra,0x0
    80002862:	e02080e7          	jalr	-510(ra) # 80002660 <balloc>
    80002866:	0005091b          	sext.w	s2,a0
    8000286a:	0124a023          	sw	s2,0(s1)
      log_write(bp);
    8000286e:	8552                	mv	a0,s4
    80002870:	00001097          	auipc	ra,0x1
    80002874:	f0c080e7          	jalr	-244(ra) # 8000377c <log_write>
    80002878:	b771                	j	80002804 <bmap+0x54>
  panic("bmap: out of range");
    8000287a:	00007517          	auipc	a0,0x7
    8000287e:	c8e50513          	addi	a0,a0,-882 # 80009508 <syscalls+0x180>
    80002882:	00004097          	auipc	ra,0x4
    80002886:	506080e7          	jalr	1286(ra) # 80006d88 <panic>

000000008000288a <iget>:
{
    8000288a:	7179                	addi	sp,sp,-48
    8000288c:	f406                	sd	ra,40(sp)
    8000288e:	f022                	sd	s0,32(sp)
    80002890:	ec26                	sd	s1,24(sp)
    80002892:	e84a                	sd	s2,16(sp)
    80002894:	e44e                	sd	s3,8(sp)
    80002896:	e052                	sd	s4,0(sp)
    80002898:	1800                	addi	s0,sp,48
    8000289a:	89aa                	mv	s3,a0
    8000289c:	8a2e                	mv	s4,a1
  acquire(&icache.lock);
    8000289e:	00016517          	auipc	a0,0x16
    800028a2:	ce250513          	addi	a0,a0,-798 # 80018580 <icache>
    800028a6:	00005097          	auipc	ra,0x5
    800028aa:	a4e080e7          	jalr	-1458(ra) # 800072f4 <acquire>
  empty = 0;
    800028ae:	4901                	li	s2,0
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800028b0:	00016497          	auipc	s1,0x16
    800028b4:	ce848493          	addi	s1,s1,-792 # 80018598 <icache+0x18>
    800028b8:	00017697          	auipc	a3,0x17
    800028bc:	77068693          	addi	a3,a3,1904 # 8001a028 <log>
    800028c0:	a039                	j	800028ce <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800028c2:	02090b63          	beqz	s2,800028f8 <iget+0x6e>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
    800028c6:	08848493          	addi	s1,s1,136
    800028ca:	02d48a63          	beq	s1,a3,800028fe <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    800028ce:	449c                	lw	a5,8(s1)
    800028d0:	fef059e3          	blez	a5,800028c2 <iget+0x38>
    800028d4:	4098                	lw	a4,0(s1)
    800028d6:	ff3716e3          	bne	a4,s3,800028c2 <iget+0x38>
    800028da:	40d8                	lw	a4,4(s1)
    800028dc:	ff4713e3          	bne	a4,s4,800028c2 <iget+0x38>
      ip->ref++;
    800028e0:	2785                	addiw	a5,a5,1
    800028e2:	c49c                	sw	a5,8(s1)
      release(&icache.lock);
    800028e4:	00016517          	auipc	a0,0x16
    800028e8:	c9c50513          	addi	a0,a0,-868 # 80018580 <icache>
    800028ec:	00005097          	auipc	ra,0x5
    800028f0:	abc080e7          	jalr	-1348(ra) # 800073a8 <release>
      return ip;
    800028f4:	8926                	mv	s2,s1
    800028f6:	a03d                	j	80002924 <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    800028f8:	f7f9                	bnez	a5,800028c6 <iget+0x3c>
    800028fa:	8926                	mv	s2,s1
    800028fc:	b7e9                	j	800028c6 <iget+0x3c>
  if(empty == 0)
    800028fe:	02090c63          	beqz	s2,80002936 <iget+0xac>
  ip->dev = dev;
    80002902:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80002906:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000290a:	4785                	li	a5,1
    8000290c:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80002910:	04092023          	sw	zero,64(s2)
  release(&icache.lock);
    80002914:	00016517          	auipc	a0,0x16
    80002918:	c6c50513          	addi	a0,a0,-916 # 80018580 <icache>
    8000291c:	00005097          	auipc	ra,0x5
    80002920:	a8c080e7          	jalr	-1396(ra) # 800073a8 <release>
}
    80002924:	854a                	mv	a0,s2
    80002926:	70a2                	ld	ra,40(sp)
    80002928:	7402                	ld	s0,32(sp)
    8000292a:	64e2                	ld	s1,24(sp)
    8000292c:	6942                	ld	s2,16(sp)
    8000292e:	69a2                	ld	s3,8(sp)
    80002930:	6a02                	ld	s4,0(sp)
    80002932:	6145                	addi	sp,sp,48
    80002934:	8082                	ret
    panic("iget: no inodes");
    80002936:	00007517          	auipc	a0,0x7
    8000293a:	bea50513          	addi	a0,a0,-1046 # 80009520 <syscalls+0x198>
    8000293e:	00004097          	auipc	ra,0x4
    80002942:	44a080e7          	jalr	1098(ra) # 80006d88 <panic>

0000000080002946 <fsinit>:
fsinit(int dev) {
    80002946:	7179                	addi	sp,sp,-48
    80002948:	f406                	sd	ra,40(sp)
    8000294a:	f022                	sd	s0,32(sp)
    8000294c:	ec26                	sd	s1,24(sp)
    8000294e:	e84a                	sd	s2,16(sp)
    80002950:	e44e                	sd	s3,8(sp)
    80002952:	1800                	addi	s0,sp,48
    80002954:	89aa                	mv	s3,a0
  bp = bread(dev, 1);
    80002956:	4585                	li	a1,1
    80002958:	00000097          	auipc	ra,0x0
    8000295c:	a20080e7          	jalr	-1504(ra) # 80002378 <bread>
    80002960:	892a                	mv	s2,a0
  memmove(sb, bp->data, sizeof(*sb));
    80002962:	00016497          	auipc	s1,0x16
    80002966:	bfe48493          	addi	s1,s1,-1026 # 80018560 <sb>
    8000296a:	02000613          	li	a2,32
    8000296e:	05850593          	addi	a1,a0,88
    80002972:	8526                	mv	a0,s1
    80002974:	ffffe097          	auipc	ra,0xffffe
    80002978:	874080e7          	jalr	-1932(ra) # 800001e8 <memmove>
  brelse(bp);
    8000297c:	854a                	mv	a0,s2
    8000297e:	00000097          	auipc	ra,0x0
    80002982:	b3c080e7          	jalr	-1220(ra) # 800024ba <brelse>
  if(sb.magic != FSMAGIC)
    80002986:	4098                	lw	a4,0(s1)
    80002988:	102037b7          	lui	a5,0x10203
    8000298c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    80002990:	02f71263          	bne	a4,a5,800029b4 <fsinit+0x6e>
  initlog(dev, &sb);
    80002994:	00016597          	auipc	a1,0x16
    80002998:	bcc58593          	addi	a1,a1,-1076 # 80018560 <sb>
    8000299c:	854e                	mv	a0,s3
    8000299e:	00001097          	auipc	ra,0x1
    800029a2:	b5c080e7          	jalr	-1188(ra) # 800034fa <initlog>
}
    800029a6:	70a2                	ld	ra,40(sp)
    800029a8:	7402                	ld	s0,32(sp)
    800029aa:	64e2                	ld	s1,24(sp)
    800029ac:	6942                	ld	s2,16(sp)
    800029ae:	69a2                	ld	s3,8(sp)
    800029b0:	6145                	addi	sp,sp,48
    800029b2:	8082                	ret
    panic("invalid file system");
    800029b4:	00007517          	auipc	a0,0x7
    800029b8:	b7c50513          	addi	a0,a0,-1156 # 80009530 <syscalls+0x1a8>
    800029bc:	00004097          	auipc	ra,0x4
    800029c0:	3cc080e7          	jalr	972(ra) # 80006d88 <panic>

00000000800029c4 <iinit>:
{
    800029c4:	7179                	addi	sp,sp,-48
    800029c6:	f406                	sd	ra,40(sp)
    800029c8:	f022                	sd	s0,32(sp)
    800029ca:	ec26                	sd	s1,24(sp)
    800029cc:	e84a                	sd	s2,16(sp)
    800029ce:	e44e                	sd	s3,8(sp)
    800029d0:	1800                	addi	s0,sp,48
  initlock(&icache.lock, "icache");
    800029d2:	00007597          	auipc	a1,0x7
    800029d6:	b7658593          	addi	a1,a1,-1162 # 80009548 <syscalls+0x1c0>
    800029da:	00016517          	auipc	a0,0x16
    800029de:	ba650513          	addi	a0,a0,-1114 # 80018580 <icache>
    800029e2:	00005097          	auipc	ra,0x5
    800029e6:	882080e7          	jalr	-1918(ra) # 80007264 <initlock>
  for(i = 0; i < NINODE; i++) {
    800029ea:	00016497          	auipc	s1,0x16
    800029ee:	bbe48493          	addi	s1,s1,-1090 # 800185a8 <icache+0x28>
    800029f2:	00017997          	auipc	s3,0x17
    800029f6:	64698993          	addi	s3,s3,1606 # 8001a038 <log+0x10>
    initsleeplock(&icache.inode[i].lock, "inode");
    800029fa:	00007917          	auipc	s2,0x7
    800029fe:	b5690913          	addi	s2,s2,-1194 # 80009550 <syscalls+0x1c8>
    80002a02:	85ca                	mv	a1,s2
    80002a04:	8526                	mv	a0,s1
    80002a06:	00001097          	auipc	ra,0x1
    80002a0a:	e7a080e7          	jalr	-390(ra) # 80003880 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    80002a0e:	08848493          	addi	s1,s1,136
    80002a12:	ff3498e3          	bne	s1,s3,80002a02 <iinit+0x3e>
}
    80002a16:	70a2                	ld	ra,40(sp)
    80002a18:	7402                	ld	s0,32(sp)
    80002a1a:	64e2                	ld	s1,24(sp)
    80002a1c:	6942                	ld	s2,16(sp)
    80002a1e:	69a2                	ld	s3,8(sp)
    80002a20:	6145                	addi	sp,sp,48
    80002a22:	8082                	ret

0000000080002a24 <ialloc>:
{
    80002a24:	715d                	addi	sp,sp,-80
    80002a26:	e486                	sd	ra,72(sp)
    80002a28:	e0a2                	sd	s0,64(sp)
    80002a2a:	fc26                	sd	s1,56(sp)
    80002a2c:	f84a                	sd	s2,48(sp)
    80002a2e:	f44e                	sd	s3,40(sp)
    80002a30:	f052                	sd	s4,32(sp)
    80002a32:	ec56                	sd	s5,24(sp)
    80002a34:	e85a                	sd	s6,16(sp)
    80002a36:	e45e                	sd	s7,8(sp)
    80002a38:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a3a:	00016797          	auipc	a5,0x16
    80002a3e:	b2678793          	addi	a5,a5,-1242 # 80018560 <sb>
    80002a42:	47d8                	lw	a4,12(a5)
    80002a44:	4785                	li	a5,1
    80002a46:	04e7fa63          	bleu	a4,a5,80002a9a <ialloc+0x76>
    80002a4a:	8a2a                	mv	s4,a0
    80002a4c:	8b2e                	mv	s6,a1
    80002a4e:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    80002a50:	00016997          	auipc	s3,0x16
    80002a54:	b1098993          	addi	s3,s3,-1264 # 80018560 <sb>
    80002a58:	00048a9b          	sext.w	s5,s1
    80002a5c:	0044d593          	srli	a1,s1,0x4
    80002a60:	0189a783          	lw	a5,24(s3)
    80002a64:	9dbd                	addw	a1,a1,a5
    80002a66:	8552                	mv	a0,s4
    80002a68:	00000097          	auipc	ra,0x0
    80002a6c:	910080e7          	jalr	-1776(ra) # 80002378 <bread>
    80002a70:	8baa                	mv	s7,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80002a72:	05850913          	addi	s2,a0,88
    80002a76:	00f4f793          	andi	a5,s1,15
    80002a7a:	079a                	slli	a5,a5,0x6
    80002a7c:	993e                	add	s2,s2,a5
    if(dip->type == 0){  // a free inode
    80002a7e:	00091783          	lh	a5,0(s2)
    80002a82:	c785                	beqz	a5,80002aaa <ialloc+0x86>
    brelse(bp);
    80002a84:	00000097          	auipc	ra,0x0
    80002a88:	a36080e7          	jalr	-1482(ra) # 800024ba <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    80002a8c:	0485                	addi	s1,s1,1
    80002a8e:	00c9a703          	lw	a4,12(s3)
    80002a92:	0004879b          	sext.w	a5,s1
    80002a96:	fce7e1e3          	bltu	a5,a4,80002a58 <ialloc+0x34>
  panic("ialloc: no inodes");
    80002a9a:	00007517          	auipc	a0,0x7
    80002a9e:	abe50513          	addi	a0,a0,-1346 # 80009558 <syscalls+0x1d0>
    80002aa2:	00004097          	auipc	ra,0x4
    80002aa6:	2e6080e7          	jalr	742(ra) # 80006d88 <panic>
      memset(dip, 0, sizeof(*dip));
    80002aaa:	04000613          	li	a2,64
    80002aae:	4581                	li	a1,0
    80002ab0:	854a                	mv	a0,s2
    80002ab2:	ffffd097          	auipc	ra,0xffffd
    80002ab6:	6ca080e7          	jalr	1738(ra) # 8000017c <memset>
      dip->type = type;
    80002aba:	01691023          	sh	s6,0(s2)
      log_write(bp);   // mark it allocated on the disk
    80002abe:	855e                	mv	a0,s7
    80002ac0:	00001097          	auipc	ra,0x1
    80002ac4:	cbc080e7          	jalr	-836(ra) # 8000377c <log_write>
      brelse(bp);
    80002ac8:	855e                	mv	a0,s7
    80002aca:	00000097          	auipc	ra,0x0
    80002ace:	9f0080e7          	jalr	-1552(ra) # 800024ba <brelse>
      return iget(dev, inum);
    80002ad2:	85d6                	mv	a1,s5
    80002ad4:	8552                	mv	a0,s4
    80002ad6:	00000097          	auipc	ra,0x0
    80002ada:	db4080e7          	jalr	-588(ra) # 8000288a <iget>
}
    80002ade:	60a6                	ld	ra,72(sp)
    80002ae0:	6406                	ld	s0,64(sp)
    80002ae2:	74e2                	ld	s1,56(sp)
    80002ae4:	7942                	ld	s2,48(sp)
    80002ae6:	79a2                	ld	s3,40(sp)
    80002ae8:	7a02                	ld	s4,32(sp)
    80002aea:	6ae2                	ld	s5,24(sp)
    80002aec:	6b42                	ld	s6,16(sp)
    80002aee:	6ba2                	ld	s7,8(sp)
    80002af0:	6161                	addi	sp,sp,80
    80002af2:	8082                	ret

0000000080002af4 <iupdate>:
{
    80002af4:	1101                	addi	sp,sp,-32
    80002af6:	ec06                	sd	ra,24(sp)
    80002af8:	e822                	sd	s0,16(sp)
    80002afa:	e426                	sd	s1,8(sp)
    80002afc:	e04a                	sd	s2,0(sp)
    80002afe:	1000                	addi	s0,sp,32
    80002b00:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002b02:	415c                	lw	a5,4(a0)
    80002b04:	0047d79b          	srliw	a5,a5,0x4
    80002b08:	00016717          	auipc	a4,0x16
    80002b0c:	a5870713          	addi	a4,a4,-1448 # 80018560 <sb>
    80002b10:	4f0c                	lw	a1,24(a4)
    80002b12:	9dbd                	addw	a1,a1,a5
    80002b14:	4108                	lw	a0,0(a0)
    80002b16:	00000097          	auipc	ra,0x0
    80002b1a:	862080e7          	jalr	-1950(ra) # 80002378 <bread>
    80002b1e:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002b20:	05850513          	addi	a0,a0,88
    80002b24:	40dc                	lw	a5,4(s1)
    80002b26:	8bbd                	andi	a5,a5,15
    80002b28:	079a                	slli	a5,a5,0x6
    80002b2a:	953e                	add	a0,a0,a5
  dip->type = ip->type;
    80002b2c:	04449783          	lh	a5,68(s1)
    80002b30:	00f51023          	sh	a5,0(a0)
  dip->major = ip->major;
    80002b34:	04649783          	lh	a5,70(s1)
    80002b38:	00f51123          	sh	a5,2(a0)
  dip->minor = ip->minor;
    80002b3c:	04849783          	lh	a5,72(s1)
    80002b40:	00f51223          	sh	a5,4(a0)
  dip->nlink = ip->nlink;
    80002b44:	04a49783          	lh	a5,74(s1)
    80002b48:	00f51323          	sh	a5,6(a0)
  dip->size = ip->size;
    80002b4c:	44fc                	lw	a5,76(s1)
    80002b4e:	c51c                	sw	a5,8(a0)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80002b50:	03400613          	li	a2,52
    80002b54:	05048593          	addi	a1,s1,80
    80002b58:	0531                	addi	a0,a0,12
    80002b5a:	ffffd097          	auipc	ra,0xffffd
    80002b5e:	68e080e7          	jalr	1678(ra) # 800001e8 <memmove>
  log_write(bp);
    80002b62:	854a                	mv	a0,s2
    80002b64:	00001097          	auipc	ra,0x1
    80002b68:	c18080e7          	jalr	-1000(ra) # 8000377c <log_write>
  brelse(bp);
    80002b6c:	854a                	mv	a0,s2
    80002b6e:	00000097          	auipc	ra,0x0
    80002b72:	94c080e7          	jalr	-1716(ra) # 800024ba <brelse>
}
    80002b76:	60e2                	ld	ra,24(sp)
    80002b78:	6442                	ld	s0,16(sp)
    80002b7a:	64a2                	ld	s1,8(sp)
    80002b7c:	6902                	ld	s2,0(sp)
    80002b7e:	6105                	addi	sp,sp,32
    80002b80:	8082                	ret

0000000080002b82 <idup>:
{
    80002b82:	1101                	addi	sp,sp,-32
    80002b84:	ec06                	sd	ra,24(sp)
    80002b86:	e822                	sd	s0,16(sp)
    80002b88:	e426                	sd	s1,8(sp)
    80002b8a:	1000                	addi	s0,sp,32
    80002b8c:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80002b8e:	00016517          	auipc	a0,0x16
    80002b92:	9f250513          	addi	a0,a0,-1550 # 80018580 <icache>
    80002b96:	00004097          	auipc	ra,0x4
    80002b9a:	75e080e7          	jalr	1886(ra) # 800072f4 <acquire>
  ip->ref++;
    80002b9e:	449c                	lw	a5,8(s1)
    80002ba0:	2785                	addiw	a5,a5,1
    80002ba2:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80002ba4:	00016517          	auipc	a0,0x16
    80002ba8:	9dc50513          	addi	a0,a0,-1572 # 80018580 <icache>
    80002bac:	00004097          	auipc	ra,0x4
    80002bb0:	7fc080e7          	jalr	2044(ra) # 800073a8 <release>
}
    80002bb4:	8526                	mv	a0,s1
    80002bb6:	60e2                	ld	ra,24(sp)
    80002bb8:	6442                	ld	s0,16(sp)
    80002bba:	64a2                	ld	s1,8(sp)
    80002bbc:	6105                	addi	sp,sp,32
    80002bbe:	8082                	ret

0000000080002bc0 <ilock>:
{
    80002bc0:	1101                	addi	sp,sp,-32
    80002bc2:	ec06                	sd	ra,24(sp)
    80002bc4:	e822                	sd	s0,16(sp)
    80002bc6:	e426                	sd	s1,8(sp)
    80002bc8:	e04a                	sd	s2,0(sp)
    80002bca:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    80002bcc:	c115                	beqz	a0,80002bf0 <ilock+0x30>
    80002bce:	84aa                	mv	s1,a0
    80002bd0:	451c                	lw	a5,8(a0)
    80002bd2:	00f05f63          	blez	a5,80002bf0 <ilock+0x30>
  acquiresleep(&ip->lock);
    80002bd6:	0541                	addi	a0,a0,16
    80002bd8:	00001097          	auipc	ra,0x1
    80002bdc:	ce2080e7          	jalr	-798(ra) # 800038ba <acquiresleep>
  if(ip->valid == 0){
    80002be0:	40bc                	lw	a5,64(s1)
    80002be2:	cf99                	beqz	a5,80002c00 <ilock+0x40>
}
    80002be4:	60e2                	ld	ra,24(sp)
    80002be6:	6442                	ld	s0,16(sp)
    80002be8:	64a2                	ld	s1,8(sp)
    80002bea:	6902                	ld	s2,0(sp)
    80002bec:	6105                	addi	sp,sp,32
    80002bee:	8082                	ret
    panic("ilock");
    80002bf0:	00007517          	auipc	a0,0x7
    80002bf4:	98050513          	addi	a0,a0,-1664 # 80009570 <syscalls+0x1e8>
    80002bf8:	00004097          	auipc	ra,0x4
    80002bfc:	190080e7          	jalr	400(ra) # 80006d88 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80002c00:	40dc                	lw	a5,4(s1)
    80002c02:	0047d79b          	srliw	a5,a5,0x4
    80002c06:	00016717          	auipc	a4,0x16
    80002c0a:	95a70713          	addi	a4,a4,-1702 # 80018560 <sb>
    80002c0e:	4f0c                	lw	a1,24(a4)
    80002c10:	9dbd                	addw	a1,a1,a5
    80002c12:	4088                	lw	a0,0(s1)
    80002c14:	fffff097          	auipc	ra,0xfffff
    80002c18:	764080e7          	jalr	1892(ra) # 80002378 <bread>
    80002c1c:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    80002c1e:	05850593          	addi	a1,a0,88
    80002c22:	40dc                	lw	a5,4(s1)
    80002c24:	8bbd                	andi	a5,a5,15
    80002c26:	079a                	slli	a5,a5,0x6
    80002c28:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80002c2a:	00059783          	lh	a5,0(a1)
    80002c2e:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    80002c32:	00259783          	lh	a5,2(a1)
    80002c36:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80002c3a:	00459783          	lh	a5,4(a1)
    80002c3e:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80002c42:	00659783          	lh	a5,6(a1)
    80002c46:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80002c4a:	459c                	lw	a5,8(a1)
    80002c4c:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80002c4e:	03400613          	li	a2,52
    80002c52:	05b1                	addi	a1,a1,12
    80002c54:	05048513          	addi	a0,s1,80
    80002c58:	ffffd097          	auipc	ra,0xffffd
    80002c5c:	590080e7          	jalr	1424(ra) # 800001e8 <memmove>
    brelse(bp);
    80002c60:	854a                	mv	a0,s2
    80002c62:	00000097          	auipc	ra,0x0
    80002c66:	858080e7          	jalr	-1960(ra) # 800024ba <brelse>
    ip->valid = 1;
    80002c6a:	4785                	li	a5,1
    80002c6c:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    80002c6e:	04449783          	lh	a5,68(s1)
    80002c72:	fbad                	bnez	a5,80002be4 <ilock+0x24>
      panic("ilock: no type");
    80002c74:	00007517          	auipc	a0,0x7
    80002c78:	90450513          	addi	a0,a0,-1788 # 80009578 <syscalls+0x1f0>
    80002c7c:	00004097          	auipc	ra,0x4
    80002c80:	10c080e7          	jalr	268(ra) # 80006d88 <panic>

0000000080002c84 <iunlock>:
{
    80002c84:	1101                	addi	sp,sp,-32
    80002c86:	ec06                	sd	ra,24(sp)
    80002c88:	e822                	sd	s0,16(sp)
    80002c8a:	e426                	sd	s1,8(sp)
    80002c8c:	e04a                	sd	s2,0(sp)
    80002c8e:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    80002c90:	c905                	beqz	a0,80002cc0 <iunlock+0x3c>
    80002c92:	84aa                	mv	s1,a0
    80002c94:	01050913          	addi	s2,a0,16
    80002c98:	854a                	mv	a0,s2
    80002c9a:	00001097          	auipc	ra,0x1
    80002c9e:	cba080e7          	jalr	-838(ra) # 80003954 <holdingsleep>
    80002ca2:	cd19                	beqz	a0,80002cc0 <iunlock+0x3c>
    80002ca4:	449c                	lw	a5,8(s1)
    80002ca6:	00f05d63          	blez	a5,80002cc0 <iunlock+0x3c>
  releasesleep(&ip->lock);
    80002caa:	854a                	mv	a0,s2
    80002cac:	00001097          	auipc	ra,0x1
    80002cb0:	c64080e7          	jalr	-924(ra) # 80003910 <releasesleep>
}
    80002cb4:	60e2                	ld	ra,24(sp)
    80002cb6:	6442                	ld	s0,16(sp)
    80002cb8:	64a2                	ld	s1,8(sp)
    80002cba:	6902                	ld	s2,0(sp)
    80002cbc:	6105                	addi	sp,sp,32
    80002cbe:	8082                	ret
    panic("iunlock");
    80002cc0:	00007517          	auipc	a0,0x7
    80002cc4:	8c850513          	addi	a0,a0,-1848 # 80009588 <syscalls+0x200>
    80002cc8:	00004097          	auipc	ra,0x4
    80002ccc:	0c0080e7          	jalr	192(ra) # 80006d88 <panic>

0000000080002cd0 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80002cd0:	7179                	addi	sp,sp,-48
    80002cd2:	f406                	sd	ra,40(sp)
    80002cd4:	f022                	sd	s0,32(sp)
    80002cd6:	ec26                	sd	s1,24(sp)
    80002cd8:	e84a                	sd	s2,16(sp)
    80002cda:	e44e                	sd	s3,8(sp)
    80002cdc:	e052                	sd	s4,0(sp)
    80002cde:	1800                	addi	s0,sp,48
    80002ce0:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80002ce2:	05050493          	addi	s1,a0,80
    80002ce6:	08050913          	addi	s2,a0,128
    80002cea:	a821                	j	80002d02 <itrunc+0x32>
    if(ip->addrs[i]){
      bfree(ip->dev, ip->addrs[i]);
    80002cec:	0009a503          	lw	a0,0(s3)
    80002cf0:	00000097          	auipc	ra,0x0
    80002cf4:	8e0080e7          	jalr	-1824(ra) # 800025d0 <bfree>
      ip->addrs[i] = 0;
    80002cf8:	0004a023          	sw	zero,0(s1)
  for(i = 0; i < NDIRECT; i++){
    80002cfc:	0491                	addi	s1,s1,4
    80002cfe:	01248563          	beq	s1,s2,80002d08 <itrunc+0x38>
    if(ip->addrs[i]){
    80002d02:	408c                	lw	a1,0(s1)
    80002d04:	dde5                	beqz	a1,80002cfc <itrunc+0x2c>
    80002d06:	b7dd                	j	80002cec <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80002d08:	0809a583          	lw	a1,128(s3)
    80002d0c:	e185                	bnez	a1,80002d2c <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80002d0e:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80002d12:	854e                	mv	a0,s3
    80002d14:	00000097          	auipc	ra,0x0
    80002d18:	de0080e7          	jalr	-544(ra) # 80002af4 <iupdate>
}
    80002d1c:	70a2                	ld	ra,40(sp)
    80002d1e:	7402                	ld	s0,32(sp)
    80002d20:	64e2                	ld	s1,24(sp)
    80002d22:	6942                	ld	s2,16(sp)
    80002d24:	69a2                	ld	s3,8(sp)
    80002d26:	6a02                	ld	s4,0(sp)
    80002d28:	6145                	addi	sp,sp,48
    80002d2a:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80002d2c:	0009a503          	lw	a0,0(s3)
    80002d30:	fffff097          	auipc	ra,0xfffff
    80002d34:	648080e7          	jalr	1608(ra) # 80002378 <bread>
    80002d38:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80002d3a:	05850493          	addi	s1,a0,88
    80002d3e:	45850913          	addi	s2,a0,1112
    80002d42:	a811                	j	80002d56 <itrunc+0x86>
        bfree(ip->dev, a[j]);
    80002d44:	0009a503          	lw	a0,0(s3)
    80002d48:	00000097          	auipc	ra,0x0
    80002d4c:	888080e7          	jalr	-1912(ra) # 800025d0 <bfree>
    for(j = 0; j < NINDIRECT; j++){
    80002d50:	0491                	addi	s1,s1,4
    80002d52:	01248563          	beq	s1,s2,80002d5c <itrunc+0x8c>
      if(a[j])
    80002d56:	408c                	lw	a1,0(s1)
    80002d58:	dde5                	beqz	a1,80002d50 <itrunc+0x80>
    80002d5a:	b7ed                	j	80002d44 <itrunc+0x74>
    brelse(bp);
    80002d5c:	8552                	mv	a0,s4
    80002d5e:	fffff097          	auipc	ra,0xfffff
    80002d62:	75c080e7          	jalr	1884(ra) # 800024ba <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80002d66:	0809a583          	lw	a1,128(s3)
    80002d6a:	0009a503          	lw	a0,0(s3)
    80002d6e:	00000097          	auipc	ra,0x0
    80002d72:	862080e7          	jalr	-1950(ra) # 800025d0 <bfree>
    ip->addrs[NDIRECT] = 0;
    80002d76:	0809a023          	sw	zero,128(s3)
    80002d7a:	bf51                	j	80002d0e <itrunc+0x3e>

0000000080002d7c <iput>:
{
    80002d7c:	1101                	addi	sp,sp,-32
    80002d7e:	ec06                	sd	ra,24(sp)
    80002d80:	e822                	sd	s0,16(sp)
    80002d82:	e426                	sd	s1,8(sp)
    80002d84:	e04a                	sd	s2,0(sp)
    80002d86:	1000                	addi	s0,sp,32
    80002d88:	84aa                	mv	s1,a0
  acquire(&icache.lock);
    80002d8a:	00015517          	auipc	a0,0x15
    80002d8e:	7f650513          	addi	a0,a0,2038 # 80018580 <icache>
    80002d92:	00004097          	auipc	ra,0x4
    80002d96:	562080e7          	jalr	1378(ra) # 800072f4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002d9a:	4498                	lw	a4,8(s1)
    80002d9c:	4785                	li	a5,1
    80002d9e:	02f70363          	beq	a4,a5,80002dc4 <iput+0x48>
  ip->ref--;
    80002da2:	449c                	lw	a5,8(s1)
    80002da4:	37fd                	addiw	a5,a5,-1
    80002da6:	c49c                	sw	a5,8(s1)
  release(&icache.lock);
    80002da8:	00015517          	auipc	a0,0x15
    80002dac:	7d850513          	addi	a0,a0,2008 # 80018580 <icache>
    80002db0:	00004097          	auipc	ra,0x4
    80002db4:	5f8080e7          	jalr	1528(ra) # 800073a8 <release>
}
    80002db8:	60e2                	ld	ra,24(sp)
    80002dba:	6442                	ld	s0,16(sp)
    80002dbc:	64a2                	ld	s1,8(sp)
    80002dbe:	6902                	ld	s2,0(sp)
    80002dc0:	6105                	addi	sp,sp,32
    80002dc2:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80002dc4:	40bc                	lw	a5,64(s1)
    80002dc6:	dff1                	beqz	a5,80002da2 <iput+0x26>
    80002dc8:	04a49783          	lh	a5,74(s1)
    80002dcc:	fbf9                	bnez	a5,80002da2 <iput+0x26>
    acquiresleep(&ip->lock);
    80002dce:	01048913          	addi	s2,s1,16
    80002dd2:	854a                	mv	a0,s2
    80002dd4:	00001097          	auipc	ra,0x1
    80002dd8:	ae6080e7          	jalr	-1306(ra) # 800038ba <acquiresleep>
    release(&icache.lock);
    80002ddc:	00015517          	auipc	a0,0x15
    80002de0:	7a450513          	addi	a0,a0,1956 # 80018580 <icache>
    80002de4:	00004097          	auipc	ra,0x4
    80002de8:	5c4080e7          	jalr	1476(ra) # 800073a8 <release>
    itrunc(ip);
    80002dec:	8526                	mv	a0,s1
    80002dee:	00000097          	auipc	ra,0x0
    80002df2:	ee2080e7          	jalr	-286(ra) # 80002cd0 <itrunc>
    ip->type = 0;
    80002df6:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80002dfa:	8526                	mv	a0,s1
    80002dfc:	00000097          	auipc	ra,0x0
    80002e00:	cf8080e7          	jalr	-776(ra) # 80002af4 <iupdate>
    ip->valid = 0;
    80002e04:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80002e08:	854a                	mv	a0,s2
    80002e0a:	00001097          	auipc	ra,0x1
    80002e0e:	b06080e7          	jalr	-1274(ra) # 80003910 <releasesleep>
    acquire(&icache.lock);
    80002e12:	00015517          	auipc	a0,0x15
    80002e16:	76e50513          	addi	a0,a0,1902 # 80018580 <icache>
    80002e1a:	00004097          	auipc	ra,0x4
    80002e1e:	4da080e7          	jalr	1242(ra) # 800072f4 <acquire>
    80002e22:	b741                	j	80002da2 <iput+0x26>

0000000080002e24 <iunlockput>:
{
    80002e24:	1101                	addi	sp,sp,-32
    80002e26:	ec06                	sd	ra,24(sp)
    80002e28:	e822                	sd	s0,16(sp)
    80002e2a:	e426                	sd	s1,8(sp)
    80002e2c:	1000                	addi	s0,sp,32
    80002e2e:	84aa                	mv	s1,a0
  iunlock(ip);
    80002e30:	00000097          	auipc	ra,0x0
    80002e34:	e54080e7          	jalr	-428(ra) # 80002c84 <iunlock>
  iput(ip);
    80002e38:	8526                	mv	a0,s1
    80002e3a:	00000097          	auipc	ra,0x0
    80002e3e:	f42080e7          	jalr	-190(ra) # 80002d7c <iput>
}
    80002e42:	60e2                	ld	ra,24(sp)
    80002e44:	6442                	ld	s0,16(sp)
    80002e46:	64a2                	ld	s1,8(sp)
    80002e48:	6105                	addi	sp,sp,32
    80002e4a:	8082                	ret

0000000080002e4c <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80002e4c:	1141                	addi	sp,sp,-16
    80002e4e:	e422                	sd	s0,8(sp)
    80002e50:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80002e52:	411c                	lw	a5,0(a0)
    80002e54:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80002e56:	415c                	lw	a5,4(a0)
    80002e58:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80002e5a:	04451783          	lh	a5,68(a0)
    80002e5e:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80002e62:	04a51783          	lh	a5,74(a0)
    80002e66:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80002e6a:	04c56783          	lwu	a5,76(a0)
    80002e6e:	e99c                	sd	a5,16(a1)
}
    80002e70:	6422                	ld	s0,8(sp)
    80002e72:	0141                	addi	sp,sp,16
    80002e74:	8082                	ret

0000000080002e76 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002e76:	457c                	lw	a5,76(a0)
    80002e78:	0ed7e963          	bltu	a5,a3,80002f6a <readi+0xf4>
{
    80002e7c:	7159                	addi	sp,sp,-112
    80002e7e:	f486                	sd	ra,104(sp)
    80002e80:	f0a2                	sd	s0,96(sp)
    80002e82:	eca6                	sd	s1,88(sp)
    80002e84:	e8ca                	sd	s2,80(sp)
    80002e86:	e4ce                	sd	s3,72(sp)
    80002e88:	e0d2                	sd	s4,64(sp)
    80002e8a:	fc56                	sd	s5,56(sp)
    80002e8c:	f85a                	sd	s6,48(sp)
    80002e8e:	f45e                	sd	s7,40(sp)
    80002e90:	f062                	sd	s8,32(sp)
    80002e92:	ec66                	sd	s9,24(sp)
    80002e94:	e86a                	sd	s10,16(sp)
    80002e96:	e46e                	sd	s11,8(sp)
    80002e98:	1880                	addi	s0,sp,112
    80002e9a:	8baa                	mv	s7,a0
    80002e9c:	8c2e                	mv	s8,a1
    80002e9e:	8a32                	mv	s4,a2
    80002ea0:	84b6                	mv	s1,a3
    80002ea2:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80002ea4:	9f35                	addw	a4,a4,a3
    return 0;
    80002ea6:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80002ea8:	0ad76063          	bltu	a4,a3,80002f48 <readi+0xd2>
  if(off + n > ip->size)
    80002eac:	00e7f463          	bleu	a4,a5,80002eb4 <readi+0x3e>
    n = ip->size - off;
    80002eb0:	40d78b3b          	subw	s6,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002eb4:	0a0b0963          	beqz	s6,80002f66 <readi+0xf0>
    80002eb8:	4901                	li	s2,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002eba:	40000d13          	li	s10,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80002ebe:	5cfd                	li	s9,-1
    80002ec0:	a82d                	j	80002efa <readi+0x84>
    80002ec2:	02099d93          	slli	s11,s3,0x20
    80002ec6:	020ddd93          	srli	s11,s11,0x20
    80002eca:	058a8613          	addi	a2,s5,88
    80002ece:	86ee                	mv	a3,s11
    80002ed0:	963a                	add	a2,a2,a4
    80002ed2:	85d2                	mv	a1,s4
    80002ed4:	8562                	mv	a0,s8
    80002ed6:	fffff097          	auipc	ra,0xfffff
    80002eda:	aa6080e7          	jalr	-1370(ra) # 8000197c <either_copyout>
    80002ede:	05950d63          	beq	a0,s9,80002f38 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80002ee2:	8556                	mv	a0,s5
    80002ee4:	fffff097          	auipc	ra,0xfffff
    80002ee8:	5d6080e7          	jalr	1494(ra) # 800024ba <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002eec:	0129893b          	addw	s2,s3,s2
    80002ef0:	009984bb          	addw	s1,s3,s1
    80002ef4:	9a6e                	add	s4,s4,s11
    80002ef6:	05697763          	bleu	s6,s2,80002f44 <readi+0xce>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002efa:	000ba983          	lw	s3,0(s7)
    80002efe:	00a4d59b          	srliw	a1,s1,0xa
    80002f02:	855e                	mv	a0,s7
    80002f04:	00000097          	auipc	ra,0x0
    80002f08:	8ac080e7          	jalr	-1876(ra) # 800027b0 <bmap>
    80002f0c:	0005059b          	sext.w	a1,a0
    80002f10:	854e                	mv	a0,s3
    80002f12:	fffff097          	auipc	ra,0xfffff
    80002f16:	466080e7          	jalr	1126(ra) # 80002378 <bread>
    80002f1a:	8aaa                	mv	s5,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80002f1c:	3ff4f713          	andi	a4,s1,1023
    80002f20:	40ed07bb          	subw	a5,s10,a4
    80002f24:	412b06bb          	subw	a3,s6,s2
    80002f28:	89be                	mv	s3,a5
    80002f2a:	2781                	sext.w	a5,a5
    80002f2c:	0006861b          	sext.w	a2,a3
    80002f30:	f8f679e3          	bleu	a5,a2,80002ec2 <readi+0x4c>
    80002f34:	89b6                	mv	s3,a3
    80002f36:	b771                	j	80002ec2 <readi+0x4c>
      brelse(bp);
    80002f38:	8556                	mv	a0,s5
    80002f3a:	fffff097          	auipc	ra,0xfffff
    80002f3e:	580080e7          	jalr	1408(ra) # 800024ba <brelse>
      tot = -1;
    80002f42:	597d                	li	s2,-1
  }
  return tot;
    80002f44:	0009051b          	sext.w	a0,s2
}
    80002f48:	70a6                	ld	ra,104(sp)
    80002f4a:	7406                	ld	s0,96(sp)
    80002f4c:	64e6                	ld	s1,88(sp)
    80002f4e:	6946                	ld	s2,80(sp)
    80002f50:	69a6                	ld	s3,72(sp)
    80002f52:	6a06                	ld	s4,64(sp)
    80002f54:	7ae2                	ld	s5,56(sp)
    80002f56:	7b42                	ld	s6,48(sp)
    80002f58:	7ba2                	ld	s7,40(sp)
    80002f5a:	7c02                	ld	s8,32(sp)
    80002f5c:	6ce2                	ld	s9,24(sp)
    80002f5e:	6d42                	ld	s10,16(sp)
    80002f60:	6da2                	ld	s11,8(sp)
    80002f62:	6165                	addi	sp,sp,112
    80002f64:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80002f66:	895a                	mv	s2,s6
    80002f68:	bff1                	j	80002f44 <readi+0xce>
    return 0;
    80002f6a:	4501                	li	a0,0
}
    80002f6c:	8082                	ret

0000000080002f6e <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80002f6e:	457c                	lw	a5,76(a0)
    80002f70:	10d7e863          	bltu	a5,a3,80003080 <writei+0x112>
{
    80002f74:	7159                	addi	sp,sp,-112
    80002f76:	f486                	sd	ra,104(sp)
    80002f78:	f0a2                	sd	s0,96(sp)
    80002f7a:	eca6                	sd	s1,88(sp)
    80002f7c:	e8ca                	sd	s2,80(sp)
    80002f7e:	e4ce                	sd	s3,72(sp)
    80002f80:	e0d2                	sd	s4,64(sp)
    80002f82:	fc56                	sd	s5,56(sp)
    80002f84:	f85a                	sd	s6,48(sp)
    80002f86:	f45e                	sd	s7,40(sp)
    80002f88:	f062                	sd	s8,32(sp)
    80002f8a:	ec66                	sd	s9,24(sp)
    80002f8c:	e86a                	sd	s10,16(sp)
    80002f8e:	e46e                	sd	s11,8(sp)
    80002f90:	1880                	addi	s0,sp,112
    80002f92:	8b2a                	mv	s6,a0
    80002f94:	8c2e                	mv	s8,a1
    80002f96:	8ab2                	mv	s5,a2
    80002f98:	84b6                	mv	s1,a3
    80002f9a:	8bba                	mv	s7,a4
  if(off > ip->size || off + n < off)
    80002f9c:	00e687bb          	addw	a5,a3,a4
    80002fa0:	0ed7e263          	bltu	a5,a3,80003084 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80002fa4:	00043737          	lui	a4,0x43
    80002fa8:	0ef76063          	bltu	a4,a5,80003088 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002fac:	0c0b8863          	beqz	s7,8000307c <writei+0x10e>
    80002fb0:	4981                	li	s3,0
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    80002fb2:	40000d13          	li	s10,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80002fb6:	5cfd                	li	s9,-1
    80002fb8:	a091                	j	80002ffc <writei+0x8e>
    80002fba:	02091d93          	slli	s11,s2,0x20
    80002fbe:	020ddd93          	srli	s11,s11,0x20
    80002fc2:	058a0513          	addi	a0,s4,88 # 2058 <_entry-0x7fffdfa8>
    80002fc6:	86ee                	mv	a3,s11
    80002fc8:	8656                	mv	a2,s5
    80002fca:	85e2                	mv	a1,s8
    80002fcc:	953a                	add	a0,a0,a4
    80002fce:	fffff097          	auipc	ra,0xfffff
    80002fd2:	a04080e7          	jalr	-1532(ra) # 800019d2 <either_copyin>
    80002fd6:	07950263          	beq	a0,s9,8000303a <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80002fda:	8552                	mv	a0,s4
    80002fdc:	00000097          	auipc	ra,0x0
    80002fe0:	7a0080e7          	jalr	1952(ra) # 8000377c <log_write>
    brelse(bp);
    80002fe4:	8552                	mv	a0,s4
    80002fe6:	fffff097          	auipc	ra,0xfffff
    80002fea:	4d4080e7          	jalr	1236(ra) # 800024ba <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80002fee:	013909bb          	addw	s3,s2,s3
    80002ff2:	009904bb          	addw	s1,s2,s1
    80002ff6:	9aee                	add	s5,s5,s11
    80002ff8:	0579f663          	bleu	s7,s3,80003044 <writei+0xd6>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    80002ffc:	000b2903          	lw	s2,0(s6)
    80003000:	00a4d59b          	srliw	a1,s1,0xa
    80003004:	855a                	mv	a0,s6
    80003006:	fffff097          	auipc	ra,0xfffff
    8000300a:	7aa080e7          	jalr	1962(ra) # 800027b0 <bmap>
    8000300e:	0005059b          	sext.w	a1,a0
    80003012:	854a                	mv	a0,s2
    80003014:	fffff097          	auipc	ra,0xfffff
    80003018:	364080e7          	jalr	868(ra) # 80002378 <bread>
    8000301c:	8a2a                	mv	s4,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000301e:	3ff4f713          	andi	a4,s1,1023
    80003022:	40ed07bb          	subw	a5,s10,a4
    80003026:	413b86bb          	subw	a3,s7,s3
    8000302a:	893e                	mv	s2,a5
    8000302c:	2781                	sext.w	a5,a5
    8000302e:	0006861b          	sext.w	a2,a3
    80003032:	f8f674e3          	bleu	a5,a2,80002fba <writei+0x4c>
    80003036:	8936                	mv	s2,a3
    80003038:	b749                	j	80002fba <writei+0x4c>
      brelse(bp);
    8000303a:	8552                	mv	a0,s4
    8000303c:	fffff097          	auipc	ra,0xfffff
    80003040:	47e080e7          	jalr	1150(ra) # 800024ba <brelse>
  }

  if(off > ip->size)
    80003044:	04cb2783          	lw	a5,76(s6)
    80003048:	0097f463          	bleu	s1,a5,80003050 <writei+0xe2>
    ip->size = off;
    8000304c:	049b2623          	sw	s1,76(s6)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003050:	855a                	mv	a0,s6
    80003052:	00000097          	auipc	ra,0x0
    80003056:	aa2080e7          	jalr	-1374(ra) # 80002af4 <iupdate>

  return tot;
    8000305a:	0009851b          	sext.w	a0,s3
}
    8000305e:	70a6                	ld	ra,104(sp)
    80003060:	7406                	ld	s0,96(sp)
    80003062:	64e6                	ld	s1,88(sp)
    80003064:	6946                	ld	s2,80(sp)
    80003066:	69a6                	ld	s3,72(sp)
    80003068:	6a06                	ld	s4,64(sp)
    8000306a:	7ae2                	ld	s5,56(sp)
    8000306c:	7b42                	ld	s6,48(sp)
    8000306e:	7ba2                	ld	s7,40(sp)
    80003070:	7c02                	ld	s8,32(sp)
    80003072:	6ce2                	ld	s9,24(sp)
    80003074:	6d42                	ld	s10,16(sp)
    80003076:	6da2                	ld	s11,8(sp)
    80003078:	6165                	addi	sp,sp,112
    8000307a:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    8000307c:	89de                	mv	s3,s7
    8000307e:	bfc9                	j	80003050 <writei+0xe2>
    return -1;
    80003080:	557d                	li	a0,-1
}
    80003082:	8082                	ret
    return -1;
    80003084:	557d                	li	a0,-1
    80003086:	bfe1                	j	8000305e <writei+0xf0>
    return -1;
    80003088:	557d                	li	a0,-1
    8000308a:	bfd1                	j	8000305e <writei+0xf0>

000000008000308c <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    8000308c:	1141                	addi	sp,sp,-16
    8000308e:	e406                	sd	ra,8(sp)
    80003090:	e022                	sd	s0,0(sp)
    80003092:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003094:	4639                	li	a2,14
    80003096:	ffffd097          	auipc	ra,0xffffd
    8000309a:	1ce080e7          	jalr	462(ra) # 80000264 <strncmp>
}
    8000309e:	60a2                	ld	ra,8(sp)
    800030a0:	6402                	ld	s0,0(sp)
    800030a2:	0141                	addi	sp,sp,16
    800030a4:	8082                	ret

00000000800030a6 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    800030a6:	7139                	addi	sp,sp,-64
    800030a8:	fc06                	sd	ra,56(sp)
    800030aa:	f822                	sd	s0,48(sp)
    800030ac:	f426                	sd	s1,40(sp)
    800030ae:	f04a                	sd	s2,32(sp)
    800030b0:	ec4e                	sd	s3,24(sp)
    800030b2:	e852                	sd	s4,16(sp)
    800030b4:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    800030b6:	04451703          	lh	a4,68(a0)
    800030ba:	4785                	li	a5,1
    800030bc:	00f71a63          	bne	a4,a5,800030d0 <dirlookup+0x2a>
    800030c0:	892a                	mv	s2,a0
    800030c2:	89ae                	mv	s3,a1
    800030c4:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    800030c6:	457c                	lw	a5,76(a0)
    800030c8:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    800030ca:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    800030cc:	e79d                	bnez	a5,800030fa <dirlookup+0x54>
    800030ce:	a8a5                	j	80003146 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    800030d0:	00006517          	auipc	a0,0x6
    800030d4:	4c050513          	addi	a0,a0,1216 # 80009590 <syscalls+0x208>
    800030d8:	00004097          	auipc	ra,0x4
    800030dc:	cb0080e7          	jalr	-848(ra) # 80006d88 <panic>
      panic("dirlookup read");
    800030e0:	00006517          	auipc	a0,0x6
    800030e4:	4c850513          	addi	a0,a0,1224 # 800095a8 <syscalls+0x220>
    800030e8:	00004097          	auipc	ra,0x4
    800030ec:	ca0080e7          	jalr	-864(ra) # 80006d88 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800030f0:	24c1                	addiw	s1,s1,16
    800030f2:	04c92783          	lw	a5,76(s2)
    800030f6:	04f4f763          	bleu	a5,s1,80003144 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800030fa:	4741                	li	a4,16
    800030fc:	86a6                	mv	a3,s1
    800030fe:	fc040613          	addi	a2,s0,-64
    80003102:	4581                	li	a1,0
    80003104:	854a                	mv	a0,s2
    80003106:	00000097          	auipc	ra,0x0
    8000310a:	d70080e7          	jalr	-656(ra) # 80002e76 <readi>
    8000310e:	47c1                	li	a5,16
    80003110:	fcf518e3          	bne	a0,a5,800030e0 <dirlookup+0x3a>
    if(de.inum == 0)
    80003114:	fc045783          	lhu	a5,-64(s0)
    80003118:	dfe1                	beqz	a5,800030f0 <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    8000311a:	fc240593          	addi	a1,s0,-62
    8000311e:	854e                	mv	a0,s3
    80003120:	00000097          	auipc	ra,0x0
    80003124:	f6c080e7          	jalr	-148(ra) # 8000308c <namecmp>
    80003128:	f561                	bnez	a0,800030f0 <dirlookup+0x4a>
      if(poff)
    8000312a:	000a0463          	beqz	s4,80003132 <dirlookup+0x8c>
        *poff = off;
    8000312e:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003132:	fc045583          	lhu	a1,-64(s0)
    80003136:	00092503          	lw	a0,0(s2)
    8000313a:	fffff097          	auipc	ra,0xfffff
    8000313e:	750080e7          	jalr	1872(ra) # 8000288a <iget>
    80003142:	a011                	j	80003146 <dirlookup+0xa0>
  return 0;
    80003144:	4501                	li	a0,0
}
    80003146:	70e2                	ld	ra,56(sp)
    80003148:	7442                	ld	s0,48(sp)
    8000314a:	74a2                	ld	s1,40(sp)
    8000314c:	7902                	ld	s2,32(sp)
    8000314e:	69e2                	ld	s3,24(sp)
    80003150:	6a42                	ld	s4,16(sp)
    80003152:	6121                	addi	sp,sp,64
    80003154:	8082                	ret

0000000080003156 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003156:	711d                	addi	sp,sp,-96
    80003158:	ec86                	sd	ra,88(sp)
    8000315a:	e8a2                	sd	s0,80(sp)
    8000315c:	e4a6                	sd	s1,72(sp)
    8000315e:	e0ca                	sd	s2,64(sp)
    80003160:	fc4e                	sd	s3,56(sp)
    80003162:	f852                	sd	s4,48(sp)
    80003164:	f456                	sd	s5,40(sp)
    80003166:	f05a                	sd	s6,32(sp)
    80003168:	ec5e                	sd	s7,24(sp)
    8000316a:	e862                	sd	s8,16(sp)
    8000316c:	e466                	sd	s9,8(sp)
    8000316e:	1080                	addi	s0,sp,96
    80003170:	84aa                	mv	s1,a0
    80003172:	8bae                	mv	s7,a1
    80003174:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003176:	00054703          	lbu	a4,0(a0)
    8000317a:	02f00793          	li	a5,47
    8000317e:	02f70363          	beq	a4,a5,800031a4 <namex+0x4e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003182:	ffffe097          	auipc	ra,0xffffe
    80003186:	d7e080e7          	jalr	-642(ra) # 80000f00 <myproc>
    8000318a:	15053503          	ld	a0,336(a0)
    8000318e:	00000097          	auipc	ra,0x0
    80003192:	9f4080e7          	jalr	-1548(ra) # 80002b82 <idup>
    80003196:	89aa                	mv	s3,a0
  while(*path == '/')
    80003198:	02f00913          	li	s2,47
  len = path - s;
    8000319c:	4b01                	li	s6,0
  if(len >= DIRSIZ)
    8000319e:	4cb5                	li	s9,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800031a0:	4c05                	li	s8,1
    800031a2:	a865                	j	8000325a <namex+0x104>
    ip = iget(ROOTDEV, ROOTINO);
    800031a4:	4585                	li	a1,1
    800031a6:	4505                	li	a0,1
    800031a8:	fffff097          	auipc	ra,0xfffff
    800031ac:	6e2080e7          	jalr	1762(ra) # 8000288a <iget>
    800031b0:	89aa                	mv	s3,a0
    800031b2:	b7dd                	j	80003198 <namex+0x42>
      iunlockput(ip);
    800031b4:	854e                	mv	a0,s3
    800031b6:	00000097          	auipc	ra,0x0
    800031ba:	c6e080e7          	jalr	-914(ra) # 80002e24 <iunlockput>
      return 0;
    800031be:	4981                	li	s3,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800031c0:	854e                	mv	a0,s3
    800031c2:	60e6                	ld	ra,88(sp)
    800031c4:	6446                	ld	s0,80(sp)
    800031c6:	64a6                	ld	s1,72(sp)
    800031c8:	6906                	ld	s2,64(sp)
    800031ca:	79e2                	ld	s3,56(sp)
    800031cc:	7a42                	ld	s4,48(sp)
    800031ce:	7aa2                	ld	s5,40(sp)
    800031d0:	7b02                	ld	s6,32(sp)
    800031d2:	6be2                	ld	s7,24(sp)
    800031d4:	6c42                	ld	s8,16(sp)
    800031d6:	6ca2                	ld	s9,8(sp)
    800031d8:	6125                	addi	sp,sp,96
    800031da:	8082                	ret
      iunlock(ip);
    800031dc:	854e                	mv	a0,s3
    800031de:	00000097          	auipc	ra,0x0
    800031e2:	aa6080e7          	jalr	-1370(ra) # 80002c84 <iunlock>
      return ip;
    800031e6:	bfe9                	j	800031c0 <namex+0x6a>
      iunlockput(ip);
    800031e8:	854e                	mv	a0,s3
    800031ea:	00000097          	auipc	ra,0x0
    800031ee:	c3a080e7          	jalr	-966(ra) # 80002e24 <iunlockput>
      return 0;
    800031f2:	89d2                	mv	s3,s4
    800031f4:	b7f1                	j	800031c0 <namex+0x6a>
  len = path - s;
    800031f6:	40b48633          	sub	a2,s1,a1
    800031fa:	00060a1b          	sext.w	s4,a2
  if(len >= DIRSIZ)
    800031fe:	094cd663          	ble	s4,s9,8000328a <namex+0x134>
    memmove(name, s, DIRSIZ);
    80003202:	4639                	li	a2,14
    80003204:	8556                	mv	a0,s5
    80003206:	ffffd097          	auipc	ra,0xffffd
    8000320a:	fe2080e7          	jalr	-30(ra) # 800001e8 <memmove>
  while(*path == '/')
    8000320e:	0004c783          	lbu	a5,0(s1)
    80003212:	01279763          	bne	a5,s2,80003220 <namex+0xca>
    path++;
    80003216:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003218:	0004c783          	lbu	a5,0(s1)
    8000321c:	ff278de3          	beq	a5,s2,80003216 <namex+0xc0>
    ilock(ip);
    80003220:	854e                	mv	a0,s3
    80003222:	00000097          	auipc	ra,0x0
    80003226:	99e080e7          	jalr	-1634(ra) # 80002bc0 <ilock>
    if(ip->type != T_DIR){
    8000322a:	04499783          	lh	a5,68(s3)
    8000322e:	f98793e3          	bne	a5,s8,800031b4 <namex+0x5e>
    if(nameiparent && *path == '\0'){
    80003232:	000b8563          	beqz	s7,8000323c <namex+0xe6>
    80003236:	0004c783          	lbu	a5,0(s1)
    8000323a:	d3cd                	beqz	a5,800031dc <namex+0x86>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000323c:	865a                	mv	a2,s6
    8000323e:	85d6                	mv	a1,s5
    80003240:	854e                	mv	a0,s3
    80003242:	00000097          	auipc	ra,0x0
    80003246:	e64080e7          	jalr	-412(ra) # 800030a6 <dirlookup>
    8000324a:	8a2a                	mv	s4,a0
    8000324c:	dd51                	beqz	a0,800031e8 <namex+0x92>
    iunlockput(ip);
    8000324e:	854e                	mv	a0,s3
    80003250:	00000097          	auipc	ra,0x0
    80003254:	bd4080e7          	jalr	-1068(ra) # 80002e24 <iunlockput>
    ip = next;
    80003258:	89d2                	mv	s3,s4
  while(*path == '/')
    8000325a:	0004c783          	lbu	a5,0(s1)
    8000325e:	05279d63          	bne	a5,s2,800032b8 <namex+0x162>
    path++;
    80003262:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003264:	0004c783          	lbu	a5,0(s1)
    80003268:	ff278de3          	beq	a5,s2,80003262 <namex+0x10c>
  if(*path == 0)
    8000326c:	cf8d                	beqz	a5,800032a6 <namex+0x150>
  while(*path != '/' && *path != 0)
    8000326e:	01278b63          	beq	a5,s2,80003284 <namex+0x12e>
    80003272:	c795                	beqz	a5,8000329e <namex+0x148>
    path++;
    80003274:	85a6                	mv	a1,s1
    path++;
    80003276:	0485                	addi	s1,s1,1
  while(*path != '/' && *path != 0)
    80003278:	0004c783          	lbu	a5,0(s1)
    8000327c:	f7278de3          	beq	a5,s2,800031f6 <namex+0xa0>
    80003280:	fbfd                	bnez	a5,80003276 <namex+0x120>
    80003282:	bf95                	j	800031f6 <namex+0xa0>
    80003284:	85a6                	mv	a1,s1
  len = path - s;
    80003286:	8a5a                	mv	s4,s6
    80003288:	865a                	mv	a2,s6
    memmove(name, s, len);
    8000328a:	2601                	sext.w	a2,a2
    8000328c:	8556                	mv	a0,s5
    8000328e:	ffffd097          	auipc	ra,0xffffd
    80003292:	f5a080e7          	jalr	-166(ra) # 800001e8 <memmove>
    name[len] = 0;
    80003296:	9a56                	add	s4,s4,s5
    80003298:	000a0023          	sb	zero,0(s4)
    8000329c:	bf8d                	j	8000320e <namex+0xb8>
  while(*path != '/' && *path != 0)
    8000329e:	85a6                	mv	a1,s1
  len = path - s;
    800032a0:	8a5a                	mv	s4,s6
    800032a2:	865a                	mv	a2,s6
    800032a4:	b7dd                	j	8000328a <namex+0x134>
  if(nameiparent){
    800032a6:	f00b8de3          	beqz	s7,800031c0 <namex+0x6a>
    iput(ip);
    800032aa:	854e                	mv	a0,s3
    800032ac:	00000097          	auipc	ra,0x0
    800032b0:	ad0080e7          	jalr	-1328(ra) # 80002d7c <iput>
    return 0;
    800032b4:	4981                	li	s3,0
    800032b6:	b729                	j	800031c0 <namex+0x6a>
  if(*path == 0)
    800032b8:	d7fd                	beqz	a5,800032a6 <namex+0x150>
    800032ba:	85a6                	mv	a1,s1
    800032bc:	bf6d                	j	80003276 <namex+0x120>

00000000800032be <dirlink>:
{
    800032be:	7139                	addi	sp,sp,-64
    800032c0:	fc06                	sd	ra,56(sp)
    800032c2:	f822                	sd	s0,48(sp)
    800032c4:	f426                	sd	s1,40(sp)
    800032c6:	f04a                	sd	s2,32(sp)
    800032c8:	ec4e                	sd	s3,24(sp)
    800032ca:	e852                	sd	s4,16(sp)
    800032cc:	0080                	addi	s0,sp,64
    800032ce:	892a                	mv	s2,a0
    800032d0:	8a2e                	mv	s4,a1
    800032d2:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800032d4:	4601                	li	a2,0
    800032d6:	00000097          	auipc	ra,0x0
    800032da:	dd0080e7          	jalr	-560(ra) # 800030a6 <dirlookup>
    800032de:	e93d                	bnez	a0,80003354 <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    800032e0:	04c92483          	lw	s1,76(s2)
    800032e4:	c49d                	beqz	s1,80003312 <dirlink+0x54>
    800032e6:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800032e8:	4741                	li	a4,16
    800032ea:	86a6                	mv	a3,s1
    800032ec:	fc040613          	addi	a2,s0,-64
    800032f0:	4581                	li	a1,0
    800032f2:	854a                	mv	a0,s2
    800032f4:	00000097          	auipc	ra,0x0
    800032f8:	b82080e7          	jalr	-1150(ra) # 80002e76 <readi>
    800032fc:	47c1                	li	a5,16
    800032fe:	06f51163          	bne	a0,a5,80003360 <dirlink+0xa2>
    if(de.inum == 0)
    80003302:	fc045783          	lhu	a5,-64(s0)
    80003306:	c791                	beqz	a5,80003312 <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003308:	24c1                	addiw	s1,s1,16
    8000330a:	04c92783          	lw	a5,76(s2)
    8000330e:	fcf4ede3          	bltu	s1,a5,800032e8 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    80003312:	4639                	li	a2,14
    80003314:	85d2                	mv	a1,s4
    80003316:	fc240513          	addi	a0,s0,-62
    8000331a:	ffffd097          	auipc	ra,0xffffd
    8000331e:	f9a080e7          	jalr	-102(ra) # 800002b4 <strncpy>
  de.inum = inum;
    80003322:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003326:	4741                	li	a4,16
    80003328:	86a6                	mv	a3,s1
    8000332a:	fc040613          	addi	a2,s0,-64
    8000332e:	4581                	li	a1,0
    80003330:	854a                	mv	a0,s2
    80003332:	00000097          	auipc	ra,0x0
    80003336:	c3c080e7          	jalr	-964(ra) # 80002f6e <writei>
    8000333a:	4741                	li	a4,16
  return 0;
    8000333c:	4781                	li	a5,0
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    8000333e:	02e51963          	bne	a0,a4,80003370 <dirlink+0xb2>
}
    80003342:	853e                	mv	a0,a5
    80003344:	70e2                	ld	ra,56(sp)
    80003346:	7442                	ld	s0,48(sp)
    80003348:	74a2                	ld	s1,40(sp)
    8000334a:	7902                	ld	s2,32(sp)
    8000334c:	69e2                	ld	s3,24(sp)
    8000334e:	6a42                	ld	s4,16(sp)
    80003350:	6121                	addi	sp,sp,64
    80003352:	8082                	ret
    iput(ip);
    80003354:	00000097          	auipc	ra,0x0
    80003358:	a28080e7          	jalr	-1496(ra) # 80002d7c <iput>
    return -1;
    8000335c:	57fd                	li	a5,-1
    8000335e:	b7d5                	j	80003342 <dirlink+0x84>
      panic("dirlink read");
    80003360:	00006517          	auipc	a0,0x6
    80003364:	25850513          	addi	a0,a0,600 # 800095b8 <syscalls+0x230>
    80003368:	00004097          	auipc	ra,0x4
    8000336c:	a20080e7          	jalr	-1504(ra) # 80006d88 <panic>
    panic("dirlink");
    80003370:	00006517          	auipc	a0,0x6
    80003374:	35850513          	addi	a0,a0,856 # 800096c8 <syscalls+0x340>
    80003378:	00004097          	auipc	ra,0x4
    8000337c:	a10080e7          	jalr	-1520(ra) # 80006d88 <panic>

0000000080003380 <namei>:

struct inode*
namei(char *path)
{
    80003380:	1101                	addi	sp,sp,-32
    80003382:	ec06                	sd	ra,24(sp)
    80003384:	e822                	sd	s0,16(sp)
    80003386:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003388:	fe040613          	addi	a2,s0,-32
    8000338c:	4581                	li	a1,0
    8000338e:	00000097          	auipc	ra,0x0
    80003392:	dc8080e7          	jalr	-568(ra) # 80003156 <namex>
}
    80003396:	60e2                	ld	ra,24(sp)
    80003398:	6442                	ld	s0,16(sp)
    8000339a:	6105                	addi	sp,sp,32
    8000339c:	8082                	ret

000000008000339e <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    8000339e:	1141                	addi	sp,sp,-16
    800033a0:	e406                	sd	ra,8(sp)
    800033a2:	e022                	sd	s0,0(sp)
    800033a4:	0800                	addi	s0,sp,16
  return namex(path, 1, name);
    800033a6:	862e                	mv	a2,a1
    800033a8:	4585                	li	a1,1
    800033aa:	00000097          	auipc	ra,0x0
    800033ae:	dac080e7          	jalr	-596(ra) # 80003156 <namex>
}
    800033b2:	60a2                	ld	ra,8(sp)
    800033b4:	6402                	ld	s0,0(sp)
    800033b6:	0141                	addi	sp,sp,16
    800033b8:	8082                	ret

00000000800033ba <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800033ba:	1101                	addi	sp,sp,-32
    800033bc:	ec06                	sd	ra,24(sp)
    800033be:	e822                	sd	s0,16(sp)
    800033c0:	e426                	sd	s1,8(sp)
    800033c2:	e04a                	sd	s2,0(sp)
    800033c4:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800033c6:	00017917          	auipc	s2,0x17
    800033ca:	c6290913          	addi	s2,s2,-926 # 8001a028 <log>
    800033ce:	01892583          	lw	a1,24(s2)
    800033d2:	02892503          	lw	a0,40(s2)
    800033d6:	fffff097          	auipc	ra,0xfffff
    800033da:	fa2080e7          	jalr	-94(ra) # 80002378 <bread>
    800033de:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800033e0:	02c92683          	lw	a3,44(s2)
    800033e4:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800033e6:	02d05763          	blez	a3,80003414 <write_head+0x5a>
    800033ea:	00017797          	auipc	a5,0x17
    800033ee:	c6e78793          	addi	a5,a5,-914 # 8001a058 <log+0x30>
    800033f2:	05c50713          	addi	a4,a0,92
    800033f6:	36fd                	addiw	a3,a3,-1
    800033f8:	1682                	slli	a3,a3,0x20
    800033fa:	9281                	srli	a3,a3,0x20
    800033fc:	068a                	slli	a3,a3,0x2
    800033fe:	00017617          	auipc	a2,0x17
    80003402:	c5e60613          	addi	a2,a2,-930 # 8001a05c <log+0x34>
    80003406:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80003408:	4390                	lw	a2,0(a5)
    8000340a:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    8000340c:	0791                	addi	a5,a5,4
    8000340e:	0711                	addi	a4,a4,4
    80003410:	fed79ce3          	bne	a5,a3,80003408 <write_head+0x4e>
  }
  bwrite(buf);
    80003414:	8526                	mv	a0,s1
    80003416:	fffff097          	auipc	ra,0xfffff
    8000341a:	066080e7          	jalr	102(ra) # 8000247c <bwrite>
  brelse(buf);
    8000341e:	8526                	mv	a0,s1
    80003420:	fffff097          	auipc	ra,0xfffff
    80003424:	09a080e7          	jalr	154(ra) # 800024ba <brelse>
}
    80003428:	60e2                	ld	ra,24(sp)
    8000342a:	6442                	ld	s0,16(sp)
    8000342c:	64a2                	ld	s1,8(sp)
    8000342e:	6902                	ld	s2,0(sp)
    80003430:	6105                	addi	sp,sp,32
    80003432:	8082                	ret

0000000080003434 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80003434:	00017797          	auipc	a5,0x17
    80003438:	bf478793          	addi	a5,a5,-1036 # 8001a028 <log>
    8000343c:	57dc                	lw	a5,44(a5)
    8000343e:	0af05d63          	blez	a5,800034f8 <install_trans+0xc4>
{
    80003442:	7139                	addi	sp,sp,-64
    80003444:	fc06                	sd	ra,56(sp)
    80003446:	f822                	sd	s0,48(sp)
    80003448:	f426                	sd	s1,40(sp)
    8000344a:	f04a                	sd	s2,32(sp)
    8000344c:	ec4e                	sd	s3,24(sp)
    8000344e:	e852                	sd	s4,16(sp)
    80003450:	e456                	sd	s5,8(sp)
    80003452:	e05a                	sd	s6,0(sp)
    80003454:	0080                	addi	s0,sp,64
    80003456:	8b2a                	mv	s6,a0
    80003458:	00017a17          	auipc	s4,0x17
    8000345c:	c00a0a13          	addi	s4,s4,-1024 # 8001a058 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003460:	4981                	li	s3,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003462:	00017917          	auipc	s2,0x17
    80003466:	bc690913          	addi	s2,s2,-1082 # 8001a028 <log>
    8000346a:	a035                	j	80003496 <install_trans+0x62>
      bunpin(dbuf);
    8000346c:	8526                	mv	a0,s1
    8000346e:	fffff097          	auipc	ra,0xfffff
    80003472:	126080e7          	jalr	294(ra) # 80002594 <bunpin>
    brelse(lbuf);
    80003476:	8556                	mv	a0,s5
    80003478:	fffff097          	auipc	ra,0xfffff
    8000347c:	042080e7          	jalr	66(ra) # 800024ba <brelse>
    brelse(dbuf);
    80003480:	8526                	mv	a0,s1
    80003482:	fffff097          	auipc	ra,0xfffff
    80003486:	038080e7          	jalr	56(ra) # 800024ba <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000348a:	2985                	addiw	s3,s3,1
    8000348c:	0a11                	addi	s4,s4,4
    8000348e:	02c92783          	lw	a5,44(s2)
    80003492:	04f9d963          	ble	a5,s3,800034e4 <install_trans+0xb0>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003496:	01892583          	lw	a1,24(s2)
    8000349a:	013585bb          	addw	a1,a1,s3
    8000349e:	2585                	addiw	a1,a1,1
    800034a0:	02892503          	lw	a0,40(s2)
    800034a4:	fffff097          	auipc	ra,0xfffff
    800034a8:	ed4080e7          	jalr	-300(ra) # 80002378 <bread>
    800034ac:	8aaa                	mv	s5,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800034ae:	000a2583          	lw	a1,0(s4)
    800034b2:	02892503          	lw	a0,40(s2)
    800034b6:	fffff097          	auipc	ra,0xfffff
    800034ba:	ec2080e7          	jalr	-318(ra) # 80002378 <bread>
    800034be:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    800034c0:	40000613          	li	a2,1024
    800034c4:	058a8593          	addi	a1,s5,88
    800034c8:	05850513          	addi	a0,a0,88
    800034cc:	ffffd097          	auipc	ra,0xffffd
    800034d0:	d1c080e7          	jalr	-740(ra) # 800001e8 <memmove>
    bwrite(dbuf);  // write dst to disk
    800034d4:	8526                	mv	a0,s1
    800034d6:	fffff097          	auipc	ra,0xfffff
    800034da:	fa6080e7          	jalr	-90(ra) # 8000247c <bwrite>
    if(recovering == 0)
    800034de:	f80b1ce3          	bnez	s6,80003476 <install_trans+0x42>
    800034e2:	b769                	j	8000346c <install_trans+0x38>
}
    800034e4:	70e2                	ld	ra,56(sp)
    800034e6:	7442                	ld	s0,48(sp)
    800034e8:	74a2                	ld	s1,40(sp)
    800034ea:	7902                	ld	s2,32(sp)
    800034ec:	69e2                	ld	s3,24(sp)
    800034ee:	6a42                	ld	s4,16(sp)
    800034f0:	6aa2                	ld	s5,8(sp)
    800034f2:	6b02                	ld	s6,0(sp)
    800034f4:	6121                	addi	sp,sp,64
    800034f6:	8082                	ret
    800034f8:	8082                	ret

00000000800034fa <initlog>:
{
    800034fa:	7179                	addi	sp,sp,-48
    800034fc:	f406                	sd	ra,40(sp)
    800034fe:	f022                	sd	s0,32(sp)
    80003500:	ec26                	sd	s1,24(sp)
    80003502:	e84a                	sd	s2,16(sp)
    80003504:	e44e                	sd	s3,8(sp)
    80003506:	1800                	addi	s0,sp,48
    80003508:	892a                	mv	s2,a0
    8000350a:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    8000350c:	00017497          	auipc	s1,0x17
    80003510:	b1c48493          	addi	s1,s1,-1252 # 8001a028 <log>
    80003514:	00006597          	auipc	a1,0x6
    80003518:	0b458593          	addi	a1,a1,180 # 800095c8 <syscalls+0x240>
    8000351c:	8526                	mv	a0,s1
    8000351e:	00004097          	auipc	ra,0x4
    80003522:	d46080e7          	jalr	-698(ra) # 80007264 <initlock>
  log.start = sb->logstart;
    80003526:	0149a583          	lw	a1,20(s3)
    8000352a:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    8000352c:	0109a783          	lw	a5,16(s3)
    80003530:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003532:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003536:	854a                	mv	a0,s2
    80003538:	fffff097          	auipc	ra,0xfffff
    8000353c:	e40080e7          	jalr	-448(ra) # 80002378 <bread>
  log.lh.n = lh->n;
    80003540:	4d3c                	lw	a5,88(a0)
    80003542:	d4dc                	sw	a5,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003544:	02f05563          	blez	a5,8000356e <initlog+0x74>
    80003548:	05c50713          	addi	a4,a0,92
    8000354c:	00017697          	auipc	a3,0x17
    80003550:	b0c68693          	addi	a3,a3,-1268 # 8001a058 <log+0x30>
    80003554:	37fd                	addiw	a5,a5,-1
    80003556:	1782                	slli	a5,a5,0x20
    80003558:	9381                	srli	a5,a5,0x20
    8000355a:	078a                	slli	a5,a5,0x2
    8000355c:	06050613          	addi	a2,a0,96
    80003560:	97b2                	add	a5,a5,a2
    log.lh.block[i] = lh->block[i];
    80003562:	4310                	lw	a2,0(a4)
    80003564:	c290                	sw	a2,0(a3)
  for (i = 0; i < log.lh.n; i++) {
    80003566:	0711                	addi	a4,a4,4
    80003568:	0691                	addi	a3,a3,4
    8000356a:	fef71ce3          	bne	a4,a5,80003562 <initlog+0x68>
  brelse(buf);
    8000356e:	fffff097          	auipc	ra,0xfffff
    80003572:	f4c080e7          	jalr	-180(ra) # 800024ba <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003576:	4505                	li	a0,1
    80003578:	00000097          	auipc	ra,0x0
    8000357c:	ebc080e7          	jalr	-324(ra) # 80003434 <install_trans>
  log.lh.n = 0;
    80003580:	00017797          	auipc	a5,0x17
    80003584:	ac07aa23          	sw	zero,-1324(a5) # 8001a054 <log+0x2c>
  write_head(); // clear the log
    80003588:	00000097          	auipc	ra,0x0
    8000358c:	e32080e7          	jalr	-462(ra) # 800033ba <write_head>
}
    80003590:	70a2                	ld	ra,40(sp)
    80003592:	7402                	ld	s0,32(sp)
    80003594:	64e2                	ld	s1,24(sp)
    80003596:	6942                	ld	s2,16(sp)
    80003598:	69a2                	ld	s3,8(sp)
    8000359a:	6145                	addi	sp,sp,48
    8000359c:	8082                	ret

000000008000359e <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    8000359e:	1101                	addi	sp,sp,-32
    800035a0:	ec06                	sd	ra,24(sp)
    800035a2:	e822                	sd	s0,16(sp)
    800035a4:	e426                	sd	s1,8(sp)
    800035a6:	e04a                	sd	s2,0(sp)
    800035a8:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800035aa:	00017517          	auipc	a0,0x17
    800035ae:	a7e50513          	addi	a0,a0,-1410 # 8001a028 <log>
    800035b2:	00004097          	auipc	ra,0x4
    800035b6:	d42080e7          	jalr	-702(ra) # 800072f4 <acquire>
  while(1){
    if(log.committing){
    800035ba:	00017497          	auipc	s1,0x17
    800035be:	a6e48493          	addi	s1,s1,-1426 # 8001a028 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800035c2:	4979                	li	s2,30
    800035c4:	a039                	j	800035d2 <begin_op+0x34>
      sleep(&log, &log.lock);
    800035c6:	85a6                	mv	a1,s1
    800035c8:	8526                	mv	a0,s1
    800035ca:	ffffe097          	auipc	ra,0xffffe
    800035ce:	150080e7          	jalr	336(ra) # 8000171a <sleep>
    if(log.committing){
    800035d2:	50dc                	lw	a5,36(s1)
    800035d4:	fbed                	bnez	a5,800035c6 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    800035d6:	509c                	lw	a5,32(s1)
    800035d8:	0017871b          	addiw	a4,a5,1
    800035dc:	0007069b          	sext.w	a3,a4
    800035e0:	0027179b          	slliw	a5,a4,0x2
    800035e4:	9fb9                	addw	a5,a5,a4
    800035e6:	0017979b          	slliw	a5,a5,0x1
    800035ea:	54d8                	lw	a4,44(s1)
    800035ec:	9fb9                	addw	a5,a5,a4
    800035ee:	00f95963          	ble	a5,s2,80003600 <begin_op+0x62>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    800035f2:	85a6                	mv	a1,s1
    800035f4:	8526                	mv	a0,s1
    800035f6:	ffffe097          	auipc	ra,0xffffe
    800035fa:	124080e7          	jalr	292(ra) # 8000171a <sleep>
    800035fe:	bfd1                	j	800035d2 <begin_op+0x34>
    } else {
      log.outstanding += 1;
    80003600:	00017517          	auipc	a0,0x17
    80003604:	a2850513          	addi	a0,a0,-1496 # 8001a028 <log>
    80003608:	d114                	sw	a3,32(a0)
      release(&log.lock);
    8000360a:	00004097          	auipc	ra,0x4
    8000360e:	d9e080e7          	jalr	-610(ra) # 800073a8 <release>
      break;
    }
  }
}
    80003612:	60e2                	ld	ra,24(sp)
    80003614:	6442                	ld	s0,16(sp)
    80003616:	64a2                	ld	s1,8(sp)
    80003618:	6902                	ld	s2,0(sp)
    8000361a:	6105                	addi	sp,sp,32
    8000361c:	8082                	ret

000000008000361e <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    8000361e:	7139                	addi	sp,sp,-64
    80003620:	fc06                	sd	ra,56(sp)
    80003622:	f822                	sd	s0,48(sp)
    80003624:	f426                	sd	s1,40(sp)
    80003626:	f04a                	sd	s2,32(sp)
    80003628:	ec4e                	sd	s3,24(sp)
    8000362a:	e852                	sd	s4,16(sp)
    8000362c:	e456                	sd	s5,8(sp)
    8000362e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003630:	00017917          	auipc	s2,0x17
    80003634:	9f890913          	addi	s2,s2,-1544 # 8001a028 <log>
    80003638:	854a                	mv	a0,s2
    8000363a:	00004097          	auipc	ra,0x4
    8000363e:	cba080e7          	jalr	-838(ra) # 800072f4 <acquire>
  log.outstanding -= 1;
    80003642:	02092783          	lw	a5,32(s2)
    80003646:	37fd                	addiw	a5,a5,-1
    80003648:	0007849b          	sext.w	s1,a5
    8000364c:	02f92023          	sw	a5,32(s2)
  if(log.committing)
    80003650:	02492783          	lw	a5,36(s2)
    80003654:	eba1                	bnez	a5,800036a4 <end_op+0x86>
    panic("log.committing");
  if(log.outstanding == 0){
    80003656:	ecb9                	bnez	s1,800036b4 <end_op+0x96>
    do_commit = 1;
    log.committing = 1;
    80003658:	00017917          	auipc	s2,0x17
    8000365c:	9d090913          	addi	s2,s2,-1584 # 8001a028 <log>
    80003660:	4785                	li	a5,1
    80003662:	02f92223          	sw	a5,36(s2)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003666:	854a                	mv	a0,s2
    80003668:	00004097          	auipc	ra,0x4
    8000366c:	d40080e7          	jalr	-704(ra) # 800073a8 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003670:	02c92783          	lw	a5,44(s2)
    80003674:	06f04763          	bgtz	a5,800036e2 <end_op+0xc4>
    acquire(&log.lock);
    80003678:	00017497          	auipc	s1,0x17
    8000367c:	9b048493          	addi	s1,s1,-1616 # 8001a028 <log>
    80003680:	8526                	mv	a0,s1
    80003682:	00004097          	auipc	ra,0x4
    80003686:	c72080e7          	jalr	-910(ra) # 800072f4 <acquire>
    log.committing = 0;
    8000368a:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    8000368e:	8526                	mv	a0,s1
    80003690:	ffffe097          	auipc	ra,0xffffe
    80003694:	210080e7          	jalr	528(ra) # 800018a0 <wakeup>
    release(&log.lock);
    80003698:	8526                	mv	a0,s1
    8000369a:	00004097          	auipc	ra,0x4
    8000369e:	d0e080e7          	jalr	-754(ra) # 800073a8 <release>
}
    800036a2:	a03d                	j	800036d0 <end_op+0xb2>
    panic("log.committing");
    800036a4:	00006517          	auipc	a0,0x6
    800036a8:	f2c50513          	addi	a0,a0,-212 # 800095d0 <syscalls+0x248>
    800036ac:	00003097          	auipc	ra,0x3
    800036b0:	6dc080e7          	jalr	1756(ra) # 80006d88 <panic>
    wakeup(&log);
    800036b4:	00017497          	auipc	s1,0x17
    800036b8:	97448493          	addi	s1,s1,-1676 # 8001a028 <log>
    800036bc:	8526                	mv	a0,s1
    800036be:	ffffe097          	auipc	ra,0xffffe
    800036c2:	1e2080e7          	jalr	482(ra) # 800018a0 <wakeup>
  release(&log.lock);
    800036c6:	8526                	mv	a0,s1
    800036c8:	00004097          	auipc	ra,0x4
    800036cc:	ce0080e7          	jalr	-800(ra) # 800073a8 <release>
}
    800036d0:	70e2                	ld	ra,56(sp)
    800036d2:	7442                	ld	s0,48(sp)
    800036d4:	74a2                	ld	s1,40(sp)
    800036d6:	7902                	ld	s2,32(sp)
    800036d8:	69e2                	ld	s3,24(sp)
    800036da:	6a42                	ld	s4,16(sp)
    800036dc:	6aa2                	ld	s5,8(sp)
    800036de:	6121                	addi	sp,sp,64
    800036e0:	8082                	ret
    800036e2:	00017a17          	auipc	s4,0x17
    800036e6:	976a0a13          	addi	s4,s4,-1674 # 8001a058 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    800036ea:	00017917          	auipc	s2,0x17
    800036ee:	93e90913          	addi	s2,s2,-1730 # 8001a028 <log>
    800036f2:	01892583          	lw	a1,24(s2)
    800036f6:	9da5                	addw	a1,a1,s1
    800036f8:	2585                	addiw	a1,a1,1
    800036fa:	02892503          	lw	a0,40(s2)
    800036fe:	fffff097          	auipc	ra,0xfffff
    80003702:	c7a080e7          	jalr	-902(ra) # 80002378 <bread>
    80003706:	89aa                	mv	s3,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003708:	000a2583          	lw	a1,0(s4)
    8000370c:	02892503          	lw	a0,40(s2)
    80003710:	fffff097          	auipc	ra,0xfffff
    80003714:	c68080e7          	jalr	-920(ra) # 80002378 <bread>
    80003718:	8aaa                	mv	s5,a0
    memmove(to->data, from->data, BSIZE);
    8000371a:	40000613          	li	a2,1024
    8000371e:	05850593          	addi	a1,a0,88
    80003722:	05898513          	addi	a0,s3,88
    80003726:	ffffd097          	auipc	ra,0xffffd
    8000372a:	ac2080e7          	jalr	-1342(ra) # 800001e8 <memmove>
    bwrite(to);  // write the log
    8000372e:	854e                	mv	a0,s3
    80003730:	fffff097          	auipc	ra,0xfffff
    80003734:	d4c080e7          	jalr	-692(ra) # 8000247c <bwrite>
    brelse(from);
    80003738:	8556                	mv	a0,s5
    8000373a:	fffff097          	auipc	ra,0xfffff
    8000373e:	d80080e7          	jalr	-640(ra) # 800024ba <brelse>
    brelse(to);
    80003742:	854e                	mv	a0,s3
    80003744:	fffff097          	auipc	ra,0xfffff
    80003748:	d76080e7          	jalr	-650(ra) # 800024ba <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    8000374c:	2485                	addiw	s1,s1,1
    8000374e:	0a11                	addi	s4,s4,4
    80003750:	02c92783          	lw	a5,44(s2)
    80003754:	f8f4cfe3          	blt	s1,a5,800036f2 <end_op+0xd4>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003758:	00000097          	auipc	ra,0x0
    8000375c:	c62080e7          	jalr	-926(ra) # 800033ba <write_head>
    install_trans(0); // Now install writes to home locations
    80003760:	4501                	li	a0,0
    80003762:	00000097          	auipc	ra,0x0
    80003766:	cd2080e7          	jalr	-814(ra) # 80003434 <install_trans>
    log.lh.n = 0;
    8000376a:	00017797          	auipc	a5,0x17
    8000376e:	8e07a523          	sw	zero,-1814(a5) # 8001a054 <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003772:	00000097          	auipc	ra,0x0
    80003776:	c48080e7          	jalr	-952(ra) # 800033ba <write_head>
    8000377a:	bdfd                	j	80003678 <end_op+0x5a>

000000008000377c <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    8000377c:	1101                	addi	sp,sp,-32
    8000377e:	ec06                	sd	ra,24(sp)
    80003780:	e822                	sd	s0,16(sp)
    80003782:	e426                	sd	s1,8(sp)
    80003784:	e04a                	sd	s2,0(sp)
    80003786:	1000                	addi	s0,sp,32
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003788:	00017797          	auipc	a5,0x17
    8000378c:	8a078793          	addi	a5,a5,-1888 # 8001a028 <log>
    80003790:	57d8                	lw	a4,44(a5)
    80003792:	47f5                	li	a5,29
    80003794:	08e7c563          	blt	a5,a4,8000381e <log_write+0xa2>
    80003798:	892a                	mv	s2,a0
    8000379a:	00017797          	auipc	a5,0x17
    8000379e:	88e78793          	addi	a5,a5,-1906 # 8001a028 <log>
    800037a2:	4fdc                	lw	a5,28(a5)
    800037a4:	37fd                	addiw	a5,a5,-1
    800037a6:	06f75c63          	ble	a5,a4,8000381e <log_write+0xa2>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800037aa:	00017797          	auipc	a5,0x17
    800037ae:	87e78793          	addi	a5,a5,-1922 # 8001a028 <log>
    800037b2:	539c                	lw	a5,32(a5)
    800037b4:	06f05d63          	blez	a5,8000382e <log_write+0xb2>
    panic("log_write outside of trans");

  acquire(&log.lock);
    800037b8:	00017497          	auipc	s1,0x17
    800037bc:	87048493          	addi	s1,s1,-1936 # 8001a028 <log>
    800037c0:	8526                	mv	a0,s1
    800037c2:	00004097          	auipc	ra,0x4
    800037c6:	b32080e7          	jalr	-1230(ra) # 800072f4 <acquire>
  for (i = 0; i < log.lh.n; i++) {
    800037ca:	54d0                	lw	a2,44(s1)
    800037cc:	0ac05063          	blez	a2,8000386c <log_write+0xf0>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800037d0:	00c92583          	lw	a1,12(s2)
    800037d4:	589c                	lw	a5,48(s1)
    800037d6:	0ab78363          	beq	a5,a1,8000387c <log_write+0x100>
    800037da:	00017717          	auipc	a4,0x17
    800037de:	88270713          	addi	a4,a4,-1918 # 8001a05c <log+0x34>
  for (i = 0; i < log.lh.n; i++) {
    800037e2:	4781                	li	a5,0
    800037e4:	2785                	addiw	a5,a5,1
    800037e6:	04c78c63          	beq	a5,a2,8000383e <log_write+0xc2>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
    800037ea:	4314                	lw	a3,0(a4)
    800037ec:	0711                	addi	a4,a4,4
    800037ee:	feb69be3          	bne	a3,a1,800037e4 <log_write+0x68>
      break;
  }
  log.lh.block[i] = b->blockno;
    800037f2:	07a1                	addi	a5,a5,8
    800037f4:	078a                	slli	a5,a5,0x2
    800037f6:	00017717          	auipc	a4,0x17
    800037fa:	83270713          	addi	a4,a4,-1998 # 8001a028 <log>
    800037fe:	97ba                	add	a5,a5,a4
    80003800:	cb8c                	sw	a1,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    log.lh.n++;
  }
  release(&log.lock);
    80003802:	00017517          	auipc	a0,0x17
    80003806:	82650513          	addi	a0,a0,-2010 # 8001a028 <log>
    8000380a:	00004097          	auipc	ra,0x4
    8000380e:	b9e080e7          	jalr	-1122(ra) # 800073a8 <release>
}
    80003812:	60e2                	ld	ra,24(sp)
    80003814:	6442                	ld	s0,16(sp)
    80003816:	64a2                	ld	s1,8(sp)
    80003818:	6902                	ld	s2,0(sp)
    8000381a:	6105                	addi	sp,sp,32
    8000381c:	8082                	ret
    panic("too big a transaction");
    8000381e:	00006517          	auipc	a0,0x6
    80003822:	dc250513          	addi	a0,a0,-574 # 800095e0 <syscalls+0x258>
    80003826:	00003097          	auipc	ra,0x3
    8000382a:	562080e7          	jalr	1378(ra) # 80006d88 <panic>
    panic("log_write outside of trans");
    8000382e:	00006517          	auipc	a0,0x6
    80003832:	dca50513          	addi	a0,a0,-566 # 800095f8 <syscalls+0x270>
    80003836:	00003097          	auipc	ra,0x3
    8000383a:	552080e7          	jalr	1362(ra) # 80006d88 <panic>
  log.lh.block[i] = b->blockno;
    8000383e:	0621                	addi	a2,a2,8
    80003840:	060a                	slli	a2,a2,0x2
    80003842:	00016797          	auipc	a5,0x16
    80003846:	7e678793          	addi	a5,a5,2022 # 8001a028 <log>
    8000384a:	963e                	add	a2,a2,a5
    8000384c:	00c92783          	lw	a5,12(s2)
    80003850:	ca1c                	sw	a5,16(a2)
    bpin(b);
    80003852:	854a                	mv	a0,s2
    80003854:	fffff097          	auipc	ra,0xfffff
    80003858:	d04080e7          	jalr	-764(ra) # 80002558 <bpin>
    log.lh.n++;
    8000385c:	00016717          	auipc	a4,0x16
    80003860:	7cc70713          	addi	a4,a4,1996 # 8001a028 <log>
    80003864:	575c                	lw	a5,44(a4)
    80003866:	2785                	addiw	a5,a5,1
    80003868:	d75c                	sw	a5,44(a4)
    8000386a:	bf61                	j	80003802 <log_write+0x86>
  log.lh.block[i] = b->blockno;
    8000386c:	00c92783          	lw	a5,12(s2)
    80003870:	00016717          	auipc	a4,0x16
    80003874:	7ef72423          	sw	a5,2024(a4) # 8001a058 <log+0x30>
  if (i == log.lh.n) {  // Add new block to log?
    80003878:	f649                	bnez	a2,80003802 <log_write+0x86>
    8000387a:	bfe1                	j	80003852 <log_write+0xd6>
  for (i = 0; i < log.lh.n; i++) {
    8000387c:	4781                	li	a5,0
    8000387e:	bf95                	j	800037f2 <log_write+0x76>

0000000080003880 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003880:	1101                	addi	sp,sp,-32
    80003882:	ec06                	sd	ra,24(sp)
    80003884:	e822                	sd	s0,16(sp)
    80003886:	e426                	sd	s1,8(sp)
    80003888:	e04a                	sd	s2,0(sp)
    8000388a:	1000                	addi	s0,sp,32
    8000388c:	84aa                	mv	s1,a0
    8000388e:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003890:	00006597          	auipc	a1,0x6
    80003894:	d8858593          	addi	a1,a1,-632 # 80009618 <syscalls+0x290>
    80003898:	0521                	addi	a0,a0,8
    8000389a:	00004097          	auipc	ra,0x4
    8000389e:	9ca080e7          	jalr	-1590(ra) # 80007264 <initlock>
  lk->name = name;
    800038a2:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800038a6:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800038aa:	0204a423          	sw	zero,40(s1)
}
    800038ae:	60e2                	ld	ra,24(sp)
    800038b0:	6442                	ld	s0,16(sp)
    800038b2:	64a2                	ld	s1,8(sp)
    800038b4:	6902                	ld	s2,0(sp)
    800038b6:	6105                	addi	sp,sp,32
    800038b8:	8082                	ret

00000000800038ba <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800038ba:	1101                	addi	sp,sp,-32
    800038bc:	ec06                	sd	ra,24(sp)
    800038be:	e822                	sd	s0,16(sp)
    800038c0:	e426                	sd	s1,8(sp)
    800038c2:	e04a                	sd	s2,0(sp)
    800038c4:	1000                	addi	s0,sp,32
    800038c6:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800038c8:	00850913          	addi	s2,a0,8
    800038cc:	854a                	mv	a0,s2
    800038ce:	00004097          	auipc	ra,0x4
    800038d2:	a26080e7          	jalr	-1498(ra) # 800072f4 <acquire>
  while (lk->locked) {
    800038d6:	409c                	lw	a5,0(s1)
    800038d8:	cb89                	beqz	a5,800038ea <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800038da:	85ca                	mv	a1,s2
    800038dc:	8526                	mv	a0,s1
    800038de:	ffffe097          	auipc	ra,0xffffe
    800038e2:	e3c080e7          	jalr	-452(ra) # 8000171a <sleep>
  while (lk->locked) {
    800038e6:	409c                	lw	a5,0(s1)
    800038e8:	fbed                	bnez	a5,800038da <acquiresleep+0x20>
  }
  lk->locked = 1;
    800038ea:	4785                	li	a5,1
    800038ec:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    800038ee:	ffffd097          	auipc	ra,0xffffd
    800038f2:	612080e7          	jalr	1554(ra) # 80000f00 <myproc>
    800038f6:	5d1c                	lw	a5,56(a0)
    800038f8:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    800038fa:	854a                	mv	a0,s2
    800038fc:	00004097          	auipc	ra,0x4
    80003900:	aac080e7          	jalr	-1364(ra) # 800073a8 <release>
}
    80003904:	60e2                	ld	ra,24(sp)
    80003906:	6442                	ld	s0,16(sp)
    80003908:	64a2                	ld	s1,8(sp)
    8000390a:	6902                	ld	s2,0(sp)
    8000390c:	6105                	addi	sp,sp,32
    8000390e:	8082                	ret

0000000080003910 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003910:	1101                	addi	sp,sp,-32
    80003912:	ec06                	sd	ra,24(sp)
    80003914:	e822                	sd	s0,16(sp)
    80003916:	e426                	sd	s1,8(sp)
    80003918:	e04a                	sd	s2,0(sp)
    8000391a:	1000                	addi	s0,sp,32
    8000391c:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    8000391e:	00850913          	addi	s2,a0,8
    80003922:	854a                	mv	a0,s2
    80003924:	00004097          	auipc	ra,0x4
    80003928:	9d0080e7          	jalr	-1584(ra) # 800072f4 <acquire>
  lk->locked = 0;
    8000392c:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003930:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003934:	8526                	mv	a0,s1
    80003936:	ffffe097          	auipc	ra,0xffffe
    8000393a:	f6a080e7          	jalr	-150(ra) # 800018a0 <wakeup>
  release(&lk->lk);
    8000393e:	854a                	mv	a0,s2
    80003940:	00004097          	auipc	ra,0x4
    80003944:	a68080e7          	jalr	-1432(ra) # 800073a8 <release>
}
    80003948:	60e2                	ld	ra,24(sp)
    8000394a:	6442                	ld	s0,16(sp)
    8000394c:	64a2                	ld	s1,8(sp)
    8000394e:	6902                	ld	s2,0(sp)
    80003950:	6105                	addi	sp,sp,32
    80003952:	8082                	ret

0000000080003954 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003954:	7179                	addi	sp,sp,-48
    80003956:	f406                	sd	ra,40(sp)
    80003958:	f022                	sd	s0,32(sp)
    8000395a:	ec26                	sd	s1,24(sp)
    8000395c:	e84a                	sd	s2,16(sp)
    8000395e:	e44e                	sd	s3,8(sp)
    80003960:	1800                	addi	s0,sp,48
    80003962:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003964:	00850913          	addi	s2,a0,8
    80003968:	854a                	mv	a0,s2
    8000396a:	00004097          	auipc	ra,0x4
    8000396e:	98a080e7          	jalr	-1654(ra) # 800072f4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003972:	409c                	lw	a5,0(s1)
    80003974:	ef99                	bnez	a5,80003992 <holdingsleep+0x3e>
    80003976:	4481                	li	s1,0
  release(&lk->lk);
    80003978:	854a                	mv	a0,s2
    8000397a:	00004097          	auipc	ra,0x4
    8000397e:	a2e080e7          	jalr	-1490(ra) # 800073a8 <release>
  return r;
}
    80003982:	8526                	mv	a0,s1
    80003984:	70a2                	ld	ra,40(sp)
    80003986:	7402                	ld	s0,32(sp)
    80003988:	64e2                	ld	s1,24(sp)
    8000398a:	6942                	ld	s2,16(sp)
    8000398c:	69a2                	ld	s3,8(sp)
    8000398e:	6145                	addi	sp,sp,48
    80003990:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    80003992:	0284a983          	lw	s3,40(s1)
    80003996:	ffffd097          	auipc	ra,0xffffd
    8000399a:	56a080e7          	jalr	1386(ra) # 80000f00 <myproc>
    8000399e:	5d04                	lw	s1,56(a0)
    800039a0:	413484b3          	sub	s1,s1,s3
    800039a4:	0014b493          	seqz	s1,s1
    800039a8:	bfc1                	j	80003978 <holdingsleep+0x24>

00000000800039aa <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800039aa:	1141                	addi	sp,sp,-16
    800039ac:	e406                	sd	ra,8(sp)
    800039ae:	e022                	sd	s0,0(sp)
    800039b0:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800039b2:	00006597          	auipc	a1,0x6
    800039b6:	c7658593          	addi	a1,a1,-906 # 80009628 <syscalls+0x2a0>
    800039ba:	00016517          	auipc	a0,0x16
    800039be:	7b650513          	addi	a0,a0,1974 # 8001a170 <ftable>
    800039c2:	00004097          	auipc	ra,0x4
    800039c6:	8a2080e7          	jalr	-1886(ra) # 80007264 <initlock>
}
    800039ca:	60a2                	ld	ra,8(sp)
    800039cc:	6402                	ld	s0,0(sp)
    800039ce:	0141                	addi	sp,sp,16
    800039d0:	8082                	ret

00000000800039d2 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800039d2:	1101                	addi	sp,sp,-32
    800039d4:	ec06                	sd	ra,24(sp)
    800039d6:	e822                	sd	s0,16(sp)
    800039d8:	e426                	sd	s1,8(sp)
    800039da:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    800039dc:	00016517          	auipc	a0,0x16
    800039e0:	79450513          	addi	a0,a0,1940 # 8001a170 <ftable>
    800039e4:	00004097          	auipc	ra,0x4
    800039e8:	910080e7          	jalr	-1776(ra) # 800072f4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    if(f->ref == 0){
    800039ec:	00016797          	auipc	a5,0x16
    800039f0:	78478793          	addi	a5,a5,1924 # 8001a170 <ftable>
    800039f4:	4fdc                	lw	a5,28(a5)
    800039f6:	cb8d                	beqz	a5,80003a28 <filealloc+0x56>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    800039f8:	00016497          	auipc	s1,0x16
    800039fc:	7c048493          	addi	s1,s1,1984 # 8001a1b8 <ftable+0x48>
    80003a00:	00018717          	auipc	a4,0x18
    80003a04:	a4870713          	addi	a4,a4,-1464 # 8001b448 <ftable+0x12d8>
    if(f->ref == 0){
    80003a08:	40dc                	lw	a5,4(s1)
    80003a0a:	c39d                	beqz	a5,80003a30 <filealloc+0x5e>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a0c:	03048493          	addi	s1,s1,48
    80003a10:	fee49ce3          	bne	s1,a4,80003a08 <filealloc+0x36>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003a14:	00016517          	auipc	a0,0x16
    80003a18:	75c50513          	addi	a0,a0,1884 # 8001a170 <ftable>
    80003a1c:	00004097          	auipc	ra,0x4
    80003a20:	98c080e7          	jalr	-1652(ra) # 800073a8 <release>
  return 0;
    80003a24:	4481                	li	s1,0
    80003a26:	a839                	j	80003a44 <filealloc+0x72>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003a28:	00016497          	auipc	s1,0x16
    80003a2c:	76048493          	addi	s1,s1,1888 # 8001a188 <ftable+0x18>
      f->ref = 1;
    80003a30:	4785                	li	a5,1
    80003a32:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003a34:	00016517          	auipc	a0,0x16
    80003a38:	73c50513          	addi	a0,a0,1852 # 8001a170 <ftable>
    80003a3c:	00004097          	auipc	ra,0x4
    80003a40:	96c080e7          	jalr	-1684(ra) # 800073a8 <release>
}
    80003a44:	8526                	mv	a0,s1
    80003a46:	60e2                	ld	ra,24(sp)
    80003a48:	6442                	ld	s0,16(sp)
    80003a4a:	64a2                	ld	s1,8(sp)
    80003a4c:	6105                	addi	sp,sp,32
    80003a4e:	8082                	ret

0000000080003a50 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003a50:	1101                	addi	sp,sp,-32
    80003a52:	ec06                	sd	ra,24(sp)
    80003a54:	e822                	sd	s0,16(sp)
    80003a56:	e426                	sd	s1,8(sp)
    80003a58:	1000                	addi	s0,sp,32
    80003a5a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003a5c:	00016517          	auipc	a0,0x16
    80003a60:	71450513          	addi	a0,a0,1812 # 8001a170 <ftable>
    80003a64:	00004097          	auipc	ra,0x4
    80003a68:	890080e7          	jalr	-1904(ra) # 800072f4 <acquire>
  if(f->ref < 1)
    80003a6c:	40dc                	lw	a5,4(s1)
    80003a6e:	02f05263          	blez	a5,80003a92 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80003a72:	2785                	addiw	a5,a5,1
    80003a74:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003a76:	00016517          	auipc	a0,0x16
    80003a7a:	6fa50513          	addi	a0,a0,1786 # 8001a170 <ftable>
    80003a7e:	00004097          	auipc	ra,0x4
    80003a82:	92a080e7          	jalr	-1750(ra) # 800073a8 <release>
  return f;
}
    80003a86:	8526                	mv	a0,s1
    80003a88:	60e2                	ld	ra,24(sp)
    80003a8a:	6442                	ld	s0,16(sp)
    80003a8c:	64a2                	ld	s1,8(sp)
    80003a8e:	6105                	addi	sp,sp,32
    80003a90:	8082                	ret
    panic("filedup");
    80003a92:	00006517          	auipc	a0,0x6
    80003a96:	b9e50513          	addi	a0,a0,-1122 # 80009630 <syscalls+0x2a8>
    80003a9a:	00003097          	auipc	ra,0x3
    80003a9e:	2ee080e7          	jalr	750(ra) # 80006d88 <panic>

0000000080003aa2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003aa2:	7139                	addi	sp,sp,-64
    80003aa4:	fc06                	sd	ra,56(sp)
    80003aa6:	f822                	sd	s0,48(sp)
    80003aa8:	f426                	sd	s1,40(sp)
    80003aaa:	f04a                	sd	s2,32(sp)
    80003aac:	ec4e                	sd	s3,24(sp)
    80003aae:	e852                	sd	s4,16(sp)
    80003ab0:	e456                	sd	s5,8(sp)
    80003ab2:	e05a                	sd	s6,0(sp)
    80003ab4:	0080                	addi	s0,sp,64
    80003ab6:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003ab8:	00016517          	auipc	a0,0x16
    80003abc:	6b850513          	addi	a0,a0,1720 # 8001a170 <ftable>
    80003ac0:	00004097          	auipc	ra,0x4
    80003ac4:	834080e7          	jalr	-1996(ra) # 800072f4 <acquire>
  if(f->ref < 1)
    80003ac8:	40dc                	lw	a5,4(s1)
    80003aca:	04f05f63          	blez	a5,80003b28 <fileclose+0x86>
    panic("fileclose");
  if(--f->ref > 0){
    80003ace:	37fd                	addiw	a5,a5,-1
    80003ad0:	0007871b          	sext.w	a4,a5
    80003ad4:	c0dc                	sw	a5,4(s1)
    80003ad6:	06e04163          	bgtz	a4,80003b38 <fileclose+0x96>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003ada:	0004a903          	lw	s2,0(s1)
    80003ade:	0094ca83          	lbu	s5,9(s1)
    80003ae2:	0104ba03          	ld	s4,16(s1)
    80003ae6:	0184b983          	ld	s3,24(s1)
    80003aea:	0204bb03          	ld	s6,32(s1)
  f->ref = 0;
    80003aee:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003af2:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003af6:	00016517          	auipc	a0,0x16
    80003afa:	67a50513          	addi	a0,a0,1658 # 8001a170 <ftable>
    80003afe:	00004097          	auipc	ra,0x4
    80003b02:	8aa080e7          	jalr	-1878(ra) # 800073a8 <release>

  if(ff.type == FD_PIPE){
    80003b06:	4785                	li	a5,1
    80003b08:	04f90a63          	beq	s2,a5,80003b5c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003b0c:	ffe9079b          	addiw	a5,s2,-2
    80003b10:	4705                	li	a4,1
    80003b12:	04f77c63          	bleu	a5,a4,80003b6a <fileclose+0xc8>
    begin_op();
    iput(ff.ip);
    end_op();
  }
#ifdef LAB_NET
  else if(ff.type == FD_SOCK){
    80003b16:	4791                	li	a5,4
    80003b18:	02f91863          	bne	s2,a5,80003b48 <fileclose+0xa6>
    sockclose(ff.sock);
    80003b1c:	855a                	mv	a0,s6
    80003b1e:	00003097          	auipc	ra,0x3
    80003b22:	9d8080e7          	jalr	-1576(ra) # 800064f6 <sockclose>
    80003b26:	a00d                	j	80003b48 <fileclose+0xa6>
    panic("fileclose");
    80003b28:	00006517          	auipc	a0,0x6
    80003b2c:	b1050513          	addi	a0,a0,-1264 # 80009638 <syscalls+0x2b0>
    80003b30:	00003097          	auipc	ra,0x3
    80003b34:	258080e7          	jalr	600(ra) # 80006d88 <panic>
    release(&ftable.lock);
    80003b38:	00016517          	auipc	a0,0x16
    80003b3c:	63850513          	addi	a0,a0,1592 # 8001a170 <ftable>
    80003b40:	00004097          	auipc	ra,0x4
    80003b44:	868080e7          	jalr	-1944(ra) # 800073a8 <release>
  }
#endif
}
    80003b48:	70e2                	ld	ra,56(sp)
    80003b4a:	7442                	ld	s0,48(sp)
    80003b4c:	74a2                	ld	s1,40(sp)
    80003b4e:	7902                	ld	s2,32(sp)
    80003b50:	69e2                	ld	s3,24(sp)
    80003b52:	6a42                	ld	s4,16(sp)
    80003b54:	6aa2                	ld	s5,8(sp)
    80003b56:	6b02                	ld	s6,0(sp)
    80003b58:	6121                	addi	sp,sp,64
    80003b5a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003b5c:	85d6                	mv	a1,s5
    80003b5e:	8552                	mv	a0,s4
    80003b60:	00000097          	auipc	ra,0x0
    80003b64:	37c080e7          	jalr	892(ra) # 80003edc <pipeclose>
    80003b68:	b7c5                	j	80003b48 <fileclose+0xa6>
    begin_op();
    80003b6a:	00000097          	auipc	ra,0x0
    80003b6e:	a34080e7          	jalr	-1484(ra) # 8000359e <begin_op>
    iput(ff.ip);
    80003b72:	854e                	mv	a0,s3
    80003b74:	fffff097          	auipc	ra,0xfffff
    80003b78:	208080e7          	jalr	520(ra) # 80002d7c <iput>
    end_op();
    80003b7c:	00000097          	auipc	ra,0x0
    80003b80:	aa2080e7          	jalr	-1374(ra) # 8000361e <end_op>
    80003b84:	b7d1                	j	80003b48 <fileclose+0xa6>

0000000080003b86 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80003b86:	715d                	addi	sp,sp,-80
    80003b88:	e486                	sd	ra,72(sp)
    80003b8a:	e0a2                	sd	s0,64(sp)
    80003b8c:	fc26                	sd	s1,56(sp)
    80003b8e:	f84a                	sd	s2,48(sp)
    80003b90:	f44e                	sd	s3,40(sp)
    80003b92:	0880                	addi	s0,sp,80
    80003b94:	84aa                	mv	s1,a0
    80003b96:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80003b98:	ffffd097          	auipc	ra,0xffffd
    80003b9c:	368080e7          	jalr	872(ra) # 80000f00 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80003ba0:	409c                	lw	a5,0(s1)
    80003ba2:	37f9                	addiw	a5,a5,-2
    80003ba4:	4705                	li	a4,1
    80003ba6:	04f76763          	bltu	a4,a5,80003bf4 <filestat+0x6e>
    80003baa:	892a                	mv	s2,a0
    ilock(f->ip);
    80003bac:	6c88                	ld	a0,24(s1)
    80003bae:	fffff097          	auipc	ra,0xfffff
    80003bb2:	012080e7          	jalr	18(ra) # 80002bc0 <ilock>
    stati(f->ip, &st);
    80003bb6:	fb840593          	addi	a1,s0,-72
    80003bba:	6c88                	ld	a0,24(s1)
    80003bbc:	fffff097          	auipc	ra,0xfffff
    80003bc0:	290080e7          	jalr	656(ra) # 80002e4c <stati>
    iunlock(f->ip);
    80003bc4:	6c88                	ld	a0,24(s1)
    80003bc6:	fffff097          	auipc	ra,0xfffff
    80003bca:	0be080e7          	jalr	190(ra) # 80002c84 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    80003bce:	46e1                	li	a3,24
    80003bd0:	fb840613          	addi	a2,s0,-72
    80003bd4:	85ce                	mv	a1,s3
    80003bd6:	05093503          	ld	a0,80(s2)
    80003bda:	ffffd097          	auipc	ra,0xffffd
    80003bde:	fa4080e7          	jalr	-92(ra) # 80000b7e <copyout>
    80003be2:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    80003be6:	60a6                	ld	ra,72(sp)
    80003be8:	6406                	ld	s0,64(sp)
    80003bea:	74e2                	ld	s1,56(sp)
    80003bec:	7942                	ld	s2,48(sp)
    80003bee:	79a2                	ld	s3,40(sp)
    80003bf0:	6161                	addi	sp,sp,80
    80003bf2:	8082                	ret
  return -1;
    80003bf4:	557d                	li	a0,-1
    80003bf6:	bfc5                	j	80003be6 <filestat+0x60>

0000000080003bf8 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80003bf8:	7179                	addi	sp,sp,-48
    80003bfa:	f406                	sd	ra,40(sp)
    80003bfc:	f022                	sd	s0,32(sp)
    80003bfe:	ec26                	sd	s1,24(sp)
    80003c00:	e84a                	sd	s2,16(sp)
    80003c02:	e44e                	sd	s3,8(sp)
    80003c04:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    80003c06:	00854783          	lbu	a5,8(a0)
    80003c0a:	cfc5                	beqz	a5,80003cc2 <fileread+0xca>
    80003c0c:	89b2                	mv	s3,a2
    80003c0e:	892e                	mv	s2,a1
    80003c10:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80003c12:	411c                	lw	a5,0(a0)
    80003c14:	4705                	li	a4,1
    80003c16:	02e78963          	beq	a5,a4,80003c48 <fileread+0x50>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003c1a:	470d                	li	a4,3
    80003c1c:	02e78d63          	beq	a5,a4,80003c56 <fileread+0x5e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80003c20:	4709                	li	a4,2
    80003c22:	04e78e63          	beq	a5,a4,80003c7e <fileread+0x86>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
      f->off += r;
    iunlock(f->ip);
  }
#ifdef LAB_NET
  else if(f->type == FD_SOCK){
    80003c26:	4711                	li	a4,4
    80003c28:	08e79563          	bne	a5,a4,80003cb2 <fileread+0xba>
    r = sockread(f->sock, addr, n);
    80003c2c:	7108                	ld	a0,32(a0)
    80003c2e:	00003097          	auipc	ra,0x3
    80003c32:	95a080e7          	jalr	-1702(ra) # 80006588 <sockread>
    80003c36:	892a                	mv	s2,a0
  else {
    panic("fileread");
  }

  return r;
}
    80003c38:	854a                	mv	a0,s2
    80003c3a:	70a2                	ld	ra,40(sp)
    80003c3c:	7402                	ld	s0,32(sp)
    80003c3e:	64e2                	ld	s1,24(sp)
    80003c40:	6942                	ld	s2,16(sp)
    80003c42:	69a2                	ld	s3,8(sp)
    80003c44:	6145                	addi	sp,sp,48
    80003c46:	8082                	ret
    r = piperead(f->pipe, addr, n);
    80003c48:	6908                	ld	a0,16(a0)
    80003c4a:	00000097          	auipc	ra,0x0
    80003c4e:	408080e7          	jalr	1032(ra) # 80004052 <piperead>
    80003c52:	892a                	mv	s2,a0
    80003c54:	b7d5                	j	80003c38 <fileread+0x40>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    80003c56:	02c51783          	lh	a5,44(a0)
    80003c5a:	03079693          	slli	a3,a5,0x30
    80003c5e:	92c1                	srli	a3,a3,0x30
    80003c60:	4725                	li	a4,9
    80003c62:	06d76263          	bltu	a4,a3,80003cc6 <fileread+0xce>
    80003c66:	0792                	slli	a5,a5,0x4
    80003c68:	00016717          	auipc	a4,0x16
    80003c6c:	46870713          	addi	a4,a4,1128 # 8001a0d0 <devsw>
    80003c70:	97ba                	add	a5,a5,a4
    80003c72:	639c                	ld	a5,0(a5)
    80003c74:	cbb9                	beqz	a5,80003cca <fileread+0xd2>
    r = devsw[f->major].read(1, addr, n);
    80003c76:	4505                	li	a0,1
    80003c78:	9782                	jalr	a5
    80003c7a:	892a                	mv	s2,a0
    80003c7c:	bf75                	j	80003c38 <fileread+0x40>
    ilock(f->ip);
    80003c7e:	6d08                	ld	a0,24(a0)
    80003c80:	fffff097          	auipc	ra,0xfffff
    80003c84:	f40080e7          	jalr	-192(ra) # 80002bc0 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80003c88:	874e                	mv	a4,s3
    80003c8a:	5494                	lw	a3,40(s1)
    80003c8c:	864a                	mv	a2,s2
    80003c8e:	4585                	li	a1,1
    80003c90:	6c88                	ld	a0,24(s1)
    80003c92:	fffff097          	auipc	ra,0xfffff
    80003c96:	1e4080e7          	jalr	484(ra) # 80002e76 <readi>
    80003c9a:	892a                	mv	s2,a0
    80003c9c:	00a05563          	blez	a0,80003ca6 <fileread+0xae>
      f->off += r;
    80003ca0:	549c                	lw	a5,40(s1)
    80003ca2:	9fa9                	addw	a5,a5,a0
    80003ca4:	d49c                	sw	a5,40(s1)
    iunlock(f->ip);
    80003ca6:	6c88                	ld	a0,24(s1)
    80003ca8:	fffff097          	auipc	ra,0xfffff
    80003cac:	fdc080e7          	jalr	-36(ra) # 80002c84 <iunlock>
    80003cb0:	b761                	j	80003c38 <fileread+0x40>
    panic("fileread");
    80003cb2:	00006517          	auipc	a0,0x6
    80003cb6:	99650513          	addi	a0,a0,-1642 # 80009648 <syscalls+0x2c0>
    80003cba:	00003097          	auipc	ra,0x3
    80003cbe:	0ce080e7          	jalr	206(ra) # 80006d88 <panic>
    return -1;
    80003cc2:	597d                	li	s2,-1
    80003cc4:	bf95                	j	80003c38 <fileread+0x40>
      return -1;
    80003cc6:	597d                	li	s2,-1
    80003cc8:	bf85                	j	80003c38 <fileread+0x40>
    80003cca:	597d                	li	s2,-1
    80003ccc:	b7b5                	j	80003c38 <fileread+0x40>

0000000080003cce <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80003cce:	00954783          	lbu	a5,9(a0)
    80003cd2:	12078263          	beqz	a5,80003df6 <filewrite+0x128>
{
    80003cd6:	715d                	addi	sp,sp,-80
    80003cd8:	e486                	sd	ra,72(sp)
    80003cda:	e0a2                	sd	s0,64(sp)
    80003cdc:	fc26                	sd	s1,56(sp)
    80003cde:	f84a                	sd	s2,48(sp)
    80003ce0:	f44e                	sd	s3,40(sp)
    80003ce2:	f052                	sd	s4,32(sp)
    80003ce4:	ec56                	sd	s5,24(sp)
    80003ce6:	e85a                	sd	s6,16(sp)
    80003ce8:	e45e                	sd	s7,8(sp)
    80003cea:	e062                	sd	s8,0(sp)
    80003cec:	0880                	addi	s0,sp,80
    80003cee:	89b2                	mv	s3,a2
    80003cf0:	8aae                	mv	s5,a1
    80003cf2:	84aa                	mv	s1,a0
    return -1;

  if(f->type == FD_PIPE){
    80003cf4:	411c                	lw	a5,0(a0)
    80003cf6:	4705                	li	a4,1
    80003cf8:	02e78c63          	beq	a5,a4,80003d30 <filewrite+0x62>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80003cfc:	470d                	li	a4,3
    80003cfe:	02e78f63          	beq	a5,a4,80003d3c <filewrite+0x6e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    80003d02:	4709                	li	a4,2
    80003d04:	04e78f63          	beq	a5,a4,80003d62 <filewrite+0x94>
      i += r;
    }
    ret = (i == n ? n : -1);
  }
#ifdef LAB_NET
  else if(f->type == FD_SOCK){
    80003d08:	4711                	li	a4,4
    80003d0a:	0ce79e63          	bne	a5,a4,80003de6 <filewrite+0x118>
    ret = sockwrite(f->sock, addr, n);
    80003d0e:	7108                	ld	a0,32(a0)
    80003d10:	00003097          	auipc	ra,0x3
    80003d14:	950080e7          	jalr	-1712(ra) # 80006660 <sockwrite>
  else {
    panic("filewrite");
  }

  return ret;
}
    80003d18:	60a6                	ld	ra,72(sp)
    80003d1a:	6406                	ld	s0,64(sp)
    80003d1c:	74e2                	ld	s1,56(sp)
    80003d1e:	7942                	ld	s2,48(sp)
    80003d20:	79a2                	ld	s3,40(sp)
    80003d22:	7a02                	ld	s4,32(sp)
    80003d24:	6ae2                	ld	s5,24(sp)
    80003d26:	6b42                	ld	s6,16(sp)
    80003d28:	6ba2                	ld	s7,8(sp)
    80003d2a:	6c02                	ld	s8,0(sp)
    80003d2c:	6161                	addi	sp,sp,80
    80003d2e:	8082                	ret
    ret = pipewrite(f->pipe, addr, n);
    80003d30:	6908                	ld	a0,16(a0)
    80003d32:	00000097          	auipc	ra,0x0
    80003d36:	21a080e7          	jalr	538(ra) # 80003f4c <pipewrite>
    80003d3a:	bff9                	j	80003d18 <filewrite+0x4a>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80003d3c:	02c51783          	lh	a5,44(a0)
    80003d40:	03079693          	slli	a3,a5,0x30
    80003d44:	92c1                	srli	a3,a3,0x30
    80003d46:	4725                	li	a4,9
    80003d48:	0ad76963          	bltu	a4,a3,80003dfa <filewrite+0x12c>
    80003d4c:	0792                	slli	a5,a5,0x4
    80003d4e:	00016717          	auipc	a4,0x16
    80003d52:	38270713          	addi	a4,a4,898 # 8001a0d0 <devsw>
    80003d56:	97ba                	add	a5,a5,a4
    80003d58:	679c                	ld	a5,8(a5)
    80003d5a:	c3d5                	beqz	a5,80003dfe <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80003d5c:	4505                	li	a0,1
    80003d5e:	9782                	jalr	a5
    80003d60:	bf65                	j	80003d18 <filewrite+0x4a>
    while(i < n){
    80003d62:	06c05c63          	blez	a2,80003dda <filewrite+0x10c>
    int i = 0;
    80003d66:	4901                	li	s2,0
    80003d68:	6b85                	lui	s7,0x1
    80003d6a:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80003d6e:	6c05                	lui	s8,0x1
    80003d70:	c00c0c1b          	addiw	s8,s8,-1024
    80003d74:	a899                	j	80003dca <filewrite+0xfc>
    80003d76:	000a0b1b          	sext.w	s6,s4
      begin_op();
    80003d7a:	00000097          	auipc	ra,0x0
    80003d7e:	824080e7          	jalr	-2012(ra) # 8000359e <begin_op>
      ilock(f->ip);
    80003d82:	6c88                	ld	a0,24(s1)
    80003d84:	fffff097          	auipc	ra,0xfffff
    80003d88:	e3c080e7          	jalr	-452(ra) # 80002bc0 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80003d8c:	875a                	mv	a4,s6
    80003d8e:	5494                	lw	a3,40(s1)
    80003d90:	01590633          	add	a2,s2,s5
    80003d94:	4585                	li	a1,1
    80003d96:	6c88                	ld	a0,24(s1)
    80003d98:	fffff097          	auipc	ra,0xfffff
    80003d9c:	1d6080e7          	jalr	470(ra) # 80002f6e <writei>
    80003da0:	8a2a                	mv	s4,a0
    80003da2:	00a05563          	blez	a0,80003dac <filewrite+0xde>
        f->off += r;
    80003da6:	549c                	lw	a5,40(s1)
    80003da8:	9fa9                	addw	a5,a5,a0
    80003daa:	d49c                	sw	a5,40(s1)
      iunlock(f->ip);
    80003dac:	6c88                	ld	a0,24(s1)
    80003dae:	fffff097          	auipc	ra,0xfffff
    80003db2:	ed6080e7          	jalr	-298(ra) # 80002c84 <iunlock>
      end_op();
    80003db6:	00000097          	auipc	ra,0x0
    80003dba:	868080e7          	jalr	-1944(ra) # 8000361e <end_op>
      if(r != n1){
    80003dbe:	016a1f63          	bne	s4,s6,80003ddc <filewrite+0x10e>
      i += r;
    80003dc2:	012b093b          	addw	s2,s6,s2
    while(i < n){
    80003dc6:	01395b63          	ble	s3,s2,80003ddc <filewrite+0x10e>
      int n1 = n - i;
    80003dca:	412987bb          	subw	a5,s3,s2
      if(n1 > max)
    80003dce:	8a3e                	mv	s4,a5
    80003dd0:	2781                	sext.w	a5,a5
    80003dd2:	fafbd2e3          	ble	a5,s7,80003d76 <filewrite+0xa8>
    80003dd6:	8a62                	mv	s4,s8
    80003dd8:	bf79                	j	80003d76 <filewrite+0xa8>
    int i = 0;
    80003dda:	4901                	li	s2,0
    ret = (i == n ? n : -1);
    80003ddc:	854e                	mv	a0,s3
    80003dde:	f3298de3          	beq	s3,s2,80003d18 <filewrite+0x4a>
    80003de2:	557d                	li	a0,-1
    80003de4:	bf15                	j	80003d18 <filewrite+0x4a>
    panic("filewrite");
    80003de6:	00006517          	auipc	a0,0x6
    80003dea:	87250513          	addi	a0,a0,-1934 # 80009658 <syscalls+0x2d0>
    80003dee:	00003097          	auipc	ra,0x3
    80003df2:	f9a080e7          	jalr	-102(ra) # 80006d88 <panic>
    return -1;
    80003df6:	557d                	li	a0,-1
}
    80003df8:	8082                	ret
      return -1;
    80003dfa:	557d                	li	a0,-1
    80003dfc:	bf31                	j	80003d18 <filewrite+0x4a>
    80003dfe:	557d                	li	a0,-1
    80003e00:	bf21                	j	80003d18 <filewrite+0x4a>

0000000080003e02 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80003e02:	7179                	addi	sp,sp,-48
    80003e04:	f406                	sd	ra,40(sp)
    80003e06:	f022                	sd	s0,32(sp)
    80003e08:	ec26                	sd	s1,24(sp)
    80003e0a:	e84a                	sd	s2,16(sp)
    80003e0c:	e44e                	sd	s3,8(sp)
    80003e0e:	e052                	sd	s4,0(sp)
    80003e10:	1800                	addi	s0,sp,48
    80003e12:	84aa                	mv	s1,a0
    80003e14:	892e                	mv	s2,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80003e16:	0005b023          	sd	zero,0(a1)
    80003e1a:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80003e1e:	00000097          	auipc	ra,0x0
    80003e22:	bb4080e7          	jalr	-1100(ra) # 800039d2 <filealloc>
    80003e26:	e088                	sd	a0,0(s1)
    80003e28:	c551                	beqz	a0,80003eb4 <pipealloc+0xb2>
    80003e2a:	00000097          	auipc	ra,0x0
    80003e2e:	ba8080e7          	jalr	-1112(ra) # 800039d2 <filealloc>
    80003e32:	00a93023          	sd	a0,0(s2)
    80003e36:	c92d                	beqz	a0,80003ea8 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80003e38:	ffffc097          	auipc	ra,0xffffc
    80003e3c:	2e4080e7          	jalr	740(ra) # 8000011c <kalloc>
    80003e40:	89aa                	mv	s3,a0
    80003e42:	c125                	beqz	a0,80003ea2 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80003e44:	4a05                	li	s4,1
    80003e46:	23452023          	sw	s4,544(a0)
  pi->writeopen = 1;
    80003e4a:	23452223          	sw	s4,548(a0)
  pi->nwrite = 0;
    80003e4e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80003e52:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80003e56:	00006597          	auipc	a1,0x6
    80003e5a:	81258593          	addi	a1,a1,-2030 # 80009668 <syscalls+0x2e0>
    80003e5e:	00003097          	auipc	ra,0x3
    80003e62:	406080e7          	jalr	1030(ra) # 80007264 <initlock>
  (*f0)->type = FD_PIPE;
    80003e66:	609c                	ld	a5,0(s1)
    80003e68:	0147a023          	sw	s4,0(a5)
  (*f0)->readable = 1;
    80003e6c:	609c                	ld	a5,0(s1)
    80003e6e:	01478423          	sb	s4,8(a5)
  (*f0)->writable = 0;
    80003e72:	609c                	ld	a5,0(s1)
    80003e74:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80003e78:	609c                	ld	a5,0(s1)
    80003e7a:	0137b823          	sd	s3,16(a5)
  (*f1)->type = FD_PIPE;
    80003e7e:	00093783          	ld	a5,0(s2)
    80003e82:	0147a023          	sw	s4,0(a5)
  (*f1)->readable = 0;
    80003e86:	00093783          	ld	a5,0(s2)
    80003e8a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80003e8e:	00093783          	ld	a5,0(s2)
    80003e92:	014784a3          	sb	s4,9(a5)
  (*f1)->pipe = pi;
    80003e96:	00093783          	ld	a5,0(s2)
    80003e9a:	0137b823          	sd	s3,16(a5)
  return 0;
    80003e9e:	4501                	li	a0,0
    80003ea0:	a025                	j	80003ec8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80003ea2:	6088                	ld	a0,0(s1)
    80003ea4:	e501                	bnez	a0,80003eac <pipealloc+0xaa>
    80003ea6:	a039                	j	80003eb4 <pipealloc+0xb2>
    80003ea8:	6088                	ld	a0,0(s1)
    80003eaa:	c51d                	beqz	a0,80003ed8 <pipealloc+0xd6>
    fileclose(*f0);
    80003eac:	00000097          	auipc	ra,0x0
    80003eb0:	bf6080e7          	jalr	-1034(ra) # 80003aa2 <fileclose>
  if(*f1)
    80003eb4:	00093783          	ld	a5,0(s2)
    fileclose(*f1);
  return -1;
    80003eb8:	557d                	li	a0,-1
  if(*f1)
    80003eba:	c799                	beqz	a5,80003ec8 <pipealloc+0xc6>
    fileclose(*f1);
    80003ebc:	853e                	mv	a0,a5
    80003ebe:	00000097          	auipc	ra,0x0
    80003ec2:	be4080e7          	jalr	-1052(ra) # 80003aa2 <fileclose>
  return -1;
    80003ec6:	557d                	li	a0,-1
}
    80003ec8:	70a2                	ld	ra,40(sp)
    80003eca:	7402                	ld	s0,32(sp)
    80003ecc:	64e2                	ld	s1,24(sp)
    80003ece:	6942                	ld	s2,16(sp)
    80003ed0:	69a2                	ld	s3,8(sp)
    80003ed2:	6a02                	ld	s4,0(sp)
    80003ed4:	6145                	addi	sp,sp,48
    80003ed6:	8082                	ret
  return -1;
    80003ed8:	557d                	li	a0,-1
    80003eda:	b7fd                	j	80003ec8 <pipealloc+0xc6>

0000000080003edc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80003edc:	1101                	addi	sp,sp,-32
    80003ede:	ec06                	sd	ra,24(sp)
    80003ee0:	e822                	sd	s0,16(sp)
    80003ee2:	e426                	sd	s1,8(sp)
    80003ee4:	e04a                	sd	s2,0(sp)
    80003ee6:	1000                	addi	s0,sp,32
    80003ee8:	84aa                	mv	s1,a0
    80003eea:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80003eec:	00003097          	auipc	ra,0x3
    80003ef0:	408080e7          	jalr	1032(ra) # 800072f4 <acquire>
  if(writable){
    80003ef4:	02090d63          	beqz	s2,80003f2e <pipeclose+0x52>
    pi->writeopen = 0;
    80003ef8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80003efc:	21848513          	addi	a0,s1,536
    80003f00:	ffffe097          	auipc	ra,0xffffe
    80003f04:	9a0080e7          	jalr	-1632(ra) # 800018a0 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80003f08:	2204b783          	ld	a5,544(s1)
    80003f0c:	eb95                	bnez	a5,80003f40 <pipeclose+0x64>
    release(&pi->lock);
    80003f0e:	8526                	mv	a0,s1
    80003f10:	00003097          	auipc	ra,0x3
    80003f14:	498080e7          	jalr	1176(ra) # 800073a8 <release>
    kfree((char*)pi);
    80003f18:	8526                	mv	a0,s1
    80003f1a:	ffffc097          	auipc	ra,0xffffc
    80003f1e:	102080e7          	jalr	258(ra) # 8000001c <kfree>
  } else
    release(&pi->lock);
}
    80003f22:	60e2                	ld	ra,24(sp)
    80003f24:	6442                	ld	s0,16(sp)
    80003f26:	64a2                	ld	s1,8(sp)
    80003f28:	6902                	ld	s2,0(sp)
    80003f2a:	6105                	addi	sp,sp,32
    80003f2c:	8082                	ret
    pi->readopen = 0;
    80003f2e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80003f32:	21c48513          	addi	a0,s1,540
    80003f36:	ffffe097          	auipc	ra,0xffffe
    80003f3a:	96a080e7          	jalr	-1686(ra) # 800018a0 <wakeup>
    80003f3e:	b7e9                	j	80003f08 <pipeclose+0x2c>
    release(&pi->lock);
    80003f40:	8526                	mv	a0,s1
    80003f42:	00003097          	auipc	ra,0x3
    80003f46:	466080e7          	jalr	1126(ra) # 800073a8 <release>
}
    80003f4a:	bfe1                	j	80003f22 <pipeclose+0x46>

0000000080003f4c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80003f4c:	7159                	addi	sp,sp,-112
    80003f4e:	f486                	sd	ra,104(sp)
    80003f50:	f0a2                	sd	s0,96(sp)
    80003f52:	eca6                	sd	s1,88(sp)
    80003f54:	e8ca                	sd	s2,80(sp)
    80003f56:	e4ce                	sd	s3,72(sp)
    80003f58:	e0d2                	sd	s4,64(sp)
    80003f5a:	fc56                	sd	s5,56(sp)
    80003f5c:	f85a                	sd	s6,48(sp)
    80003f5e:	f45e                	sd	s7,40(sp)
    80003f60:	f062                	sd	s8,32(sp)
    80003f62:	ec66                	sd	s9,24(sp)
    80003f64:	1880                	addi	s0,sp,112
    80003f66:	84aa                	mv	s1,a0
    80003f68:	8aae                	mv	s5,a1
    80003f6a:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80003f6c:	ffffd097          	auipc	ra,0xffffd
    80003f70:	f94080e7          	jalr	-108(ra) # 80000f00 <myproc>
    80003f74:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80003f76:	8526                	mv	a0,s1
    80003f78:	00003097          	auipc	ra,0x3
    80003f7c:	37c080e7          	jalr	892(ra) # 800072f4 <acquire>
  while(i < n){
    80003f80:	0d405763          	blez	s4,8000404e <pipewrite+0x102>
    80003f84:	8ba6                	mv	s7,s1
    if(pi->readopen == 0 || pr->killed){
    80003f86:	2204a783          	lw	a5,544(s1)
    80003f8a:	cb99                	beqz	a5,80003fa0 <pipewrite+0x54>
    80003f8c:	0309a903          	lw	s2,48(s3)
    80003f90:	00091863          	bnez	s2,80003fa0 <pipewrite+0x54>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80003f94:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80003f96:	21848c93          	addi	s9,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80003f9a:	21c48c13          	addi	s8,s1,540
    80003f9e:	a0bd                	j	8000400c <pipewrite+0xc0>
      release(&pi->lock);
    80003fa0:	8526                	mv	a0,s1
    80003fa2:	00003097          	auipc	ra,0x3
    80003fa6:	406080e7          	jalr	1030(ra) # 800073a8 <release>
      return -1;
    80003faa:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80003fac:	854a                	mv	a0,s2
    80003fae:	70a6                	ld	ra,104(sp)
    80003fb0:	7406                	ld	s0,96(sp)
    80003fb2:	64e6                	ld	s1,88(sp)
    80003fb4:	6946                	ld	s2,80(sp)
    80003fb6:	69a6                	ld	s3,72(sp)
    80003fb8:	6a06                	ld	s4,64(sp)
    80003fba:	7ae2                	ld	s5,56(sp)
    80003fbc:	7b42                	ld	s6,48(sp)
    80003fbe:	7ba2                	ld	s7,40(sp)
    80003fc0:	7c02                	ld	s8,32(sp)
    80003fc2:	6ce2                	ld	s9,24(sp)
    80003fc4:	6165                	addi	sp,sp,112
    80003fc6:	8082                	ret
      wakeup(&pi->nread);
    80003fc8:	8566                	mv	a0,s9
    80003fca:	ffffe097          	auipc	ra,0xffffe
    80003fce:	8d6080e7          	jalr	-1834(ra) # 800018a0 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80003fd2:	85de                	mv	a1,s7
    80003fd4:	8562                	mv	a0,s8
    80003fd6:	ffffd097          	auipc	ra,0xffffd
    80003fda:	744080e7          	jalr	1860(ra) # 8000171a <sleep>
    80003fde:	a839                	j	80003ffc <pipewrite+0xb0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80003fe0:	21c4a783          	lw	a5,540(s1)
    80003fe4:	0017871b          	addiw	a4,a5,1
    80003fe8:	20e4ae23          	sw	a4,540(s1)
    80003fec:	1ff7f793          	andi	a5,a5,511
    80003ff0:	97a6                	add	a5,a5,s1
    80003ff2:	f9f44703          	lbu	a4,-97(s0)
    80003ff6:	00e78c23          	sb	a4,24(a5)
      i++;
    80003ffa:	2905                	addiw	s2,s2,1
  while(i < n){
    80003ffc:	03495d63          	ble	s4,s2,80004036 <pipewrite+0xea>
    if(pi->readopen == 0 || pr->killed){
    80004000:	2204a783          	lw	a5,544(s1)
    80004004:	dfd1                	beqz	a5,80003fa0 <pipewrite+0x54>
    80004006:	0309a783          	lw	a5,48(s3)
    8000400a:	fbd9                	bnez	a5,80003fa0 <pipewrite+0x54>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    8000400c:	2184a783          	lw	a5,536(s1)
    80004010:	21c4a703          	lw	a4,540(s1)
    80004014:	2007879b          	addiw	a5,a5,512
    80004018:	faf708e3          	beq	a4,a5,80003fc8 <pipewrite+0x7c>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000401c:	4685                	li	a3,1
    8000401e:	01590633          	add	a2,s2,s5
    80004022:	f9f40593          	addi	a1,s0,-97
    80004026:	0509b503          	ld	a0,80(s3)
    8000402a:	ffffd097          	auipc	ra,0xffffd
    8000402e:	be0080e7          	jalr	-1056(ra) # 80000c0a <copyin>
    80004032:	fb6517e3          	bne	a0,s6,80003fe0 <pipewrite+0x94>
  wakeup(&pi->nread);
    80004036:	21848513          	addi	a0,s1,536
    8000403a:	ffffe097          	auipc	ra,0xffffe
    8000403e:	866080e7          	jalr	-1946(ra) # 800018a0 <wakeup>
  release(&pi->lock);
    80004042:	8526                	mv	a0,s1
    80004044:	00003097          	auipc	ra,0x3
    80004048:	364080e7          	jalr	868(ra) # 800073a8 <release>
  return i;
    8000404c:	b785                	j	80003fac <pipewrite+0x60>
  int i = 0;
    8000404e:	4901                	li	s2,0
    80004050:	b7dd                	j	80004036 <pipewrite+0xea>

0000000080004052 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004052:	715d                	addi	sp,sp,-80
    80004054:	e486                	sd	ra,72(sp)
    80004056:	e0a2                	sd	s0,64(sp)
    80004058:	fc26                	sd	s1,56(sp)
    8000405a:	f84a                	sd	s2,48(sp)
    8000405c:	f44e                	sd	s3,40(sp)
    8000405e:	f052                	sd	s4,32(sp)
    80004060:	ec56                	sd	s5,24(sp)
    80004062:	e85a                	sd	s6,16(sp)
    80004064:	0880                	addi	s0,sp,80
    80004066:	84aa                	mv	s1,a0
    80004068:	89ae                	mv	s3,a1
    8000406a:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000406c:	ffffd097          	auipc	ra,0xffffd
    80004070:	e94080e7          	jalr	-364(ra) # 80000f00 <myproc>
    80004074:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004076:	8526                	mv	a0,s1
    80004078:	00003097          	auipc	ra,0x3
    8000407c:	27c080e7          	jalr	636(ra) # 800072f4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004080:	2184a703          	lw	a4,536(s1)
    80004084:	21c4a783          	lw	a5,540(s1)
    80004088:	06f71b63          	bne	a4,a5,800040fe <piperead+0xac>
    8000408c:	8926                	mv	s2,s1
    8000408e:	2244a783          	lw	a5,548(s1)
    80004092:	cf9d                	beqz	a5,800040d0 <piperead+0x7e>
    if(pr->killed){
    80004094:	030a2783          	lw	a5,48(s4)
    80004098:	e78d                	bnez	a5,800040c2 <piperead+0x70>
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000409a:	21848b13          	addi	s6,s1,536
    8000409e:	85ca                	mv	a1,s2
    800040a0:	855a                	mv	a0,s6
    800040a2:	ffffd097          	auipc	ra,0xffffd
    800040a6:	678080e7          	jalr	1656(ra) # 8000171a <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    800040aa:	2184a703          	lw	a4,536(s1)
    800040ae:	21c4a783          	lw	a5,540(s1)
    800040b2:	04f71663          	bne	a4,a5,800040fe <piperead+0xac>
    800040b6:	2244a783          	lw	a5,548(s1)
    800040ba:	cb99                	beqz	a5,800040d0 <piperead+0x7e>
    if(pr->killed){
    800040bc:	030a2783          	lw	a5,48(s4)
    800040c0:	dff9                	beqz	a5,8000409e <piperead+0x4c>
      release(&pi->lock);
    800040c2:	8526                	mv	a0,s1
    800040c4:	00003097          	auipc	ra,0x3
    800040c8:	2e4080e7          	jalr	740(ra) # 800073a8 <release>
      return -1;
    800040cc:	597d                	li	s2,-1
    800040ce:	a829                	j	800040e8 <piperead+0x96>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    if(pi->nread == pi->nwrite)
    800040d0:	4901                	li	s2,0
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    800040d2:	21c48513          	addi	a0,s1,540
    800040d6:	ffffd097          	auipc	ra,0xffffd
    800040da:	7ca080e7          	jalr	1994(ra) # 800018a0 <wakeup>
  release(&pi->lock);
    800040de:	8526                	mv	a0,s1
    800040e0:	00003097          	auipc	ra,0x3
    800040e4:	2c8080e7          	jalr	712(ra) # 800073a8 <release>
  return i;
}
    800040e8:	854a                	mv	a0,s2
    800040ea:	60a6                	ld	ra,72(sp)
    800040ec:	6406                	ld	s0,64(sp)
    800040ee:	74e2                	ld	s1,56(sp)
    800040f0:	7942                	ld	s2,48(sp)
    800040f2:	79a2                	ld	s3,40(sp)
    800040f4:	7a02                	ld	s4,32(sp)
    800040f6:	6ae2                	ld	s5,24(sp)
    800040f8:	6b42                	ld	s6,16(sp)
    800040fa:	6161                	addi	sp,sp,80
    800040fc:	8082                	ret
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800040fe:	4901                	li	s2,0
    80004100:	fd5059e3          	blez	s5,800040d2 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004104:	2184a783          	lw	a5,536(s1)
    80004108:	4901                	li	s2,0
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    8000410a:	5b7d                	li	s6,-1
    ch = pi->data[pi->nread++ % PIPESIZE];
    8000410c:	0017871b          	addiw	a4,a5,1
    80004110:	20e4ac23          	sw	a4,536(s1)
    80004114:	1ff7f793          	andi	a5,a5,511
    80004118:	97a6                	add	a5,a5,s1
    8000411a:	0187c783          	lbu	a5,24(a5)
    8000411e:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004122:	4685                	li	a3,1
    80004124:	fbf40613          	addi	a2,s0,-65
    80004128:	85ce                	mv	a1,s3
    8000412a:	050a3503          	ld	a0,80(s4)
    8000412e:	ffffd097          	auipc	ra,0xffffd
    80004132:	a50080e7          	jalr	-1456(ra) # 80000b7e <copyout>
    80004136:	f9650ee3          	beq	a0,s6,800040d2 <piperead+0x80>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    8000413a:	2905                	addiw	s2,s2,1
    8000413c:	f92a8be3          	beq	s5,s2,800040d2 <piperead+0x80>
    if(pi->nread == pi->nwrite)
    80004140:	2184a783          	lw	a5,536(s1)
    80004144:	0985                	addi	s3,s3,1
    80004146:	21c4a703          	lw	a4,540(s1)
    8000414a:	fcf711e3          	bne	a4,a5,8000410c <piperead+0xba>
    8000414e:	b751                	j	800040d2 <piperead+0x80>

0000000080004150 <exec>:

static int loadseg(pde_t *pgdir, uint64 addr, struct inode *ip, uint offset, uint sz);

int
exec(char *path, char **argv)
{
    80004150:	de010113          	addi	sp,sp,-544
    80004154:	20113c23          	sd	ra,536(sp)
    80004158:	20813823          	sd	s0,528(sp)
    8000415c:	20913423          	sd	s1,520(sp)
    80004160:	21213023          	sd	s2,512(sp)
    80004164:	ffce                	sd	s3,504(sp)
    80004166:	fbd2                	sd	s4,496(sp)
    80004168:	f7d6                	sd	s5,488(sp)
    8000416a:	f3da                	sd	s6,480(sp)
    8000416c:	efde                	sd	s7,472(sp)
    8000416e:	ebe2                	sd	s8,464(sp)
    80004170:	e7e6                	sd	s9,456(sp)
    80004172:	e3ea                	sd	s10,448(sp)
    80004174:	ff6e                	sd	s11,440(sp)
    80004176:	1400                	addi	s0,sp,544
    80004178:	892a                	mv	s2,a0
    8000417a:	dea43823          	sd	a0,-528(s0)
    8000417e:	deb43c23          	sd	a1,-520(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004182:	ffffd097          	auipc	ra,0xffffd
    80004186:	d7e080e7          	jalr	-642(ra) # 80000f00 <myproc>
    8000418a:	84aa                	mv	s1,a0

  begin_op();
    8000418c:	fffff097          	auipc	ra,0xfffff
    80004190:	412080e7          	jalr	1042(ra) # 8000359e <begin_op>

  if((ip = namei(path)) == 0){
    80004194:	854a                	mv	a0,s2
    80004196:	fffff097          	auipc	ra,0xfffff
    8000419a:	1ea080e7          	jalr	490(ra) # 80003380 <namei>
    8000419e:	c93d                	beqz	a0,80004214 <exec+0xc4>
    800041a0:	892a                	mv	s2,a0
    end_op();
    return -1;
  }
  ilock(ip);
    800041a2:	fffff097          	auipc	ra,0xfffff
    800041a6:	a1e080e7          	jalr	-1506(ra) # 80002bc0 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    800041aa:	04000713          	li	a4,64
    800041ae:	4681                	li	a3,0
    800041b0:	e4840613          	addi	a2,s0,-440
    800041b4:	4581                	li	a1,0
    800041b6:	854a                	mv	a0,s2
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	cbe080e7          	jalr	-834(ra) # 80002e76 <readi>
    800041c0:	04000793          	li	a5,64
    800041c4:	00f51a63          	bne	a0,a5,800041d8 <exec+0x88>
    goto bad;
  if(elf.magic != ELF_MAGIC)
    800041c8:	e4842703          	lw	a4,-440(s0)
    800041cc:	464c47b7          	lui	a5,0x464c4
    800041d0:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    800041d4:	04f70663          	beq	a4,a5,80004220 <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800041d8:	854a                	mv	a0,s2
    800041da:	fffff097          	auipc	ra,0xfffff
    800041de:	c4a080e7          	jalr	-950(ra) # 80002e24 <iunlockput>
    end_op();
    800041e2:	fffff097          	auipc	ra,0xfffff
    800041e6:	43c080e7          	jalr	1084(ra) # 8000361e <end_op>
  }
  return -1;
    800041ea:	557d                	li	a0,-1
}
    800041ec:	21813083          	ld	ra,536(sp)
    800041f0:	21013403          	ld	s0,528(sp)
    800041f4:	20813483          	ld	s1,520(sp)
    800041f8:	20013903          	ld	s2,512(sp)
    800041fc:	79fe                	ld	s3,504(sp)
    800041fe:	7a5e                	ld	s4,496(sp)
    80004200:	7abe                	ld	s5,488(sp)
    80004202:	7b1e                	ld	s6,480(sp)
    80004204:	6bfe                	ld	s7,472(sp)
    80004206:	6c5e                	ld	s8,464(sp)
    80004208:	6cbe                	ld	s9,456(sp)
    8000420a:	6d1e                	ld	s10,448(sp)
    8000420c:	7dfa                	ld	s11,440(sp)
    8000420e:	22010113          	addi	sp,sp,544
    80004212:	8082                	ret
    end_op();
    80004214:	fffff097          	auipc	ra,0xfffff
    80004218:	40a080e7          	jalr	1034(ra) # 8000361e <end_op>
    return -1;
    8000421c:	557d                	li	a0,-1
    8000421e:	b7f9                	j	800041ec <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004220:	8526                	mv	a0,s1
    80004222:	ffffd097          	auipc	ra,0xffffd
    80004226:	da4080e7          	jalr	-604(ra) # 80000fc6 <proc_pagetable>
    8000422a:	e0a43423          	sd	a0,-504(s0)
    8000422e:	d54d                	beqz	a0,800041d8 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004230:	e6842983          	lw	s3,-408(s0)
    80004234:	e8045783          	lhu	a5,-384(s0)
    80004238:	c7ad                	beqz	a5,800042a2 <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    8000423a:	4481                	li	s1,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000423c:	4b01                	li	s6,0
    if(ph.vaddr % PGSIZE != 0)
    8000423e:	6c05                	lui	s8,0x1
    80004240:	fffc0793          	addi	a5,s8,-1 # fff <_entry-0x7ffff001>
    80004244:	def43423          	sd	a5,-536(s0)
    80004248:	7cfd                	lui	s9,0xfffff
    8000424a:	ac1d                	j	80004480 <exec+0x330>
    panic("loadseg: va must be page aligned");

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    8000424c:	00005517          	auipc	a0,0x5
    80004250:	42450513          	addi	a0,a0,1060 # 80009670 <syscalls+0x2e8>
    80004254:	00003097          	auipc	ra,0x3
    80004258:	b34080e7          	jalr	-1228(ra) # 80006d88 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    8000425c:	8756                	mv	a4,s5
    8000425e:	009d86bb          	addw	a3,s11,s1
    80004262:	4581                	li	a1,0
    80004264:	854a                	mv	a0,s2
    80004266:	fffff097          	auipc	ra,0xfffff
    8000426a:	c10080e7          	jalr	-1008(ra) # 80002e76 <readi>
    8000426e:	2501                	sext.w	a0,a0
    80004270:	1aaa9e63          	bne	s5,a0,8000442c <exec+0x2dc>
  for(i = 0; i < sz; i += PGSIZE){
    80004274:	6785                	lui	a5,0x1
    80004276:	9cbd                	addw	s1,s1,a5
    80004278:	014c8a3b          	addw	s4,s9,s4
    8000427c:	1f74f963          	bleu	s7,s1,8000446e <exec+0x31e>
    pa = walkaddr(pagetable, va + i);
    80004280:	02049593          	slli	a1,s1,0x20
    80004284:	9181                	srli	a1,a1,0x20
    80004286:	95ea                	add	a1,a1,s10
    80004288:	e0843503          	ld	a0,-504(s0)
    8000428c:	ffffc097          	auipc	ra,0xffffc
    80004290:	2be080e7          	jalr	702(ra) # 8000054a <walkaddr>
    80004294:	862a                	mv	a2,a0
    if(pa == 0)
    80004296:	d95d                	beqz	a0,8000424c <exec+0xfc>
      n = PGSIZE;
    80004298:	8ae2                	mv	s5,s8
    if(sz - i < PGSIZE)
    8000429a:	fd8a71e3          	bleu	s8,s4,8000425c <exec+0x10c>
      n = sz - i;
    8000429e:	8ad2                	mv	s5,s4
    800042a0:	bf75                	j	8000425c <exec+0x10c>
  uint64 argc, sz = 0, sp, ustack[MAXARG+1], stackbase;
    800042a2:	4481                	li	s1,0
  iunlockput(ip);
    800042a4:	854a                	mv	a0,s2
    800042a6:	fffff097          	auipc	ra,0xfffff
    800042aa:	b7e080e7          	jalr	-1154(ra) # 80002e24 <iunlockput>
  end_op();
    800042ae:	fffff097          	auipc	ra,0xfffff
    800042b2:	370080e7          	jalr	880(ra) # 8000361e <end_op>
  p = myproc();
    800042b6:	ffffd097          	auipc	ra,0xffffd
    800042ba:	c4a080e7          	jalr	-950(ra) # 80000f00 <myproc>
    800042be:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800042c0:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    800042c4:	6785                	lui	a5,0x1
    800042c6:	17fd                	addi	a5,a5,-1
    800042c8:	94be                	add	s1,s1,a5
    800042ca:	77fd                	lui	a5,0xfffff
    800042cc:	8fe5                	and	a5,a5,s1
    800042ce:	e0f43023          	sd	a5,-512(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800042d2:	6609                	lui	a2,0x2
    800042d4:	963e                	add	a2,a2,a5
    800042d6:	85be                	mv	a1,a5
    800042d8:	e0843483          	ld	s1,-504(s0)
    800042dc:	8526                	mv	a0,s1
    800042de:	ffffc097          	auipc	ra,0xffffc
    800042e2:	650080e7          	jalr	1616(ra) # 8000092e <uvmalloc>
    800042e6:	8b2a                	mv	s6,a0
  ip = 0;
    800042e8:	4901                	li	s2,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE)) == 0)
    800042ea:	14050163          	beqz	a0,8000442c <exec+0x2dc>
  uvmclear(pagetable, sz-2*PGSIZE);
    800042ee:	75f9                	lui	a1,0xffffe
    800042f0:	95aa                	add	a1,a1,a0
    800042f2:	8526                	mv	a0,s1
    800042f4:	ffffd097          	auipc	ra,0xffffd
    800042f8:	858080e7          	jalr	-1960(ra) # 80000b4c <uvmclear>
  stackbase = sp - PGSIZE;
    800042fc:	7bfd                	lui	s7,0xfffff
    800042fe:	9bda                	add	s7,s7,s6
  for(argc = 0; argv[argc]; argc++) {
    80004300:	df843783          	ld	a5,-520(s0)
    80004304:	6388                	ld	a0,0(a5)
    80004306:	c925                	beqz	a0,80004376 <exec+0x226>
    80004308:	e8840993          	addi	s3,s0,-376
    8000430c:	f8840c13          	addi	s8,s0,-120
  sp = sz;
    80004310:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004312:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004314:	ffffc097          	auipc	ra,0xffffc
    80004318:	012080e7          	jalr	18(ra) # 80000326 <strlen>
    8000431c:	2505                	addiw	a0,a0,1
    8000431e:	40a90933          	sub	s2,s2,a0
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004322:	ff097913          	andi	s2,s2,-16
    if(sp < stackbase)
    80004326:	13796863          	bltu	s2,s7,80004456 <exec+0x306>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    8000432a:	df843c83          	ld	s9,-520(s0)
    8000432e:	000cba03          	ld	s4,0(s9) # fffffffffffff000 <end+0xffffffff7ffd7a80>
    80004332:	8552                	mv	a0,s4
    80004334:	ffffc097          	auipc	ra,0xffffc
    80004338:	ff2080e7          	jalr	-14(ra) # 80000326 <strlen>
    8000433c:	0015069b          	addiw	a3,a0,1
    80004340:	8652                	mv	a2,s4
    80004342:	85ca                	mv	a1,s2
    80004344:	e0843503          	ld	a0,-504(s0)
    80004348:	ffffd097          	auipc	ra,0xffffd
    8000434c:	836080e7          	jalr	-1994(ra) # 80000b7e <copyout>
    80004350:	10054763          	bltz	a0,8000445e <exec+0x30e>
    ustack[argc] = sp;
    80004354:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80004358:	0485                	addi	s1,s1,1
    8000435a:	008c8793          	addi	a5,s9,8
    8000435e:	def43c23          	sd	a5,-520(s0)
    80004362:	008cb503          	ld	a0,8(s9)
    80004366:	c911                	beqz	a0,8000437a <exec+0x22a>
    if(argc >= MAXARG)
    80004368:	09a1                	addi	s3,s3,8
    8000436a:	fb8995e3          	bne	s3,s8,80004314 <exec+0x1c4>
  sz = sz1;
    8000436e:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004372:	4901                	li	s2,0
    80004374:	a865                	j	8000442c <exec+0x2dc>
  sp = sz;
    80004376:	895a                	mv	s2,s6
  for(argc = 0; argv[argc]; argc++) {
    80004378:	4481                	li	s1,0
  ustack[argc] = 0;
    8000437a:	00349793          	slli	a5,s1,0x3
    8000437e:	f9040713          	addi	a4,s0,-112
    80004382:	97ba                	add	a5,a5,a4
    80004384:	ee07bc23          	sd	zero,-264(a5) # ffffffffffffeef8 <end+0xffffffff7ffd7978>
  sp -= (argc+1) * sizeof(uint64);
    80004388:	00148693          	addi	a3,s1,1
    8000438c:	068e                	slli	a3,a3,0x3
    8000438e:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    80004392:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80004396:	01797663          	bleu	s7,s2,800043a2 <exec+0x252>
  sz = sz1;
    8000439a:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000439e:	4901                	li	s2,0
    800043a0:	a071                	j	8000442c <exec+0x2dc>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800043a2:	e8840613          	addi	a2,s0,-376
    800043a6:	85ca                	mv	a1,s2
    800043a8:	e0843503          	ld	a0,-504(s0)
    800043ac:	ffffc097          	auipc	ra,0xffffc
    800043b0:	7d2080e7          	jalr	2002(ra) # 80000b7e <copyout>
    800043b4:	0a054963          	bltz	a0,80004466 <exec+0x316>
  p->trapframe->a1 = sp;
    800043b8:	058ab783          	ld	a5,88(s5)
    800043bc:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800043c0:	df043783          	ld	a5,-528(s0)
    800043c4:	0007c703          	lbu	a4,0(a5)
    800043c8:	cf11                	beqz	a4,800043e4 <exec+0x294>
    800043ca:	0785                	addi	a5,a5,1
    if(*s == '/')
    800043cc:	02f00693          	li	a3,47
    800043d0:	a029                	j	800043da <exec+0x28a>
  for(last=s=path; *s; s++)
    800043d2:	0785                	addi	a5,a5,1
    800043d4:	fff7c703          	lbu	a4,-1(a5)
    800043d8:	c711                	beqz	a4,800043e4 <exec+0x294>
    if(*s == '/')
    800043da:	fed71ce3          	bne	a4,a3,800043d2 <exec+0x282>
      last = s+1;
    800043de:	def43823          	sd	a5,-528(s0)
    800043e2:	bfc5                	j	800043d2 <exec+0x282>
  safestrcpy(p->name, last, sizeof(p->name));
    800043e4:	4641                	li	a2,16
    800043e6:	df043583          	ld	a1,-528(s0)
    800043ea:	158a8513          	addi	a0,s5,344
    800043ee:	ffffc097          	auipc	ra,0xffffc
    800043f2:	f06080e7          	jalr	-250(ra) # 800002f4 <safestrcpy>
  oldpagetable = p->pagetable;
    800043f6:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    800043fa:	e0843783          	ld	a5,-504(s0)
    800043fe:	04fab823          	sd	a5,80(s5)
  p->sz = sz;
    80004402:	056ab423          	sd	s6,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004406:	058ab783          	ld	a5,88(s5)
    8000440a:	e6043703          	ld	a4,-416(s0)
    8000440e:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004410:	058ab783          	ld	a5,88(s5)
    80004414:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    80004418:	85ea                	mv	a1,s10
    8000441a:	ffffd097          	auipc	ra,0xffffd
    8000441e:	c48080e7          	jalr	-952(ra) # 80001062 <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004422:	0004851b          	sext.w	a0,s1
    80004426:	b3d9                	j	800041ec <exec+0x9c>
    80004428:	e0943023          	sd	s1,-512(s0)
    proc_freepagetable(pagetable, sz);
    8000442c:	e0043583          	ld	a1,-512(s0)
    80004430:	e0843503          	ld	a0,-504(s0)
    80004434:	ffffd097          	auipc	ra,0xffffd
    80004438:	c2e080e7          	jalr	-978(ra) # 80001062 <proc_freepagetable>
  if(ip){
    8000443c:	d8091ee3          	bnez	s2,800041d8 <exec+0x88>
  return -1;
    80004440:	557d                	li	a0,-1
    80004442:	b36d                	j	800041ec <exec+0x9c>
    80004444:	e0943023          	sd	s1,-512(s0)
    80004448:	b7d5                	j	8000442c <exec+0x2dc>
    8000444a:	e0943023          	sd	s1,-512(s0)
    8000444e:	bff9                	j	8000442c <exec+0x2dc>
    80004450:	e0943023          	sd	s1,-512(s0)
    80004454:	bfe1                	j	8000442c <exec+0x2dc>
  sz = sz1;
    80004456:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000445a:	4901                	li	s2,0
    8000445c:	bfc1                	j	8000442c <exec+0x2dc>
  sz = sz1;
    8000445e:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    80004462:	4901                	li	s2,0
    80004464:	b7e1                	j	8000442c <exec+0x2dc>
  sz = sz1;
    80004466:	e1643023          	sd	s6,-512(s0)
  ip = 0;
    8000446a:	4901                	li	s2,0
    8000446c:	b7c1                	j	8000442c <exec+0x2dc>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    8000446e:	e0043483          	ld	s1,-512(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004472:	2b05                	addiw	s6,s6,1
    80004474:	0389899b          	addiw	s3,s3,56
    80004478:	e8045783          	lhu	a5,-384(s0)
    8000447c:	e2fb54e3          	ble	a5,s6,800042a4 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004480:	2981                	sext.w	s3,s3
    80004482:	03800713          	li	a4,56
    80004486:	86ce                	mv	a3,s3
    80004488:	e1040613          	addi	a2,s0,-496
    8000448c:	4581                	li	a1,0
    8000448e:	854a                	mv	a0,s2
    80004490:	fffff097          	auipc	ra,0xfffff
    80004494:	9e6080e7          	jalr	-1562(ra) # 80002e76 <readi>
    80004498:	03800793          	li	a5,56
    8000449c:	f8f516e3          	bne	a0,a5,80004428 <exec+0x2d8>
    if(ph.type != ELF_PROG_LOAD)
    800044a0:	e1042783          	lw	a5,-496(s0)
    800044a4:	4705                	li	a4,1
    800044a6:	fce796e3          	bne	a5,a4,80004472 <exec+0x322>
    if(ph.memsz < ph.filesz)
    800044aa:	e3843603          	ld	a2,-456(s0)
    800044ae:	e3043783          	ld	a5,-464(s0)
    800044b2:	f8f669e3          	bltu	a2,a5,80004444 <exec+0x2f4>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800044b6:	e2043783          	ld	a5,-480(s0)
    800044ba:	963e                	add	a2,a2,a5
    800044bc:	f8f667e3          	bltu	a2,a5,8000444a <exec+0x2fa>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz)) == 0)
    800044c0:	85a6                	mv	a1,s1
    800044c2:	e0843503          	ld	a0,-504(s0)
    800044c6:	ffffc097          	auipc	ra,0xffffc
    800044ca:	468080e7          	jalr	1128(ra) # 8000092e <uvmalloc>
    800044ce:	e0a43023          	sd	a0,-512(s0)
    800044d2:	dd3d                	beqz	a0,80004450 <exec+0x300>
    if(ph.vaddr % PGSIZE != 0)
    800044d4:	e2043d03          	ld	s10,-480(s0)
    800044d8:	de843783          	ld	a5,-536(s0)
    800044dc:	00fd77b3          	and	a5,s10,a5
    800044e0:	f7b1                	bnez	a5,8000442c <exec+0x2dc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800044e2:	e1842d83          	lw	s11,-488(s0)
    800044e6:	e3042b83          	lw	s7,-464(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800044ea:	f80b82e3          	beqz	s7,8000446e <exec+0x31e>
    800044ee:	8a5e                	mv	s4,s7
    800044f0:	4481                	li	s1,0
    800044f2:	b379                	j	80004280 <exec+0x130>

00000000800044f4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800044f4:	7179                	addi	sp,sp,-48
    800044f6:	f406                	sd	ra,40(sp)
    800044f8:	f022                	sd	s0,32(sp)
    800044fa:	ec26                	sd	s1,24(sp)
    800044fc:	e84a                	sd	s2,16(sp)
    800044fe:	1800                	addi	s0,sp,48
    80004500:	892e                	mv	s2,a1
    80004502:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
    80004504:	fdc40593          	addi	a1,s0,-36
    80004508:	ffffe097          	auipc	ra,0xffffe
    8000450c:	af8080e7          	jalr	-1288(ra) # 80002000 <argint>
    80004510:	04054063          	bltz	a0,80004550 <argfd+0x5c>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80004514:	fdc42703          	lw	a4,-36(s0)
    80004518:	47bd                	li	a5,15
    8000451a:	02e7ed63          	bltu	a5,a4,80004554 <argfd+0x60>
    8000451e:	ffffd097          	auipc	ra,0xffffd
    80004522:	9e2080e7          	jalr	-1566(ra) # 80000f00 <myproc>
    80004526:	fdc42703          	lw	a4,-36(s0)
    8000452a:	01a70793          	addi	a5,a4,26
    8000452e:	078e                	slli	a5,a5,0x3
    80004530:	953e                	add	a0,a0,a5
    80004532:	611c                	ld	a5,0(a0)
    80004534:	c395                	beqz	a5,80004558 <argfd+0x64>
    return -1;
  if(pfd)
    80004536:	00090463          	beqz	s2,8000453e <argfd+0x4a>
    *pfd = fd;
    8000453a:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    8000453e:	4501                	li	a0,0
  if(pf)
    80004540:	c091                	beqz	s1,80004544 <argfd+0x50>
    *pf = f;
    80004542:	e09c                	sd	a5,0(s1)
}
    80004544:	70a2                	ld	ra,40(sp)
    80004546:	7402                	ld	s0,32(sp)
    80004548:	64e2                	ld	s1,24(sp)
    8000454a:	6942                	ld	s2,16(sp)
    8000454c:	6145                	addi	sp,sp,48
    8000454e:	8082                	ret
    return -1;
    80004550:	557d                	li	a0,-1
    80004552:	bfcd                	j	80004544 <argfd+0x50>
    return -1;
    80004554:	557d                	li	a0,-1
    80004556:	b7fd                	j	80004544 <argfd+0x50>
    80004558:	557d                	li	a0,-1
    8000455a:	b7ed                	j	80004544 <argfd+0x50>

000000008000455c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000455c:	1101                	addi	sp,sp,-32
    8000455e:	ec06                	sd	ra,24(sp)
    80004560:	e822                	sd	s0,16(sp)
    80004562:	e426                	sd	s1,8(sp)
    80004564:	1000                	addi	s0,sp,32
    80004566:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004568:	ffffd097          	auipc	ra,0xffffd
    8000456c:	998080e7          	jalr	-1640(ra) # 80000f00 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
    if(p->ofile[fd] == 0){
    80004570:	697c                	ld	a5,208(a0)
    80004572:	c395                	beqz	a5,80004596 <fdalloc+0x3a>
    80004574:	0d850713          	addi	a4,a0,216
  for(fd = 0; fd < NOFILE; fd++){
    80004578:	4785                	li	a5,1
    8000457a:	4641                	li	a2,16
    if(p->ofile[fd] == 0){
    8000457c:	6314                	ld	a3,0(a4)
    8000457e:	ce89                	beqz	a3,80004598 <fdalloc+0x3c>
  for(fd = 0; fd < NOFILE; fd++){
    80004580:	2785                	addiw	a5,a5,1
    80004582:	0721                	addi	a4,a4,8
    80004584:	fec79ce3          	bne	a5,a2,8000457c <fdalloc+0x20>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004588:	57fd                	li	a5,-1
}
    8000458a:	853e                	mv	a0,a5
    8000458c:	60e2                	ld	ra,24(sp)
    8000458e:	6442                	ld	s0,16(sp)
    80004590:	64a2                	ld	s1,8(sp)
    80004592:	6105                	addi	sp,sp,32
    80004594:	8082                	ret
  for(fd = 0; fd < NOFILE; fd++){
    80004596:	4781                	li	a5,0
      p->ofile[fd] = f;
    80004598:	01a78713          	addi	a4,a5,26
    8000459c:	070e                	slli	a4,a4,0x3
    8000459e:	953a                	add	a0,a0,a4
    800045a0:	e104                	sd	s1,0(a0)
      return fd;
    800045a2:	b7e5                	j	8000458a <fdalloc+0x2e>

00000000800045a4 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    800045a4:	715d                	addi	sp,sp,-80
    800045a6:	e486                	sd	ra,72(sp)
    800045a8:	e0a2                	sd	s0,64(sp)
    800045aa:	fc26                	sd	s1,56(sp)
    800045ac:	f84a                	sd	s2,48(sp)
    800045ae:	f44e                	sd	s3,40(sp)
    800045b0:	f052                	sd	s4,32(sp)
    800045b2:	ec56                	sd	s5,24(sp)
    800045b4:	0880                	addi	s0,sp,80
    800045b6:	89ae                	mv	s3,a1
    800045b8:	8ab2                	mv	s5,a2
    800045ba:	8a36                	mv	s4,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800045bc:	fb040593          	addi	a1,s0,-80
    800045c0:	fffff097          	auipc	ra,0xfffff
    800045c4:	dde080e7          	jalr	-546(ra) # 8000339e <nameiparent>
    800045c8:	892a                	mv	s2,a0
    800045ca:	12050f63          	beqz	a0,80004708 <create+0x164>
    return 0;

  ilock(dp);
    800045ce:	ffffe097          	auipc	ra,0xffffe
    800045d2:	5f2080e7          	jalr	1522(ra) # 80002bc0 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800045d6:	4601                	li	a2,0
    800045d8:	fb040593          	addi	a1,s0,-80
    800045dc:	854a                	mv	a0,s2
    800045de:	fffff097          	auipc	ra,0xfffff
    800045e2:	ac8080e7          	jalr	-1336(ra) # 800030a6 <dirlookup>
    800045e6:	84aa                	mv	s1,a0
    800045e8:	c921                	beqz	a0,80004638 <create+0x94>
    iunlockput(dp);
    800045ea:	854a                	mv	a0,s2
    800045ec:	fffff097          	auipc	ra,0xfffff
    800045f0:	838080e7          	jalr	-1992(ra) # 80002e24 <iunlockput>
    ilock(ip);
    800045f4:	8526                	mv	a0,s1
    800045f6:	ffffe097          	auipc	ra,0xffffe
    800045fa:	5ca080e7          	jalr	1482(ra) # 80002bc0 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800045fe:	2981                	sext.w	s3,s3
    80004600:	4789                	li	a5,2
    80004602:	02f99463          	bne	s3,a5,8000462a <create+0x86>
    80004606:	0444d783          	lhu	a5,68(s1)
    8000460a:	37f9                	addiw	a5,a5,-2
    8000460c:	17c2                	slli	a5,a5,0x30
    8000460e:	93c1                	srli	a5,a5,0x30
    80004610:	4705                	li	a4,1
    80004612:	00f76c63          	bltu	a4,a5,8000462a <create+0x86>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
    80004616:	8526                	mv	a0,s1
    80004618:	60a6                	ld	ra,72(sp)
    8000461a:	6406                	ld	s0,64(sp)
    8000461c:	74e2                	ld	s1,56(sp)
    8000461e:	7942                	ld	s2,48(sp)
    80004620:	79a2                	ld	s3,40(sp)
    80004622:	7a02                	ld	s4,32(sp)
    80004624:	6ae2                	ld	s5,24(sp)
    80004626:	6161                	addi	sp,sp,80
    80004628:	8082                	ret
    iunlockput(ip);
    8000462a:	8526                	mv	a0,s1
    8000462c:	ffffe097          	auipc	ra,0xffffe
    80004630:	7f8080e7          	jalr	2040(ra) # 80002e24 <iunlockput>
    return 0;
    80004634:	4481                	li	s1,0
    80004636:	b7c5                	j	80004616 <create+0x72>
  if((ip = ialloc(dp->dev, type)) == 0)
    80004638:	85ce                	mv	a1,s3
    8000463a:	00092503          	lw	a0,0(s2)
    8000463e:	ffffe097          	auipc	ra,0xffffe
    80004642:	3e6080e7          	jalr	998(ra) # 80002a24 <ialloc>
    80004646:	84aa                	mv	s1,a0
    80004648:	c529                	beqz	a0,80004692 <create+0xee>
  ilock(ip);
    8000464a:	ffffe097          	auipc	ra,0xffffe
    8000464e:	576080e7          	jalr	1398(ra) # 80002bc0 <ilock>
  ip->major = major;
    80004652:	05549323          	sh	s5,70(s1)
  ip->minor = minor;
    80004656:	05449423          	sh	s4,72(s1)
  ip->nlink = 1;
    8000465a:	4785                	li	a5,1
    8000465c:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004660:	8526                	mv	a0,s1
    80004662:	ffffe097          	auipc	ra,0xffffe
    80004666:	492080e7          	jalr	1170(ra) # 80002af4 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    8000466a:	2981                	sext.w	s3,s3
    8000466c:	4785                	li	a5,1
    8000466e:	02f98a63          	beq	s3,a5,800046a2 <create+0xfe>
  if(dirlink(dp, name, ip->inum) < 0)
    80004672:	40d0                	lw	a2,4(s1)
    80004674:	fb040593          	addi	a1,s0,-80
    80004678:	854a                	mv	a0,s2
    8000467a:	fffff097          	auipc	ra,0xfffff
    8000467e:	c44080e7          	jalr	-956(ra) # 800032be <dirlink>
    80004682:	06054b63          	bltz	a0,800046f8 <create+0x154>
  iunlockput(dp);
    80004686:	854a                	mv	a0,s2
    80004688:	ffffe097          	auipc	ra,0xffffe
    8000468c:	79c080e7          	jalr	1948(ra) # 80002e24 <iunlockput>
  return ip;
    80004690:	b759                	j	80004616 <create+0x72>
    panic("create: ialloc");
    80004692:	00005517          	auipc	a0,0x5
    80004696:	ffe50513          	addi	a0,a0,-2 # 80009690 <syscalls+0x308>
    8000469a:	00002097          	auipc	ra,0x2
    8000469e:	6ee080e7          	jalr	1774(ra) # 80006d88 <panic>
    dp->nlink++;  // for ".."
    800046a2:	04a95783          	lhu	a5,74(s2)
    800046a6:	2785                	addiw	a5,a5,1
    800046a8:	04f91523          	sh	a5,74(s2)
    iupdate(dp);
    800046ac:	854a                	mv	a0,s2
    800046ae:	ffffe097          	auipc	ra,0xffffe
    800046b2:	446080e7          	jalr	1094(ra) # 80002af4 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    800046b6:	40d0                	lw	a2,4(s1)
    800046b8:	00005597          	auipc	a1,0x5
    800046bc:	fe858593          	addi	a1,a1,-24 # 800096a0 <syscalls+0x318>
    800046c0:	8526                	mv	a0,s1
    800046c2:	fffff097          	auipc	ra,0xfffff
    800046c6:	bfc080e7          	jalr	-1028(ra) # 800032be <dirlink>
    800046ca:	00054f63          	bltz	a0,800046e8 <create+0x144>
    800046ce:	00492603          	lw	a2,4(s2)
    800046d2:	00005597          	auipc	a1,0x5
    800046d6:	fd658593          	addi	a1,a1,-42 # 800096a8 <syscalls+0x320>
    800046da:	8526                	mv	a0,s1
    800046dc:	fffff097          	auipc	ra,0xfffff
    800046e0:	be2080e7          	jalr	-1054(ra) # 800032be <dirlink>
    800046e4:	f80557e3          	bgez	a0,80004672 <create+0xce>
      panic("create dots");
    800046e8:	00005517          	auipc	a0,0x5
    800046ec:	fc850513          	addi	a0,a0,-56 # 800096b0 <syscalls+0x328>
    800046f0:	00002097          	auipc	ra,0x2
    800046f4:	698080e7          	jalr	1688(ra) # 80006d88 <panic>
    panic("create: dirlink");
    800046f8:	00005517          	auipc	a0,0x5
    800046fc:	fc850513          	addi	a0,a0,-56 # 800096c0 <syscalls+0x338>
    80004700:	00002097          	auipc	ra,0x2
    80004704:	688080e7          	jalr	1672(ra) # 80006d88 <panic>
    return 0;
    80004708:	84aa                	mv	s1,a0
    8000470a:	b731                	j	80004616 <create+0x72>

000000008000470c <sys_dup>:
{
    8000470c:	7179                	addi	sp,sp,-48
    8000470e:	f406                	sd	ra,40(sp)
    80004710:	f022                	sd	s0,32(sp)
    80004712:	ec26                	sd	s1,24(sp)
    80004714:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004716:	fd840613          	addi	a2,s0,-40
    8000471a:	4581                	li	a1,0
    8000471c:	4501                	li	a0,0
    8000471e:	00000097          	auipc	ra,0x0
    80004722:	dd6080e7          	jalr	-554(ra) # 800044f4 <argfd>
    return -1;
    80004726:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004728:	02054363          	bltz	a0,8000474e <sys_dup+0x42>
  if((fd=fdalloc(f)) < 0)
    8000472c:	fd843503          	ld	a0,-40(s0)
    80004730:	00000097          	auipc	ra,0x0
    80004734:	e2c080e7          	jalr	-468(ra) # 8000455c <fdalloc>
    80004738:	84aa                	mv	s1,a0
    return -1;
    8000473a:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000473c:	00054963          	bltz	a0,8000474e <sys_dup+0x42>
  filedup(f);
    80004740:	fd843503          	ld	a0,-40(s0)
    80004744:	fffff097          	auipc	ra,0xfffff
    80004748:	30c080e7          	jalr	780(ra) # 80003a50 <filedup>
  return fd;
    8000474c:	87a6                	mv	a5,s1
}
    8000474e:	853e                	mv	a0,a5
    80004750:	70a2                	ld	ra,40(sp)
    80004752:	7402                	ld	s0,32(sp)
    80004754:	64e2                	ld	s1,24(sp)
    80004756:	6145                	addi	sp,sp,48
    80004758:	8082                	ret

000000008000475a <sys_read>:
{
    8000475a:	7179                	addi	sp,sp,-48
    8000475c:	f406                	sd	ra,40(sp)
    8000475e:	f022                	sd	s0,32(sp)
    80004760:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004762:	fe840613          	addi	a2,s0,-24
    80004766:	4581                	li	a1,0
    80004768:	4501                	li	a0,0
    8000476a:	00000097          	auipc	ra,0x0
    8000476e:	d8a080e7          	jalr	-630(ra) # 800044f4 <argfd>
    return -1;
    80004772:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004774:	04054163          	bltz	a0,800047b6 <sys_read+0x5c>
    80004778:	fe440593          	addi	a1,s0,-28
    8000477c:	4509                	li	a0,2
    8000477e:	ffffe097          	auipc	ra,0xffffe
    80004782:	882080e7          	jalr	-1918(ra) # 80002000 <argint>
    return -1;
    80004786:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004788:	02054763          	bltz	a0,800047b6 <sys_read+0x5c>
    8000478c:	fd840593          	addi	a1,s0,-40
    80004790:	4505                	li	a0,1
    80004792:	ffffe097          	auipc	ra,0xffffe
    80004796:	890080e7          	jalr	-1904(ra) # 80002022 <argaddr>
    return -1;
    8000479a:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    8000479c:	00054d63          	bltz	a0,800047b6 <sys_read+0x5c>
  return fileread(f, p, n);
    800047a0:	fe442603          	lw	a2,-28(s0)
    800047a4:	fd843583          	ld	a1,-40(s0)
    800047a8:	fe843503          	ld	a0,-24(s0)
    800047ac:	fffff097          	auipc	ra,0xfffff
    800047b0:	44c080e7          	jalr	1100(ra) # 80003bf8 <fileread>
    800047b4:	87aa                	mv	a5,a0
}
    800047b6:	853e                	mv	a0,a5
    800047b8:	70a2                	ld	ra,40(sp)
    800047ba:	7402                	ld	s0,32(sp)
    800047bc:	6145                	addi	sp,sp,48
    800047be:	8082                	ret

00000000800047c0 <sys_write>:
{
    800047c0:	7179                	addi	sp,sp,-48
    800047c2:	f406                	sd	ra,40(sp)
    800047c4:	f022                	sd	s0,32(sp)
    800047c6:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047c8:	fe840613          	addi	a2,s0,-24
    800047cc:	4581                	li	a1,0
    800047ce:	4501                	li	a0,0
    800047d0:	00000097          	auipc	ra,0x0
    800047d4:	d24080e7          	jalr	-732(ra) # 800044f4 <argfd>
    return -1;
    800047d8:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047da:	04054163          	bltz	a0,8000481c <sys_write+0x5c>
    800047de:	fe440593          	addi	a1,s0,-28
    800047e2:	4509                	li	a0,2
    800047e4:	ffffe097          	auipc	ra,0xffffe
    800047e8:	81c080e7          	jalr	-2020(ra) # 80002000 <argint>
    return -1;
    800047ec:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    800047ee:	02054763          	bltz	a0,8000481c <sys_write+0x5c>
    800047f2:	fd840593          	addi	a1,s0,-40
    800047f6:	4505                	li	a0,1
    800047f8:	ffffe097          	auipc	ra,0xffffe
    800047fc:	82a080e7          	jalr	-2006(ra) # 80002022 <argaddr>
    return -1;
    80004800:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argaddr(1, &p) < 0)
    80004802:	00054d63          	bltz	a0,8000481c <sys_write+0x5c>
  return filewrite(f, p, n);
    80004806:	fe442603          	lw	a2,-28(s0)
    8000480a:	fd843583          	ld	a1,-40(s0)
    8000480e:	fe843503          	ld	a0,-24(s0)
    80004812:	fffff097          	auipc	ra,0xfffff
    80004816:	4bc080e7          	jalr	1212(ra) # 80003cce <filewrite>
    8000481a:	87aa                	mv	a5,a0
}
    8000481c:	853e                	mv	a0,a5
    8000481e:	70a2                	ld	ra,40(sp)
    80004820:	7402                	ld	s0,32(sp)
    80004822:	6145                	addi	sp,sp,48
    80004824:	8082                	ret

0000000080004826 <sys_close>:
{
    80004826:	1101                	addi	sp,sp,-32
    80004828:	ec06                	sd	ra,24(sp)
    8000482a:	e822                	sd	s0,16(sp)
    8000482c:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    8000482e:	fe040613          	addi	a2,s0,-32
    80004832:	fec40593          	addi	a1,s0,-20
    80004836:	4501                	li	a0,0
    80004838:	00000097          	auipc	ra,0x0
    8000483c:	cbc080e7          	jalr	-836(ra) # 800044f4 <argfd>
    return -1;
    80004840:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004842:	02054463          	bltz	a0,8000486a <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80004846:	ffffc097          	auipc	ra,0xffffc
    8000484a:	6ba080e7          	jalr	1722(ra) # 80000f00 <myproc>
    8000484e:	fec42783          	lw	a5,-20(s0)
    80004852:	07e9                	addi	a5,a5,26
    80004854:	078e                	slli	a5,a5,0x3
    80004856:	953e                	add	a0,a0,a5
    80004858:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000485c:	fe043503          	ld	a0,-32(s0)
    80004860:	fffff097          	auipc	ra,0xfffff
    80004864:	242080e7          	jalr	578(ra) # 80003aa2 <fileclose>
  return 0;
    80004868:	4781                	li	a5,0
}
    8000486a:	853e                	mv	a0,a5
    8000486c:	60e2                	ld	ra,24(sp)
    8000486e:	6442                	ld	s0,16(sp)
    80004870:	6105                	addi	sp,sp,32
    80004872:	8082                	ret

0000000080004874 <sys_fstat>:
{
    80004874:	1101                	addi	sp,sp,-32
    80004876:	ec06                	sd	ra,24(sp)
    80004878:	e822                	sd	s0,16(sp)
    8000487a:	1000                	addi	s0,sp,32
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000487c:	fe840613          	addi	a2,s0,-24
    80004880:	4581                	li	a1,0
    80004882:	4501                	li	a0,0
    80004884:	00000097          	auipc	ra,0x0
    80004888:	c70080e7          	jalr	-912(ra) # 800044f4 <argfd>
    return -1;
    8000488c:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    8000488e:	02054563          	bltz	a0,800048b8 <sys_fstat+0x44>
    80004892:	fe040593          	addi	a1,s0,-32
    80004896:	4505                	li	a0,1
    80004898:	ffffd097          	auipc	ra,0xffffd
    8000489c:	78a080e7          	jalr	1930(ra) # 80002022 <argaddr>
    return -1;
    800048a0:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0 || argaddr(1, &st) < 0)
    800048a2:	00054b63          	bltz	a0,800048b8 <sys_fstat+0x44>
  return filestat(f, st);
    800048a6:	fe043583          	ld	a1,-32(s0)
    800048aa:	fe843503          	ld	a0,-24(s0)
    800048ae:	fffff097          	auipc	ra,0xfffff
    800048b2:	2d8080e7          	jalr	728(ra) # 80003b86 <filestat>
    800048b6:	87aa                	mv	a5,a0
}
    800048b8:	853e                	mv	a0,a5
    800048ba:	60e2                	ld	ra,24(sp)
    800048bc:	6442                	ld	s0,16(sp)
    800048be:	6105                	addi	sp,sp,32
    800048c0:	8082                	ret

00000000800048c2 <sys_link>:
{
    800048c2:	7169                	addi	sp,sp,-304
    800048c4:	f606                	sd	ra,296(sp)
    800048c6:	f222                	sd	s0,288(sp)
    800048c8:	ee26                	sd	s1,280(sp)
    800048ca:	ea4a                	sd	s2,272(sp)
    800048cc:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048ce:	08000613          	li	a2,128
    800048d2:	ed040593          	addi	a1,s0,-304
    800048d6:	4501                	li	a0,0
    800048d8:	ffffd097          	auipc	ra,0xffffd
    800048dc:	76c080e7          	jalr	1900(ra) # 80002044 <argstr>
    return -1;
    800048e0:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048e2:	10054e63          	bltz	a0,800049fe <sys_link+0x13c>
    800048e6:	08000613          	li	a2,128
    800048ea:	f5040593          	addi	a1,s0,-176
    800048ee:	4505                	li	a0,1
    800048f0:	ffffd097          	auipc	ra,0xffffd
    800048f4:	754080e7          	jalr	1876(ra) # 80002044 <argstr>
    return -1;
    800048f8:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800048fa:	10054263          	bltz	a0,800049fe <sys_link+0x13c>
  begin_op();
    800048fe:	fffff097          	auipc	ra,0xfffff
    80004902:	ca0080e7          	jalr	-864(ra) # 8000359e <begin_op>
  if((ip = namei(old)) == 0){
    80004906:	ed040513          	addi	a0,s0,-304
    8000490a:	fffff097          	auipc	ra,0xfffff
    8000490e:	a76080e7          	jalr	-1418(ra) # 80003380 <namei>
    80004912:	84aa                	mv	s1,a0
    80004914:	c551                	beqz	a0,800049a0 <sys_link+0xde>
  ilock(ip);
    80004916:	ffffe097          	auipc	ra,0xffffe
    8000491a:	2aa080e7          	jalr	682(ra) # 80002bc0 <ilock>
  if(ip->type == T_DIR){
    8000491e:	04449703          	lh	a4,68(s1)
    80004922:	4785                	li	a5,1
    80004924:	08f70463          	beq	a4,a5,800049ac <sys_link+0xea>
  ip->nlink++;
    80004928:	04a4d783          	lhu	a5,74(s1)
    8000492c:	2785                	addiw	a5,a5,1
    8000492e:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004932:	8526                	mv	a0,s1
    80004934:	ffffe097          	auipc	ra,0xffffe
    80004938:	1c0080e7          	jalr	448(ra) # 80002af4 <iupdate>
  iunlock(ip);
    8000493c:	8526                	mv	a0,s1
    8000493e:	ffffe097          	auipc	ra,0xffffe
    80004942:	346080e7          	jalr	838(ra) # 80002c84 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004946:	fd040593          	addi	a1,s0,-48
    8000494a:	f5040513          	addi	a0,s0,-176
    8000494e:	fffff097          	auipc	ra,0xfffff
    80004952:	a50080e7          	jalr	-1456(ra) # 8000339e <nameiparent>
    80004956:	892a                	mv	s2,a0
    80004958:	c935                	beqz	a0,800049cc <sys_link+0x10a>
  ilock(dp);
    8000495a:	ffffe097          	auipc	ra,0xffffe
    8000495e:	266080e7          	jalr	614(ra) # 80002bc0 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004962:	00092703          	lw	a4,0(s2)
    80004966:	409c                	lw	a5,0(s1)
    80004968:	04f71d63          	bne	a4,a5,800049c2 <sys_link+0x100>
    8000496c:	40d0                	lw	a2,4(s1)
    8000496e:	fd040593          	addi	a1,s0,-48
    80004972:	854a                	mv	a0,s2
    80004974:	fffff097          	auipc	ra,0xfffff
    80004978:	94a080e7          	jalr	-1718(ra) # 800032be <dirlink>
    8000497c:	04054363          	bltz	a0,800049c2 <sys_link+0x100>
  iunlockput(dp);
    80004980:	854a                	mv	a0,s2
    80004982:	ffffe097          	auipc	ra,0xffffe
    80004986:	4a2080e7          	jalr	1186(ra) # 80002e24 <iunlockput>
  iput(ip);
    8000498a:	8526                	mv	a0,s1
    8000498c:	ffffe097          	auipc	ra,0xffffe
    80004990:	3f0080e7          	jalr	1008(ra) # 80002d7c <iput>
  end_op();
    80004994:	fffff097          	auipc	ra,0xfffff
    80004998:	c8a080e7          	jalr	-886(ra) # 8000361e <end_op>
  return 0;
    8000499c:	4781                	li	a5,0
    8000499e:	a085                	j	800049fe <sys_link+0x13c>
    end_op();
    800049a0:	fffff097          	auipc	ra,0xfffff
    800049a4:	c7e080e7          	jalr	-898(ra) # 8000361e <end_op>
    return -1;
    800049a8:	57fd                	li	a5,-1
    800049aa:	a891                	j	800049fe <sys_link+0x13c>
    iunlockput(ip);
    800049ac:	8526                	mv	a0,s1
    800049ae:	ffffe097          	auipc	ra,0xffffe
    800049b2:	476080e7          	jalr	1142(ra) # 80002e24 <iunlockput>
    end_op();
    800049b6:	fffff097          	auipc	ra,0xfffff
    800049ba:	c68080e7          	jalr	-920(ra) # 8000361e <end_op>
    return -1;
    800049be:	57fd                	li	a5,-1
    800049c0:	a83d                	j	800049fe <sys_link+0x13c>
    iunlockput(dp);
    800049c2:	854a                	mv	a0,s2
    800049c4:	ffffe097          	auipc	ra,0xffffe
    800049c8:	460080e7          	jalr	1120(ra) # 80002e24 <iunlockput>
  ilock(ip);
    800049cc:	8526                	mv	a0,s1
    800049ce:	ffffe097          	auipc	ra,0xffffe
    800049d2:	1f2080e7          	jalr	498(ra) # 80002bc0 <ilock>
  ip->nlink--;
    800049d6:	04a4d783          	lhu	a5,74(s1)
    800049da:	37fd                	addiw	a5,a5,-1
    800049dc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800049e0:	8526                	mv	a0,s1
    800049e2:	ffffe097          	auipc	ra,0xffffe
    800049e6:	112080e7          	jalr	274(ra) # 80002af4 <iupdate>
  iunlockput(ip);
    800049ea:	8526                	mv	a0,s1
    800049ec:	ffffe097          	auipc	ra,0xffffe
    800049f0:	438080e7          	jalr	1080(ra) # 80002e24 <iunlockput>
  end_op();
    800049f4:	fffff097          	auipc	ra,0xfffff
    800049f8:	c2a080e7          	jalr	-982(ra) # 8000361e <end_op>
  return -1;
    800049fc:	57fd                	li	a5,-1
}
    800049fe:	853e                	mv	a0,a5
    80004a00:	70b2                	ld	ra,296(sp)
    80004a02:	7412                	ld	s0,288(sp)
    80004a04:	64f2                	ld	s1,280(sp)
    80004a06:	6952                	ld	s2,272(sp)
    80004a08:	6155                	addi	sp,sp,304
    80004a0a:	8082                	ret

0000000080004a0c <sys_unlink>:
{
    80004a0c:	7151                	addi	sp,sp,-240
    80004a0e:	f586                	sd	ra,232(sp)
    80004a10:	f1a2                	sd	s0,224(sp)
    80004a12:	eda6                	sd	s1,216(sp)
    80004a14:	e9ca                	sd	s2,208(sp)
    80004a16:	e5ce                	sd	s3,200(sp)
    80004a18:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004a1a:	08000613          	li	a2,128
    80004a1e:	f3040593          	addi	a1,s0,-208
    80004a22:	4501                	li	a0,0
    80004a24:	ffffd097          	auipc	ra,0xffffd
    80004a28:	620080e7          	jalr	1568(ra) # 80002044 <argstr>
    80004a2c:	16054f63          	bltz	a0,80004baa <sys_unlink+0x19e>
  begin_op();
    80004a30:	fffff097          	auipc	ra,0xfffff
    80004a34:	b6e080e7          	jalr	-1170(ra) # 8000359e <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004a38:	fb040593          	addi	a1,s0,-80
    80004a3c:	f3040513          	addi	a0,s0,-208
    80004a40:	fffff097          	auipc	ra,0xfffff
    80004a44:	95e080e7          	jalr	-1698(ra) # 8000339e <nameiparent>
    80004a48:	89aa                	mv	s3,a0
    80004a4a:	c979                	beqz	a0,80004b20 <sys_unlink+0x114>
  ilock(dp);
    80004a4c:	ffffe097          	auipc	ra,0xffffe
    80004a50:	174080e7          	jalr	372(ra) # 80002bc0 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004a54:	00005597          	auipc	a1,0x5
    80004a58:	c4c58593          	addi	a1,a1,-948 # 800096a0 <syscalls+0x318>
    80004a5c:	fb040513          	addi	a0,s0,-80
    80004a60:	ffffe097          	auipc	ra,0xffffe
    80004a64:	62c080e7          	jalr	1580(ra) # 8000308c <namecmp>
    80004a68:	14050863          	beqz	a0,80004bb8 <sys_unlink+0x1ac>
    80004a6c:	00005597          	auipc	a1,0x5
    80004a70:	c3c58593          	addi	a1,a1,-964 # 800096a8 <syscalls+0x320>
    80004a74:	fb040513          	addi	a0,s0,-80
    80004a78:	ffffe097          	auipc	ra,0xffffe
    80004a7c:	614080e7          	jalr	1556(ra) # 8000308c <namecmp>
    80004a80:	12050c63          	beqz	a0,80004bb8 <sys_unlink+0x1ac>
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004a84:	f2c40613          	addi	a2,s0,-212
    80004a88:	fb040593          	addi	a1,s0,-80
    80004a8c:	854e                	mv	a0,s3
    80004a8e:	ffffe097          	auipc	ra,0xffffe
    80004a92:	618080e7          	jalr	1560(ra) # 800030a6 <dirlookup>
    80004a96:	84aa                	mv	s1,a0
    80004a98:	12050063          	beqz	a0,80004bb8 <sys_unlink+0x1ac>
  ilock(ip);
    80004a9c:	ffffe097          	auipc	ra,0xffffe
    80004aa0:	124080e7          	jalr	292(ra) # 80002bc0 <ilock>
  if(ip->nlink < 1)
    80004aa4:	04a49783          	lh	a5,74(s1)
    80004aa8:	08f05263          	blez	a5,80004b2c <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004aac:	04449703          	lh	a4,68(s1)
    80004ab0:	4785                	li	a5,1
    80004ab2:	08f70563          	beq	a4,a5,80004b3c <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    80004ab6:	4641                	li	a2,16
    80004ab8:	4581                	li	a1,0
    80004aba:	fc040513          	addi	a0,s0,-64
    80004abe:	ffffb097          	auipc	ra,0xffffb
    80004ac2:	6be080e7          	jalr	1726(ra) # 8000017c <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004ac6:	4741                	li	a4,16
    80004ac8:	f2c42683          	lw	a3,-212(s0)
    80004acc:	fc040613          	addi	a2,s0,-64
    80004ad0:	4581                	li	a1,0
    80004ad2:	854e                	mv	a0,s3
    80004ad4:	ffffe097          	auipc	ra,0xffffe
    80004ad8:	49a080e7          	jalr	1178(ra) # 80002f6e <writei>
    80004adc:	47c1                	li	a5,16
    80004ade:	0af51363          	bne	a0,a5,80004b84 <sys_unlink+0x178>
  if(ip->type == T_DIR){
    80004ae2:	04449703          	lh	a4,68(s1)
    80004ae6:	4785                	li	a5,1
    80004ae8:	0af70663          	beq	a4,a5,80004b94 <sys_unlink+0x188>
  iunlockput(dp);
    80004aec:	854e                	mv	a0,s3
    80004aee:	ffffe097          	auipc	ra,0xffffe
    80004af2:	336080e7          	jalr	822(ra) # 80002e24 <iunlockput>
  ip->nlink--;
    80004af6:	04a4d783          	lhu	a5,74(s1)
    80004afa:	37fd                	addiw	a5,a5,-1
    80004afc:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004b00:	8526                	mv	a0,s1
    80004b02:	ffffe097          	auipc	ra,0xffffe
    80004b06:	ff2080e7          	jalr	-14(ra) # 80002af4 <iupdate>
  iunlockput(ip);
    80004b0a:	8526                	mv	a0,s1
    80004b0c:	ffffe097          	auipc	ra,0xffffe
    80004b10:	318080e7          	jalr	792(ra) # 80002e24 <iunlockput>
  end_op();
    80004b14:	fffff097          	auipc	ra,0xfffff
    80004b18:	b0a080e7          	jalr	-1270(ra) # 8000361e <end_op>
  return 0;
    80004b1c:	4501                	li	a0,0
    80004b1e:	a07d                	j	80004bcc <sys_unlink+0x1c0>
    end_op();
    80004b20:	fffff097          	auipc	ra,0xfffff
    80004b24:	afe080e7          	jalr	-1282(ra) # 8000361e <end_op>
    return -1;
    80004b28:	557d                	li	a0,-1
    80004b2a:	a04d                	j	80004bcc <sys_unlink+0x1c0>
    panic("unlink: nlink < 1");
    80004b2c:	00005517          	auipc	a0,0x5
    80004b30:	ba450513          	addi	a0,a0,-1116 # 800096d0 <syscalls+0x348>
    80004b34:	00002097          	auipc	ra,0x2
    80004b38:	254080e7          	jalr	596(ra) # 80006d88 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b3c:	44f8                	lw	a4,76(s1)
    80004b3e:	02000793          	li	a5,32
    80004b42:	f6e7fae3          	bleu	a4,a5,80004ab6 <sys_unlink+0xaa>
    80004b46:	02000913          	li	s2,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004b4a:	4741                	li	a4,16
    80004b4c:	86ca                	mv	a3,s2
    80004b4e:	f1840613          	addi	a2,s0,-232
    80004b52:	4581                	li	a1,0
    80004b54:	8526                	mv	a0,s1
    80004b56:	ffffe097          	auipc	ra,0xffffe
    80004b5a:	320080e7          	jalr	800(ra) # 80002e76 <readi>
    80004b5e:	47c1                	li	a5,16
    80004b60:	00f51a63          	bne	a0,a5,80004b74 <sys_unlink+0x168>
    if(de.inum != 0)
    80004b64:	f1845783          	lhu	a5,-232(s0)
    80004b68:	e3b9                	bnez	a5,80004bae <sys_unlink+0x1a2>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004b6a:	2941                	addiw	s2,s2,16
    80004b6c:	44fc                	lw	a5,76(s1)
    80004b6e:	fcf96ee3          	bltu	s2,a5,80004b4a <sys_unlink+0x13e>
    80004b72:	b791                	j	80004ab6 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80004b74:	00005517          	auipc	a0,0x5
    80004b78:	b7450513          	addi	a0,a0,-1164 # 800096e8 <syscalls+0x360>
    80004b7c:	00002097          	auipc	ra,0x2
    80004b80:	20c080e7          	jalr	524(ra) # 80006d88 <panic>
    panic("unlink: writei");
    80004b84:	00005517          	auipc	a0,0x5
    80004b88:	b7c50513          	addi	a0,a0,-1156 # 80009700 <syscalls+0x378>
    80004b8c:	00002097          	auipc	ra,0x2
    80004b90:	1fc080e7          	jalr	508(ra) # 80006d88 <panic>
    dp->nlink--;
    80004b94:	04a9d783          	lhu	a5,74(s3)
    80004b98:	37fd                	addiw	a5,a5,-1
    80004b9a:	04f99523          	sh	a5,74(s3)
    iupdate(dp);
    80004b9e:	854e                	mv	a0,s3
    80004ba0:	ffffe097          	auipc	ra,0xffffe
    80004ba4:	f54080e7          	jalr	-172(ra) # 80002af4 <iupdate>
    80004ba8:	b791                	j	80004aec <sys_unlink+0xe0>
    return -1;
    80004baa:	557d                	li	a0,-1
    80004bac:	a005                	j	80004bcc <sys_unlink+0x1c0>
    iunlockput(ip);
    80004bae:	8526                	mv	a0,s1
    80004bb0:	ffffe097          	auipc	ra,0xffffe
    80004bb4:	274080e7          	jalr	628(ra) # 80002e24 <iunlockput>
  iunlockput(dp);
    80004bb8:	854e                	mv	a0,s3
    80004bba:	ffffe097          	auipc	ra,0xffffe
    80004bbe:	26a080e7          	jalr	618(ra) # 80002e24 <iunlockput>
  end_op();
    80004bc2:	fffff097          	auipc	ra,0xfffff
    80004bc6:	a5c080e7          	jalr	-1444(ra) # 8000361e <end_op>
  return -1;
    80004bca:	557d                	li	a0,-1
}
    80004bcc:	70ae                	ld	ra,232(sp)
    80004bce:	740e                	ld	s0,224(sp)
    80004bd0:	64ee                	ld	s1,216(sp)
    80004bd2:	694e                	ld	s2,208(sp)
    80004bd4:	69ae                	ld	s3,200(sp)
    80004bd6:	616d                	addi	sp,sp,240
    80004bd8:	8082                	ret

0000000080004bda <sys_open>:

uint64
sys_open(void)
{
    80004bda:	7131                	addi	sp,sp,-192
    80004bdc:	fd06                	sd	ra,184(sp)
    80004bde:	f922                	sd	s0,176(sp)
    80004be0:	f526                	sd	s1,168(sp)
    80004be2:	f14a                	sd	s2,160(sp)
    80004be4:	ed4e                	sd	s3,152(sp)
    80004be6:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004be8:	08000613          	li	a2,128
    80004bec:	f5040593          	addi	a1,s0,-176
    80004bf0:	4501                	li	a0,0
    80004bf2:	ffffd097          	auipc	ra,0xffffd
    80004bf6:	452080e7          	jalr	1106(ra) # 80002044 <argstr>
    return -1;
    80004bfa:	54fd                	li	s1,-1
  if((n = argstr(0, path, MAXPATH)) < 0 || argint(1, &omode) < 0)
    80004bfc:	0c054163          	bltz	a0,80004cbe <sys_open+0xe4>
    80004c00:	f4c40593          	addi	a1,s0,-180
    80004c04:	4505                	li	a0,1
    80004c06:	ffffd097          	auipc	ra,0xffffd
    80004c0a:	3fa080e7          	jalr	1018(ra) # 80002000 <argint>
    80004c0e:	0a054863          	bltz	a0,80004cbe <sys_open+0xe4>

  begin_op();
    80004c12:	fffff097          	auipc	ra,0xfffff
    80004c16:	98c080e7          	jalr	-1652(ra) # 8000359e <begin_op>

  if(omode & O_CREATE){
    80004c1a:	f4c42783          	lw	a5,-180(s0)
    80004c1e:	2007f793          	andi	a5,a5,512
    80004c22:	cbdd                	beqz	a5,80004cd8 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80004c24:	4681                	li	a3,0
    80004c26:	4601                	li	a2,0
    80004c28:	4589                	li	a1,2
    80004c2a:	f5040513          	addi	a0,s0,-176
    80004c2e:	00000097          	auipc	ra,0x0
    80004c32:	976080e7          	jalr	-1674(ra) # 800045a4 <create>
    80004c36:	892a                	mv	s2,a0
    if(ip == 0){
    80004c38:	c959                	beqz	a0,80004cce <sys_open+0xf4>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004c3a:	04491703          	lh	a4,68(s2)
    80004c3e:	478d                	li	a5,3
    80004c40:	00f71763          	bne	a4,a5,80004c4e <sys_open+0x74>
    80004c44:	04695703          	lhu	a4,70(s2)
    80004c48:	47a5                	li	a5,9
    80004c4a:	0ce7ec63          	bltu	a5,a4,80004d22 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004c4e:	fffff097          	auipc	ra,0xfffff
    80004c52:	d84080e7          	jalr	-636(ra) # 800039d2 <filealloc>
    80004c56:	89aa                	mv	s3,a0
    80004c58:	10050263          	beqz	a0,80004d5c <sys_open+0x182>
    80004c5c:	00000097          	auipc	ra,0x0
    80004c60:	900080e7          	jalr	-1792(ra) # 8000455c <fdalloc>
    80004c64:	84aa                	mv	s1,a0
    80004c66:	0e054663          	bltz	a0,80004d52 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004c6a:	04491703          	lh	a4,68(s2)
    80004c6e:	478d                	li	a5,3
    80004c70:	0cf70463          	beq	a4,a5,80004d38 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004c74:	4789                	li	a5,2
    80004c76:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80004c7a:	0209a423          	sw	zero,40(s3)
  }
  f->ip = ip;
    80004c7e:	0129bc23          	sd	s2,24(s3)
  f->readable = !(omode & O_WRONLY);
    80004c82:	f4c42783          	lw	a5,-180(s0)
    80004c86:	0017c713          	xori	a4,a5,1
    80004c8a:	8b05                	andi	a4,a4,1
    80004c8c:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004c90:	0037f713          	andi	a4,a5,3
    80004c94:	00e03733          	snez	a4,a4
    80004c98:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004c9c:	4007f793          	andi	a5,a5,1024
    80004ca0:	c791                	beqz	a5,80004cac <sys_open+0xd2>
    80004ca2:	04491703          	lh	a4,68(s2)
    80004ca6:	4789                	li	a5,2
    80004ca8:	08f70f63          	beq	a4,a5,80004d46 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80004cac:	854a                	mv	a0,s2
    80004cae:	ffffe097          	auipc	ra,0xffffe
    80004cb2:	fd6080e7          	jalr	-42(ra) # 80002c84 <iunlock>
  end_op();
    80004cb6:	fffff097          	auipc	ra,0xfffff
    80004cba:	968080e7          	jalr	-1688(ra) # 8000361e <end_op>

  return fd;
}
    80004cbe:	8526                	mv	a0,s1
    80004cc0:	70ea                	ld	ra,184(sp)
    80004cc2:	744a                	ld	s0,176(sp)
    80004cc4:	74aa                	ld	s1,168(sp)
    80004cc6:	790a                	ld	s2,160(sp)
    80004cc8:	69ea                	ld	s3,152(sp)
    80004cca:	6129                	addi	sp,sp,192
    80004ccc:	8082                	ret
      end_op();
    80004cce:	fffff097          	auipc	ra,0xfffff
    80004cd2:	950080e7          	jalr	-1712(ra) # 8000361e <end_op>
      return -1;
    80004cd6:	b7e5                	j	80004cbe <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    80004cd8:	f5040513          	addi	a0,s0,-176
    80004cdc:	ffffe097          	auipc	ra,0xffffe
    80004ce0:	6a4080e7          	jalr	1700(ra) # 80003380 <namei>
    80004ce4:	892a                	mv	s2,a0
    80004ce6:	c905                	beqz	a0,80004d16 <sys_open+0x13c>
    ilock(ip);
    80004ce8:	ffffe097          	auipc	ra,0xffffe
    80004cec:	ed8080e7          	jalr	-296(ra) # 80002bc0 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004cf0:	04491703          	lh	a4,68(s2)
    80004cf4:	4785                	li	a5,1
    80004cf6:	f4f712e3          	bne	a4,a5,80004c3a <sys_open+0x60>
    80004cfa:	f4c42783          	lw	a5,-180(s0)
    80004cfe:	dba1                	beqz	a5,80004c4e <sys_open+0x74>
      iunlockput(ip);
    80004d00:	854a                	mv	a0,s2
    80004d02:	ffffe097          	auipc	ra,0xffffe
    80004d06:	122080e7          	jalr	290(ra) # 80002e24 <iunlockput>
      end_op();
    80004d0a:	fffff097          	auipc	ra,0xfffff
    80004d0e:	914080e7          	jalr	-1772(ra) # 8000361e <end_op>
      return -1;
    80004d12:	54fd                	li	s1,-1
    80004d14:	b76d                	j	80004cbe <sys_open+0xe4>
      end_op();
    80004d16:	fffff097          	auipc	ra,0xfffff
    80004d1a:	908080e7          	jalr	-1784(ra) # 8000361e <end_op>
      return -1;
    80004d1e:	54fd                	li	s1,-1
    80004d20:	bf79                	j	80004cbe <sys_open+0xe4>
    iunlockput(ip);
    80004d22:	854a                	mv	a0,s2
    80004d24:	ffffe097          	auipc	ra,0xffffe
    80004d28:	100080e7          	jalr	256(ra) # 80002e24 <iunlockput>
    end_op();
    80004d2c:	fffff097          	auipc	ra,0xfffff
    80004d30:	8f2080e7          	jalr	-1806(ra) # 8000361e <end_op>
    return -1;
    80004d34:	54fd                	li	s1,-1
    80004d36:	b761                	j	80004cbe <sys_open+0xe4>
    f->type = FD_DEVICE;
    80004d38:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80004d3c:	04691783          	lh	a5,70(s2)
    80004d40:	02f99623          	sh	a5,44(s3)
    80004d44:	bf2d                	j	80004c7e <sys_open+0xa4>
    itrunc(ip);
    80004d46:	854a                	mv	a0,s2
    80004d48:	ffffe097          	auipc	ra,0xffffe
    80004d4c:	f88080e7          	jalr	-120(ra) # 80002cd0 <itrunc>
    80004d50:	bfb1                	j	80004cac <sys_open+0xd2>
      fileclose(f);
    80004d52:	854e                	mv	a0,s3
    80004d54:	fffff097          	auipc	ra,0xfffff
    80004d58:	d4e080e7          	jalr	-690(ra) # 80003aa2 <fileclose>
    iunlockput(ip);
    80004d5c:	854a                	mv	a0,s2
    80004d5e:	ffffe097          	auipc	ra,0xffffe
    80004d62:	0c6080e7          	jalr	198(ra) # 80002e24 <iunlockput>
    end_op();
    80004d66:	fffff097          	auipc	ra,0xfffff
    80004d6a:	8b8080e7          	jalr	-1864(ra) # 8000361e <end_op>
    return -1;
    80004d6e:	54fd                	li	s1,-1
    80004d70:	b7b9                	j	80004cbe <sys_open+0xe4>

0000000080004d72 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004d72:	7175                	addi	sp,sp,-144
    80004d74:	e506                	sd	ra,136(sp)
    80004d76:	e122                	sd	s0,128(sp)
    80004d78:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004d7a:	fffff097          	auipc	ra,0xfffff
    80004d7e:	824080e7          	jalr	-2012(ra) # 8000359e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004d82:	08000613          	li	a2,128
    80004d86:	f7040593          	addi	a1,s0,-144
    80004d8a:	4501                	li	a0,0
    80004d8c:	ffffd097          	auipc	ra,0xffffd
    80004d90:	2b8080e7          	jalr	696(ra) # 80002044 <argstr>
    80004d94:	02054963          	bltz	a0,80004dc6 <sys_mkdir+0x54>
    80004d98:	4681                	li	a3,0
    80004d9a:	4601                	li	a2,0
    80004d9c:	4585                	li	a1,1
    80004d9e:	f7040513          	addi	a0,s0,-144
    80004da2:	00000097          	auipc	ra,0x0
    80004da6:	802080e7          	jalr	-2046(ra) # 800045a4 <create>
    80004daa:	cd11                	beqz	a0,80004dc6 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004dac:	ffffe097          	auipc	ra,0xffffe
    80004db0:	078080e7          	jalr	120(ra) # 80002e24 <iunlockput>
  end_op();
    80004db4:	fffff097          	auipc	ra,0xfffff
    80004db8:	86a080e7          	jalr	-1942(ra) # 8000361e <end_op>
  return 0;
    80004dbc:	4501                	li	a0,0
}
    80004dbe:	60aa                	ld	ra,136(sp)
    80004dc0:	640a                	ld	s0,128(sp)
    80004dc2:	6149                	addi	sp,sp,144
    80004dc4:	8082                	ret
    end_op();
    80004dc6:	fffff097          	auipc	ra,0xfffff
    80004dca:	858080e7          	jalr	-1960(ra) # 8000361e <end_op>
    return -1;
    80004dce:	557d                	li	a0,-1
    80004dd0:	b7fd                	j	80004dbe <sys_mkdir+0x4c>

0000000080004dd2 <sys_mknod>:

uint64
sys_mknod(void)
{
    80004dd2:	7135                	addi	sp,sp,-160
    80004dd4:	ed06                	sd	ra,152(sp)
    80004dd6:	e922                	sd	s0,144(sp)
    80004dd8:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80004dda:	ffffe097          	auipc	ra,0xffffe
    80004dde:	7c4080e7          	jalr	1988(ra) # 8000359e <begin_op>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004de2:	08000613          	li	a2,128
    80004de6:	f7040593          	addi	a1,s0,-144
    80004dea:	4501                	li	a0,0
    80004dec:	ffffd097          	auipc	ra,0xffffd
    80004df0:	258080e7          	jalr	600(ra) # 80002044 <argstr>
    80004df4:	04054a63          	bltz	a0,80004e48 <sys_mknod+0x76>
     argint(1, &major) < 0 ||
    80004df8:	f6c40593          	addi	a1,s0,-148
    80004dfc:	4505                	li	a0,1
    80004dfe:	ffffd097          	auipc	ra,0xffffd
    80004e02:	202080e7          	jalr	514(ra) # 80002000 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80004e06:	04054163          	bltz	a0,80004e48 <sys_mknod+0x76>
     argint(2, &minor) < 0 ||
    80004e0a:	f6840593          	addi	a1,s0,-152
    80004e0e:	4509                	li	a0,2
    80004e10:	ffffd097          	auipc	ra,0xffffd
    80004e14:	1f0080e7          	jalr	496(ra) # 80002000 <argint>
     argint(1, &major) < 0 ||
    80004e18:	02054863          	bltz	a0,80004e48 <sys_mknod+0x76>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80004e1c:	f6841683          	lh	a3,-152(s0)
    80004e20:	f6c41603          	lh	a2,-148(s0)
    80004e24:	458d                	li	a1,3
    80004e26:	f7040513          	addi	a0,s0,-144
    80004e2a:	fffff097          	auipc	ra,0xfffff
    80004e2e:	77a080e7          	jalr	1914(ra) # 800045a4 <create>
     argint(2, &minor) < 0 ||
    80004e32:	c919                	beqz	a0,80004e48 <sys_mknod+0x76>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004e34:	ffffe097          	auipc	ra,0xffffe
    80004e38:	ff0080e7          	jalr	-16(ra) # 80002e24 <iunlockput>
  end_op();
    80004e3c:	ffffe097          	auipc	ra,0xffffe
    80004e40:	7e2080e7          	jalr	2018(ra) # 8000361e <end_op>
  return 0;
    80004e44:	4501                	li	a0,0
    80004e46:	a031                	j	80004e52 <sys_mknod+0x80>
    end_op();
    80004e48:	ffffe097          	auipc	ra,0xffffe
    80004e4c:	7d6080e7          	jalr	2006(ra) # 8000361e <end_op>
    return -1;
    80004e50:	557d                	li	a0,-1
}
    80004e52:	60ea                	ld	ra,152(sp)
    80004e54:	644a                	ld	s0,144(sp)
    80004e56:	610d                	addi	sp,sp,160
    80004e58:	8082                	ret

0000000080004e5a <sys_chdir>:

uint64
sys_chdir(void)
{
    80004e5a:	7135                	addi	sp,sp,-160
    80004e5c:	ed06                	sd	ra,152(sp)
    80004e5e:	e922                	sd	s0,144(sp)
    80004e60:	e526                	sd	s1,136(sp)
    80004e62:	e14a                	sd	s2,128(sp)
    80004e64:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80004e66:	ffffc097          	auipc	ra,0xffffc
    80004e6a:	09a080e7          	jalr	154(ra) # 80000f00 <myproc>
    80004e6e:	892a                	mv	s2,a0
  
  begin_op();
    80004e70:	ffffe097          	auipc	ra,0xffffe
    80004e74:	72e080e7          	jalr	1838(ra) # 8000359e <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80004e78:	08000613          	li	a2,128
    80004e7c:	f6040593          	addi	a1,s0,-160
    80004e80:	4501                	li	a0,0
    80004e82:	ffffd097          	auipc	ra,0xffffd
    80004e86:	1c2080e7          	jalr	450(ra) # 80002044 <argstr>
    80004e8a:	04054b63          	bltz	a0,80004ee0 <sys_chdir+0x86>
    80004e8e:	f6040513          	addi	a0,s0,-160
    80004e92:	ffffe097          	auipc	ra,0xffffe
    80004e96:	4ee080e7          	jalr	1262(ra) # 80003380 <namei>
    80004e9a:	84aa                	mv	s1,a0
    80004e9c:	c131                	beqz	a0,80004ee0 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80004e9e:	ffffe097          	auipc	ra,0xffffe
    80004ea2:	d22080e7          	jalr	-734(ra) # 80002bc0 <ilock>
  if(ip->type != T_DIR){
    80004ea6:	04449703          	lh	a4,68(s1)
    80004eaa:	4785                	li	a5,1
    80004eac:	04f71063          	bne	a4,a5,80004eec <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80004eb0:	8526                	mv	a0,s1
    80004eb2:	ffffe097          	auipc	ra,0xffffe
    80004eb6:	dd2080e7          	jalr	-558(ra) # 80002c84 <iunlock>
  iput(p->cwd);
    80004eba:	15093503          	ld	a0,336(s2)
    80004ebe:	ffffe097          	auipc	ra,0xffffe
    80004ec2:	ebe080e7          	jalr	-322(ra) # 80002d7c <iput>
  end_op();
    80004ec6:	ffffe097          	auipc	ra,0xffffe
    80004eca:	758080e7          	jalr	1880(ra) # 8000361e <end_op>
  p->cwd = ip;
    80004ece:	14993823          	sd	s1,336(s2)
  return 0;
    80004ed2:	4501                	li	a0,0
}
    80004ed4:	60ea                	ld	ra,152(sp)
    80004ed6:	644a                	ld	s0,144(sp)
    80004ed8:	64aa                	ld	s1,136(sp)
    80004eda:	690a                	ld	s2,128(sp)
    80004edc:	610d                	addi	sp,sp,160
    80004ede:	8082                	ret
    end_op();
    80004ee0:	ffffe097          	auipc	ra,0xffffe
    80004ee4:	73e080e7          	jalr	1854(ra) # 8000361e <end_op>
    return -1;
    80004ee8:	557d                	li	a0,-1
    80004eea:	b7ed                	j	80004ed4 <sys_chdir+0x7a>
    iunlockput(ip);
    80004eec:	8526                	mv	a0,s1
    80004eee:	ffffe097          	auipc	ra,0xffffe
    80004ef2:	f36080e7          	jalr	-202(ra) # 80002e24 <iunlockput>
    end_op();
    80004ef6:	ffffe097          	auipc	ra,0xffffe
    80004efa:	728080e7          	jalr	1832(ra) # 8000361e <end_op>
    return -1;
    80004efe:	557d                	li	a0,-1
    80004f00:	bfd1                	j	80004ed4 <sys_chdir+0x7a>

0000000080004f02 <sys_exec>:

uint64
sys_exec(void)
{
    80004f02:	7145                	addi	sp,sp,-464
    80004f04:	e786                	sd	ra,456(sp)
    80004f06:	e3a2                	sd	s0,448(sp)
    80004f08:	ff26                	sd	s1,440(sp)
    80004f0a:	fb4a                	sd	s2,432(sp)
    80004f0c:	f74e                	sd	s3,424(sp)
    80004f0e:	f352                	sd	s4,416(sp)
    80004f10:	ef56                	sd	s5,408(sp)
    80004f12:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004f14:	08000613          	li	a2,128
    80004f18:	f4040593          	addi	a1,s0,-192
    80004f1c:	4501                	li	a0,0
    80004f1e:	ffffd097          	auipc	ra,0xffffd
    80004f22:	126080e7          	jalr	294(ra) # 80002044 <argstr>
    return -1;
    80004f26:	597d                	li	s2,-1
  if(argstr(0, path, MAXPATH) < 0 || argaddr(1, &uargv) < 0){
    80004f28:	0e054c63          	bltz	a0,80005020 <sys_exec+0x11e>
    80004f2c:	e3840593          	addi	a1,s0,-456
    80004f30:	4505                	li	a0,1
    80004f32:	ffffd097          	auipc	ra,0xffffd
    80004f36:	0f0080e7          	jalr	240(ra) # 80002022 <argaddr>
    80004f3a:	0e054363          	bltz	a0,80005020 <sys_exec+0x11e>
  }
  memset(argv, 0, sizeof(argv));
    80004f3e:	e4040913          	addi	s2,s0,-448
    80004f42:	10000613          	li	a2,256
    80004f46:	4581                	li	a1,0
    80004f48:	854a                	mv	a0,s2
    80004f4a:	ffffb097          	auipc	ra,0xffffb
    80004f4e:	232080e7          	jalr	562(ra) # 8000017c <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80004f52:	89ca                	mv	s3,s2
  memset(argv, 0, sizeof(argv));
    80004f54:	4481                	li	s1,0
    if(i >= NELEM(argv)){
    80004f56:	02000a93          	li	s5,32
    80004f5a:	00048a1b          	sext.w	s4,s1
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80004f5e:	00349513          	slli	a0,s1,0x3
    80004f62:	e3040593          	addi	a1,s0,-464
    80004f66:	e3843783          	ld	a5,-456(s0)
    80004f6a:	953e                	add	a0,a0,a5
    80004f6c:	ffffd097          	auipc	ra,0xffffd
    80004f70:	ff8080e7          	jalr	-8(ra) # 80001f64 <fetchaddr>
    80004f74:	02054a63          	bltz	a0,80004fa8 <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80004f78:	e3043783          	ld	a5,-464(s0)
    80004f7c:	cfa9                	beqz	a5,80004fd6 <sys_exec+0xd4>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80004f7e:	ffffb097          	auipc	ra,0xffffb
    80004f82:	19e080e7          	jalr	414(ra) # 8000011c <kalloc>
    80004f86:	00a93023          	sd	a0,0(s2)
    if(argv[i] == 0)
    80004f8a:	cd19                	beqz	a0,80004fa8 <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80004f8c:	6605                	lui	a2,0x1
    80004f8e:	85aa                	mv	a1,a0
    80004f90:	e3043503          	ld	a0,-464(s0)
    80004f94:	ffffd097          	auipc	ra,0xffffd
    80004f98:	024080e7          	jalr	36(ra) # 80001fb8 <fetchstr>
    80004f9c:	00054663          	bltz	a0,80004fa8 <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80004fa0:	0485                	addi	s1,s1,1
    80004fa2:	0921                	addi	s2,s2,8
    80004fa4:	fb549be3          	bne	s1,s5,80004f5a <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fa8:	e4043503          	ld	a0,-448(s0)
    kfree(argv[i]);
  return -1;
    80004fac:	597d                	li	s2,-1
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fae:	c92d                	beqz	a0,80005020 <sys_exec+0x11e>
    kfree(argv[i]);
    80004fb0:	ffffb097          	auipc	ra,0xffffb
    80004fb4:	06c080e7          	jalr	108(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fb8:	e4840493          	addi	s1,s0,-440
    80004fbc:	10098993          	addi	s3,s3,256
    80004fc0:	6088                	ld	a0,0(s1)
    80004fc2:	cd31                	beqz	a0,8000501e <sys_exec+0x11c>
    kfree(argv[i]);
    80004fc4:	ffffb097          	auipc	ra,0xffffb
    80004fc8:	058080e7          	jalr	88(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004fcc:	04a1                	addi	s1,s1,8
    80004fce:	ff3499e3          	bne	s1,s3,80004fc0 <sys_exec+0xbe>
  return -1;
    80004fd2:	597d                	li	s2,-1
    80004fd4:	a0b1                	j	80005020 <sys_exec+0x11e>
      argv[i] = 0;
    80004fd6:	0a0e                	slli	s4,s4,0x3
    80004fd8:	fc040793          	addi	a5,s0,-64
    80004fdc:	9a3e                	add	s4,s4,a5
    80004fde:	e80a3023          	sd	zero,-384(s4)
  int ret = exec(path, argv);
    80004fe2:	e4040593          	addi	a1,s0,-448
    80004fe6:	f4040513          	addi	a0,s0,-192
    80004fea:	fffff097          	auipc	ra,0xfffff
    80004fee:	166080e7          	jalr	358(ra) # 80004150 <exec>
    80004ff2:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80004ff4:	e4043503          	ld	a0,-448(s0)
    80004ff8:	c505                	beqz	a0,80005020 <sys_exec+0x11e>
    kfree(argv[i]);
    80004ffa:	ffffb097          	auipc	ra,0xffffb
    80004ffe:	022080e7          	jalr	34(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005002:	e4840493          	addi	s1,s0,-440
    80005006:	10098993          	addi	s3,s3,256
    8000500a:	6088                	ld	a0,0(s1)
    8000500c:	c911                	beqz	a0,80005020 <sys_exec+0x11e>
    kfree(argv[i]);
    8000500e:	ffffb097          	auipc	ra,0xffffb
    80005012:	00e080e7          	jalr	14(ra) # 8000001c <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005016:	04a1                	addi	s1,s1,8
    80005018:	ff3499e3          	bne	s1,s3,8000500a <sys_exec+0x108>
    8000501c:	a011                	j	80005020 <sys_exec+0x11e>
  return -1;
    8000501e:	597d                	li	s2,-1
}
    80005020:	854a                	mv	a0,s2
    80005022:	60be                	ld	ra,456(sp)
    80005024:	641e                	ld	s0,448(sp)
    80005026:	74fa                	ld	s1,440(sp)
    80005028:	795a                	ld	s2,432(sp)
    8000502a:	79ba                	ld	s3,424(sp)
    8000502c:	7a1a                	ld	s4,416(sp)
    8000502e:	6afa                	ld	s5,408(sp)
    80005030:	6179                	addi	sp,sp,464
    80005032:	8082                	ret

0000000080005034 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005034:	7139                	addi	sp,sp,-64
    80005036:	fc06                	sd	ra,56(sp)
    80005038:	f822                	sd	s0,48(sp)
    8000503a:	f426                	sd	s1,40(sp)
    8000503c:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    8000503e:	ffffc097          	auipc	ra,0xffffc
    80005042:	ec2080e7          	jalr	-318(ra) # 80000f00 <myproc>
    80005046:	84aa                	mv	s1,a0

  if(argaddr(0, &fdarray) < 0)
    80005048:	fd840593          	addi	a1,s0,-40
    8000504c:	4501                	li	a0,0
    8000504e:	ffffd097          	auipc	ra,0xffffd
    80005052:	fd4080e7          	jalr	-44(ra) # 80002022 <argaddr>
    return -1;
    80005056:	57fd                	li	a5,-1
  if(argaddr(0, &fdarray) < 0)
    80005058:	0c054f63          	bltz	a0,80005136 <sys_pipe+0x102>
  if(pipealloc(&rf, &wf) < 0)
    8000505c:	fc840593          	addi	a1,s0,-56
    80005060:	fd040513          	addi	a0,s0,-48
    80005064:	fffff097          	auipc	ra,0xfffff
    80005068:	d9e080e7          	jalr	-610(ra) # 80003e02 <pipealloc>
    return -1;
    8000506c:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    8000506e:	0c054463          	bltz	a0,80005136 <sys_pipe+0x102>
  fd0 = -1;
    80005072:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005076:	fd043503          	ld	a0,-48(s0)
    8000507a:	fffff097          	auipc	ra,0xfffff
    8000507e:	4e2080e7          	jalr	1250(ra) # 8000455c <fdalloc>
    80005082:	fca42223          	sw	a0,-60(s0)
    80005086:	08054b63          	bltz	a0,8000511c <sys_pipe+0xe8>
    8000508a:	fc843503          	ld	a0,-56(s0)
    8000508e:	fffff097          	auipc	ra,0xfffff
    80005092:	4ce080e7          	jalr	1230(ra) # 8000455c <fdalloc>
    80005096:	fca42023          	sw	a0,-64(s0)
    8000509a:	06054863          	bltz	a0,8000510a <sys_pipe+0xd6>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    8000509e:	4691                	li	a3,4
    800050a0:	fc440613          	addi	a2,s0,-60
    800050a4:	fd843583          	ld	a1,-40(s0)
    800050a8:	68a8                	ld	a0,80(s1)
    800050aa:	ffffc097          	auipc	ra,0xffffc
    800050ae:	ad4080e7          	jalr	-1324(ra) # 80000b7e <copyout>
    800050b2:	02054063          	bltz	a0,800050d2 <sys_pipe+0x9e>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    800050b6:	4691                	li	a3,4
    800050b8:	fc040613          	addi	a2,s0,-64
    800050bc:	fd843583          	ld	a1,-40(s0)
    800050c0:	0591                	addi	a1,a1,4
    800050c2:	68a8                	ld	a0,80(s1)
    800050c4:	ffffc097          	auipc	ra,0xffffc
    800050c8:	aba080e7          	jalr	-1350(ra) # 80000b7e <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    800050cc:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    800050ce:	06055463          	bgez	a0,80005136 <sys_pipe+0x102>
    p->ofile[fd0] = 0;
    800050d2:	fc442783          	lw	a5,-60(s0)
    800050d6:	07e9                	addi	a5,a5,26
    800050d8:	078e                	slli	a5,a5,0x3
    800050da:	97a6                	add	a5,a5,s1
    800050dc:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    800050e0:	fc042783          	lw	a5,-64(s0)
    800050e4:	07e9                	addi	a5,a5,26
    800050e6:	078e                	slli	a5,a5,0x3
    800050e8:	94be                	add	s1,s1,a5
    800050ea:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    800050ee:	fd043503          	ld	a0,-48(s0)
    800050f2:	fffff097          	auipc	ra,0xfffff
    800050f6:	9b0080e7          	jalr	-1616(ra) # 80003aa2 <fileclose>
    fileclose(wf);
    800050fa:	fc843503          	ld	a0,-56(s0)
    800050fe:	fffff097          	auipc	ra,0xfffff
    80005102:	9a4080e7          	jalr	-1628(ra) # 80003aa2 <fileclose>
    return -1;
    80005106:	57fd                	li	a5,-1
    80005108:	a03d                	j	80005136 <sys_pipe+0x102>
    if(fd0 >= 0)
    8000510a:	fc442783          	lw	a5,-60(s0)
    8000510e:	0007c763          	bltz	a5,8000511c <sys_pipe+0xe8>
      p->ofile[fd0] = 0;
    80005112:	07e9                	addi	a5,a5,26
    80005114:	078e                	slli	a5,a5,0x3
    80005116:	94be                	add	s1,s1,a5
    80005118:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    8000511c:	fd043503          	ld	a0,-48(s0)
    80005120:	fffff097          	auipc	ra,0xfffff
    80005124:	982080e7          	jalr	-1662(ra) # 80003aa2 <fileclose>
    fileclose(wf);
    80005128:	fc843503          	ld	a0,-56(s0)
    8000512c:	fffff097          	auipc	ra,0xfffff
    80005130:	976080e7          	jalr	-1674(ra) # 80003aa2 <fileclose>
    return -1;
    80005134:	57fd                	li	a5,-1
}
    80005136:	853e                	mv	a0,a5
    80005138:	70e2                	ld	ra,56(sp)
    8000513a:	7442                	ld	s0,48(sp)
    8000513c:	74a2                	ld	s1,40(sp)
    8000513e:	6121                	addi	sp,sp,64
    80005140:	8082                	ret

0000000080005142 <sys_connect>:


#ifdef LAB_NET
int
sys_connect(void)
{
    80005142:	7179                	addi	sp,sp,-48
    80005144:	f406                	sd	ra,40(sp)
    80005146:	f022                	sd	s0,32(sp)
    80005148:	1800                	addi	s0,sp,48
  int fd;
  uint32 raddr;
  uint32 rport;
  uint32 lport;

  if (argint(0, (int*)&raddr) < 0 ||
    8000514a:	fe440593          	addi	a1,s0,-28
    8000514e:	4501                	li	a0,0
    80005150:	ffffd097          	auipc	ra,0xffffd
    80005154:	eb0080e7          	jalr	-336(ra) # 80002000 <argint>
    80005158:	06054663          	bltz	a0,800051c4 <sys_connect+0x82>
      argint(1, (int*)&lport) < 0 ||
    8000515c:	fdc40593          	addi	a1,s0,-36
    80005160:	4505                	li	a0,1
    80005162:	ffffd097          	auipc	ra,0xffffd
    80005166:	e9e080e7          	jalr	-354(ra) # 80002000 <argint>
  if (argint(0, (int*)&raddr) < 0 ||
    8000516a:	04054f63          	bltz	a0,800051c8 <sys_connect+0x86>
      argint(2, (int*)&rport) < 0) {
    8000516e:	fe040593          	addi	a1,s0,-32
    80005172:	4509                	li	a0,2
    80005174:	ffffd097          	auipc	ra,0xffffd
    80005178:	e8c080e7          	jalr	-372(ra) # 80002000 <argint>
      argint(1, (int*)&lport) < 0 ||
    8000517c:	04054863          	bltz	a0,800051cc <sys_connect+0x8a>
    return -1;
  }

  if(sockalloc(&f, raddr, lport, rport) < 0)
    80005180:	fe045683          	lhu	a3,-32(s0)
    80005184:	fdc45603          	lhu	a2,-36(s0)
    80005188:	fe442583          	lw	a1,-28(s0)
    8000518c:	fe840513          	addi	a0,s0,-24
    80005190:	00001097          	auipc	ra,0x1
    80005194:	240080e7          	jalr	576(ra) # 800063d0 <sockalloc>
    80005198:	02054c63          	bltz	a0,800051d0 <sys_connect+0x8e>
    return -1;
  if((fd=fdalloc(f)) < 0){
    8000519c:	fe843503          	ld	a0,-24(s0)
    800051a0:	fffff097          	auipc	ra,0xfffff
    800051a4:	3bc080e7          	jalr	956(ra) # 8000455c <fdalloc>
    800051a8:	00054663          	bltz	a0,800051b4 <sys_connect+0x72>
    fileclose(f);
    return -1;
  }

  return fd;
}
    800051ac:	70a2                	ld	ra,40(sp)
    800051ae:	7402                	ld	s0,32(sp)
    800051b0:	6145                	addi	sp,sp,48
    800051b2:	8082                	ret
    fileclose(f);
    800051b4:	fe843503          	ld	a0,-24(s0)
    800051b8:	fffff097          	auipc	ra,0xfffff
    800051bc:	8ea080e7          	jalr	-1814(ra) # 80003aa2 <fileclose>
    return -1;
    800051c0:	557d                	li	a0,-1
    800051c2:	b7ed                	j	800051ac <sys_connect+0x6a>
    return -1;
    800051c4:	557d                	li	a0,-1
    800051c6:	b7dd                	j	800051ac <sys_connect+0x6a>
    800051c8:	557d                	li	a0,-1
    800051ca:	b7cd                	j	800051ac <sys_connect+0x6a>
    800051cc:	557d                	li	a0,-1
    800051ce:	bff9                	j	800051ac <sys_connect+0x6a>
    return -1;
    800051d0:	557d                	li	a0,-1
    800051d2:	bfe9                	j	800051ac <sys_connect+0x6a>
	...

00000000800051e0 <kernelvec>:
    800051e0:	7111                	addi	sp,sp,-256
    800051e2:	e006                	sd	ra,0(sp)
    800051e4:	e40a                	sd	sp,8(sp)
    800051e6:	e80e                	sd	gp,16(sp)
    800051e8:	ec12                	sd	tp,24(sp)
    800051ea:	f016                	sd	t0,32(sp)
    800051ec:	f41a                	sd	t1,40(sp)
    800051ee:	f81e                	sd	t2,48(sp)
    800051f0:	fc22                	sd	s0,56(sp)
    800051f2:	e0a6                	sd	s1,64(sp)
    800051f4:	e4aa                	sd	a0,72(sp)
    800051f6:	e8ae                	sd	a1,80(sp)
    800051f8:	ecb2                	sd	a2,88(sp)
    800051fa:	f0b6                	sd	a3,96(sp)
    800051fc:	f4ba                	sd	a4,104(sp)
    800051fe:	f8be                	sd	a5,112(sp)
    80005200:	fcc2                	sd	a6,120(sp)
    80005202:	e146                	sd	a7,128(sp)
    80005204:	e54a                	sd	s2,136(sp)
    80005206:	e94e                	sd	s3,144(sp)
    80005208:	ed52                	sd	s4,152(sp)
    8000520a:	f156                	sd	s5,160(sp)
    8000520c:	f55a                	sd	s6,168(sp)
    8000520e:	f95e                	sd	s7,176(sp)
    80005210:	fd62                	sd	s8,184(sp)
    80005212:	e1e6                	sd	s9,192(sp)
    80005214:	e5ea                	sd	s10,200(sp)
    80005216:	e9ee                	sd	s11,208(sp)
    80005218:	edf2                	sd	t3,216(sp)
    8000521a:	f1f6                	sd	t4,224(sp)
    8000521c:	f5fa                	sd	t5,232(sp)
    8000521e:	f9fe                	sd	t6,240(sp)
    80005220:	c0dfc0ef          	jal	ra,80001e2c <kerneltrap>
    80005224:	6082                	ld	ra,0(sp)
    80005226:	6122                	ld	sp,8(sp)
    80005228:	61c2                	ld	gp,16(sp)
    8000522a:	7282                	ld	t0,32(sp)
    8000522c:	7322                	ld	t1,40(sp)
    8000522e:	73c2                	ld	t2,48(sp)
    80005230:	7462                	ld	s0,56(sp)
    80005232:	6486                	ld	s1,64(sp)
    80005234:	6526                	ld	a0,72(sp)
    80005236:	65c6                	ld	a1,80(sp)
    80005238:	6666                	ld	a2,88(sp)
    8000523a:	7686                	ld	a3,96(sp)
    8000523c:	7726                	ld	a4,104(sp)
    8000523e:	77c6                	ld	a5,112(sp)
    80005240:	7866                	ld	a6,120(sp)
    80005242:	688a                	ld	a7,128(sp)
    80005244:	692a                	ld	s2,136(sp)
    80005246:	69ca                	ld	s3,144(sp)
    80005248:	6a6a                	ld	s4,152(sp)
    8000524a:	7a8a                	ld	s5,160(sp)
    8000524c:	7b2a                	ld	s6,168(sp)
    8000524e:	7bca                	ld	s7,176(sp)
    80005250:	7c6a                	ld	s8,184(sp)
    80005252:	6c8e                	ld	s9,192(sp)
    80005254:	6d2e                	ld	s10,200(sp)
    80005256:	6dce                	ld	s11,208(sp)
    80005258:	6e6e                	ld	t3,216(sp)
    8000525a:	7e8e                	ld	t4,224(sp)
    8000525c:	7f2e                	ld	t5,232(sp)
    8000525e:	7fce                	ld	t6,240(sp)
    80005260:	6111                	addi	sp,sp,256
    80005262:	10200073          	sret
    80005266:	00000013          	nop
    8000526a:	00000013          	nop
    8000526e:	0001                	nop

0000000080005270 <timervec>:
    80005270:	34051573          	csrrw	a0,mscratch,a0
    80005274:	e10c                	sd	a1,0(a0)
    80005276:	e510                	sd	a2,8(a0)
    80005278:	e914                	sd	a3,16(a0)
    8000527a:	6d0c                	ld	a1,24(a0)
    8000527c:	7110                	ld	a2,32(a0)
    8000527e:	6194                	ld	a3,0(a1)
    80005280:	96b2                	add	a3,a3,a2
    80005282:	e194                	sd	a3,0(a1)
    80005284:	4589                	li	a1,2
    80005286:	14459073          	csrw	sip,a1
    8000528a:	6914                	ld	a3,16(a0)
    8000528c:	6510                	ld	a2,8(a0)
    8000528e:	610c                	ld	a1,0(a0)
    80005290:	34051573          	csrrw	a0,mscratch,a0
    80005294:	30200073          	mret
	...

000000008000529a <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000529a:	1141                	addi	sp,sp,-16
    8000529c:	e422                	sd	s0,8(sp)
    8000529e:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    800052a0:	0c0007b7          	lui	a5,0xc000
    800052a4:	4705                	li	a4,1
    800052a6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    800052a8:	c3d8                	sw	a4,4(a5)
    800052aa:	0791                	addi	a5,a5,4
  
#ifdef LAB_NET
  // PCIE IRQs are 32 to 35
  for(int irq = 1; irq < 0x35; irq++){
    *(uint32*)(PLIC + irq*4) = 1;
    800052ac:	4685                	li	a3,1
  for(int irq = 1; irq < 0x35; irq++){
    800052ae:	0c000737          	lui	a4,0xc000
    800052b2:	0d470713          	addi	a4,a4,212 # c0000d4 <_entry-0x73ffff2c>
    *(uint32*)(PLIC + irq*4) = 1;
    800052b6:	c394                	sw	a3,0(a5)
  for(int irq = 1; irq < 0x35; irq++){
    800052b8:	0791                	addi	a5,a5,4
    800052ba:	fee79ee3          	bne	a5,a4,800052b6 <plicinit+0x1c>
  }
#endif  
}
    800052be:	6422                	ld	s0,8(sp)
    800052c0:	0141                	addi	sp,sp,16
    800052c2:	8082                	ret

00000000800052c4 <plicinithart>:

void
plicinithart(void)
{
    800052c4:	1141                	addi	sp,sp,-16
    800052c6:	e406                	sd	ra,8(sp)
    800052c8:	e022                	sd	s0,0(sp)
    800052ca:	0800                	addi	s0,sp,16
  int hart = cpuid();
    800052cc:	ffffc097          	auipc	ra,0xffffc
    800052d0:	c08080e7          	jalr	-1016(ra) # 80000ed4 <cpuid>
  
  // set uart's enable bit for this hart's S-mode. 
  *(uint32*)PLIC_SENABLE(hart)= (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    800052d4:	0085171b          	slliw	a4,a0,0x8
    800052d8:	0c0027b7          	lui	a5,0xc002
    800052dc:	97ba                	add	a5,a5,a4
    800052de:	40200713          	li	a4,1026
    800052e2:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

#ifdef LAB_NET
  // hack to get at next 32 IRQs for e1000
  *(uint32*)(PLIC_SENABLE(hart)+4) = 0xffffffff;
    800052e6:	577d                	li	a4,-1
    800052e8:	08e7a223          	sw	a4,132(a5)
#endif
  
  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    800052ec:	00d5151b          	slliw	a0,a0,0xd
    800052f0:	0c2017b7          	lui	a5,0xc201
    800052f4:	953e                	add	a0,a0,a5
    800052f6:	00052023          	sw	zero,0(a0)
}
    800052fa:	60a2                	ld	ra,8(sp)
    800052fc:	6402                	ld	s0,0(sp)
    800052fe:	0141                	addi	sp,sp,16
    80005300:	8082                	ret

0000000080005302 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005302:	1141                	addi	sp,sp,-16
    80005304:	e406                	sd	ra,8(sp)
    80005306:	e022                	sd	s0,0(sp)
    80005308:	0800                	addi	s0,sp,16
  int hart = cpuid();
    8000530a:	ffffc097          	auipc	ra,0xffffc
    8000530e:	bca080e7          	jalr	-1078(ra) # 80000ed4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005312:	00d5151b          	slliw	a0,a0,0xd
    80005316:	0c2017b7          	lui	a5,0xc201
    8000531a:	97aa                	add	a5,a5,a0
  return irq;
}
    8000531c:	43c8                	lw	a0,4(a5)
    8000531e:	60a2                	ld	ra,8(sp)
    80005320:	6402                	ld	s0,0(sp)
    80005322:	0141                	addi	sp,sp,16
    80005324:	8082                	ret

0000000080005326 <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005326:	1101                	addi	sp,sp,-32
    80005328:	ec06                	sd	ra,24(sp)
    8000532a:	e822                	sd	s0,16(sp)
    8000532c:	e426                	sd	s1,8(sp)
    8000532e:	1000                	addi	s0,sp,32
    80005330:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005332:	ffffc097          	auipc	ra,0xffffc
    80005336:	ba2080e7          	jalr	-1118(ra) # 80000ed4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000533a:	00d5151b          	slliw	a0,a0,0xd
    8000533e:	0c2017b7          	lui	a5,0xc201
    80005342:	97aa                	add	a5,a5,a0
    80005344:	c3c4                	sw	s1,4(a5)
}
    80005346:	60e2                	ld	ra,24(sp)
    80005348:	6442                	ld	s0,16(sp)
    8000534a:	64a2                	ld	s1,8(sp)
    8000534c:	6105                	addi	sp,sp,32
    8000534e:	8082                	ret

0000000080005350 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005350:	1141                	addi	sp,sp,-16
    80005352:	e406                	sd	ra,8(sp)
    80005354:	e022                	sd	s0,0(sp)
    80005356:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005358:	479d                	li	a5,7
    8000535a:	06a7c963          	blt	a5,a0,800053cc <free_desc+0x7c>
    panic("free_desc 1");
  if(disk.free[i])
    8000535e:	00017797          	auipc	a5,0x17
    80005362:	ca278793          	addi	a5,a5,-862 # 8001c000 <disk>
    80005366:	00a78733          	add	a4,a5,a0
    8000536a:	6789                	lui	a5,0x2
    8000536c:	97ba                	add	a5,a5,a4
    8000536e:	0187c783          	lbu	a5,24(a5) # 2018 <_entry-0x7fffdfe8>
    80005372:	e7ad                	bnez	a5,800053dc <free_desc+0x8c>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005374:	00451793          	slli	a5,a0,0x4
    80005378:	00019717          	auipc	a4,0x19
    8000537c:	c8870713          	addi	a4,a4,-888 # 8001e000 <disk+0x2000>
    80005380:	6314                	ld	a3,0(a4)
    80005382:	96be                	add	a3,a3,a5
    80005384:	0006b023          	sd	zero,0(a3)
  disk.desc[i].len = 0;
    80005388:	6314                	ld	a3,0(a4)
    8000538a:	96be                	add	a3,a3,a5
    8000538c:	0006a423          	sw	zero,8(a3)
  disk.desc[i].flags = 0;
    80005390:	6314                	ld	a3,0(a4)
    80005392:	96be                	add	a3,a3,a5
    80005394:	00069623          	sh	zero,12(a3)
  disk.desc[i].next = 0;
    80005398:	6318                	ld	a4,0(a4)
    8000539a:	97ba                	add	a5,a5,a4
    8000539c:	00079723          	sh	zero,14(a5)
  disk.free[i] = 1;
    800053a0:	00017797          	auipc	a5,0x17
    800053a4:	c6078793          	addi	a5,a5,-928 # 8001c000 <disk>
    800053a8:	97aa                	add	a5,a5,a0
    800053aa:	6509                	lui	a0,0x2
    800053ac:	953e                	add	a0,a0,a5
    800053ae:	4785                	li	a5,1
    800053b0:	00f50c23          	sb	a5,24(a0) # 2018 <_entry-0x7fffdfe8>
  wakeup(&disk.free[0]);
    800053b4:	00019517          	auipc	a0,0x19
    800053b8:	c6450513          	addi	a0,a0,-924 # 8001e018 <disk+0x2018>
    800053bc:	ffffc097          	auipc	ra,0xffffc
    800053c0:	4e4080e7          	jalr	1252(ra) # 800018a0 <wakeup>
}
    800053c4:	60a2                	ld	ra,8(sp)
    800053c6:	6402                	ld	s0,0(sp)
    800053c8:	0141                	addi	sp,sp,16
    800053ca:	8082                	ret
    panic("free_desc 1");
    800053cc:	00004517          	auipc	a0,0x4
    800053d0:	34450513          	addi	a0,a0,836 # 80009710 <syscalls+0x388>
    800053d4:	00002097          	auipc	ra,0x2
    800053d8:	9b4080e7          	jalr	-1612(ra) # 80006d88 <panic>
    panic("free_desc 2");
    800053dc:	00004517          	auipc	a0,0x4
    800053e0:	34450513          	addi	a0,a0,836 # 80009720 <syscalls+0x398>
    800053e4:	00002097          	auipc	ra,0x2
    800053e8:	9a4080e7          	jalr	-1628(ra) # 80006d88 <panic>

00000000800053ec <virtio_disk_init>:
{
    800053ec:	1101                	addi	sp,sp,-32
    800053ee:	ec06                	sd	ra,24(sp)
    800053f0:	e822                	sd	s0,16(sp)
    800053f2:	e426                	sd	s1,8(sp)
    800053f4:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    800053f6:	00004597          	auipc	a1,0x4
    800053fa:	33a58593          	addi	a1,a1,826 # 80009730 <syscalls+0x3a8>
    800053fe:	00019517          	auipc	a0,0x19
    80005402:	d2a50513          	addi	a0,a0,-726 # 8001e128 <disk+0x2128>
    80005406:	00002097          	auipc	ra,0x2
    8000540a:	e5e080e7          	jalr	-418(ra) # 80007264 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000540e:	100017b7          	lui	a5,0x10001
    80005412:	4398                	lw	a4,0(a5)
    80005414:	2701                	sext.w	a4,a4
    80005416:	747277b7          	lui	a5,0x74727
    8000541a:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000541e:	0ef71163          	bne	a4,a5,80005500 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005422:	100017b7          	lui	a5,0x10001
    80005426:	43dc                	lw	a5,4(a5)
    80005428:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    8000542a:	4705                	li	a4,1
    8000542c:	0ce79a63          	bne	a5,a4,80005500 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005430:	100017b7          	lui	a5,0x10001
    80005434:	479c                	lw	a5,8(a5)
    80005436:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 1 ||
    80005438:	4709                	li	a4,2
    8000543a:	0ce79363          	bne	a5,a4,80005500 <virtio_disk_init+0x114>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000543e:	100017b7          	lui	a5,0x10001
    80005442:	47d8                	lw	a4,12(a5)
    80005444:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005446:	554d47b7          	lui	a5,0x554d4
    8000544a:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000544e:	0af71963          	bne	a4,a5,80005500 <virtio_disk_init+0x114>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005452:	100017b7          	lui	a5,0x10001
    80005456:	4705                	li	a4,1
    80005458:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000545a:	470d                	li	a4,3
    8000545c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000545e:	4b94                	lw	a3,16(a5)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005460:	c7ffe737          	lui	a4,0xc7ffe
    80005464:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fd71df>
    80005468:	8f75                	and	a4,a4,a3
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000546a:	2701                	sext.w	a4,a4
    8000546c:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000546e:	472d                	li	a4,11
    80005470:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    80005472:	473d                	li	a4,15
    80005474:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_GUEST_PAGE_SIZE) = PGSIZE;
    80005476:	6705                	lui	a4,0x1
    80005478:	d798                	sw	a4,40(a5)
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000547a:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000547e:	5bdc                	lw	a5,52(a5)
    80005480:	2781                	sext.w	a5,a5
  if(max == 0)
    80005482:	c7d9                	beqz	a5,80005510 <virtio_disk_init+0x124>
  if(max < NUM)
    80005484:	471d                	li	a4,7
    80005486:	08f77d63          	bleu	a5,a4,80005520 <virtio_disk_init+0x134>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000548a:	100014b7          	lui	s1,0x10001
    8000548e:	47a1                	li	a5,8
    80005490:	dc9c                	sw	a5,56(s1)
  memset(disk.pages, 0, sizeof(disk.pages));
    80005492:	6609                	lui	a2,0x2
    80005494:	4581                	li	a1,0
    80005496:	00017517          	auipc	a0,0x17
    8000549a:	b6a50513          	addi	a0,a0,-1174 # 8001c000 <disk>
    8000549e:	ffffb097          	auipc	ra,0xffffb
    800054a2:	cde080e7          	jalr	-802(ra) # 8000017c <memset>
  *R(VIRTIO_MMIO_QUEUE_PFN) = ((uint64)disk.pages) >> PGSHIFT;
    800054a6:	00017717          	auipc	a4,0x17
    800054aa:	b5a70713          	addi	a4,a4,-1190 # 8001c000 <disk>
    800054ae:	00c75793          	srli	a5,a4,0xc
    800054b2:	2781                	sext.w	a5,a5
    800054b4:	c0bc                	sw	a5,64(s1)
  disk.desc = (struct virtq_desc *) disk.pages;
    800054b6:	00019797          	auipc	a5,0x19
    800054ba:	b4a78793          	addi	a5,a5,-1206 # 8001e000 <disk+0x2000>
    800054be:	e398                	sd	a4,0(a5)
  disk.avail = (struct virtq_avail *)(disk.pages + NUM*sizeof(struct virtq_desc));
    800054c0:	00017717          	auipc	a4,0x17
    800054c4:	bc070713          	addi	a4,a4,-1088 # 8001c080 <disk+0x80>
    800054c8:	e798                	sd	a4,8(a5)
  disk.used = (struct virtq_used *) (disk.pages + PGSIZE);
    800054ca:	00018717          	auipc	a4,0x18
    800054ce:	b3670713          	addi	a4,a4,-1226 # 8001d000 <disk+0x1000>
    800054d2:	eb98                	sd	a4,16(a5)
    disk.free[i] = 1;
    800054d4:	4705                	li	a4,1
    800054d6:	00e78c23          	sb	a4,24(a5)
    800054da:	00e78ca3          	sb	a4,25(a5)
    800054de:	00e78d23          	sb	a4,26(a5)
    800054e2:	00e78da3          	sb	a4,27(a5)
    800054e6:	00e78e23          	sb	a4,28(a5)
    800054ea:	00e78ea3          	sb	a4,29(a5)
    800054ee:	00e78f23          	sb	a4,30(a5)
    800054f2:	00e78fa3          	sb	a4,31(a5)
}
    800054f6:	60e2                	ld	ra,24(sp)
    800054f8:	6442                	ld	s0,16(sp)
    800054fa:	64a2                	ld	s1,8(sp)
    800054fc:	6105                	addi	sp,sp,32
    800054fe:	8082                	ret
    panic("could not find virtio disk");
    80005500:	00004517          	auipc	a0,0x4
    80005504:	24050513          	addi	a0,a0,576 # 80009740 <syscalls+0x3b8>
    80005508:	00002097          	auipc	ra,0x2
    8000550c:	880080e7          	jalr	-1920(ra) # 80006d88 <panic>
    panic("virtio disk has no queue 0");
    80005510:	00004517          	auipc	a0,0x4
    80005514:	25050513          	addi	a0,a0,592 # 80009760 <syscalls+0x3d8>
    80005518:	00002097          	auipc	ra,0x2
    8000551c:	870080e7          	jalr	-1936(ra) # 80006d88 <panic>
    panic("virtio disk max queue too short");
    80005520:	00004517          	auipc	a0,0x4
    80005524:	26050513          	addi	a0,a0,608 # 80009780 <syscalls+0x3f8>
    80005528:	00002097          	auipc	ra,0x2
    8000552c:	860080e7          	jalr	-1952(ra) # 80006d88 <panic>

0000000080005530 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005530:	711d                	addi	sp,sp,-96
    80005532:	ec86                	sd	ra,88(sp)
    80005534:	e8a2                	sd	s0,80(sp)
    80005536:	e4a6                	sd	s1,72(sp)
    80005538:	e0ca                	sd	s2,64(sp)
    8000553a:	fc4e                	sd	s3,56(sp)
    8000553c:	f852                	sd	s4,48(sp)
    8000553e:	f456                	sd	s5,40(sp)
    80005540:	f05a                	sd	s6,32(sp)
    80005542:	ec5e                	sd	s7,24(sp)
    80005544:	e862                	sd	s8,16(sp)
    80005546:	1080                	addi	s0,sp,96
    80005548:	892a                	mv	s2,a0
    8000554a:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000554c:	00c52b83          	lw	s7,12(a0)
    80005550:	001b9b9b          	slliw	s7,s7,0x1
    80005554:	1b82                	slli	s7,s7,0x20
    80005556:	020bdb93          	srli	s7,s7,0x20

  acquire(&disk.vdisk_lock);
    8000555a:	00019517          	auipc	a0,0x19
    8000555e:	bce50513          	addi	a0,a0,-1074 # 8001e128 <disk+0x2128>
    80005562:	00002097          	auipc	ra,0x2
    80005566:	d92080e7          	jalr	-622(ra) # 800072f4 <acquire>
    if(disk.free[i]){
    8000556a:	00019997          	auipc	s3,0x19
    8000556e:	a9698993          	addi	s3,s3,-1386 # 8001e000 <disk+0x2000>
  for(int i = 0; i < NUM; i++){
    80005572:	4b21                	li	s6,8
      disk.free[i] = 0;
    80005574:	00017a97          	auipc	s5,0x17
    80005578:	a8ca8a93          	addi	s5,s5,-1396 # 8001c000 <disk>
  for(int i = 0; i < 3; i++){
    8000557c:	4a0d                	li	s4,3
    8000557e:	a079                	j	8000560c <virtio_disk_rw+0xdc>
      disk.free[i] = 0;
    80005580:	00fa86b3          	add	a3,s5,a5
    80005584:	96ae                	add	a3,a3,a1
    80005586:	00068c23          	sb	zero,24(a3)
    idx[i] = alloc_desc();
    8000558a:	c21c                	sw	a5,0(a2)
    if(idx[i] < 0){
    8000558c:	0207ca63          	bltz	a5,800055c0 <virtio_disk_rw+0x90>
  for(int i = 0; i < 3; i++){
    80005590:	2485                	addiw	s1,s1,1
    80005592:	0711                	addi	a4,a4,4
    80005594:	25448b63          	beq	s1,s4,800057ea <virtio_disk_rw+0x2ba>
    idx[i] = alloc_desc();
    80005598:	863a                	mv	a2,a4
    if(disk.free[i]){
    8000559a:	0189c783          	lbu	a5,24(s3)
    8000559e:	26079e63          	bnez	a5,8000581a <virtio_disk_rw+0x2ea>
    800055a2:	00019697          	auipc	a3,0x19
    800055a6:	a7768693          	addi	a3,a3,-1417 # 8001e019 <disk+0x2019>
  for(int i = 0; i < NUM; i++){
    800055aa:	87aa                	mv	a5,a0
    if(disk.free[i]){
    800055ac:	0006c803          	lbu	a6,0(a3)
    800055b0:	fc0818e3          	bnez	a6,80005580 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    800055b4:	2785                	addiw	a5,a5,1
    800055b6:	0685                	addi	a3,a3,1
    800055b8:	ff679ae3          	bne	a5,s6,800055ac <virtio_disk_rw+0x7c>
    idx[i] = alloc_desc();
    800055bc:	57fd                	li	a5,-1
    800055be:	c21c                	sw	a5,0(a2)
      for(int j = 0; j < i; j++)
    800055c0:	02905a63          	blez	s1,800055f4 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800055c4:	fa042503          	lw	a0,-96(s0)
    800055c8:	00000097          	auipc	ra,0x0
    800055cc:	d88080e7          	jalr	-632(ra) # 80005350 <free_desc>
      for(int j = 0; j < i; j++)
    800055d0:	4785                	li	a5,1
    800055d2:	0297d163          	ble	s1,a5,800055f4 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800055d6:	fa442503          	lw	a0,-92(s0)
    800055da:	00000097          	auipc	ra,0x0
    800055de:	d76080e7          	jalr	-650(ra) # 80005350 <free_desc>
      for(int j = 0; j < i; j++)
    800055e2:	4789                	li	a5,2
    800055e4:	0097d863          	ble	s1,a5,800055f4 <virtio_disk_rw+0xc4>
        free_desc(idx[j]);
    800055e8:	fa842503          	lw	a0,-88(s0)
    800055ec:	00000097          	auipc	ra,0x0
    800055f0:	d64080e7          	jalr	-668(ra) # 80005350 <free_desc>
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    800055f4:	00019597          	auipc	a1,0x19
    800055f8:	b3458593          	addi	a1,a1,-1228 # 8001e128 <disk+0x2128>
    800055fc:	00019517          	auipc	a0,0x19
    80005600:	a1c50513          	addi	a0,a0,-1508 # 8001e018 <disk+0x2018>
    80005604:	ffffc097          	auipc	ra,0xffffc
    80005608:	116080e7          	jalr	278(ra) # 8000171a <sleep>
  for(int i = 0; i < 3; i++){
    8000560c:	fa040713          	addi	a4,s0,-96
    80005610:	4481                	li	s1,0
  for(int i = 0; i < NUM; i++){
    80005612:	4505                	li	a0,1
      disk.free[i] = 0;
    80005614:	6589                	lui	a1,0x2
    80005616:	b749                	j	80005598 <virtio_disk_rw+0x68>
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];

  if(write)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
    80005618:	20058793          	addi	a5,a1,512 # 2200 <_entry-0x7fffde00>
    8000561c:	00479613          	slli	a2,a5,0x4
    80005620:	00017797          	auipc	a5,0x17
    80005624:	9e078793          	addi	a5,a5,-1568 # 8001c000 <disk>
    80005628:	97b2                	add	a5,a5,a2
    8000562a:	4605                	li	a2,1
    8000562c:	0ac7a423          	sw	a2,168(a5)
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    80005630:	20058793          	addi	a5,a1,512
    80005634:	00479613          	slli	a2,a5,0x4
    80005638:	00017797          	auipc	a5,0x17
    8000563c:	9c878793          	addi	a5,a5,-1592 # 8001c000 <disk>
    80005640:	97b2                	add	a5,a5,a2
    80005642:	0a07a623          	sw	zero,172(a5)
  buf0->sector = sector;
    80005646:	0b77b823          	sd	s7,176(a5)

  disk.desc[idx[0]].addr = (uint64) buf0;
    8000564a:	00019797          	auipc	a5,0x19
    8000564e:	9b678793          	addi	a5,a5,-1610 # 8001e000 <disk+0x2000>
    80005652:	6390                	ld	a2,0(a5)
    80005654:	963a                	add	a2,a2,a4
    80005656:	7779                	lui	a4,0xffffe
    80005658:	9732                	add	a4,a4,a2
    8000565a:	e314                	sd	a3,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    8000565c:	00459713          	slli	a4,a1,0x4
    80005660:	6394                	ld	a3,0(a5)
    80005662:	96ba                	add	a3,a3,a4
    80005664:	4641                	li	a2,16
    80005666:	c690                	sw	a2,8(a3)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005668:	6394                	ld	a3,0(a5)
    8000566a:	96ba                	add	a3,a3,a4
    8000566c:	4605                	li	a2,1
    8000566e:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[0]].next = idx[1];
    80005672:	fa442683          	lw	a3,-92(s0)
    80005676:	6390                	ld	a2,0(a5)
    80005678:	963a                	add	a2,a2,a4
    8000567a:	00d61723          	sh	a3,14(a2) # 200e <_entry-0x7fffdff2>

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000567e:	0692                	slli	a3,a3,0x4
    80005680:	6390                	ld	a2,0(a5)
    80005682:	9636                	add	a2,a2,a3
    80005684:	05890513          	addi	a0,s2,88
    80005688:	e208                	sd	a0,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    8000568a:	639c                	ld	a5,0(a5)
    8000568c:	97b6                	add	a5,a5,a3
    8000568e:	40000613          	li	a2,1024
    80005692:	c790                	sw	a2,8(a5)
  if(write)
    80005694:	140c0163          	beqz	s8,800057d6 <virtio_disk_rw+0x2a6>
    disk.desc[idx[1]].flags = 0; // device reads b->data
    80005698:	00019797          	auipc	a5,0x19
    8000569c:	96878793          	addi	a5,a5,-1688 # 8001e000 <disk+0x2000>
    800056a0:	639c                	ld	a5,0(a5)
    800056a2:	97b6                	add	a5,a5,a3
    800056a4:	00079623          	sh	zero,12(a5)
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800056a8:	00017897          	auipc	a7,0x17
    800056ac:	95888893          	addi	a7,a7,-1704 # 8001c000 <disk>
    800056b0:	00019797          	auipc	a5,0x19
    800056b4:	95078793          	addi	a5,a5,-1712 # 8001e000 <disk+0x2000>
    800056b8:	6390                	ld	a2,0(a5)
    800056ba:	9636                	add	a2,a2,a3
    800056bc:	00c65503          	lhu	a0,12(a2)
    800056c0:	00156513          	ori	a0,a0,1
    800056c4:	00a61623          	sh	a0,12(a2)
  disk.desc[idx[1]].next = idx[2];
    800056c8:	fa842603          	lw	a2,-88(s0)
    800056cc:	6388                	ld	a0,0(a5)
    800056ce:	96aa                	add	a3,a3,a0
    800056d0:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    800056d4:	20058513          	addi	a0,a1,512
    800056d8:	0512                	slli	a0,a0,0x4
    800056da:	9546                	add	a0,a0,a7
    800056dc:	56fd                	li	a3,-1
    800056de:	02d50823          	sb	a3,48(a0)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    800056e2:	00461693          	slli	a3,a2,0x4
    800056e6:	6390                	ld	a2,0(a5)
    800056e8:	9636                	add	a2,a2,a3
    800056ea:	6809                	lui	a6,0x2
    800056ec:	03080813          	addi	a6,a6,48 # 2030 <_entry-0x7fffdfd0>
    800056f0:	9742                	add	a4,a4,a6
    800056f2:	9746                	add	a4,a4,a7
    800056f4:	e218                	sd	a4,0(a2)
  disk.desc[idx[2]].len = 1;
    800056f6:	6398                	ld	a4,0(a5)
    800056f8:	9736                	add	a4,a4,a3
    800056fa:	4605                	li	a2,1
    800056fc:	c710                	sw	a2,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    800056fe:	6398                	ld	a4,0(a5)
    80005700:	9736                	add	a4,a4,a3
    80005702:	4809                	li	a6,2
    80005704:	01071623          	sh	a6,12(a4) # ffffffffffffe00c <end+0xffffffff7ffd6a8c>
  disk.desc[idx[2]].next = 0;
    80005708:	6398                	ld	a4,0(a5)
    8000570a:	96ba                	add	a3,a3,a4
    8000570c:	00069723          	sh	zero,14(a3)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    80005710:	00c92223          	sw	a2,4(s2)
  disk.info[idx[0]].b = b;
    80005714:	03253423          	sd	s2,40(a0)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005718:	6794                	ld	a3,8(a5)
    8000571a:	0026d703          	lhu	a4,2(a3)
    8000571e:	8b1d                	andi	a4,a4,7
    80005720:	0706                	slli	a4,a4,0x1
    80005722:	9736                	add	a4,a4,a3
    80005724:	00b71223          	sh	a1,4(a4)

  __sync_synchronize();
    80005728:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    8000572c:	6798                	ld	a4,8(a5)
    8000572e:	00275783          	lhu	a5,2(a4)
    80005732:	2785                	addiw	a5,a5,1
    80005734:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005738:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    8000573c:	100017b7          	lui	a5,0x10001
    80005740:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80005744:	00492703          	lw	a4,4(s2)
    80005748:	4785                	li	a5,1
    8000574a:	02f71163          	bne	a4,a5,8000576c <virtio_disk_rw+0x23c>
    sleep(b, &disk.vdisk_lock);
    8000574e:	00019997          	auipc	s3,0x19
    80005752:	9da98993          	addi	s3,s3,-1574 # 8001e128 <disk+0x2128>
  while(b->disk == 1) {
    80005756:	4485                	li	s1,1
    sleep(b, &disk.vdisk_lock);
    80005758:	85ce                	mv	a1,s3
    8000575a:	854a                	mv	a0,s2
    8000575c:	ffffc097          	auipc	ra,0xffffc
    80005760:	fbe080e7          	jalr	-66(ra) # 8000171a <sleep>
  while(b->disk == 1) {
    80005764:	00492783          	lw	a5,4(s2)
    80005768:	fe9788e3          	beq	a5,s1,80005758 <virtio_disk_rw+0x228>
  }

  disk.info[idx[0]].b = 0;
    8000576c:	fa042503          	lw	a0,-96(s0)
    80005770:	20050793          	addi	a5,a0,512
    80005774:	00479713          	slli	a4,a5,0x4
    80005778:	00017797          	auipc	a5,0x17
    8000577c:	88878793          	addi	a5,a5,-1912 # 8001c000 <disk>
    80005780:	97ba                	add	a5,a5,a4
    80005782:	0207b423          	sd	zero,40(a5)
    int flag = disk.desc[i].flags;
    80005786:	00019997          	auipc	s3,0x19
    8000578a:	87a98993          	addi	s3,s3,-1926 # 8001e000 <disk+0x2000>
    8000578e:	00451713          	slli	a4,a0,0x4
    80005792:	0009b783          	ld	a5,0(s3)
    80005796:	97ba                	add	a5,a5,a4
    80005798:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    8000579c:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057a0:	00000097          	auipc	ra,0x0
    800057a4:	bb0080e7          	jalr	-1104(ra) # 80005350 <free_desc>
      i = nxt;
    800057a8:	854a                	mv	a0,s2
    if(flag & VRING_DESC_F_NEXT)
    800057aa:	8885                	andi	s1,s1,1
    800057ac:	f0ed                	bnez	s1,8000578e <virtio_disk_rw+0x25e>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057ae:	00019517          	auipc	a0,0x19
    800057b2:	97a50513          	addi	a0,a0,-1670 # 8001e128 <disk+0x2128>
    800057b6:	00002097          	auipc	ra,0x2
    800057ba:	bf2080e7          	jalr	-1038(ra) # 800073a8 <release>
}
    800057be:	60e6                	ld	ra,88(sp)
    800057c0:	6446                	ld	s0,80(sp)
    800057c2:	64a6                	ld	s1,72(sp)
    800057c4:	6906                	ld	s2,64(sp)
    800057c6:	79e2                	ld	s3,56(sp)
    800057c8:	7a42                	ld	s4,48(sp)
    800057ca:	7aa2                	ld	s5,40(sp)
    800057cc:	7b02                	ld	s6,32(sp)
    800057ce:	6be2                	ld	s7,24(sp)
    800057d0:	6c42                	ld	s8,16(sp)
    800057d2:	6125                	addi	sp,sp,96
    800057d4:	8082                	ret
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
    800057d6:	00019797          	auipc	a5,0x19
    800057da:	82a78793          	addi	a5,a5,-2006 # 8001e000 <disk+0x2000>
    800057de:	639c                	ld	a5,0(a5)
    800057e0:	97b6                	add	a5,a5,a3
    800057e2:	4609                	li	a2,2
    800057e4:	00c79623          	sh	a2,12(a5)
    800057e8:	b5c1                	j	800056a8 <virtio_disk_rw+0x178>
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800057ea:	fa042583          	lw	a1,-96(s0)
    800057ee:	20058713          	addi	a4,a1,512
    800057f2:	0712                	slli	a4,a4,0x4
    800057f4:	00017697          	auipc	a3,0x17
    800057f8:	8b468693          	addi	a3,a3,-1868 # 8001c0a8 <disk+0xa8>
    800057fc:	96ba                	add	a3,a3,a4
  if(write)
    800057fe:	e00c1de3          	bnez	s8,80005618 <virtio_disk_rw+0xe8>
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
    80005802:	20058793          	addi	a5,a1,512
    80005806:	00479613          	slli	a2,a5,0x4
    8000580a:	00016797          	auipc	a5,0x16
    8000580e:	7f678793          	addi	a5,a5,2038 # 8001c000 <disk>
    80005812:	97b2                	add	a5,a5,a2
    80005814:	0a07a423          	sw	zero,168(a5)
    80005818:	bd21                	j	80005630 <virtio_disk_rw+0x100>
      disk.free[i] = 0;
    8000581a:	00098c23          	sb	zero,24(s3)
    idx[i] = alloc_desc();
    8000581e:	00072023          	sw	zero,0(a4)
    if(idx[i] < 0){
    80005822:	b3bd                	j	80005590 <virtio_disk_rw+0x60>

0000000080005824 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005824:	1101                	addi	sp,sp,-32
    80005826:	ec06                	sd	ra,24(sp)
    80005828:	e822                	sd	s0,16(sp)
    8000582a:	e426                	sd	s1,8(sp)
    8000582c:	e04a                	sd	s2,0(sp)
    8000582e:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    80005830:	00019517          	auipc	a0,0x19
    80005834:	8f850513          	addi	a0,a0,-1800 # 8001e128 <disk+0x2128>
    80005838:	00002097          	auipc	ra,0x2
    8000583c:	abc080e7          	jalr	-1348(ra) # 800072f4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005840:	10001737          	lui	a4,0x10001
    80005844:	533c                	lw	a5,96(a4)
    80005846:	8b8d                	andi	a5,a5,3
    80005848:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    8000584a:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    8000584e:	00018797          	auipc	a5,0x18
    80005852:	7b278793          	addi	a5,a5,1970 # 8001e000 <disk+0x2000>
    80005856:	6b94                	ld	a3,16(a5)
    80005858:	0207d703          	lhu	a4,32(a5)
    8000585c:	0026d783          	lhu	a5,2(a3)
    80005860:	06f70163          	beq	a4,a5,800058c2 <virtio_disk_intr+0x9e>
    __sync_synchronize();
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005864:	00016917          	auipc	s2,0x16
    80005868:	79c90913          	addi	s2,s2,1948 # 8001c000 <disk>
    8000586c:	00018497          	auipc	s1,0x18
    80005870:	79448493          	addi	s1,s1,1940 # 8001e000 <disk+0x2000>
    __sync_synchronize();
    80005874:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005878:	6898                	ld	a4,16(s1)
    8000587a:	0204d783          	lhu	a5,32(s1)
    8000587e:	8b9d                	andi	a5,a5,7
    80005880:	078e                	slli	a5,a5,0x3
    80005882:	97ba                	add	a5,a5,a4
    80005884:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005886:	20078713          	addi	a4,a5,512
    8000588a:	0712                	slli	a4,a4,0x4
    8000588c:	974a                	add	a4,a4,s2
    8000588e:	03074703          	lbu	a4,48(a4) # 10001030 <_entry-0x6fffefd0>
    80005892:	e731                	bnez	a4,800058de <virtio_disk_intr+0xba>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005894:	20078793          	addi	a5,a5,512
    80005898:	0792                	slli	a5,a5,0x4
    8000589a:	97ca                	add	a5,a5,s2
    8000589c:	7788                	ld	a0,40(a5)
    b->disk = 0;   // disk is done with buf
    8000589e:	00052223          	sw	zero,4(a0)
    wakeup(b);
    800058a2:	ffffc097          	auipc	ra,0xffffc
    800058a6:	ffe080e7          	jalr	-2(ra) # 800018a0 <wakeup>

    disk.used_idx += 1;
    800058aa:	0204d783          	lhu	a5,32(s1)
    800058ae:	2785                	addiw	a5,a5,1
    800058b0:	17c2                	slli	a5,a5,0x30
    800058b2:	93c1                	srli	a5,a5,0x30
    800058b4:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    800058b8:	6898                	ld	a4,16(s1)
    800058ba:	00275703          	lhu	a4,2(a4)
    800058be:	faf71be3          	bne	a4,a5,80005874 <virtio_disk_intr+0x50>
  }

  release(&disk.vdisk_lock);
    800058c2:	00019517          	auipc	a0,0x19
    800058c6:	86650513          	addi	a0,a0,-1946 # 8001e128 <disk+0x2128>
    800058ca:	00002097          	auipc	ra,0x2
    800058ce:	ade080e7          	jalr	-1314(ra) # 800073a8 <release>
}
    800058d2:	60e2                	ld	ra,24(sp)
    800058d4:	6442                	ld	s0,16(sp)
    800058d6:	64a2                	ld	s1,8(sp)
    800058d8:	6902                	ld	s2,0(sp)
    800058da:	6105                	addi	sp,sp,32
    800058dc:	8082                	ret
      panic("virtio_disk_intr status");
    800058de:	00004517          	auipc	a0,0x4
    800058e2:	ec250513          	addi	a0,a0,-318 # 800097a0 <syscalls+0x418>
    800058e6:	00001097          	auipc	ra,0x1
    800058ea:	4a2080e7          	jalr	1186(ra) # 80006d88 <panic>

00000000800058ee <e1000_init>:
// called by pci_init().
// xregs is the memory address at which the
// e1000's registers are mapped.
void
e1000_init(uint32 *xregs)
{
    800058ee:	7179                	addi	sp,sp,-48
    800058f0:	f406                	sd	ra,40(sp)
    800058f2:	f022                	sd	s0,32(sp)
    800058f4:	ec26                	sd	s1,24(sp)
    800058f6:	e84a                	sd	s2,16(sp)
    800058f8:	e44e                	sd	s3,8(sp)
    800058fa:	1800                	addi	s0,sp,48
    800058fc:	84aa                	mv	s1,a0
  int i;

  initlock(&e1000_lock, "e1000");
    800058fe:	00004597          	auipc	a1,0x4
    80005902:	eba58593          	addi	a1,a1,-326 # 800097b8 <syscalls+0x430>
    80005906:	00019517          	auipc	a0,0x19
    8000590a:	6fa50513          	addi	a0,a0,1786 # 8001f000 <e1000_lock>
    8000590e:	00002097          	auipc	ra,0x2
    80005912:	956080e7          	jalr	-1706(ra) # 80007264 <initlock>

  regs = xregs;
    80005916:	00004797          	auipc	a5,0x4
    8000591a:	7097b523          	sd	s1,1802(a5) # 8000a020 <regs>

  // Reset the device
  regs[E1000_IMS] = 0; // disable interrupts
    8000591e:	0c04a823          	sw	zero,208(s1)
  regs[E1000_CTL] |= E1000_CTL_RST;
    80005922:	409c                	lw	a5,0(s1)
    80005924:	00400737          	lui	a4,0x400
    80005928:	8fd9                	or	a5,a5,a4
    8000592a:	2781                	sext.w	a5,a5
    8000592c:	c09c                	sw	a5,0(s1)
  regs[E1000_IMS] = 0; // redisable interrupts
    8000592e:	0c04a823          	sw	zero,208(s1)
  __sync_synchronize();
    80005932:	0ff0000f          	fence

  // [E1000 14.5] Transmit initialization
  memset(tx_ring, 0, sizeof(tx_ring));
    80005936:	10000613          	li	a2,256
    8000593a:	4581                	li	a1,0
    8000593c:	00019517          	auipc	a0,0x19
    80005940:	6e450513          	addi	a0,a0,1764 # 8001f020 <tx_ring>
    80005944:	ffffb097          	auipc	ra,0xffffb
    80005948:	838080e7          	jalr	-1992(ra) # 8000017c <memset>
  for (i = 0; i < TX_RING_SIZE; i++) {
    8000594c:	00019717          	auipc	a4,0x19
    80005950:	6e070713          	addi	a4,a4,1760 # 8001f02c <tx_ring+0xc>
    80005954:	00019797          	auipc	a5,0x19
    80005958:	7cc78793          	addi	a5,a5,1996 # 8001f120 <tx_mbufs>
    8000595c:	0001a617          	auipc	a2,0x1a
    80005960:	84460613          	addi	a2,a2,-1980 # 8001f1a0 <rx_ring>
    tx_ring[i].status = E1000_TXD_STAT_DD;
    80005964:	4685                	li	a3,1
    80005966:	00d70023          	sb	a3,0(a4)
    tx_mbufs[i] = 0;
    8000596a:	0007b023          	sd	zero,0(a5)
  for (i = 0; i < TX_RING_SIZE; i++) {
    8000596e:	0741                	addi	a4,a4,16
    80005970:	07a1                	addi	a5,a5,8
    80005972:	fec79ae3          	bne	a5,a2,80005966 <e1000_init+0x78>
  }
  regs[E1000_TDBAL] = (uint64) tx_ring;
    80005976:	00004797          	auipc	a5,0x4
    8000597a:	6aa78793          	addi	a5,a5,1706 # 8000a020 <regs>
    8000597e:	639c                	ld	a5,0(a5)
    80005980:	00019717          	auipc	a4,0x19
    80005984:	6a070713          	addi	a4,a4,1696 # 8001f020 <tx_ring>
    80005988:	6691                	lui	a3,0x4
    8000598a:	97b6                	add	a5,a5,a3
    8000598c:	80e7a023          	sw	a4,-2048(a5)
  if(sizeof(tx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_TDLEN] = sizeof(tx_ring);
    80005990:	10000713          	li	a4,256
    80005994:	80e7a423          	sw	a4,-2040(a5)
  regs[E1000_TDH] = regs[E1000_TDT] = 0;
    80005998:	8007ac23          	sw	zero,-2024(a5)
    8000599c:	8007a823          	sw	zero,-2032(a5)
  
  // [E1000 14.4] Receive initialization
  memset(rx_ring, 0, sizeof(rx_ring));
    800059a0:	0001a917          	auipc	s2,0x1a
    800059a4:	80090913          	addi	s2,s2,-2048 # 8001f1a0 <rx_ring>
    800059a8:	10000613          	li	a2,256
    800059ac:	4581                	li	a1,0
    800059ae:	854a                	mv	a0,s2
    800059b0:	ffffa097          	auipc	ra,0xffffa
    800059b4:	7cc080e7          	jalr	1996(ra) # 8000017c <memset>
  for (i = 0; i < RX_RING_SIZE; i++) {
    800059b8:	0001a497          	auipc	s1,0x1a
    800059bc:	8e848493          	addi	s1,s1,-1816 # 8001f2a0 <rx_mbufs>
    800059c0:	0001a997          	auipc	s3,0x1a
    800059c4:	96098993          	addi	s3,s3,-1696 # 8001f320 <lock>
    rx_mbufs[i] = mbufalloc(0);
    800059c8:	4501                	li	a0,0
    800059ca:	00000097          	auipc	ra,0x0
    800059ce:	420080e7          	jalr	1056(ra) # 80005dea <mbufalloc>
    800059d2:	e088                	sd	a0,0(s1)
    if (!rx_mbufs[i])
    800059d4:	c94d                	beqz	a0,80005a86 <e1000_init+0x198>
      panic("e1000");
    rx_ring[i].addr = (uint64) rx_mbufs[i]->head;
    800059d6:	651c                	ld	a5,8(a0)
    800059d8:	00f93023          	sd	a5,0(s2)
  for (i = 0; i < RX_RING_SIZE; i++) {
    800059dc:	04a1                	addi	s1,s1,8
    800059de:	0941                	addi	s2,s2,16
    800059e0:	ff3494e3          	bne	s1,s3,800059c8 <e1000_init+0xda>
  }
  regs[E1000_RDBAL] = (uint64) rx_ring;
    800059e4:	00004797          	auipc	a5,0x4
    800059e8:	63c78793          	addi	a5,a5,1596 # 8000a020 <regs>
    800059ec:	6394                	ld	a3,0(a5)
    800059ee:	00019717          	auipc	a4,0x19
    800059f2:	7b270713          	addi	a4,a4,1970 # 8001f1a0 <rx_ring>
    800059f6:	678d                	lui	a5,0x3
    800059f8:	97b6                	add	a5,a5,a3
    800059fa:	80e7a023          	sw	a4,-2048(a5) # 2800 <_entry-0x7fffd800>
  if(sizeof(rx_ring) % 128 != 0)
    panic("e1000");
  regs[E1000_RDH] = 0;
    800059fe:	8007a823          	sw	zero,-2032(a5)
  regs[E1000_RDT] = RX_RING_SIZE - 1;
    80005a02:	473d                	li	a4,15
    80005a04:	80e7ac23          	sw	a4,-2024(a5)
  regs[E1000_RDLEN] = sizeof(rx_ring);
    80005a08:	10000713          	li	a4,256
    80005a0c:	80e7a423          	sw	a4,-2040(a5)

  // filter by qemu's MAC address, 52:54:00:12:34:56
  regs[E1000_RA] = 0x12005452;
    80005a10:	6715                	lui	a4,0x5
    80005a12:	00e68633          	add	a2,a3,a4
    80005a16:	120057b7          	lui	a5,0x12005
    80005a1a:	4527879b          	addiw	a5,a5,1106
    80005a1e:	40f62023          	sw	a5,1024(a2)
  regs[E1000_RA+1] = 0x5634 | (1<<31);
    80005a22:	800057b7          	lui	a5,0x80005
    80005a26:	6347879b          	addiw	a5,a5,1588
    80005a2a:	40f62223          	sw	a5,1028(a2)
  // multicast table
  for (int i = 0; i < 4096/32; i++)
    80005a2e:	20070793          	addi	a5,a4,512 # 5200 <_entry-0x7fffae00>
    80005a32:	97b6                	add	a5,a5,a3
    80005a34:	40070713          	addi	a4,a4,1024
    80005a38:	9736                	add	a4,a4,a3
    regs[E1000_MTA + i] = 0;
    80005a3a:	0007a023          	sw	zero,0(a5) # ffffffff80005000 <end+0xfffffffefffdda80>
  for (int i = 0; i < 4096/32; i++)
    80005a3e:	0791                	addi	a5,a5,4
    80005a40:	fef71de3          	bne	a4,a5,80005a3a <e1000_init+0x14c>

  // transmitter control bits.
  regs[E1000_TCTL] = E1000_TCTL_EN |  // enable
    80005a44:	000407b7          	lui	a5,0x40
    80005a48:	10a7879b          	addiw	a5,a5,266
    80005a4c:	40f6a023          	sw	a5,1024(a3) # 4400 <_entry-0x7fffbc00>
    E1000_TCTL_PSP |                  // pad short packets
    (0x10 << E1000_TCTL_CT_SHIFT) |   // collision stuff
    (0x40 << E1000_TCTL_COLD_SHIFT);
  regs[E1000_TIPG] = 10 | (8<<10) | (6<<20); // inter-pkt gap
    80005a50:	006027b7          	lui	a5,0x602
    80005a54:	27a9                	addiw	a5,a5,10
    80005a56:	40f6a823          	sw	a5,1040(a3)

  // receiver control bits.
  regs[E1000_RCTL] = E1000_RCTL_EN | // enable receiver
    80005a5a:	040087b7          	lui	a5,0x4008
    80005a5e:	2789                	addiw	a5,a5,2
    80005a60:	10f6a023          	sw	a5,256(a3)
    E1000_RCTL_BAM |                 // enable broadcast
    E1000_RCTL_SZ_2048 |             // 2048-byte rx buffers
    E1000_RCTL_SECRC;                // strip CRC
  
  // ask e1000 for receive interrupts.
  regs[E1000_RDTR] = 0; // interrupt after every received packet (no timer)
    80005a64:	678d                	lui	a5,0x3
    80005a66:	97b6                	add	a5,a5,a3
    80005a68:	8207a023          	sw	zero,-2016(a5) # 2820 <_entry-0x7fffd7e0>
  regs[E1000_RADV] = 0; // interrupt after every packet (no timer)
    80005a6c:	8207a623          	sw	zero,-2004(a5)
  regs[E1000_IMS] = (1 << 7); // RXDW -- Receiver Descriptor Write Back
    80005a70:	08000793          	li	a5,128
    80005a74:	0cf6a823          	sw	a5,208(a3)
}
    80005a78:	70a2                	ld	ra,40(sp)
    80005a7a:	7402                	ld	s0,32(sp)
    80005a7c:	64e2                	ld	s1,24(sp)
    80005a7e:	6942                	ld	s2,16(sp)
    80005a80:	69a2                	ld	s3,8(sp)
    80005a82:	6145                	addi	sp,sp,48
    80005a84:	8082                	ret
      panic("e1000");
    80005a86:	00004517          	auipc	a0,0x4
    80005a8a:	d3250513          	addi	a0,a0,-718 # 800097b8 <syscalls+0x430>
    80005a8e:	00001097          	auipc	ra,0x1
    80005a92:	2fa080e7          	jalr	762(ra) # 80006d88 <panic>

0000000080005a96 <e1000_transmit>:

int
e1000_transmit(struct mbuf *m)
{
    80005a96:	7179                	addi	sp,sp,-48
    80005a98:	f406                	sd	ra,40(sp)
    80005a9a:	f022                	sd	s0,32(sp)
    80005a9c:	ec26                	sd	s1,24(sp)
    80005a9e:	e84a                	sd	s2,16(sp)
    80005aa0:	e44e                	sd	s3,8(sp)
    80005aa2:	1800                	addi	s0,sp,48
    80005aa4:	89aa                	mv	s3,a0
  // the mbuf contains an ethernet frame; program it into
  // the TX descriptor ring so that the e1000 sends it. Stash
  // a pointer so that it can be freed after sending.
  //

  acquire(&e1000_lock);
    80005aa6:	00019917          	auipc	s2,0x19
    80005aaa:	55a90913          	addi	s2,s2,1370 # 8001f000 <e1000_lock>
    80005aae:	854a                	mv	a0,s2
    80005ab0:	00002097          	auipc	ra,0x2
    80005ab4:	844080e7          	jalr	-1980(ra) # 800072f4 <acquire>
  // ask for the ring index where to expect next packet
  int idx = regs[E1000_TDT];
    80005ab8:	00004797          	auipc	a5,0x4
    80005abc:	56878793          	addi	a5,a5,1384 # 8000a020 <regs>
    80005ac0:	639c                	ld	a5,0(a5)
    80005ac2:	6711                	lui	a4,0x4
    80005ac4:	97ba                	add	a5,a5,a4
    80005ac6:	8187a483          	lw	s1,-2024(a5)
    80005aca:	2481                	sext.w	s1,s1

  if ((tx_ring[idx].status & E1000_TXD_STAT_DD) == 0) {
    80005acc:	00449793          	slli	a5,s1,0x4
    80005ad0:	993e                	add	s2,s2,a5
    80005ad2:	02c94783          	lbu	a5,44(s2)
    80005ad6:	8b85                	andi	a5,a5,1
    80005ad8:	c3d1                	beqz	a5,80005b5c <e1000_transmit+0xc6>
    release(&e1000_lock);
    return -1;
  }

  // free the last transmitted packet
  if (tx_mbufs[idx])
    80005ada:	00349713          	slli	a4,s1,0x3
    80005ade:	00019797          	auipc	a5,0x19
    80005ae2:	52278793          	addi	a5,a5,1314 # 8001f000 <e1000_lock>
    80005ae6:	97ba                	add	a5,a5,a4
    80005ae8:	1207b503          	ld	a0,288(a5)
    80005aec:	c509                	beqz	a0,80005af6 <e1000_transmit+0x60>
    mbuffree(tx_mbufs[idx]);
    80005aee:	00000097          	auipc	ra,0x0
    80005af2:	354080e7          	jalr	852(ra) # 80005e42 <mbuffree>
  // stuff the packet into tx buffer

  tx_mbufs[idx] = m;
    80005af6:	00019517          	auipc	a0,0x19
    80005afa:	50a50513          	addi	a0,a0,1290 # 8001f000 <e1000_lock>
    80005afe:	00349793          	slli	a5,s1,0x3
    80005b02:	97aa                	add	a5,a5,a0
    80005b04:	1337b023          	sd	s3,288(a5)
  tx_ring[idx].length = m->len;
    80005b08:	00449793          	slli	a5,s1,0x4
    80005b0c:	97aa                	add	a5,a5,a0
    80005b0e:	0109a703          	lw	a4,16(s3)
    80005b12:	02e79423          	sh	a4,40(a5)
  tx_ring[idx].addr = (uint64) m->head;
    80005b16:	0089b703          	ld	a4,8(s3)
    80005b1a:	f398                	sd	a4,32(a5)
  tx_ring[idx].cmd = E1000_TXD_CMD_RS | E1000_TXD_CMD_EOP;
    80005b1c:	4725                	li	a4,9
    80005b1e:	02e785a3          	sb	a4,43(a5)
  regs[E1000_TDT] = (idx + 1) % TX_RING_SIZE;
    80005b22:	00004797          	auipc	a5,0x4
    80005b26:	4fe78793          	addi	a5,a5,1278 # 8000a020 <regs>
    80005b2a:	6398                	ld	a4,0(a5)
    80005b2c:	2485                	addiw	s1,s1,1
    80005b2e:	41f4d79b          	sraiw	a5,s1,0x1f
    80005b32:	01c7d79b          	srliw	a5,a5,0x1c
    80005b36:	9cbd                	addw	s1,s1,a5
    80005b38:	88bd                	andi	s1,s1,15
    80005b3a:	9c9d                	subw	s1,s1,a5
    80005b3c:	6791                	lui	a5,0x4
    80005b3e:	97ba                	add	a5,a5,a4
    80005b40:	8097ac23          	sw	s1,-2024(a5) # 3818 <_entry-0x7fffc7e8>

  release(&e1000_lock);
    80005b44:	00002097          	auipc	ra,0x2
    80005b48:	864080e7          	jalr	-1948(ra) # 800073a8 <release>
  return 0;
    80005b4c:	4501                	li	a0,0
}
    80005b4e:	70a2                	ld	ra,40(sp)
    80005b50:	7402                	ld	s0,32(sp)
    80005b52:	64e2                	ld	s1,24(sp)
    80005b54:	6942                	ld	s2,16(sp)
    80005b56:	69a2                	ld	s3,8(sp)
    80005b58:	6145                	addi	sp,sp,48
    80005b5a:	8082                	ret
    release(&e1000_lock);
    80005b5c:	00019517          	auipc	a0,0x19
    80005b60:	4a450513          	addi	a0,a0,1188 # 8001f000 <e1000_lock>
    80005b64:	00002097          	auipc	ra,0x2
    80005b68:	844080e7          	jalr	-1980(ra) # 800073a8 <release>
    return -1;
    80005b6c:	557d                	li	a0,-1
    80005b6e:	b7c5                	j	80005b4e <e1000_transmit+0xb8>

0000000080005b70 <e1000_intr>:
  }
}

void
e1000_intr(void)
{
    80005b70:	7139                	addi	sp,sp,-64
    80005b72:	fc06                	sd	ra,56(sp)
    80005b74:	f822                	sd	s0,48(sp)
    80005b76:	f426                	sd	s1,40(sp)
    80005b78:	f04a                	sd	s2,32(sp)
    80005b7a:	ec4e                	sd	s3,24(sp)
    80005b7c:	e852                	sd	s4,16(sp)
    80005b7e:	e456                	sd	s5,8(sp)
    80005b80:	e05a                	sd	s6,0(sp)
    80005b82:	0080                	addi	s0,sp,64
  // tell the e1000 we've seen this interrupt;
  // without this the e1000 won't raise any
  // further interrupts.
  regs[E1000_ICR] = 0xffffffff;
    80005b84:	00004797          	auipc	a5,0x4
    80005b88:	49c78793          	addi	a5,a5,1180 # 8000a020 <regs>
    80005b8c:	639c                	ld	a5,0(a5)
    80005b8e:	577d                	li	a4,-1
    80005b90:	0ce7a023          	sw	a4,192(a5)
    int idx = (regs[E1000_RDT] + 1) % RX_RING_SIZE;
    80005b94:	670d                	lui	a4,0x3
    80005b96:	97ba                	add	a5,a5,a4
    80005b98:	8187a483          	lw	s1,-2024(a5)
    80005b9c:	2485                	addiw	s1,s1,1
    80005b9e:	88bd                	andi	s1,s1,15
    if ((rx_ring[idx].status & E1000_RXD_STAT_DD) == 0) {
    80005ba0:	00449713          	slli	a4,s1,0x4
    80005ba4:	00019797          	auipc	a5,0x19
    80005ba8:	45c78793          	addi	a5,a5,1116 # 8001f000 <e1000_lock>
    80005bac:	97ba                	add	a5,a5,a4
    80005bae:	1ac7c783          	lbu	a5,428(a5)
    80005bb2:	8b85                	andi	a5,a5,1
    80005bb4:	cba5                	beqz	a5,80005c24 <e1000_intr+0xb4>
    rx_mbufs[idx]->len = rx_ring[idx].length;
    80005bb6:	00019a17          	auipc	s4,0x19
    80005bba:	44aa0a13          	addi	s4,s4,1098 # 8001f000 <e1000_lock>
    regs[E1000_RDT] = idx;
    80005bbe:	00004b17          	auipc	s6,0x4
    80005bc2:	462b0b13          	addi	s6,s6,1122 # 8000a020 <regs>
    80005bc6:	6a8d                	lui	s5,0x3
    rx_mbufs[idx]->len = rx_ring[idx].length;
    80005bc8:	00349993          	slli	s3,s1,0x3
    80005bcc:	99d2                	add	s3,s3,s4
    80005bce:	2a09b783          	ld	a5,672(s3)
    80005bd2:	00449913          	slli	s2,s1,0x4
    80005bd6:	9952                	add	s2,s2,s4
    80005bd8:	1a895703          	lhu	a4,424(s2)
    80005bdc:	cb98                	sw	a4,16(a5)
    net_rx(rx_mbufs[idx]);
    80005bde:	2a09b503          	ld	a0,672(s3)
    80005be2:	00000097          	auipc	ra,0x0
    80005be6:	3d4080e7          	jalr	980(ra) # 80005fb6 <net_rx>
    rx_mbufs[idx] = mbufalloc(0);
    80005bea:	4501                	li	a0,0
    80005bec:	00000097          	auipc	ra,0x0
    80005bf0:	1fe080e7          	jalr	510(ra) # 80005dea <mbufalloc>
    80005bf4:	2aa9b023          	sd	a0,672(s3)
    rx_ring[idx].status = 0;
    80005bf8:	1a090623          	sb	zero,428(s2)
    rx_ring[idx].addr = (uint64)rx_mbufs[idx]->head;
    80005bfc:	651c                	ld	a5,8(a0)
    80005bfe:	1af93023          	sd	a5,416(s2)
    regs[E1000_RDT] = idx;
    80005c02:	000b3783          	ld	a5,0(s6)
    80005c06:	2481                	sext.w	s1,s1
    80005c08:	97d6                	add	a5,a5,s5
    80005c0a:	8097ac23          	sw	s1,-2024(a5)
    int idx = (regs[E1000_RDT] + 1) % RX_RING_SIZE;
    80005c0e:	8187a483          	lw	s1,-2024(a5)
    80005c12:	2485                	addiw	s1,s1,1
    80005c14:	88bd                	andi	s1,s1,15
    if ((rx_ring[idx].status & E1000_RXD_STAT_DD) == 0) {
    80005c16:	00449793          	slli	a5,s1,0x4
    80005c1a:	97d2                	add	a5,a5,s4
    80005c1c:	1ac7c783          	lbu	a5,428(a5)
    80005c20:	8b85                	andi	a5,a5,1
    80005c22:	f3dd                	bnez	a5,80005bc8 <e1000_intr+0x58>

  e1000_recv();
}
    80005c24:	70e2                	ld	ra,56(sp)
    80005c26:	7442                	ld	s0,48(sp)
    80005c28:	74a2                	ld	s1,40(sp)
    80005c2a:	7902                	ld	s2,32(sp)
    80005c2c:	69e2                	ld	s3,24(sp)
    80005c2e:	6a42                	ld	s4,16(sp)
    80005c30:	6aa2                	ld	s5,8(sp)
    80005c32:	6b02                	ld	s6,0(sp)
    80005c34:	6121                	addi	sp,sp,64
    80005c36:	8082                	ret

0000000080005c38 <in_cksum>:

// This code is lifted from FreeBSD's ping.c, and is copyright by the Regents
// of the University of California.
static unsigned short
in_cksum(const unsigned char *addr, int len)
{
    80005c38:	1101                	addi	sp,sp,-32
    80005c3a:	ec22                	sd	s0,24(sp)
    80005c3c:	1000                	addi	s0,sp,32
  int nleft = len;
  const unsigned short *w = (const unsigned short *)addr;
  unsigned int sum = 0;
  unsigned short answer = 0;
    80005c3e:	fe041723          	sh	zero,-18(s0)
  /*
   * Our algorithm is simple, using a 32 bit accumulator (sum), we add
   * sequential 16 bit words to it, and at the end, fold back all the
   * carry bits from the top 16 bits into the lower 16 bits.
   */
  while (nleft > 1)  {
    80005c42:	4785                	li	a5,1
    80005c44:	04b7dc63          	ble	a1,a5,80005c9c <in_cksum+0x64>
    80005c48:	ffe5861b          	addiw	a2,a1,-2
    80005c4c:	0016561b          	srliw	a2,a2,0x1
    80005c50:	02061693          	slli	a3,a2,0x20
    80005c54:	9281                	srli	a3,a3,0x20
    80005c56:	0685                	addi	a3,a3,1
    80005c58:	0686                	slli	a3,a3,0x1
    80005c5a:	96aa                	add	a3,a3,a0
  unsigned int sum = 0;
    80005c5c:	4781                	li	a5,0
    sum += *w++;
    80005c5e:	0509                	addi	a0,a0,2
    80005c60:	ffe55703          	lhu	a4,-2(a0)
    80005c64:	9fb9                	addw	a5,a5,a4
  while (nleft > 1)  {
    80005c66:	fed51ce3          	bne	a0,a3,80005c5e <in_cksum+0x26>
    80005c6a:	35f9                	addiw	a1,a1,-2
    80005c6c:	40c0063b          	negw	a2,a2
    80005c70:	0016161b          	slliw	a2,a2,0x1
    80005c74:	9db1                	addw	a1,a1,a2
    nleft -= 2;
  }

  /* mop up an odd byte, if necessary */
  if (nleft == 1) {
    80005c76:	4705                	li	a4,1
    80005c78:	02e58563          	beq	a1,a4,80005ca2 <in_cksum+0x6a>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    sum += answer;
  }

  /* add back carry outs from top 16 bits to low 16 bits */
  sum = (sum & 0xffff) + (sum >> 16);
    80005c7c:	03079513          	slli	a0,a5,0x30
    80005c80:	9141                	srli	a0,a0,0x30
    80005c82:	0107d79b          	srliw	a5,a5,0x10
    80005c86:	9fa9                	addw	a5,a5,a0
  sum += (sum >> 16);
    80005c88:	0107d51b          	srliw	a0,a5,0x10
  /* guaranteed now that the lower 16 bits of sum are correct */

  answer = ~sum; /* truncate to 16 bits */
    80005c8c:	9d3d                	addw	a0,a0,a5
    80005c8e:	fff54513          	not	a0,a0
  return answer;
}
    80005c92:	1542                	slli	a0,a0,0x30
    80005c94:	9141                	srli	a0,a0,0x30
    80005c96:	6462                	ld	s0,24(sp)
    80005c98:	6105                	addi	sp,sp,32
    80005c9a:	8082                	ret
  const unsigned short *w = (const unsigned short *)addr;
    80005c9c:	86aa                	mv	a3,a0
  unsigned int sum = 0;
    80005c9e:	4781                	li	a5,0
    80005ca0:	bfd9                	j	80005c76 <in_cksum+0x3e>
    *(unsigned char *)(&answer) = *(const unsigned char *)w;
    80005ca2:	0006c703          	lbu	a4,0(a3)
    80005ca6:	fee40723          	sb	a4,-18(s0)
    sum += answer;
    80005caa:	fee45703          	lhu	a4,-18(s0)
    80005cae:	9fb9                	addw	a5,a5,a4
    80005cb0:	b7f1                	j	80005c7c <in_cksum+0x44>

0000000080005cb2 <mbufpull>:
{
    80005cb2:	1141                	addi	sp,sp,-16
    80005cb4:	e422                	sd	s0,8(sp)
    80005cb6:	0800                	addi	s0,sp,16
    80005cb8:	87aa                	mv	a5,a0
  char *tmp = m->head;
    80005cba:	6508                	ld	a0,8(a0)
  if (m->len < len)
    80005cbc:	4b98                	lw	a4,16(a5)
    80005cbe:	00b76b63          	bltu	a4,a1,80005cd4 <mbufpull+0x22>
  m->len -= len;
    80005cc2:	9f0d                	subw	a4,a4,a1
    80005cc4:	cb98                	sw	a4,16(a5)
  m->head += len;
    80005cc6:	1582                	slli	a1,a1,0x20
    80005cc8:	9181                	srli	a1,a1,0x20
    80005cca:	95aa                	add	a1,a1,a0
    80005ccc:	e78c                	sd	a1,8(a5)
}
    80005cce:	6422                	ld	s0,8(sp)
    80005cd0:	0141                	addi	sp,sp,16
    80005cd2:	8082                	ret
    return 0;
    80005cd4:	4501                	li	a0,0
    80005cd6:	bfe5                	j	80005cce <mbufpull+0x1c>

0000000080005cd8 <mbufpush>:
  m->head -= len;
    80005cd8:	02059713          	slli	a4,a1,0x20
    80005cdc:	9301                	srli	a4,a4,0x20
    80005cde:	651c                	ld	a5,8(a0)
    80005ce0:	8f99                	sub	a5,a5,a4
    80005ce2:	e51c                	sd	a5,8(a0)
  if (m->head < m->buf)
    80005ce4:	01450713          	addi	a4,a0,20
    80005ce8:	00e7e763          	bltu	a5,a4,80005cf6 <mbufpush+0x1e>
  m->len += len;
    80005cec:	4918                	lw	a4,16(a0)
    80005cee:	9f2d                	addw	a4,a4,a1
    80005cf0:	c918                	sw	a4,16(a0)
}
    80005cf2:	853e                	mv	a0,a5
    80005cf4:	8082                	ret
{
    80005cf6:	1141                	addi	sp,sp,-16
    80005cf8:	e406                	sd	ra,8(sp)
    80005cfa:	e022                	sd	s0,0(sp)
    80005cfc:	0800                	addi	s0,sp,16
    panic("mbufpush");
    80005cfe:	00004517          	auipc	a0,0x4
    80005d02:	ac250513          	addi	a0,a0,-1342 # 800097c0 <syscalls+0x438>
    80005d06:	00001097          	auipc	ra,0x1
    80005d0a:	082080e7          	jalr	130(ra) # 80006d88 <panic>

0000000080005d0e <net_tx_eth>:

// sends an ethernet packet
static void
net_tx_eth(struct mbuf *m, uint16 ethtype)
{
    80005d0e:	7179                	addi	sp,sp,-48
    80005d10:	f406                	sd	ra,40(sp)
    80005d12:	f022                	sd	s0,32(sp)
    80005d14:	ec26                	sd	s1,24(sp)
    80005d16:	e84a                	sd	s2,16(sp)
    80005d18:	e44e                	sd	s3,8(sp)
    80005d1a:	1800                	addi	s0,sp,48
    80005d1c:	89aa                	mv	s3,a0
    80005d1e:	84ae                	mv	s1,a1
  struct eth *ethhdr;

  ethhdr = mbufpushhdr(m, *ethhdr);
    80005d20:	45b9                	li	a1,14
    80005d22:	00000097          	auipc	ra,0x0
    80005d26:	fb6080e7          	jalr	-74(ra) # 80005cd8 <mbufpush>
    80005d2a:	892a                	mv	s2,a0
  memmove(ethhdr->shost, local_mac, ETHADDR_LEN);
    80005d2c:	4619                	li	a2,6
    80005d2e:	00004597          	auipc	a1,0x4
    80005d32:	b5258593          	addi	a1,a1,-1198 # 80009880 <local_mac>
    80005d36:	0519                	addi	a0,a0,6
    80005d38:	ffffa097          	auipc	ra,0xffffa
    80005d3c:	4b0080e7          	jalr	1200(ra) # 800001e8 <memmove>
  // In a real networking stack, dhost would be set to the address discovered
  // through ARP. Because we don't support enough of the ARP protocol, set it
  // to broadcast instead.
  memmove(ethhdr->dhost, broadcast_mac, ETHADDR_LEN);
    80005d40:	4619                	li	a2,6
    80005d42:	00004597          	auipc	a1,0x4
    80005d46:	b3658593          	addi	a1,a1,-1226 # 80009878 <broadcast_mac>
    80005d4a:	854a                	mv	a0,s2
    80005d4c:	ffffa097          	auipc	ra,0xffffa
    80005d50:	49c080e7          	jalr	1180(ra) # 800001e8 <memmove>
// endianness support
//

static inline uint16 bswaps(uint16 val)
{
  return (((val & 0x00ffU) << 8) |
    80005d54:	0084d79b          	srliw	a5,s1,0x8
    80005d58:	0084949b          	slliw	s1,s1,0x8
    80005d5c:	8cdd                	or	s1,s1,a5
  ethhdr->type = htons(ethtype);
    80005d5e:	00990623          	sb	s1,12(s2)
    80005d62:	80a1                	srli	s1,s1,0x8
    80005d64:	009906a3          	sb	s1,13(s2)
  if (e1000_transmit(m)) {
    80005d68:	854e                	mv	a0,s3
    80005d6a:	00000097          	auipc	ra,0x0
    80005d6e:	d2c080e7          	jalr	-724(ra) # 80005a96 <e1000_transmit>
    80005d72:	e901                	bnez	a0,80005d82 <net_tx_eth+0x74>
    mbuffree(m);
  }
}
    80005d74:	70a2                	ld	ra,40(sp)
    80005d76:	7402                	ld	s0,32(sp)
    80005d78:	64e2                	ld	s1,24(sp)
    80005d7a:	6942                	ld	s2,16(sp)
    80005d7c:	69a2                	ld	s3,8(sp)
    80005d7e:	6145                	addi	sp,sp,48
    80005d80:	8082                	ret
  kfree(m);
    80005d82:	854e                	mv	a0,s3
    80005d84:	ffffa097          	auipc	ra,0xffffa
    80005d88:	298080e7          	jalr	664(ra) # 8000001c <kfree>
}
    80005d8c:	b7e5                	j	80005d74 <net_tx_eth+0x66>

0000000080005d8e <mbufput>:
{
    80005d8e:	872a                	mv	a4,a0
  char *tmp = m->head + m->len;
    80005d90:	491c                	lw	a5,16(a0)
    80005d92:	02079693          	slli	a3,a5,0x20
    80005d96:	9281                	srli	a3,a3,0x20
    80005d98:	6508                	ld	a0,8(a0)
    80005d9a:	9536                	add	a0,a0,a3
  m->len += len;
    80005d9c:	9dbd                	addw	a1,a1,a5
    80005d9e:	0005869b          	sext.w	a3,a1
    80005da2:	cb0c                	sw	a1,16(a4)
  if (m->len > MBUF_SIZE)
    80005da4:	6785                	lui	a5,0x1
    80005da6:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    80005daa:	00d7e363          	bltu	a5,a3,80005db0 <mbufput+0x22>
}
    80005dae:	8082                	ret
{
    80005db0:	1141                	addi	sp,sp,-16
    80005db2:	e406                	sd	ra,8(sp)
    80005db4:	e022                	sd	s0,0(sp)
    80005db6:	0800                	addi	s0,sp,16
    panic("mbufput");
    80005db8:	00004517          	auipc	a0,0x4
    80005dbc:	a1850513          	addi	a0,a0,-1512 # 800097d0 <syscalls+0x448>
    80005dc0:	00001097          	auipc	ra,0x1
    80005dc4:	fc8080e7          	jalr	-56(ra) # 80006d88 <panic>

0000000080005dc8 <mbuftrim>:
{
    80005dc8:	1141                	addi	sp,sp,-16
    80005dca:	e422                	sd	s0,8(sp)
    80005dcc:	0800                	addi	s0,sp,16
  if (len > m->len)
    80005dce:	491c                	lw	a5,16(a0)
    80005dd0:	00b7eb63          	bltu	a5,a1,80005de6 <mbuftrim+0x1e>
  m->len -= len;
    80005dd4:	9f8d                	subw	a5,a5,a1
    80005dd6:	c91c                	sw	a5,16(a0)
  return m->head + m->len;
    80005dd8:	1782                	slli	a5,a5,0x20
    80005dda:	9381                	srli	a5,a5,0x20
    80005ddc:	6508                	ld	a0,8(a0)
    80005dde:	953e                	add	a0,a0,a5
}
    80005de0:	6422                	ld	s0,8(sp)
    80005de2:	0141                	addi	sp,sp,16
    80005de4:	8082                	ret
    return 0;
    80005de6:	4501                	li	a0,0
    80005de8:	bfe5                	j	80005de0 <mbuftrim+0x18>

0000000080005dea <mbufalloc>:
{
    80005dea:	1101                	addi	sp,sp,-32
    80005dec:	ec06                	sd	ra,24(sp)
    80005dee:	e822                	sd	s0,16(sp)
    80005df0:	e426                	sd	s1,8(sp)
    80005df2:	e04a                	sd	s2,0(sp)
    80005df4:	1000                	addi	s0,sp,32
  if (headroom > MBUF_SIZE)
    80005df6:	6785                	lui	a5,0x1
    80005df8:	80078793          	addi	a5,a5,-2048 # 800 <_entry-0x7ffff800>
    return 0;
    80005dfc:	4901                	li	s2,0
  if (headroom > MBUF_SIZE)
    80005dfe:	02a7eb63          	bltu	a5,a0,80005e34 <mbufalloc+0x4a>
    80005e02:	84aa                	mv	s1,a0
  m = kalloc();
    80005e04:	ffffa097          	auipc	ra,0xffffa
    80005e08:	318080e7          	jalr	792(ra) # 8000011c <kalloc>
    80005e0c:	892a                	mv	s2,a0
  if (m == 0)
    80005e0e:	c11d                	beqz	a0,80005e34 <mbufalloc+0x4a>
  m->next = 0;
    80005e10:	00053023          	sd	zero,0(a0)
  m->head = (char *)m->buf + headroom;
    80005e14:	0551                	addi	a0,a0,20
    80005e16:	1482                	slli	s1,s1,0x20
    80005e18:	9081                	srli	s1,s1,0x20
    80005e1a:	94aa                	add	s1,s1,a0
    80005e1c:	00993423          	sd	s1,8(s2)
  m->len = 0;
    80005e20:	00092823          	sw	zero,16(s2)
  memset(m->buf, 0, sizeof(m->buf));
    80005e24:	6605                	lui	a2,0x1
    80005e26:	80060613          	addi	a2,a2,-2048 # 800 <_entry-0x7ffff800>
    80005e2a:	4581                	li	a1,0
    80005e2c:	ffffa097          	auipc	ra,0xffffa
    80005e30:	350080e7          	jalr	848(ra) # 8000017c <memset>
}
    80005e34:	854a                	mv	a0,s2
    80005e36:	60e2                	ld	ra,24(sp)
    80005e38:	6442                	ld	s0,16(sp)
    80005e3a:	64a2                	ld	s1,8(sp)
    80005e3c:	6902                	ld	s2,0(sp)
    80005e3e:	6105                	addi	sp,sp,32
    80005e40:	8082                	ret

0000000080005e42 <mbuffree>:
{
    80005e42:	1141                	addi	sp,sp,-16
    80005e44:	e406                	sd	ra,8(sp)
    80005e46:	e022                	sd	s0,0(sp)
    80005e48:	0800                	addi	s0,sp,16
  kfree(m);
    80005e4a:	ffffa097          	auipc	ra,0xffffa
    80005e4e:	1d2080e7          	jalr	466(ra) # 8000001c <kfree>
}
    80005e52:	60a2                	ld	ra,8(sp)
    80005e54:	6402                	ld	s0,0(sp)
    80005e56:	0141                	addi	sp,sp,16
    80005e58:	8082                	ret

0000000080005e5a <mbufq_pushtail>:
{
    80005e5a:	1141                	addi	sp,sp,-16
    80005e5c:	e422                	sd	s0,8(sp)
    80005e5e:	0800                	addi	s0,sp,16
  m->next = 0;
    80005e60:	0005b023          	sd	zero,0(a1)
  if (!q->head){
    80005e64:	611c                	ld	a5,0(a0)
    80005e66:	c799                	beqz	a5,80005e74 <mbufq_pushtail+0x1a>
  q->tail->next = m;
    80005e68:	651c                	ld	a5,8(a0)
    80005e6a:	e38c                	sd	a1,0(a5)
  q->tail = m;
    80005e6c:	e50c                	sd	a1,8(a0)
}
    80005e6e:	6422                	ld	s0,8(sp)
    80005e70:	0141                	addi	sp,sp,16
    80005e72:	8082                	ret
    q->head = q->tail = m;
    80005e74:	e50c                	sd	a1,8(a0)
    80005e76:	e10c                	sd	a1,0(a0)
    return;
    80005e78:	bfdd                	j	80005e6e <mbufq_pushtail+0x14>

0000000080005e7a <mbufq_pophead>:
{
    80005e7a:	1141                	addi	sp,sp,-16
    80005e7c:	e422                	sd	s0,8(sp)
    80005e7e:	0800                	addi	s0,sp,16
  struct mbuf *head = q->head;
    80005e80:	611c                	ld	a5,0(a0)
  if (!head)
    80005e82:	c399                	beqz	a5,80005e88 <mbufq_pophead+0xe>
  q->head = head->next;
    80005e84:	6398                	ld	a4,0(a5)
    80005e86:	e118                	sd	a4,0(a0)
}
    80005e88:	853e                	mv	a0,a5
    80005e8a:	6422                	ld	s0,8(sp)
    80005e8c:	0141                	addi	sp,sp,16
    80005e8e:	8082                	ret

0000000080005e90 <mbufq_empty>:
{
    80005e90:	1141                	addi	sp,sp,-16
    80005e92:	e422                	sd	s0,8(sp)
    80005e94:	0800                	addi	s0,sp,16
  return q->head == 0;
    80005e96:	6108                	ld	a0,0(a0)
}
    80005e98:	00153513          	seqz	a0,a0
    80005e9c:	6422                	ld	s0,8(sp)
    80005e9e:	0141                	addi	sp,sp,16
    80005ea0:	8082                	ret

0000000080005ea2 <mbufq_init>:
{
    80005ea2:	1141                	addi	sp,sp,-16
    80005ea4:	e422                	sd	s0,8(sp)
    80005ea6:	0800                	addi	s0,sp,16
  q->head = 0;
    80005ea8:	00053023          	sd	zero,0(a0)
}
    80005eac:	6422                	ld	s0,8(sp)
    80005eae:	0141                	addi	sp,sp,16
    80005eb0:	8082                	ret

0000000080005eb2 <net_tx_udp>:

// sends a UDP packet
void
net_tx_udp(struct mbuf *m, uint32 dip,
           uint16 sport, uint16 dport)
{
    80005eb2:	7179                	addi	sp,sp,-48
    80005eb4:	f406                	sd	ra,40(sp)
    80005eb6:	f022                	sd	s0,32(sp)
    80005eb8:	ec26                	sd	s1,24(sp)
    80005eba:	e84a                	sd	s2,16(sp)
    80005ebc:	e44e                	sd	s3,8(sp)
    80005ebe:	e052                	sd	s4,0(sp)
    80005ec0:	1800                	addi	s0,sp,48
    80005ec2:	89aa                	mv	s3,a0
    80005ec4:	892e                	mv	s2,a1
    80005ec6:	8a32                	mv	s4,a2
    80005ec8:	84b6                	mv	s1,a3
  struct udp *udphdr;

  // put the UDP header
  udphdr = mbufpushhdr(m, *udphdr);
    80005eca:	45a1                	li	a1,8
    80005ecc:	00000097          	auipc	ra,0x0
    80005ed0:	e0c080e7          	jalr	-500(ra) # 80005cd8 <mbufpush>
    80005ed4:	008a579b          	srliw	a5,s4,0x8
    80005ed8:	008a1a1b          	slliw	s4,s4,0x8
    80005edc:	00fa6a33          	or	s4,s4,a5
  udphdr->sport = htons(sport);
    80005ee0:	01451023          	sh	s4,0(a0)
    80005ee4:	0084d79b          	srliw	a5,s1,0x8
    80005ee8:	0084949b          	slliw	s1,s1,0x8
    80005eec:	8cdd                	or	s1,s1,a5
  udphdr->dport = htons(dport);
    80005eee:	00951123          	sh	s1,2(a0)
  udphdr->ulen = htons(m->len);
    80005ef2:	0109a783          	lw	a5,16(s3)
    80005ef6:	0087d713          	srli	a4,a5,0x8
    80005efa:	0087979b          	slliw	a5,a5,0x8
    80005efe:	0ff77713          	andi	a4,a4,255
    80005f02:	8fd9                	or	a5,a5,a4
    80005f04:	00f51223          	sh	a5,4(a0)
  udphdr->sum = 0; // zero means no checksum is provided
    80005f08:	00051323          	sh	zero,6(a0)
  iphdr = mbufpushhdr(m, *iphdr);
    80005f0c:	45d1                	li	a1,20
    80005f0e:	854e                	mv	a0,s3
    80005f10:	00000097          	auipc	ra,0x0
    80005f14:	dc8080e7          	jalr	-568(ra) # 80005cd8 <mbufpush>
    80005f18:	84aa                	mv	s1,a0
  memset(iphdr, 0, sizeof(*iphdr));
    80005f1a:	4651                	li	a2,20
    80005f1c:	4581                	li	a1,0
    80005f1e:	ffffa097          	auipc	ra,0xffffa
    80005f22:	25e080e7          	jalr	606(ra) # 8000017c <memset>
  iphdr->ip_vhl = (4 << 4) | (20 >> 2);
    80005f26:	04500793          	li	a5,69
    80005f2a:	00f48023          	sb	a5,0(s1)
  iphdr->ip_p = proto;
    80005f2e:	47c5                	li	a5,17
    80005f30:	00f484a3          	sb	a5,9(s1)
  iphdr->ip_src = htonl(local_ip);
    80005f34:	0f0207b7          	lui	a5,0xf020
    80005f38:	27a9                	addiw	a5,a5,10
    80005f3a:	c4dc                	sw	a5,12(s1)
          ((val & 0xff00U) >> 8));
}

static inline uint32 bswapl(uint32 val)
{
  return (((val & 0x000000ffUL) << 24) |
    80005f3c:	0189179b          	slliw	a5,s2,0x18
          ((val & 0x0000ff00UL) << 8) |
          ((val & 0x00ff0000UL) >> 8) |
          ((val & 0xff000000UL) >> 24));
    80005f40:	0189571b          	srliw	a4,s2,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80005f44:	8fd9                	or	a5,a5,a4
          ((val & 0x0000ff00UL) << 8) |
    80005f46:	0089171b          	slliw	a4,s2,0x8
    80005f4a:	00ff06b7          	lui	a3,0xff0
    80005f4e:	8f75                	and	a4,a4,a3
          ((val & 0x00ff0000UL) >> 8) |
    80005f50:	8fd9                	or	a5,a5,a4
    80005f52:	0089591b          	srliw	s2,s2,0x8
    80005f56:	6741                	lui	a4,0x10
    80005f58:	f0070713          	addi	a4,a4,-256 # ff00 <_entry-0x7fff0100>
    80005f5c:	00e97933          	and	s2,s2,a4
    80005f60:	0127e933          	or	s2,a5,s2
  iphdr->ip_dst = htonl(dip);
    80005f64:	0124a823          	sw	s2,16(s1)
  iphdr->ip_len = htons(m->len);
    80005f68:	0109a783          	lw	a5,16(s3)
  return (((val & 0x00ffU) << 8) |
    80005f6c:	0087d713          	srli	a4,a5,0x8
    80005f70:	0087979b          	slliw	a5,a5,0x8
    80005f74:	0ff77713          	andi	a4,a4,255
    80005f78:	8fd9                	or	a5,a5,a4
    80005f7a:	00f49123          	sh	a5,2(s1)
  iphdr->ip_ttl = 100;
    80005f7e:	06400793          	li	a5,100
    80005f82:	00f48423          	sb	a5,8(s1)
  iphdr->ip_sum = in_cksum((unsigned char *)iphdr, sizeof(*iphdr));
    80005f86:	45d1                	li	a1,20
    80005f88:	8526                	mv	a0,s1
    80005f8a:	00000097          	auipc	ra,0x0
    80005f8e:	cae080e7          	jalr	-850(ra) # 80005c38 <in_cksum>
    80005f92:	00a49523          	sh	a0,10(s1)
  net_tx_eth(m, ETHTYPE_IP);
    80005f96:	6585                	lui	a1,0x1
    80005f98:	80058593          	addi	a1,a1,-2048 # 800 <_entry-0x7ffff800>
    80005f9c:	854e                	mv	a0,s3
    80005f9e:	00000097          	auipc	ra,0x0
    80005fa2:	d70080e7          	jalr	-656(ra) # 80005d0e <net_tx_eth>

  // now on to the IP layer
  net_tx_ip(m, IPPROTO_UDP, dip);
}
    80005fa6:	70a2                	ld	ra,40(sp)
    80005fa8:	7402                	ld	s0,32(sp)
    80005faa:	64e2                	ld	s1,24(sp)
    80005fac:	6942                	ld	s2,16(sp)
    80005fae:	69a2                	ld	s3,8(sp)
    80005fb0:	6a02                	ld	s4,0(sp)
    80005fb2:	6145                	addi	sp,sp,48
    80005fb4:	8082                	ret

0000000080005fb6 <net_rx>:
}

// called by e1000 driver's interrupt handler to deliver a packet to the
// networking stack
void net_rx(struct mbuf *m)
{
    80005fb6:	715d                	addi	sp,sp,-80
    80005fb8:	e486                	sd	ra,72(sp)
    80005fba:	e0a2                	sd	s0,64(sp)
    80005fbc:	fc26                	sd	s1,56(sp)
    80005fbe:	f84a                	sd	s2,48(sp)
    80005fc0:	f44e                	sd	s3,40(sp)
    80005fc2:	f052                	sd	s4,32(sp)
    80005fc4:	ec56                	sd	s5,24(sp)
    80005fc6:	0880                	addi	s0,sp,80
    80005fc8:	84aa                	mv	s1,a0
  struct eth *ethhdr;
  uint16 type;

  ethhdr = mbufpullhdr(m, *ethhdr);
    80005fca:	45b9                	li	a1,14
    80005fcc:	00000097          	auipc	ra,0x0
    80005fd0:	ce6080e7          	jalr	-794(ra) # 80005cb2 <mbufpull>
  if (!ethhdr) {
    80005fd4:	c529                	beqz	a0,8000601e <net_rx+0x68>
    mbuffree(m);
    return;
  }

  type = ntohs(ethhdr->type);
    80005fd6:	00c54703          	lbu	a4,12(a0)
    80005fda:	00d54683          	lbu	a3,13(a0)
    80005fde:	06a2                	slli	a3,a3,0x8
    80005fe0:	00e6e7b3          	or	a5,a3,a4
    80005fe4:	82a1                	srli	a3,a3,0x8
    80005fe6:	0087979b          	slliw	a5,a5,0x8
    80005fea:	8fd5                	or	a5,a5,a3
    80005fec:	17c2                	slli	a5,a5,0x30
    80005fee:	93c1                	srli	a5,a5,0x30
  if (type == ETHTYPE_IP)
    80005ff0:	8007871b          	addiw	a4,a5,-2048
    80005ff4:	cb1d                	beqz	a4,8000602a <net_rx+0x74>
    net_rx_ip(m);
  else if (type == ETHTYPE_ARP)
    80005ff6:	2781                	sext.w	a5,a5
    80005ff8:	6705                	lui	a4,0x1
    80005ffa:	80670713          	addi	a4,a4,-2042 # 806 <_entry-0x7ffff7fa>
    80005ffe:	18e78e63          	beq	a5,a4,8000619a <net_rx+0x1e4>
  kfree(m);
    80006002:	8526                	mv	a0,s1
    80006004:	ffffa097          	auipc	ra,0xffffa
    80006008:	018080e7          	jalr	24(ra) # 8000001c <kfree>
    net_rx_arp(m);
  else
    mbuffree(m);
}
    8000600c:	60a6                	ld	ra,72(sp)
    8000600e:	6406                	ld	s0,64(sp)
    80006010:	74e2                	ld	s1,56(sp)
    80006012:	7942                	ld	s2,48(sp)
    80006014:	79a2                	ld	s3,40(sp)
    80006016:	7a02                	ld	s4,32(sp)
    80006018:	6ae2                	ld	s5,24(sp)
    8000601a:	6161                	addi	sp,sp,80
    8000601c:	8082                	ret
  kfree(m);
    8000601e:	8526                	mv	a0,s1
    80006020:	ffffa097          	auipc	ra,0xffffa
    80006024:	ffc080e7          	jalr	-4(ra) # 8000001c <kfree>
    80006028:	b7d5                	j	8000600c <net_rx+0x56>
  iphdr = mbufpullhdr(m, *iphdr);
    8000602a:	45d1                	li	a1,20
    8000602c:	8526                	mv	a0,s1
    8000602e:	00000097          	auipc	ra,0x0
    80006032:	c84080e7          	jalr	-892(ra) # 80005cb2 <mbufpull>
    80006036:	892a                	mv	s2,a0
  if (!iphdr)
    80006038:	c519                	beqz	a0,80006046 <net_rx+0x90>
  if (iphdr->ip_vhl != ((4 << 4) | (20 >> 2)))
    8000603a:	00054703          	lbu	a4,0(a0)
    8000603e:	04500793          	li	a5,69
    80006042:	00f70863          	beq	a4,a5,80006052 <net_rx+0x9c>
  kfree(m);
    80006046:	8526                	mv	a0,s1
    80006048:	ffffa097          	auipc	ra,0xffffa
    8000604c:	fd4080e7          	jalr	-44(ra) # 8000001c <kfree>
    80006050:	bf75                	j	8000600c <net_rx+0x56>
  if (in_cksum((unsigned char *)iphdr, sizeof(*iphdr)))
    80006052:	45d1                	li	a1,20
    80006054:	00000097          	auipc	ra,0x0
    80006058:	be4080e7          	jalr	-1052(ra) # 80005c38 <in_cksum>
    8000605c:	f56d                	bnez	a0,80006046 <net_rx+0x90>
    8000605e:	00695783          	lhu	a5,6(s2)
    80006062:	0087d713          	srli	a4,a5,0x8
    80006066:	0087979b          	slliw	a5,a5,0x8
    8000606a:	0ff77713          	andi	a4,a4,255
    8000606e:	8fd9                	or	a5,a5,a4
  if (htons(iphdr->ip_off) != 0)
    80006070:	17c2                	slli	a5,a5,0x30
    80006072:	93c1                	srli	a5,a5,0x30
    80006074:	fbe9                	bnez	a5,80006046 <net_rx+0x90>
  if (htonl(iphdr->ip_dst) != local_ip)
    80006076:	01092703          	lw	a4,16(s2)
  return (((val & 0x000000ffUL) << 24) |
    8000607a:	0187179b          	slliw	a5,a4,0x18
          ((val & 0xff000000UL) >> 24));
    8000607e:	0187569b          	srliw	a3,a4,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006082:	8fd5                	or	a5,a5,a3
          ((val & 0x0000ff00UL) << 8) |
    80006084:	0087169b          	slliw	a3,a4,0x8
    80006088:	00ff0637          	lui	a2,0xff0
    8000608c:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    8000608e:	8fd5                	or	a5,a5,a3
    80006090:	0087571b          	srliw	a4,a4,0x8
    80006094:	66c1                	lui	a3,0x10
    80006096:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    8000609a:	8f75                	and	a4,a4,a3
    8000609c:	8fd9                	or	a5,a5,a4
    8000609e:	2781                	sext.w	a5,a5
    800060a0:	0a000737          	lui	a4,0xa000
    800060a4:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    800060a8:	f8e79fe3          	bne	a5,a4,80006046 <net_rx+0x90>
  if (iphdr->ip_p != IPPROTO_UDP)
    800060ac:	00994703          	lbu	a4,9(s2)
    800060b0:	47c5                	li	a5,17
    800060b2:	f8f71ae3          	bne	a4,a5,80006046 <net_rx+0x90>
  return (((val & 0x00ffU) << 8) |
    800060b6:	00295783          	lhu	a5,2(s2)
    800060ba:	0087d713          	srli	a4,a5,0x8
    800060be:	0087979b          	slliw	a5,a5,0x8
    800060c2:	0ff77713          	andi	a4,a4,255
    800060c6:	8fd9                	or	a5,a5,a4
    800060c8:	03079993          	slli	s3,a5,0x30
    800060cc:	0309d993          	srli	s3,s3,0x30
  len = ntohs(iphdr->ip_len) - sizeof(*iphdr);
    800060d0:	fec9879b          	addiw	a5,s3,-20
    800060d4:	03079a13          	slli	s4,a5,0x30
    800060d8:	030a5a13          	srli	s4,s4,0x30
  udphdr = mbufpullhdr(m, *udphdr);
    800060dc:	45a1                	li	a1,8
    800060de:	8526                	mv	a0,s1
    800060e0:	00000097          	auipc	ra,0x0
    800060e4:	bd2080e7          	jalr	-1070(ra) # 80005cb2 <mbufpull>
    800060e8:	8aaa                	mv	s5,a0
  if (!udphdr)
    800060ea:	c915                	beqz	a0,8000611e <net_rx+0x168>
    800060ec:	00455783          	lhu	a5,4(a0)
    800060f0:	0087d713          	srli	a4,a5,0x8
    800060f4:	0087979b          	slliw	a5,a5,0x8
    800060f8:	0ff77713          	andi	a4,a4,255
    800060fc:	8fd9                	or	a5,a5,a4
  if (ntohs(udphdr->ulen) != len)
    800060fe:	2a01                	sext.w	s4,s4
    80006100:	17c2                	slli	a5,a5,0x30
    80006102:	93c1                	srli	a5,a5,0x30
    80006104:	00fa1d63          	bne	s4,a5,8000611e <net_rx+0x168>
  len -= sizeof(*udphdr);
    80006108:	fe49879b          	addiw	a5,s3,-28
  if (len > m->len)
    8000610c:	0107979b          	slliw	a5,a5,0x10
    80006110:	0107d79b          	srliw	a5,a5,0x10
    80006114:	0007871b          	sext.w	a4,a5
    80006118:	488c                	lw	a1,16(s1)
    8000611a:	00e5f863          	bleu	a4,a1,8000612a <net_rx+0x174>
  kfree(m);
    8000611e:	8526                	mv	a0,s1
    80006120:	ffffa097          	auipc	ra,0xffffa
    80006124:	efc080e7          	jalr	-260(ra) # 8000001c <kfree>
    80006128:	b5d5                	j	8000600c <net_rx+0x56>
  mbuftrim(m, m->len - len);
    8000612a:	9d9d                	subw	a1,a1,a5
    8000612c:	8526                	mv	a0,s1
    8000612e:	00000097          	auipc	ra,0x0
    80006132:	c9a080e7          	jalr	-870(ra) # 80005dc8 <mbuftrim>
  sip = ntohl(iphdr->ip_src);
    80006136:	00c92783          	lw	a5,12(s2)
    8000613a:	000ad703          	lhu	a4,0(s5) # 3000 <_entry-0x7fffd000>
    8000613e:	00875693          	srli	a3,a4,0x8
    80006142:	0087171b          	slliw	a4,a4,0x8
    80006146:	0ff6f693          	andi	a3,a3,255
    8000614a:	8ed9                	or	a3,a3,a4
    8000614c:	002ad703          	lhu	a4,2(s5)
    80006150:	00875613          	srli	a2,a4,0x8
    80006154:	0087171b          	slliw	a4,a4,0x8
    80006158:	0ff67613          	andi	a2,a2,255
    8000615c:	8e59                	or	a2,a2,a4
  return (((val & 0x000000ffUL) << 24) |
    8000615e:	0187971b          	slliw	a4,a5,0x18
          ((val & 0xff000000UL) >> 24));
    80006162:	0187d59b          	srliw	a1,a5,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006166:	8f4d                	or	a4,a4,a1
          ((val & 0x0000ff00UL) << 8) |
    80006168:	0087959b          	slliw	a1,a5,0x8
    8000616c:	00ff0537          	lui	a0,0xff0
    80006170:	8de9                	and	a1,a1,a0
          ((val & 0x00ff0000UL) >> 8) |
    80006172:	8f4d                	or	a4,a4,a1
    80006174:	0087d79b          	srliw	a5,a5,0x8
    80006178:	65c1                	lui	a1,0x10
    8000617a:	f0058593          	addi	a1,a1,-256 # ff00 <_entry-0x7fff0100>
    8000617e:	8fed                	and	a5,a5,a1
    80006180:	8fd9                	or	a5,a5,a4
  sockrecvudp(m, sip, dport, sport);
    80006182:	16c2                	slli	a3,a3,0x30
    80006184:	92c1                	srli	a3,a3,0x30
    80006186:	1642                	slli	a2,a2,0x30
    80006188:	9241                	srli	a2,a2,0x30
    8000618a:	0007859b          	sext.w	a1,a5
    8000618e:	8526                	mv	a0,s1
    80006190:	00000097          	auipc	ra,0x0
    80006194:	564080e7          	jalr	1380(ra) # 800066f4 <sockrecvudp>
  return;
    80006198:	bd95                	j	8000600c <net_rx+0x56>
  arphdr = mbufpullhdr(m, *arphdr);
    8000619a:	45f1                	li	a1,28
    8000619c:	8526                	mv	a0,s1
    8000619e:	00000097          	auipc	ra,0x0
    800061a2:	b14080e7          	jalr	-1260(ra) # 80005cb2 <mbufpull>
    800061a6:	892a                	mv	s2,a0
  if (!arphdr)
    800061a8:	c171                	beqz	a0,8000626c <net_rx+0x2b6>
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    800061aa:	00054783          	lbu	a5,0(a0) # ff0000 <_entry-0x7f010000>
    800061ae:	00154703          	lbu	a4,1(a0)
    800061b2:	0722                	slli	a4,a4,0x8
  return (((val & 0x00ffU) << 8) |
    800061b4:	8fd9                	or	a5,a5,a4
    800061b6:	8321                	srli	a4,a4,0x8
    800061b8:	0087979b          	slliw	a5,a5,0x8
    800061bc:	8fd9                	or	a5,a5,a4
    800061be:	17c2                	slli	a5,a5,0x30
    800061c0:	93c1                	srli	a5,a5,0x30
    800061c2:	4705                	li	a4,1
    800061c4:	0ae79463          	bne	a5,a4,8000626c <net_rx+0x2b6>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    800061c8:	00254783          	lbu	a5,2(a0)
    800061cc:	00354703          	lbu	a4,3(a0)
    800061d0:	0722                	slli	a4,a4,0x8
    800061d2:	8fd9                	or	a5,a5,a4
    800061d4:	8321                	srli	a4,a4,0x8
    800061d6:	0087979b          	slliw	a5,a5,0x8
    800061da:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->hrd) != ARP_HRD_ETHER ||
    800061dc:	0107979b          	slliw	a5,a5,0x10
    800061e0:	0107d79b          	srliw	a5,a5,0x10
    800061e4:	8007879b          	addiw	a5,a5,-2048
    800061e8:	e3d1                	bnez	a5,8000626c <net_rx+0x2b6>
      ntohs(arphdr->pro) != ETHTYPE_IP ||
    800061ea:	00454703          	lbu	a4,4(a0)
    800061ee:	4799                	li	a5,6
    800061f0:	06f71e63          	bne	a4,a5,8000626c <net_rx+0x2b6>
      arphdr->hln != ETHADDR_LEN ||
    800061f4:	00554703          	lbu	a4,5(a0)
    800061f8:	4791                	li	a5,4
    800061fa:	06f71963          	bne	a4,a5,8000626c <net_rx+0x2b6>
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    800061fe:	00654783          	lbu	a5,6(a0)
    80006202:	00754703          	lbu	a4,7(a0)
    80006206:	0722                	slli	a4,a4,0x8
    80006208:	8fd9                	or	a5,a5,a4
    8000620a:	8321                	srli	a4,a4,0x8
    8000620c:	0087979b          	slliw	a5,a5,0x8
    80006210:	8fd9                	or	a5,a5,a4
    80006212:	17c2                	slli	a5,a5,0x30
    80006214:	93c1                	srli	a5,a5,0x30
    80006216:	4705                	li	a4,1
    80006218:	04e79a63          	bne	a5,a4,8000626c <net_rx+0x2b6>
  tip = ntohl(arphdr->tip); // target IP address
    8000621c:	01854783          	lbu	a5,24(a0)
    80006220:	01954703          	lbu	a4,25(a0)
    80006224:	0722                	slli	a4,a4,0x8
    80006226:	8f5d                	or	a4,a4,a5
    80006228:	01a54783          	lbu	a5,26(a0)
    8000622c:	07c2                	slli	a5,a5,0x10
    8000622e:	8f5d                	or	a4,a4,a5
    80006230:	01b54783          	lbu	a5,27(a0)
    80006234:	07e2                	slli	a5,a5,0x18
    80006236:	8fd9                	or	a5,a5,a4
    80006238:	2781                	sext.w	a5,a5
  return (((val & 0x000000ffUL) << 24) |
    8000623a:	0187971b          	slliw	a4,a5,0x18
          ((val & 0xff000000UL) >> 24));
    8000623e:	0187d69b          	srliw	a3,a5,0x18
          ((val & 0x00ff0000UL) >> 8) |
    80006242:	8f55                	or	a4,a4,a3
          ((val & 0x0000ff00UL) << 8) |
    80006244:	0087969b          	slliw	a3,a5,0x8
    80006248:	00ff0637          	lui	a2,0xff0
    8000624c:	8ef1                	and	a3,a3,a2
          ((val & 0x00ff0000UL) >> 8) |
    8000624e:	8f55                	or	a4,a4,a3
    80006250:	0087d79b          	srliw	a5,a5,0x8
    80006254:	66c1                	lui	a3,0x10
    80006256:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    8000625a:	8ff5                	and	a5,a5,a3
    8000625c:	8fd9                	or	a5,a5,a4
  if (ntohs(arphdr->op) != ARP_OP_REQUEST || tip != local_ip)
    8000625e:	2781                	sext.w	a5,a5
    80006260:	0a000737          	lui	a4,0xa000
    80006264:	20f70713          	addi	a4,a4,527 # a00020f <_entry-0x75fffdf1>
    80006268:	00e78863          	beq	a5,a4,80006278 <net_rx+0x2c2>
  kfree(m);
    8000626c:	8526                	mv	a0,s1
    8000626e:	ffffa097          	auipc	ra,0xffffa
    80006272:	dae080e7          	jalr	-594(ra) # 8000001c <kfree>
    80006276:	bb59                	j	8000600c <net_rx+0x56>
  memmove(smac, arphdr->sha, ETHADDR_LEN); // sender's ethernet address
    80006278:	4619                	li	a2,6
    8000627a:	00850593          	addi	a1,a0,8
    8000627e:	fb840513          	addi	a0,s0,-72
    80006282:	ffffa097          	auipc	ra,0xffffa
    80006286:	f66080e7          	jalr	-154(ra) # 800001e8 <memmove>
  sip = ntohl(arphdr->sip); // sender's IP address (qemu's slirp)
    8000628a:	00e94783          	lbu	a5,14(s2)
    8000628e:	00f94703          	lbu	a4,15(s2)
    80006292:	0722                	slli	a4,a4,0x8
    80006294:	8f5d                	or	a4,a4,a5
    80006296:	01094783          	lbu	a5,16(s2)
    8000629a:	07c2                	slli	a5,a5,0x10
    8000629c:	8f5d                	or	a4,a4,a5
    8000629e:	01194783          	lbu	a5,17(s2)
    800062a2:	07e2                	slli	a5,a5,0x18
    800062a4:	8fd9                	or	a5,a5,a4
    800062a6:	2781                	sext.w	a5,a5
  return (((val & 0x000000ffUL) << 24) |
    800062a8:	0187999b          	slliw	s3,a5,0x18
          ((val & 0xff000000UL) >> 24));
    800062ac:	0187d71b          	srliw	a4,a5,0x18
          ((val & 0x00ff0000UL) >> 8) |
    800062b0:	00e9e9b3          	or	s3,s3,a4
          ((val & 0x0000ff00UL) << 8) |
    800062b4:	0087971b          	slliw	a4,a5,0x8
    800062b8:	00ff06b7          	lui	a3,0xff0
    800062bc:	8f75                	and	a4,a4,a3
          ((val & 0x00ff0000UL) >> 8) |
    800062be:	00e9e9b3          	or	s3,s3,a4
    800062c2:	0087d79b          	srliw	a5,a5,0x8
    800062c6:	6741                	lui	a4,0x10
    800062c8:	f0070713          	addi	a4,a4,-256 # ff00 <_entry-0x7fff0100>
    800062cc:	8ff9                	and	a5,a5,a4
    800062ce:	00f9e7b3          	or	a5,s3,a5
    800062d2:	0007899b          	sext.w	s3,a5
  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    800062d6:	08000513          	li	a0,128
    800062da:	00000097          	auipc	ra,0x0
    800062de:	b10080e7          	jalr	-1264(ra) # 80005dea <mbufalloc>
    800062e2:	8a2a                	mv	s4,a0
  if (!m)
    800062e4:	d541                	beqz	a0,8000626c <net_rx+0x2b6>
  arphdr = mbufputhdr(m, *arphdr);
    800062e6:	45f1                	li	a1,28
    800062e8:	00000097          	auipc	ra,0x0
    800062ec:	aa6080e7          	jalr	-1370(ra) # 80005d8e <mbufput>
    800062f0:	892a                	mv	s2,a0
  arphdr->hrd = htons(ARP_HRD_ETHER);
    800062f2:	00050023          	sb	zero,0(a0)
    800062f6:	4785                	li	a5,1
    800062f8:	00f500a3          	sb	a5,1(a0)
  arphdr->pro = htons(ETHTYPE_IP);
    800062fc:	47a1                	li	a5,8
    800062fe:	00f50123          	sb	a5,2(a0)
    80006302:	000501a3          	sb	zero,3(a0)
  arphdr->hln = ETHADDR_LEN;
    80006306:	4799                	li	a5,6
    80006308:	00f50223          	sb	a5,4(a0)
  arphdr->pln = sizeof(uint32);
    8000630c:	4791                	li	a5,4
    8000630e:	00f502a3          	sb	a5,5(a0)
  arphdr->op = htons(op);
    80006312:	00050323          	sb	zero,6(a0)
    80006316:	4a89                	li	s5,2
    80006318:	015503a3          	sb	s5,7(a0)
  memmove(arphdr->sha, local_mac, ETHADDR_LEN);
    8000631c:	4619                	li	a2,6
    8000631e:	00003597          	auipc	a1,0x3
    80006322:	56258593          	addi	a1,a1,1378 # 80009880 <local_mac>
    80006326:	0521                	addi	a0,a0,8
    80006328:	ffffa097          	auipc	ra,0xffffa
    8000632c:	ec0080e7          	jalr	-320(ra) # 800001e8 <memmove>
  arphdr->sip = htonl(local_ip);
    80006330:	47a9                	li	a5,10
    80006332:	00f90723          	sb	a5,14(s2)
    80006336:	000907a3          	sb	zero,15(s2)
    8000633a:	01590823          	sb	s5,16(s2)
    8000633e:	47bd                	li	a5,15
    80006340:	00f908a3          	sb	a5,17(s2)
  memmove(arphdr->tha, dmac, ETHADDR_LEN);
    80006344:	4619                	li	a2,6
    80006346:	fb840593          	addi	a1,s0,-72
    8000634a:	01290513          	addi	a0,s2,18
    8000634e:	ffffa097          	auipc	ra,0xffffa
    80006352:	e9a080e7          	jalr	-358(ra) # 800001e8 <memmove>
  return (((val & 0x000000ffUL) << 24) |
    80006356:	0189979b          	slliw	a5,s3,0x18
          ((val & 0xff000000UL) >> 24));
    8000635a:	0189d71b          	srliw	a4,s3,0x18
          ((val & 0x00ff0000UL) >> 8) |
    8000635e:	8fd9                	or	a5,a5,a4
          ((val & 0x0000ff00UL) << 8) |
    80006360:	0089971b          	slliw	a4,s3,0x8
    80006364:	00ff06b7          	lui	a3,0xff0
    80006368:	8f75                	and	a4,a4,a3
          ((val & 0x00ff0000UL) >> 8) |
    8000636a:	8fd9                	or	a5,a5,a4
    8000636c:	0089d71b          	srliw	a4,s3,0x8
    80006370:	66c1                	lui	a3,0x10
    80006372:	f0068693          	addi	a3,a3,-256 # ff00 <_entry-0x7fff0100>
    80006376:	8f75                	and	a4,a4,a3
    80006378:	8fd9                	or	a5,a5,a4
  arphdr->tip = htonl(dip);
    8000637a:	00f90c23          	sb	a5,24(s2)
    8000637e:	0087d71b          	srliw	a4,a5,0x8
    80006382:	00e90ca3          	sb	a4,25(s2)
    80006386:	0107d71b          	srliw	a4,a5,0x10
    8000638a:	00e90d23          	sb	a4,26(s2)
    8000638e:	0187d79b          	srliw	a5,a5,0x18
    80006392:	00f90da3          	sb	a5,27(s2)
  net_tx_eth(m, ETHTYPE_ARP);
    80006396:	6585                	lui	a1,0x1
    80006398:	80658593          	addi	a1,a1,-2042 # 806 <_entry-0x7ffff7fa>
    8000639c:	8552                	mv	a0,s4
    8000639e:	00000097          	auipc	ra,0x0
    800063a2:	970080e7          	jalr	-1680(ra) # 80005d0e <net_tx_eth>
  return 0;
    800063a6:	b5d9                	j	8000626c <net_rx+0x2b6>

00000000800063a8 <sockinit>:
static struct spinlock lock;
static struct sock *sockets;

void
sockinit(void)
{
    800063a8:	1141                	addi	sp,sp,-16
    800063aa:	e406                	sd	ra,8(sp)
    800063ac:	e022                	sd	s0,0(sp)
    800063ae:	0800                	addi	s0,sp,16
  initlock(&lock, "socktbl");
    800063b0:	00003597          	auipc	a1,0x3
    800063b4:	42858593          	addi	a1,a1,1064 # 800097d8 <syscalls+0x450>
    800063b8:	00019517          	auipc	a0,0x19
    800063bc:	f6850513          	addi	a0,a0,-152 # 8001f320 <lock>
    800063c0:	00001097          	auipc	ra,0x1
    800063c4:	ea4080e7          	jalr	-348(ra) # 80007264 <initlock>
}
    800063c8:	60a2                	ld	ra,8(sp)
    800063ca:	6402                	ld	s0,0(sp)
    800063cc:	0141                	addi	sp,sp,16
    800063ce:	8082                	ret

00000000800063d0 <sockalloc>:

int
sockalloc(struct file **f, uint32 raddr, uint16 lport, uint16 rport)
{
    800063d0:	7139                	addi	sp,sp,-64
    800063d2:	fc06                	sd	ra,56(sp)
    800063d4:	f822                	sd	s0,48(sp)
    800063d6:	f426                	sd	s1,40(sp)
    800063d8:	f04a                	sd	s2,32(sp)
    800063da:	ec4e                	sd	s3,24(sp)
    800063dc:	e852                	sd	s4,16(sp)
    800063de:	e456                	sd	s5,8(sp)
    800063e0:	0080                	addi	s0,sp,64
    800063e2:	89aa                	mv	s3,a0
    800063e4:	84ae                	mv	s1,a1
    800063e6:	8a32                	mv	s4,a2
    800063e8:	8ab6                	mv	s5,a3
  struct sock *si, *pos;

  si = 0;
  *f = 0;
    800063ea:	00053023          	sd	zero,0(a0)
  if ((*f = filealloc()) == 0)
    800063ee:	ffffd097          	auipc	ra,0xffffd
    800063f2:	5e4080e7          	jalr	1508(ra) # 800039d2 <filealloc>
    800063f6:	00a9b023          	sd	a0,0(s3)
    800063fa:	c975                	beqz	a0,800064ee <sockalloc+0x11e>
    goto bad;
  if ((si = (struct sock*)kalloc()) == 0)
    800063fc:	ffffa097          	auipc	ra,0xffffa
    80006400:	d20080e7          	jalr	-736(ra) # 8000011c <kalloc>
    80006404:	892a                	mv	s2,a0
    80006406:	c15d                	beqz	a0,800064ac <sockalloc+0xdc>
    goto bad;

  // initialize objects
  si->raddr = raddr;
    80006408:	c504                	sw	s1,8(a0)
  si->lport = lport;
    8000640a:	01451623          	sh	s4,12(a0)
  si->rport = rport;
    8000640e:	01551723          	sh	s5,14(a0)
  initlock(&si->lock, "sock");
    80006412:	00003597          	auipc	a1,0x3
    80006416:	3ce58593          	addi	a1,a1,974 # 800097e0 <syscalls+0x458>
    8000641a:	0541                	addi	a0,a0,16
    8000641c:	00001097          	auipc	ra,0x1
    80006420:	e48080e7          	jalr	-440(ra) # 80007264 <initlock>
  mbufq_init(&si->rxq);
    80006424:	02890513          	addi	a0,s2,40
    80006428:	00000097          	auipc	ra,0x0
    8000642c:	a7a080e7          	jalr	-1414(ra) # 80005ea2 <mbufq_init>
  (*f)->type = FD_SOCK;
    80006430:	0009b783          	ld	a5,0(s3)
    80006434:	4711                	li	a4,4
    80006436:	c398                	sw	a4,0(a5)
  (*f)->readable = 1;
    80006438:	0009b703          	ld	a4,0(s3)
    8000643c:	4785                	li	a5,1
    8000643e:	00f70423          	sb	a5,8(a4)
  (*f)->writable = 1;
    80006442:	0009b703          	ld	a4,0(s3)
    80006446:	00f704a3          	sb	a5,9(a4)
  (*f)->sock = si;
    8000644a:	0009b783          	ld	a5,0(s3)
    8000644e:	0327b023          	sd	s2,32(a5) # f020020 <_entry-0x70fdffe0>

  // add to list of sockets
  acquire(&lock);
    80006452:	00019517          	auipc	a0,0x19
    80006456:	ece50513          	addi	a0,a0,-306 # 8001f320 <lock>
    8000645a:	00001097          	auipc	ra,0x1
    8000645e:	e9a080e7          	jalr	-358(ra) # 800072f4 <acquire>
  pos = sockets;
    80006462:	00004797          	auipc	a5,0x4
    80006466:	bc678793          	addi	a5,a5,-1082 # 8000a028 <sockets>
    8000646a:	6394                	ld	a3,0(a5)
  while (pos) {
    8000646c:	caa9                	beqz	a3,800064be <sockalloc+0xee>
  pos = sockets;
    8000646e:	87b6                	mv	a5,a3
    if (pos->raddr == raddr &&
    80006470:	000a061b          	sext.w	a2,s4
        pos->lport == lport &&
    80006474:	2a81                	sext.w	s5,s5
    80006476:	a019                	j	8000647c <sockalloc+0xac>
	pos->rport == rport) {
      release(&lock);
      goto bad;
    }
    pos = pos->next;
    80006478:	639c                	ld	a5,0(a5)
  while (pos) {
    8000647a:	c3b1                	beqz	a5,800064be <sockalloc+0xee>
    if (pos->raddr == raddr &&
    8000647c:	4798                	lw	a4,8(a5)
    8000647e:	fe971de3          	bne	a4,s1,80006478 <sockalloc+0xa8>
    80006482:	00c7d703          	lhu	a4,12(a5)
    80006486:	fec719e3          	bne	a4,a2,80006478 <sockalloc+0xa8>
        pos->lport == lport &&
    8000648a:	00e7d703          	lhu	a4,14(a5)
    8000648e:	ff5715e3          	bne	a4,s5,80006478 <sockalloc+0xa8>
      release(&lock);
    80006492:	00019517          	auipc	a0,0x19
    80006496:	e8e50513          	addi	a0,a0,-370 # 8001f320 <lock>
    8000649a:	00001097          	auipc	ra,0x1
    8000649e:	f0e080e7          	jalr	-242(ra) # 800073a8 <release>
  release(&lock);
  return 0;

bad:
  if (si)
    kfree((char*)si);
    800064a2:	854a                	mv	a0,s2
    800064a4:	ffffa097          	auipc	ra,0xffffa
    800064a8:	b78080e7          	jalr	-1160(ra) # 8000001c <kfree>
  if (*f)
    800064ac:	0009b503          	ld	a0,0(s3)
    800064b0:	c129                	beqz	a0,800064f2 <sockalloc+0x122>
    fileclose(*f);
    800064b2:	ffffd097          	auipc	ra,0xffffd
    800064b6:	5f0080e7          	jalr	1520(ra) # 80003aa2 <fileclose>
  return -1;
    800064ba:	557d                	li	a0,-1
    800064bc:	a005                	j	800064dc <sockalloc+0x10c>
  si->next = sockets;
    800064be:	00d93023          	sd	a3,0(s2)
  sockets = si;
    800064c2:	00004797          	auipc	a5,0x4
    800064c6:	b727b323          	sd	s2,-1178(a5) # 8000a028 <sockets>
  release(&lock);
    800064ca:	00019517          	auipc	a0,0x19
    800064ce:	e5650513          	addi	a0,a0,-426 # 8001f320 <lock>
    800064d2:	00001097          	auipc	ra,0x1
    800064d6:	ed6080e7          	jalr	-298(ra) # 800073a8 <release>
  return 0;
    800064da:	4501                	li	a0,0
}
    800064dc:	70e2                	ld	ra,56(sp)
    800064de:	7442                	ld	s0,48(sp)
    800064e0:	74a2                	ld	s1,40(sp)
    800064e2:	7902                	ld	s2,32(sp)
    800064e4:	69e2                	ld	s3,24(sp)
    800064e6:	6a42                	ld	s4,16(sp)
    800064e8:	6aa2                	ld	s5,8(sp)
    800064ea:	6121                	addi	sp,sp,64
    800064ec:	8082                	ret
  return -1;
    800064ee:	557d                	li	a0,-1
    800064f0:	b7f5                	j	800064dc <sockalloc+0x10c>
    800064f2:	557d                	li	a0,-1
    800064f4:	b7e5                	j	800064dc <sockalloc+0x10c>

00000000800064f6 <sockclose>:

void
sockclose(struct sock *si)
{
    800064f6:	1101                	addi	sp,sp,-32
    800064f8:	ec06                	sd	ra,24(sp)
    800064fa:	e822                	sd	s0,16(sp)
    800064fc:	e426                	sd	s1,8(sp)
    800064fe:	e04a                	sd	s2,0(sp)
    80006500:	1000                	addi	s0,sp,32
    80006502:	892a                	mv	s2,a0
  struct sock **pos;
  struct mbuf *m;

  // remove from list of sockets
  acquire(&lock);
    80006504:	00019517          	auipc	a0,0x19
    80006508:	e1c50513          	addi	a0,a0,-484 # 8001f320 <lock>
    8000650c:	00001097          	auipc	ra,0x1
    80006510:	de8080e7          	jalr	-536(ra) # 800072f4 <acquire>
  pos = &sockets;
    80006514:	00004797          	auipc	a5,0x4
    80006518:	b1478793          	addi	a5,a5,-1260 # 8000a028 <sockets>
    8000651c:	6398                	ld	a4,0(a5)
  while (*pos) {
    8000651e:	c305                	beqz	a4,8000653e <sockclose+0x48>
    if (*pos == si){
    80006520:	00e90863          	beq	s2,a4,80006530 <sockclose+0x3a>
      *pos = si->next;
      break;
    }
    pos = &(*pos)->next;
    80006524:	631c                	ld	a5,0(a4)
  while (*pos) {
    80006526:	cf81                	beqz	a5,8000653e <sockclose+0x48>
    if (*pos == si){
    80006528:	00f90863          	beq	s2,a5,80006538 <sockclose+0x42>
    pos = &(*pos)->next;
    8000652c:	873e                	mv	a4,a5
    8000652e:	bfdd                	j	80006524 <sockclose+0x2e>
  pos = &sockets;
    80006530:	00004717          	auipc	a4,0x4
    80006534:	af870713          	addi	a4,a4,-1288 # 8000a028 <sockets>
      *pos = si->next;
    80006538:	00093783          	ld	a5,0(s2)
    8000653c:	e31c                	sd	a5,0(a4)
  }
  release(&lock);
    8000653e:	00019517          	auipc	a0,0x19
    80006542:	de250513          	addi	a0,a0,-542 # 8001f320 <lock>
    80006546:	00001097          	auipc	ra,0x1
    8000654a:	e62080e7          	jalr	-414(ra) # 800073a8 <release>

  // free any pending mbufs
  while (!mbufq_empty(&si->rxq)) {
    8000654e:	02890493          	addi	s1,s2,40
    80006552:	8526                	mv	a0,s1
    80006554:	00000097          	auipc	ra,0x0
    80006558:	93c080e7          	jalr	-1732(ra) # 80005e90 <mbufq_empty>
    8000655c:	e919                	bnez	a0,80006572 <sockclose+0x7c>
    m = mbufq_pophead(&si->rxq);
    8000655e:	8526                	mv	a0,s1
    80006560:	00000097          	auipc	ra,0x0
    80006564:	91a080e7          	jalr	-1766(ra) # 80005e7a <mbufq_pophead>
    mbuffree(m);
    80006568:	00000097          	auipc	ra,0x0
    8000656c:	8da080e7          	jalr	-1830(ra) # 80005e42 <mbuffree>
    80006570:	b7cd                	j	80006552 <sockclose+0x5c>
  }

  kfree((char*)si);
    80006572:	854a                	mv	a0,s2
    80006574:	ffffa097          	auipc	ra,0xffffa
    80006578:	aa8080e7          	jalr	-1368(ra) # 8000001c <kfree>
}
    8000657c:	60e2                	ld	ra,24(sp)
    8000657e:	6442                	ld	s0,16(sp)
    80006580:	64a2                	ld	s1,8(sp)
    80006582:	6902                	ld	s2,0(sp)
    80006584:	6105                	addi	sp,sp,32
    80006586:	8082                	ret

0000000080006588 <sockread>:

int
sockread(struct sock *si, uint64 addr, int n)
{
    80006588:	7139                	addi	sp,sp,-64
    8000658a:	fc06                	sd	ra,56(sp)
    8000658c:	f822                	sd	s0,48(sp)
    8000658e:	f426                	sd	s1,40(sp)
    80006590:	f04a                	sd	s2,32(sp)
    80006592:	ec4e                	sd	s3,24(sp)
    80006594:	e852                	sd	s4,16(sp)
    80006596:	e456                	sd	s5,8(sp)
    80006598:	e05a                	sd	s6,0(sp)
    8000659a:	0080                	addi	s0,sp,64
    8000659c:	84aa                	mv	s1,a0
    8000659e:	8b2e                	mv	s6,a1
    800065a0:	8ab2                	mv	s5,a2
  struct proc *pr = myproc();
    800065a2:	ffffb097          	auipc	ra,0xffffb
    800065a6:	95e080e7          	jalr	-1698(ra) # 80000f00 <myproc>
    800065aa:	892a                	mv	s2,a0
  struct mbuf *m;
  int len;

  acquire(&si->lock);
    800065ac:	01048993          	addi	s3,s1,16
    800065b0:	854e                	mv	a0,s3
    800065b2:	00001097          	auipc	ra,0x1
    800065b6:	d42080e7          	jalr	-702(ra) # 800072f4 <acquire>
  while (mbufq_empty(&si->rxq) && !pr->killed) {
    800065ba:	02848493          	addi	s1,s1,40
    800065be:	8526                	mv	a0,s1
    800065c0:	00000097          	auipc	ra,0x0
    800065c4:	8d0080e7          	jalr	-1840(ra) # 80005e90 <mbufq_empty>
    800065c8:	c919                	beqz	a0,800065de <sockread+0x56>
    800065ca:	03092783          	lw	a5,48(s2)
    800065ce:	ebbd                	bnez	a5,80006644 <sockread+0xbc>
    sleep(&si->rxq, &si->lock);
    800065d0:	85ce                	mv	a1,s3
    800065d2:	8526                	mv	a0,s1
    800065d4:	ffffb097          	auipc	ra,0xffffb
    800065d8:	146080e7          	jalr	326(ra) # 8000171a <sleep>
    800065dc:	b7cd                	j	800065be <sockread+0x36>
  }
  if (pr->killed) {
    800065de:	03092783          	lw	a5,48(s2)
    800065e2:	e3ad                	bnez	a5,80006644 <sockread+0xbc>
    release(&si->lock);
    return -1;
  }
  m = mbufq_pophead(&si->rxq);
    800065e4:	8526                	mv	a0,s1
    800065e6:	00000097          	auipc	ra,0x0
    800065ea:	894080e7          	jalr	-1900(ra) # 80005e7a <mbufq_pophead>
    800065ee:	8a2a                	mv	s4,a0
  release(&si->lock);
    800065f0:	854e                	mv	a0,s3
    800065f2:	00001097          	auipc	ra,0x1
    800065f6:	db6080e7          	jalr	-586(ra) # 800073a8 <release>

  len = m->len;
    800065fa:	010a2783          	lw	a5,16(s4)
  if (len > n)
    800065fe:	84be                	mv	s1,a5
    80006600:	00fad363          	ble	a5,s5,80006606 <sockread+0x7e>
    80006604:	84d6                	mv	s1,s5
    80006606:	2481                	sext.w	s1,s1
    len = n;
  if (copyout(pr->pagetable, addr, m->head, len) == -1) {
    80006608:	86a6                	mv	a3,s1
    8000660a:	008a3603          	ld	a2,8(s4)
    8000660e:	85da                	mv	a1,s6
    80006610:	05093503          	ld	a0,80(s2)
    80006614:	ffffa097          	auipc	ra,0xffffa
    80006618:	56a080e7          	jalr	1386(ra) # 80000b7e <copyout>
    8000661c:	892a                	mv	s2,a0
    8000661e:	57fd                	li	a5,-1
    80006620:	02f50963          	beq	a0,a5,80006652 <sockread+0xca>
    mbuffree(m);
    return -1;
  }
  mbuffree(m);
    80006624:	8552                	mv	a0,s4
    80006626:	00000097          	auipc	ra,0x0
    8000662a:	81c080e7          	jalr	-2020(ra) # 80005e42 <mbuffree>
  return len;
}
    8000662e:	8526                	mv	a0,s1
    80006630:	70e2                	ld	ra,56(sp)
    80006632:	7442                	ld	s0,48(sp)
    80006634:	74a2                	ld	s1,40(sp)
    80006636:	7902                	ld	s2,32(sp)
    80006638:	69e2                	ld	s3,24(sp)
    8000663a:	6a42                	ld	s4,16(sp)
    8000663c:	6aa2                	ld	s5,8(sp)
    8000663e:	6b02                	ld	s6,0(sp)
    80006640:	6121                	addi	sp,sp,64
    80006642:	8082                	ret
    release(&si->lock);
    80006644:	854e                	mv	a0,s3
    80006646:	00001097          	auipc	ra,0x1
    8000664a:	d62080e7          	jalr	-670(ra) # 800073a8 <release>
    return -1;
    8000664e:	54fd                	li	s1,-1
    80006650:	bff9                	j	8000662e <sockread+0xa6>
    mbuffree(m);
    80006652:	8552                	mv	a0,s4
    80006654:	fffff097          	auipc	ra,0xfffff
    80006658:	7ee080e7          	jalr	2030(ra) # 80005e42 <mbuffree>
    return -1;
    8000665c:	84ca                	mv	s1,s2
    8000665e:	bfc1                	j	8000662e <sockread+0xa6>

0000000080006660 <sockwrite>:

int
sockwrite(struct sock *si, uint64 addr, int n)
{
    80006660:	7139                	addi	sp,sp,-64
    80006662:	fc06                	sd	ra,56(sp)
    80006664:	f822                	sd	s0,48(sp)
    80006666:	f426                	sd	s1,40(sp)
    80006668:	f04a                	sd	s2,32(sp)
    8000666a:	ec4e                	sd	s3,24(sp)
    8000666c:	e852                	sd	s4,16(sp)
    8000666e:	e456                	sd	s5,8(sp)
    80006670:	0080                	addi	s0,sp,64
    80006672:	8a2a                	mv	s4,a0
    80006674:	892e                	mv	s2,a1
    80006676:	89b2                	mv	s3,a2
  struct proc *pr = myproc();
    80006678:	ffffb097          	auipc	ra,0xffffb
    8000667c:	888080e7          	jalr	-1912(ra) # 80000f00 <myproc>
    80006680:	8aaa                	mv	s5,a0
  struct mbuf *m;

  m = mbufalloc(MBUF_DEFAULT_HEADROOM);
    80006682:	08000513          	li	a0,128
    80006686:	fffff097          	auipc	ra,0xfffff
    8000668a:	764080e7          	jalr	1892(ra) # 80005dea <mbufalloc>
  if (!m)
    8000668e:	c12d                	beqz	a0,800066f0 <sockwrite+0x90>
    80006690:	84aa                	mv	s1,a0
    return -1;

  if (copyin(pr->pagetable, mbufput(m, n), addr, n) == -1) {
    80006692:	050aba83          	ld	s5,80(s5)
    80006696:	85ce                	mv	a1,s3
    80006698:	fffff097          	auipc	ra,0xfffff
    8000669c:	6f6080e7          	jalr	1782(ra) # 80005d8e <mbufput>
    800066a0:	86ce                	mv	a3,s3
    800066a2:	864a                	mv	a2,s2
    800066a4:	85aa                	mv	a1,a0
    800066a6:	8556                	mv	a0,s5
    800066a8:	ffffa097          	auipc	ra,0xffffa
    800066ac:	562080e7          	jalr	1378(ra) # 80000c0a <copyin>
    800066b0:	892a                	mv	s2,a0
    800066b2:	57fd                	li	a5,-1
    800066b4:	02f50863          	beq	a0,a5,800066e4 <sockwrite+0x84>
    mbuffree(m);
    return -1;
  }
  net_tx_udp(m, si->raddr, si->lport, si->rport);
    800066b8:	00ea5683          	lhu	a3,14(s4)
    800066bc:	00ca5603          	lhu	a2,12(s4)
    800066c0:	008a2583          	lw	a1,8(s4)
    800066c4:	8526                	mv	a0,s1
    800066c6:	fffff097          	auipc	ra,0xfffff
    800066ca:	7ec080e7          	jalr	2028(ra) # 80005eb2 <net_tx_udp>
  return n;
    800066ce:	894e                	mv	s2,s3
}
    800066d0:	854a                	mv	a0,s2
    800066d2:	70e2                	ld	ra,56(sp)
    800066d4:	7442                	ld	s0,48(sp)
    800066d6:	74a2                	ld	s1,40(sp)
    800066d8:	7902                	ld	s2,32(sp)
    800066da:	69e2                	ld	s3,24(sp)
    800066dc:	6a42                	ld	s4,16(sp)
    800066de:	6aa2                	ld	s5,8(sp)
    800066e0:	6121                	addi	sp,sp,64
    800066e2:	8082                	ret
    mbuffree(m);
    800066e4:	8526                	mv	a0,s1
    800066e6:	fffff097          	auipc	ra,0xfffff
    800066ea:	75c080e7          	jalr	1884(ra) # 80005e42 <mbuffree>
    return -1;
    800066ee:	b7cd                	j	800066d0 <sockwrite+0x70>
    return -1;
    800066f0:	597d                	li	s2,-1
    800066f2:	bff9                	j	800066d0 <sockwrite+0x70>

00000000800066f4 <sockrecvudp>:

// called by protocol handler layer to deliver UDP packets
void
sockrecvudp(struct mbuf *m, uint32 raddr, uint16 lport, uint16 rport)
{
    800066f4:	7139                	addi	sp,sp,-64
    800066f6:	fc06                	sd	ra,56(sp)
    800066f8:	f822                	sd	s0,48(sp)
    800066fa:	f426                	sd	s1,40(sp)
    800066fc:	f04a                	sd	s2,32(sp)
    800066fe:	ec4e                	sd	s3,24(sp)
    80006700:	e852                	sd	s4,16(sp)
    80006702:	e456                	sd	s5,8(sp)
    80006704:	0080                	addi	s0,sp,64
    80006706:	8aaa                	mv	s5,a0
    80006708:	892e                	mv	s2,a1
    8000670a:	89b2                	mv	s3,a2
    8000670c:	8a36                	mv	s4,a3
  // any sleeping reader. Free the mbuf if there are no sockets
  // registered to handle it.
  //
  struct sock *si;

  acquire(&lock);
    8000670e:	00019517          	auipc	a0,0x19
    80006712:	c1250513          	addi	a0,a0,-1006 # 8001f320 <lock>
    80006716:	00001097          	auipc	ra,0x1
    8000671a:	bde080e7          	jalr	-1058(ra) # 800072f4 <acquire>
  si = sockets;
    8000671e:	00004797          	auipc	a5,0x4
    80006722:	90a78793          	addi	a5,a5,-1782 # 8000a028 <sockets>
    80006726:	6384                	ld	s1,0(a5)
  while (si) {
    80006728:	c4ad                	beqz	s1,80006792 <sockrecvudp+0x9e>
    if (si->raddr == raddr && si->lport == lport && si->rport == rport)
    8000672a:	0009861b          	sext.w	a2,s3
    8000672e:	000a069b          	sext.w	a3,s4
    80006732:	a019                	j	80006738 <sockrecvudp+0x44>
      goto found;
    si = si->next;
    80006734:	6084                	ld	s1,0(s1)
  while (si) {
    80006736:	ccb1                	beqz	s1,80006792 <sockrecvudp+0x9e>
    if (si->raddr == raddr && si->lport == lport && si->rport == rport)
    80006738:	449c                	lw	a5,8(s1)
    8000673a:	ff279de3          	bne	a5,s2,80006734 <sockrecvudp+0x40>
    8000673e:	00c4d783          	lhu	a5,12(s1)
    80006742:	fec799e3          	bne	a5,a2,80006734 <sockrecvudp+0x40>
    80006746:	00e4d783          	lhu	a5,14(s1)
    8000674a:	fed795e3          	bne	a5,a3,80006734 <sockrecvudp+0x40>
  release(&lock);
  mbuffree(m);
  return;

found:
  acquire(&si->lock);
    8000674e:	01048913          	addi	s2,s1,16
    80006752:	854a                	mv	a0,s2
    80006754:	00001097          	auipc	ra,0x1
    80006758:	ba0080e7          	jalr	-1120(ra) # 800072f4 <acquire>
  mbufq_pushtail(&si->rxq, m);
    8000675c:	02848493          	addi	s1,s1,40
    80006760:	85d6                	mv	a1,s5
    80006762:	8526                	mv	a0,s1
    80006764:	fffff097          	auipc	ra,0xfffff
    80006768:	6f6080e7          	jalr	1782(ra) # 80005e5a <mbufq_pushtail>
  wakeup(&si->rxq);
    8000676c:	8526                	mv	a0,s1
    8000676e:	ffffb097          	auipc	ra,0xffffb
    80006772:	132080e7          	jalr	306(ra) # 800018a0 <wakeup>
  release(&si->lock);
    80006776:	854a                	mv	a0,s2
    80006778:	00001097          	auipc	ra,0x1
    8000677c:	c30080e7          	jalr	-976(ra) # 800073a8 <release>
  release(&lock);
    80006780:	00019517          	auipc	a0,0x19
    80006784:	ba050513          	addi	a0,a0,-1120 # 8001f320 <lock>
    80006788:	00001097          	auipc	ra,0x1
    8000678c:	c20080e7          	jalr	-992(ra) # 800073a8 <release>
    80006790:	a831                	j	800067ac <sockrecvudp+0xb8>
  release(&lock);
    80006792:	00019517          	auipc	a0,0x19
    80006796:	b8e50513          	addi	a0,a0,-1138 # 8001f320 <lock>
    8000679a:	00001097          	auipc	ra,0x1
    8000679e:	c0e080e7          	jalr	-1010(ra) # 800073a8 <release>
  mbuffree(m);
    800067a2:	8556                	mv	a0,s5
    800067a4:	fffff097          	auipc	ra,0xfffff
    800067a8:	69e080e7          	jalr	1694(ra) # 80005e42 <mbuffree>
}
    800067ac:	70e2                	ld	ra,56(sp)
    800067ae:	7442                	ld	s0,48(sp)
    800067b0:	74a2                	ld	s1,40(sp)
    800067b2:	7902                	ld	s2,32(sp)
    800067b4:	69e2                	ld	s3,24(sp)
    800067b6:	6a42                	ld	s4,16(sp)
    800067b8:	6aa2                	ld	s5,8(sp)
    800067ba:	6121                	addi	sp,sp,64
    800067bc:	8082                	ret

00000000800067be <pci_init>:
#include "proc.h"
#include "defs.h"

void
pci_init()
{
    800067be:	715d                	addi	sp,sp,-80
    800067c0:	e486                	sd	ra,72(sp)
    800067c2:	e0a2                	sd	s0,64(sp)
    800067c4:	fc26                	sd	s1,56(sp)
    800067c6:	f84a                	sd	s2,48(sp)
    800067c8:	f44e                	sd	s3,40(sp)
    800067ca:	f052                	sd	s4,32(sp)
    800067cc:	ec56                	sd	s5,24(sp)
    800067ce:	e85a                	sd	s6,16(sp)
    800067d0:	e45e                	sd	s7,8(sp)
    800067d2:	0880                	addi	s0,sp,80
    800067d4:	300004b7          	lui	s1,0x30000
    uint32 off = (bus << 16) | (dev << 11) | (func << 8) | (offset);
    volatile uint32 *base = ecam + off;
    uint32 id = base[0];
    
    // 100e:8086 is an e1000
    if(id == 0x100e8086){
    800067d8:	100e8937          	lui	s2,0x100e8
    800067dc:	08690913          	addi	s2,s2,134 # 100e8086 <_entry-0x6ff17f7a>
      // command and status register.
      // bit 0 : I/O access enable
      // bit 1 : memory access enable
      // bit 2 : enable mastering
      base[1] = 7;
    800067e0:	4b9d                	li	s7,7
      for(int i = 0; i < 6; i++){
        uint32 old = base[4+i];

        // writing all 1's to the BAR causes it to be
        // replaced with its size.
        base[4+i] = 0xffffffff;
    800067e2:	5afd                	li	s5,-1
        base[4+i] = old;
      }

      // tell the e1000 to reveal its registers at
      // physical address 0x40000000.
      base[4+0] = e1000_regs;
    800067e4:	40000b37          	lui	s6,0x40000
    800067e8:	6a09                	lui	s4,0x2
  for(int dev = 0; dev < 32; dev++){
    800067ea:	300409b7          	lui	s3,0x30040
    800067ee:	a821                	j	80006806 <pci_init+0x48>
      base[4+0] = e1000_regs;
    800067f0:	0166a823          	sw	s6,16(a3)

      e1000_init((uint32*)e1000_regs);
    800067f4:	40000537          	lui	a0,0x40000
    800067f8:	fffff097          	auipc	ra,0xfffff
    800067fc:	0f6080e7          	jalr	246(ra) # 800058ee <e1000_init>
  for(int dev = 0; dev < 32; dev++){
    80006800:	94d2                	add	s1,s1,s4
    80006802:	03348a63          	beq	s1,s3,80006836 <pci_init+0x78>
    volatile uint32 *base = ecam + off;
    80006806:	86a6                	mv	a3,s1
    uint32 id = base[0];
    80006808:	409c                	lw	a5,0(s1)
    8000680a:	2781                	sext.w	a5,a5
    if(id == 0x100e8086){
    8000680c:	ff279ae3          	bne	a5,s2,80006800 <pci_init+0x42>
      base[1] = 7;
    80006810:	0174a223          	sw	s7,4(s1) # 30000004 <_entry-0x4ffffffc>
      __sync_synchronize();
    80006814:	0ff0000f          	fence
      for(int i = 0; i < 6; i++){
    80006818:	01048793          	addi	a5,s1,16
    8000681c:	02848613          	addi	a2,s1,40
        uint32 old = base[4+i];
    80006820:	4398                	lw	a4,0(a5)
    80006822:	2701                	sext.w	a4,a4
        base[4+i] = 0xffffffff;
    80006824:	0157a023          	sw	s5,0(a5)
        __sync_synchronize();
    80006828:	0ff0000f          	fence
        base[4+i] = old;
    8000682c:	c398                	sw	a4,0(a5)
      for(int i = 0; i < 6; i++){
    8000682e:	0791                	addi	a5,a5,4
    80006830:	fec798e3          	bne	a5,a2,80006820 <pci_init+0x62>
    80006834:	bf75                	j	800067f0 <pci_init+0x32>
    }
  }
}
    80006836:	60a6                	ld	ra,72(sp)
    80006838:	6406                	ld	s0,64(sp)
    8000683a:	74e2                	ld	s1,56(sp)
    8000683c:	7942                	ld	s2,48(sp)
    8000683e:	79a2                	ld	s3,40(sp)
    80006840:	7a02                	ld	s4,32(sp)
    80006842:	6ae2                	ld	s5,24(sp)
    80006844:	6b42                	ld	s6,16(sp)
    80006846:	6ba2                	ld	s7,8(sp)
    80006848:	6161                	addi	sp,sp,80
    8000684a:	8082                	ret

000000008000684c <timerinit>:
// which arrive at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000684c:	1141                	addi	sp,sp,-16
    8000684e:	e422                	sd	s0,8(sp)
    80006850:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80006852:	f1402773          	csrr	a4,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80006856:	2701                	sext.w	a4,a4

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    80006858:	0037161b          	slliw	a2,a4,0x3
    8000685c:	020047b7          	lui	a5,0x2004
    80006860:	963e                	add	a2,a2,a5
    80006862:	0200c7b7          	lui	a5,0x200c
    80006866:	ff87b783          	ld	a5,-8(a5) # 200bff8 <_entry-0x7dff4008>
    8000686a:	000f46b7          	lui	a3,0xf4
    8000686e:	24068693          	addi	a3,a3,576 # f4240 <_entry-0x7ff0bdc0>
    80006872:	97b6                	add	a5,a5,a3
    80006874:	e21c                	sd	a5,0(a2)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80006876:	00271793          	slli	a5,a4,0x2
    8000687a:	97ba                	add	a5,a5,a4
    8000687c:	00379713          	slli	a4,a5,0x3
    80006880:	00019797          	auipc	a5,0x19
    80006884:	ac078793          	addi	a5,a5,-1344 # 8001f340 <timer_scratch>
    80006888:	97ba                	add	a5,a5,a4
  scratch[3] = CLINT_MTIMECMP(id);
    8000688a:	ef90                	sd	a2,24(a5)
  scratch[4] = interval;
    8000688c:	f394                	sd	a3,32(a5)
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000688e:	34079073          	csrw	mscratch,a5
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80006892:	fffff797          	auipc	a5,0xfffff
    80006896:	9de78793          	addi	a5,a5,-1570 # 80005270 <timervec>
    8000689a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000689e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    800068a2:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800068a6:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    800068aa:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    800068ae:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    800068b2:	30479073          	csrw	mie,a5
}
    800068b6:	6422                	ld	s0,8(sp)
    800068b8:	0141                	addi	sp,sp,16
    800068ba:	8082                	ret

00000000800068bc <start>:
{
    800068bc:	1141                	addi	sp,sp,-16
    800068be:	e406                	sd	ra,8(sp)
    800068c0:	e022                	sd	s0,0(sp)
    800068c2:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    800068c4:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    800068c8:	7779                	lui	a4,0xffffe
    800068ca:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffd727f>
    800068ce:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800068d0:	6705                	lui	a4,0x1
    800068d2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800068d6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800068d8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800068dc:	ffffa797          	auipc	a5,0xffffa
    800068e0:	a7478793          	addi	a5,a5,-1420 # 80000350 <main>
    800068e4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800068e8:	4781                	li	a5,0
    800068ea:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800068ee:	67c1                	lui	a5,0x10
    800068f0:	17fd                	addi	a5,a5,-1
    800068f2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800068f6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800068fa:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800068fe:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    80006902:	10479073          	csrw	sie,a5
  timerinit();
    80006906:	00000097          	auipc	ra,0x0
    8000690a:	f46080e7          	jalr	-186(ra) # 8000684c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    8000690e:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    80006912:	2781                	sext.w	a5,a5
  asm volatile("mv tp, %0" : : "r" (x));
    80006914:	823e                	mv	tp,a5
  asm volatile("mret");
    80006916:	30200073          	mret
}
    8000691a:	60a2                	ld	ra,8(sp)
    8000691c:	6402                	ld	s0,0(sp)
    8000691e:	0141                	addi	sp,sp,16
    80006920:	8082                	ret

0000000080006922 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80006922:	715d                	addi	sp,sp,-80
    80006924:	e486                	sd	ra,72(sp)
    80006926:	e0a2                	sd	s0,64(sp)
    80006928:	fc26                	sd	s1,56(sp)
    8000692a:	f84a                	sd	s2,48(sp)
    8000692c:	f44e                	sd	s3,40(sp)
    8000692e:	f052                	sd	s4,32(sp)
    80006930:	ec56                	sd	s5,24(sp)
    80006932:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80006934:	04c05663          	blez	a2,80006980 <consolewrite+0x5e>
    80006938:	8a2a                	mv	s4,a0
    8000693a:	892e                	mv	s2,a1
    8000693c:	89b2                	mv	s3,a2
    8000693e:	4481                	li	s1,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    80006940:	5afd                	li	s5,-1
    80006942:	4685                	li	a3,1
    80006944:	864a                	mv	a2,s2
    80006946:	85d2                	mv	a1,s4
    80006948:	fbf40513          	addi	a0,s0,-65
    8000694c:	ffffb097          	auipc	ra,0xffffb
    80006950:	086080e7          	jalr	134(ra) # 800019d2 <either_copyin>
    80006954:	01550c63          	beq	a0,s5,8000696c <consolewrite+0x4a>
      break;
    uartputc(c);
    80006958:	fbf44503          	lbu	a0,-65(s0)
    8000695c:	00000097          	auipc	ra,0x0
    80006960:	7d2080e7          	jalr	2002(ra) # 8000712e <uartputc>
  for(i = 0; i < n; i++){
    80006964:	2485                	addiw	s1,s1,1
    80006966:	0905                	addi	s2,s2,1
    80006968:	fc999de3          	bne	s3,s1,80006942 <consolewrite+0x20>
  }

  return i;
}
    8000696c:	8526                	mv	a0,s1
    8000696e:	60a6                	ld	ra,72(sp)
    80006970:	6406                	ld	s0,64(sp)
    80006972:	74e2                	ld	s1,56(sp)
    80006974:	7942                	ld	s2,48(sp)
    80006976:	79a2                	ld	s3,40(sp)
    80006978:	7a02                	ld	s4,32(sp)
    8000697a:	6ae2                	ld	s5,24(sp)
    8000697c:	6161                	addi	sp,sp,80
    8000697e:	8082                	ret
  for(i = 0; i < n; i++){
    80006980:	4481                	li	s1,0
    80006982:	b7ed                	j	8000696c <consolewrite+0x4a>

0000000080006984 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80006984:	7119                	addi	sp,sp,-128
    80006986:	fc86                	sd	ra,120(sp)
    80006988:	f8a2                	sd	s0,112(sp)
    8000698a:	f4a6                	sd	s1,104(sp)
    8000698c:	f0ca                	sd	s2,96(sp)
    8000698e:	ecce                	sd	s3,88(sp)
    80006990:	e8d2                	sd	s4,80(sp)
    80006992:	e4d6                	sd	s5,72(sp)
    80006994:	e0da                	sd	s6,64(sp)
    80006996:	fc5e                	sd	s7,56(sp)
    80006998:	f862                	sd	s8,48(sp)
    8000699a:	f466                	sd	s9,40(sp)
    8000699c:	f06a                	sd	s10,32(sp)
    8000699e:	ec6e                	sd	s11,24(sp)
    800069a0:	0100                	addi	s0,sp,128
    800069a2:	8caa                	mv	s9,a0
    800069a4:	8aae                	mv	s5,a1
    800069a6:	8a32                	mv	s4,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    800069a8:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    800069ac:	00021517          	auipc	a0,0x21
    800069b0:	ad450513          	addi	a0,a0,-1324 # 80027480 <cons>
    800069b4:	00001097          	auipc	ra,0x1
    800069b8:	940080e7          	jalr	-1728(ra) # 800072f4 <acquire>
  while(n > 0){
    800069bc:	09405663          	blez	s4,80006a48 <consoleread+0xc4>
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    800069c0:	00021497          	auipc	s1,0x21
    800069c4:	ac048493          	addi	s1,s1,-1344 # 80027480 <cons>
      if(myproc()->killed){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800069c8:	89a6                	mv	s3,s1
    800069ca:	00021917          	auipc	s2,0x21
    800069ce:	b4e90913          	addi	s2,s2,-1202 # 80027518 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF];

    if(c == C('D')){  // end-of-file
    800069d2:	4c11                	li	s8,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800069d4:	5d7d                	li	s10,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800069d6:	4da9                	li	s11,10
    while(cons.r == cons.w){
    800069d8:	0984a783          	lw	a5,152(s1)
    800069dc:	09c4a703          	lw	a4,156(s1)
    800069e0:	02f71463          	bne	a4,a5,80006a08 <consoleread+0x84>
      if(myproc()->killed){
    800069e4:	ffffa097          	auipc	ra,0xffffa
    800069e8:	51c080e7          	jalr	1308(ra) # 80000f00 <myproc>
    800069ec:	591c                	lw	a5,48(a0)
    800069ee:	eba5                	bnez	a5,80006a5e <consoleread+0xda>
      sleep(&cons.r, &cons.lock);
    800069f0:	85ce                	mv	a1,s3
    800069f2:	854a                	mv	a0,s2
    800069f4:	ffffb097          	auipc	ra,0xffffb
    800069f8:	d26080e7          	jalr	-730(ra) # 8000171a <sleep>
    while(cons.r == cons.w){
    800069fc:	0984a783          	lw	a5,152(s1)
    80006a00:	09c4a703          	lw	a4,156(s1)
    80006a04:	fef700e3          	beq	a4,a5,800069e4 <consoleread+0x60>
    c = cons.buf[cons.r++ % INPUT_BUF];
    80006a08:	0017871b          	addiw	a4,a5,1
    80006a0c:	08e4ac23          	sw	a4,152(s1)
    80006a10:	07f7f713          	andi	a4,a5,127
    80006a14:	9726                	add	a4,a4,s1
    80006a16:	01874703          	lbu	a4,24(a4)
    80006a1a:	00070b9b          	sext.w	s7,a4
    if(c == C('D')){  // end-of-file
    80006a1e:	078b8863          	beq	s7,s8,80006a8e <consoleread+0x10a>
    cbuf = c;
    80006a22:	f8e407a3          	sb	a4,-113(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80006a26:	4685                	li	a3,1
    80006a28:	f8f40613          	addi	a2,s0,-113
    80006a2c:	85d6                	mv	a1,s5
    80006a2e:	8566                	mv	a0,s9
    80006a30:	ffffb097          	auipc	ra,0xffffb
    80006a34:	f4c080e7          	jalr	-180(ra) # 8000197c <either_copyout>
    80006a38:	01a50863          	beq	a0,s10,80006a48 <consoleread+0xc4>
    dst++;
    80006a3c:	0a85                	addi	s5,s5,1
    --n;
    80006a3e:	3a7d                	addiw	s4,s4,-1
    if(c == '\n'){
    80006a40:	01bb8463          	beq	s7,s11,80006a48 <consoleread+0xc4>
  while(n > 0){
    80006a44:	f80a1ae3          	bnez	s4,800069d8 <consoleread+0x54>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80006a48:	00021517          	auipc	a0,0x21
    80006a4c:	a3850513          	addi	a0,a0,-1480 # 80027480 <cons>
    80006a50:	00001097          	auipc	ra,0x1
    80006a54:	958080e7          	jalr	-1704(ra) # 800073a8 <release>

  return target - n;
    80006a58:	414b053b          	subw	a0,s6,s4
    80006a5c:	a811                	j	80006a70 <consoleread+0xec>
        release(&cons.lock);
    80006a5e:	00021517          	auipc	a0,0x21
    80006a62:	a2250513          	addi	a0,a0,-1502 # 80027480 <cons>
    80006a66:	00001097          	auipc	ra,0x1
    80006a6a:	942080e7          	jalr	-1726(ra) # 800073a8 <release>
        return -1;
    80006a6e:	557d                	li	a0,-1
}
    80006a70:	70e6                	ld	ra,120(sp)
    80006a72:	7446                	ld	s0,112(sp)
    80006a74:	74a6                	ld	s1,104(sp)
    80006a76:	7906                	ld	s2,96(sp)
    80006a78:	69e6                	ld	s3,88(sp)
    80006a7a:	6a46                	ld	s4,80(sp)
    80006a7c:	6aa6                	ld	s5,72(sp)
    80006a7e:	6b06                	ld	s6,64(sp)
    80006a80:	7be2                	ld	s7,56(sp)
    80006a82:	7c42                	ld	s8,48(sp)
    80006a84:	7ca2                	ld	s9,40(sp)
    80006a86:	7d02                	ld	s10,32(sp)
    80006a88:	6de2                	ld	s11,24(sp)
    80006a8a:	6109                	addi	sp,sp,128
    80006a8c:	8082                	ret
      if(n < target){
    80006a8e:	000a071b          	sext.w	a4,s4
    80006a92:	fb677be3          	bleu	s6,a4,80006a48 <consoleread+0xc4>
        cons.r--;
    80006a96:	00021717          	auipc	a4,0x21
    80006a9a:	a8f72123          	sw	a5,-1406(a4) # 80027518 <cons+0x98>
    80006a9e:	b76d                	j	80006a48 <consoleread+0xc4>

0000000080006aa0 <consputc>:
{
    80006aa0:	1141                	addi	sp,sp,-16
    80006aa2:	e406                	sd	ra,8(sp)
    80006aa4:	e022                	sd	s0,0(sp)
    80006aa6:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80006aa8:	10000793          	li	a5,256
    80006aac:	00f50a63          	beq	a0,a5,80006ac0 <consputc+0x20>
    uartputc_sync(c);
    80006ab0:	00000097          	auipc	ra,0x0
    80006ab4:	58a080e7          	jalr	1418(ra) # 8000703a <uartputc_sync>
}
    80006ab8:	60a2                	ld	ra,8(sp)
    80006aba:	6402                	ld	s0,0(sp)
    80006abc:	0141                	addi	sp,sp,16
    80006abe:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    80006ac0:	4521                	li	a0,8
    80006ac2:	00000097          	auipc	ra,0x0
    80006ac6:	578080e7          	jalr	1400(ra) # 8000703a <uartputc_sync>
    80006aca:	02000513          	li	a0,32
    80006ace:	00000097          	auipc	ra,0x0
    80006ad2:	56c080e7          	jalr	1388(ra) # 8000703a <uartputc_sync>
    80006ad6:	4521                	li	a0,8
    80006ad8:	00000097          	auipc	ra,0x0
    80006adc:	562080e7          	jalr	1378(ra) # 8000703a <uartputc_sync>
    80006ae0:	bfe1                	j	80006ab8 <consputc+0x18>

0000000080006ae2 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80006ae2:	1101                	addi	sp,sp,-32
    80006ae4:	ec06                	sd	ra,24(sp)
    80006ae6:	e822                	sd	s0,16(sp)
    80006ae8:	e426                	sd	s1,8(sp)
    80006aea:	e04a                	sd	s2,0(sp)
    80006aec:	1000                	addi	s0,sp,32
    80006aee:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    80006af0:	00021517          	auipc	a0,0x21
    80006af4:	99050513          	addi	a0,a0,-1648 # 80027480 <cons>
    80006af8:	00000097          	auipc	ra,0x0
    80006afc:	7fc080e7          	jalr	2044(ra) # 800072f4 <acquire>

  switch(c){
    80006b00:	47c1                	li	a5,16
    80006b02:	12f48463          	beq	s1,a5,80006c2a <consoleintr+0x148>
    80006b06:	0297df63          	ble	s1,a5,80006b44 <consoleintr+0x62>
    80006b0a:	47d5                	li	a5,21
    80006b0c:	0af48863          	beq	s1,a5,80006bbc <consoleintr+0xda>
    80006b10:	07f00793          	li	a5,127
    80006b14:	02f49b63          	bne	s1,a5,80006b4a <consoleintr+0x68>
      consputc(BACKSPACE);
    }
    break;
  case C('H'): // Backspace
  case '\x7f':
    if(cons.e != cons.w){
    80006b18:	00021717          	auipc	a4,0x21
    80006b1c:	96870713          	addi	a4,a4,-1688 # 80027480 <cons>
    80006b20:	0a072783          	lw	a5,160(a4)
    80006b24:	09c72703          	lw	a4,156(a4)
    80006b28:	10f70563          	beq	a4,a5,80006c32 <consoleintr+0x150>
      cons.e--;
    80006b2c:	37fd                	addiw	a5,a5,-1
    80006b2e:	00021717          	auipc	a4,0x21
    80006b32:	9ef72923          	sw	a5,-1550(a4) # 80027520 <cons+0xa0>
      consputc(BACKSPACE);
    80006b36:	10000513          	li	a0,256
    80006b3a:	00000097          	auipc	ra,0x0
    80006b3e:	f66080e7          	jalr	-154(ra) # 80006aa0 <consputc>
    80006b42:	a8c5                	j	80006c32 <consoleintr+0x150>
  switch(c){
    80006b44:	47a1                	li	a5,8
    80006b46:	fcf489e3          	beq	s1,a5,80006b18 <consoleintr+0x36>
    }
    break;
  default:
    if(c != 0 && cons.e-cons.r < INPUT_BUF){
    80006b4a:	c4e5                	beqz	s1,80006c32 <consoleintr+0x150>
    80006b4c:	00021717          	auipc	a4,0x21
    80006b50:	93470713          	addi	a4,a4,-1740 # 80027480 <cons>
    80006b54:	0a072783          	lw	a5,160(a4)
    80006b58:	09872703          	lw	a4,152(a4)
    80006b5c:	9f99                	subw	a5,a5,a4
    80006b5e:	07f00713          	li	a4,127
    80006b62:	0cf76863          	bltu	a4,a5,80006c32 <consoleintr+0x150>
      c = (c == '\r') ? '\n' : c;
    80006b66:	47b5                	li	a5,13
    80006b68:	0ef48363          	beq	s1,a5,80006c4e <consoleintr+0x16c>

      // echo back to the user.
      consputc(c);
    80006b6c:	8526                	mv	a0,s1
    80006b6e:	00000097          	auipc	ra,0x0
    80006b72:	f32080e7          	jalr	-206(ra) # 80006aa0 <consputc>

      // store for consumption by consoleread().
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80006b76:	00021797          	auipc	a5,0x21
    80006b7a:	90a78793          	addi	a5,a5,-1782 # 80027480 <cons>
    80006b7e:	0a07a703          	lw	a4,160(a5)
    80006b82:	0017069b          	addiw	a3,a4,1
    80006b86:	0006861b          	sext.w	a2,a3
    80006b8a:	0ad7a023          	sw	a3,160(a5)
    80006b8e:	07f77713          	andi	a4,a4,127
    80006b92:	97ba                	add	a5,a5,a4
    80006b94:	00978c23          	sb	s1,24(a5)

      if(c == '\n' || c == C('D') || cons.e == cons.r+INPUT_BUF){
    80006b98:	47a9                	li	a5,10
    80006b9a:	0ef48163          	beq	s1,a5,80006c7c <consoleintr+0x19a>
    80006b9e:	4791                	li	a5,4
    80006ba0:	0cf48e63          	beq	s1,a5,80006c7c <consoleintr+0x19a>
    80006ba4:	00021797          	auipc	a5,0x21
    80006ba8:	8dc78793          	addi	a5,a5,-1828 # 80027480 <cons>
    80006bac:	0987a783          	lw	a5,152(a5)
    80006bb0:	0807879b          	addiw	a5,a5,128
    80006bb4:	06f61f63          	bne	a2,a5,80006c32 <consoleintr+0x150>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80006bb8:	863e                	mv	a2,a5
    80006bba:	a0c9                	j	80006c7c <consoleintr+0x19a>
    while(cons.e != cons.w &&
    80006bbc:	00021717          	auipc	a4,0x21
    80006bc0:	8c470713          	addi	a4,a4,-1852 # 80027480 <cons>
    80006bc4:	0a072783          	lw	a5,160(a4)
    80006bc8:	09c72703          	lw	a4,156(a4)
    80006bcc:	06f70363          	beq	a4,a5,80006c32 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80006bd0:	37fd                	addiw	a5,a5,-1
    80006bd2:	0007871b          	sext.w	a4,a5
    80006bd6:	07f7f793          	andi	a5,a5,127
    80006bda:	00021697          	auipc	a3,0x21
    80006bde:	8a668693          	addi	a3,a3,-1882 # 80027480 <cons>
    80006be2:	97b6                	add	a5,a5,a3
    while(cons.e != cons.w &&
    80006be4:	0187c683          	lbu	a3,24(a5)
    80006be8:	47a9                	li	a5,10
      cons.e--;
    80006bea:	00021497          	auipc	s1,0x21
    80006bee:	89648493          	addi	s1,s1,-1898 # 80027480 <cons>
    while(cons.e != cons.w &&
    80006bf2:	4929                	li	s2,10
    80006bf4:	02f68f63          	beq	a3,a5,80006c32 <consoleintr+0x150>
      cons.e--;
    80006bf8:	0ae4a023          	sw	a4,160(s1)
      consputc(BACKSPACE);
    80006bfc:	10000513          	li	a0,256
    80006c00:	00000097          	auipc	ra,0x0
    80006c04:	ea0080e7          	jalr	-352(ra) # 80006aa0 <consputc>
    while(cons.e != cons.w &&
    80006c08:	0a04a783          	lw	a5,160(s1)
    80006c0c:	09c4a703          	lw	a4,156(s1)
    80006c10:	02f70163          	beq	a4,a5,80006c32 <consoleintr+0x150>
          cons.buf[(cons.e-1) % INPUT_BUF] != '\n'){
    80006c14:	37fd                	addiw	a5,a5,-1
    80006c16:	0007871b          	sext.w	a4,a5
    80006c1a:	07f7f793          	andi	a5,a5,127
    80006c1e:	97a6                	add	a5,a5,s1
    while(cons.e != cons.w &&
    80006c20:	0187c783          	lbu	a5,24(a5)
    80006c24:	fd279ae3          	bne	a5,s2,80006bf8 <consoleintr+0x116>
    80006c28:	a029                	j	80006c32 <consoleintr+0x150>
    procdump();
    80006c2a:	ffffb097          	auipc	ra,0xffffb
    80006c2e:	dfe080e7          	jalr	-514(ra) # 80001a28 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    80006c32:	00021517          	auipc	a0,0x21
    80006c36:	84e50513          	addi	a0,a0,-1970 # 80027480 <cons>
    80006c3a:	00000097          	auipc	ra,0x0
    80006c3e:	76e080e7          	jalr	1902(ra) # 800073a8 <release>
}
    80006c42:	60e2                	ld	ra,24(sp)
    80006c44:	6442                	ld	s0,16(sp)
    80006c46:	64a2                	ld	s1,8(sp)
    80006c48:	6902                	ld	s2,0(sp)
    80006c4a:	6105                	addi	sp,sp,32
    80006c4c:	8082                	ret
      consputc(c);
    80006c4e:	4529                	li	a0,10
    80006c50:	00000097          	auipc	ra,0x0
    80006c54:	e50080e7          	jalr	-432(ra) # 80006aa0 <consputc>
      cons.buf[cons.e++ % INPUT_BUF] = c;
    80006c58:	00021797          	auipc	a5,0x21
    80006c5c:	82878793          	addi	a5,a5,-2008 # 80027480 <cons>
    80006c60:	0a07a703          	lw	a4,160(a5)
    80006c64:	0017069b          	addiw	a3,a4,1
    80006c68:	0006861b          	sext.w	a2,a3
    80006c6c:	0ad7a023          	sw	a3,160(a5)
    80006c70:	07f77713          	andi	a4,a4,127
    80006c74:	97ba                	add	a5,a5,a4
    80006c76:	4729                	li	a4,10
    80006c78:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80006c7c:	00021797          	auipc	a5,0x21
    80006c80:	8ac7a023          	sw	a2,-1888(a5) # 8002751c <cons+0x9c>
        wakeup(&cons.r);
    80006c84:	00021517          	auipc	a0,0x21
    80006c88:	89450513          	addi	a0,a0,-1900 # 80027518 <cons+0x98>
    80006c8c:	ffffb097          	auipc	ra,0xffffb
    80006c90:	c14080e7          	jalr	-1004(ra) # 800018a0 <wakeup>
    80006c94:	bf79                	j	80006c32 <consoleintr+0x150>

0000000080006c96 <consoleinit>:

void
consoleinit(void)
{
    80006c96:	1141                	addi	sp,sp,-16
    80006c98:	e406                	sd	ra,8(sp)
    80006c9a:	e022                	sd	s0,0(sp)
    80006c9c:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80006c9e:	00003597          	auipc	a1,0x3
    80006ca2:	b4a58593          	addi	a1,a1,-1206 # 800097e8 <syscalls+0x460>
    80006ca6:	00020517          	auipc	a0,0x20
    80006caa:	7da50513          	addi	a0,a0,2010 # 80027480 <cons>
    80006cae:	00000097          	auipc	ra,0x0
    80006cb2:	5b6080e7          	jalr	1462(ra) # 80007264 <initlock>

  uartinit();
    80006cb6:	00000097          	auipc	ra,0x0
    80006cba:	334080e7          	jalr	820(ra) # 80006fea <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80006cbe:	00013797          	auipc	a5,0x13
    80006cc2:	41278793          	addi	a5,a5,1042 # 8001a0d0 <devsw>
    80006cc6:	00000717          	auipc	a4,0x0
    80006cca:	cbe70713          	addi	a4,a4,-834 # 80006984 <consoleread>
    80006cce:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    80006cd0:	00000717          	auipc	a4,0x0
    80006cd4:	c5270713          	addi	a4,a4,-942 # 80006922 <consolewrite>
    80006cd8:	ef98                	sd	a4,24(a5)
}
    80006cda:	60a2                	ld	ra,8(sp)
    80006cdc:	6402                	ld	s0,0(sp)
    80006cde:	0141                	addi	sp,sp,16
    80006ce0:	8082                	ret

0000000080006ce2 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    80006ce2:	7179                	addi	sp,sp,-48
    80006ce4:	f406                	sd	ra,40(sp)
    80006ce6:	f022                	sd	s0,32(sp)
    80006ce8:	ec26                	sd	s1,24(sp)
    80006cea:	e84a                	sd	s2,16(sp)
    80006cec:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    80006cee:	c219                	beqz	a2,80006cf4 <printint+0x12>
    80006cf0:	00054d63          	bltz	a0,80006d0a <printint+0x28>
    x = -xx;
  else
    x = xx;
    80006cf4:	2501                	sext.w	a0,a0
    80006cf6:	4881                	li	a7,0
    80006cf8:	fd040713          	addi	a4,s0,-48

  i = 0;
    80006cfc:	4601                	li	a2,0
  do {
    buf[i++] = digits[x % base];
    80006cfe:	2581                	sext.w	a1,a1
    80006d00:	00003817          	auipc	a6,0x3
    80006d04:	af080813          	addi	a6,a6,-1296 # 800097f0 <digits>
    80006d08:	a801                	j	80006d18 <printint+0x36>
    x = -xx;
    80006d0a:	40a0053b          	negw	a0,a0
    80006d0e:	2501                	sext.w	a0,a0
  if(sign && (sign = xx < 0))
    80006d10:	4885                	li	a7,1
    x = -xx;
    80006d12:	b7dd                	j	80006cf8 <printint+0x16>
  } while((x /= base) != 0);
    80006d14:	853e                	mv	a0,a5
    buf[i++] = digits[x % base];
    80006d16:	8636                	mv	a2,a3
    80006d18:	0016069b          	addiw	a3,a2,1
    80006d1c:	02b577bb          	remuw	a5,a0,a1
    80006d20:	1782                	slli	a5,a5,0x20
    80006d22:	9381                	srli	a5,a5,0x20
    80006d24:	97c2                	add	a5,a5,a6
    80006d26:	0007c783          	lbu	a5,0(a5)
    80006d2a:	00f70023          	sb	a5,0(a4)
  } while((x /= base) != 0);
    80006d2e:	0705                	addi	a4,a4,1
    80006d30:	02b557bb          	divuw	a5,a0,a1
    80006d34:	feb570e3          	bleu	a1,a0,80006d14 <printint+0x32>

  if(sign)
    80006d38:	00088b63          	beqz	a7,80006d4e <printint+0x6c>
    buf[i++] = '-';
    80006d3c:	fe040793          	addi	a5,s0,-32
    80006d40:	96be                	add	a3,a3,a5
    80006d42:	02d00793          	li	a5,45
    80006d46:	fef68823          	sb	a5,-16(a3)
    80006d4a:	0026069b          	addiw	a3,a2,2

  while(--i >= 0)
    80006d4e:	02d05763          	blez	a3,80006d7c <printint+0x9a>
    80006d52:	fd040793          	addi	a5,s0,-48
    80006d56:	00d784b3          	add	s1,a5,a3
    80006d5a:	fff78913          	addi	s2,a5,-1
    80006d5e:	9936                	add	s2,s2,a3
    80006d60:	36fd                	addiw	a3,a3,-1
    80006d62:	1682                	slli	a3,a3,0x20
    80006d64:	9281                	srli	a3,a3,0x20
    80006d66:	40d90933          	sub	s2,s2,a3
    consputc(buf[i]);
    80006d6a:	fff4c503          	lbu	a0,-1(s1)
    80006d6e:	00000097          	auipc	ra,0x0
    80006d72:	d32080e7          	jalr	-718(ra) # 80006aa0 <consputc>
  while(--i >= 0)
    80006d76:	14fd                	addi	s1,s1,-1
    80006d78:	ff2499e3          	bne	s1,s2,80006d6a <printint+0x88>
}
    80006d7c:	70a2                	ld	ra,40(sp)
    80006d7e:	7402                	ld	s0,32(sp)
    80006d80:	64e2                	ld	s1,24(sp)
    80006d82:	6942                	ld	s2,16(sp)
    80006d84:	6145                	addi	sp,sp,48
    80006d86:	8082                	ret

0000000080006d88 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80006d88:	1101                	addi	sp,sp,-32
    80006d8a:	ec06                	sd	ra,24(sp)
    80006d8c:	e822                	sd	s0,16(sp)
    80006d8e:	e426                	sd	s1,8(sp)
    80006d90:	1000                	addi	s0,sp,32
    80006d92:	84aa                	mv	s1,a0
  pr.locking = 0;
    80006d94:	00020797          	auipc	a5,0x20
    80006d98:	7a07a623          	sw	zero,1964(a5) # 80027540 <pr+0x18>
  printf("panic: ");
    80006d9c:	00003517          	auipc	a0,0x3
    80006da0:	a6c50513          	addi	a0,a0,-1428 # 80009808 <digits+0x18>
    80006da4:	00000097          	auipc	ra,0x0
    80006da8:	02e080e7          	jalr	46(ra) # 80006dd2 <printf>
  printf(s);
    80006dac:	8526                	mv	a0,s1
    80006dae:	00000097          	auipc	ra,0x0
    80006db2:	024080e7          	jalr	36(ra) # 80006dd2 <printf>
  printf("\n");
    80006db6:	00002517          	auipc	a0,0x2
    80006dba:	29250513          	addi	a0,a0,658 # 80009048 <etext+0x48>
    80006dbe:	00000097          	auipc	ra,0x0
    80006dc2:	014080e7          	jalr	20(ra) # 80006dd2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    80006dc6:	4785                	li	a5,1
    80006dc8:	00003717          	auipc	a4,0x3
    80006dcc:	26f72423          	sw	a5,616(a4) # 8000a030 <panicked>
  for(;;)
    80006dd0:	a001                	j	80006dd0 <panic+0x48>

0000000080006dd2 <printf>:
{
    80006dd2:	7131                	addi	sp,sp,-192
    80006dd4:	fc86                	sd	ra,120(sp)
    80006dd6:	f8a2                	sd	s0,112(sp)
    80006dd8:	f4a6                	sd	s1,104(sp)
    80006dda:	f0ca                	sd	s2,96(sp)
    80006ddc:	ecce                	sd	s3,88(sp)
    80006dde:	e8d2                	sd	s4,80(sp)
    80006de0:	e4d6                	sd	s5,72(sp)
    80006de2:	e0da                	sd	s6,64(sp)
    80006de4:	fc5e                	sd	s7,56(sp)
    80006de6:	f862                	sd	s8,48(sp)
    80006de8:	f466                	sd	s9,40(sp)
    80006dea:	f06a                	sd	s10,32(sp)
    80006dec:	ec6e                	sd	s11,24(sp)
    80006dee:	0100                	addi	s0,sp,128
    80006df0:	8aaa                	mv	s5,a0
    80006df2:	e40c                	sd	a1,8(s0)
    80006df4:	e810                	sd	a2,16(s0)
    80006df6:	ec14                	sd	a3,24(s0)
    80006df8:	f018                	sd	a4,32(s0)
    80006dfa:	f41c                	sd	a5,40(s0)
    80006dfc:	03043823          	sd	a6,48(s0)
    80006e00:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    80006e04:	00020797          	auipc	a5,0x20
    80006e08:	72478793          	addi	a5,a5,1828 # 80027528 <pr>
    80006e0c:	0187ad83          	lw	s11,24(a5)
  if(locking)
    80006e10:	020d9b63          	bnez	s11,80006e46 <printf+0x74>
  if (fmt == 0)
    80006e14:	020a8f63          	beqz	s5,80006e52 <printf+0x80>
  va_start(ap, fmt);
    80006e18:	00840793          	addi	a5,s0,8
    80006e1c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006e20:	000ac503          	lbu	a0,0(s5)
    80006e24:	16050063          	beqz	a0,80006f84 <printf+0x1b2>
    80006e28:	4481                	li	s1,0
    if(c != '%'){
    80006e2a:	02500a13          	li	s4,37
    switch(c){
    80006e2e:	07000b13          	li	s6,112
  consputc('x');
    80006e32:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006e34:	00003b97          	auipc	s7,0x3
    80006e38:	9bcb8b93          	addi	s7,s7,-1604 # 800097f0 <digits>
    switch(c){
    80006e3c:	07300c93          	li	s9,115
    80006e40:	06400c13          	li	s8,100
    80006e44:	a815                	j	80006e78 <printf+0xa6>
    acquire(&pr.lock);
    80006e46:	853e                	mv	a0,a5
    80006e48:	00000097          	auipc	ra,0x0
    80006e4c:	4ac080e7          	jalr	1196(ra) # 800072f4 <acquire>
    80006e50:	b7d1                	j	80006e14 <printf+0x42>
    panic("null fmt");
    80006e52:	00003517          	auipc	a0,0x3
    80006e56:	9c650513          	addi	a0,a0,-1594 # 80009818 <digits+0x28>
    80006e5a:	00000097          	auipc	ra,0x0
    80006e5e:	f2e080e7          	jalr	-210(ra) # 80006d88 <panic>
      consputc(c);
    80006e62:	00000097          	auipc	ra,0x0
    80006e66:	c3e080e7          	jalr	-962(ra) # 80006aa0 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80006e6a:	2485                	addiw	s1,s1,1
    80006e6c:	009a87b3          	add	a5,s5,s1
    80006e70:	0007c503          	lbu	a0,0(a5)
    80006e74:	10050863          	beqz	a0,80006f84 <printf+0x1b2>
    if(c != '%'){
    80006e78:	ff4515e3          	bne	a0,s4,80006e62 <printf+0x90>
    c = fmt[++i] & 0xff;
    80006e7c:	2485                	addiw	s1,s1,1
    80006e7e:	009a87b3          	add	a5,s5,s1
    80006e82:	0007c783          	lbu	a5,0(a5)
    80006e86:	0007891b          	sext.w	s2,a5
    if(c == 0)
    80006e8a:	0e090d63          	beqz	s2,80006f84 <printf+0x1b2>
    switch(c){
    80006e8e:	05678a63          	beq	a5,s6,80006ee2 <printf+0x110>
    80006e92:	02fb7663          	bleu	a5,s6,80006ebe <printf+0xec>
    80006e96:	09978963          	beq	a5,s9,80006f28 <printf+0x156>
    80006e9a:	07800713          	li	a4,120
    80006e9e:	0ce79863          	bne	a5,a4,80006f6e <printf+0x19c>
      printint(va_arg(ap, int), 16, 1);
    80006ea2:	f8843783          	ld	a5,-120(s0)
    80006ea6:	00878713          	addi	a4,a5,8
    80006eaa:	f8e43423          	sd	a4,-120(s0)
    80006eae:	4605                	li	a2,1
    80006eb0:	85ea                	mv	a1,s10
    80006eb2:	4388                	lw	a0,0(a5)
    80006eb4:	00000097          	auipc	ra,0x0
    80006eb8:	e2e080e7          	jalr	-466(ra) # 80006ce2 <printint>
      break;
    80006ebc:	b77d                	j	80006e6a <printf+0x98>
    switch(c){
    80006ebe:	0b478263          	beq	a5,s4,80006f62 <printf+0x190>
    80006ec2:	0b879663          	bne	a5,s8,80006f6e <printf+0x19c>
      printint(va_arg(ap, int), 10, 1);
    80006ec6:	f8843783          	ld	a5,-120(s0)
    80006eca:	00878713          	addi	a4,a5,8
    80006ece:	f8e43423          	sd	a4,-120(s0)
    80006ed2:	4605                	li	a2,1
    80006ed4:	45a9                	li	a1,10
    80006ed6:	4388                	lw	a0,0(a5)
    80006ed8:	00000097          	auipc	ra,0x0
    80006edc:	e0a080e7          	jalr	-502(ra) # 80006ce2 <printint>
      break;
    80006ee0:	b769                	j	80006e6a <printf+0x98>
      printptr(va_arg(ap, uint64));
    80006ee2:	f8843783          	ld	a5,-120(s0)
    80006ee6:	00878713          	addi	a4,a5,8
    80006eea:	f8e43423          	sd	a4,-120(s0)
    80006eee:	0007b983          	ld	s3,0(a5)
  consputc('0');
    80006ef2:	03000513          	li	a0,48
    80006ef6:	00000097          	auipc	ra,0x0
    80006efa:	baa080e7          	jalr	-1110(ra) # 80006aa0 <consputc>
  consputc('x');
    80006efe:	07800513          	li	a0,120
    80006f02:	00000097          	auipc	ra,0x0
    80006f06:	b9e080e7          	jalr	-1122(ra) # 80006aa0 <consputc>
    80006f0a:	896a                	mv	s2,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    80006f0c:	03c9d793          	srli	a5,s3,0x3c
    80006f10:	97de                	add	a5,a5,s7
    80006f12:	0007c503          	lbu	a0,0(a5)
    80006f16:	00000097          	auipc	ra,0x0
    80006f1a:	b8a080e7          	jalr	-1142(ra) # 80006aa0 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80006f1e:	0992                	slli	s3,s3,0x4
    80006f20:	397d                	addiw	s2,s2,-1
    80006f22:	fe0915e3          	bnez	s2,80006f0c <printf+0x13a>
    80006f26:	b791                	j	80006e6a <printf+0x98>
      if((s = va_arg(ap, char*)) == 0)
    80006f28:	f8843783          	ld	a5,-120(s0)
    80006f2c:	00878713          	addi	a4,a5,8
    80006f30:	f8e43423          	sd	a4,-120(s0)
    80006f34:	0007b903          	ld	s2,0(a5)
    80006f38:	00090e63          	beqz	s2,80006f54 <printf+0x182>
      for(; *s; s++)
    80006f3c:	00094503          	lbu	a0,0(s2)
    80006f40:	d50d                	beqz	a0,80006e6a <printf+0x98>
        consputc(*s);
    80006f42:	00000097          	auipc	ra,0x0
    80006f46:	b5e080e7          	jalr	-1186(ra) # 80006aa0 <consputc>
      for(; *s; s++)
    80006f4a:	0905                	addi	s2,s2,1
    80006f4c:	00094503          	lbu	a0,0(s2)
    80006f50:	f96d                	bnez	a0,80006f42 <printf+0x170>
    80006f52:	bf21                	j	80006e6a <printf+0x98>
        s = "(null)";
    80006f54:	00003917          	auipc	s2,0x3
    80006f58:	8bc90913          	addi	s2,s2,-1860 # 80009810 <digits+0x20>
      for(; *s; s++)
    80006f5c:	02800513          	li	a0,40
    80006f60:	b7cd                	j	80006f42 <printf+0x170>
      consputc('%');
    80006f62:	8552                	mv	a0,s4
    80006f64:	00000097          	auipc	ra,0x0
    80006f68:	b3c080e7          	jalr	-1220(ra) # 80006aa0 <consputc>
      break;
    80006f6c:	bdfd                	j	80006e6a <printf+0x98>
      consputc('%');
    80006f6e:	8552                	mv	a0,s4
    80006f70:	00000097          	auipc	ra,0x0
    80006f74:	b30080e7          	jalr	-1232(ra) # 80006aa0 <consputc>
      consputc(c);
    80006f78:	854a                	mv	a0,s2
    80006f7a:	00000097          	auipc	ra,0x0
    80006f7e:	b26080e7          	jalr	-1242(ra) # 80006aa0 <consputc>
      break;
    80006f82:	b5e5                	j	80006e6a <printf+0x98>
  if(locking)
    80006f84:	020d9163          	bnez	s11,80006fa6 <printf+0x1d4>
}
    80006f88:	70e6                	ld	ra,120(sp)
    80006f8a:	7446                	ld	s0,112(sp)
    80006f8c:	74a6                	ld	s1,104(sp)
    80006f8e:	7906                	ld	s2,96(sp)
    80006f90:	69e6                	ld	s3,88(sp)
    80006f92:	6a46                	ld	s4,80(sp)
    80006f94:	6aa6                	ld	s5,72(sp)
    80006f96:	6b06                	ld	s6,64(sp)
    80006f98:	7be2                	ld	s7,56(sp)
    80006f9a:	7c42                	ld	s8,48(sp)
    80006f9c:	7ca2                	ld	s9,40(sp)
    80006f9e:	7d02                	ld	s10,32(sp)
    80006fa0:	6de2                	ld	s11,24(sp)
    80006fa2:	6129                	addi	sp,sp,192
    80006fa4:	8082                	ret
    release(&pr.lock);
    80006fa6:	00020517          	auipc	a0,0x20
    80006faa:	58250513          	addi	a0,a0,1410 # 80027528 <pr>
    80006fae:	00000097          	auipc	ra,0x0
    80006fb2:	3fa080e7          	jalr	1018(ra) # 800073a8 <release>
}
    80006fb6:	bfc9                	j	80006f88 <printf+0x1b6>

0000000080006fb8 <printfinit>:
    ;
}

void
printfinit(void)
{
    80006fb8:	1101                	addi	sp,sp,-32
    80006fba:	ec06                	sd	ra,24(sp)
    80006fbc:	e822                	sd	s0,16(sp)
    80006fbe:	e426                	sd	s1,8(sp)
    80006fc0:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80006fc2:	00020497          	auipc	s1,0x20
    80006fc6:	56648493          	addi	s1,s1,1382 # 80027528 <pr>
    80006fca:	00003597          	auipc	a1,0x3
    80006fce:	85e58593          	addi	a1,a1,-1954 # 80009828 <digits+0x38>
    80006fd2:	8526                	mv	a0,s1
    80006fd4:	00000097          	auipc	ra,0x0
    80006fd8:	290080e7          	jalr	656(ra) # 80007264 <initlock>
  pr.locking = 1;
    80006fdc:	4785                	li	a5,1
    80006fde:	cc9c                	sw	a5,24(s1)
}
    80006fe0:	60e2                	ld	ra,24(sp)
    80006fe2:	6442                	ld	s0,16(sp)
    80006fe4:	64a2                	ld	s1,8(sp)
    80006fe6:	6105                	addi	sp,sp,32
    80006fe8:	8082                	ret

0000000080006fea <uartinit>:

void uartstart();

void
uartinit(void)
{
    80006fea:	1141                	addi	sp,sp,-16
    80006fec:	e406                	sd	ra,8(sp)
    80006fee:	e022                	sd	s0,0(sp)
    80006ff0:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80006ff2:	100007b7          	lui	a5,0x10000
    80006ff6:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    80006ffa:	f8000713          	li	a4,-128
    80006ffe:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80007002:	470d                	li	a4,3
    80007004:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80007008:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    8000700c:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    80007010:	469d                	li	a3,7
    80007012:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80007016:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    8000701a:	00003597          	auipc	a1,0x3
    8000701e:	81658593          	addi	a1,a1,-2026 # 80009830 <digits+0x40>
    80007022:	00020517          	auipc	a0,0x20
    80007026:	52650513          	addi	a0,a0,1318 # 80027548 <uart_tx_lock>
    8000702a:	00000097          	auipc	ra,0x0
    8000702e:	23a080e7          	jalr	570(ra) # 80007264 <initlock>
}
    80007032:	60a2                	ld	ra,8(sp)
    80007034:	6402                	ld	s0,0(sp)
    80007036:	0141                	addi	sp,sp,16
    80007038:	8082                	ret

000000008000703a <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    8000703a:	1101                	addi	sp,sp,-32
    8000703c:	ec06                	sd	ra,24(sp)
    8000703e:	e822                	sd	s0,16(sp)
    80007040:	e426                	sd	s1,8(sp)
    80007042:	1000                	addi	s0,sp,32
    80007044:	84aa                	mv	s1,a0
  push_off();
    80007046:	00000097          	auipc	ra,0x0
    8000704a:	262080e7          	jalr	610(ra) # 800072a8 <push_off>

  if(panicked){
    8000704e:	00003797          	auipc	a5,0x3
    80007052:	fe278793          	addi	a5,a5,-30 # 8000a030 <panicked>
    80007056:	439c                	lw	a5,0(a5)
    80007058:	2781                	sext.w	a5,a5
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000705a:	10000737          	lui	a4,0x10000
  if(panicked){
    8000705e:	c391                	beqz	a5,80007062 <uartputc_sync+0x28>
    for(;;)
    80007060:	a001                	j	80007060 <uartputc_sync+0x26>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80007062:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80007066:	0ff7f793          	andi	a5,a5,255
    8000706a:	0207f793          	andi	a5,a5,32
    8000706e:	dbf5                	beqz	a5,80007062 <uartputc_sync+0x28>
    ;
  WriteReg(THR, c);
    80007070:	0ff4f793          	andi	a5,s1,255
    80007074:	10000737          	lui	a4,0x10000
    80007078:	00f70023          	sb	a5,0(a4) # 10000000 <_entry-0x70000000>

  pop_off();
    8000707c:	00000097          	auipc	ra,0x0
    80007080:	2cc080e7          	jalr	716(ra) # 80007348 <pop_off>
}
    80007084:	60e2                	ld	ra,24(sp)
    80007086:	6442                	ld	s0,16(sp)
    80007088:	64a2                	ld	s1,8(sp)
    8000708a:	6105                	addi	sp,sp,32
    8000708c:	8082                	ret

000000008000708e <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000708e:	00003797          	auipc	a5,0x3
    80007092:	faa78793          	addi	a5,a5,-86 # 8000a038 <uart_tx_r>
    80007096:	639c                	ld	a5,0(a5)
    80007098:	00003717          	auipc	a4,0x3
    8000709c:	fa870713          	addi	a4,a4,-88 # 8000a040 <uart_tx_w>
    800070a0:	6318                	ld	a4,0(a4)
    800070a2:	08f70563          	beq	a4,a5,8000712c <uartstart+0x9e>
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800070a6:	10000737          	lui	a4,0x10000
    800070aa:	00574703          	lbu	a4,5(a4) # 10000005 <_entry-0x6ffffffb>
    800070ae:	0ff77713          	andi	a4,a4,255
    800070b2:	02077713          	andi	a4,a4,32
    800070b6:	cb3d                	beqz	a4,8000712c <uartstart+0x9e>
{
    800070b8:	7139                	addi	sp,sp,-64
    800070ba:	fc06                	sd	ra,56(sp)
    800070bc:	f822                	sd	s0,48(sp)
    800070be:	f426                	sd	s1,40(sp)
    800070c0:	f04a                	sd	s2,32(sp)
    800070c2:	ec4e                	sd	s3,24(sp)
    800070c4:	e852                	sd	s4,16(sp)
    800070c6:	e456                	sd	s5,8(sp)
    800070c8:	0080                	addi	s0,sp,64
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800070ca:	00020a17          	auipc	s4,0x20
    800070ce:	47ea0a13          	addi	s4,s4,1150 # 80027548 <uart_tx_lock>
    uart_tx_r += 1;
    800070d2:	00003497          	auipc	s1,0x3
    800070d6:	f6648493          	addi	s1,s1,-154 # 8000a038 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800070da:	10000937          	lui	s2,0x10000
    if(uart_tx_w == uart_tx_r){
    800070de:	00003997          	auipc	s3,0x3
    800070e2:	f6298993          	addi	s3,s3,-158 # 8000a040 <uart_tx_w>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800070e6:	01f7f713          	andi	a4,a5,31
    800070ea:	9752                	add	a4,a4,s4
    800070ec:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    800070f0:	0785                	addi	a5,a5,1
    800070f2:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800070f4:	8526                	mv	a0,s1
    800070f6:	ffffa097          	auipc	ra,0xffffa
    800070fa:	7aa080e7          	jalr	1962(ra) # 800018a0 <wakeup>
    WriteReg(THR, c);
    800070fe:	01590023          	sb	s5,0(s2) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80007102:	609c                	ld	a5,0(s1)
    80007104:	0009b703          	ld	a4,0(s3)
    80007108:	00f70963          	beq	a4,a5,8000711a <uartstart+0x8c>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000710c:	00594703          	lbu	a4,5(s2)
    80007110:	0ff77713          	andi	a4,a4,255
    80007114:	02077713          	andi	a4,a4,32
    80007118:	f779                	bnez	a4,800070e6 <uartstart+0x58>
  }
}
    8000711a:	70e2                	ld	ra,56(sp)
    8000711c:	7442                	ld	s0,48(sp)
    8000711e:	74a2                	ld	s1,40(sp)
    80007120:	7902                	ld	s2,32(sp)
    80007122:	69e2                	ld	s3,24(sp)
    80007124:	6a42                	ld	s4,16(sp)
    80007126:	6aa2                	ld	s5,8(sp)
    80007128:	6121                	addi	sp,sp,64
    8000712a:	8082                	ret
    8000712c:	8082                	ret

000000008000712e <uartputc>:
{
    8000712e:	7179                	addi	sp,sp,-48
    80007130:	f406                	sd	ra,40(sp)
    80007132:	f022                	sd	s0,32(sp)
    80007134:	ec26                	sd	s1,24(sp)
    80007136:	e84a                	sd	s2,16(sp)
    80007138:	e44e                	sd	s3,8(sp)
    8000713a:	e052                	sd	s4,0(sp)
    8000713c:	1800                	addi	s0,sp,48
    8000713e:	89aa                	mv	s3,a0
  acquire(&uart_tx_lock);
    80007140:	00020517          	auipc	a0,0x20
    80007144:	40850513          	addi	a0,a0,1032 # 80027548 <uart_tx_lock>
    80007148:	00000097          	auipc	ra,0x0
    8000714c:	1ac080e7          	jalr	428(ra) # 800072f4 <acquire>
  if(panicked){
    80007150:	00003797          	auipc	a5,0x3
    80007154:	ee078793          	addi	a5,a5,-288 # 8000a030 <panicked>
    80007158:	439c                	lw	a5,0(a5)
    8000715a:	2781                	sext.w	a5,a5
    8000715c:	c391                	beqz	a5,80007160 <uartputc+0x32>
    for(;;)
    8000715e:	a001                	j	8000715e <uartputc+0x30>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80007160:	00003797          	auipc	a5,0x3
    80007164:	ee078793          	addi	a5,a5,-288 # 8000a040 <uart_tx_w>
    80007168:	639c                	ld	a5,0(a5)
    8000716a:	00003717          	auipc	a4,0x3
    8000716e:	ece70713          	addi	a4,a4,-306 # 8000a038 <uart_tx_r>
    80007172:	6318                	ld	a4,0(a4)
    80007174:	02070713          	addi	a4,a4,32
    80007178:	02f71b63          	bne	a4,a5,800071ae <uartputc+0x80>
      sleep(&uart_tx_r, &uart_tx_lock);
    8000717c:	00020a17          	auipc	s4,0x20
    80007180:	3cca0a13          	addi	s4,s4,972 # 80027548 <uart_tx_lock>
    80007184:	00003497          	auipc	s1,0x3
    80007188:	eb448493          	addi	s1,s1,-332 # 8000a038 <uart_tx_r>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000718c:	00003917          	auipc	s2,0x3
    80007190:	eb490913          	addi	s2,s2,-332 # 8000a040 <uart_tx_w>
      sleep(&uart_tx_r, &uart_tx_lock);
    80007194:	85d2                	mv	a1,s4
    80007196:	8526                	mv	a0,s1
    80007198:	ffffa097          	auipc	ra,0xffffa
    8000719c:	582080e7          	jalr	1410(ra) # 8000171a <sleep>
    if(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800071a0:	00093783          	ld	a5,0(s2)
    800071a4:	6098                	ld	a4,0(s1)
    800071a6:	02070713          	addi	a4,a4,32
    800071aa:	fef705e3          	beq	a4,a5,80007194 <uartputc+0x66>
      uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800071ae:	00020497          	auipc	s1,0x20
    800071b2:	39a48493          	addi	s1,s1,922 # 80027548 <uart_tx_lock>
    800071b6:	01f7f713          	andi	a4,a5,31
    800071ba:	9726                	add	a4,a4,s1
    800071bc:	01370c23          	sb	s3,24(a4)
      uart_tx_w += 1;
    800071c0:	0785                	addi	a5,a5,1
    800071c2:	00003717          	auipc	a4,0x3
    800071c6:	e6f73f23          	sd	a5,-386(a4) # 8000a040 <uart_tx_w>
      uartstart();
    800071ca:	00000097          	auipc	ra,0x0
    800071ce:	ec4080e7          	jalr	-316(ra) # 8000708e <uartstart>
      release(&uart_tx_lock);
    800071d2:	8526                	mv	a0,s1
    800071d4:	00000097          	auipc	ra,0x0
    800071d8:	1d4080e7          	jalr	468(ra) # 800073a8 <release>
}
    800071dc:	70a2                	ld	ra,40(sp)
    800071de:	7402                	ld	s0,32(sp)
    800071e0:	64e2                	ld	s1,24(sp)
    800071e2:	6942                	ld	s2,16(sp)
    800071e4:	69a2                	ld	s3,8(sp)
    800071e6:	6a02                	ld	s4,0(sp)
    800071e8:	6145                	addi	sp,sp,48
    800071ea:	8082                	ret

00000000800071ec <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800071ec:	1141                	addi	sp,sp,-16
    800071ee:	e422                	sd	s0,8(sp)
    800071f0:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800071f2:	100007b7          	lui	a5,0x10000
    800071f6:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    800071fa:	8b85                	andi	a5,a5,1
    800071fc:	cb91                	beqz	a5,80007210 <uartgetc+0x24>
    // input data is ready.
    return ReadReg(RHR);
    800071fe:	100007b7          	lui	a5,0x10000
    80007202:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
    80007206:	0ff57513          	andi	a0,a0,255
  } else {
    return -1;
  }
}
    8000720a:	6422                	ld	s0,8(sp)
    8000720c:	0141                	addi	sp,sp,16
    8000720e:	8082                	ret
    return -1;
    80007210:	557d                	li	a0,-1
    80007212:	bfe5                	j	8000720a <uartgetc+0x1e>

0000000080007214 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from trap.c.
void
uartintr(void)
{
    80007214:	1101                	addi	sp,sp,-32
    80007216:	ec06                	sd	ra,24(sp)
    80007218:	e822                	sd	s0,16(sp)
    8000721a:	e426                	sd	s1,8(sp)
    8000721c:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    8000721e:	54fd                	li	s1,-1
    int c = uartgetc();
    80007220:	00000097          	auipc	ra,0x0
    80007224:	fcc080e7          	jalr	-52(ra) # 800071ec <uartgetc>
    if(c == -1)
    80007228:	00950763          	beq	a0,s1,80007236 <uartintr+0x22>
      break;
    consoleintr(c);
    8000722c:	00000097          	auipc	ra,0x0
    80007230:	8b6080e7          	jalr	-1866(ra) # 80006ae2 <consoleintr>
  while(1){
    80007234:	b7f5                	j	80007220 <uartintr+0xc>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80007236:	00020497          	auipc	s1,0x20
    8000723a:	31248493          	addi	s1,s1,786 # 80027548 <uart_tx_lock>
    8000723e:	8526                	mv	a0,s1
    80007240:	00000097          	auipc	ra,0x0
    80007244:	0b4080e7          	jalr	180(ra) # 800072f4 <acquire>
  uartstart();
    80007248:	00000097          	auipc	ra,0x0
    8000724c:	e46080e7          	jalr	-442(ra) # 8000708e <uartstart>
  release(&uart_tx_lock);
    80007250:	8526                	mv	a0,s1
    80007252:	00000097          	auipc	ra,0x0
    80007256:	156080e7          	jalr	342(ra) # 800073a8 <release>
}
    8000725a:	60e2                	ld	ra,24(sp)
    8000725c:	6442                	ld	s0,16(sp)
    8000725e:	64a2                	ld	s1,8(sp)
    80007260:	6105                	addi	sp,sp,32
    80007262:	8082                	ret

0000000080007264 <initlock>:
}
#endif

void
initlock(struct spinlock *lk, char *name)
{
    80007264:	1141                	addi	sp,sp,-16
    80007266:	e422                	sd	s0,8(sp)
    80007268:	0800                	addi	s0,sp,16
  lk->name = name;
    8000726a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    8000726c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80007270:	00053823          	sd	zero,16(a0)
#ifdef LAB_LOCK
  lk->nts = 0;
  lk->n = 0;
  findslot(lk);
#endif  
}
    80007274:	6422                	ld	s0,8(sp)
    80007276:	0141                	addi	sp,sp,16
    80007278:	8082                	ret

000000008000727a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    8000727a:	411c                	lw	a5,0(a0)
    8000727c:	e399                	bnez	a5,80007282 <holding+0x8>
    8000727e:	4501                	li	a0,0
  return r;
}
    80007280:	8082                	ret
{
    80007282:	1101                	addi	sp,sp,-32
    80007284:	ec06                	sd	ra,24(sp)
    80007286:	e822                	sd	s0,16(sp)
    80007288:	e426                	sd	s1,8(sp)
    8000728a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    8000728c:	6904                	ld	s1,16(a0)
    8000728e:	ffffa097          	auipc	ra,0xffffa
    80007292:	c56080e7          	jalr	-938(ra) # 80000ee4 <mycpu>
    80007296:	40a48533          	sub	a0,s1,a0
    8000729a:	00153513          	seqz	a0,a0
}
    8000729e:	60e2                	ld	ra,24(sp)
    800072a0:	6442                	ld	s0,16(sp)
    800072a2:	64a2                	ld	s1,8(sp)
    800072a4:	6105                	addi	sp,sp,32
    800072a6:	8082                	ret

00000000800072a8 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    800072a8:	1101                	addi	sp,sp,-32
    800072aa:	ec06                	sd	ra,24(sp)
    800072ac:	e822                	sd	s0,16(sp)
    800072ae:	e426                	sd	s1,8(sp)
    800072b0:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800072b2:	100024f3          	csrr	s1,sstatus
    800072b6:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800072ba:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800072bc:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    800072c0:	ffffa097          	auipc	ra,0xffffa
    800072c4:	c24080e7          	jalr	-988(ra) # 80000ee4 <mycpu>
    800072c8:	5d3c                	lw	a5,120(a0)
    800072ca:	cf89                	beqz	a5,800072e4 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    800072cc:	ffffa097          	auipc	ra,0xffffa
    800072d0:	c18080e7          	jalr	-1000(ra) # 80000ee4 <mycpu>
    800072d4:	5d3c                	lw	a5,120(a0)
    800072d6:	2785                	addiw	a5,a5,1
    800072d8:	dd3c                	sw	a5,120(a0)
}
    800072da:	60e2                	ld	ra,24(sp)
    800072dc:	6442                	ld	s0,16(sp)
    800072de:	64a2                	ld	s1,8(sp)
    800072e0:	6105                	addi	sp,sp,32
    800072e2:	8082                	ret
    mycpu()->intena = old;
    800072e4:	ffffa097          	auipc	ra,0xffffa
    800072e8:	c00080e7          	jalr	-1024(ra) # 80000ee4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    800072ec:	8085                	srli	s1,s1,0x1
    800072ee:	8885                	andi	s1,s1,1
    800072f0:	dd64                	sw	s1,124(a0)
    800072f2:	bfe9                	j	800072cc <push_off+0x24>

00000000800072f4 <acquire>:
{
    800072f4:	1101                	addi	sp,sp,-32
    800072f6:	ec06                	sd	ra,24(sp)
    800072f8:	e822                	sd	s0,16(sp)
    800072fa:	e426                	sd	s1,8(sp)
    800072fc:	1000                	addi	s0,sp,32
    800072fe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80007300:	00000097          	auipc	ra,0x0
    80007304:	fa8080e7          	jalr	-88(ra) # 800072a8 <push_off>
  if(holding(lk))
    80007308:	8526                	mv	a0,s1
    8000730a:	00000097          	auipc	ra,0x0
    8000730e:	f70080e7          	jalr	-144(ra) # 8000727a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80007312:	4705                	li	a4,1
  if(holding(lk))
    80007314:	e115                	bnez	a0,80007338 <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0) {
    80007316:	87ba                	mv	a5,a4
    80007318:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    8000731c:	2781                	sext.w	a5,a5
    8000731e:	ffe5                	bnez	a5,80007316 <acquire+0x22>
  __sync_synchronize();
    80007320:	0ff0000f          	fence
  lk->cpu = mycpu();
    80007324:	ffffa097          	auipc	ra,0xffffa
    80007328:	bc0080e7          	jalr	-1088(ra) # 80000ee4 <mycpu>
    8000732c:	e888                	sd	a0,16(s1)
}
    8000732e:	60e2                	ld	ra,24(sp)
    80007330:	6442                	ld	s0,16(sp)
    80007332:	64a2                	ld	s1,8(sp)
    80007334:	6105                	addi	sp,sp,32
    80007336:	8082                	ret
    panic("acquire");
    80007338:	00002517          	auipc	a0,0x2
    8000733c:	50050513          	addi	a0,a0,1280 # 80009838 <digits+0x48>
    80007340:	00000097          	auipc	ra,0x0
    80007344:	a48080e7          	jalr	-1464(ra) # 80006d88 <panic>

0000000080007348 <pop_off>:

void
pop_off(void)
{
    80007348:	1141                	addi	sp,sp,-16
    8000734a:	e406                	sd	ra,8(sp)
    8000734c:	e022                	sd	s0,0(sp)
    8000734e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80007350:	ffffa097          	auipc	ra,0xffffa
    80007354:	b94080e7          	jalr	-1132(ra) # 80000ee4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80007358:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    8000735c:	8b89                	andi	a5,a5,2
  if(intr_get())
    8000735e:	e78d                	bnez	a5,80007388 <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80007360:	5d3c                	lw	a5,120(a0)
    80007362:	02f05b63          	blez	a5,80007398 <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80007366:	37fd                	addiw	a5,a5,-1
    80007368:	0007871b          	sext.w	a4,a5
    8000736c:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    8000736e:	eb09                	bnez	a4,80007380 <pop_off+0x38>
    80007370:	5d7c                	lw	a5,124(a0)
    80007372:	c799                	beqz	a5,80007380 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80007374:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80007378:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000737c:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80007380:	60a2                	ld	ra,8(sp)
    80007382:	6402                	ld	s0,0(sp)
    80007384:	0141                	addi	sp,sp,16
    80007386:	8082                	ret
    panic("pop_off - interruptible");
    80007388:	00002517          	auipc	a0,0x2
    8000738c:	4b850513          	addi	a0,a0,1208 # 80009840 <digits+0x50>
    80007390:	00000097          	auipc	ra,0x0
    80007394:	9f8080e7          	jalr	-1544(ra) # 80006d88 <panic>
    panic("pop_off");
    80007398:	00002517          	auipc	a0,0x2
    8000739c:	4c050513          	addi	a0,a0,1216 # 80009858 <digits+0x68>
    800073a0:	00000097          	auipc	ra,0x0
    800073a4:	9e8080e7          	jalr	-1560(ra) # 80006d88 <panic>

00000000800073a8 <release>:
{
    800073a8:	1101                	addi	sp,sp,-32
    800073aa:	ec06                	sd	ra,24(sp)
    800073ac:	e822                	sd	s0,16(sp)
    800073ae:	e426                	sd	s1,8(sp)
    800073b0:	1000                	addi	s0,sp,32
    800073b2:	84aa                	mv	s1,a0
  if(!holding(lk))
    800073b4:	00000097          	auipc	ra,0x0
    800073b8:	ec6080e7          	jalr	-314(ra) # 8000727a <holding>
    800073bc:	c115                	beqz	a0,800073e0 <release+0x38>
  lk->cpu = 0;
    800073be:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    800073c2:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    800073c6:	0f50000f          	fence	iorw,ow
    800073ca:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    800073ce:	00000097          	auipc	ra,0x0
    800073d2:	f7a080e7          	jalr	-134(ra) # 80007348 <pop_off>
}
    800073d6:	60e2                	ld	ra,24(sp)
    800073d8:	6442                	ld	s0,16(sp)
    800073da:	64a2                	ld	s1,8(sp)
    800073dc:	6105                	addi	sp,sp,32
    800073de:	8082                	ret
    panic("release");
    800073e0:	00002517          	auipc	a0,0x2
    800073e4:	48050513          	addi	a0,a0,1152 # 80009860 <digits+0x70>
    800073e8:	00000097          	auipc	ra,0x0
    800073ec:	9a0080e7          	jalr	-1632(ra) # 80006d88 <panic>

00000000800073f0 <lockfree_read8>:

// Read a shared 64-bit value without holding a lock
uint64
lockfree_read8(uint64 *addr) {
    800073f0:	1141                	addi	sp,sp,-16
    800073f2:	e422                	sd	s0,8(sp)
    800073f4:	0800                	addi	s0,sp,16
  uint64 val;
  __atomic_load(addr, &val, __ATOMIC_SEQ_CST);
    800073f6:	0ff0000f          	fence
    800073fa:	6108                	ld	a0,0(a0)
    800073fc:	0ff0000f          	fence
  return val;
}
    80007400:	6422                	ld	s0,8(sp)
    80007402:	0141                	addi	sp,sp,16
    80007404:	8082                	ret

0000000080007406 <lockfree_read4>:

// Read a shared 32-bit value without holding a lock
int
lockfree_read4(int *addr) {
    80007406:	1141                	addi	sp,sp,-16
    80007408:	e422                	sd	s0,8(sp)
    8000740a:	0800                	addi	s0,sp,16
  uint32 val;
  __atomic_load(addr, &val, __ATOMIC_SEQ_CST);
    8000740c:	0ff0000f          	fence
    80007410:	4108                	lw	a0,0(a0)
    80007412:	0ff0000f          	fence
  return val;
}
    80007416:	2501                	sext.w	a0,a0
    80007418:	6422                	ld	s0,8(sp)
    8000741a:	0141                	addi	sp,sp,16
    8000741c:	8082                	ret
	...

0000000080008000 <_trampoline>:
    80008000:	14051573          	csrrw	a0,sscratch,a0
    80008004:	02153423          	sd	ra,40(a0)
    80008008:	02253823          	sd	sp,48(a0)
    8000800c:	02353c23          	sd	gp,56(a0)
    80008010:	04453023          	sd	tp,64(a0)
    80008014:	04553423          	sd	t0,72(a0)
    80008018:	04653823          	sd	t1,80(a0)
    8000801c:	04753c23          	sd	t2,88(a0)
    80008020:	f120                	sd	s0,96(a0)
    80008022:	f524                	sd	s1,104(a0)
    80008024:	fd2c                	sd	a1,120(a0)
    80008026:	e150                	sd	a2,128(a0)
    80008028:	e554                	sd	a3,136(a0)
    8000802a:	e958                	sd	a4,144(a0)
    8000802c:	ed5c                	sd	a5,152(a0)
    8000802e:	0b053023          	sd	a6,160(a0)
    80008032:	0b153423          	sd	a7,168(a0)
    80008036:	0b253823          	sd	s2,176(a0)
    8000803a:	0b353c23          	sd	s3,184(a0)
    8000803e:	0d453023          	sd	s4,192(a0)
    80008042:	0d553423          	sd	s5,200(a0)
    80008046:	0d653823          	sd	s6,208(a0)
    8000804a:	0d753c23          	sd	s7,216(a0)
    8000804e:	0f853023          	sd	s8,224(a0)
    80008052:	0f953423          	sd	s9,232(a0)
    80008056:	0fa53823          	sd	s10,240(a0)
    8000805a:	0fb53c23          	sd	s11,248(a0)
    8000805e:	11c53023          	sd	t3,256(a0)
    80008062:	11d53423          	sd	t4,264(a0)
    80008066:	11e53823          	sd	t5,272(a0)
    8000806a:	11f53c23          	sd	t6,280(a0)
    8000806e:	140022f3          	csrr	t0,sscratch
    80008072:	06553823          	sd	t0,112(a0)
    80008076:	00853103          	ld	sp,8(a0)
    8000807a:	02053203          	ld	tp,32(a0)
    8000807e:	01053283          	ld	t0,16(a0)
    80008082:	00053303          	ld	t1,0(a0)
    80008086:	18031073          	csrw	satp,t1
    8000808a:	12000073          	sfence.vma
    8000808e:	8282                	jr	t0

0000000080008090 <userret>:
    80008090:	18059073          	csrw	satp,a1
    80008094:	12000073          	sfence.vma
    80008098:	07053283          	ld	t0,112(a0)
    8000809c:	14029073          	csrw	sscratch,t0
    800080a0:	02853083          	ld	ra,40(a0)
    800080a4:	03053103          	ld	sp,48(a0)
    800080a8:	03853183          	ld	gp,56(a0)
    800080ac:	04053203          	ld	tp,64(a0)
    800080b0:	04853283          	ld	t0,72(a0)
    800080b4:	05053303          	ld	t1,80(a0)
    800080b8:	05853383          	ld	t2,88(a0)
    800080bc:	7120                	ld	s0,96(a0)
    800080be:	7524                	ld	s1,104(a0)
    800080c0:	7d2c                	ld	a1,120(a0)
    800080c2:	6150                	ld	a2,128(a0)
    800080c4:	6554                	ld	a3,136(a0)
    800080c6:	6958                	ld	a4,144(a0)
    800080c8:	6d5c                	ld	a5,152(a0)
    800080ca:	0a053803          	ld	a6,160(a0)
    800080ce:	0a853883          	ld	a7,168(a0)
    800080d2:	0b053903          	ld	s2,176(a0)
    800080d6:	0b853983          	ld	s3,184(a0)
    800080da:	0c053a03          	ld	s4,192(a0)
    800080de:	0c853a83          	ld	s5,200(a0)
    800080e2:	0d053b03          	ld	s6,208(a0)
    800080e6:	0d853b83          	ld	s7,216(a0)
    800080ea:	0e053c03          	ld	s8,224(a0)
    800080ee:	0e853c83          	ld	s9,232(a0)
    800080f2:	0f053d03          	ld	s10,240(a0)
    800080f6:	0f853d83          	ld	s11,248(a0)
    800080fa:	10053e03          	ld	t3,256(a0)
    800080fe:	10853e83          	ld	t4,264(a0)
    80008102:	11053f03          	ld	t5,272(a0)
    80008106:	11853f83          	ld	t6,280(a0)
    8000810a:	14051573          	csrrw	a0,sscratch,a0
    8000810e:	10200073          	sret
	...
