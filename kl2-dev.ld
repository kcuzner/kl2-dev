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

SECTIONS
{
    .text :
    {
        CREATE_OBJECT_SYMBOLS
        /* Insert the interrupt vector table first */
        __interrupt_vector_table = .;
        *(.interrupt_vector_table)

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
    } >flash

    /**
     * SRAM Sections
     */

    /**
     * If the vectors are moved into RAM, they must live on a 1024-byte boundary
     */
    .RAMVectorTable :
    {
        *(.RAMVectorTable)
    }
    . = ALIGN(4);

    /*  From generic.ld, supplied by CodeSourcery  */
    /* .ARM.exidx is sorted, so has to go in its own output section.  */
    PROVIDE_HIDDEN (__exidx_start = .);
    .ARM.exidx :
    {
        *(.ARM.exidx* .gnu.linkonce.armexidx.*)
    } >sram
    PROVIDE_HIDDEN (__exidx_end = .);

    .data :
    {
        _start_data_flash = LOADADDR(.data);
        _start_data = .;
        *(.data)
        *(.data.*)
        *(.shdata)
        _end_data = .;
    } >sram  AT>flash
    . = ALIGN(4);
    _data_size = _end_data - _start_data;

    .noinit :
    {
        *(.noinit)
        *(.noinit.*)
    } >sram

    _start_bss = .;
    .bss :
    {
        *(.bss)
        *(.bss.*)
        *(COMMON)
    } >sram
    . = ALIGN(4);
    PROVIDE(_end_bss = .);				/* make value of _end_bss available externally */

    bss_size = _end_bss - _start_bss;

    /* Stack can grow down to here, right after data and bss sections in
     * SRAM */
    _start_stack = _top_stack - TOTAL_RESERVED_STACK;
    _top_stack = _top_stack;			/* just to make the map file easier to read */

    /*
     *  If you want a heap, declare it here.
     */
    /*
    .heap :
    {
        PROVIDE(_startHeap = .);
        *(.heap)
        . += TOTAL_RESERVED_HEAP;
        . = ALIGN(4);
        PROVIDE(_endHeap = .);
    } > ahbsram1
    */



    /* Linker wants .eh_frame section defined because of gcc 4.4.X bug,
    * just discard it here. */
    /DISCARD/ :
    {
        *(.eh_*)
    }
}
