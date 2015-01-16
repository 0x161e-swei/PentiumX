
//#define WRITE						21



/*读取buffer中的一个字节,存在$a0的低8位*/  
// void read()
// {
// 	int WriteP;
// 	int ReadP;
// 	int ReadChar=0;
// 	WriteP=(*(int *)POINTER)%0x00010000;    //往buffer里写的指针，是低16位
// 	ReadP=(*(int *)POINTER)/0x00010000;       //在buffer里读的指针，是高16位
// 	if(WriteP==ReadP)
// 	return ;
// 	else
// 	{
		
// 		ReadChar=(  *(int *)(BUFFER+ReadP)  >>  ((3-ReadP%4)*8))&0x000000ff;
// 		asm ("add $a0, $zero, %0":(ReadChar));
// 		if (ReadP==60)
// 			*(int *)POINTER  =  *(int *)POINTER  &  0x0000ffff;
// 		else 
// 			*(int *)POINTER  =  *(int *)POINTER  +  0x00010000;

// 	}

// }


/*向buffer中写入一个字节*/      //中断响应
void write()
{	
	int ReadWord;       //低8位是要读的数据
	int offset;
	int WritePointer=0;
	ReadWord=*(int *)READ_ADDR;
	ReadWord=(ReadWord<<24)/0x01000000;  //确保高24位为零

	offset=(*(int *)POINTER)%0x00010000;      //往buffer里写的指针，是低16位
	
	WritePointer=BUFFER+offset;
	*(int *)WritePointer=*(int *)WritePointer+ReadWord<<((3-offset%4)*8);
	if (offset==60)
		*(int *)POINTER=*(int *)POINTER&0xffff0000;
	else 
		*(int *)POINTER=*(int *)POINTER+1;
}


void init()  //读指针和写指针初始化为0
{
	*(int* ) POINTER=0;
}

int main()
{
	int syscall_code;
	unsigned int a0, a1, a2;
	init();
	asm ("add %0, $zero, $v0":"=r"(syscall_code));

	switch (syscall_code){
	case READ:
		read();break;
		default:
			break;
	}
	asm ("eret");
	asm ("nop");
}