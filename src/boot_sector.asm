org 0x7c00                  ; Declare the address at which the first instruction in this program is located
KERNEL_OFFSET equ 0x1000

mov [BOOT_DRIVE], dl

mov bp, 0x9000              ; base of the stack
mov sp, bp                  ; stack pointer

mov di, MSG_REAL_MODE
call print_string           ; Announce we're booted in real mode

call load_kernel

call switch_to_pm           ; We never return from here

jmp $                       ; infinite loop

%include "src/utils/print_str.asm"    ; replaces this by the code in print_str.asm
%include "src/utils/print_hex.asm"
%include "src/utils/disk_load.asm"
%include "src/gdt.asm"
%include "src/utils/print_str_pm.asm"
%include "src/switch_to_pm.asm"

[bits 16]
load_kernel:
    mov di, MSG_LOAD_KERNEL
    call print_string       ; Announce we're loading the kernel

    mov bx, KERNEL_OFFSET   ; Setting up params for the disk-loading routine
    mov dh, 15              ; We load the first 15 sectors (excluding boot)
    mov dl, [BOOT_DRIVE]    ; from the boot disk to address KERNEL_OFFSET
    call disk_load

    ret

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm    ; Use 32-bit print routine

    call KERNEL_OFFSET

    jmp $         ; Infinite loop

; data
BOOT_DRIVE: db 0
MSG_REAL_MODE: db "Started in 16-bit Real Mode", 0x00
MSG_PROT_MODE: db "Succesfully switched to 32-bit Protected Mode", 0x00
MSG_LOAD_KERNEL: db "Loading kernel into memory", 0x00

; padding and magic BIOS number
times 510-($-$$) db 0
dw 0xaa55