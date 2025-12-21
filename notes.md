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
The linker script (`.ld` file, stands for Linker Description, just a convention, linker doesn't care after file extension) is a set of instructions for the linker. The linker
 - decides wherein memory everything lies
 - decides what runs first and
 - how the sections are laid out
 - combines all the `.o` files into one binary
 We use a dedicated linker script so that the linker doesn't assume that we are building a normal program
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
    . = 1M;

    .text : ALIGN(4K) {
        *(.multiboot)
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
 - `. - 1M`
	 - `.` refers to current location counter
	 - `1M` means 1 megabyte (0x100000)
	 - **Translation:** Start placing the kernel at the physical address 1MB.

> [!question] Why 1 MB?
> - BIOS and Legacy real-mode data lives below 1MB
> - Historically safe and conventional
> - GRUB loads kernels here by defualt

 - `.text: ALIGN(4K) {...}`
	 - `.text`: Name of the section
	 - `:`: assignment operator
	 - `ALIGN(4K)`: Alignment Constraint
	 - `{}`: The contents of the section
	 - **Translation:** Create a section `.text` aligned to 4096 bytes.

 > [!Question] Why 4096 bytes (4Kib)?
>- Page size on x86_64 is 4Kib.
>- Makes paging easier later on.
>- Avoids instructions crossing page boundries.

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
	- `.bas` stands for **Block Started by Symbol** (historical name)
	- Contains
		- Uninitialized Globals
		- Zero initialized variables
- `*(COMMON)`
	- Old-style for uninitialized Globals
	- Compiler compatability relic
	- Included for saftey
The memory layout is deterministic and the linker now knows exactly how to construct the `kernel.elf`