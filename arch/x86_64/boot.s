.section .multiboot, "a"
.align 8

header_start:
    .long 0xE85250D6          # magic
    .long 0                  # architecture (i386/x86_64)
    .long header_end - header_start
    .long -(0xE85250D6 + 0 + (header_end - header_start))

    # End tag (required)
    .word 0
    .word 0
    .long 8

header_end:

.section .text
.global _start
.extern kernel_main

_start:
    mov $stack_top, %rsp
    call kernel_main

.hang:
    cli
    hlt
    jmp .hang

.section .bss
.align 16
stack_bottom:
    .skip 16384
stack_top:
