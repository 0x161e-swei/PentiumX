// syscall_code
#define PRINT_INT 1
#define PRINT_STRING 4
#define READ_INT 5
#define READ_STRING 8
#define PRINT_CHAR 11
#define READ_CHAR 12
#define OPEN 13
#define READ 14
#define WRITE 15
#define CLOSE 16
// address
#define CODE_SEGMENT 66760
#define CHAR_DEVICE 65536
#define KB_BUFFER 66500
#define FILE_BUFFER 328912
#define FILE_INFO 333008
// global variable
#define CONSOLE (CODE_SEGMENT+4)
#define ERROR (CONSOLE+10)
#define CMD_DIR (ERROR+7)
#define CMD_TYPE (CMD_DIR+4)
#define CMD_RENAME (CMD_TYPE+5)
#define CMD_EXIT (CMD_RENAME+4)
#define CMD_DEL (CMD_EXIT+5)
#define CMD_TOUCH (CMD_DEL+4)
#define CMD_EXEC (CMD_TOUCH+6)
#define CMD_LOU (CMD_EXEC+5)
// key code
#define BACK_SPACE 0x08
#define ENTER 0x0d
// file operations
#define FILE_IDLE 0
#define FILE_READ 14
#define FILE_WRITE 15
#define FILE_NORMAL 0
#define FILE_ERROR 1
#define FILE_EOF 2
#define FILE_MODE_BINARY 0
#define FILE_MODE_CHAR 1
#define FILE_MODE_IN 2
#define FILE_MODE_OUT 4
// disk address
#define CATALOG_OFFSET 159
#define DATA_OFFSET 191
#define BLOCK_SIZE 512
// constant
#define TRUE 1
#define FALSE 0
#define TEXT_HEIGHT 24
#define TEXT_WIDTH 40

typedef int BOOL;

typedef struct{
	unsigned short current_sector;
	unsigned short read_write_head;
	unsigned int size;
}FileInfo;

typedef struct{
	char name[8];
	char extension[3];
	unsigned char nature;
	char reserved[10];
	unsigned short time;
	unsigned short date;
	unsigned short starting_sector;
	unsigned int size;
}CatalogItem;

char* console;
char* error;
char* cmd_dir;
char* cmd_type;
char* cmd_rename;
char* cmd_exit;
char* cmd_del;
char* cmd_touch;
char* cmd_exec;
char* cmd_lou;
FileInfo* file_info;

void Initial()
{
	char* address;
	// initial CHAR_DEVICE
	address = (char*)CHAR_DEVICE;
	*address = 0;
	*(address+1) = 0;

	// initial KB_BUFFER
	address = (char*)KB_BUFFER;
	*address = 0;
	*(address+1) = 0;

	// initial global variable
	console = (char*)CONSOLE;
	console[0] = 'C'; console[1] = 'o'; console[2] = 'n'; console[3] = 's'; console[4] = 'o';
	console[5] = 'l'; console[6] = 'e'; console[7] = '>'; console[8] = '>'; console[9] = '\0';

	error = (char*)ERROR;
	error[0] = 'E'; error[1] = 'r'; error[2] = 'r'; error[3] = 'o';
	error[4] = 'r'; error[5] = '!'; error[6] = '\0';

	cmd_dir = (char*)CMD_DIR;
	cmd_dir[0] = 'd'; cmd_dir[1] = 'i'; cmd_dir[2] = 'r'; cmd_dir[3] = '\0'; 

	cmd_type = (char*)CMD_TYPE;
	cmd_type[0] = 't'; cmd_type[1] = 'y'; cmd_type[2] = 'p'; cmd_type[3] = 'e'; cmd_type[4] = '\0';

	cmd_rename = (char*)CMD_RENAME;
	cmd_rename[0] = 'r'; cmd_rename[1] = 'e'; cmd_rename[2] = 'n'; cmd_rename[3] = '\0';

	cmd_exit = (char*)CMD_EXIT;
	cmd_exit[0] = 'e'; cmd_exit[1] = 'x'; cmd_exit[2] = 'i'; cmd_exit[3] = 't'; cmd_exit[4] = '\0';

	cmd_del = (char*)CMD_DEL;
	cmd_del[0] = 'd'; cmd_del[1] = 'e'; cmd_del[2] = 'l'; cmd_del[3] = '\0';

	cmd_touch = (char*)CMD_TOUCH;
	cmd_touch[0] = 't'; cmd_touch[1] = 'o'; cmd_touch[2] = 'u'; cmd_touch[3] = 'c'; cmd_touch[4] = 'h'; cmd_touch[5] = '\0';

	cmd_exec = (char*)CMD_EXEC;
	cmd_exec[0] = 'e'; cmd_exec[1] = 'x'; cmd_exec[2] = 'e'; cmd_exec[3] = 'c'; cmd_exec[4] = '\0';

	cmd_lou = (char*)CMD_LOU;
	cmd_lou[0] = 'l'; cmd_lou[1] = 'o'; cmd_lou[2] = 'u'; cmd_lou[3] = '\0'; 

	file_info = (FileInfo*)FILE_INFO;
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
	// extra chars covered by 0
	for (; i<size; i++) {
		dest[i] = '\0';
	}
}

