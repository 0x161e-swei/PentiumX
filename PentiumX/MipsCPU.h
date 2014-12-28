#ifndef __MIPSCPU_H__
#define __MIPSCPU_H__

#include "stdafx.h"
#include  "cstring"

typedef unsigned short UINT16;
typedef unsigned int UINT32;
typedef unsigned char byte;

class MipsCPU
{
public:
	~MipsCPU()
	{
	}
	static void getInstance();
	// 执行指令
	void step();
	// 模拟显示
	void vgaRun();
	// 键盘中断
	void kbInt(byte key);
private:
	MipsCPU()
	{
		memset(this, 0, sizeof(MipsCPU));
		pc = 0;
	}
	// 在程序启动时载入代码
public:
	static MipsCPU* pCpu;
	static const UINT32 REG_NUMBER = 32;
	static const UINT32 MEMORY_SIZE = 1024*1024;
	static const UINT32 VRAM_OFFSET = 1024*64;
	static const UINT32 USER_OFFSET = 1024*512;
	static const UINT32 INT_OFFSET = 0x00000004;
	static const UINT32 VGA_WIDTH = 640;
	static const UINT32 VGA_HEIGHT = 480;
	enum RegName{
		zero = 0, at, v0, v1, a0, a1, a2, a3, 
		t0, t1, t2, t3, t4, t5, t6, t7, 
		s0, s1, s2, s3, s4, s5, s6, s7, 
		t8, t9, k0, k1, gp, sp, fp, ra 
	};
	enum cp0Name{
		BadVAddr = 8, Count = 9, Compare = 11, Status = 12,
		Cause = 13, EPC = 14, Config = 16
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
		Ilh = 0x21,
		Ilhu = 0x25,
		Ilui = 0x0f,
		Ilw = 0x23,
		Iori = 0x0d,
		Ish = 0x29,
		Islti = 0x0a,
		Isltiu = 0x0b,
		Isw = 0x2b,
		Ixori = 0x0e,
		Imfc0 = 0x10,
		J = 0x02,
		Jal = 0x03,
	};
	enum funct{
		Fadd = 0x20,
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
		Fsyscall = 0x0c,
	};
private:
	UINT32 reg[REG_NUMBER];
	UINT32 cp0[REG_NUMBER];
	UINT32 pc;
	byte memory[MEMORY_SIZE];
	POINT cursor;
	bool overflow;
};


#endif //__MIPSCPU_H__