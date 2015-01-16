.text
	j 		main
interruptIn:
	mfc0 	$t0, 	$13			# Cause
	addi	$t1,	$zero,	0x1
	beq		$t0,	$t1,	syscall_I
	addi	$t1,	$zero,	0x2
	beq		$t0,	$t1,	uart_I
	addi	$t1,	$zero,	0x4
	beq		$t0,	$t1,	keyboard_I
	addi	$t1,	$zero,	0x5
	addi	$t1,	$zero,	0x8
	beq		$t0,	$t1,	timer_I

	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
vectorTable:
	add 	$zero, 	$zero, 	$zero
	j 		syscall_I
	j 		keyboard_I

# $v0 kept in the register
# 
# 
syscall_I:
	beq 	$v0,	$zero, 	printChar			# 0 => printChar
	addi 	$v0, 	$v0,	-1
	beq 	$v0,	$zero, 	serialRead			# 1 => serialRead
	addi 	$v0,	$v0, 	-1
	beq 	$v0,	$zero, 	serialWrite			# 2 => serialWrite
	addi 	$v0,	$v0, 	-1					
	beq 	$v0,	$zero, 	clearScreen			# 3 => clearScreen
	addi 	$v0,	$v0, 	-1					
	beq 	$v0,	$zero, 	rollUp				# 4 => rollUp

uart_I:
	
	sw 		$s1,	0($s0)
	addi 	$s0,	$s0,	4
	addi 	$s1,	$s1,	1

	addi 	$t0,  	$zero,	512
read_b:
	lw 		$t1,	0($s3)
	sw 		$t1,	0($s3)
	addi	$t0,	$t0,	-1
	bne 	$t0,	$zero,	read_b
	eret
	
timer_I:




######################################## keyboard interrupt service

keyboard_I:
	# push	
	
	addi	$s1,	$zero, 	0x461
	addi	$t0,	$zero,	0xd000
	lw 		$t1,	0($t0)						# key data
	# addi	$t2,	$
	lw 		$t3,	0xf0($t0)
	# andi	$t3,	$t3,	0xff				# write pointer
	add 	$t3,	$t3,	1 					# move ahead 					
	add 	$t4,	$t0,	$t3
	sw 		$s1,	0($s0)
	addi 	$s0,	$s0,	4

# 	addi	$t3,	$t3, 	0xf0				# write addr
# 	add 	$t3,	$t3,	$t0					# 0xffff_d0f0
# 	lw 		$t4,	0($t3)						# read
# 	andi	$t5,	$t3,	0x3	   				# get byteoffset
# 	beq		$t5,	$zero,	keyOffset00
# 	add 	$t6,	$zero,	1
# 	beq 	$t5,	$t6,	keyOffset01
# 	add 	$t6,	$zero,	2
# 	beq 	$t5,	$t6,	keyOffset10
# 	add 	$t6,	$zero,	3
# 	beq 	$t5,	$t6,	keyOffset11
	
# keyOffset00:
# 	lui		$t5,	0xffff
# 	addi	$s1,	$zero,	0x461
# 	sw 		$s1,	4($s0)
# 	addi	$t5,	$t5,	0xff00
# 	and		$t5, 	$t5,	$t4
# 	andi	$t1,	$t1,	0xff
# 	add		$t5,	$t5,	$t1
# 	sw 		$t5,	0($t0)
# 	j 		writePointer
# keyOffset01:
# 	lui		$t5,	0xffff
# 	addi	$s1,	$zero,	0x262
# 	sw 		$s1,	8($s0)
# 	addi	$t5,	$t5,	0x00ff
# 	and		$t5, 	$t5,	$t4
# 	andi 	$t1,	$t1,	0xff
# 	sll 	$t1,	$t1,	8
# 	add		$t5,	$t5,	$t1
# 	sw 		$t5,	0($t0)
# 	j 		writePointer
# keyOffset10:
# 	lui		$t5,	0xff00
# 	addi	$s1,	$zero,	0x163
# 	sw 		$s1,	0xc($s0)
# 	addi	$t5,	$t5,	0xffff
# 	and		$t5, 	$t5,	$t4
# 	andi 	$t1,	$t1,	0xff
# 	sll 	$t1,	$t1,	16
# 	add		$t5,	$t5,	$t1
# 	sw 		$t5,	0($t0)
# 	j 		writePointer
# keyOffset11:
# 	lui		$t5,	0xff
# 	addi	$s1,	$zero,	0x264
# 	sw 		$s1,	0xf($s0)
# 	addi	$t5,	$t5,	0xffff					# offset 11 the highest byte
# 	and 	$t5, 	$t5,	$t4
# 	andi 	$t1,	$t1,	0xff
# 	sll 	$t1,	$t1,	26
# 	add		$t5,	$t5,	$t1
# 	sw 		$t5,	0($t0)

writePointer:
	sw 		$t3,	0xf0($t0)
	eret


##########################################

printChar:
	# push	
	lui 	$t0, 	0x000c 						# vram
	# lw 		$t1,	ScreenAddr					# global screen address
	add 	$t1, 	$zero, 	8
	add 	$t0,	$t0,	$t1
	sw 		$a0,	0($t0)						# lower 16bits valid
	addi 	$t1, 	$t1,	1
	# sw 		$t1, 	ScreenAddr
	eret

serialRead:
serialWrite:
clearScreen:
rollUp:
	add 	$zero, 	$zero,	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	eret		
 
 main:
 	# add 	$v0, 	$zero, 	$zero
 	addi 	$a0,	$zero, 	0x761
 	# syscall
 	addi 	$t0,	$zero,	0xff
 	lui	 	$s0,	0x000c						# vram addr
 	addi 	$s1,	$zero,	0x161
 	lui 	$s3,	0xfe00
 	mtc0	$t0,	$11
polling:
 	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
 	j 		polling

