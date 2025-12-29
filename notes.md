# Zen OS Personal Running Notes
## Road-map
- [x] Cross-compiler toolchain
- [ ] Bare-metal kernel entry
- [ ] VGA text output
- [ ] Memory management
- [ ] Interrupt handling
- [ ] Scheduler
- [ ] User mode support
- [ ] File system

## Project Directory
zen-os/
 ├── .git
 ├── .gitignore
 ├── arch/
  |           └── x86_64/
 ├── build/
 ├── README.md
 ├── scripts/
 ├── src/
 └── toolchain/
     ├── build/
      |	     └── binutils/
     ├── install/
     └── src/



## What it is
### QEMU 
Stands for Quick Emulator. It is a machine emulator, fake PC that pretends to be a real computer and allows:
 - debugging the OS without rebooting the hardware
 - the kernel to crash without affecting then host PC
 - attaching debuggers to the kernel 

### Cross-Compiled GCC
GCC (GNU Compiler Collection) that compiles code on one system for another system (e.g: Complies code for x86_64-elf on Arch)
 - Normal compilers inject system specific code such as system calls
 - The Kernel must be freestanding and cannot assume another system like Linux exists under it and hence cannot depend on that system's code

### Multiboot2
A boot protocol (handshake agreement between the bootloader and the kernel) that defines how
 - a bootloader load a kernel
 - how it passes information to the kernel
It loads the kernel, sets up CPU state and tells you about the 
- memory layout
- boot device
- command line
- modules

