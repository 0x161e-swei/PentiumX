OUTPUT_FORMAT("elf32-tradlittlemips", "elf32-tradbigmips", "elf32-tradlittlemips")
OUTPUT_ARCH(mips)
SECTIONS {
	. = 66760;
	.text : {
		*(.text)
	}
	.data : {
		*(.data)
	}
	.bss : {
		*(.bss)
	}
}
