.set ALIGN,    1<<0
.set MEMINFO,  1<<1
.set FLAGS,    ALIGN | MEMINFO
.set MAGIC,    0xE85250D6
.set CHECKSUM, -(MAGIC + FLAGS)

.section .multiboot
.align 8
.long MAGIC
.long FLAGS
.long CHECKSUM
.long 0
.long 0

.section .text
.global _start
.extern kernel_main

_start:
    mov $stack_top, %rsp
    call kernel_main

hang:
    cli
    hlt
    jmp hang

.section .bss
.align 16
stack_bottom:
    .skip 16384
stack_top:
