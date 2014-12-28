#include "stdafx.h"
#include "MipsCPU.h"


void MipsCPU::getInstance()
{
	static bool init = false;
	if (init == false)
	{
		pCpu = new MipsCPU();
		init = true;
	}
}


void MipsCPU::step()
{
	UINT32 instruction;
	if (pc+4 >= MEMORY_SIZE)
	{
		pc = 0;
	}
	instruction = (static_cast<UINT32>(memory[pc]) << 24)
		+ (static_cast<UINT32>(memory[pc+1]) << 16)
		+ (static_cast<UINT32>(memory[pc+2]) << 8)
		+ (static_cast<UINT32>(memory[pc+3]));
	pc += 4;
	// 初始化一些值
	reg[zero] = 0;
	overflow = false;
	if (instruction == Eret)
	{
		pc = cp0[EPC];
		cp0[Status] &= 0xfffffffd;// 设置exl为0
		return;
	}
	if (instruction == Syscall)
	{
		cp0[EPC] = pc;
		pc = INT_OFFSET;
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
	switch (opcode)
	{
	case RInstruction:
		switch (func)
		{
		case Fadd:
			reg[rd] = reg[rs] + reg[rt];
			if (reg[rd] < reg[rs] || reg[rd] < reg[rt])
			{
				overflow = true;
			}
			else
			{
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
			if (reg[rs] < reg[rt])
			{
				overflow = true;
			}
			else
			{
				overflow = false;
			}
			break;
		case Fsubu:
			reg[rd] = reg[rs] - reg[rt];
			break;
		case Fxor:
			reg[rd] = reg[rs] ^ reg[rt];
			break;
		case Fsyscall:
			break;
		}
		break;
	case Iaddi:
		// warning 
		reg[rt] = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		if (reg[rt] < reg[rs] || reg[rs] < static_cast<UINT32>(immediate))
		{
			overflow = true;
		}
		else
		{
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
		if (reg[rs] == reg[rt])
		{
			pc += static_cast<int>(static_cast<short>(immediate));
		}
		break;
	case Ibne:
		if (reg[rs] != reg[rt])
		{
			pc += static_cast<int>(static_cast<short>(immediate));
		}
		break;
	case Ilh:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = static_cast<int>(
			static_cast<short>(
			(static_cast<UINT16>(memory[srcMem]) << 8)
			+ static_cast<UINT16>(memory[srcMem+1])));
		break;
	case Ilhu:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = static_cast<UINT32>(
			(static_cast<UINT16>(memory[srcMem]) << 8)
			+ static_cast<UINT16>(memory[srcMem+1]));
		break;
	case Ilui:
		reg[rt] = static_cast<UINT32>(immediate) << 16;
		break;
	case Ilw:
		srcMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		reg[rt] = (static_cast<UINT32>(memory[srcMem]) << 24)
			+ (static_cast<UINT32>(memory[srcMem+1]) << 16)
			+ (static_cast<UINT32>(memory[srcMem+2]) << 8)
			+ static_cast<UINT32>(memory[srcMem+3]);
		break;
	case Iori:
		reg[rt] = reg[rs] | static_cast<UINT32>(immediate);
		reg[rt] &= 0x0000ffff;// 高16位填0
		break;
	case Ish:
		destMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		memory[destMem] = static_cast<byte>((reg[rt] & 0x0000ff00) >> 8);
		memory[destMem+1] = static_cast<byte>(reg[rt] & 0x000000ff);
		break;
	case Islti:
		reg[rt] = static_cast<int>(reg[rs]) < static_cast<int>(static_cast<short>(immediate)) ? 1:0;
		break;
	case Isltiu:
		reg[rt] = reg[rs] < static_cast<UINT32>(immediate) ? 1:0;
		break;
	case Isw:
		destMem = reg[rs] + static_cast<int>(static_cast<short>(immediate));
		memory[destMem] = static_cast<byte>((reg[rt] & 0xff000000) >> 24);
		memory[destMem+1] = static_cast<byte>((reg[rt] & 0x00ff0000) >> 16);
		memory[destMem+2] = static_cast<byte>((reg[rt] & 0x0000ff00) >> 8);
		memory[destMem+3] = static_cast<byte>(reg[rt] & 0x000000ff);
		break;
	case Ixori:
		reg[rt] = reg[rs] ^ static_cast<UINT32>(immediate);
		reg[rt] &= 0x0000ffff;
		break;
	case Imfc0:
		if (reg[rs] == 4)
		{
			cp0[rd] = reg[rt];
		}
		else if (reg[rs] == 0)
		{
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
	}
	reg[zero] = 0;
}

void MipsCPU::vgaRun()
{
	//HANDLE hOut = GetStdHandle(STD_OUTPUT_HANDLE);
	//// 隐藏光标
	//CONSOLE_CURSOR_INFO curInfo;
	//curInfo.bVisible = 0;
	//curInfo.dwSize = 1;
	//SetConsoleCursorInfo(hOut, &curInfo);
	//for (;;)
	//{
	//	for (auto i=0; i<80; i++)
	//	{
	//		for (auto j=0; j<24; j++)
	//		{
	//			INT16 letter = static_cast<INT16>(*(memory+VRAM_OFFSET+(i*24+j)*2));
	//			char c = static_cast<char>(letter & static_cast<INT16>(0xff));
	//			SetConsoleTextAttribute(GetStdHandle(STD_OUTPUT_HANDLE),(letter & static_cast<INT16>(0x0700))>>8);
	//			COORD pos = {i, j};
	//			SetConsoleCursorPosition(hOut, pos);
	//			printf("c");
	//		}
	//	}
	//	system("cls");
	//	Sleep(40);
	//}
	glPointSize(1.0f);
	glBegin(GL_POINTS);
	for (auto i = 0; i<VGA_WIDTH; i++)
	{
		for (auto j = 0; j<VGA_HEIGHT; j++)
		{
			byte point = memory[VRAM_OFFSET+i*VGA_HEIGHT+j];
			glColor3ub(point&0xc0, (point&0x30)<<2, (point&0x0c)<<4);
			glVertex2f((j-240)/240.0, (320-i)/320.0);
		}
	}
	glEnd();
	glutSwapBuffers();
}

void MipsCPU::kbInt(byte key)
{
	if (key>=0x20 && key<=0xfe)// 如果是可打印字符
	{
		for (auto i=0; i<16; i++)
		{
			for (auto j=0; j<20; j++)
			{
				if (j < 16)
				{
					if (((Font[key][i] >> (15-j))&1) == 0)
					{
						memory[VRAM_OFFSET+i*480+cursor.y*16+cursor.x*16*480+j] = 0x00;
					}
					else
					{
						memory[VRAM_OFFSET+i*480+cursor.y*16+cursor.x*16*480+j] = 0xff;
					}
				}
				else
				{
					memory[VRAM_OFFSET+i*480+cursor.y*16+cursor.x*16*480+j] = 0xff;
				}
			}
		}
		cursor.y++;
		if (cursor.y == 30)
		{
			cursor.y = 0;
			cursor.x++;
		}
		if (cursor.x == 40)
		{
			cursor.x = 0;
		}
	}
}