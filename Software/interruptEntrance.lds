OUTPUT_FORMAT("elf32-tradlittlemips", "elf32-tradbigmips", "elf32-tradlittlemips")
OUTPUT_ARCH(mips)
SECTIONS {
	. = 0x00000000;
	.text : AT(0x0) {
		*(.text)
	}
	.rodata : {
		*(.rodata*)
	}
	.data : {
		*(.data)
	}
	.bss : {
		*(.bss)
	}
	
	
}

