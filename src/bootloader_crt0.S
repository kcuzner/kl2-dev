/**
 * Low level initialization routines for the bootloader
 * Based on Freedom Board initialization, combined with the K20 initialization
 */

    .syntax unified
    .thumb

/**
 * Interrupt vector table for the bootloader code
 */
    .section ".bootloader.interrupt_vector_table"
	.global __bootloader_interrupt_vector_table

__bootloader_interrupt_vector_table:
    .long   _top_stack          /* marks the top of stack */
    .long   bootloader_Reset_Handler       /* initial program counter */
    .long   bootloader_NMI_Handler
    .long   bootloader_HardFault_Handler
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   0
    .long   bootloader_SVC_Handler
    .long   0
    .long   0
    .long   bootloader_PendSV_Handler
    .long   bootloader_SysTick_Handler

    /* MKL26 Vector Declarations */

    .long   bootloader_DMA0_IRQHandler     /* 16: DMA channel 0 transfer complete and error */
    .long   bootloader_DMA1_IRQHandler     /* 17: DMA channel 1 transfer complete and error */
    .long   bootloader_DMA2_IRQHandler     /* 18: DMA channel 2 transfer complete and error */
    .long   bootloader_DMA3_IRQHandler     /* 19: DMA channel 3 transfer complete and error */
    .long   0
    .long   bootloader_FTFA_IRQHandler     /* 21: FTFA Command complete and read collision */
    .long   bootloader_PMC_IRQHandler      /* 22: PMC Low-voltage detect, low-voltage warning */
    .long   bootloader_LLWU_IRQHandler     /* 23: Low Leakage Wakeup */
    .long   bootloader_I2C0_IRQHandler     /* 24: I2C0 */
    .long   bootloader_I2C1_IRQHandler     /* 25: I2C1 */
    .long   bootloader_SPI0_IRQHandler     /* 26: SPI0 Single interrupt vector for all sources */
    .long   bootloader_SPI1_IRQHandler     /* 27: SPI1 Single interrupt vector for all sources */
    .long   bootloader_UART0_IRQHandler    /* 28: UART0 Status and error */
    .long   bootloader_UART1_IRQHandler    /* 29: UART1 Status and error */
    .long   bootloader_UART2_IRQHandler    /* 30: UART2 Status and error */
    .long   bootloader_ADC0_IRQHandler     /* 31: ADC0 */
    .long   bootloader_CMP0_IRQHandler     /* 32: CMP0 */
    .long   bootloader_TPM0_IRQHandler     /* 33: TPM0 */
    .long   bootloader_TPM1_IRQHandler     /* 34: TPM1 */
    .long   bootloader_TPM2_IRQHandler     /* 35: TPM2 */
    .long   bootloader_RTC_IRQHandler      /* 36: RTC Alarm interrupt */
    .long   bootloader_RTCSeconds_IRQHandler /* 37: RTC Seconds interrupt */
    .long   bootloader_PIT_IRQHandler      /* 38: PIT Single interrupt vector for all channels */
    .long   bootloader_I2S0_IRQHandler     /* 39: I2S0 Single interrupt vector for all sources */
    .long   bootloader_USB_IRQHandler      /* 40: USB OTG */
    .long   bootloader_DAC0_IRQHandler     /* 41: DAC0 */
    .long   bootloader_TSI0_IRQHandler     /* 42: TSI0 */
    .long   bootloader_MCG_IRQHandler      /* 43: MCG */
    .long   bootloader_LPTMR0_IRQHandler   /* 44: LPTimer */
    .long   0
    .long   bootloader_PORTA_IRQHandler    /* 46: Pin detect (Port A) */
    .long   bootloader_PORTD_IRQHandler    /* 47: Pin detect (Single interrupt vector for Port C and Port D) */

/* Weak declarations */

    .thumb

    .weak	bootloader_NMI_Handler
    .weak	bootloader_HardFault_Handler
    .weak	bootloader_SVC_Handler
    .weak	bootloader_PendSV_Handler
    .weak	bootloader_SysTick_Handler

    .weak   bootloader_DMA0_IRQHandler
    .weak   bootloader_DMA1_IRQHandler
    .weak   bootloader_DMA2_IRQHandler
    .weak   bootloader_DMA3_IRQHandler
    .weak   bootloader_FTFA_IRQHandler
    .weak   bootloader_PMC_IRQHandler
    .weak   bootloader_LLWU_IRQHandler
    .weak   bootloader_I2C0_IRQHandler
    .weak   bootloader_I2C1_IRQHandler
    .weak   bootloader_SPI0_IRQHandler
    .weak   bootloader_SPI1_IRQHandler
    .weak   bootloader_UART0_IRQHandler
    .weak   bootloader_UART1_IRQHandler
    .weak   bootloader_UART2_IRQHandler
    .weak   bootloader_ADC0_IRQHandler
    .weak   bootloader_CMP0_IRQHandler
    .weak   bootloader_TPM0_IRQHandler
    .weak   bootloader_TPM1_IRQHandler
    .weak   bootloader_TPM2_IRQHandler
    .weak   bootloader_RTC_IRQHandler
    .weak   bootloader_RTCSeconds_IRQHandler
    .weak   bootloader_PIT_IRQHandler
    .weak   bootloader_I2S0_IRQHandler
    .weak   bootloader_USB_IRQHandler
    .weak   bootloader_DAC0_IRQHandler
    .weak   bootloader_TSI0_IRQHandler
    .weak   bootloader_MCG_IRQHandler
    .weak   bootloader_LPTMR0_IRQHandler
    .weak   bootloader_PORTA_IRQHandler
    .weak   bootloader_PORTD_IRQHandler

/**
 * The rest of the module lives in the bootloader section
 */

    .section ".bootloader","x",%progbits
    .thumb_func

/*
 *  Stub routines for the main vectors.
 */
bootloader_NMI_Handler:
    b	.

bootloader_HardFault_Handler:
    b	.

bootloader_SVC_Handler:
    b	.

bootloader_PendSV_Handler:
    b	.

bootloader_SysTick_Handler:
    b	.

/**
 * Default IRQ Handler stubs
 */
bootloader_DMA0_IRQHandler:
bootloader_DMA1_IRQHandler:
bootloader_DMA2_IRQHandler:
bootloader_DMA3_IRQHandler:
bootloader_FTFA_IRQHandler:
bootloader_PMC_IRQHandler:
bootloader_LLWU_IRQHandler:
bootloader_I2C0_IRQHandler:
bootloader_I2C1_IRQHandler:
bootloader_SPI0_IRQHandler:
bootloader_SPI1_IRQHandler:
bootloader_UART0_IRQHandler:
bootloader_UART1_IRQHandler:
bootloader_UART2_IRQHandler:
bootloader_ADC0_IRQHandler:
bootloader_CMP0_IRQHandler:
bootloader_TPM0_IRQHandler:
bootloader_TPM1_IRQHandler:
bootloader_TPM2_IRQHandler:
bootloader_RTC_IRQHandler:
bootloader_RTCSeconds_IRQHandler:
bootloader_PIT_IRQHandler:
bootloader_I2S0_IRQHandler:
bootloader_USB_IRQHandler:
bootloader_DAC0_IRQHandler:
bootloader_TSI0_IRQHandler:
bootloader_MCG_IRQHandler:
bootloader_LPTMR0_IRQHandler:
bootloader_PORTA_IRQHandler:
bootloader_PORTD_IRQHandler:
    b   .

