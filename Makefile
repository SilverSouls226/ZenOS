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
