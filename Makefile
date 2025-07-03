OBJECTS =

DEPENDENCIES =

build: clean
	nasm -f bin ./src/boot.asm -o ./bin/boot.bin
	dd if=./message.txt >> ./bin/boot.bin
	dd if=/dev/zero bs=512 count=1 >> ./bin/boot.bin

run:
	qemu-system-i386 -hda ./bin/boot.bin

debug:
	gdb -q

test:

clean:
	rm -rf ./bin/boot.bin
	rm -rf $(OBJECTS)