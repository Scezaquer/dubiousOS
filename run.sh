#!/bin/bash

while getopts a flag
do
    case "${flag}" in
        a) ./assemble.sh
    esac
done

qemu-system-x86_64 -drive format=raw,file=build/boot_sector.bin