
user/_uthread：     文件格式 elf64-littleriscv


Disassembly of section .text:

0000000000000000 <clear_thread>:
extern void thread_switch(uint64, uint64);

/*
 * helper function to setup the routine for a newly-created thread
 */
void clear_thread(struct thread *t, void (*func)()) {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	e04a                	sd	s2,0(sp)
   a:	1000                	addi	s0,sp,32
   c:	84aa                	mv	s1,a0
   e:	892e                	mv	s2,a1
  memset((void *)&t->stack, 0, STACK_SIZE);
  10:	6609                	lui	a2,0x2
  12:	4581                	li	a1,0
  14:	07050513          	addi	a0,a0,112
  18:	00000097          	auipc	ra,0x0
  1c:	548080e7          	jalr	1352(ra) # 560 <memset>
  memset((void *)&t->thread_context, 0, sizeof(struct thread_context));
  20:	07000613          	li	a2,112
  24:	4581                	li	a1,0
  26:	8526                	mv	a0,s1
  28:	00000097          	auipc	ra,0x0
  2c:	538080e7          	jalr	1336(ra) # 560 <memset>
  t->state = RUNNABLE;
  30:	6789                	lui	a5,0x2
  32:	00f48733          	add	a4,s1,a5
  36:	4689                	li	a3,2
  38:	db34                	sw	a3,112(a4)
  t->thread_context.sp = (uint64) ((char *)&t->stack + STACK_SIZE);
  3a:	07078793          	addi	a5,a5,112 # 2070 <__global_pointer$+0xab8>
  3e:	97a6                	add	a5,a5,s1
  40:	e49c                	sd	a5,8(s1)
  t->thread_context.ra = (uint64) func;
  42:	0124b023          	sd	s2,0(s1)
}
  46:	60e2                	ld	ra,24(sp)
  48:	6442                	ld	s0,16(sp)
  4a:	64a2                	ld	s1,8(sp)
  4c:	6902                	ld	s2,0(sp)
  4e:	6105                	addi	sp,sp,32
  50:	8082                	ret

0000000000000052 <thread_init>:

void 
thread_init(void)
{
  52:	1141                	addi	sp,sp,-16
  54:	e422                	sd	s0,8(sp)
  56:	0800                	addi	s0,sp,16
  // main() is thread 0, which will make the first invocation to
  // thread_schedule().  it needs a stack so that the first thread_switch() can
  // save thread 0's state.  thread_schedule() won't run the main thread ever
  // again, because its state is set to RUNNING, and thread_schedule() selects
  // a RUNNABLE thread.
  current_thread = &all_thread[0];
  58:	00001797          	auipc	a5,0x1
  5c:	d8878793          	addi	a5,a5,-632 # de0 <all_thread>
  60:	00001717          	auipc	a4,0x1
  64:	d6f73823          	sd	a5,-656(a4) # dd0 <current_thread>
  current_thread->state = RUNNING;
  68:	4785                	li	a5,1
  6a:	00003717          	auipc	a4,0x3
  6e:	def72323          	sw	a5,-538(a4) # 2e50 <__global_pointer$+0x1898>
}
  72:	6422                	ld	s0,8(sp)
  74:	0141                	addi	sp,sp,16
  76:	8082                	ret

0000000000000078 <thread_schedule>:

