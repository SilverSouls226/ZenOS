void kernel_main(void) {
    for (;;) {
	// Halt the CPU to do nothing
        __asm__ volatile ("hlt");
    }
}
