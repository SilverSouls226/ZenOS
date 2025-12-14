# ZenOS

ZenOS is a minimal educational operating system built from scratch for the x86_64 architecture.

The goal of this project is to understand how an operating system works at the lowest level:
 - booting
 - memory management
 - interrupts
 - multitasking
 - user/kernel separation.

This OS is built using C and x86 assembly, runs on bare metal, and is tested using QEMU.

## Tooling
- Emulator: QEMU (x86_64)
- Compiler: Cross-compiled GCC (x86_64-elf)
- Bootloader: GRUB (Multiboot2)

## Build Requirements

The following tools are required on the host system:
- GNU Make
- GCC and Binutils
- GRUB
- xorriso
- GDB
- QEMU

## Directory Structure
zen-os/<br>
├── README.md<br>
├── .gitignore<br>
├── src/&emsp;&emsp;&emsp;&emsp;&emsp;&emsp;# kernel C code<br>
├── arch/x86_64/&emsp;&ensp;&thinsp;# architecture-specific code (ASM, linker)<br>
├── build/&emsp;&emsp;&emsp;&emsp;&emsp;# build artifacts<br>
└── scripts/&emsp;&emsp;&emsp;&emsp;&thinsp;# helper scripts
