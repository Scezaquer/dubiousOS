ENTRY(_start)

SECTIONS {
    . = 0x10000;

    .text : {
        *(.text._start)
        *(.text*)        /* Text/code section */
    }

    .rodata :
    {
        *(.rodata*)      /* Read-only data */
    }

    .data :
    {
        *(.data*)        /* Initialized data */
    }

    .bss :
    {
        *(.bss*)         /* Uninitialized data */
        *(COMMON)
    }

    /DISCARD/ : { *(.eh_frame*) *(.debug*) }
}
