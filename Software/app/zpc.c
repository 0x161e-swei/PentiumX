int main()
{
	unsigned int a[7];
	a[0] = 0xab;
	a[1] = 0xd0;
	a[2] = ',';
	a[3] = 'Z';
	a[4] = 'P';
	a[5] = 'C';
	a[6] = '\0';
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $a0, $zero, %0"::"r"(a));
	asm ("add $v0, $zero, 4");
	asm ("syscall");

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
	asm ("jr $ra");
}

//void Exec(unsigned int* argv[])
//{
//	OpenFile(argv[1], 0, 0);
//	asm ("jal 0x1234");
//}
