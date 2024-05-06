;32 bits version of the print_string routine (protected mode)
[bits 32]

; Constants
VIDEO_MEMORY equ 0xb8000
WHITE_ON_BLACK equ 0x0f

;This takes EBX as argument (the address of a null terminated string)
print_string_pm:
    pusha
    mov edx, VIDEO_MEMORY   ; pointer to the video memory

print_string_pm_loop:
    mov al, [ebx]           ; load character

    cmp al, 0x00            ; Check we haven't reached the end of the string
    je end_print_string_pm     ; break if we did

    mov ah, WHITE_ON_BLACK  ; load attributes
    mov [edx], ax           ; print char 
    add edx, 2              ; move the pointer to next char cell in video memory
    add ebx, 1              ; move to next character in string

    jmp print_string_pm_loop

end_print_string_pm:
    popa
    ret