
//#define WRITE						21



/*��ȡbuffer�е�һ���ֽ�,����$a0�ĵ�8λ*/  
// void read()
// {
// 	int WriteP;
// 	int ReadP;
// 	int ReadChar=0;
// 	WriteP=(*(int *)POINTER)%0x00010000;    //��buffer��д��ָ�룬�ǵ�16λ
// 	ReadP=(*(int *)POINTER)/0x00010000;       //��buffer�����ָ�룬�Ǹ�16λ
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


/*��buffer��д��һ���ֽ�*/      //�ж���Ӧ
void write()
{	
	int ReadWord;       //��8λ��Ҫ��������
	int offset;
	int WritePointer=0;
	ReadWord=*(int *)READ_ADDR;
	ReadWord=(ReadWord<<24)/0x01000000;  //ȷ����24λΪ��

	offset=(*(int *)POINTER)%0x00010000;      //��buffer��д��ָ�룬�ǵ�16λ
	
	WritePointer=BUFFER+offset;
	*(int *)WritePointer=*(int *)WritePointer+ReadWord<<((3-offset%4)*8);
	if (offset==60)
		*(int *)POINTER=*(int *)POINTER&0xffff0000;
	else 
		*(int *)POINTER=*(int *)POINTER+1;
}


void init()  //��ָ���дָ���ʼ��Ϊ0
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