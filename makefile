all: build/os-image

run: build/os-image
	qemu-system-x86_64 -drive format=raw,file="build/os-image"

build/os-image: build/boot_sector.bin build/kernel.bin
	cat $^ > "build/os-image"

build/boot_sector.bin: src/*.asm src/utils/*.asm
	nasm "src/boot_sector.asm" -f bin -o "build/boot_sector.bin"

build/kernel.bin: build/kernel.o
	ld -o "build/kernel.bin" -Ttext 0x1000 "build/kernel.o" --oformat binary

build/kernel.o: src/kernel.rs
	rustc --target x86_64-unknown-none -O --emit obj "src/kernel.rs" -o "build/kernel.o"

clean :
	rm -rf build/*.bin build/*.dis build/*.o build/os-image build/*.map