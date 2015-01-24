/**
 * ARM Cortex-M0+ Common Code
 * Kevin Cuzner
 *
 * Basically anything that deals with talking to the processor and not computing
 * things on it should end up here one way or another
 */

#ifndef _ARM_CM0P_H_
#define _ARM_CM0P_H_

#include "common.h"
#include "MKL26Z4.h"

/*
 * The basic data types
 */
typedef unsigned char		uint8;  /*  8 bits */
typedef unsigned short int	uint16; /* 16 bits */
typedef unsigned long int	uint32; /* 32 bits */

typedef char			int8;   /*  8 bits */
typedef short int	        int16;  /* 16 bits */
typedef int		        int32;  /* 32 bits */

typedef volatile int8		vint8;  /*  8 bits */
typedef volatile int16		vint16; /* 16 bits */
typedef volatile int32		vint32; /* 32 bits */

typedef volatile uint8		vuint8;  /*  8 bits */
typedef volatile uint16		vuint16; /* 16 bits */
typedef volatile uint32		vuint32; /* 32 bits */

/*
 * Common defines
 */
#define NULL 0
#define FALSE 0
#define TRUE 1

/**
 * Clock setup
 */
#define CLK0_FREQ_HZ 4000000
#define LOW_POWER 1
#define CLK0_TYPE 0
#define PLL0_PRDIV 1
#define PLL0_VDIV 1
#define MCGOUT 0
#define OUTDIV1_VAL 0
#define OUTDIV4_VAL 0


/*
 * NVIC Macros
 */
#define EnableInterrupts()      asm(" CPSIE i")
#define DisableInterrupts()     asm(" CPSID i")
#define IRQ(N)                  (N - 16)
#define NVIC_ENABLE_IRQ(n)      NVIC_ISER = NVIC_ISER_SETENA(n)
#define NVIC_DISABLE_IRQ(n)     NVIC_ICER = NVIC_ICER_CLRENA(n)
#define NVIC_SET_PENDING(n)     NVIC_ISPR = NVIC_ISPR_SETPEND(n)
#define NVIC_CLEAR_PENDING(n)   NVIC_ICPR = NVIC_ICPR_CLRPEND(n)
void nvic_set_priority(uint8_t irq, uint8_t priority);

#endif // _ARM_CM0P_H_
