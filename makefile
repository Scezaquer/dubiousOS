# Define the source directories
RUST_SOURCES := $(wildcard src/kernel/*.rs) $(wildcard src/drivers/*.rs)

# Define the object files with the build directory
OBJ := $(patsubst src/%.rs, build/%.o, $(RUST_SOURCES))

all: build/os-image

run: build/os-image
	qemu-system-x86_64 -drive format=raw,file="build/os-image"

build/os-image: build/boot_sector.bin build/kernel.bin
	cat $^ > "build/os-image"

build/boot_sector.bin: src/boot/*.asm src/boot/utils/*.asm
	nasm "src/boot/boot_sector.asm" -f bin -o "build/boot_sector.bin"

build/kernel.bin: ${OBJ}
	ld -o $@ -Ttext 0x1000 $^ --oformat binary

build/%.o: src/%.rs
	rustc --target x86_64-unknown-none -O --emit obj $< -o $@

clean :
	rm -rf build/*.bin build/*.dis build/*.o build/os-image build/*.map