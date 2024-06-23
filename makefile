# Define the source directories
KERNEL_SOURCES := $(wildcard src/kernel/src/*.rs)
DRIVERS_SOURCES :=  $(wildcard src/drivers/src/*.rs)

# Define the object files with the build directory
KERNEL_OBJ := $(patsubst src/%.rs, build/%.o, $(KERNEL_SOURCES))

all: build/os-image

run: build/os-image
	qemu-system-x86_64 -drive format=raw,file="build/os-image"

build/os-image: build/boot_sector.bin build/kernel.bin
	cat $^ > "build/os-image"

build/boot_sector.bin: src/boot/*.asm src/boot/utils/*.asm
	nasm "src/boot/boot_sector.asm" -f bin -o "build/boot_sector.bin"

build/kernel.bin: ${KERNEL_OBJ}
	ld -o $@ -Ttext 0x1000 $^ --oformat binary

build/kernel/%.o: src/kernel/%.rs $(wildcard src/kernel/**/*.rs) build/drivers
	mkdir -p build/kernel/src
	rustc --extern drivers=build/drivers/libdisk.rlib --target x86_64-unknown-none -O --emit obj $< -o $@

build/drivers: ${DRIVERS_SOURCES} $(wildcard src/drivers/**/*.rs)
	mkdir -p build/drivers
	rustc --crate-type=lib --target x86_64-unknown-none --out-dir build/drivers $<

clean :
	rm -rf build/*