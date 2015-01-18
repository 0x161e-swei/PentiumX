// syscall_code
#define PRINT_INT 1
#define PRINT_STRING 4
#define READ_INT 5
#define READ_STRING 8
#define PRINT_CHAR 11
#define READ_CHAR 12
#define READ 14
#define WRITE 15
#define SendIns 23    //syscall_code
#define SendBlock 25    //syscall_code
// mipscom
#define OFFSET 0x00007a08     //存
// 数据时的偏移量
#define COMADR 0xfe000000     //串口地址
// address
#define KB_BUFFER 0x00007f00
#define KEY_CODE 0xffffd000
#define KB_BUFFER_SIZE 15
#define FILE_BUFFER 0x00007a08
#define FILE_INFO 0x00007a00
#define GPIO 0xffffff00
#define VRAM 0x000c0000
// constant
#define TEXT_WIDTH 40
#define TEXT_HEIGHT 30
// key_code
#define BACK_SAPCE 0x08
#define ENTER 0x0d
#define CAPSLOCK   0x14
// file operation
#define FILE_IDLE 0
#define SECTION_READ 1
#define SECTION_WRITE 2
// global variable
#define CODE_SEGMENT 12
#define CONSOLE (CODE_SEGMENT+16)
#define ERROR (CONSOLE+40)
#define CMD_DIR (ERROR+28)
#define CMD_TYPE (CMD_DIR+16)
#define CMD_RENAME (CMD_TYPE+20)
#define CMD_EXIT (CMD_RENAME+16)
#define CMD_DEL (CMD_EXIT+20)
#define CMD_TOUCH (CMD_DEL+16)
#define CMD_EXEC (CMD_TOUCH+24)
#define CMD_LOU (CMD_EXEC+20)
#define HEX (CMD_LOU+16)
#define CHAR_DEVICE (HEX+64)
#define KEYF0IN		(CHAR_DEVICE + 8)
#define CAPSON 		(KEYF0IN + 4)

typedef struct{
	unsigned int x, y;
}Point;

typedef struct{
	unsigned short current_sector;
	unsigned short read_write_head;
	unsigned short size;
	unsigned short is_valid;
}FileInfo;


extern unsigned int* hex;

extern void Strcpy(unsigned int* dest, unsigned int* src, unsigned int size);

extern unsigned int Multiply(unsigned int a, unsigned int b);

extern unsigned int Mod(unsigned int dividend, unsigned divider);

extern volatile FileInfo* file_info;

extern int main();

asm ("j main");

asm ("j IntEntry");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");


asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");

asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");

asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");
asm ("nop");asm ("nop");asm ("nop");asm ("nop");asm ("nop");



void RollScreen()
{
	int i,j;
	unsigned int* vram = (unsigned int*)VRAM;

	// copy from next raw to current raw
	for (i=0; i<TEXT_HEIGHT-1; i++) {
		for (j=0; j<TEXT_WIDTH; j++) {
			*(vram + Multiply(TEXT_WIDTH, i) + j) 
			= *(vram + Multiply(TEXT_WIDTH, i+1) + j);
		}
	}

	// clear the bottom raw
	for (j=0; j<TEXT_WIDTH; j++) {
		*(vram + Multiply(TEXT_WIDTH, TEXT_HEIGHT-1) + j) = 0;
	}
}

