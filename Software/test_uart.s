.text
	lui $s3, 0xfe00 # $s3=fe00000：uart端口
	#lui $s2, 0x000c #vram
	addi	$t1, $zero, 0xff
Loop:
	sw		$t1, 0($s3)
	j		Loop