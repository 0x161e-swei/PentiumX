OUTPUT_FORMAT("elf32-tradlittlemips", "elf32-tradbigmips", "elf32-tradlittlemips")
OUTPUT_ARCH(mips)
SECTIONS {
	. = 0x00000000;
	.text : {
		*(.text)
	}
	. = 0x00006000;
	.data : {
		*(.data)
	}
	.rodata : {
		*(.rodata*)
	}
	.bss : {
		*(.bss)
	}
}

