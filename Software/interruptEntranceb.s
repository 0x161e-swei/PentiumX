
interruptEntrance.bin:     file format binary


Disassembly of section .data:

00000000 <.data>:
   0:	26000008 	j	0x98
   4:	00000000 	sll	zero,zero,0x0
   8:	00680840 	mfc0	t0,c0_cause
   c:	20400801 	add	t0,t0,t0
  10:	20400801 	add	t0,t0,t0
  14:	0000093c 	lui	t1,0x0
  18:	28002925 	addiu	t1,t1,40
  1c:	20400901 	add	t0,t0,t1
  20:	08000001 	jr	t0
  24:	00000000 	sll	zero,zero,0x0
  28:	20000000 	add	zero,zero,zero
  2c:	0f000008 	j	0x3c
  30:	00000000 	sll	zero,zero,0x0
  34:	1d000008 	j	0x74
  38:	00000000 	sll	zero,zero,0x0
  3c:	0e004010 	beqz	v0,0x78
  40:	00000000 	sll	zero,zero,0x0
  44:	ffff4220 	addi	v0,v0,-1
  48:	11004010 	beqz	v0,0x90
  4c:	00000000 	sll	zero,zero,0x0
  50:	ffff4220 	addi	v0,v0,-1
  54:	0e004010 	beqz	v0,0x90
  58:	00000000 	sll	zero,zero,0x0
  5c:	ffff4220 	addi	v0,v0,-1
  60:	0b004010 	beqz	v0,0x90
  64:	00000000 	sll	zero,zero,0x0
  68:	ffff4220 	addi	v0,v0,-1
  6c:	08004010 	beqz	v0,0x90
  70:	00000000 	sll	zero,zero,0x0
  74:	18000042 	eret
  78:	0c00083c 	lui	t0,0xc
  7c:	08000920 	addi	t1,zero,8
  80:	20400901 	add	t0,t0,t1
  84:	000004a5 	sh	a0,0(t0)
  88:	01002921 	addi	t1,t1,1
  8c:	18000042 	eret
  90:	20000000 	add	zero,zero,zero
  94:	18000042 	eret
  98:	20100000 	add	v0,zero,zero
  9c:	61000420 	addi	a0,zero,97
  a0:	0c000000 	syscall
  a4:	26000008 	j	0x98
  a8:	00000000 	sll	zero,zero,0x0
  ac:	00000000 	sll	zero,zero,0x0
  b0:	00002002 	0x2200000
  b4:	01010005 	bltz	t0,0x4bc
  b8:	00000000 	sll	zero,zero,0x0
  bc:	00000000 	sll	zero,zero,0x0
  c0:	00000000 	sll	zero,zero,0x0
  c4:	00000000 	sll	zero,zero,0x0
