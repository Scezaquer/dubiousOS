#!/bin/bash

# Handle the -a and -c flags
while getopts ac flag
do
    case "${flag}" in
        # -a flag assembles the boot sector
        a) ./assemble.sh ;;
        # -c flag compiles the kernel
        c) 
            rustc --target x86_64-unknown-none -O --emit obj src/kernel.rs -o build/kernel.o
            ld -o build/kernel.bin -Ttext 0x1000 build/kernel.o --oformat binary;;
    esac
done

# run the cpu emulator with the kernel image we made
qemu-system-x86_64 -drive format=raw,file=build/boot_sector.bin
