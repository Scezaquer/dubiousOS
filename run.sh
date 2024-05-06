#!/bin/bash

# Set default values for input and output folders
INPUT_FOLDER="src"
OUTPUT_FOLDER="build"

# Parse command line arguments
for arg in "$@"
do
    case "${arg}" in
        -a)
            ASSEMBLE=true ;;
        -c)
            COMPILE=true ;;
        -t)
            CONCATENATE=true ;;
        input=*)
            INPUT_FOLDER="${arg#*=}" ;;
        output=*)
            OUTPUT_FOLDER="${arg#*=}" ;;
    esac
done

# Handle flags based on parsed arguments
if [ "$ASSEMBLE" = true ]; then
    nasm "${INPUT_FOLDER}/boot_sector.asm" -f bin -o "${OUTPUT_FOLDER}/boot_sector.bin"
fi

if [ "$COMPILE" = true ]; then
    rustc --target x86_64-unknown-none -O --emit obj "${INPUT_FOLDER}/kernel.rs" -o "${OUTPUT_FOLDER}/kernel.o"
    ld -o "${OUTPUT_FOLDER}/kernel.bin" -Ttext 0x1000 "${OUTPUT_FOLDER}/kernel.o" --oformat binary
fi

if [ "$CONCATENATE" = true ]; then
    cat "${OUTPUT_FOLDER}/boot_sector.bin" "${OUTPUT_FOLDER}/kernel.bin" > "${OUTPUT_FOLDER}/os-image"
fi

# Run the CPU emulator with the kernel image
qemu-system-x86_64 -drive format=raw,file="${OUTPUT_FOLDER}/os-image"