void sys_PrintChar(unsigned int a0)
{
	Point cursor;
	unsigned int* gpio = (unsigned int*)GPIO;
	unsigned int* vram = (unsigned int*)VRAM;
	unsigned int* char_device = (unsigned int*)CHAR_DEVICE;

	// fetch current cursor
	cursor.x = *(char_device);
	cursor.y = *(char_device + 1);


	if ((a0 & 0xff) >= 20 && (a0 & 0xff) <= 0xff) {
		*(vram + Multiply(TEXT_WIDTH, cursor.x) + cursor.y) = a0;
		cursor.y++;
		if (cursor.y == TEXT_WIDTH) {
			*(char_device + 1) = 0;
		
			asm ("sll $t0, %0, 16"::"r"(*char_device));
			asm ("sll $t1, %0, 10"::"r"(*(char_device+1)));
			asm ("add $t0, $t0, $t1");
			asm ("sw $t0, 0(%0)"::"r"(gpio));
			
			//*gpio &= 0xffff03ff;
			cursor.x++;
			if (cursor.x == TEXT_HEIGHT) {
				RollScreen();
			}
			else {
				// raw++
				++(*char_device);
				asm ("sll $t0, %0, 16"::"r"(*char_device));
				asm ("sll $t1, %0, 10"::"r"(*(char_device+1)));
				asm ("add $t0, $t0, $t1");
				asm ("sw $t0, 0(%0)"::"r"(gpio));

				//*gpio += 0x10000;
			}
		}
		else {
			// column++
			++*(char_device+1);
			asm ("sll $t0, %0, 16"::"r"(*char_device));
			asm ("sll $t1, %0, 10"::"r"(*(char_device+1)));
			asm ("add $t0, $t0, $t1");
			asm ("sw $t0, 0(%0)"::"r"(gpio));

			//*gpio += 0x400;
		}
	}
	else if ((a0 & 0xff) == BACK_SAPCE) {
		if (cursor.y != 0) {
			--cursor.y;
			*(vram + Multiply(TEXT_WIDTH, cursor.x) + cursor.y) = 0;
			--*(char_device+1);
			asm ("sll $t0, %0, 16"::"r"(*char_device));
			asm ("sll $t1, %0, 10"::"r"(*(char_device+1)));
			asm ("add $t0, $t0, $t1");
			asm ("sw $t0, 0(%0)"::"r"(gpio));

			//*gpio -= 0x400;
		}
		else {
			cursor.y = TEXT_WIDTH-1;
			--cursor.x;
			*(vram + Multiply(TEXT_WIDTH, cursor.x) + cursor.y) = 0;
			--*char_device;
			asm ("sll $t0, %0, 16"::"r"(*char_device));
			asm ("sll $t1, %0, 10"::"r"(*(char_device+1)));
			asm ("add $t0, $t0, $t1");
			asm ("sw $t0, 0(%0)"::"r"(gpio));
	
			//*gpio -= 0x10000;
			//*gpio &= 0xffff03ff;
			//*gpio += 0x00009c00;
		}
	}
	else if ((a0 & 0xff) == ENTER) {
		//*gpio &= 0xffff03ff;
		*(char_device+1) = 0;
		if (cursor.x == TEXT_HEIGHT-1) {
			RollScreen();
		}
		else {
			++*char_device;
			//*gpio += 0x10000;
		}
		asm ("sll $t0, %0, 16"::"r"(*char_device));
		asm ("sll $t1, %0, 10"::"r"(*(char_device+1)));
		asm ("add $t0, $t0, $t1");
		asm ("sw $t0, 0(%0)"::"r"(gpio));

	}
}

void sys_PrintString(unsigned int* str)
{
	int i;

	for (i=0; str[i] != '\0'; i++){
		sys_PrintChar(str[i]);
	}
}

void sys_PrintInt(unsigned int a0)
{
	int i;
	char c;
	for (i=0; i<8; i++) {
		c = (a0&0xf0000000) >> 28;
		sys_PrintChar(hex[c]+0x700);
		a0 = a0 << 4;
	}
}

/**
 * This is a syscalll function
 * The syscall read a Word from 0x00007f04 to 0x00007f3c
 * And move the return it with $a0
 */
void sys_ReadChar()
{
	unsigned int* kb_buffer = (unsigned int*)KB_BUFFER;
	unsigned int c;
	unsigned int begin, end;
	begin = ((*kb_buffer) & 0xffff0000) >> 16;
	end = (*kb_buffer) & 0x0000ffff;
	if (begin == end) {
		asm ("addiu $a0, $zero, 0");
	}
	else {
		c = *(kb_buffer+1+begin);
		begin++;
		if (begin == KB_BUFFER_SIZE) {
			asm ("add %0, $zero, $zero":"=r"(begin));
		}
		*kb_buffer &= 0x0000ffff;
		*kb_buffer += begin<<16;
		asm ("add $a0, $zero, %0"::"r"(c));
	}
}

