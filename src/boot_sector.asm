org 0x7c00                  ; Declare the address at which the first instruction in this program is located

mov bp, 0x9000              ; base of the stack
mov sp, bp                  ; stack pointer

mov di, MSG_REAL_MODE
call print_string

call switch_to_pm           ; We never return from here

jmp $                       ; infinite loop

%include "src/utils/print_str.asm"    ; replaces this by the code in print_str.asm
%include "src/utils/print_hex.asm"
;%include "src/utils/disk_load.asm"
%include "src/gdt.asm"
%include "src/utils/print_str_pm.asm"
%include "src/switch_to_pm.asm"

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm    ; Use 32-bit print routine

    jmp $         ; Infinite loop

; data
MSG_REAL_MODE: db "Started in 16-bit Real Mode", 0x00
MSG_PROT_MODE: db "Succesfully switched to 32-bit Protected Mode", 0x00

; padding and magic BIOS number
times 510-($-$$) db 0
dw 0xaa55