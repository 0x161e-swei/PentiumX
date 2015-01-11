#include "stdafx.h"
#include <string>
#include "VirtualDisk.h"
#include "MipsCPU.h"
using std::string;

MipsCPU* MipsCPU::GetInstance()
{
	static bool init = false;
	static MipsCPU* cpu;
	if (init == false) {
		cpu = new MipsCPU();
		init = true;
	}
	return cpu;
}

bool MipsCPU::Boot()
{
	File* boot_bin;
	boot_bin = vhd->read(string("boot.bin"));
	if (boot_bin == nullptr) {
		return false;
	}
	memcpy(memory + CODE_SEGMENT_OFFSET, boot_bin->content, boot_bin->size);
	delete boot_bin;

	File* syscall_bin;
	syscall_bin = vhd->read(string("syscall.bin"));
	if (syscall_bin == nullptr) {
		return false;
	}
	memcpy(memory, syscall_bin->content, syscall_bin->size);
	delete syscall_bin;

	return true;
}

void MipsCPU::RePaint()
{
	if (memory[VGA_SIGNAL] != VGA_OUTPUT) {
		return;
	}

	for (auto i = 0; i < TEXT_HEIGHT; i++) {
		for (auto j = 0; j < TEXT_WIDTH; j++) {
			char temp = memory[CHAR_DEVICE_OFFSET + 2 + i*TEXT_WIDTH + j];
			WriteTerminal(i, j, temp);
		}
	}
	memory[VGA_SIGNAL] = VGA_IDLE;
}

void MipsCPU::FileOperation()
{
	//typedef struct {
	//	unsigned int operation;
	//	unsigned int mode;
	//	char file_name[8];
	//	char file_extension[4];
	//	unsigned int read_write_head;
	//	unsigned int file_size;
	//	unsigned int modified_flag;
	//	unsigned int buffer_using_flag;
	//	unsigned int file_status;
	//}file_info;

	UINT32* file_operation = reinterpret_cast<UINT32*>(memory+FILE_BUFFER_OFFSET);
	if (*file_operation == FILE_IDLE) {
		return;
	}

	UINT32* file_size= reinterpret_cast<UINT32*>(memory+FILE_BUFFER_OFFSET+24);
	UINT32* file_read_write_head = reinterpret_cast<UINT32*>(memory+FILE_BUFFER_OFFSET+20);
	UINT32* file_status = reinterpret_cast<UINT32*>(memory+FILE_BUFFER_OFFSET+36);
	UINT32* file_modified_flag = reinterpret_cast<UINT32*>(memory+FILE_BUFFER_OFFSET+28);

	File* file;
	VirtualDisk* pVhd = VirtualDisk::getInstance();
	char file_name[9], file_extension[4];
	VirtualDisk::strcpy_v(file_name,reinterpret_cast<char*>(memory+FILE_BUFFER_OFFSET+8), 8);
	VirtualDisk::strcpy_v(file_extension, reinterpret_cast<char*>(memory+FILE_BUFFER_OFFSET+16), 3);
	file_name[8] = file_extension[3] = '\0';
	file = pVhd->read(string(file_name)+string(".")+string(file_extension));

	UINT32 length, num;
	switch (*reinterpret_cast<UINT32*>(memory+FILE_BUFFER_OFFSET)) {
	case FILE_OPEN:
		length = file->size < FILE_BUFFER_SIZE ? file->size:FILE_BUFFER_SIZE;
		memcpy(memory+FILE_BUFFER_OFFSET+FILE_INFO_SIZE, file->content, length);
		*file_size = file->size;
		*file_status = FILE_NORMAL;
		break;
	case FILE_READ:
		num = file->size/FILE_BUFFER_SIZE;
		if (*file_modified_flag == 1) {
			// 写回
			memcpy(file->content+(num-1)*FILE_BUFFER_SIZE, memory+FILE_BUFFER_OFFSET+FILE_INFO_SIZE, FILE_BUFFER_SIZE);
		}
		length = file->size-num*FILE_BUFFER_SIZE < FILE_BUFFER_SIZE ? file->size-num*FILE_BUFFER_SIZE:FILE_BUFFER_SIZE;
		// 取回新块
		memcpy(memory+FILE_BUFFER_OFFSET+FILE_INFO_SIZE, file->content+num*FILE_BUFFER_SIZE, length);
		break;
	case FILE_CLOSE:
		file->size = *file_size;
		num = *file_read_write_head/FILE_BUFFER_SIZE;
		// 最后一块特殊情况
		if (file->size/FILE_BUFFER_SIZE == num) {
			memcpy(file->content+num*FILE_BUFFER_SIZE, memory+FILE_BUFFER_OFFSET+FILE_INFO_SIZE, file->size%FILE_BUFFER_SIZE);
		}
		else {
			memcpy(file->content+num*FILE_BUFFER_SIZE, memory+FILE_BUFFER_OFFSET+FILE_INFO_SIZE, FILE_BUFFER_SIZE);
		}
		pVhd->write(file);
		break;
	default:
		break;
	}
	*file_operation = FILE_IDLE;
}