void 
thread_schedule(void)
{
  78:	1141                	addi	sp,sp,-16
  7a:	e406                	sd	ra,8(sp)
  7c:	e022                	sd	s0,0(sp)
  7e:	0800                	addi	s0,sp,16
  struct thread *t, *next_thread;

  /* Find another runnable thread. */
  next_thread = 0;
  t = current_thread + 1;
  80:	00001797          	auipc	a5,0x1
  84:	d5078793          	addi	a5,a5,-688 # dd0 <current_thread>
  88:	6388                	ld	a0,0(a5)
  8a:	6589                	lui	a1,0x2
  8c:	07858593          	addi	a1,a1,120 # 2078 <__global_pointer$+0xac0>
  90:	95aa                	add	a1,a1,a0
  92:	4791                	li	a5,4
  for(int i = 0; i < MAX_THREAD; i++){
    if(t >= all_thread + MAX_THREAD)
  94:	00009817          	auipc	a6,0x9
  98:	f2c80813          	addi	a6,a6,-212 # 8fc0 <base>
      t = all_thread;
    if(t->state == RUNNABLE) {
  9c:	6689                	lui	a3,0x2
  9e:	4609                	li	a2,2
      next_thread = t;
      break;
    }
    t = t + 1;
  a0:	07868893          	addi	a7,a3,120 # 2078 <__global_pointer$+0xac0>
  a4:	a809                	j	b6 <thread_schedule+0x3e>
    if(t->state == RUNNABLE) {
  a6:	00d58733          	add	a4,a1,a3
  aa:	5b38                	lw	a4,112(a4)
  ac:	02c70963          	beq	a4,a2,de <thread_schedule+0x66>
    t = t + 1;
  b0:	95c6                	add	a1,a1,a7
  for(int i = 0; i < MAX_THREAD; i++){
  b2:	37fd                	addiw	a5,a5,-1
  b4:	cb81                	beqz	a5,c4 <thread_schedule+0x4c>
    if(t >= all_thread + MAX_THREAD)
  b6:	ff05e8e3          	bltu	a1,a6,a6 <thread_schedule+0x2e>
      t = all_thread;
  ba:	00001597          	auipc	a1,0x1
  be:	d2658593          	addi	a1,a1,-730 # de0 <all_thread>
  c2:	b7d5                	j	a6 <thread_schedule+0x2e>
  }

  if (next_thread == 0) {
    printf("thread_schedule: no runnable threads\n");
  c4:	00001517          	auipc	a0,0x1
  c8:	bd450513          	addi	a0,a0,-1068 # c98 <malloc+0xea>
  cc:	00001097          	auipc	ra,0x1
  d0:	a22080e7          	jalr	-1502(ra) # aee <printf>
    exit(-1);
  d4:	557d                	li	a0,-1
  d6:	00000097          	auipc	ra,0x0
  da:	6a0080e7          	jalr	1696(ra) # 776 <exit>
  }

  if (current_thread != next_thread) {         /* switch threads?  */
  de:	00b50e63          	beq	a0,a1,fa <thread_schedule+0x82>
    next_thread->state = RUNNING;
  e2:	6789                	lui	a5,0x2
  e4:	97ae                	add	a5,a5,a1
  e6:	4705                	li	a4,1
  e8:	dbb8                	sw	a4,112(a5)
    t = current_thread;
    current_thread = next_thread;
  ea:	00001797          	auipc	a5,0x1
  ee:	ceb7b323          	sd	a1,-794(a5) # dd0 <current_thread>
    /* YOUR CODE HERE
     * Invoke thread_switch to switch from t to next_thread:
     * thread_switch(??, ??);
     */
    thread_switch((uint64) t, (uint64) current_thread);
  f2:	00000097          	auipc	ra,0x0
  f6:	38a080e7          	jalr	906(ra) # 47c <thread_switch>
  } else
    next_thread = 0;
}
  fa:	60a2                	ld	ra,8(sp)
  fc:	6402                	ld	s0,0(sp)
  fe:	0141                	addi	sp,sp,16
 100:	8082                	ret

0000000000000102 <thread_create>:

void 
thread_create(void (*func)())
{
 102:	1141                	addi	sp,sp,-16
 104:	e406                	sd	ra,8(sp)
 106:	e022                	sd	s0,0(sp)
 108:	0800                	addi	s0,sp,16
 10a:	85aa                	mv	a1,a0
  struct thread *t;

  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
    if (t->state == FREE) break;
 10c:	00003797          	auipc	a5,0x3
 110:	cd478793          	addi	a5,a5,-812 # 2de0 <__global_pointer$+0x1828>
 114:	5bbc                	lw	a5,112(a5)
 116:	cf8d                	beqz	a5,150 <thread_create+0x4e>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 118:	00003517          	auipc	a0,0x3
 11c:	d4050513          	addi	a0,a0,-704 # 2e58 <__global_pointer$+0x18a0>
    if (t->state == FREE) break;
 120:	6709                	lui	a4,0x2
 122:	07070613          	addi	a2,a4,112 # 2070 <__global_pointer$+0xab8>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 126:	07870713          	addi	a4,a4,120
 12a:	00009817          	auipc	a6,0x9
 12e:	e9680813          	addi	a6,a6,-362 # 8fc0 <base>
    if (t->state == FREE) break;
 132:	00c506b3          	add	a3,a0,a2
 136:	4294                	lw	a3,0(a3)
 138:	c681                	beqz	a3,140 <thread_create+0x3e>
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 13a:	953a                	add	a0,a0,a4
 13c:	ff051be3          	bne	a0,a6,132 <thread_create+0x30>
  }
  // YOUR CODE HERE
  clear_thread(t, func);
 140:	00000097          	auipc	ra,0x0
 144:	ec0080e7          	jalr	-320(ra) # 0 <clear_thread>
}
 148:	60a2                	ld	ra,8(sp)
 14a:	6402                	ld	s0,0(sp)
 14c:	0141                	addi	sp,sp,16
 14e:	8082                	ret
  for (t = all_thread; t < all_thread + MAX_THREAD; t++) {
 150:	00001517          	auipc	a0,0x1
 154:	c9050513          	addi	a0,a0,-880 # de0 <all_thread>
 158:	b7e5                	j	140 <thread_create+0x3e>

000000000000015a <thread_yield>:

void 
thread_yield(void)
{
 15a:	1141                	addi	sp,sp,-16
 15c:	e406                	sd	ra,8(sp)
 15e:	e022                	sd	s0,0(sp)
 160:	0800                	addi	s0,sp,16
  current_thread->state = RUNNABLE;
 162:	00001797          	auipc	a5,0x1
 166:	c6e78793          	addi	a5,a5,-914 # dd0 <current_thread>
 16a:	639c                	ld	a5,0(a5)
 16c:	6709                	lui	a4,0x2
 16e:	97ba                	add	a5,a5,a4
 170:	4709                	li	a4,2
 172:	dbb8                	sw	a4,112(a5)
  thread_schedule();
 174:	00000097          	auipc	ra,0x0
 178:	f04080e7          	jalr	-252(ra) # 78 <thread_schedule>
}
 17c:	60a2                	ld	ra,8(sp)
 17e:	6402                	ld	s0,0(sp)
 180:	0141                	addi	sp,sp,16
 182:	8082                	ret

0000000000000184 <thread_a>:
volatile int a_started, b_started, c_started;
volatile int a_n, b_n, c_n;

void 
thread_a(void)
{
 184:	7179                	addi	sp,sp,-48
 186:	f406                	sd	ra,40(sp)
 188:	f022                	sd	s0,32(sp)
 18a:	ec26                	sd	s1,24(sp)
 18c:	e84a                	sd	s2,16(sp)
 18e:	e44e                	sd	s3,8(sp)
 190:	e052                	sd	s4,0(sp)
 192:	1800                	addi	s0,sp,48
  int i;
  printf("thread_a started\n");
 194:	00001517          	auipc	a0,0x1
 198:	b2c50513          	addi	a0,a0,-1236 # cc0 <malloc+0x112>
 19c:	00001097          	auipc	ra,0x1
 1a0:	952080e7          	jalr	-1710(ra) # aee <printf>
  a_started = 1;
 1a4:	4785                	li	a5,1
 1a6:	00001717          	auipc	a4,0x1
 1aa:	c2f72323          	sw	a5,-986(a4) # dcc <a_started>
  while(b_started == 0 || c_started == 0)
 1ae:	00001497          	auipc	s1,0x1
 1b2:	c1a48493          	addi	s1,s1,-998 # dc8 <b_started>
 1b6:	00001917          	auipc	s2,0x1
 1ba:	c0e90913          	addi	s2,s2,-1010 # dc4 <c_started>
 1be:	a029                	j	1c8 <thread_a+0x44>
    thread_yield();
 1c0:	00000097          	auipc	ra,0x0
 1c4:	f9a080e7          	jalr	-102(ra) # 15a <thread_yield>
  while(b_started == 0 || c_started == 0)
 1c8:	409c                	lw	a5,0(s1)
 1ca:	2781                	sext.w	a5,a5
 1cc:	dbf5                	beqz	a5,1c0 <thread_a+0x3c>
 1ce:	00092783          	lw	a5,0(s2)
 1d2:	2781                	sext.w	a5,a5
 1d4:	d7f5                	beqz	a5,1c0 <thread_a+0x3c>
  
  for (i = 0; i < 100; i++) {
 1d6:	4481                	li	s1,0
    printf("thread_a %d\n", i);
 1d8:	00001a17          	auipc	s4,0x1
 1dc:	b00a0a13          	addi	s4,s4,-1280 # cd8 <malloc+0x12a>
    a_n += 1;
 1e0:	00001917          	auipc	s2,0x1
 1e4:	be090913          	addi	s2,s2,-1056 # dc0 <a_n>
  for (i = 0; i < 100; i++) {
 1e8:	06400993          	li	s3,100
    printf("thread_a %d\n", i);
 1ec:	85a6                	mv	a1,s1
 1ee:	8552                	mv	a0,s4
 1f0:	00001097          	auipc	ra,0x1
 1f4:	8fe080e7          	jalr	-1794(ra) # aee <printf>
    a_n += 1;
 1f8:	00092783          	lw	a5,0(s2)
 1fc:	2785                	addiw	a5,a5,1
 1fe:	00f92023          	sw	a5,0(s2)
    thread_yield();
 202:	00000097          	auipc	ra,0x0
 206:	f58080e7          	jalr	-168(ra) # 15a <thread_yield>
  for (i = 0; i < 100; i++) {
 20a:	2485                	addiw	s1,s1,1
 20c:	ff3490e3          	bne	s1,s3,1ec <thread_a+0x68>
  }
  printf("thread_a: exit after %d\n", a_n);
 210:	00001797          	auipc	a5,0x1
 214:	bb078793          	addi	a5,a5,-1104 # dc0 <a_n>
 218:	438c                	lw	a1,0(a5)
 21a:	2581                	sext.w	a1,a1
 21c:	00001517          	auipc	a0,0x1
 220:	acc50513          	addi	a0,a0,-1332 # ce8 <malloc+0x13a>
 224:	00001097          	auipc	ra,0x1
 228:	8ca080e7          	jalr	-1846(ra) # aee <printf>

  current_thread->state = FREE;
 22c:	00001797          	auipc	a5,0x1
 230:	ba478793          	addi	a5,a5,-1116 # dd0 <current_thread>
 234:	639c                	ld	a5,0(a5)
 236:	6709                	lui	a4,0x2
 238:	97ba                	add	a5,a5,a4
 23a:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 23e:	00000097          	auipc	ra,0x0
 242:	e3a080e7          	jalr	-454(ra) # 78 <thread_schedule>
}
 246:	70a2                	ld	ra,40(sp)
 248:	7402                	ld	s0,32(sp)
 24a:	64e2                	ld	s1,24(sp)
 24c:	6942                	ld	s2,16(sp)
 24e:	69a2                	ld	s3,8(sp)
 250:	6a02                	ld	s4,0(sp)
 252:	6145                	addi	sp,sp,48
 254:	8082                	ret

0000000000000256 <thread_b>:

void 
thread_b(void)
{
 256:	7179                	addi	sp,sp,-48
 258:	f406                	sd	ra,40(sp)
 25a:	f022                	sd	s0,32(sp)
 25c:	ec26                	sd	s1,24(sp)
 25e:	e84a                	sd	s2,16(sp)
 260:	e44e                	sd	s3,8(sp)
 262:	e052                	sd	s4,0(sp)
 264:	1800                	addi	s0,sp,48
  int i;
  printf("thread_b started\n");
 266:	00001517          	auipc	a0,0x1
 26a:	aa250513          	addi	a0,a0,-1374 # d08 <malloc+0x15a>
 26e:	00001097          	auipc	ra,0x1
 272:	880080e7          	jalr	-1920(ra) # aee <printf>
  b_started = 1;
 276:	4785                	li	a5,1
 278:	00001717          	auipc	a4,0x1
 27c:	b4f72823          	sw	a5,-1200(a4) # dc8 <b_started>
  while(a_started == 0 || c_started == 0)
 280:	00001497          	auipc	s1,0x1
 284:	b4c48493          	addi	s1,s1,-1204 # dcc <a_started>
 288:	00001917          	auipc	s2,0x1
 28c:	b3c90913          	addi	s2,s2,-1220 # dc4 <c_started>
 290:	a029                	j	29a <thread_b+0x44>
    thread_yield();
 292:	00000097          	auipc	ra,0x0
 296:	ec8080e7          	jalr	-312(ra) # 15a <thread_yield>
  while(a_started == 0 || c_started == 0)
 29a:	409c                	lw	a5,0(s1)
 29c:	2781                	sext.w	a5,a5
 29e:	dbf5                	beqz	a5,292 <thread_b+0x3c>
 2a0:	00092783          	lw	a5,0(s2)
 2a4:	2781                	sext.w	a5,a5
 2a6:	d7f5                	beqz	a5,292 <thread_b+0x3c>
  
  for (i = 0; i < 100; i++) {
 2a8:	4481                	li	s1,0
    printf("thread_b %d\n", i);
 2aa:	00001a17          	auipc	s4,0x1
 2ae:	a76a0a13          	addi	s4,s4,-1418 # d20 <malloc+0x172>
    b_n += 1;
 2b2:	00001917          	auipc	s2,0x1
 2b6:	b0a90913          	addi	s2,s2,-1270 # dbc <b_n>
  for (i = 0; i < 100; i++) {
 2ba:	06400993          	li	s3,100
    printf("thread_b %d\n", i);
 2be:	85a6                	mv	a1,s1
 2c0:	8552                	mv	a0,s4
 2c2:	00001097          	auipc	ra,0x1
 2c6:	82c080e7          	jalr	-2004(ra) # aee <printf>
    b_n += 1;
 2ca:	00092783          	lw	a5,0(s2)
 2ce:	2785                	addiw	a5,a5,1
 2d0:	00f92023          	sw	a5,0(s2)
    thread_yield();
 2d4:	00000097          	auipc	ra,0x0
 2d8:	e86080e7          	jalr	-378(ra) # 15a <thread_yield>
  for (i = 0; i < 100; i++) {
 2dc:	2485                	addiw	s1,s1,1
 2de:	ff3490e3          	bne	s1,s3,2be <thread_b+0x68>
  }
  printf("thread_b: exit after %d\n", b_n);
 2e2:	00001797          	auipc	a5,0x1
 2e6:	ada78793          	addi	a5,a5,-1318 # dbc <b_n>
 2ea:	438c                	lw	a1,0(a5)
 2ec:	2581                	sext.w	a1,a1
 2ee:	00001517          	auipc	a0,0x1
 2f2:	a4250513          	addi	a0,a0,-1470 # d30 <malloc+0x182>
 2f6:	00000097          	auipc	ra,0x0
 2fa:	7f8080e7          	jalr	2040(ra) # aee <printf>

  current_thread->state = FREE;
 2fe:	00001797          	auipc	a5,0x1
 302:	ad278793          	addi	a5,a5,-1326 # dd0 <current_thread>
 306:	639c                	ld	a5,0(a5)
 308:	6709                	lui	a4,0x2
 30a:	97ba                	add	a5,a5,a4
 30c:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 310:	00000097          	auipc	ra,0x0
 314:	d68080e7          	jalr	-664(ra) # 78 <thread_schedule>
}
 318:	70a2                	ld	ra,40(sp)
 31a:	7402                	ld	s0,32(sp)
 31c:	64e2                	ld	s1,24(sp)
 31e:	6942                	ld	s2,16(sp)
 320:	69a2                	ld	s3,8(sp)
 322:	6a02                	ld	s4,0(sp)
 324:	6145                	addi	sp,sp,48
 326:	8082                	ret

0000000000000328 <thread_c>:

void 
thread_c(void)
{
 328:	7179                	addi	sp,sp,-48
 32a:	f406                	sd	ra,40(sp)
 32c:	f022                	sd	s0,32(sp)
 32e:	ec26                	sd	s1,24(sp)
 330:	e84a                	sd	s2,16(sp)
 332:	e44e                	sd	s3,8(sp)
 334:	e052                	sd	s4,0(sp)
 336:	1800                	addi	s0,sp,48
  int i;
  printf("thread_c started\n");
 338:	00001517          	auipc	a0,0x1
 33c:	a1850513          	addi	a0,a0,-1512 # d50 <malloc+0x1a2>
 340:	00000097          	auipc	ra,0x0
 344:	7ae080e7          	jalr	1966(ra) # aee <printf>
  c_started = 1;
 348:	4785                	li	a5,1
 34a:	00001717          	auipc	a4,0x1
 34e:	a6f72d23          	sw	a5,-1414(a4) # dc4 <c_started>
  while(a_started == 0 || b_started == 0)
 352:	00001497          	auipc	s1,0x1
 356:	a7a48493          	addi	s1,s1,-1414 # dcc <a_started>
 35a:	00001917          	auipc	s2,0x1
 35e:	a6e90913          	addi	s2,s2,-1426 # dc8 <b_started>
 362:	a029                	j	36c <thread_c+0x44>
    thread_yield();
 364:	00000097          	auipc	ra,0x0
 368:	df6080e7          	jalr	-522(ra) # 15a <thread_yield>
  while(a_started == 0 || b_started == 0)
 36c:	409c                	lw	a5,0(s1)
 36e:	2781                	sext.w	a5,a5
 370:	dbf5                	beqz	a5,364 <thread_c+0x3c>
 372:	00092783          	lw	a5,0(s2)
 376:	2781                	sext.w	a5,a5
 378:	d7f5                	beqz	a5,364 <thread_c+0x3c>
  
  for (i = 0; i < 100; i++) {
 37a:	4481                	li	s1,0
    printf("thread_c %d\n", i);
 37c:	00001a17          	auipc	s4,0x1
 380:	9eca0a13          	addi	s4,s4,-1556 # d68 <malloc+0x1ba>
    c_n += 1;
 384:	00001917          	auipc	s2,0x1
 388:	a3490913          	addi	s2,s2,-1484 # db8 <c_n>
  for (i = 0; i < 100; i++) {
 38c:	06400993          	li	s3,100
    printf("thread_c %d\n", i);
 390:	85a6                	mv	a1,s1
 392:	8552                	mv	a0,s4
 394:	00000097          	auipc	ra,0x0
 398:	75a080e7          	jalr	1882(ra) # aee <printf>
    c_n += 1;
 39c:	00092783          	lw	a5,0(s2)
 3a0:	2785                	addiw	a5,a5,1
 3a2:	00f92023          	sw	a5,0(s2)
    thread_yield();
 3a6:	00000097          	auipc	ra,0x0
 3aa:	db4080e7          	jalr	-588(ra) # 15a <thread_yield>
  for (i = 0; i < 100; i++) {
 3ae:	2485                	addiw	s1,s1,1
 3b0:	ff3490e3          	bne	s1,s3,390 <thread_c+0x68>
  }
  printf("thread_c: exit after %d\n", c_n);
 3b4:	00001797          	auipc	a5,0x1
 3b8:	a0478793          	addi	a5,a5,-1532 # db8 <c_n>
 3bc:	438c                	lw	a1,0(a5)
 3be:	2581                	sext.w	a1,a1
 3c0:	00001517          	auipc	a0,0x1
 3c4:	9b850513          	addi	a0,a0,-1608 # d78 <malloc+0x1ca>
 3c8:	00000097          	auipc	ra,0x0
 3cc:	726080e7          	jalr	1830(ra) # aee <printf>

  current_thread->state = FREE;
 3d0:	00001797          	auipc	a5,0x1
 3d4:	a0078793          	addi	a5,a5,-1536 # dd0 <current_thread>
 3d8:	639c                	ld	a5,0(a5)
 3da:	6709                	lui	a4,0x2
 3dc:	97ba                	add	a5,a5,a4
 3de:	0607a823          	sw	zero,112(a5)
  thread_schedule();
 3e2:	00000097          	auipc	ra,0x0
 3e6:	c96080e7          	jalr	-874(ra) # 78 <thread_schedule>
}
 3ea:	70a2                	ld	ra,40(sp)
 3ec:	7402                	ld	s0,32(sp)
 3ee:	64e2                	ld	s1,24(sp)
 3f0:	6942                	ld	s2,16(sp)
 3f2:	69a2                	ld	s3,8(sp)
 3f4:	6a02                	ld	s4,0(sp)
 3f6:	6145                	addi	sp,sp,48
 3f8:	8082                	ret

00000000000003fa <main>:

int 
main(int argc, char *argv[]) 
{
 3fa:	1141                	addi	sp,sp,-16
 3fc:	e406                	sd	ra,8(sp)
 3fe:	e022                	sd	s0,0(sp)
 400:	0800                	addi	s0,sp,16
  a_started = b_started = c_started = 0;
 402:	00001797          	auipc	a5,0x1
 406:	9c07a123          	sw	zero,-1598(a5) # dc4 <c_started>
 40a:	00001797          	auipc	a5,0x1
 40e:	9a07af23          	sw	zero,-1602(a5) # dc8 <b_started>
 412:	00001797          	auipc	a5,0x1
 416:	9a07ad23          	sw	zero,-1606(a5) # dcc <a_started>
  a_n = b_n = c_n = 0;
 41a:	00001797          	auipc	a5,0x1
 41e:	9807af23          	sw	zero,-1634(a5) # db8 <c_n>
 422:	00001797          	auipc	a5,0x1
 426:	9807ad23          	sw	zero,-1638(a5) # dbc <b_n>
 42a:	00001797          	auipc	a5,0x1
 42e:	9807ab23          	sw	zero,-1642(a5) # dc0 <a_n>
  thread_init();
 432:	00000097          	auipc	ra,0x0
 436:	c20080e7          	jalr	-992(ra) # 52 <thread_init>
  thread_create(thread_a);
 43a:	00000517          	auipc	a0,0x0
 43e:	d4a50513          	addi	a0,a0,-694 # 184 <thread_a>
 442:	00000097          	auipc	ra,0x0
 446:	cc0080e7          	jalr	-832(ra) # 102 <thread_create>
  thread_create(thread_b);
 44a:	00000517          	auipc	a0,0x0
 44e:	e0c50513          	addi	a0,a0,-500 # 256 <thread_b>
 452:	00000097          	auipc	ra,0x0
 456:	cb0080e7          	jalr	-848(ra) # 102 <thread_create>
  thread_create(thread_c);
 45a:	00000517          	auipc	a0,0x0
 45e:	ece50513          	addi	a0,a0,-306 # 328 <thread_c>
 462:	00000097          	auipc	ra,0x0
 466:	ca0080e7          	jalr	-864(ra) # 102 <thread_create>
  thread_schedule();
 46a:	00000097          	auipc	ra,0x0
 46e:	c0e080e7          	jalr	-1010(ra) # 78 <thread_schedule>
  exit(0);
 472:	4501                	li	a0,0
 474:	00000097          	auipc	ra,0x0
 478:	302080e7          	jalr	770(ra) # 776 <exit>

000000000000047c <thread_switch>:
         */

	.globl thread_switch
thread_switch:
	/* YOUR CODE HERE */
        sd ra, 0(a0)
 47c:	00153023          	sd	ra,0(a0)
        sd sp, 8(a0)
 480:	00253423          	sd	sp,8(a0)
        sd s0, 16(a0)
 484:	e900                	sd	s0,16(a0)
        sd s1, 24(a0)
 486:	ed04                	sd	s1,24(a0)
        sd s2, 32(a0)
 488:	03253023          	sd	s2,32(a0)
        sd s3, 40(a0)
 48c:	03353423          	sd	s3,40(a0)
        sd s4, 48(a0)
 490:	03453823          	sd	s4,48(a0)
        sd s5, 56(a0)
 494:	03553c23          	sd	s5,56(a0)
        sd s6, 64(a0)
 498:	05653023          	sd	s6,64(a0)
        sd s7, 72(a0)
 49c:	05753423          	sd	s7,72(a0)
        sd s8, 80(a0)
 4a0:	05853823          	sd	s8,80(a0)
        sd s9, 88(a0)
 4a4:	05953c23          	sd	s9,88(a0)
        sd s10, 96(a0)
 4a8:	07a53023          	sd	s10,96(a0)
        sd s11, 104(a0)
 4ac:	07b53423          	sd	s11,104(a0)

        ld ra, 0(a1)
 4b0:	0005b083          	ld	ra,0(a1)
        ld sp, 8(a1)
 4b4:	0085b103          	ld	sp,8(a1)
        ld s0, 16(a1)
 4b8:	6980                	ld	s0,16(a1)
        ld s1, 24(a1)
 4ba:	6d84                	ld	s1,24(a1)
        ld s2, 32(a1)
 4bc:	0205b903          	ld	s2,32(a1)
        ld s3, 40(a1)
 4c0:	0285b983          	ld	s3,40(a1)
        ld s4, 48(a1)
 4c4:	0305ba03          	ld	s4,48(a1)
        ld s5, 56(a1)
 4c8:	0385ba83          	ld	s5,56(a1)
        ld s6, 64(a1)
 4cc:	0405bb03          	ld	s6,64(a1)
        ld s7, 72(a1)
 4d0:	0485bb83          	ld	s7,72(a1)
        ld s8, 80(a1)
 4d4:	0505bc03          	ld	s8,80(a1)
        ld s9, 88(a1)
 4d8:	0585bc83          	ld	s9,88(a1)
        ld s10, 96(a1)
 4dc:	0605bd03          	ld	s10,96(a1)
        ld s11, 104(a1)
 4e0:	0685bd83          	ld	s11,104(a1)
	ret    /* return to ra */
 4e4:	8082                	ret

00000000000004e6 <strcpy>:
#include "kernel/fcntl.h"
#include "user/user.h"

char*
strcpy(char *s, const char *t)
{
 4e6:	1141                	addi	sp,sp,-16
 4e8:	e422                	sd	s0,8(sp)
 4ea:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 4ec:	87aa                	mv	a5,a0
 4ee:	0585                	addi	a1,a1,1
 4f0:	0785                	addi	a5,a5,1
 4f2:	fff5c703          	lbu	a4,-1(a1)
 4f6:	fee78fa3          	sb	a4,-1(a5)
 4fa:	fb75                	bnez	a4,4ee <strcpy+0x8>
    ;
  return os;
}
 4fc:	6422                	ld	s0,8(sp)
 4fe:	0141                	addi	sp,sp,16
 500:	8082                	ret

0000000000000502 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 502:	1141                	addi	sp,sp,-16
 504:	e422                	sd	s0,8(sp)
 506:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 508:	00054783          	lbu	a5,0(a0)
 50c:	cf91                	beqz	a5,528 <strcmp+0x26>
 50e:	0005c703          	lbu	a4,0(a1)
 512:	00f71b63          	bne	a4,a5,528 <strcmp+0x26>
    p++, q++;
 516:	0505                	addi	a0,a0,1
 518:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 51a:	00054783          	lbu	a5,0(a0)
 51e:	c789                	beqz	a5,528 <strcmp+0x26>
 520:	0005c703          	lbu	a4,0(a1)
 524:	fef709e3          	beq	a4,a5,516 <strcmp+0x14>
  return (uchar)*p - (uchar)*q;
 528:	0005c503          	lbu	a0,0(a1)
}
 52c:	40a7853b          	subw	a0,a5,a0
 530:	6422                	ld	s0,8(sp)
 532:	0141                	addi	sp,sp,16
 534:	8082                	ret

0000000000000536 <strlen>:

uint
strlen(const char *s)
{
 536:	1141                	addi	sp,sp,-16
 538:	e422                	sd	s0,8(sp)
 53a:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 53c:	00054783          	lbu	a5,0(a0)
 540:	cf91                	beqz	a5,55c <strlen+0x26>
 542:	0505                	addi	a0,a0,1
 544:	87aa                	mv	a5,a0
 546:	4685                	li	a3,1
 548:	9e89                	subw	a3,a3,a0
 54a:	00f6853b          	addw	a0,a3,a5
 54e:	0785                	addi	a5,a5,1
 550:	fff7c703          	lbu	a4,-1(a5)
 554:	fb7d                	bnez	a4,54a <strlen+0x14>
    ;
  return n;
}
 556:	6422                	ld	s0,8(sp)
 558:	0141                	addi	sp,sp,16
 55a:	8082                	ret
  for(n = 0; s[n]; n++)
 55c:	4501                	li	a0,0
 55e:	bfe5                	j	556 <strlen+0x20>

0000000000000560 <memset>:

void*
memset(void *dst, int c, uint n)
{
 560:	1141                	addi	sp,sp,-16
 562:	e422                	sd	s0,8(sp)
 564:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 566:	ce09                	beqz	a2,580 <memset+0x20>
 568:	87aa                	mv	a5,a0
 56a:	fff6071b          	addiw	a4,a2,-1
 56e:	1702                	slli	a4,a4,0x20
 570:	9301                	srli	a4,a4,0x20
 572:	0705                	addi	a4,a4,1
 574:	972a                	add	a4,a4,a0
    cdst[i] = c;
 576:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 57a:	0785                	addi	a5,a5,1
 57c:	fee79de3          	bne	a5,a4,576 <memset+0x16>
  }
  return dst;
}
 580:	6422                	ld	s0,8(sp)
 582:	0141                	addi	sp,sp,16
 584:	8082                	ret

0000000000000586 <strchr>:

char*
strchr(const char *s, char c)
{
 586:	1141                	addi	sp,sp,-16
 588:	e422                	sd	s0,8(sp)
 58a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 58c:	00054783          	lbu	a5,0(a0)
 590:	cf91                	beqz	a5,5ac <strchr+0x26>
    if(*s == c)
 592:	00f58a63          	beq	a1,a5,5a6 <strchr+0x20>
  for(; *s; s++)
 596:	0505                	addi	a0,a0,1
 598:	00054783          	lbu	a5,0(a0)
 59c:	c781                	beqz	a5,5a4 <strchr+0x1e>
    if(*s == c)
 59e:	feb79ce3          	bne	a5,a1,596 <strchr+0x10>
 5a2:	a011                	j	5a6 <strchr+0x20>
      return (char*)s;
  return 0;
 5a4:	4501                	li	a0,0
}
 5a6:	6422                	ld	s0,8(sp)
 5a8:	0141                	addi	sp,sp,16
 5aa:	8082                	ret
  return 0;
 5ac:	4501                	li	a0,0
 5ae:	bfe5                	j	5a6 <strchr+0x20>

00000000000005b0 <gets>:

char*
gets(char *buf, int max)
{
 5b0:	711d                	addi	sp,sp,-96
 5b2:	ec86                	sd	ra,88(sp)
 5b4:	e8a2                	sd	s0,80(sp)
 5b6:	e4a6                	sd	s1,72(sp)
 5b8:	e0ca                	sd	s2,64(sp)
 5ba:	fc4e                	sd	s3,56(sp)
 5bc:	f852                	sd	s4,48(sp)
 5be:	f456                	sd	s5,40(sp)
 5c0:	f05a                	sd	s6,32(sp)
 5c2:	ec5e                	sd	s7,24(sp)
 5c4:	1080                	addi	s0,sp,96
 5c6:	8baa                	mv	s7,a0
 5c8:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 5ca:	892a                	mv	s2,a0
 5cc:	4981                	li	s3,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 5ce:	4aa9                	li	s5,10
 5d0:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 5d2:	0019849b          	addiw	s1,s3,1
 5d6:	0344d863          	ble	s4,s1,606 <gets+0x56>
    cc = read(0, &c, 1);
 5da:	4605                	li	a2,1
 5dc:	faf40593          	addi	a1,s0,-81
 5e0:	4501                	li	a0,0
 5e2:	00000097          	auipc	ra,0x0
 5e6:	1ac080e7          	jalr	428(ra) # 78e <read>
    if(cc < 1)
 5ea:	00a05e63          	blez	a0,606 <gets+0x56>
    buf[i++] = c;
 5ee:	faf44783          	lbu	a5,-81(s0)
 5f2:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 5f6:	01578763          	beq	a5,s5,604 <gets+0x54>
 5fa:	0905                	addi	s2,s2,1
  for(i=0; i+1 < max; ){
 5fc:	89a6                	mv	s3,s1
    if(c == '\n' || c == '\r')
 5fe:	fd679ae3          	bne	a5,s6,5d2 <gets+0x22>
 602:	a011                	j	606 <gets+0x56>
  for(i=0; i+1 < max; ){
 604:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 606:	99de                	add	s3,s3,s7
 608:	00098023          	sb	zero,0(s3)
  return buf;
}
 60c:	855e                	mv	a0,s7
 60e:	60e6                	ld	ra,88(sp)
 610:	6446                	ld	s0,80(sp)
 612:	64a6                	ld	s1,72(sp)
 614:	6906                	ld	s2,64(sp)
 616:	79e2                	ld	s3,56(sp)
 618:	7a42                	ld	s4,48(sp)
 61a:	7aa2                	ld	s5,40(sp)
 61c:	7b02                	ld	s6,32(sp)
 61e:	6be2                	ld	s7,24(sp)
 620:	6125                	addi	sp,sp,96
 622:	8082                	ret

0000000000000624 <stat>:

int
stat(const char *n, struct stat *st)
{
 624:	1101                	addi	sp,sp,-32
 626:	ec06                	sd	ra,24(sp)
 628:	e822                	sd	s0,16(sp)
 62a:	e426                	sd	s1,8(sp)
 62c:	e04a                	sd	s2,0(sp)
 62e:	1000                	addi	s0,sp,32
 630:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 632:	4581                	li	a1,0
 634:	00000097          	auipc	ra,0x0
 638:	182080e7          	jalr	386(ra) # 7b6 <open>
  if(fd < 0)
 63c:	02054563          	bltz	a0,666 <stat+0x42>
 640:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 642:	85ca                	mv	a1,s2
 644:	00000097          	auipc	ra,0x0
 648:	18a080e7          	jalr	394(ra) # 7ce <fstat>
 64c:	892a                	mv	s2,a0
  close(fd);
 64e:	8526                	mv	a0,s1
 650:	00000097          	auipc	ra,0x0
 654:	14e080e7          	jalr	334(ra) # 79e <close>
  return r;
}
 658:	854a                	mv	a0,s2
 65a:	60e2                	ld	ra,24(sp)
 65c:	6442                	ld	s0,16(sp)
 65e:	64a2                	ld	s1,8(sp)
 660:	6902                	ld	s2,0(sp)
 662:	6105                	addi	sp,sp,32
 664:	8082                	ret
    return -1;
 666:	597d                	li	s2,-1
 668:	bfc5                	j	658 <stat+0x34>

000000000000066a <atoi>:

int
atoi(const char *s)
{
 66a:	1141                	addi	sp,sp,-16
 66c:	e422                	sd	s0,8(sp)
 66e:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 670:	00054683          	lbu	a3,0(a0)
 674:	fd06879b          	addiw	a5,a3,-48
 678:	0ff7f793          	andi	a5,a5,255
 67c:	4725                	li	a4,9
 67e:	02f76963          	bltu	a4,a5,6b0 <atoi+0x46>
 682:	862a                	mv	a2,a0
  n = 0;
 684:	4501                	li	a0,0
  while('0' <= *s && *s <= '9')
 686:	45a5                	li	a1,9
    n = n*10 + *s++ - '0';
 688:	0605                	addi	a2,a2,1
 68a:	0025179b          	slliw	a5,a0,0x2
 68e:	9fa9                	addw	a5,a5,a0
 690:	0017979b          	slliw	a5,a5,0x1
 694:	9fb5                	addw	a5,a5,a3
 696:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 69a:	00064683          	lbu	a3,0(a2) # 2000 <__global_pointer$+0xa48>
 69e:	fd06871b          	addiw	a4,a3,-48
 6a2:	0ff77713          	andi	a4,a4,255
 6a6:	fee5f1e3          	bleu	a4,a1,688 <atoi+0x1e>
  return n;
}
 6aa:	6422                	ld	s0,8(sp)
 6ac:	0141                	addi	sp,sp,16
 6ae:	8082                	ret
  n = 0;
 6b0:	4501                	li	a0,0
 6b2:	bfe5                	j	6aa <atoi+0x40>

00000000000006b4 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 6b4:	1141                	addi	sp,sp,-16
 6b6:	e422                	sd	s0,8(sp)
 6b8:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 6ba:	02b57663          	bleu	a1,a0,6e6 <memmove+0x32>
    while(n-- > 0)
 6be:	02c05163          	blez	a2,6e0 <memmove+0x2c>
 6c2:	fff6079b          	addiw	a5,a2,-1
 6c6:	1782                	slli	a5,a5,0x20
 6c8:	9381                	srli	a5,a5,0x20
 6ca:	0785                	addi	a5,a5,1
 6cc:	97aa                	add	a5,a5,a0
  dst = vdst;
 6ce:	872a                	mv	a4,a0
      *dst++ = *src++;
 6d0:	0585                	addi	a1,a1,1
 6d2:	0705                	addi	a4,a4,1
 6d4:	fff5c683          	lbu	a3,-1(a1)
 6d8:	fed70fa3          	sb	a3,-1(a4) # 1fff <__global_pointer$+0xa47>
    while(n-- > 0)
 6dc:	fee79ae3          	bne	a5,a4,6d0 <memmove+0x1c>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 6e0:	6422                	ld	s0,8(sp)
 6e2:	0141                	addi	sp,sp,16
 6e4:	8082                	ret
    dst += n;
 6e6:	00c50733          	add	a4,a0,a2
    src += n;
 6ea:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 6ec:	fec05ae3          	blez	a2,6e0 <memmove+0x2c>
 6f0:	fff6079b          	addiw	a5,a2,-1
 6f4:	1782                	slli	a5,a5,0x20
 6f6:	9381                	srli	a5,a5,0x20
 6f8:	fff7c793          	not	a5,a5
 6fc:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 6fe:	15fd                	addi	a1,a1,-1
 700:	177d                	addi	a4,a4,-1
 702:	0005c683          	lbu	a3,0(a1)
 706:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 70a:	fef71ae3          	bne	a4,a5,6fe <memmove+0x4a>
 70e:	bfc9                	j	6e0 <memmove+0x2c>

0000000000000710 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 710:	1141                	addi	sp,sp,-16
 712:	e422                	sd	s0,8(sp)
 714:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 716:	ce15                	beqz	a2,752 <memcmp+0x42>
 718:	fff6069b          	addiw	a3,a2,-1
    if (*p1 != *p2) {
 71c:	00054783          	lbu	a5,0(a0)
 720:	0005c703          	lbu	a4,0(a1)
 724:	02e79063          	bne	a5,a4,744 <memcmp+0x34>
 728:	1682                	slli	a3,a3,0x20
 72a:	9281                	srli	a3,a3,0x20
 72c:	0685                	addi	a3,a3,1
 72e:	96aa                	add	a3,a3,a0
      return *p1 - *p2;
    }
    p1++;
 730:	0505                	addi	a0,a0,1
    p2++;
 732:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 734:	00d50d63          	beq	a0,a3,74e <memcmp+0x3e>
    if (*p1 != *p2) {
 738:	00054783          	lbu	a5,0(a0)
 73c:	0005c703          	lbu	a4,0(a1)
 740:	fee788e3          	beq	a5,a4,730 <memcmp+0x20>
      return *p1 - *p2;
 744:	40e7853b          	subw	a0,a5,a4
  }
  return 0;
}
 748:	6422                	ld	s0,8(sp)
 74a:	0141                	addi	sp,sp,16
 74c:	8082                	ret
  return 0;
 74e:	4501                	li	a0,0
 750:	bfe5                	j	748 <memcmp+0x38>
 752:	4501                	li	a0,0
 754:	bfd5                	j	748 <memcmp+0x38>

0000000000000756 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 756:	1141                	addi	sp,sp,-16
 758:	e406                	sd	ra,8(sp)
 75a:	e022                	sd	s0,0(sp)
 75c:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 75e:	00000097          	auipc	ra,0x0
 762:	f56080e7          	jalr	-170(ra) # 6b4 <memmove>
}
 766:	60a2                	ld	ra,8(sp)
 768:	6402                	ld	s0,0(sp)
 76a:	0141                	addi	sp,sp,16
 76c:	8082                	ret

000000000000076e <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 76e:	4885                	li	a7,1
 ecall
 770:	00000073          	ecall
 ret
 774:	8082                	ret

0000000000000776 <exit>:
.global exit
exit:
 li a7, SYS_exit
 776:	4889                	li	a7,2
 ecall
 778:	00000073          	ecall
 ret
 77c:	8082                	ret

000000000000077e <wait>:
.global wait
wait:
 li a7, SYS_wait
 77e:	488d                	li	a7,3
 ecall
 780:	00000073          	ecall
 ret
 784:	8082                	ret

0000000000000786 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 786:	4891                	li	a7,4
 ecall
 788:	00000073          	ecall
 ret
 78c:	8082                	ret

000000000000078e <read>:
.global read
read:
 li a7, SYS_read
 78e:	4895                	li	a7,5
 ecall
 790:	00000073          	ecall
 ret
 794:	8082                	ret

0000000000000796 <write>:
.global write
write:
 li a7, SYS_write
 796:	48c1                	li	a7,16
 ecall
 798:	00000073          	ecall
 ret
 79c:	8082                	ret

000000000000079e <close>:
.global close
close:
 li a7, SYS_close
 79e:	48d5                	li	a7,21
 ecall
 7a0:	00000073          	ecall
 ret
 7a4:	8082                	ret

00000000000007a6 <kill>:
.global kill
kill:
 li a7, SYS_kill
 7a6:	4899                	li	a7,6
 ecall
 7a8:	00000073          	ecall
 ret
 7ac:	8082                	ret

00000000000007ae <exec>:
.global exec
exec:
 li a7, SYS_exec
 7ae:	489d                	li	a7,7
 ecall
 7b0:	00000073          	ecall
 ret
 7b4:	8082                	ret

00000000000007b6 <open>:
.global open
open:
 li a7, SYS_open
 7b6:	48bd                	li	a7,15
 ecall
 7b8:	00000073          	ecall
 ret
 7bc:	8082                	ret

00000000000007be <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 7be:	48c5                	li	a7,17
 ecall
 7c0:	00000073          	ecall
 ret
 7c4:	8082                	ret

00000000000007c6 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 7c6:	48c9                	li	a7,18
 ecall
 7c8:	00000073          	ecall
 ret
 7cc:	8082                	ret

00000000000007ce <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 7ce:	48a1                	li	a7,8
 ecall
 7d0:	00000073          	ecall
 ret
 7d4:	8082                	ret

00000000000007d6 <link>:
.global link
link:
 li a7, SYS_link
 7d6:	48cd                	li	a7,19
 ecall
 7d8:	00000073          	ecall
 ret
 7dc:	8082                	ret

00000000000007de <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 7de:	48d1                	li	a7,20
 ecall
 7e0:	00000073          	ecall
 ret
 7e4:	8082                	ret

00000000000007e6 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 7e6:	48a5                	li	a7,9
 ecall
 7e8:	00000073          	ecall
 ret
 7ec:	8082                	ret

00000000000007ee <dup>:
.global dup
dup:
 li a7, SYS_dup
 7ee:	48a9                	li	a7,10
 ecall
 7f0:	00000073          	ecall
 ret
 7f4:	8082                	ret

00000000000007f6 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 7f6:	48ad                	li	a7,11
 ecall
 7f8:	00000073          	ecall
 ret
 7fc:	8082                	ret

00000000000007fe <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 7fe:	48b1                	li	a7,12
 ecall
 800:	00000073          	ecall
 ret
 804:	8082                	ret

0000000000000806 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 806:	48b5                	li	a7,13
 ecall
 808:	00000073          	ecall
 ret
 80c:	8082                	ret

000000000000080e <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 80e:	48b9                	li	a7,14
 ecall
 810:	00000073          	ecall
 ret
 814:	8082                	ret

0000000000000816 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 816:	1101                	addi	sp,sp,-32
 818:	ec06                	sd	ra,24(sp)
 81a:	e822                	sd	s0,16(sp)
 81c:	1000                	addi	s0,sp,32
 81e:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 822:	4605                	li	a2,1
 824:	fef40593          	addi	a1,s0,-17
 828:	00000097          	auipc	ra,0x0
 82c:	f6e080e7          	jalr	-146(ra) # 796 <write>
}
 830:	60e2                	ld	ra,24(sp)
 832:	6442                	ld	s0,16(sp)
 834:	6105                	addi	sp,sp,32
 836:	8082                	ret

0000000000000838 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 838:	7139                	addi	sp,sp,-64
 83a:	fc06                	sd	ra,56(sp)
 83c:	f822                	sd	s0,48(sp)
 83e:	f426                	sd	s1,40(sp)
 840:	f04a                	sd	s2,32(sp)
 842:	ec4e                	sd	s3,24(sp)
 844:	0080                	addi	s0,sp,64
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 846:	c299                	beqz	a3,84c <printint+0x14>
 848:	0005cd63          	bltz	a1,862 <printint+0x2a>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 84c:	2581                	sext.w	a1,a1
  neg = 0;
 84e:	4301                	li	t1,0
 850:	fc040713          	addi	a4,s0,-64
  }

  i = 0;
 854:	4801                	li	a6,0
  do{
    buf[i++] = digits[x % base];
 856:	2601                	sext.w	a2,a2
 858:	00000897          	auipc	a7,0x0
 85c:	54088893          	addi	a7,a7,1344 # d98 <digits>
 860:	a801                	j	870 <printint+0x38>
    x = -xx;
 862:	40b005bb          	negw	a1,a1
 866:	2581                	sext.w	a1,a1
    neg = 1;
 868:	4305                	li	t1,1
    x = -xx;
 86a:	b7dd                	j	850 <printint+0x18>
  }while((x /= base) != 0);
 86c:	85be                	mv	a1,a5
    buf[i++] = digits[x % base];
 86e:	8836                	mv	a6,a3
 870:	0018069b          	addiw	a3,a6,1
 874:	02c5f7bb          	remuw	a5,a1,a2
 878:	1782                	slli	a5,a5,0x20
 87a:	9381                	srli	a5,a5,0x20
 87c:	97c6                	add	a5,a5,a7
 87e:	0007c783          	lbu	a5,0(a5)
 882:	00f70023          	sb	a5,0(a4)
  }while((x /= base) != 0);
 886:	0705                	addi	a4,a4,1
 888:	02c5d7bb          	divuw	a5,a1,a2
 88c:	fec5f0e3          	bleu	a2,a1,86c <printint+0x34>
  if(neg)
 890:	00030b63          	beqz	t1,8a6 <printint+0x6e>
    buf[i++] = '-';
 894:	fd040793          	addi	a5,s0,-48
 898:	96be                	add	a3,a3,a5
 89a:	02d00793          	li	a5,45
 89e:	fef68823          	sb	a5,-16(a3)
 8a2:	0028069b          	addiw	a3,a6,2

  while(--i >= 0)
 8a6:	02d05963          	blez	a3,8d8 <printint+0xa0>
 8aa:	89aa                	mv	s3,a0
 8ac:	fc040793          	addi	a5,s0,-64
 8b0:	00d784b3          	add	s1,a5,a3
 8b4:	fff78913          	addi	s2,a5,-1
 8b8:	9936                	add	s2,s2,a3
 8ba:	36fd                	addiw	a3,a3,-1
 8bc:	1682                	slli	a3,a3,0x20
 8be:	9281                	srli	a3,a3,0x20
 8c0:	40d90933          	sub	s2,s2,a3
    putc(fd, buf[i]);
 8c4:	fff4c583          	lbu	a1,-1(s1)
 8c8:	854e                	mv	a0,s3
 8ca:	00000097          	auipc	ra,0x0
 8ce:	f4c080e7          	jalr	-180(ra) # 816 <putc>
  while(--i >= 0)
 8d2:	14fd                	addi	s1,s1,-1
 8d4:	ff2498e3          	bne	s1,s2,8c4 <printint+0x8c>
}
 8d8:	70e2                	ld	ra,56(sp)
 8da:	7442                	ld	s0,48(sp)
 8dc:	74a2                	ld	s1,40(sp)
 8de:	7902                	ld	s2,32(sp)
 8e0:	69e2                	ld	s3,24(sp)
 8e2:	6121                	addi	sp,sp,64
 8e4:	8082                	ret

00000000000008e6 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 8e6:	7119                	addi	sp,sp,-128
 8e8:	fc86                	sd	ra,120(sp)
 8ea:	f8a2                	sd	s0,112(sp)
 8ec:	f4a6                	sd	s1,104(sp)
 8ee:	f0ca                	sd	s2,96(sp)
 8f0:	ecce                	sd	s3,88(sp)
 8f2:	e8d2                	sd	s4,80(sp)
 8f4:	e4d6                	sd	s5,72(sp)
 8f6:	e0da                	sd	s6,64(sp)
 8f8:	fc5e                	sd	s7,56(sp)
 8fa:	f862                	sd	s8,48(sp)
 8fc:	f466                	sd	s9,40(sp)
 8fe:	f06a                	sd	s10,32(sp)
 900:	ec6e                	sd	s11,24(sp)
 902:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 904:	0005c483          	lbu	s1,0(a1)
 908:	18048d63          	beqz	s1,aa2 <vprintf+0x1bc>
 90c:	8aaa                	mv	s5,a0
 90e:	8b32                	mv	s6,a2
 910:	00158913          	addi	s2,a1,1
  state = 0;
 914:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 916:	02500a13          	li	s4,37
      if(c == 'd'){
 91a:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c == 'l') {
 91e:	06c00c93          	li	s9,108
        printint(fd, va_arg(ap, uint64), 10, 0);
      } else if(c == 'x') {
 922:	07800d13          	li	s10,120
        printint(fd, va_arg(ap, int), 16, 0);
      } else if(c == 'p') {
 926:	07000d93          	li	s11,112
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 92a:	00000b97          	auipc	s7,0x0
 92e:	46eb8b93          	addi	s7,s7,1134 # d98 <digits>
 932:	a839                	j	950 <vprintf+0x6a>
        putc(fd, c);
 934:	85a6                	mv	a1,s1
 936:	8556                	mv	a0,s5
 938:	00000097          	auipc	ra,0x0
 93c:	ede080e7          	jalr	-290(ra) # 816 <putc>
 940:	a019                	j	946 <vprintf+0x60>
    } else if(state == '%'){
 942:	01498f63          	beq	s3,s4,960 <vprintf+0x7a>
  for(i = 0; fmt[i]; i++){
 946:	0905                	addi	s2,s2,1
 948:	fff94483          	lbu	s1,-1(s2)
 94c:	14048b63          	beqz	s1,aa2 <vprintf+0x1bc>
    c = fmt[i] & 0xff;
 950:	0004879b          	sext.w	a5,s1
    if(state == 0){
 954:	fe0997e3          	bnez	s3,942 <vprintf+0x5c>
      if(c == '%'){
 958:	fd479ee3          	bne	a5,s4,934 <vprintf+0x4e>
        state = '%';
 95c:	89be                	mv	s3,a5
 95e:	b7e5                	j	946 <vprintf+0x60>
      if(c == 'd'){
 960:	05878063          	beq	a5,s8,9a0 <vprintf+0xba>
      } else if(c == 'l') {
 964:	05978c63          	beq	a5,s9,9bc <vprintf+0xd6>
      } else if(c == 'x') {
 968:	07a78863          	beq	a5,s10,9d8 <vprintf+0xf2>
      } else if(c == 'p') {
 96c:	09b78463          	beq	a5,s11,9f4 <vprintf+0x10e>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
 970:	07300713          	li	a4,115
 974:	0ce78563          	beq	a5,a4,a3e <vprintf+0x158>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 978:	06300713          	li	a4,99
 97c:	0ee78c63          	beq	a5,a4,a74 <vprintf+0x18e>
        putc(fd, va_arg(ap, uint));
      } else if(c == '%'){
 980:	11478663          	beq	a5,s4,a8c <vprintf+0x1a6>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 984:	85d2                	mv	a1,s4
 986:	8556                	mv	a0,s5
 988:	00000097          	auipc	ra,0x0
 98c:	e8e080e7          	jalr	-370(ra) # 816 <putc>
        putc(fd, c);
 990:	85a6                	mv	a1,s1
 992:	8556                	mv	a0,s5
 994:	00000097          	auipc	ra,0x0
 998:	e82080e7          	jalr	-382(ra) # 816 <putc>
      }
      state = 0;
 99c:	4981                	li	s3,0
 99e:	b765                	j	946 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 10, 1);
 9a0:	008b0493          	addi	s1,s6,8
 9a4:	4685                	li	a3,1
 9a6:	4629                	li	a2,10
 9a8:	000b2583          	lw	a1,0(s6)
 9ac:	8556                	mv	a0,s5
 9ae:	00000097          	auipc	ra,0x0
 9b2:	e8a080e7          	jalr	-374(ra) # 838 <printint>
 9b6:	8b26                	mv	s6,s1
      state = 0;
 9b8:	4981                	li	s3,0
 9ba:	b771                	j	946 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 9bc:	008b0493          	addi	s1,s6,8
 9c0:	4681                	li	a3,0
 9c2:	4629                	li	a2,10
 9c4:	000b2583          	lw	a1,0(s6)
 9c8:	8556                	mv	a0,s5
 9ca:	00000097          	auipc	ra,0x0
 9ce:	e6e080e7          	jalr	-402(ra) # 838 <printint>
 9d2:	8b26                	mv	s6,s1
      state = 0;
 9d4:	4981                	li	s3,0
 9d6:	bf85                	j	946 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 9d8:	008b0493          	addi	s1,s6,8
 9dc:	4681                	li	a3,0
 9de:	4641                	li	a2,16
 9e0:	000b2583          	lw	a1,0(s6)
 9e4:	8556                	mv	a0,s5
 9e6:	00000097          	auipc	ra,0x0
 9ea:	e52080e7          	jalr	-430(ra) # 838 <printint>
 9ee:	8b26                	mv	s6,s1
      state = 0;
 9f0:	4981                	li	s3,0
 9f2:	bf91                	j	946 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 9f4:	008b0793          	addi	a5,s6,8
 9f8:	f8f43423          	sd	a5,-120(s0)
 9fc:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 a00:	03000593          	li	a1,48
 a04:	8556                	mv	a0,s5
 a06:	00000097          	auipc	ra,0x0
 a0a:	e10080e7          	jalr	-496(ra) # 816 <putc>
  putc(fd, 'x');
 a0e:	85ea                	mv	a1,s10
 a10:	8556                	mv	a0,s5
 a12:	00000097          	auipc	ra,0x0
 a16:	e04080e7          	jalr	-508(ra) # 816 <putc>
 a1a:	44c1                	li	s1,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 a1c:	03c9d793          	srli	a5,s3,0x3c
 a20:	97de                	add	a5,a5,s7
 a22:	0007c583          	lbu	a1,0(a5)
 a26:	8556                	mv	a0,s5
 a28:	00000097          	auipc	ra,0x0
 a2c:	dee080e7          	jalr	-530(ra) # 816 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 a30:	0992                	slli	s3,s3,0x4
 a32:	34fd                	addiw	s1,s1,-1
 a34:	f4e5                	bnez	s1,a1c <vprintf+0x136>
        printptr(fd, va_arg(ap, uint64));
 a36:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 a3a:	4981                	li	s3,0
 a3c:	b729                	j	946 <vprintf+0x60>
        s = va_arg(ap, char*);
 a3e:	008b0993          	addi	s3,s6,8
 a42:	000b3483          	ld	s1,0(s6)
        if(s == 0)
 a46:	c085                	beqz	s1,a66 <vprintf+0x180>
        while(*s != 0){
 a48:	0004c583          	lbu	a1,0(s1)
 a4c:	c9a1                	beqz	a1,a9c <vprintf+0x1b6>
          putc(fd, *s);
 a4e:	8556                	mv	a0,s5
 a50:	00000097          	auipc	ra,0x0
 a54:	dc6080e7          	jalr	-570(ra) # 816 <putc>
          s++;
 a58:	0485                	addi	s1,s1,1
        while(*s != 0){
 a5a:	0004c583          	lbu	a1,0(s1)
 a5e:	f9e5                	bnez	a1,a4e <vprintf+0x168>
        s = va_arg(ap, char*);
 a60:	8b4e                	mv	s6,s3
      state = 0;
 a62:	4981                	li	s3,0
 a64:	b5cd                	j	946 <vprintf+0x60>
          s = "(null)";
 a66:	00000497          	auipc	s1,0x0
 a6a:	34a48493          	addi	s1,s1,842 # db0 <digits+0x18>
        while(*s != 0){
 a6e:	02800593          	li	a1,40
 a72:	bff1                	j	a4e <vprintf+0x168>
        putc(fd, va_arg(ap, uint));
 a74:	008b0493          	addi	s1,s6,8
 a78:	000b4583          	lbu	a1,0(s6)
 a7c:	8556                	mv	a0,s5
 a7e:	00000097          	auipc	ra,0x0
 a82:	d98080e7          	jalr	-616(ra) # 816 <putc>
 a86:	8b26                	mv	s6,s1
      state = 0;
 a88:	4981                	li	s3,0
 a8a:	bd75                	j	946 <vprintf+0x60>
        putc(fd, c);
 a8c:	85d2                	mv	a1,s4
 a8e:	8556                	mv	a0,s5
 a90:	00000097          	auipc	ra,0x0
 a94:	d86080e7          	jalr	-634(ra) # 816 <putc>
      state = 0;
 a98:	4981                	li	s3,0
 a9a:	b575                	j	946 <vprintf+0x60>
        s = va_arg(ap, char*);
 a9c:	8b4e                	mv	s6,s3
      state = 0;
 a9e:	4981                	li	s3,0
 aa0:	b55d                	j	946 <vprintf+0x60>
    }
  }
}
 aa2:	70e6                	ld	ra,120(sp)
 aa4:	7446                	ld	s0,112(sp)
 aa6:	74a6                	ld	s1,104(sp)
 aa8:	7906                	ld	s2,96(sp)
 aaa:	69e6                	ld	s3,88(sp)
 aac:	6a46                	ld	s4,80(sp)
 aae:	6aa6                	ld	s5,72(sp)
 ab0:	6b06                	ld	s6,64(sp)
 ab2:	7be2                	ld	s7,56(sp)
 ab4:	7c42                	ld	s8,48(sp)
 ab6:	7ca2                	ld	s9,40(sp)
 ab8:	7d02                	ld	s10,32(sp)
 aba:	6de2                	ld	s11,24(sp)
 abc:	6109                	addi	sp,sp,128
 abe:	8082                	ret

0000000000000ac0 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 ac0:	715d                	addi	sp,sp,-80
 ac2:	ec06                	sd	ra,24(sp)
 ac4:	e822                	sd	s0,16(sp)
 ac6:	1000                	addi	s0,sp,32
 ac8:	e010                	sd	a2,0(s0)
 aca:	e414                	sd	a3,8(s0)
 acc:	e818                	sd	a4,16(s0)
 ace:	ec1c                	sd	a5,24(s0)
 ad0:	03043023          	sd	a6,32(s0)
 ad4:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 ad8:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 adc:	8622                	mv	a2,s0
 ade:	00000097          	auipc	ra,0x0
 ae2:	e08080e7          	jalr	-504(ra) # 8e6 <vprintf>
}
 ae6:	60e2                	ld	ra,24(sp)
 ae8:	6442                	ld	s0,16(sp)
 aea:	6161                	addi	sp,sp,80
 aec:	8082                	ret

0000000000000aee <printf>:

void
printf(const char *fmt, ...)
{
 aee:	711d                	addi	sp,sp,-96
 af0:	ec06                	sd	ra,24(sp)
 af2:	e822                	sd	s0,16(sp)
 af4:	1000                	addi	s0,sp,32
 af6:	e40c                	sd	a1,8(s0)
 af8:	e810                	sd	a2,16(s0)
 afa:	ec14                	sd	a3,24(s0)
 afc:	f018                	sd	a4,32(s0)
 afe:	f41c                	sd	a5,40(s0)
 b00:	03043823          	sd	a6,48(s0)
 b04:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 b08:	00840613          	addi	a2,s0,8
 b0c:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 b10:	85aa                	mv	a1,a0
 b12:	4505                	li	a0,1
 b14:	00000097          	auipc	ra,0x0
 b18:	dd2080e7          	jalr	-558(ra) # 8e6 <vprintf>
}
 b1c:	60e2                	ld	ra,24(sp)
 b1e:	6442                	ld	s0,16(sp)
 b20:	6125                	addi	sp,sp,96
 b22:	8082                	ret

0000000000000b24 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 b24:	1141                	addi	sp,sp,-16
 b26:	e422                	sd	s0,8(sp)
 b28:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 b2a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b2e:	00000797          	auipc	a5,0x0
 b32:	2aa78793          	addi	a5,a5,682 # dd8 <freep>
 b36:	639c                	ld	a5,0(a5)
 b38:	a805                	j	b68 <free+0x44>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 b3a:	4618                	lw	a4,8(a2)
 b3c:	9db9                	addw	a1,a1,a4
 b3e:	feb52c23          	sw	a1,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 b42:	6398                	ld	a4,0(a5)
 b44:	6318                	ld	a4,0(a4)
 b46:	fee53823          	sd	a4,-16(a0)
 b4a:	a091                	j	b8e <free+0x6a>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 b4c:	ff852703          	lw	a4,-8(a0)
 b50:	9e39                	addw	a2,a2,a4
 b52:	c790                	sw	a2,8(a5)
    p->s.ptr = bp->s.ptr;
 b54:	ff053703          	ld	a4,-16(a0)
 b58:	e398                	sd	a4,0(a5)
 b5a:	a099                	j	ba0 <free+0x7c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b5c:	6398                	ld	a4,0(a5)
 b5e:	00e7e463          	bltu	a5,a4,b66 <free+0x42>
 b62:	00e6ea63          	bltu	a3,a4,b76 <free+0x52>
{
 b66:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 b68:	fed7fae3          	bleu	a3,a5,b5c <free+0x38>
 b6c:	6398                	ld	a4,0(a5)
 b6e:	00e6e463          	bltu	a3,a4,b76 <free+0x52>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 b72:	fee7eae3          	bltu	a5,a4,b66 <free+0x42>
  if(bp + bp->s.size == p->s.ptr){
 b76:	ff852583          	lw	a1,-8(a0)
 b7a:	6390                	ld	a2,0(a5)
 b7c:	02059713          	slli	a4,a1,0x20
 b80:	9301                	srli	a4,a4,0x20
 b82:	0712                	slli	a4,a4,0x4
 b84:	9736                	add	a4,a4,a3
 b86:	fae60ae3          	beq	a2,a4,b3a <free+0x16>
    bp->s.ptr = p->s.ptr;
 b8a:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 b8e:	4790                	lw	a2,8(a5)
 b90:	02061713          	slli	a4,a2,0x20
 b94:	9301                	srli	a4,a4,0x20
 b96:	0712                	slli	a4,a4,0x4
 b98:	973e                	add	a4,a4,a5
 b9a:	fae689e3          	beq	a3,a4,b4c <free+0x28>
  } else
    p->s.ptr = bp;
 b9e:	e394                	sd	a3,0(a5)
  freep = p;
 ba0:	00000717          	auipc	a4,0x0
 ba4:	22f73c23          	sd	a5,568(a4) # dd8 <freep>
}
 ba8:	6422                	ld	s0,8(sp)
 baa:	0141                	addi	sp,sp,16
 bac:	8082                	ret

0000000000000bae <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 bae:	7139                	addi	sp,sp,-64
 bb0:	fc06                	sd	ra,56(sp)
 bb2:	f822                	sd	s0,48(sp)
 bb4:	f426                	sd	s1,40(sp)
 bb6:	f04a                	sd	s2,32(sp)
 bb8:	ec4e                	sd	s3,24(sp)
 bba:	e852                	sd	s4,16(sp)
 bbc:	e456                	sd	s5,8(sp)
 bbe:	e05a                	sd	s6,0(sp)
 bc0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 bc2:	02051993          	slli	s3,a0,0x20
 bc6:	0209d993          	srli	s3,s3,0x20
 bca:	09bd                	addi	s3,s3,15
 bcc:	0049d993          	srli	s3,s3,0x4
 bd0:	2985                	addiw	s3,s3,1
 bd2:	0009891b          	sext.w	s2,s3
  if((prevp = freep) == 0){
 bd6:	00000797          	auipc	a5,0x0
 bda:	20278793          	addi	a5,a5,514 # dd8 <freep>
 bde:	6388                	ld	a0,0(a5)
 be0:	c515                	beqz	a0,c0c <malloc+0x5e>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 be2:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 be4:	4798                	lw	a4,8(a5)
 be6:	03277f63          	bleu	s2,a4,c24 <malloc+0x76>
 bea:	8a4e                	mv	s4,s3
 bec:	0009871b          	sext.w	a4,s3
 bf0:	6685                	lui	a3,0x1
 bf2:	00d77363          	bleu	a3,a4,bf8 <malloc+0x4a>
 bf6:	6a05                	lui	s4,0x1
 bf8:	000a0a9b          	sext.w	s5,s4
  p = sbrk(nu * sizeof(Header));
 bfc:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 c00:	00000497          	auipc	s1,0x0
 c04:	1d848493          	addi	s1,s1,472 # dd8 <freep>
  if(p == (char*)-1)
 c08:	5b7d                	li	s6,-1
 c0a:	a885                	j	c7a <malloc+0xcc>
    base.s.ptr = freep = prevp = &base;
 c0c:	00008797          	auipc	a5,0x8
 c10:	3b478793          	addi	a5,a5,948 # 8fc0 <base>
 c14:	00000717          	auipc	a4,0x0
 c18:	1cf73223          	sd	a5,452(a4) # dd8 <freep>
 c1c:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 c1e:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 c22:	b7e1                	j	bea <malloc+0x3c>
      if(p->s.size == nunits)
 c24:	02e90b63          	beq	s2,a4,c5a <malloc+0xac>
        p->s.size -= nunits;
 c28:	4137073b          	subw	a4,a4,s3
 c2c:	c798                	sw	a4,8(a5)
        p += p->s.size;
 c2e:	1702                	slli	a4,a4,0x20
 c30:	9301                	srli	a4,a4,0x20
 c32:	0712                	slli	a4,a4,0x4
 c34:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 c36:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 c3a:	00000717          	auipc	a4,0x0
 c3e:	18a73f23          	sd	a0,414(a4) # dd8 <freep>
      return (void*)(p + 1);
 c42:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 c46:	70e2                	ld	ra,56(sp)
 c48:	7442                	ld	s0,48(sp)
 c4a:	74a2                	ld	s1,40(sp)
 c4c:	7902                	ld	s2,32(sp)
 c4e:	69e2                	ld	s3,24(sp)
 c50:	6a42                	ld	s4,16(sp)
 c52:	6aa2                	ld	s5,8(sp)
 c54:	6b02                	ld	s6,0(sp)
 c56:	6121                	addi	sp,sp,64
 c58:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 c5a:	6398                	ld	a4,0(a5)
 c5c:	e118                	sd	a4,0(a0)
 c5e:	bff1                	j	c3a <malloc+0x8c>
  hp->s.size = nu;
 c60:	01552423          	sw	s5,8(a0)
  free((void*)(hp + 1));
 c64:	0541                	addi	a0,a0,16
 c66:	00000097          	auipc	ra,0x0
 c6a:	ebe080e7          	jalr	-322(ra) # b24 <free>
  return freep;
 c6e:	6088                	ld	a0,0(s1)
      if((p = morecore(nunits)) == 0)
 c70:	d979                	beqz	a0,c46 <malloc+0x98>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 c72:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 c74:	4798                	lw	a4,8(a5)
 c76:	fb2777e3          	bleu	s2,a4,c24 <malloc+0x76>
    if(p == freep)
 c7a:	6098                	ld	a4,0(s1)
 c7c:	853e                	mv	a0,a5
 c7e:	fef71ae3          	bne	a4,a5,c72 <malloc+0xc4>
  p = sbrk(nu * sizeof(Header));
 c82:	8552                	mv	a0,s4
 c84:	00000097          	auipc	ra,0x0
 c88:	b7a080e7          	jalr	-1158(ra) # 7fe <sbrk>
  if(p == (char*)-1)
 c8c:	fd651ae3          	bne	a0,s6,c60 <malloc+0xb2>
        return 0;
 c90:	4501                	li	a0,0
 c92:	bf55                	j	c46 <malloc+0x98>
