/**
 * Low level initialization routines
 * Based on Freedom Board initialization, combined with the K20 initialization
 */

    .syntax unified
    .thumb

    .section ".startup","x",%progbits
    .thumb_func
    .global _startup

_startup:
    /* Initialize GPRs */
    ldr r0,=0
    ldr r1,=0
    ldr r2,=0
    ldr r3,=0
    ldr r4,=0
    ldr r5,=0
    ldr r6,=0
    ldr r7,=0

    /**
     * Disable watchdog timer
     * According to Sections 3.4.10.2 and 12.2.18, the COP (watchdog) is enabled
     * by default upon startup operating from an internal 1Khz clock reference
     * with a timeout of 2^10 cycles. The COP control register (SIM_COPC) can
     * only be written once after reset. It would appear that once the watchdog
     * is disabled, it cannot be re-enabled.
     */
    ldr r0,=0x40048100
    ldr r1,=0
    str r1, [r0]

    /**
     * Clear BSS
     */
    ldr r0,=0
    ldr r1, = _start_bss
    ldr r2, = _end_bss
    cmp	r1, r2
    beq	_done_clear

    subs r2, #1
_clear:
    cmp r1, r2
    str r0, [r1, #0]
    adds r1, #4
    blo _clear
_done_clear:

    /**
     *  Copy data from flash initialization area to RAM
     *
     *  The three values seen here are supplied by the linker script
     */
    ldr   r0, =_start_data_flash	/* initial values, found in flash */
    ldr   r1, =_start_data			/* target locations in RAM to write */
    ldr   r2, =_data_size			/* number of bytes to write */

    /*
     *  Perform the copy.
     *  Handle the special case where _data_size == 0
     */
    cmp   r2, #0
    beq   done_copy
copy:
    ldrb   r4, [r0]
    adds   r0, r0, #1
    strb   r4, [r1]
    adds   r1, r1, #1
    subs   r2, r2, #1
    bne    copy
done_copy:

    /**
     * Configure vector table offset register
     * NOTE: I'm not sure if this is actually implemented
     */
    ldr r0,=0xE000ED08
    ldr r1,=__interrupt_vector_table
    str r1, [r0]

    /**
     * Hand off code to C initialization stuff
     */
    ldr r0,=startup
    blx r0
    /* If we come back, loop forever */
    b   .
