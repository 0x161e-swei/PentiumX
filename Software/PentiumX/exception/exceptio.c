// address
#define KB_EXCEPTION 0
#define KB_BUFFER 66498
#define KB_BUFFER_SIZE 254
#define CHAR_DEVICE 65536

// constant
#define KEY_UP 0xff01
#define KEY_DOWN 0xff02
#define KEY_LEFT 0xff03
#define KEY_RIGHT 0xff04
#define TEXT_HEIGHT 24
#define TEXT_WIDTH 40

void KeyboardException()
{
	unsigned char* char_device = (unsigned char*)CHAR_DEVICE;
	char* kb_buffer = (char*)KB_BUFFER;
	unsigned int c;
	unsigned char begin, end;
	asm ("add %0, $zero, $k0":"=r"(c));
	switch (c) {
	case KEY_UP:
		if (*char_device!= 0) {
			(*char_device)--;
		}
		break;
	case KEY_DOWN:
		if (*char_device!= TEXT_HEIGHT-1) {
			(*char_device)++;
		}
		break;
	case KEY_LEFT:
		if (*(char_device+1) != 0) {
			(*(char_device+1))--;
		}
		break;
	case KEY_RIGHT:
		if (*(char_device+1) != TEXT_WIDTH-1) {
			(*(char_device+1))++;
		}
		break;
	default:
		end = *(kb_buffer+1);
	
		// we do not check buffer overflow
		*(kb_buffer+2+end) = (char)c;
		if (++end == KB_BUFFER_SIZE) {
			asm ("add %0, $zero, $zero":"=r"(end));
		}
		*(kb_buffer+1) = end;
		break;
	}
}

void ExceptionHandler(unsigned int cause)
{
	switch (cause) {
	case KB_EXCEPTION:
		KeyboardException();
		break;
	default:
		break;
	}
}

int main()
{
	unsigned int cause;
	asm ("addiu $sp, $sp, -24");
	asm ("sw $a0, 0($sp)");
	asm ("sw $a1, 4($sp)");
	asm ("sw $a2, 8($sp)");
	asm ("sw $a3, 12($sp)");
	asm ("sw $v0, 14($sp)");
	asm ("sw $v1, 16($sp)");

	asm ("mfc0 %0, $13":"=r"(cause));
	ExceptionHandler(cause);

	asm ("lw $a0, 0($sp)");
	asm ("lw $a1, 4($sp)");
	asm ("lw $a2, 8($sp)");
	asm ("lw $a3, 12($sp)");
	asm ("lw $v0, 14($sp)");
	asm ("lw $v1, 16($sp)");
	asm ("addiu $sp, $sp, 24");

	asm ("lw $ra, 20($sp)");
	asm ("addiu $sp, $sp, 24");
	asm ("eret");
}
