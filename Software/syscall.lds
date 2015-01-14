OUTPUT_FORMAT("elf32-tradlittlemips", "elf32-tradbigmips", "elf32-tradlittlemips")
OUTPUT_ARCH(mips)
SECTIONS {
	.data : {
		*(.data)
	}
	.bss : {
		*(.bss)
	}
	.text : {
		*(.text)
	}
}

