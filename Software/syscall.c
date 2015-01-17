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
// vga_control
#define VGA_IDLE 0
#define VGA_OUTPUT 1
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
	unsigned int size;
}FileInfo;


extern unsigned int* hex;

extern void Strcpy(unsigned int* dest, unsigned int* src, unsigned int size);

extern unsigned int Multiply(unsigned int a, unsigned int b);

extern unsigned int Mod(unsigned int dividend, unsigned divider);

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
		sys_PrintChar(hex[c]);
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
void Sendchar(int  C)
{
	*(int *)COMADR=C;
	return ;
}

//发送请求并接受一个block
void sys_Recv(unsigned int block)
{
	unsigned int end;
	unsigned int blocks;
	end=(unsigned int)('#') ;
	Sendchar((unsigned int) ('!'));
	while(1)
	{
		// 把数字拆成8进制
		blocks = block & 0x00000007;
		block = block >> 3;
		Sendchar(blocks);
		if (block<=0)break;
	}
	Sendchar(end);  
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
	BlockOffset=0;

	Sendchar((unsigned int) ('*'));
	while(1)
	{
		blocks = block & 0x00000007;
		block = block >> 3;
		Sendchar(blocks);
		if (block<=0)break;
	}
	Sendchar((unsigned int) ('#'));
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
		case SendIns:
			sys_Recv(a0);
			break;
		case SendBlock:
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
	asm ("addiu $sp, $sp, -20");
	asm ("sw $a0, 0($sp)");
	asm ("sw $a1, 4($sp)");
	asm ("sw $v0, 8($sp)");
	asm ("sw $v1, 12($sp)");
	asm ("sw $ra, 16($sp)");


	int WOffset;               //第几个word
	int BOffset;                //word中的第几个byte
	int BlockOffset;
	unsigned int aword=0;    //一个字
	if (*(int*)OFFSET == 512) {
		*(int*)OFFSET=0;
	}
	BlockOffset = *(int*)OFFSET;
	*(int *)OFFSET = *(int*)OFFSET+1;
	WOffset = BlockOffset >> 2;            
	BOffset = BlockOffset & 0x00000003;          

	aword = *(unsigned int*)COMADR >> (BOffset<<3);
	*(int*)(FILE_BUFFER+WOffset) = aword+*(int*)(FILE_BUFFER+WOffset); 

	asm ("lw $a0, 0($sp)");
	asm ("lw $a1, 4($sp)");
	asm ("lw $v0, 8($sp)");
	asm ("lw $v1, 12($sp)");
	asm ("lw $ra, 16($sp)");
	asm ("addiu $sp, $sp, 20");
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
{}

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
