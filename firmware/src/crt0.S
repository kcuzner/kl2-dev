/**
 * Low level initialization routines
 * Based on Freedom Board initialization, combined with the K20 initialization
 */

    .syntax unified
    .thumb

/**
 * Create the interrupt vector table
 * I prefer how the K20 code does it rather than the KL26 example
 */
    .section ".interrupt_vector_table"
	.global __interrupt_vector_table

__interrupt_vector_table:
    .long   _top_stack          /* marks the top of stack */
    .long   Reset_Handler       /* initial program counter */
    .long   NMI_Handler
    .long   HardFault_Handler
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   SVC_Handler
    .long   0
    .long   0
    .long   PendSV_Handler
    .long   SysTick_Handler

    /* MKL26 Vector Declarations */

    .long   DMA0_IRQHandler     /* 16: DMA channel 0 transfer complete and error */
    .long   DMA1_IRQHandler     /* 17: DMA channel 1 transfer complete and error */
    .long   DMA2_IRQHandler     /* 18: DMA channel 2 transfer complete and error */
    .long   DMA3_IRQHandler     /* 19: DMA channel 3 transfer complete and error */
    .long   0
    .long   FTFA_IRQHandler     /* 21: FTFA Command complete and read collision */
    .long   PMC_IRQHandler      /* 22: PMC Low-voltage detect, low-voltage warning */
    .long   LLWU_IRQHandler     /* 23: Low Leakage Wakeup */
    .long   I2C0_IRQHandler     /* 24: I2C0 */
    .long   I2C1_IRQHandler     /* 25: I2C1 */
    .long   SPI0_IRQHandler     /* 26: SPI0 Single interrupt vector for all sources */
    .long   SPI1_IRQHandler     /* 27: SPI1 Single interrupt vector for all sources */
    .long   UART0_IRQHandler    /* 28: UART0 Status and error */
    .long   UART1_IRQHandler    /* 29: UART1 Status and error */
    .long   UART2_IRQHandler    /* 30: UART2 Status and error */
    .long   ADC0_IRQHandler     /* 31: ADC0 */
    .long   CMP0_IRQHandler     /* 32: CMP0 */
    .long   TPM0_IRQHandler     /* 33: TPM0 */
    .long   TPM1_IRQHandler     /* 34: TPM1 */
    .long   TPM2_IRQHandler     /* 35: TPM2 */
    .long   RTC_IRQHandler      /* 36: RTC Alarm interrupt */
    .long   RTCSeconds_IRQHandler /* 37: RTC Seconds interrupt */
    .long   PIT_IRQHandler      /* 38: PIT Single interrupt vector for all channels */
    .long   I2S0_IRQHandler     /* 39: I2S0 Single interrupt vector for all sources */
    .long   USB_IRQHandler      /* 40: USB OTG */
    .long   DAC0_IRQHandler     /* 41: DAC0 */
    .long   TSI0_IRQHandler     /* 42: TSI0 */
    .long   MCG_IRQHandler      /* 43: MCG */
    .long   LPTMR0_IRQHandler   /* 44: LPTimer */
    .long   0
    .long   PORTA_IRQHandler    /* 46: Pin detect (Port A) */
    .long   PORTD_IRQHandler    /* 47: Pin detect (Single interrupt vector for Port C and Port D) */


/* Flash Configuration */
    .section ".flash_config"
    .global __flash_config

    .long 0xFFFFFFFF
    .long 0xFFFFFFFF
    .long 0xFFFFFFFF
    .long 0xFFFFFFFE

/* Weak declarations */

    .thumb

    .weak	NMI_Handler
    .weak	HardFault_Handler
    .weak	SVC_Handler
    .weak	PendSV_Handler
    .weak	SysTick_Handler

    .weak   DMA0_IRQHandler
    .weak   DMA1_IRQHandler
    .weak   DMA2_IRQHandler
    .weak   DMA3_IRQHandler
    .weak   FTFA_IRQHandler
    .weak   PMC_IRQHandler
    .weak   LLWU_IRQHandler
    .weak   I2C0_IRQHandler
    .weak   I2C1_IRQHandler
    .weak   SPI0_IRQHandler
    .weak   SPI1_IRQHandler
    .weak   UART0_IRQHandler
    .weak   UART1_IRQHandler
    .weak   UART2_IRQHandler
    .weak   ADC0_IRQHandler
    .weak   CMP0_IRQHandler
    .weak   TPM0_IRQHandler
    .weak   TPM1_IRQHandler
    .weak   TPM2_IRQHandler
    .weak   RTC_IRQHandler
    .weak   RTCSeconds_IRQHandler
    .weak   PIT_IRQHandler
    .weak   I2S0_IRQHandler
    .weak   USB_IRQHandler
    .weak   DAC0_IRQHandler
    .weak   TSI0_IRQHandler
    .weak   MCG_IRQHandler
    .weak   LPTMR0_IRQHandler
    .weak   PORTA_IRQHandler
    .weak   PORTD_IRQHandler

/**
 * Startup code
 */

    .section ".startup","x",%progbits
    .thumb_func
    .global _startup

Reset_Handler:
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
     * Configure vector table offset register
     * NOTE: I'm not sure if this is actually implemented
     */
    ldr r0,=0xE000ED08
    ldr r1,=__interrupt_vector_table
    str r1, [r0]

    /**
     * Hand off code to C initialization stuff which does copying and zeroing
     */
    ldr r0,=startup
    blx r0
    /* If we come back, loop forever */
    b   .


/*
 *  Stub routines for the main vectors.
 */
NMI_Handler:
    b	.

HardFault_Handler:
    b	.

SVC_Handler:
    b	.

PendSV_Handler:
    b	.

SysTick_Handler:
    b	.

/**
 * Default IRQ Handler stubs
 */
DMA0_IRQHandler:
DMA1_IRQHandler:
DMA2_IRQHandler:
DMA3_IRQHandler:
FTFA_IRQHandler:
PMC_IRQHandler:
LLWU_IRQHandler:
I2C0_IRQHandler:
I2C1_IRQHandler:
SPI0_IRQHandler:
SPI1_IRQHandler:
UART0_IRQHandler:
UART1_IRQHandler:
UART2_IRQHandler:
ADC0_IRQHandler:
CMP0_IRQHandler:
TPM0_IRQHandler:
TPM1_IRQHandler:
TPM2_IRQHandler:
RTC_IRQHandler:
RTCSeconds_IRQHandler:
PIT_IRQHandler:
I2S0_IRQHandler:
USB_IRQHandler:
DAC0_IRQHandler:
TSI0_IRQHandler:
MCG_IRQHandler:
LPTMR0_IRQHandler:
PORTA_IRQHandler:
PORTD_IRQHandler:
    b   .