### base-devel
An Arch Linux package group that is on the host side only used as a toolbox to build things. The kernel never uses this directly (Shouldn't be dependent on the system). Includes
 - make
 - gcc
 - ld
 - headers etc

### GDB
The GNU debugger that lets you:
 - pause kernel execution
 - inspect memory and registers
 - stop instruction by instruction
 Used to find:
 - triple faults
 - invalid memory accesses
 - bad stack setup

### GRUB
Grand Unified Debugger. It 
 - runs before any OS
 - loads the kernel into the memeory
 - hands over control to the OS

### iso
It is a single-file, digital replica (or "image") of an entire optical disk
- A disk image format
 - containing the disc's file system, data, and structure
- can be virtually "mounted" as a real disc
- burned to physical media for installing operating systems
- Used by CDs/DVDs and bootable by VMs
### xorriso
Used to 
 - Create iso images.
 - Packages GRUB + Kernel into one file
 - Boot in QEMU 

### gmp, mpfr, libmpc
Math libraries used internally by GCC. They are build dependencies, not kernel dependencies. They support 
 - Arbitrary precision integers (GMP)
 - Floating-point math with guarantees (MPMR)
 - Complex number arithemetic (MPC)

### x86_64
A CPU architecture that is
- a 64-bit extension of the x86
- Used by Intel and AMD CPUs
- (Required by my laptop)
Kernels are architecture specific so you would have different files for different architectures.

### ELF
Stands for **E**xecuteable and **L**inkable **F**ormat. It is
 - A file format for executable and object files
 - Used by Linus, BSDs and kernels.
 They contain
  - machine code
  - symbol tables
  - sections
  - relocation info
  The kernel is:
   - an ELF file
   - loaded by GRUB and then executed

### Toolchain
it is the **chain of tools** that turns human-written source code into something a CPU can execute, i.e full pipeline that turns source code into machine code. This toolchain includes
 - x86_64-elf-gcc (compiler)
 - x86_64-elf-as (assembler)
 - x86_64-elf-ld (linker)
Each tool feeds to the next and all of them must agree on formats and assumptions.
C / ASM source → assembler → compiler → linker → executable binary
### binutils 
Collection of binary tools. They don't compile C but are essential for turning instructions into executable. Includes:
 - as (assembler)
 - ld (linker)
 - objdump (inspect binaries)
 - nm (symbol tables)

### Makefile
A Makefile tells make what files depend on what other files, and which commands to run to turn inputs into outputs.
Example:
 - kernel.o depends on kernel.c
 - kernel.elf depends on kernel.o and linker.ld
If kernel.c changes:
 - make recompiles kernel.o
 - then relinks kernel.elf
 - nothing else
Why this matters in OS dev:
 - You will compile C + assembly
 - You will link with custom scripts
 - Manual builds will break your sanity

### ABI - Application Binary Interface
Dictates how compiled code actually interacts at the machine level. A system ABI is a set of rules that let separately compiles code to work together. It's like a contract that defines things like:
- How function arguments are passed (registers vs stack)
- Which registers a function must preserve
- How the stack is aligned
- How system calls are made
- How executables are laid out in memory
- How the OS starts a program
- How errors are returned
It is required because multiple different programs written by different people operate using the same files. Like GCC compiles the code, the linker links it, the loader loads it, the kernel runs it. 
All these programs must agree on questions like
 - Where does the execution start
 - Where are arguments
 - Who cleans the stack
These are answered by the ABI



> [!warning]
> Do not confuse ABI with CPU architecture. CPU architecture dictates what instructions and registers exist. The system ABI dictates how those registers are used by the software.
> The same CPU can have different ABIs.

### System V (SYSV) ABI
SYSV ABI is the dominant ABI for Unix-line systems on x86_64. It specifies things like:
1. Function Calls
2. Stack Rules
3. Register Roles
4. Program Setup
Linux, BSD, macOS (with variations) all rely on this.

>[!info] Extra Info
>BSD stands for Berkeley Software Distribution. It is a family of Unix-like operating systems that originated at UC Berkeley, historically parallel to AT&T Unix. Examples of major modern BSDs are FreeBSD, OpenBSD, NetBSD.
> These are full operating systems (kernel + userland) that are not Linux, not macOS and are still very much alive.

### libc
It is the C standard library. A massive collection of code that provides:
 - printf, malloc, free, memcpy, strlen
 - file I/O
 - process control
 - system call wrappers
On Linux, libc usually refers to glibc (GNU libc) or musl. This is required for normal cases because the C language itself only provides syntax, basic operators and types, it does not provide printing, memory allocation, file access, threads etc. These are provided by libc.

The Kernel must not use libc because libc assumes that an OS, system calls, file descriptor tables, virtual memory and processes exist. But the kernel (that is supposed to provide these functionalities, is the OS, it is the file you are trying to make).

If you used libc, it would try to call syscalls, but since no syscalls exist yet, it would cause an instant crash or undefined behaviour.

> [!important] Important: libc vs kernel code
> User programs depend on libc and use syscalls to talk to the kernel.
> The kernel implements the syscalls and hence cannot depend on libc. The kernel may later include a very tiny custom *libc-like* subset. Early kernels often implement `memcpy`, `memset`, `strlen` etc manually.

### Linker
The linker
 - decides wherein memory everything lies
 - decides what runs first and
 - how the sections are laid out
 - combines all the `.o` files into one binary
The linker script (`.ld` file, stands for Linker Description, just a convention, linker doesn't care after file extension) is a set of instructions for the linker. We use a dedicated linker script so that the linker doesn't assume that we are building a normal program. The `.ld` is like a blueprint used by the linker.

## Commands

### Installing required packages
`sudo pacman -S qemu-full base-devel gdb grub xorriso gmp mpfr libmpc`
### Confirming QEMU download
`qemu-system-x86_64 --version`
### Downloading and Extracting Required tools
```bash
cd toolchain/src
wget https://ftp.gnu.org/gnu/binutils/binutils-2.41.tar.xz
wget https://ftp.gnu.org/gnu/gcc/gcc-13.2.0/gcc-13.2.0.tar.xz
tar -xf binutils-2.41.tar.xz
tar -xf gcc-13.2.0.tar.xz
```
 - Sets pwd to toolchain/src. 
 - `wget` = web get
     - It connects to the given URL and downloads the file, saving it to the current directory while keeping the original file name (`binutils-2.41.tar.xz` and `gcc-13.2.0.tar.xz`)
  - `binutils-2.41.tar.xz` and `gcc-13.2.0.tar.xz` are **compressed archives** containing the binutils source code.
 - tar is an archive tool. `-x` means to extract the given file, `-f` specifies the file the operation is to be done on.
     - Translation: Extract all files from this archive into the current directory

### Building binutils (assembler and linker)
```bash
cd ../build
mkdir binutils
cd binutils

../../src/binutils-2.41/configure \
  --target=x86_64-elf \
  --prefix=$(pwd)/../../install \
  --with-sysroot \
  --disable-nls \
  --disable-werror

make -j$(nproc)
make install
```
 - `cd ../build`, `mkdir binutils`, `cd binutils` moves you from `/zen-os/toolchain/src/` to `/zen-os/toolchain/build/binutils/`. We do this so that we build outside the source directory, keeping the source clean and allowing us to rebuild with different options. This is called an out-of-tree-build.
 - `../../src/binutils-2.41/configure` runs the `configure` script in the current `toolchain/build/binutils/` directory even though is it located in the `toolchain/src/` directory.
 - `--target=x86_64-elf` tells the script to generate code for x86_64 without any operating system ABI. Makes it useable for kernels.
 - `--prefix=$(pwd)/../../install` tell the script where to save the final binaries.
     - `pwd` right now is `/zen-os/toolchain/build/binutils`
     - `pwd/../..` becomes `/zen-os/toolchain`
     - `pwd/../../install` becomes `/zen-os/toolchain/installs`
     - This avoids polluting `/usr/bin`, requiring sudo, conflicting with system tools.
 - `--with-sysroot` Tells the script to assume a separate root directory for the target system.
     - Prepares for future headers and libraries 
    - Is standard practice for OS dev
    - Prevents accidental host dependency leakage
- `--disable-nls` disables natural language support (Translation, localization, message catalogs.). Which means no localization, fewer dependencies and simpler builds.
- `--disable-werror` Prevents warnings being treated as errors. Newer compilers + older code = warnings, werror would break the build unnecessarily. Disabling it makes the build robust.
- `make -j$(nproc)` Breakdown: 
     - `make` builds according to makefile
     - `-j` allows multiple jobs at once
     - `$(nproc)` number of CPU cores
 - Translation: Compile binutils using all available CPU cores. Makes builds faster. Does not change the output, only speed.
 - `make install` copies the built tools into the directory specified by --prefix

### Verifying binutils installation
```bash
../../install/bin/x86_64-elf-ld --version
```
Should give output the version number, something along the lines of:
```terminal
GNU ld (GNU Binutils) 2.41
Copyright (C) 2023 Free Software Foundation, Inc.
This program is free software; you may redistribute it under the terms of
the GNU General Public License version 3 or (at your option) a later version.
This program has absolutely no warranty.
```
### Building GCC (freestanding, no libc)
C compiler without standard library or headers
```bash
cd ../
mkdir gcc
cd gcc

../../src/gcc-13.2.0/configure \
  --target=x86_64-elf \
  --prefix=$(pwd)/../../install \
  --disable-nls \
  --enable-languages=c \
  --without-headers

make all-gcc -j$(nproc)
make install-gcc
```
- `cd ../`, `mkdir gcc`, `cd gcc` moves you from `/zen-os/toolchain/build/binutils` to `/zen-os/toolchain/build/gcc/`. We do this so that we build outside the source directory, keeping the source clean and allowing us to rebuild with different options. This is called an out-of-tree-build.
- `../../src/gcc-13.2.0/configure` runs the configure script in the current  `toolchain/build/gcc` directory even though it is located in the `toolchain/src/gcc-13.2.0/` directory.
- `--target=x86_64-elf` tells the script to generate code for x86_64 without any operating system ABI. Makes it usable for kernels.
- `--prefix=$(pwd)/../../install` tells the script where to save the final binaries.
    - `pwd` right now is `/zen-os/toolchain/build/gcc`
    - `pwd/../..` becomes `/zen-os/toolchain`
    - `pwd/../../install` becomes `/zen-os/toolchain/installs`
    - This avoids polluting `/usr/bin`, requiring sudo, conflicting with system tools.
- `--disable-nls` disables natural language support (Translation, localization, message catalogs.). Which means no localization, fewer dependencies and simpler builds.
- `--enable-languages=c` tells GCC to build only the C compiler, not C++, fortan or anything else.  Everything else is overhead.
- `--without-headers` tells GCC not to expect libc headers to exist. It enforces freestanding mode, without it
    - GGC assumes a hosted environment
    - Tries to use system headers
    - Breaks kernel compilation subtly
- `make all-gcc -j$(nproc)` builds the GCC frontend, code generator but not all runtime libraries. We don't do the full GCC because
    - No libc
    - No target OS
    - Runtime libraries come later (or never)
- `make install-gcc` installs x86_64-elf-gcc and supporting internal files. No libraries, no headers.
- This installation is expected to take some time.

### Verifying the GCC installation
```bash
../../install/bin/x86_64-elf-gcc --version
```
Should give output the version number, something along the lines of:
```terminal
x86_64-elf-gcc (GCC) 13.2.0
Copyright (C) 2023 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

### Sanity Test
```bash
mkdir -p scripts/tests
nano scripts/tests/test.c
```
`test.c`:
```C
void _start(void) {
    for (;;);
}
```
Compile it:
```bash
toolchain/install/bin/x86_64-elf-gcc \
  -ffreestanding -nostdlib \
  -c scripts/tests/test.c \
  -o scripts/tests/test.o
```
 - `ffreestanding` tells GCC that this is not a normal program so no main, no startup code and no assumptions about the OS.
 - `nostdlib` tells GCC to not like any standard libraries and prevents libc, crt0 and systemcalls which is mandatory for kernels.
 - `-c` tells GCC to only compile the source file, no linking, no runtime executions, just turning the source file into an object file. Hence this results in a `.o` file.
 - `-o scripts/tests/test.o` specifies the output path where the resulting `.o` file should be saved. Important to be done in OS dev.
This would create a object file (`test.o`) with the same name as the source file (`test.c`)
You should not get any errors or any messages.
Checking the file type:
```bash
file scripts/tests/test.o
```
Should result in the following output
```terminal
scripts/tests/test.o: ELF 64-bit LSB relocatable, x86-64, version 1 (SYSV), not stripped
```
This indicates that the output file is a  **64-bit** **relocatable object** of **ELF format** for the **x86-64**.
- ELF (Executable and Linkable Format)
    - It is a standardized binary file format that is understood by compilers, linkers, bootloaders and kernels.
    - It is the common language (file type) of the toolchain. The compiler emits ELF, linker consumes ELF, GRUB loads ELF, your kernel is an ELF.
    - Can represent object files, executable, shared libraries, kernels.
- 64-bit
    - System bus size (Registers, addresses etc)
- LSB
    - Least Significant Byte First. Describes endianness. Using LSB because x86 CPUs are little-endian. Means that
        - Multi byte numbers are stored in little-endian.
        - Lowest byte at lowest address.
- Relocatable Object
    - `.o` files that contain code, symbols, relocation entries.
    - This is not the final executable, has no fixed memory addresses and can be moved around by the linker.
    - The linker decides where everything lives, applies relocation and produces the final ELF kernel.
- x84-64
    - Tells you the ISA (Instruction Set Architecture) the object file was made for.
    - Shows that we made the correct machine code for AMD64 / Intel 64 and is for 64-bit x86 not for ARM, i386 etc.
- Version 1 (SYSV)
    - Refers to the ELF ABI Version.
    - System V ABI is the standard Unix ABI, used by Linux, BSDs, and bootloaders.
    - GRUB expects the System V ABI so our toolchain must produce the same.
- Not Stripped:
    - Still includes debug symbols and function names are present so that GDB can understand it.
    - Stripping removes them to save space which we do not want to do in development as it would make debugging painful.
To look inside the file, we can run the following command:
```bash
toolchain/install/bin/x86_64-elf-objdump -d scripts/tests/test.o
```
Which shows us the contents of the object file (in assembly)
```terminal
scripts/tests/test.o:     file format elf64-x86-64


Disassembly of section .text:

0000000000000000 <_start>:
   0:	55                   	push   %rbp
   1:	48 89 e5             	mov    %rsp,%rbp
   4:	eb fe                	jmp    4 <_start+0x4>
```
 - `_start` is the entry symbol. There is no main in a kernel program, this is where the execution begins. GRUB jumps to here.
 - `push %rbp` saves the base pointer. This is a standard function prologue emitted by GCC.
 - `mov %rsp, %rbp` sets up the stack frame. Again, just standard compiler behaviour.
 - `jump 4` is the infinite loop generated by `for (;;);`.
This indicates that the cross-compiler is working correctly, is free standing and produces correct architecture code not dependent on the host system.

### Creating Kernel Linker Script
Create
```bash
nano arch/x86_64/linker.ld
```
`arch/x86_64/linker.ld`
```ld
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

```
 - Kernel loads at 1MB
 - `_start` is the entry symbol
 - Page-aligned sections simplify later memory work
 - `ENTRY(_start)`
    - `ENTRY` is a linker directive
    - `_start` is a symbol name
    - **Translation:** When the kernel is loaded, execution begins at the symbol `_start`.
    - Must match the `.global _start` in the multiboot2 file (next section). If the symbol doesn't exist then the kernel won't boot.
- `SECTIONS` indicates the start of the memory layout description. It describes:
     - Memory addresses
     - Section Placement
     - Alignment
 - `.multiboot` creates an output section names `.multiboot`
     - `ALING(8)` ensures 8 bit alignment (as required by Multiboot2 specification)
 - `:AT(0)`
     - Sets File offset = 0
     - Memory address is irrelevant since GRUB scans the file, not virtual memory
     - This guarantees the header appears early enough for GRUB to find it.
     - File layout is what GRUB sees, runtime layout is where the kernel executes.
 - `KEEP(*(.multiboot))`
     - Forces the linker to keep this section and not  discard it even if it looks unused.
 - `. = 1M` sets the virtual memory address counter.
     - `.` refers to current location counter
     - `1M` means 1 megabyte (0x100000)
     - **Translation:** Start placing the kernel at the physical address 1MB.

> [!question] Why 1 MB?
> - BIOS and Legacy real-mode data lives below 1MB
> - Historically safe and conventional
> - GRUB loads kernels here by default

 - `.text: ALIGN(4K) {...}`
     - `.text`: Name of the section
     - `:`: assignment operator
     - `ALIGN(4K)`: Alignment Constraint
     - `{}`: The contents of the section
     - **Translation:** Create a section `.text` aligned to 4096 bytes.

 > [!Question] Why 4096 bytes (4Kib)?
>- Page size on x86_64 is 4Kib.
>- Makes paging easier later on.
>- Avoids instructions crossing page boundaries.

- `*(.multiboot)` 
    - `*`: wildcard (from all input object files)
    - `(.multiboot)`: section name
    - **Translation:** Take all multiboot sections from all object files and put them here.
 - `*(.text*)`
    - Same as `*(.multiboot)` but the second  wildcard matches
        - `.text`
        - `.text.startup`
        - `.text.foo`
    - **Translation:** Place all executable code here
- `.rodata : ALIGN { *(.rodata*) }`
    - `.rodata` stands for read only data
    - Includes
        - Constants
        - String literals
        - Lookup Tables
    - Separated because 
        - Can later be marked as read-only in paging
        - Prevents accidental writes
- `.data : ALIGN(4K) { *(.data*) }`
    - Has initialized Global Variables
- `.bas : ALIGN(4K) {...}`
    - `*(.bas*)` stands for **Block Started by Symbol** (historical name)
    - Contains
        - Uninitialized Globals
        - Zero initialized variables
    - `*(COMMON)`
        - Old-style for uninitialized Globals
        - Compiler compatibility relic
        - Included for safety
The memory layout is deterministic and the linker now knows exactly how to construct the `kernel.elf`

### Multiboot2 header
Required to let GRUB to load this binary. Create the following file
```bash
nano arch/x86_64/boot.s
```
`nano arch/x86_64/boot.s`:
```asm
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
```
 - This code 
     - Declares Multiboot2 compliance
     - Creates a stack manually
     - Transfer control to C

 - `.section multiboot, "a"`
     - creates a section names `.multiboot`
     - `"a"` means ALLOC -> this loads this section into memory because GRUB scans only loaded sections. Without it, GRUB would never see this header.
- `.align 8`
    - It aligns the next symbol on an 8 byte boundary.
    - Required by Multiboot2 spec. GRUB will reject it if it is not aligned properly.
- `header_start:`
    - label marking the exact beginning of the Multiboot2 header
    - Everything GRUB reads starts form here
    - Length and checksum calculations depend on this label
- `.long 0xE85250D6`
    - The **Multiboot2 magic number**
    - Identifies this binary as Multiboot2-compliant
    - Stored little-endian in memory
    - If this value is wrong, GRUB ignores the kernel
- `.long 0`
    - Architecture field
    - `0` means **i386 architecture**
    - Multiboot2 uses this value for both 32-bit and 64-bit x86
    - Required even for x86_64 kernels
- `.long header_end - header_start`
    - Total length of the Multiboot2 header in bytes
    - GRUB uses this to know how many bytes to parse
    - Includes:
        - magic
        - architecture
        - length
        - checksum
        - all tags (including the end tag)
- `.long -(0xE85250D6 + 0 + (header_end - header_start))`
    - This is a checksum value that Multiboot2 requires before trusting the header

> [!info] MAGIC and CHECKSUM
> The MAGIC number is not any arbitrary number. GRUB searches for this exact value, the kernel binary will be ignored if this number is not found.
> CHECKSUM is used for a simple integrity check to prevent false positives. It's value is calculated such that $$\text{MAGIC} + \text{Architecture} + \text{Length of Header} + \text{CHECKSUM} = 0 \mod 2^{32}$$

- `.word 0`, `.word 0`, `.long 8` together make the Multiboot2 end tag.
    - It sets
        - type = 0
        - flags = 0
        - size = 8
    - It tells GRUB to stop parsing and that there are no more tags.
- `header_end:`
    - Marks the end of the header. Used along with the `header_start` label to compute the length of the header.
- `.section text`
    - This is the start of the executable code. This section will be loaded at 1MiB (as per the linker script)
    - CPU begins execution here after GRUB hands off control.
- `.global _start`
    - Make `_start` visible to the linker
    - Without this `ENTRY(_start)` fails and the kernel will not boot.
- `.extern kernel_main`
    - Declares that this symbol `kernel_main` (declared in C) exists somewhere.
- `_start:`
    - This is the first instruction the CPU executes
- `mov $stack_top, %rsp`
    - `$`: immediate value
    - `stack_top`: address
    - `%rsp`:  stack pointer register
    - Initializes the stack pointer. No stack exists till this line.
- `call kernel_main`
    - Pushes return address.
    - Jumps to C code.
- `hang:`
    - Label
- `cli`
    - Clear Interupt Flag
    - Disables hardware interupts
- `hlt`
    - Halt CPU until interrupt
    - It is a low power, stable state
- `jmp hang`
    - Infinite Loop so that the kernel may never return.
- `.section .bss`
    - Switch to uninitialized memory.
- `.align 16`
    - Align stack to 16 bytes.
    - Required by ABI.
- `stack_bottom:`
    - Label
- `.skip 16384`
    - Reserve 16KB for stack
- `stack_top`:
    - Label at the top of the stack.
    - Stack grows downwards.

### Kernel main 
Create the kernel c file
```bash
nano src/kernel.c
```
`src/kernel.c`:
```
void kernel_main(void) {
    for (;;) {
        __asm__ volatile ("hlt");
    }
}
```
This does nothing, just halts the CPU.
`__asm__ volatile ("hlt")` embeds the assembly statement "hlt" without any optimization whatsoever.
    - `__asm__` is a GCC keyword to embed assembly.
    - `vloatile` tells the compiler not to take this out while optimizing. Without it, the compiler may:
        - remove the instruction
        - reorder it
        - assume it does nothing
    - `"hlt"` is the raw assembly instruction that halts the CPU till an interrupt occurs. Since interrupts are disabled, the CPU will sleep forever. This prevents
        - Undefined execution
        - Falling off the end of `kernel_main`

### Makefile
Create:
```bash
nano Makefile
```
Makefile:
```
TARGET = x86_64-elf
CC = toolchain/install/bin/$(TARGET)-gcc
AS = toolchain/install/bin/$(TARGET)-as
LD = toolchain/install/bin/$(TARGET)-ld

CFLAGS = -ffreestanding -O2 -Wall -Wextra
LDFLAGS = -T arch/x86_64/linker.ld -nostdlib

KERNEL = build/kernel.elf

OBJS = \
  arch/x86_64/boot.o \
  src/kernel.o

all: $(KERNEL)

build/kernel.elf: $(OBJS)
    $(LD) $(LDFLAGS) -o $@ $^

arch/x86_64/boot.o: arch/x86_64/boot.s
    $(AS) $< -o $@

src/kernel.o: src/kernel.c
    $(CC) $(CFLAGS) -c $< -o $@

clean:
    rm -rf build/*.o build/*.elf
```
A makefile is a dependency graph describes relationships and  is what make uses to decide which files need to be re compiled and linked together by checking if its dependencies are newer.
- Lines 1 - 13 just assign reusable strings to variables used for textual substitution
    - `TARGET = x86_64-elf` sets the target Architecture
    - `CC = toolchain/install/bin/$(TARGET)-gcc` sets the C Compiler Path
    - `AS = toolchain/install/bin/$(TARGET)-as` sets the Assembler Path
    - `LD = toolchain/install/bin/$(TARGET)-ld` sets the Linker Path
    - `CFLAGS = -ffreestanding -O2 -Wall -Wextra` sets the compiler flags
        - `-ffreestanding` tells GCC this is not a normal program, not to use libc, no implicit main, not host OS features
        - `-O2` tells GCC to optimize reasonably and avoids insane reordering unlike `-03`
        - `-Wall` enables common warnings
        - `-Wextra` enables more warnings
    - `LDFLAGS = -T arch/x86_64/linker.ld -nostdlib` sets the linker flags
        - `-T linker.ld` uses our linker script and ignores default memory layout.
        - `-nostdlib` tells not to link libc or startup code.
    - `KERNEL = build/kernel.elf` defines the final product.
    - `OBJS = arch/x86_64/boot.o src/kernel.o` lists the object files that the kernel uses.
`all`, `build/kernel.elf`, `arch/x86_64/boot.o`, `src/kernel.o`, `clean` are meta-targets.  It won't produce files with those names, it checks that target's dependencies. For example, it  just says to satisfy `all`, make sure `$(KERNEL)` exists. `all` is just the de-facto default target name. Just a convention, it can be anything, `make` will always run the first target by default unless specified, for example `make clean`.
- `all: $(KERNEL)` says that to build all, you must build `build/kernel.elf`
- `build/kernel.elf: $(OBJS)` says that to build `build/kernel.elf` you need `arch/x86_64/boot.o` and `src/kernel.o`
- `$(LD) $(LDFLAGS) -o $@ $^` is the command line (must start with a tab) that tells make how to build `build/kernel.elf`.
    - `$(LD)` refers to the linker executable
    - `$(LDFLAGS)` refers to the linker flags
    - `-o` specifies the output file 
    - `$@` refers to the target name (in this case `build/kernel.elf`)
    - `$^` refers to all the dependencies (the `.o` files)
    - So this basically expands to `toolchain/install/bin/$(TARGET)-ld -T arch/x86_64/linker.ld -nostdlib -o build/kernel.elf arch/x86_64/boot.o src/kernel.o`.
- `arch/x86_64/boot.o: arch/x86_64/boot.s` says that `boot.o` requires `boot.s`
- `$(AS) $< -o $@`is the command that make runs to build `boot.o` using `boot.s`
    - `$(AS)` refers to the assembler.
    - `$<` refers to the first dependency. (in this case `arch/x86_64/boot.s`)
    - `-o` specifies the output file
    - `$@` refers to the target name. (in this case `arch/x86_64/boot.o`)
- `src/kernel.o: src/kernel.c` says that `kernel.o` depends on `kernel.c`.
- `$(CC) $(CFLAGS) -c $< -o $@` is the command that make runs to build `kernel.o` from `kernel.c`.
    - `$(CC)` refers to the compiler.
    - `$(CFLAGS)` refers to the compiler flags.
    - `-c` tells GCC to only compiler, and not to link. (Since we are doing that separately)
    - `$<` refers to the first dependency.
    - `-o` specifies the output file.
    - `$@` refers to the target file.
- `clean:` is the clean target. Has no dependencies. Is called a phony target and is used to delete build artifacts. which can be and has to be run explicitly by doing `make clean`.
- `rm -rf build/*.o build/*.elf` deletes all `.o` and `.elf` files in `build/`
> [!info] How does make decide whether is should rebuild a target or not?
> make compares the timestamps for the file modification time (mtime) for the target and dependencies. There are 3 possible cases:
> 1. The target does not exist: make builds the targets
> 2. The target exists and mtime(target) < any(mtime(dependencies)): rebuild the target
> 3. The target exists and mtime(target) > all(mtime(dependencies)): do nothing
> This is a reliable method because code editors update mtime when saving a file, compilers, assemblers and linkers update mtime after compiling, assembling or linking a file and the file system keeps track of the mtime of all files.

### Build the kernel
```bash
make
```
Should build without any errors.
### Create ISO filesystem
```bash
mkdir -p iso/boot/grub
cp build/kernel.elf iso/boot/kernel.elf
```
### GRUB config
Create `iso/boot/grub/grub.cfg` with the following contents:
```
set timeout=0
set default=0

menuentry "Zen OS" {
    multiboot2 /boot/kernel.elf
    boot
}
```
- `set timeout=0` assigns timeout the value of 0, i.e shows the grub menu for 0 seconds.
- `set default=0` the index of the default menu entry to boot. (Refers to first index since it follows 0-based indexing)
- `menuentry "Zen OS" {}` defined a bootable menu item.
    - `menuentry` GRUB keyword for a boot option.
    - `"Zen OS"` human-readable name show in the entry.
    - `{}` block of commands to execute if that entry is chosen.
    - `multiboot2 /boot/kernel.elf` 
        - `multiboot2` tells grub that the file about to be loaded is a Multiboot2-compliant kernel.
            - GRUB scans the binary for a multiboot2 header, verifies magic number, checks checksum, reads flags, builds boot information structures and then loads the kernel into memory.
            - If any of those fail then GRUB refuses to boot
        - `/boot/kernel.elf` is the absolute path inside the ISO file system, not the host file system and is hence resolved relative to the ISO root.
    - `boot` transfers control to the loaded kernel. CPU jumps to the kernel entry point and `_start` symbol executes. GRUB no longer exists as far as the CPU is concerned.
### Building the ISO
```
grub-mkrescue -o zen-os.iso iso
```
- `grub-mkrescue`
    - Creates a bootable disk image
    - Installs GRUB boot sectors
    - Builds a filesystem
    - Embeds GRUB modules
    - Sets up BIOS and (optionally) UEFI boot paths
- `-o zen-os.iso` specifies the output iso image file that will be the bootable CD-ROM image.
- `iso` is the input directory. Is is the structure that becomes the disk. With this, GRUB
    - Treats `iso/` as the file system root.
    - Packs it into an ISO 9660 image
    - Places GRUB in the correct boot locations
    - Copies `boot/grub/grub.cfg` and `boot/kernel.elf`
Should not result in any errors and the following output (or something similar)
```bash
xorriso 1.5.6 : RockRidge filesystem manipulator, libburnia project.

Drive current: -outdev 'stdio:zen-os.iso'
Media current: stdio file, overwriteable
Media status : is blank
Media summary: 0 sessions, 0 data blocks, 0 data, 30.1g free
Added to ISO image: directory '/'='/tmp/grub.pgOQwB'
xorriso : UPDATE :    1058 files added in 1 seconds
Added to ISO image: directory '/'='/home/silversouls/projects/zen-os/iso'
xorriso : UPDATE :    1062 files added in 1 seconds
xorriso : NOTE : Copying to System Area: 512 bytes from file '/usr/lib/grub/i386-pc/boot_hybrid.img'
ISO image produced: 15586 sectors
Written to medium : 15586 sectors at LBA 0
Writing to 'stdio:zen-os.iso' completed successfully.
```