#ifndef __MIPSCPU_H__
#define __MIPSCPU_H__

#include <string>
#include <fstream>
#include "stdafx.h"
#include "VirtualDisk.h"

typedef unsigned short UINT16;
typedef unsigned int UINT32;
typedef unsigned char byte;

class MipsCPU
{
public:
	~MipsCPU(){};
	static MipsCPU* GetInstance();
	// 执行指令
	void Step();
	// 模拟显示
	void VgaRun();
	// 键盘中断
	void KbInt(unsigned int key);
	// 启动
	bool Boot();
private:
	MipsCPU() {
		memset(this, 0, sizeof(MipsCPU));
		pc = CODE_SEGMENT_OFFSET;
		reg[sp] = DATA_SEGMENT_OFFSET + DATA_SEGMENT_SIZE;// 栈自顶向下增长
		vhd = VirtualDisk::getInstance();
		pc_mutex = false;
		exception_mutex = false;
	}
	// 写控制台
	void WriteTerminal(int row, int col, unsigned char c);
	// 通知vga刷新
	void RePaint();
	// 操作文件
	void FileOperation();
public:
	static const UINT32 REG_NUMBER = 32;// 寄存器数量
	static const UINT32 MEMORY_SIZE = 1024*1024;// 内存大小

	static const UINT32 INT_OFFSET = 0;// 中断处理程序偏移
	static const UINT32 EXCEPTION_OFFSET = 1024*32;// exception偏移

	static const UINT32 CHAR_DEVICE_OFFSET = 1024*64;// 字符设备偏移
	static const UINT32 TEXT_WIDTH = 40;// 文本宽度
	static const UINT32 TEXT_HEIGHT = 24;// 文本高度

	static const UINT32 KEYBOARD_BUFFER_OFFSET = CHAR_DEVICE_OFFSET + 4 + TEXT_WIDTH*TEXT_HEIGHT;// 键盘缓冲区偏移
	static const UINT32 KEYBOARD_BUFFER_SIZE = 256;// 键盘缓冲区大小

	static const UINT32 VGA_SIGNAL = KEYBOARD_BUFFER_OFFSET + KEYBOARD_BUFFER_SIZE;// 输出到vga的信号
	static const UINT32 VGA_SIGNAL_SIZE = 4;// 通知VGA刷新

	static const UINT32 CODE_SEGMENT_OFFSET = VGA_SIGNAL + VGA_SIGNAL_SIZE;// 代码段
	static const UINT32 CODE_SEGMENT_SIZE = 1024*128;

	static const UINT32 DATA_SEGMENT_OFFSET = CODE_SEGMENT_OFFSET + CODE_SEGMENT_SIZE;// 数据段
	static const UINT32 DATA_SEGMENT_SIZE = 1024*128;

	static const UINT32 FILE_PORT = DATA_SEGMENT_OFFSET + DATA_SEGMENT_SIZE;
	static const UINT32 FILE_BUFFER_OFFSET = FILE_PORT+8;
	static const UINT32 FILE_BUFFER_SIZE = 512*8;
	static const UINT32 FILE_INFO = FILE_BUFFER_OFFSET + FILE_BUFFER_SIZE;

	static const UINT32 VGA_WIDTH = 640;// VGA宽度
	static const UINT32 VGA_HEIGHT = 480;// VGA高度

	static const byte VGA_IDLE = 0;
	static const byte VGA_OUTPUT = 1;
	
	// file operation
	static const UINT32 FILE_IDLE = 0;
	static const UINT32 SECTION_READ = 1;
	static const UINT32 SECTION_WRITE = 2;


	enum RegName{
		zero = 0, at, v0, v1, a0, a1, a2, a3, 
		t0, t1, t2, t3, t4, t5, t6, t7, 
		s0, s1, s2, s3, s4, s5, s6, s7, 
		t8, t9, k0, k1, gp, sp, fp, ra 
	};
	enum cp0Name{
		BadVAddr = 8, Count = 9, Compare = 11, Status = 12,
		Cause = 13, EPC = 14, Config = 16,
	};
	enum op{
		Syscall = 0x0000000c,
		Eret = 0x42000018,
		RInstruction = 0x00,
		Iaddi = 0x08,
		Iaddiu = 0x09,
		Iandi = 0x0c,
		Ibeq = 0x04,
		Ibne = 0x05,
		Iblez = 0x06,
		Ilh = 0x21,
		Ilhu = 0x25,
		Ilui = 0x0f,
		Ilw = 0x23,
		Iori = 0x0d,
		Isb = 0x28,
		Ilb = 0x20,
		Ilbu = 0x24,
		Ish = 0x29,
		Islti = 0x0a,
		Isltiu = 0x0b,
		Isw = 0x2b,
		Ixori = 0x0e,
		Imfc0 = 0x10,
		J = 0x02,
		Jal = 0x03
	};
	enum funct{
		Fadd = 0x20,
		Fmovz = 0x0a,
		Fmovn = 0x0b,
		Faddu = 0x21,
		Fand = 0x24,
		Fjalr = 0x09,
		Fjr = 0x08,
		Fnor = 0x27,
		For = 0x25,
		Fsll = 0x00,
		Fslt = 0x2a,
		Fsltu = 0x2b,
		Fsra = 0x03,
		Fsrl = 0x02,
		Fsub = 0x22,
		Fsubu = 0x23,
		Fxor = 0x26,
		Fsyscall = 0x0c
	};
	enum interrupt_cause {
		KB_EXCEPTION = 0,
		SYSCALL_EXCEPTION = 8,
	};
private:
	UINT32 instruction;
	UINT32 reg[REG_NUMBER];
	UINT32 cp0[REG_NUMBER];
	UINT32 pc;
	byte vga_ram[VGA_HEIGHT*VGA_WIDTH];
	byte memory[MEMORY_SIZE];
	POINT cursor;
	bool overflow;
	VirtualDisk* vhd;
	volatile bool pc_mutex;
	volatile bool exception_mutex;
};


#endif //__MIPSCPU_H__