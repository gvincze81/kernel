OBJECTS = ./build/kernel.asm.o ./build/kernel.o ./build/idt/idt.o ./build/memory/memory.o ./build/idt/idt.asm.o \
	./build/io/io.asm.o ./build/memory/heap/heap.o ./build/memory/heap/kheap.o

HEADERS = ./src/config.h ./src/kernel.h ./src/idt/idt.h ./src/memory/memory.h ./src/io/io.h ./src/memory/heap/heap.h \
	./src/memory/heap/kheap.h

INCLUDES = -I./src

FLAGS = -g -ffreestanding -falign-jumps -falign-functions -falign-labels -falign-loops -fstrength-reduce -fomit-frame-pointer \
	-finline-functions -Wno-unused-function -Wno-builtin -Werror -Wno-unused-label -Wno-cpp -Wno-unused-parameter -nostdlib \
	-nostartfiles -nodefaultlibs -Wall -O0 -Iinc

.PHONY = clean

./bin/os.bin: ./bin/boot.bin ./bin/kernel.bin
	rm -rf ./bin/os.bin
	dd if=./bin/boot.bin >> ./bin/os.bin
	dd if=./bin/kernel.bin >> ./bin/os.bin
	dd if=/dev/zero bs=512 count=100 >> ./bin/os.bin 

./bin/boot.bin: ./src/boot/boot.asm
	nasm -f bin ./src/boot/boot.asm -o ./bin/boot.bin

# The Linker sticks all the OBJECTS together 
./bin/kernel.bin: ./build/kernelfull.o ./linker.ld 
	i686-elf-gcc $(FLAGS) -T ./linker.ld ./build/kernelfull.o -o ./bin/kernel.bin

# OBJECT FILES
./build/kernelfull.o: $(OBJECTS)
	i686-elf-ld -g -relocatable $(OBJECTS) -o ./build/kernelfull.o

./build/kernel.asm.o: ./src/kernel.asm
	nasm -f elf -g ./src/kernel.asm -o ./build/kernel.asm.o

./build/kernel.o: ./src/kernel.c $(HEADERS)
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/kernel.c -o ./build/kernel.o

./build/idt/idt.asm.o: ./src/idt/idt.asm
	nasm -f elf -g ./src/idt/idt.asm -o ./build/idt/idt.asm.o

./build/idt/idt.o: ./src/idt/idt.c $(HEADERS)
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/idt/idt.c -o ./build/idt/idt.o

./build/memory/memory.o: ./src/memory/memory.c $(HEADERS)
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/memory/memory.c -o ./build/memory/memory.o

./build/memory/heap/heap.o: ./src/memory/heap/heap.c $(HEADERS)
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/memory/heap/heap.c -o ./build/memory/heap/heap.o

./build/memory/heap/kheap.o: ./src/memory/heap/kheap.c $(HEADERS)
	i686-elf-gcc $(INCLUDES) $(FLAGS) -std=gnu99 -c ./src/memory/heap/kheap.c -o ./build/memory/heap/kheap.o

./build/io/io.asm.o: ./src/io/io.asm
	nasm -f elf -g ./src/io/io.asm -o ./build/io/io.asm.o

# END

run:
	qemu-system-i386 -hda ./bin/os.bin

debug:
	gdb -q

test:

clean:
	rm -rf ./bin/boot.bin ./bin/kernel.bin ./bin/os.bin $(OBJECTS) ./build/kernelfull.o
