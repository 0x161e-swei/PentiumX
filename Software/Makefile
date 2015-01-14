FILE=syscall
default:$(FILE).txt $(FILE).bin $(FILE)b.txt

$(FILE)b.txt:$(FILE).bin
	mips-mti-elf-objdump -z -M no-aliases -D -b binary $(FILE).bin --architecture=mips:isa32 > $(FILE)b.txt
	
$(FILE).bin:$(FILE).elf
	mips-mti-elf-objcopy -R -S -O binary $(FILE).elf $(FILE).bin

$(FILE).txt:$(FILE).elf
	mips-mti-elf-objdump -S -z -M no-aliases $(FILE).elf > $(FILE).txt

$(FILE).elf:$(FILE).o
	mips-mti-elf-gcc -EL -fno-delayed-branch -T $(FILE).lds -o $(FILE).elf $(FILE).o

$(FILE).o:$(FILE).c
	mips-mti-elf-gcc -EL -fno-delayed-branch -O -G0 -fno-builtin -o $(FILE).o -c $(FILE).c

clean:
	rm *.o
