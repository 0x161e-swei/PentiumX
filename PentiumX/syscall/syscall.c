// syscall_code
#define PRINT_INT 1
#define PRINT_STRING 4
#define READ_INT 5
#define READ_STRING 8
#define PRINT_CHAR 11
#define READ_CHAR 12
#define READ 14
#define WRITE 15
// exception_code
#define KB_EXCEPTION 0
#define SYSCALL_EXCEPTION 8
// address
#define CHAR_DEVICE_OFFSET 65536
#define VGA_SIGNAL 66756
#define KB_BUFFER 66498
#define KB_BUFFER_SIZE 254
#define FILE_PORT 328904
#define FILE_BUFFER 328912
#define FILE_INFO 333008
// constant
#define TEXT_WIDTH 40
#define TEXT_HEIGHT 24
// vga_control
#define VGA_IDLE 0
#define VGA_OUTPUT 1
// key_code
#define BACK_SAPCE 0x08
#define ENTER 0x0d
// file operation
#define FILE_IDLE 0
#define SECTION_READ 1
#define SECTION_WRITE 2
// global variable
#define HEX 4

typedef struct{
	unsigned char x, y;
}Point;

typedef struct{
	char name[8];
	char extension[4];// for alignment, use 4 instead of 3
	unsigned int starting_sector;
	unsigned int read_write_head;
}FileInfo;

char* hex;

void Initial()
{
	hex = (char*)HEX;
	hex[0]='0';hex[1]='1';hex[2]='2';hex[3]='3';
	hex[4]='4';hex[5]='5';hex[6]='6';hex[7]='7';
	hex[8]='8';hex[9]='9';hex[10]='a';hex[11]='b';
	hex[12]='c';hex[13]='d';hex[14]='e';hex[15]='f';
}

void Strcpy(char* dest, char* src, unsigned int size)
{
	int i=0;
	while (i<size) {
		dest[i] = src[i];
		if (src[i] == '\0') {
			break;
		}
		i++;
	}
}

void Strcat(char* dest, char* src)
{
	int i=0,j=0;;
	while (dest[i] != '\0') {
		i++;
	}
	while (src[j] != '\0') {
		dest[i] = src[j];
		i++;
		j++;
	}
	dest[j] = '\0';
}

unsigned int Multiply(unsigned int a, unsigned int b)
{
	unsigned int i;
	unsigned int result = 0;
	for (i=0; i<b; i++) {
		result += a;
	}
	return result;
}

unsigned int Mod(unsigned int dividend, unsigned divider)
{
	int i=0;
	while (dividend > divider) {
		dividend -= divider;
	}
	return dividend;
}


void RollScreen()
{
	int i,j;
	char* char_device = (char*)CHAR_DEVICE_OFFSET;

	// copy from next raw to current raw
	for (i=0; i<TEXT_HEIGHT-1; i++) {
		for (j=0; j<TEXT_WIDTH; j++) {
			*(char_device+2+i*TEXT_WIDTH+j) = *(char_device+2+(i+1)*TEXT_WIDTH+j);
		}
	}

	// clear the bottom raw
	for (j=0; j<TEXT_WIDTH; j++) {
		*(char_device+2+(TEXT_HEIGHT-1)*TEXT_WIDTH+j) = '\0';
	}
}