// void sys_Read(unsigned short section_number, unsigned short buffer_number)
// {
// 	unsigned short *psn, *pbn;
// 	unsigned int *file_operation = (unsigned int*)FILE_PORT;
// 	psn = (unsigned short*)(FILE_PORT+4);
// 	pbn = (unsigned short*)(FILE_PORT+6);
// 	*psn = section_number;
// 	*pbn = buffer_number;
// 	*file_operation = SECTION_READ;
// }

// void sys_Write(unsigned short section_number, unsigned short buffer_number)
// {
// 	unsigned short *psn, *pbn;
// 	unsigned int *file_operation = (unsigned int*)FILE_PORT;
// 	psn = (unsigned short*)(FILE_PORT+4);
// 	pbn = (unsigned short*)(FILE_PORT+6);
// 	*psn = section_number;
// 	*pbn = buffer_number;
// 	*file_operation = SECTION_WRITE;
// }

/*---将发送的字符存在串口地址高位---*/
void Sendchar(unsigned int  C)
{
	*(unsigned int *)COMADR=C;
	return ;
}

//发送请求并接受一个block
void sys_Recv(unsigned int block)
{
	unsigned int blocks;
	unsigned int* vram = (unsigned int*)VRAM;
	// asm("syscall");asm("syscall");asm("syscall");
	file_info->current_sector = block;
	// asm("syscall");asm("syscall");asm("syscall");
	file_info->is_valid = 0;
	// asm("syscall");asm("syscall");asm("syscall");
	volatile unsigned int* com = (unsigned int*)COMADR;
	// TODO: whatever
	// *(vram + 0x100) = 0x461;
	*com = (unsigned int)'!';
	// *(vram + 0x104) = 0x462;
	// *(vram + 0x106) = 0x400 | block;
	while(1)
	{
		// 把数字拆成8进制
		blocks = block & 0x000000ff;
		block = block >> 8;
		// asm("syscall");asm("syscall");asm("syscall");
		*com = (unsigned int)blocks;
		// asm("syscall");asm("syscall");asm("syscall");
		// asm("syscall");asm("syscall");asm("syscall");
		// asm("syscall");asm("syscall");asm("syscall");
		if (block<=0)break;
	}
	// *(vram + 0x108) = 0x463;
	*com = (unsigned int)'#';
	// *(vram + 0x10c) = 0x464;
	// *(vram + 0x110) = 0x400 | block;
	

}

//发送一个block至pc端
void sys_Sendblock(unsigned int block)
{
	unsigned int WOffset;               //第几个word
	unsigned int BOffset;                //word中的第几个byte
	unsigned int aword=0;            //一个word
	unsigned int BlockOffset;
	unsigned int blocks;
	unsigned int shift_number;
	volatile unsigned int* com = (unsigned int*)COMADR;
	BlockOffset=0;

	*com = (unsigned int)'*';
	while(1)
	{
		blocks = block & 0x000000ff;
		block = block >> 8;
		*com = blocks;
		if (block<=0)break;
	}
	*com = (unsigned int)'#';
	for(;BlockOffset<512;)
	{
		aword=0;
		WOffset=BlockOffset >> 2;            
		BOffset=BlockOffset & 0x00000003;          

		shift_number = (3-BOffset)<<3;
		aword = *(unsigned int*)(FILE_BUFFER+WOffset);
		while (shift_number){
			aword >>= 1;
			shift_number--;
		}
		//aword= *(unsigned int* )(FILE_BUFFER+WOffset)>>((3-BOffset)<<3);
		Sendchar(aword);
		BlockOffset++;
	}
}

void Syscall()
{
	unsigned int syscall_code;
	unsigned int a0, a1, a2;
	unsigned int* vram = (unsigned int*)VRAM;

	// get parameters
	asm ("add %0, $zero, $a2":"=r"(a2));
	asm ("add %0, $zero, $a1":"=r"(a1));
	asm ("add %0, $zero, $a0":"=r"(a0));
	asm ("add %0, $zero, $v0":"=r"(syscall_code));

	switch (syscall_code){
		case PRINT_CHAR:
			sys_PrintChar(a0);
			break;
		case PRINT_STRING:
			sys_PrintString((unsigned int*)a0);
			break;
		case PRINT_INT:
			sys_PrintInt(a0);
			break;
		case READ_CHAR:
			sys_ReadChar(a0, a1, a2);
			break;
		// case READ:
		// 	sys_Read((unsigned short)a0, (unsigned short)a1);
		// 	break;
		// case WRITE:
		// 	sys_Write((unsigned short)a0, (unsigned short)a1);
		// 	break;
		case READ:
			// *(vram + 0x124) = 0x261;
			sys_Recv(a0);
			// *(vram + 0x128) = 0x262;
			break;
		case WRITE:
			sys_Sendblock(a0);
			break;
		default:
			break;
	}
	asm	("lw $ra, 20($sp)");
	asm ("addiu $sp, $sp, 24");
	asm ("eret");
}

