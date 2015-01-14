#define COMADR    0xfc000000     //串口地址
#define  BlockADR  0x00000000    //数据段地址
int BlockOffset=0 ;                                 //偏移地址



void init()
{
	BlockOffset=0;
	*(int*)(BlockADR+513)=0; //initial
	return ;
}


/*---将fasongde字符存在串口地址高位---*/
void SendChar(int C)
{
	*(int*)COMADR=C;
	return ;
}

/*----将收到的字符存在数据段---*/
void RecvBlock()
{
	init();
	if(*(int*)COMADR!='#')
	{
        BlockOffset=*(int*)(BlockADR+512);
	*(int*)(BlockADR+BlockOffset)=*(int*)COMADR; //此处，加i还是加i*4? //zhe shi 512 zijie
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