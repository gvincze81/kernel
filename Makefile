OBJECTS = ./build/kernel.asm.o

DEPENDENCIES = kernel.asm

BOOTLOADER_BINARY = ./bin/boot.bin

FLAGS = -ffreestanding -O0 -nostdlib

build: clean boot kernel
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin 

boot:
	nasm -f bin ./src/boot/boot.asm -o $(BOOTLOADER_BINARY)

# The Linker sticks all the OBJECTS together 
kernel: $(DEPENDENCIES)
	i686-elf-ld -g -relocatable $(OBJECTS) -o ./build/kernelfull.o
	i686-elf-gcc -T ./linker.ld -o ./bin/kernel.bin $(FLAGS) ./build/kernelfull.o

# OBJECT FILES
kernel.asm:
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o
# END

run:
	qemu-system-i386 -hda $(BOOTLOADER_BINARY)

debug:
	gdb -q

test:

clean:
	rm -rf $(BOOTLOADER_BINARY)
	rm -rf ./bin/os.bin
	rm -rf $(OBJECTS)