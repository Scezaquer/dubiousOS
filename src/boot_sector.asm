org 0x7c00                  ; Declare the address at which the first instruction in this program is located

mov [BOOT_DRIVE], dl        ; BIOS stores boot drive in DL, remember for later

mov bp, 0x8000              ; base of the stack
mov sp, bp                  ; stack pointer

mov bx, 0x9000              ; Load 2 sectors to 0x0000(ES):0x9000(BX) (this is where the data will end up)
mov dh, 2                   ; from the boot disk
mov dl, [BOOT_DRIVE]
call disk_load

mov di, [0x9000]            ; Print out the first loaded word
call print_hex

mov di, [0x9000 + 512]      ; Print first word from second loaded sector
call print_hex

jmp $                       ; infinite loop

%include "src/print_str.asm"    ; replaces this by the code in print_str.asm
%include "src/print_hex.asm"
%include "src/disk_load.asm"

; Global var
BOOT_DRIVE: db 0

; data
my_string:
    db "Hello, dubious world!!!", 0x00   ; Reserve space for a null-ended string

; padding and magic BIOS number
times 510-($-$$) db 0
dw 0xaa55

; Extra sectors
times 256 dw 0xdada
times 256 dw 0xface