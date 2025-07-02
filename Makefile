OBJECTS =

DEPENDENCIES =

build: clean
	nasm -f bin ./src/boot.asm -o ./bin/boot.bin

run:
	qemu-system-i386 -hda ./bin/boot.bin

debug:

test:

clean:
	rm -rf ./bin/boot.bin
	rm -rf $(OBJECTS)