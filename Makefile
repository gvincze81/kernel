OBJECTS =

DEPENDENCIES =

BOOTLOADER_BINARY = ./bin/boot.bin

build: clean
	nasm -f bin ./src/boot/boot.asm -o $(BOOTLOADER_BINARY)

run:
	qemu-system-i386 -hda $(BOOTLOADER_BINARY)

debug:
	gdb -q

test:

clean:
	rm -rf $(BOOTLOADER_BINARY)
	rm -rf $(OBJECTS)