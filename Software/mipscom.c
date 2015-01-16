

/*---将发送的字符存在串口地址高位---*/
// void Sendchar(int  C)
// {
// 	*(int *)COMADR=C;
// 	return ;
// }

// /*----将收到的字符存在数据段---*/   //中断响应程序
// void RecvBlock()
// {
// 	int WOffset;               //第几个word
// 	int BOffset;                //word中的第几个byte
// 	int BlockOffset;
// 	unsigned int  aword=0;    //一个字
// 	if (*(int *)OFFSET==512)
// 		*(int *)	OFFSET=0;
// 	 BlockOffset=	*(int *)	OFFSET;
// 	 *(int *)	OFFSET=*(int *)OFFSET+1;
// 	WOffset=BlockOffset/4;            
// 	BOffset=BlockOffset%4;          

// 		aword=*(unsigned int *) COMADR>>(BOffset*8);
// 		*(int*)(BLOCKADR+WOffset)=aword+*(int*)(BLOCKADR+WOffset); 
// }


// //发送一个block至pc端
// void Sendblock(int block)
// {
// 	int WOffset;               //第几个word
// 	int BOffset;                //word中的第几个byte
// 	int aword=0;            //一个word
// 	int BlockOffset;
// 	int blocks;
// 	BlockOffset=0;

// 	Sendchar((int) ('*'<<24));
// 	while(1)
// 	{
// 		blocks=block%10;
// 		block=block/10;
// 		Sendchar(blocks);
// 		if (block<=0)break;
// 	}
// 	if(BlockOffset<512)
// 	{
		
// 		WOffset=BlockOffset/4;            
// 		BOffset=BlockOffset%4;          

// 		aword= *(int* ) (BLOCKADR+WOffset)<<(8*BOffset);
// 		Sendchar(aword);
// 		BlockOffset++;
// 	}
// }


//发送请求并接受一个block
// void Recv(int block)
// {
// 	int end;
// 	int blocks;
// 	end=(int)('#'<<24) ;
// 	Sendchar((int) ('!'<<24));
// 	while(1)
// 	{
// 		blocks=block%10;
// 		block=block/10;
// 		Sendchar(blocks);
// 		if (block<=0)break;
// 	}
// 	Sendchar( end);  
// }

// void init()
// {
// 	*(int*)OFFSET=0;
// }


int main()
{
	int syscall_code;
	unsigned int a0,a1;
	init();
	asm ("add %0, $zero, $v0":"=r"(syscall_code));
	asm ("add %0, $zero, $v1":"=r"(a0));
	asm ("add %0, $zero, $v2":"=r"(a1));

	switch (syscall_code){
	case SendIns:
		Recv(a0);break;
	case SendBlock:
		Sendblock(a1);break;
		default:
			break;
	}
	asm ("eret");
	asm ("nop");
}