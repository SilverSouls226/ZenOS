## Road-map
- [ ] Cross-compiler toolchain
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
 ├── arch
  |           └──x86_64
 ├── build
 ├── README.md
 ├── scripts
 ├── src
 └── toolchain
	├── build
	├── install
	└── src



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

## Commands

### Installing required packages
`sudo pacman -S qemu-full base-devel gdb grub xorriso gmp mpfr libmpc`
### Confirming QEMU downlaod
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
```
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
 - `cd ../build`, `mkdir binutils`, `cd binutils` moves you from `/zen-os/toolchain/src/` to `/zen-os/toolchain/build/binutils/`
 - `../../src/binutils-2.41/configure` runs the `configure` script in that `build` directory even tho is it located in the `src` directory 
 - `--target=x86_64-elf` tells the script to generate code for x86_64 without any operating system ABI.
 - `--prefix=$(pwd)/../../install` tell the script where to save the final binaries.
	 - `pwd` right now is `/zen-os/toolchain/build/binutils`
	 - `pwd/../..` becomes `/zen-os/toolchain`
	 - `pwd/../../install` becomes `/zen-os/toolchain/installs`
 - This avoids polluting `/usr/bin`, requiring sudo, conflicting with system tools.
 - `--with-sysroot` Tells the script to assume a separate root directory for the target system.
 - This
	 - Prepares for future headers and libraries 
	- Is standard practice for OS dev
	- Prevents accidental host dependency leakage
- `--disable-nls` disables natural language support (Translation, localization, message catalogs.)
- `--disable-werror` Prevents warnings being treated as errors. Newer compilers + older code = warnings, werror would break the build unnecessarily. Disabling it makes the build robust.
- `make -j$(nproc)` Breakdown: 
	 - `make` builds according to makefile
	 - `-j` allows multiple jobs at once
	 - `$(nproc)` number of CPU cores
 - Translation: Compile binutils using all available CPU cores. Makes builds faster. Does not change the output, only speed.
 - `make install` copies the built tools into the directory specified by --prefix