void Uart()
{
	asm ("addiu $sp, $sp, -68");
	asm ("sw $a0, 0($sp)");
	asm ("sw $a1, 4($sp)");
	asm ("sw $v0, 8($sp)");
	asm ("sw $v1, 12($sp)");
	asm ("sw $t0, 16($sp)");
	asm ("sw $t1, 20($sp)");
	asm ("sw $t2, 24($sp)");
	asm ("sw $t3, 28($sp)");
	asm ("sw $t4, 32($sp)");
	asm ("sw $t5, 36($sp)");
	asm ("sw $t6, 40($sp)");
	asm ("sw $t7, 44($sp)");
	asm ("sw $t8, 48($sp)");
	asm ("sw $t9, 52($sp)");
	asm ("sw $a2, 56($sp)");
	asm ("sw $a3, 60($sp)");
	asm ("sw $ra, 64($sp)");

	// asm ("srl $t0, $sp, 0");
	// asm ("addi $t0, $t0, 0x780");
	// asm ("sw $sp, 2400(%0)"::"r"((unsigned int*)VRAM));

	// asm ("srl $t0, $sp, 8");
	// asm ("addi $t0, $t0, 0x780");
	// asm ("sw $t0, 2408(%0)"::"r"((unsigned int*)VRAM));

	// asm ("srl $t0, $sp, 16");
	// asm ("addi $t0, $t0, 0x780");
	// asm ("sw $t0, 2412(%0)"::"r"((unsigned int*)VRAM));

	// asm ("srl $t0, $sp, 24");
	// asm ("addi $t0, $t0, 0x780");
	// asm ("sw $t0, 2416(%0)"::"r"((unsigned int*)VRAM));


	// asm ("sw $t0, 2416(%0)"::"r"((unsigned int*)VRAM));

	unsigned int WOffset, i;               //第几个word
	unsigned int BOffset;                //word中的第几个byte
	unsigned int BlockOffset;
	volatile unsigned int aword=0;    //一个字
	unsigned int* vram = (unsigned int*)VRAM;
	volatile unsigned int temp;


	// *(vram + 0x210 - 1) = 0x461;
	for (i=0; i<512; i++){
		WOffset = i >> 2;            
		BOffset = i & 0x00000003; 
     	
		aword = *(unsigned int*)COMADR;
		asm("nop");
		asm("nop");
		// *(unsigned int*)COMADR = aword;
		aword -= 0x100;
		// aword &= 0xff;
		// *(vram + 0x210 + i) = (aword | 0x400);
		switch (BOffset) {
			case 0:
				aword <<= 24;
				temp = 0x00ffffff;
				// asm ("lui $s0, 0xff");
				// asm ("andi $s0, 0xffff");
				// asm ("and %0, %1, $s0":"r"():""();
				*(unsigned int*)(FILE_BUFFER+WOffset) &= temp;
				break;
			case 1:
				aword <<= 16;
				*(unsigned int*)(FILE_BUFFER+WOffset) &= 0xff00ffff;
				break;
			case 2:
				aword <<= 8;
				*(unsigned int*)(FILE_BUFFER+WOffset) &= 0xffff00ff;
			break;
			case 3:
				*(unsigned int*)(FILE_BUFFER+WOffset) &= 0xffffff00;
			break;
		}
		asm("nop");
		asm("nop");		
		aword |= *(unsigned int*)(FILE_BUFFER+WOffset);
		*(unsigned int*)(FILE_BUFFER+WOffset) = aword;
		// *(vram + 0x240) = 0x262;
		// *(vram + 0x244 + i) = *(unsigned int*)(FILE_BUFFER+WOffset);
	} 
	// *(vram + 0x210 + i) = 0x461;\
	// TODO: 
	// asm ("add $t7, $zero, %0"::"r"(file_info->is_valid + 0x480));
	// asm ("sw $t7, 2420(%0)"::"r"((unsigned int*)VRAM));
	file_info->is_valid = 1;
	// asm ("add $t7, $zero, %0"::"r"(file_info->is_valid + 0x480));
	// asm ("sw $t7, 2428(%0)"::"r"((unsigned int*)VRAM));



	asm ("lw $a0, 0($sp)");
	asm ("lw $a1, 4($sp)");
	asm ("lw $v0, 8($sp)");
	asm ("lw $v1, 12($sp)");
	asm ("lw $t0, 16($sp)");
	asm ("lw $t1, 20($sp)");
	asm ("lw $t2, 24($sp)");
	asm ("lw $t3, 28($sp)");
	asm ("lw $t4, 32($sp)");
	asm ("lw $t5, 36($sp)");
	asm ("lw $t6, 40($sp)");
	asm ("lw $t7, 44($sp)");
	asm ("lw $t8, 48($sp)");
	asm ("lw $t9, 52($sp)");
	asm ("lw $a2, 56($sp)");
	asm ("lw $a3, 60($sp)");
	asm ("lw $ra, 64($sp)");
	
	// asm ("lw $a0, 0($sp)");
	// asm ("lw $a1, 4($sp)");
	// asm ("lw $v0, 8($sp)");
	// asm ("lw $v1, 12($sp)");
	// asm ("lw $ra, 16($sp)");
	asm ("addiu $sp, $sp, 68");
	asm ("addiu $sp, $sp, 8");
	asm ("eret");
}

