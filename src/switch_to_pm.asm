[bits 16]
; switch to protected mode (32 bits)
switch_to_pm:
    cli                     ; Switch off all interrupts, otherwise big problems

    lgdt [gdt_descriptor]   ; Load global descriptor table, which defines the PM segments

    mov eax, cr0            ; Set the first bit of cr0 to 1 to switch to PM
    or eax, 0x1             ;
    mov cr0, eax            ;

    jmp CODE_SEG:init_pm    ; Make a far jump (i.e. to a new segment) to flush the cache

[bits 32]
; Initialize registers and the stack once in PM
init_pm:
    mov ax, DATA_SEG    ; In PM, our old segments are meaningless.
    mov ds, ax          ; We point our segment registers ot the data sector
    mov ss, ax          ; defined in the GDT
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000    ; Update stack position to be at the top of the free space
    mov esp, ebp        ; 

    call BEGIN_PM
