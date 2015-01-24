# KL26 Bootloader
## Kevin Cuzner

This bootloader operates by checking for an external pin being held high. If
the pin is high, the main bootlaoder method is run. Alternately, the user
program can also directly call the main bootloader method.

The main bootloader method is assigned to live at 0x410, right after the
flash config. The reset handler follows immediately.

Upon reset, the handler invokes startup after disabling the WDT (maybe we
should just leave it on) and setting up the IVT. The startup code does the
appropriate .bss and .data clear/copy and then calls main.

In main, the GPIOs are initialized and the processor checks to see if the
specified GPIO reads high. If it does not, it sets the IVT to point to the
user main startup point (right after the 4K boundary) and jumps to the address
pointed to by the next value (the reset handler in the user program). We may
just simply initiate a reset since I think that would work (testing will be
needed).

If the GPIO is high, the bootloader will proceed to initialize the PLL for
USB operation. After initialization, the bootloader will initialize the USB
driver which should make the device show up on the host machine.