void MipsCPU::Step()
{
	RePaint();
	FileOperation();

	while(pc_mutex == true);
	pc_mutex = true;

	if (pc + 4 >= MEMORY_SIZE) {
		pc = CODE_SEGMENT_OFFSET;
	}

	instruction =
		(static_cast<UINT32>(memory[pc + 3]) << 24)
		| (static_cast<UINT32>(memory[pc + 2]) << 16)
		| (static_cast<UINT32>(memory[pc + 1]) << 8)
		| static_cast<UINT32>(memory[pc]);
	pc += 4;

	// 初始化一些值
	reg[zero] = 0;
	overflow = false;
	if (instruction == Eret) {
		if (cp0[Cause] != SYSCALL_EXCEPTION) {
			reg[a0] = memory[reg[sp]+0];
			reg[a1] = memory[reg[sp]+4];
			reg[a2] = memory[reg[sp]+8];
			reg[a3] = memory[reg[sp]+12];
			reg[v0] = memory[reg[sp]+16];
			reg[v1] = memory[reg[sp]+20];
			reg[sp] += 24;
		}
		pc = cp0[EPC];
		cp0[Status] &= 0x1111111d;// EXL = 0
		exception_mutex = false;
		pc_mutex = false;
		return;
	}
	if (instruction == Syscall) {
		while (exception_mutex == true);
		exception_mutex = true;
		cp0[Status] |= 0x00000002;// EXL = 1
		cp0[Cause] = SYSCALL_EXCEPTION;
		cp0[EPC] = pc;
		pc = INT_OFFSET;
		pc_mutex = false;
		return;
	}


	byte opcode, rd, rs, rt, func, shift;
	UINT16 immediate;
	UINT32 jumpAdd;
	jumpAdd = instruction & 0x03ffffff;
	immediate = static_cast<UINT16>(instruction & 0x0000ffff);
	opcode = static_cast<byte>((instruction & 0xfc000000) >> 26);
	rs = static_cast<byte>((instruction & 0x03e00000) >> 21);
	rt = static_cast<byte>((instruction & 0x001f0000) >> 16);
	rd = static_cast<byte>((instruction & 0x0000f800) >> 11);
	shift = static_cast<byte>((instruction & 0x000007c0) >> 6);
	func = static_cast<byte>(instruction & 0x0000003f);

	UINT32 srcMem, destMem;
	switch (opcode) {
	case RInstruction:
		switch (func) {
		case Fadd:
			reg[rd] = reg[rs] + reg[rt];
			if (reg[rd] < reg[rs] || reg[rd] < reg[rt]) {
				overflow = true;
			}
			else {
				overflow = false;
			}
			break;
		case Faddu:
			reg[rd] = reg[rs] + reg[rt];
			break;
		case Fand:
			reg[rd] = reg[rs] & reg[rt];
			break;
		case Fjalr:
			reg[rd] = pc;
			pc = reg[rs];
			break;
		case Fjr:
			pc = reg[rs];
			break;
		case Fnor:
			reg[rd] = ~(reg[rs] | reg[rt]);
			break;
		case For:
			reg[rd] = reg[rs] | reg[rt];
			break;
		case Fsll:
			reg[rd] = reg[rt] << shift;
			break;
		case Fslt:
			reg[rd] = static_cast<int>(reg[rs]) < static_cast<int>(reg[rt]) ? 1 : 0;
			break;
		case Fsltu:
			reg[rd] = reg[rs] < reg[rt] ? 1 : 0;
			break;
		case Fsra:
			reg[rd] = static_cast<int>(reg[rt]) >> shift;
			break;
		case Fsrl:
			reg[rd] = reg[rt] >> shift;
			break;
		case Fsub:
			reg[rd] = reg[rs] - reg[rt];
			if (reg[rs] < reg[rt]) {
				overflow = true;
			}
			else {
				overflow = false;
			}
			break;
		case Fsubu:
			reg[rd] = reg[rs] - reg[rt];
			break;
		case Fxor:
			reg[rd] = reg[rs] ^ reg[rt];
			break;
		case Fmovz:
			if (reg[rt] == 0) {
				reg[rd] = reg[rs];
			}
			break;
		case Fmovn:
			if (reg[rt] != 0) {
				reg[rd] = reg[rs];
			}
			break;
		case Fsyscall:
			break;
		}
		break;
	case Iaddi:
		// todo
		reg[rt] = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		if (reg[rt] < reg[rs] || reg[rt] < static_cast<UINT32>(immediate)) {
			overflow = true;
		}
		else {
			overflow = false;
		}
		break;
	case Iaddiu:
		reg[rt] = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		break;
	case Iandi:
		reg[rt] = reg[rs] & static_cast<UINT32>(immediate);
		break;
	case Ibeq:
		if (reg[rs] == reg[rt]) {
			pc += static_cast<int>(static_cast<short>(immediate)) * 4;
		}
		break;
	case Ibne:
		if (reg[rs] != reg[rt]) {
			pc += static_cast<int>(static_cast<short>(immediate)) * 4;
		}
		break;
	case Iblez:
		if (static_cast<int>(reg[rs]) <= 0) {
			pc += static_cast<int>(static_cast<short>(immediate)) * 4;
		}
		break;
	case Ilh:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = static_cast<int>(
			static_cast<short>(
			(static_cast<UINT16>(memory[srcMem + 1]) << 8)
			+ static_cast<UINT16>(memory[srcMem])));
		break;
	case Ilhu:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = static_cast<UINT32>(
			(static_cast<UINT16>(memory[srcMem + 1]) << 8)
			+ static_cast<UINT16>(memory[srcMem]));
		break;
	case Ilui:
		reg[rt] = static_cast<UINT32>(immediate) << 16;
		break;
	case Ilw:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = (static_cast<UINT32>(memory[srcMem + 3]) << 24)
			+ (static_cast<UINT32>(memory[srcMem + 2]) << 16)
			+ (static_cast<UINT32>(memory[srcMem + 1]) << 8)
			+ static_cast<UINT32>(memory[srcMem]);
		break;
	case Iori:
		reg[rt] = reg[rs] | static_cast<UINT32>(immediate);
		reg[rt] &= 0x0000ffff;// 高16位填0
		break;
	case Ish:
		destMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		memory[destMem] = static_cast<byte>((reg[rt] & 0x0000ff00) >> 8);
		memory[destMem + 1] = static_cast<byte>(reg[rt] & 0x000000ff);
		break;
	case Islti:
		reg[rt] = static_cast<int>(reg[rs]) < static_cast<int>(static_cast<short>(immediate)) ? 1 : 0;
		break;
	case Isltiu:
		reg[rt] = reg[rs] < static_cast<UINT32>(immediate) ? 1 : 0;
		break;
	case Isw:
		destMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		memory[destMem + 3] = static_cast<byte>((reg[rt] & 0xff000000) >> 24);
		memory[destMem + 2] = static_cast<byte>((reg[rt] & 0x00ff0000) >> 16);
		memory[destMem + 1] = static_cast<byte>((reg[rt] & 0x0000ff00) >> 8);
		memory[destMem] = static_cast<byte>(reg[rt] & 0x000000ff);
		break;
	case Isb:
		destMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		memory[destMem] = static_cast<byte>(reg[rt] & 0x000000ff);
		break;
	case Ilb:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = static_cast<int>(static_cast<char>(memory[srcMem]));
		break;
	case Ilbu:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = static_cast<UINT32>(static_cast<byte>(memory[srcMem]));
		break;
	case Ixori:
		reg[rt] = reg[rs] ^ static_cast<UINT32>(immediate);
		reg[rt] &= 0x0000ffff;
		break;
	case Imfc0:
		if (reg[rs] == 4) {
			cp0[rd] = reg[rt];
		}
		else if (reg[rs] == 0) {
			reg[rt] = cp0[rd];
		}
		break;
	case J:
		pc = (pc & 0xf0000000) | (jumpAdd << 2);
		break;
	case Jal:
		reg[ra] = pc;
		pc = (pc & 0xf0000000) | (jumpAdd << 2);
		break;
	default:
		break;
	}
	reg[zero] = 0;
	
	pc_mutex = false;
}

