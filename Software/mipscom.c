#define COMADR    0xfc000000     //���ڵ�ַ
#define  BlockADR  0x00000000    //���ݶε�ַ
int BlockOffset=0 ;                                 //ƫ�Ƶ�ַ



void init()
{
	BlockOffset=0;
	*(int*)(BlockADR+513)=0; //initial
	return ;
}


/*---��fasongde�ַ����ڴ��ڵ�ַ��λ---*/
void SendChar(int C)
{
	*(int*)COMADR=C;
	return ;
}

/*----���յ����ַ��������ݶ�---*/
void RecvBlock()
{
	init();
	if(*(int*)COMADR!='#')
	{
        BlockOffset=*(int*)(BlockADR+512);
	*(int*)(BlockADR+BlockOffset)=*(int*)COMADR; //�˴�����i���Ǽ�i*4? //zhe shi 512 zijie
	*(int*)(BlockADR+512)=BlockOffset+1;
	}
}


void SendStr(int *Sendstr)
{
	int i=0;
	for (;Sendstr[i]!='\0';i++)
	{
		SendChar(Sendstr[i]);
	}
	SendChar('#');   //end when  '#' received 
	RecvBlock();
}



int main ()
{
	int syscall_code; 
	__asm ("add %0, $zero, $v0":"=r"(syscall_code));
	init();    
	SendStr((int*)syscall_code);
		
	asm ("eret");
	asm ("nop");
	
}