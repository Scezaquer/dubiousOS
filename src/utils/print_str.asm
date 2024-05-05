; takes di as the adress of the null-ended string to print

print_string:
    pusha
    mov ah, 0x0e                ; scrolling teletype BIOS routine
    mov al, [di]                ; load first character

    loop_print_string:
        cmp al, 0x00            ; Check we haven't reached the end of the string
        je end_print_string     ; break if we did
        int 0x10                ; otherwise print char
        add di, 1               ; move the pointer to next char 
        mov al, [di]            ; load new char
        jmp loop_print_string
    
    end_print_string:
        mov al, 0x0d            ; carriage return
        int 0x10
        mov al, 0x0a            ; line break
        int 0x10
        popa
        ret