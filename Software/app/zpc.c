#define ENTER  0x0d;
int main()
{
	unsigned int a[8];
	a[0] = 0xab + 0x700;
	a[1] = 0xd0 + 0x700;
	a[2] = ',' + 0x700;
	a[3] = 'Z' + 0x700;
	a[4] = 'P' + 0x700;
	a[5] = 'C' + 0x700;
	a[6] = ENTER + 0x700;
	a[7] = '\0';
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $a0, $zero, %0"::"r"(a));
	asm ("add $v0, $zero, 4");
	asm ("syscall");

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
	asm ("addiu $sp, $sp, 40");
	asm ("jr $ra");
}

//void Exec(unsigned int* argv[])
//{
//	OpenFile(argv[1], 0, 0);
//	asm ("jal 0x1234");
//}
