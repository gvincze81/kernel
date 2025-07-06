OBJECTS = ./build/kernel.asm.o ./build/kernel.o ./build/idt/idt.o

DEPENDENCIES = kernel.asm kernel.c idt

INCLUDES = -I./src

FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer \
	-finline-functions -Wno-unused-function -Wno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib \
	-nostartfiles -nodefaultlibs -Wall -O0 -Iinc

build: clean boot kernel
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin 

boot:
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

# The Linker sticks all the OBJECTS together 
kernel: $(DEPENDENCIES)
	i686-elf-ld -g -relocatable $(OBJECTS) -o ./build/kernelfull.o
	i686-elf-gcc $(FLAGS) -T ./linker.ld -o ./bin/kernel.bin ./build/kernelfull.o

# OBJECT FILES
kernel.asm:
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o

kernel.c:
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel.c -o ./build/kernel.o

idt:
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/idt/idt.c -o ./build/idt/idt.o
# END

run:
	qemu-system-i386 -hda ./bin/os.bin

debug:
	gdb -q

test:

clean:
	rm -rf ./bin/boot.bin
	rm -rf ./bin/kernel.bin
	rm -rf ./bin/os.bin
	rm -rf $(OBJECTS)
	rm -rf ./build/kernelfull.o