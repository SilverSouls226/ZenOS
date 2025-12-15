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

## Cross-compiler dependencies
 - gmp
 - mpfr
 - libmpc

## Roadmap
- [ ] Cross-compiler toolchain
- [ ] Bare-metal kernel entry
- [ ] VGA text output
- [ ] Memory management
- [ ] Interrupt handling
- [ ] Scheduler
- [ ] User mode support
- [ ] File system

## Cross-Compiler Toolchain
A freestanding x86_64-elf cross-compiler is used to ensure the kernel does not depend on the host operating system.
Components:
- binutils (assembler and linker)
- GCC (C compiler without standard library)
The GCC build is configured as freestanding:
- No libc
- No system calls
- No host OS dependencies

## Building the Toolchain
The cross-compiler toolchain is not stored in the repository.
To build it locally run:
```bash
./scripts/build-toolchain.sh
```
This will download, build, and install a freestanding x86_64-elf GCC toolchain under toolchain/install/.