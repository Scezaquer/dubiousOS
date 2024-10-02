org 0x7c00                  ; Declare the address at which the first instruction in this program is located
KERNEL_OFFSET equ 0x0
KERNEL_OFFSET2 equ 0x1000   ; kernel will be placed at 0x10000 (es:bx)

mov [BOOT_DRIVE], dl

mov bp, 0x9000              ; base of the stack
mov sp, bp                  ; stack pointer

call load_kernel

call switch_to_pm           ; We never return from here

jmp $                       ; infinite loop

;%include "src/utils/print_str.asm"    ; replaces this by the code in print_str.asm
;%include "src/utils/print_hex.asm"
;%include "src/boot/utils/disk_load.asm"
%include "src/boot/gdt.asm"
%include "src/boot/utils/print_str_pm.asm"
%include "src/boot/switch_to_pm.asm"
%include "src/boot/switch_to_long_mode.asm"
%include "src/boot/gdt64.asm"

[bits 16]
load_kernel:
    ; Ok so this is painful:
    ; We need to load the kernel from the disk to 0x10000. However, we can only
    ; load 127 sectors at a time. So we load the first 127 sectors to 0x10000
    mov ax, KERNEL_OFFSET2
    mov es, ax
    mov bx, KERNEL_OFFSET   ; Setting up params for the disk-loading routine
    mov dl, [BOOT_DRIVE]    ; from the boot disk to address KERNEL_OFFSET
    mov ah, 0x02    ; BIOS read sector function
    mov al, 127     ; read 127 sectors from the start point
    mov ch, 0x00    ; select cylinder 0
    mov dh, 0x00    ; select head 0
    mov cl, 0x02    ; start reading from second sector (i.e. after boot sector)
    int 0x13        ; BIOS interrupt

    ; then we load the next 127 sectors to 0x10000 + 127 * 512 = 0x1F800.
    ; - Every sector is 512 bytes long, 
    ; - every head contains 63 sectors (number 1 through 63)
    ; - every cylinder contains 16 heads (number 0 through 15).
    ; Since we already read 128 sectors (127 from the first read and 1 from the
    ; boot sector), we are now at
    ; - head 128//63 = 2,
    ; - sector 128%63 = 2 (+1 since sectors are 1-indexed),
    ; - cylinder 127//(16*63) = 0.
    ; TODO: Make a function that automates this calculation. NOTE: It is also
    ; illegal to cross a cylinder boundary.
    add bx, 512*127         ; move the pointer to the next 127 sectors
    mov dl, [BOOT_DRIVE]    ; from the boot disk to address KERNEL_OFFSET
    ; We need to re-assign ah and al because the BIOS function will overwrite them
    mov ah, 0x02    ; BIOS read sector function
    mov al, 127     ; read 127 sectors from the start point
    mov ch, 0x00    ; select cylinder 0
    mov dh, 0x02    ; select head 2
    mov cl, 0x03    ; start reading from third sector
    int 0x13        ; BIOS interrupt

    mov ax, 0x0
    mov es, ax
    ret
%if 0
    mov ax, KERNEL_OFFSET2
    mov es, ax
    mov bx, KERNEL_OFFSET   ; Setting up params for the disk-loading routine
    mov dh, 127              ; We load the first 15 sectors (excluding boot)
    mov dl, [BOOT_DRIVE]    ; from the boot disk to address KERNEL_OFFSET
    mov cl, 0x02    ; start reading from second sector (i.e. after boot sector)
    call disk_load

    ;add bx, 512*127         ; 127 sectors * 512 bytes per sector
    ;mov dh, 1               ; We load the first 15 sectors (excluding boot)
    ;mov cl, 0x81
    ;call disk_load

    mov ax, 0x0
    mov es, ax

    ret
%endif
[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm    ; Use 32-bit print routine

    call switch_to_long_mode

    ;call KERNEL_OFFSET      ; call the kernel code

    ;jmp $         ; Infinite loop

[bits 64]
Realm64:
    cli                           ; Clear the interrupt flag.
    mov ax, GDT.Data              ; Set the A-register to the data descriptor.
    mov ds, ax                    ; Set the data segment to the A-register.
    mov es, ax                    ; Set the extra segment to the A-register.
    mov fs, ax                    ; Set the F-segment to the A-register.
    mov gs, ax                    ; Set the G-segment to the A-register.
    mov ss, ax                    ; Set the stack segment to the A-register.

    ; print message 64-bit mode
    mov edi, 0xB8000              ; Set the destination index to 0xB8000.
    mov rax, 0x0f620f2d0f340f36
    mov [edi], rax
    mov rax, 0x0f6d0f200f740f69
    mov [edi+8], rax
    mov rax, 0x0f200f650f640f6f
    mov [edi+16], rax

    ; Clear the screen.
    ;mov rax, 0x0f200f200f200f20
    ;mov edi, 0xB8018
    ;mov ecx, 497
    ;rep stosq

    ;*0x7dc5
    ;*0x7db3
    mov rax, 0x10000       ; Kernel entry point address in long mode
    jmp rax                ; Jump to the 64-bit kernel entry point

    hlt                    ; Halt the processor.

    ; jump to the kernel address
    xor rax, rax
    mov rax, KERNEL_OFFSET2
    shl rax, 4
    add rax, KERNEL_OFFSET
    jmp rax
    
    hlt                           ; Halt the processor.

[bits 16]
; data
BOOT_DRIVE: db 0
MSG_PROT_MODE: db "32-bit PM", 0x00
;MSG_LONG_MODE: db "Succesfully switched to 64-bit Protected Mode", 0x00

; padding and magic BIOS number
times 510-($-$$) db 0
dw 0xaa55