void MipsCPU::VgaRun()
{
	glPointSize(1.0f);
	glBegin(GL_POINTS);
	for (auto i = 0; i < VGA_HEIGHT; i++) {
		for (auto j = 0; j < VGA_WIDTH; j++) {
			byte point = vga_ram[i*VGA_WIDTH + j];
			glColor3ub(point & 0xc0, (point & 0x30) << 2, (point & 0x0c) << 4);
			glVertex2f((j - 320.0) / 320.0, (240 - i) / 240.0);
		}
	}
	glEnd();
	glutSwapBuffers();
}

void MipsCPU::KbInt(char key)
{
	while (exception_mutex == true);
	exception_mutex = true;
	cp0[Cause] = KB_EXCEPTION;
	cp0[Status] |= 0x1111111d;// EXL =1
	cp0[EPC] = pc;
	reg[k0] = static_cast<UINT32>(key);

	while(pc_mutex == true);
	pc_mutex = true;
	pc = INT_OFFSET;
	pc_mutex = false;
	// push context
	reg[sp] -= 24;
	memory[reg[sp]+0] = reg[a0];
	memory[reg[sp]+4] = reg[a1];
	memory[reg[sp]+8] = reg[a2];
	memory[reg[sp]+12] = reg[a3];
	memory[reg[sp]+16] = reg[v0];
	memory[reg[sp]+20] = reg[v1];
}

void MipsCPU::WriteTerminal(int row, int col, char c)
{
	for (auto i = 0; i < 20; i++) {
		for (auto j = 0; j < 16; j++) {
			if (i < 16) {
				if (((Font[c][i] >> (15 - j)) & 1) == 0) {
					vga_ram[row*VGA_WIDTH * 20 + col * 16 + i*VGA_WIDTH + j] = 0x00;
				}
				else {
					vga_ram[row*VGA_WIDTH * 20 + col * 16 + i*VGA_WIDTH + j] = 0xff;
				}
			}
			else {
				vga_ram[row*VGA_WIDTH * 20 + col * 16 + i*VGA_WIDTH + j] = 0x00;
			}
		}
	}
}