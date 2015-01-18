void CharToInt(unsigned int* src, unsigned int* dest, unsigned int size) 
{
	unsigned int count=0;
	while (1) {
		asm ("srl $t7, %0, 0"::"r"(src[count>>2]));
		asm ("andi $t7, $t7, 0xff");
		asm ("sw $t7, 0(%0)"::"r"(dest+count));
		//asm ("add %0, $t7, $zero":"=r"(dest[count]));
		//dest[count] = src[count>>2]&0x000000ff;
		if (dest[count] == '\0') {
			break;
		}
		count++;
		if (count >= size) {
			break;
		}
		asm ("srl $t7, %0, 8"::"r"(src[count>>2]));
		asm ("andi $t7, $t7, 0xff");
		asm ("sw $t7, 0(%0)"::"r"(dest+count));
		//asm ("add %0, $t7, $zero":"=r"(dest[count]));
		//dest[count] = (src[count>>2]&0x0000ff00)>>8;
		if (dest[count] == '\0') {
			break;
		}
		count++;
		if (count >= size) {
			break;
		}
		asm ("srl $t7, %0, 16"::"r"(src[count>>2]));
		asm ("andi $t7, $t7, 0xff");
		asm ("sw $t7, 0(%0)"::"r"(dest+count));
		//asm ("add %0, $t7, $zero":"=r"(dest[count]));
		//dest[count] = (src[count>>2]&0x00ff0000)>>16;
		if (dest[count] == '\0') {
			break;
		}
		count++;
		if (count >= size) {
			break;
		}
		asm ("srl $t7, %0, 24"::"r"(src[count>>2]));
		asm ("andi $t7, $t7, 0xff");
		asm ("sw $t7, 0(%0)"::"r"(dest+count));
		//asm ("add %0, $t0, $zero":"=r"(dest[count]));
		//dest[count] = (src[count>>2]&0xff000000)>>24;
		if (dest[count] == '\0') {
			break;
		}
		count++;
		if (count >= size) {
			break;
		}
	}
}