void Ps2()
{
	asm ("addiu $sp, $sp, -20");
	asm ("sw $a0, 0($sp)");
	asm ("sw $a1, 4($sp)");
	asm ("sw $v0, 8($sp)");
	asm ("sw $v1, 12($sp)");
	asm ("sw $ra, 16($sp)");

	unsigned int* kb_buffer = (unsigned int*)KB_BUFFER;
	unsigned int c;
	unsigned int end;
	end = (*kb_buffer) & 0x0000ffff;
	c = *(unsigned int*)KEY_CODE;

	if (c == 0x1f0 ) {
		*(unsigned int *)KEYF0IN = 1;
		goto ps2_rtn;	
	}
	else if (*(unsigned int *)KEYF0IN == 1){
		*(unsigned int *)KEYF0IN = 0;
		goto ps2_rtn;		
	}
	else {
		*(unsigned int *)KEYF0IN = 0;
	}
		
	*(kb_buffer+1+end) = c;
	end++;
	if (end == KB_BUFFER_SIZE){
		asm ("add %0, $zero, $zero":"=r"(end));
	}
	*(kb_buffer) &= 0xffff0000;
	*(kb_buffer) += end;

ps2_rtn:
	asm ("lw $a0, 0($sp)");
	asm ("lw $a1, 4($sp)");
	asm ("lw $v0, 8($sp)");
	asm ("lw $v1, 12($sp)");
	asm ("lw $ra, 16($sp)");
	asm ("addiu $sp, $sp, 20");
	asm ("eret");
}

void Timer()
{
	asm ("eret");	
}

int IntEntry()
{
	asm ("mfc0 $t0, $13");
	asm ("addi $t1, $zero, 1");
	asm ("bne $t0, $t1, after_syscall");
	asm ("j Syscall");


	asm ("after_syscall:");
	asm ("addi $t1, $zero, 2");
	asm ("bne $t0, $t1, after_uart");
	asm ("j  Uart");


	asm ("after_uart:");
	asm ("addi $t1, $zero, 4");
	asm ("bne $t0, $t1, after_ps2");
	asm ("j  Ps2");


	asm ("after_ps2:");
	asm ("addi $t1, $zero, 8");
	asm ("bne $t0, $t1, after_timer");
	asm ("j  Timer");


	asm ("after_timer:");

	//asm ("addi $t1, $zero, 16");
	//asm ("bne $t0, $t1, after_error");
	//asm ("jal ");
	//after_error:

	// adjust sp manually
	asm ("eret");
}