void PrintChar(char a0)
{
	Point cursor;
	char* dest = (char*)VGA_SIGNAL;
	char* char_device = (char*)CHAR_DEVICE_OFFSET;

	// fetch current cursor
	cursor.x = (unsigned char)*(char_device);
	cursor.y = (unsigned char)*(char_device + 1);

	if (a0>=20 && a0<=0xfe) {
		*(char_device +2 + cursor.x*TEXT_WIDTH + cursor.y) = a0;
		if (++cursor.y == TEXT_WIDTH) {
			*(char_device + 1) = 0;
			cursor.x++;
			if (cursor.x == TEXT_HEIGHT) {
				RollScreen();
			}
			else {
				// raw++
				++(*char_device);
			}
		}
		else {
			// column++
			++*(char_device + 1);
		}
	}
	else if (a0 == BACK_SAPCE) {
		if (cursor.y != 0) {
			--cursor.y;
			*(char_device+2+cursor.x*TEXT_WIDTH+cursor.y) = '\0';
			--*(char_device+1);
		}
		else {
			cursor.y == TEXT_WIDTH-1;
			--cursor.x;
			*(char_device+2+cursor.x*TEXT_WIDTH+cursor.y) = '\0';
			--*char_device;
			*(char_device+1) = cursor.y;
		}
	}
	else if (a0 == ENTER) {
		cursor.y = 0;
		if (cursor.x == TEXT_HEIGHT-1) {
			RollScreen();
		}
		else {
			cursor.x++;
		}
		*char_device = cursor.x;
		*(char_device + 1) = cursor.y;
	}

	// repaint screen
	*dest = VGA_OUTPUT;
}

void PrintString(char* str)
{
	int i;

	for (i=0; str[i]!='\0'; i++){
		PrintChar(str[i]);
	}
}

void PrintInt(unsigned int a0)
{
	int i;
	char c;
	for (i=0; i<8; i++) {
		c = (a0&0xf0000000) >> 28;
		PrintChar(hex[c]);
		a0 = a0 << 4;
	}
}

void ReadChar()
{
	char* kb_buffer = (char*)KB_BUFFER;
	char c;
	unsigned char begin, end;
	begin = *kb_buffer;
	end = *(kb_buffer+1);
	if (begin == end) {
		asm ("addiu $a0, $zero, 0");
	}
	else {
		c = *(kb_buffer+2+begin);
		begin++;
		if (begin == KB_BUFFER_SIZE) {
			asm ("add %0, $zero, $zero":"=r"(begin));
		}
		*kb_buffer = begin;
		asm ("add $a0, $zero, %0"::"r"(c));
	}
}

void Read(unsigned short section_number, unsigned short buffer_number)
{
	unsigned short *psn, *pbn;
	unsigned int *file_operation = (unsigned int*)FILE_PORT;
	psn = (unsigned short*)(FILE_PORT+4);
	pbn = (unsigned short*)(FILE_PORT+6);
	*psn = section_number;
	*pbn = buffer_number;
	*file_operation = SECTION_READ;
}

void Write(unsigned short section_number, unsigned short buffer_number)
{
	unsigned short *psn, *pbn;
	unsigned int *file_operation = (unsigned int*)FILE_PORT;
	psn = (unsigned short*)(FILE_PORT+4);
	pbn = (unsigned short*)(FILE_PORT+6);
	*psn = section_number;
	*pbn = buffer_number;
	*file_operation = SECTION_WRITE;
}

void Syscall(unsigned int syscall_code, unsigned int a0, unsigned int a1, unsigned int a2)
{
	switch (syscall_code){
		case PRINT_CHAR:
			PrintChar((char)a0);
			break;
		case PRINT_STRING:
			PrintString((char*)a0);
			break;
		case PRINT_INT:
			PrintInt(a0);
			break;
		case READ_CHAR:
			ReadChar((char*)a0, a1, a2);
			break;
		case READ:
			Read((unsigned short)a0, (unsigned short)a1);
			break;
		case WRITE:
			Write((unsigned short)a0, (unsigned short)a1);
			break;
		default:
			break;
	}
}

int main()
{
	unsigned int syscall_code;
	unsigned int a0, a1, a2;

	// get parameters
	asm ("add %0, $zero, $a2":"=r"(a2));
	asm ("add %0, $zero, $a1":"=r"(a1));
	asm ("add %0, $zero, $a0":"=r"(a0));
	asm ("add %0, $zero, $v0":"=r"(syscall_code));

	Syscall(syscall_code, a0, a1, a2);

	// adjust sp manually
	asm ("lw $ra, 20($sp)");
	asm ("addiu $sp, $sp, 24");
	asm ("eret");
}
