/**
 * Mid-level startup routine for MKL26Z
 * Kevin Cuzner
 */

#include "arm_cm0p.h"

/*
 * Linker-provided addresses and values for initial loading
 */

extern uint32_t _start_bss, _end_bss, _start_data_flash, _start_data, _data_size;

void startup(void)
{
    uint32_t *src, *dest;
    int32_t size, i;

    // we perform the bss and data clear/load here because it was discovered that
    // implementing it in assembly isn't so portable and it's something that can
    // easily be done in C

    // zero .bss
    dest = &_start_bss;
    for (dest = &_start_bss; dest < &_end_bss; dest++)
        *dest = 0;

    // copy .data
    src = &_start_data_flash;
    dest = &_start_data;
    for (size = (int32_t)(&_data_size); size > 0; size -= 4) //uint32 = preform 4-byte copying
    {
        *dest = *src;
        dest++;
        src++;
    }

    main();
    while(1) {}
}