BOOL Strcmp(const char* s1, const char* s2, unsigned int size)
{
	int i;
	for (i=0; i<size; i++) {
		if (s1[i]=='\0' && s2[i]=='\0') {
			return TRUE;
		}
		else if (s1[i]=='\0' && s2[i]!='\0') {
			return FALSE;
		}
		else if (s1[i]!='\0' && s2[i]=='\0') {
			return FALSE;
		}
		else if (s1[i]-s2[i] != 0) {
			return FALSE;
		}
	}
	return TRUE;
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

unsigned int Divide(unsigned int dividend, unsigned divider)
{
	int i=0;
	while (dividend >= divider) {
		dividend -= divider;
		i++;
	}
	return i;
}

unsigned int Mod(unsigned int dividend, unsigned divider)
{
	while (dividend >= divider) {
		dividend -= divider;
	}
	return dividend;
}

char ReadChar()
{
	char a0;
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $v0, $zero, 12");
	asm ("syscall");
	asm ("add %0, $zero, $a0":"=r"(a0));

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
	return a0;
}

void PrintChar(char c)
{
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $a0, $zero, %0"::"r"(c));
	asm ("add $v0, $zero, 11");
	asm ("syscall");

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
}

void PrintString(char* str)
{
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $a0, $zero, %0"::"r"(str));
	asm ("add $v0, $zero, 4");
	asm ("syscall");

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
}

void PrintInt(unsigned int i)
{
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $a0, $zero, %0"::"r"(i));
	asm ("add $v0, $zero, 1");
	asm ("syscall");

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
}


// split file_name to name and extension
void SplitName(char* file_name, char* name, char* extension)
{
	unsigned int i, j;
	for (i=0; i<8; i++) {
		if (file_name[i] == '.') {
			name[i] = '\0';
			break;
		}
		name[i] = file_name[i];
	}
	i++;
	for (j=0; j<3; j++) {
		extension[j] = file_name[i];
		if (file_name[i] == '\0') {
			break;
		}
		i++;
	}
}

void SectionRead(unsigned int section_number)
{
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $a0, $zero, %0"::"r"(section_number));
	asm ("add $a1, $zero, $zero");
	asm ("add $v0, $zero, 14");
	asm ("syscall");

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
}

void SectionWrite(unsigned int section_number)
{
	asm ("addiu $sp, $sp, -4");
	asm ("sw $ra, 0($sp)");

	asm ("add $a0, $zero, %0"::"r"(section_number));
	asm ("add $a1, $zero, $zero");
	asm ("add $v0, $zero, 15");
	asm ("syscall");

	asm ("lw $ra, 0($sp)");
	asm ("addiu $sp, $sp, 4");
}

void OpenFile(char* file_name, unsigned int flag, unsigned int mode)
{
	CatalogItem* item;
	char name[9], extension[4];
	unsigned int i,j;
	unsigned short file_sectors[9];
	int current_sector, next_sector;

	SplitName(file_name, name, extension);
	// search in catalog
	for (i=0; i<32; i++) {
		SectionRead(CATALOG_OFFSET+i);
		item = (CatalogItem*)FILE_BUFFER;
		for (j=0; j<16; j++) {
			if (Strcmp(item->name, name, 8)==TRUE 
				&& Strcmp(item->extension, extension, 3)==TRUE) {
				break;
			}
			else {
				item++;
			}
		}
		if (j != 16) {
			break;
		}
	}
	// if cannot find the file
	if (i == 32) {
		PrintString(error);
		PrintChar(ENTER);
		file_info->current_sector = 0xff;
		file_info->read_write_head = 0;
		file_info->size = 0;
		return;
	}
	else {
		// set file_info
		file_info->current_sector = item->starting_sector;
		file_info->read_write_head = 0;
		file_info->size = item->size;
		// read file
		SectionRead(DATA_OFFSET+file_info->current_sector-2);
	}
}

// length must less than 512
void ReadFile(char* buffer, unsigned int length)
{
	int i;
	char* file = (char*)FILE_BUFFER;
	unsigned int fat_sector;
	unsigned short next_sector;
	unsigned int sum_of_sectors;

	// the last sector
	if (file_info->read_write_head+length > file_info->size) {
		length = file_info->size - file_info->read_write_head;
		for (i=0; i<length; i++) {
			buffer[i] = file[file_info->read_write_head++];
		}
	}
	// cross sectors
	else if (file_info->read_write_head+length > 512) {
		length -= 512 - file_info->read_write_head;
		for (i=0; file_info->read_write_head<512; i++) {
			buffer[i] = file[file_info->read_write_head++];
		}
		fat_sector = file_info->current_sector >> 8; 
		// read FAT
		SectionRead(fat_sector+1);
		next_sector = *(unsigned short*)(file+((file_info->current_sector&0xff)<<1)); 
		// read file
		SectionRead(DATA_OFFSET+next_sector-2);
		file_info->current_sector = next_sector;
		file_info->read_write_head = 0;
		file_info->size -= 512;
		for (; length>0; length--) {
			buffer[i] = file[file_info->read_write_head];
			file_info->read_write_head++;
			i++;
		}
	}
	// simple case
	else {
		for (i=0; i<length; i++) {
			buffer[i] = file[file_info->read_write_head++];
		}
	}
}

void ClearScreen()
{
	char* char_device = (char*)CHAR_DEVICE;
	unsigned int i, j;
	
	*char_device = 0;
	*(char_device+1) = 0;
	for (i=0; i<TEXT_HEIGHT; i++) {
		for (j=0; j<TEXT_WIDTH; j++) {
			PrintChar(20);
		}
	}
	*char_device = 0;
	*(char_device+1) = 0;
}

void Dir()
{
	CatalogItem* item;
	char name[9], extension[4];
	char empty[1];
	int i,j;

	empty[0] = '\0';
	// search in catalog
	for (i=0; i<32; i++) {
		SectionRead(CATALOG_OFFSET+i);
		item = (CatalogItem*)FILE_BUFFER;
		for (j=0; j<16; j++) {
			if (Strcmp(item->name, empty, 8)==FALSE) {
				Strcpy(name, item->name, 8);
				Strcpy(extension, item->extension, 3);
				name[8] = '\0';
				extension[3] = '\0';
				PrintString(name);
				PrintChar('.');
				PrintString(extension);
				PrintChar(ENTER);
			}
			item++;
		}
	}
}

void Type(char* argv[])
{
	int i, j;
	char* file = (char*)FILE_BUFFER;
	unsigned int sum_sectors;
	unsigned short fat_sector, next_sector;

	OpenFile(argv[1], 0, 0);

	sum_sectors = (file_info->size >> 9) + 1;

	for (i=0; i<sum_sectors; i++) {
		if (i == sum_sectors-1) {
			for (j=0; j<file_info->size; j++) {
				PrintChar(file[j]);
			}
		}
		else {
			for (j=0; j<512; j++) {
				PrintChar(file[j]);
			}
			fat_sector = file_info->current_sector >> 8; // divide by 256
			// read FAT
			SectionRead(fat_sector+1);
			next_sector = *(unsigned short*)(file+((file_info->current_sector&0xff)<<1));
			// read file
			SectionRead(DATA_OFFSET+next_sector-2);
			file_info->current_sector = next_sector;
			file_info->read_write_head = 0;
		}
	}
	PrintChar(ENTER);
}

void Rename(char* argv[])
{
	CatalogItem* item;
	char name[9], extension[4];
	char new_name[9], new_extension[4];
	unsigned int i,j;

	SplitName(argv[1], name, extension);
	SplitName(argv[2], new_name, new_extension);
	// search in catalog
	for (i=0; i<32; i++) {
		SectionRead(CATALOG_OFFSET+i);
		item = (CatalogItem*)FILE_BUFFER;
		for (j=0; j<16; j++) {
			if (Strcmp(item->name, name, 8)==TRUE 
				&& Strcmp(item->extension, extension, 3)==TRUE) {

				Strcpy(item->name, new_name, 8);
				Strcpy(item->extension, new_extension, 3);
				SectionWrite(CATALOG_OFFSET+i);
				return;
			}
			else {
				item++;
			}
		}
	}
	// if cannot find the file
	if (i == 32) {
		PrintString(error);
		PrintChar(ENTER);
		file_info->current_sector = 0;
		file_info->read_write_head = 0;
		file_info->size = 0;
		return;
	}
}

void Touch(char* argv[])
{
	CatalogItem* item;
	char name[9], extension[4];
	char empty[0];
	unsigned int i,j;
	unsigned short sector_number;
	char* file = (char*)FILE_BUFFER;
	
	empty[0] = '\0';

	SplitName(argv[1], name, extension);
	// read FAT
	for (i=0; i<79; i++) {
		SectionRead(1+i);
		for (j=0; j<512; j+=2) {
			sector_number = *(unsigned short*)(file+j);
			if (sector_number == 0) {
				*(unsigned short*)(file+j) = 0xffff;
				sector_number = (i<<8) + (j>>1);
				// write 2 FAT
				SectionWrite(1+i);
				SectionWrite(80+i);
				goto out;
			}
		}
	}
out:
	// search in catalog
	for (i=0; i<32; i++) {
		SectionRead(CATALOG_OFFSET+i);
		item = (CatalogItem*)FILE_BUFFER;
		for (j=0; j<16; j++) {
			if (Strcmp(item->name, empty, 8)==TRUE) {
				Strcpy(item->name, name, 8);
				Strcpy(item->extension, extension, 3);
				item->size = 0;
				item->starting_sector = sector_number;
				SectionWrite(CATALOG_OFFSET+i);

				return;
			}
			else {
				item++;
			}
		}
	}
}

void Del(char* argv[]) 
{
	CatalogItem* item;
	char name[9], extension[4];
	unsigned int i,j;
	unsigned short next_sector;
	char* file = (char*)FILE_BUFFER;

	SplitName(argv[1], name, extension);
	// search in catalog
	for (i=0; i<32; i++) {
		SectionRead(CATALOG_OFFSET+i);
		item = (CatalogItem*)FILE_BUFFER;
		for (j=0; j<16; j++) {
			if (Strcmp(item->name, name, 8)==TRUE 
				&& Strcmp(item->extension, extension, 3)==TRUE) {
				item->name[0] = '\0';
				item->extension[0] = '\0';
				item->size = 0;
				file_info->current_sector = item->starting_sector;
				SectionWrite(CATALOG_OFFSET+i);
				goto clear;
			}
			else {
				item++;
			}
		}
	}
	// if cannot find the file
	if (i == 32) {
		PrintString(error);
		PrintChar(ENTER);
		file_info->current_sector = 0;
		file_info->read_write_head = 0;
		file_info->size = 0;
		return;
	}
	// clear FAT
clear:
	do {
		SectionRead(1+(file_info->current_sector>>8));
		next_sector = *(unsigned short*)(file+((file_info->current_sector&0xff)<<1));
		*(unsigned short*)(file+((file_info->current_sector&0xff)<<1)) = 0;
		SectionWrite(1+(file_info->current_sector>>8));
		SectionWrite(80+(file_info->current_sector>>8));
		file_info->current_sector = next_sector;
	}
	while (next_sector != 0xffff);
}

BOOL PutDown(char c)
{
	char* char_device = (char*)CHAR_DEVICE;
	char current_c;
	current_c = *(char_device+Multiply(TEXT_WIDTH,*(char_device))+*(char_device+1)+2);
	if (current_c == 'x' || current_c == 'o') {
		return FALSE;
	}
	else {
		PrintChar(c);
		if (*(char_device+1) == 0) {
			*(char_device+1) = TEXT_WIDTH - 1;
			(*char_device)--;
		}
		else {
			(*(char_device+1))--;
		}
		return TRUE;
	}
}

BOOL CheckWin(char current)
{
	char* char_device = (char*)CHAR_DEVICE;
	unsigned int i, j, count, result, raw, col, dot;

	raw = *char_device;
	col = *(char_device+1);
	// check four directions in turn
	// 0 degree
	count = 1;
	dot = Multiply(TEXT_WIDTH, raw) + col;
	for (i=1; i<=4; i++) {
		if (col >= i 
			&& *(char_device+2+dot-i) == current) {
			count++;
			if (count == 5) {
				return TRUE;
			}
		}
		else {
			break;
		}
	}
	for (i=1; i<=4; i++) {
		if (col+i <= TEXT_WIDTH-1
			&& *(char_device+2+dot+i) == current) {
			count++;
			if (count == 5) {
				return TRUE;
			}
		}
		else {
			break;
		}
	}
	// 90 degree
	count = 1;
	for (i=1; i<=4; i++) {
		dot -= TEXT_WIDTH;
		if (raw >= i
			&& *(char_device+2+dot) == current) {
			count++;
			if (count == 5) {
				return TRUE;
			}
		}
		else {
			break;
		}
	}
	dot = Multiply(TEXT_WIDTH, raw) + col;
	for (i=1; i<=4; i++) {
		dot += TEXT_WIDTH;
		if (raw+i <= TEXT_HEIGHT-1
			&& *(char_device+2+dot) == current) {
			count++;
			if (count == 5) {
				return TRUE;
			}
		}
		else {
			break;
		}
	}
	return FALSE;
}

void Exec(char* argv[])
{
	char c;
	char* char_device = (char*)CHAR_DEVICE;
	int flag = 0;
	unsigned int i, j, result;
	char xWin[6];
	xWin[0] = 'x'; xWin[1] = ' '; xWin[2] = 'w'; xWin[3] = 'i'; xWin[4] = 'n'; xWin[5] = '\0';
	char oWin[6];
	oWin[0] = 'o'; xWin[1] = ' '; xWin[2] = 'w'; xWin[3] = 'i'; xWin[4] = 'n'; xWin[5] = '\0';

	ClearScreen();
	*char_device = TEXT_HEIGHT>>1;
	*(char_device+1) = TEXT_WIDTH>>1;
	while (1) {
		while (1) {
			c = ReadChar();
			if (c != '\0') {
				break;
			}
		}
		switch (c) {
		case 'x':
			if (flag == 1) {
				break;
			}
			if (PutDown('x') == TRUE) { 
				flag = 1;
				if (CheckWin('x') == TRUE) {
					ClearScreen();
					*char_device = TEXT_HEIGHT>>1;
					*(char_device+1) = (TEXT_WIDTH>>1)-2;
					PrintString(xWin);
					while (1) {
						c = ReadChar();
						if (c == ENTER) {
							break;
						}
					}
					ClearScreen();
					return;
				}
			}
			break;
		case 'o':
			if (flag == 0) {
				break;
			}
			if (PutDown('o') == TRUE) {
				flag = 0;
				if (CheckWin('o') == TRUE) {
					ClearScreen();
					*char_device = TEXT_HEIGHT>>1;
					*(char_device+1) = (TEXT_WIDTH>>1)-2;
					PrintString(oWin);
					while (1) {
						c = ReadChar();
						if (c == ENTER) {
							break;
						}
					}
					ClearScreen();
					return;
				}
			}
			break;
		case ENTER:
			*char_device = 0;
			*(char_device+1) = 0;
			for (i=0; i<TEXT_HEIGHT; i++) {
				for (j=0; j<TEXT_WIDTH; j++) {
					PrintChar(20);
				}
			}
			*char_device = 0;
			*(char_device+1) = 0;
			return;
		default:
			break;
		}
	}
}

void Lou()
{
	char s[23];
	s[0] = 0x80; s[1] = 's'; s[2] = 'i'; s[3] = 'r'; s[4] = ',';
	s[5] = 0xab; s[6] = 0xd0; s[7] = ' '; // 楼sir，你好
	s[8] = ENTER;
	s[9] = 0x84; s[10] = 0x85; s[11] = 0x86;// 魏世嘉
	s[12] = ' ';
	s[13] = 0x87; s[14] = 0x88;// 陈俊
	s[15] = ' ';
	s[16] = 0x89; s[17] = 0x88; s[18] = 0x8a;// 刘俊灏
	s[19] = ' ';
	s[20] = 0x8b; s[21] = 0xf2;// 孙同
	s[22] = '\0';

	PrintString(s);
	PrintChar(ENTER);
}

void Exit()
{
	volatile unsigned int* exit = 0;
	*exit = 1;
}

void ReadLine(char* line)
{
	char c;
	int count = 0;
	while (1) {
		c = ReadChar();
		PrintChar(c);
		switch (c) {
			case '\0':
				break;
			case ENTER:
				line[count] = '\0';
				return;
				break;
			case BACK_SPACE:
				line[--count] = '\0';
				break;
			default:
				if (c>=20 && c<=0xfe) {
					line[count++] = c;
				}
				break;
		}
		// command buffer is full
		if (count == 256) {
			line[0] = '\0';
			PrintChar(ENTER);
			PrintString(error);
			PrintChar(ENTER);
			return;
		}
	}
}

void GetParameter(char* command, int* argc, char** argv)
{
	int i;
	int flag = 0;

	*argc = 0;
	for (i=0;;i++) {
		if (*argc == 3) {
			break;
		}
		if (flag == 0) {
			if (command[i] != ' ') {
				flag = 1;
				argv[*argc] = command+i;
				(*argc)++;
			}
			else {
				continue;
			}
		}
		else {
			if (command[i]==' ' || command[i]=='\0') {
				command[i] = '\0';
				flag = 0;
			}
			else {
				continue;
			}
		}
	}
}

void Execute(unsigned int argc, char* argv[])
{
	char* file = (char*)FILE_BUFFER;
	int i;

	if (Strcmp(argv[0], cmd_dir, 4) == TRUE) {
		Dir();
	}
	else if (Strcmp(argv[0], cmd_type, 5) == TRUE) {
		Type(argv);
	}
	else if (Strcmp(argv[0], cmd_rename, 4) == TRUE) {
		Rename(argv);
	}
	else if (Strcmp(argv[0], cmd_del, 4) == TRUE) {
		Del(argv);
	}
	else if (Strcmp(argv[0], cmd_touch, 6) == TRUE) {
		Touch(argv);
	}
	else if (Strcmp(argv[0], cmd_exec, 5) == TRUE) {
		Exec(argv);
	}
	else if (Strcmp(argv[0], cmd_exit, 5) == TRUE) {
		Exit();
	}
	else if (Strcmp(argv[0], cmd_lou, 4) == TRUE) {
		Lou();
	}
	else {
		PrintString(error);
		PrintChar(ENTER);
	}
}

int main()
{
	char command[25];
	int i;
	int argc;
	char* argv[3];

	Initial();
	
	while (1) {
		for (i=0; i<25; i++) {
			command[i] = '\0';
		}
		PrintString(console);
		ReadLine(command);
		GetParameter(command, &argc, argv);
		Execute(argc, argv);
	}
	
	return 0;
}
