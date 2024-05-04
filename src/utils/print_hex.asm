; takes di as the hex we want to represent

print_hex:
    pusha

    mov bx, HEX_OUT         ; Point to end of string
    add bx, 5               ;

    mov cx, 4               ; number of iterations in the loop

    replace_HEX_OUT:
        sub cx, 1           ; count one iteration
        mov ax, di          ; di is the hex we want to represent
        and ax, 0x000f      ; only represent the last 4 bits, mask others
        call hex_to_char    ; hex to char conversion subroutine
        mov [bx], al        ; write character in string
        sub bx, 1           ; move to next character
        shr di, 4           ; shift di by 4 bits
        cmp cx, 0           ; end if 4 iterations are complete
        jg replace_HEX_OUT

    mov di, HEX_OUT     ; point to beginning of string
    call print_string   ; print string
    popa
    ret


hex_to_char:
    cmp ax, 0x000a              ; Separate numbers from letters
    jl hex_to_char_number       ; jump to numbers case
    hex_to_char_letter:         ; If character is a letter
        add al, 87              ; convert to ASCII code
        ret

    hex_to_char_number:         ; if character is a number
        add al, 48              ; convert to ASCII code
        ret

HEX_OUT: db '0x0000', 0