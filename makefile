# Paths and files
BUILD_DIR := build
BOOT_ASM := src/boot/boot_sector.asm
UTILS_ASM := src/boot/utils/*.asm
BOOT_BIN := $(BUILD_DIR)/boot_sector.bin
KERNEL_BIN := $(BUILD_DIR)/kernel.bin
OS_IMAGE := $(BUILD_DIR)/os-image

# Compiler and assembler options
NASM := nasm
NASMFLAGS := -f bin
CARGO := cargo

# Default target: Build OS image
.PHONY: all
all: $(OS_IMAGE)

# Assemble the boot sector
$(BOOT_BIN): $(BOOT_ASM) $(UTILS_ASM)
	@mkdir -p $(BUILD_DIR)
	RUSTFLAGS=-Wl,--verbose $(NASM) $(NASMFLAGS) "src/boot/boot_sector.asm" -o "$(BOOT_BIN)"

# Compile kernel sources using Cargo
$(KERNEL_BIN):
	@mkdir -p $(BUILD_DIR)
	$(CARGO) +nightly rustc --target x86_64-unknown-none.json --release -- -C link-arg=-c
	ar x target/x86_64-unknown-none/release/libdubiousOS.a --output target/x86_64-unknown-none/release/
	ld.lld -m elf_x86_64 -Tlinker.ld -o $(KERNEL_BIN) target/x86_64-unknown-none/release/*.o
#cp target/x86_64-unknown-none/release/libdubiousOS.a $(KERNEL_BIN)
# $(CARGO) build --target x86_64-unknown-none.json --release

# Concatenate boot sector and kernel into OS image
$(OS_IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	(cat $(BOOT_BIN); dd if=$(KERNEL_BIN) bs=1 skip=4096) > $(OS_IMAGE)
# Disgusting hack. In order to make everything work, we
# - compile the kernel into a static library archive (libdubiousOS.a)
# - extract the object files from the archive
# - link the object files into a kernel binary using the linker.ld script. This
#   makes the kernel binary think it's located at address 10000 (which is where
#   the kernel is loaded by the boot sector), so it will compile as such.
# - we then concatenate the boot sector and the kernel binary into the OS image
#   using the dd command. The dd command skips the first 4096 bytes of the kernel
#   because for some reason the kernel binary has a bunch of null bytes and garbage
#   info I don't care about at the beginning of the file.
# This works, but I'm pretty sure it's a crime in most countries.

# Run QEMU with the OS image
.PHONY: run
run: $(OS_IMAGE)
	qemu-system-x86_64 -drive format=raw,file="$(OS_IMAGE)"

# Clean the build directory and Cargo output
.PHONY: clean
clean:
	rm -rf $(BUILD_DIR)
	cargo clean

# Recompile: Clean and build everything
.PHONY: recompile
recompile: clean all

# Rerun: Clean and build everything, run the result
.PHONY: rerun
rerun: clean all run