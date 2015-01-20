/**
 * USB Bootloader
 * Kevin Cuzner
 */

#include "arm_cm0p.h"

#define VTOR_REG          0xE000ED08
#define VTOR_SET(ADDR)    *((uint32_t**)VTOR_REG) = ADDR

#define AIRCR_REG       0xE000ED0C
#define AIRCR           *((uint32_t*)AIRCR_REG)
#define AIRCR_VAL(V)    (0x05FA0000 | V)
#define AIRCR_SYSRESETREQ_MASK  0x4

/*
 * Linker-provided values as addresses
 */
extern uint32_t _start_bootloader_flash;
extern uint32_t _start_bootloader;
extern uint32_t _bootloader_size; //NOTE: This points to a location corresponding to the value of _bootloader_size, so the address is the value

/*
 * External crt0 symbols (also from bootstrap_crt0)
 */
extern uint32_t __interrupt_vector_table;
extern uint32_t __bootloader_interrupt_vector_table;

static void bootloader_main(void);

void bootloader_run(void)
{
    //Start by copying the bootloader and its data into RAM
    //NOTE: This possibly destroys all .data and .bss
    uint32_t* src = &_start_bootloader_flash;
    uint32_t* dest = &_start_bootloader;
    uint32_t len = (uint32_t)(&_bootloader_size);

    while (len)
    {
        *src = *dest;
        len--;
    }

    //Set the interrupt vector table accordingly
    VTOR_SET(&__bootloader_interrupt_vector_table);

    //Run the bootloader
    bootloader_main();

    //RAM is now dirty, but the stack should be ok
    //TODO: This should really be done in assembly to avoid dirty RAM bugs

    //When the bootloader is finished, reset the interrupt vector table
    VTOR_SET(&__interrupt_vector_table);

    //Initiate a soft reset
    AIRCR = AIRCR_VAL(AIRCR_SYSRESETREQ_MASK);

    //Loop forever until the reset
    while(1) { }
}

int __attribute__((section(".bootloader.data"))) bootloaderData = 4;

void bootloader_Reset_Handler(void) __attribute__((alias("bootloader_main")));
static void __attribute__ ((section(".bootloader"))) bootloader_main(void)
{
}
