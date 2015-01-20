/**
 * kl2-dev.ld
 * Generic Linker File for MKL26Z32VFM4-based projects
 *
 * Kevin Cuzner
 */

OUTPUT_FORMAT("elf32-littlearm", "elf32-littlearm", "elf32-littlearm")
OUTPUT_ARCH(arm)
ENTRY(_startup)

/**
 * KL26 Sub-Family Reference Manual Section 3.6.3.2 & Fig. 3-20
 *
 * SRAM is split into two regions, L and U with 1/4 allocated to L and 3/4
 * allocated to U. The origin for SRAM is calculated as 0x20000000-SIZE/4.
 */
MEMORY
{
    sram (W!RX) : ORIGIN = 0x1ffffc00, LENGTH = 4K
    flash (RX)  : ORIGIN = 0x00000000, LENGTH = 32K
}

/**
 * Define the top of the stack as the end of the SRAM
 * We read in another file that the stdio functions can use 8KB of stack...we
 * don't even have that much RAM, so I think we may need to get by without them.
 */
TOTAL_RESERVED_STACK = 512; /* On a system with 64K ram, we saw 8K used */
_top_stack = (0x1ffffc00+4K);

/**
 * Define heap space
 */
TOTAL_RESERVED_HEAP = 0;

EXTERN(__interrupt_vector_table);
EXTERN(__flash_config);

/**
 * Prevent the bootloader from accessing the sections that it lives on top of
 */

NOCROSSREFS(.bootloader .data);
NOCROSSREFS(.bootloader .bss);

SECTIONS
{
    .text :
    {
        CREATE_OBJECT_SYMBOLS
        /* Insert the interrupt vector table first */
        __interrupt_vector_table = .;
        *(.interrupt_vector_table)

        /* The flash configuration section must be located at a specific point */
        . = 0x0400;
        __flash_config = .;
        *(.flash_config)

        /* Startup assembly */
        *(.startup)

        /* Rest of the code (C) */
        *(.text)
        *(.text.*)
        *(.glue_7)
        *(.glue_7t)

        /*  Added following section for holding initializers for variables
         *  that will be accessed from RAM; see also the AT(_end_data_flash)
         *  usage below.
         *
         *  The _data_size value will be used in the startup code to step through
         *  the image of data in flash and copy it to RAM.
         */

        . = ALIGN(4);
        *(.rodata)
        *(.rodata*)
        *(.init)					/* added */
        *(.fini)					/* added */
        . = ALIGN(4);
        _end_data_flash = .;
        _end_flash = .;
    } >flash

    /**
     * SRAM Sections
     */

    /**
     * In order to have the bootloader work properly, we need to start in the
     * ram rather than packing things using >sram
     */
    . = ORIGIN(sram);

    /**
     * The bootloader and general ram live in the same area of memory
     * NOTE: The bootloader gets its own special RAM space and it lives on top
     * of both .data and .bss.
     */

    _shared_start = .;
    .bootloader _shared_start : AT(_end_flash)
    {
        /* We keep the bootloader and its data together */
        _start_bootloader_flash = LOADADDR(.bootloader);
        _start_bootloader = .;
        *(.bootloader.data)
        *(.bootloader.data.*)
        . = ALIGN(1024); /* Interrupt vector tables must be aligned to a 1024-byte boundary */
        *(.bootloader.interrupt_vector_table)
        *(.bootloader)
        _end_bootloader = .;
    }

    .data _shared_start : AT(_end_flash + SIZEOF(.bootloader))
    {
        _start_data_flash = LOADADDR(.data);
        _start_data = .;
        *(.data)
        *(.data.*)
        *(.shdata)
        _end_data = .;
    }
    . = _shared_start + SIZEOF (.data);
    _bootloader_size = _end_bootloader - _start_bootloader;
    _data_size = _end_data - _start_data;

    /**
     * Zero intialization section
     */

    .noinit ALIGN(4) :
    {
        *(.noinit)
        *(.noinit.*)
    }

    _start_bss = .;
    .bss ALIGN(4) :
    {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    }
    PROVIDE(_end_bss = .);				/* make value of _end_bss available externally */

    bss_size = _end_bss - _start_bss;

    /**
     * The following section lives after bootstrap, data, and bss so that it can
     * be shared between both the bootloader and the user program
     */

    . = MAX(., _shared_start + MAX(SIZEOF(.data), SIZEOF(.bootloader)));

    /*  From generic.ld, supplied by CodeSourcery  */
    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    }
    PROVIDE_HIDDEN (__exidx_end = .);

    /**
     * END OF DATA, BEGINNING OF MAX STACK
     */

    /* Stack can grow down to here, right after data and bss sections in
     * SRAM */
    _start_stack = _top_stack - TOTAL_RESERVED_STACK;
    _top_stack = _top_stack;			/* just to make the map file easier to read */

    /* Linker wants .eh_frame section defined because of gcc 4.4.X bug,
    * just discard it here. */
    /DISCARD/ :
    {
        *(.eh_*)
    }
}
