.text
	j 		main
interruptIn:
	mfc0 	$t0, 	$13			# Cause
	add 	$t0,	$t0, 	$t0
	add 	$t0,	$t0, 	$t0
	la 		$t1, 	vectorTable
	add 	$t0, 	$t0, 	$t1
	jr		$t0
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

keyboard_I:
	# push	
	eret
#

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
 	add 	$v0, 	$zero, 	$zero
 	addi 	$a0,	$zero, 	0x761
 	syscall
 	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
	add 	$zero, 	$zero, 	$zero
 	j 		main

