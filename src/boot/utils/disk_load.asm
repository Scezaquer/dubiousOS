; takes arguments
; DL (drive number)
; DH (number of sectors to read)
; BX (data will end up in ES:BX)


disk_load:
    pusha
    push dx         ; Store dx on stack to recall how many sectors we requested to read

    mov ah, 0x02    ; BIOS read sector function
    mov al, dh      ; read dh sectors from the start point
    mov ch, 0x00    ; select cylinder 0
    mov dh, 0x00    ; select head 0

    int 0x13        ; BIOS interrupt

    ; error handling
    jc disk_error      ; Jump if error
    pop dx             ; Restore DX from stack
    cmp dh, al         ; if AL (sectors read) != DH (sectors expected)
    jne disk_error     ;   display error message
    end_disk_load:

    popa
    ret

disk_error:
    pop dx              ; Necessary otherwise popa won't pop the right data at the end of disk_load
    mov di, DISK_ERROR_MSG
    ;call print_string
    jmp $
    jmp end_disk_load

DISK_ERROR_MSG: db "Disk read error", 0