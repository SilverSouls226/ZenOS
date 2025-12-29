ENTRY(_start)

SECTIONS
{
    /* Multiboot header must be in first 32 KiB of file */
    .multiboot ALIGN(8) : AT(0) {
        KEEP(*(.multiboot))
    }

    /* Kernel is loaded at 1 MiB in memory */
    . = 1M;

    .text : ALIGN(4K) {
        *(.text*)
    }

    .rodata : ALIGN(4K) {
        *(.rodata*)
    }

    .data : ALIGN(4K) {
        *(.data*)
    }

    .bss : ALIGN(4K) {
        *(COMMON)
        *(.bss*)
    }
}
