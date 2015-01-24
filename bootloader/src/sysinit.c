/*
 * File:        sysinit.c
 * Purpose:     Kinetis L Family Configuration
 *              Initializes processor to a default state
 *
 * Notes:
 *
 *
 */

#include "arm_cm0p.h"
#include "sysinit.h"

/********************************************************************/

/* System clock frequency variables - Represents the current system clock
 * settings
 */
int mcg_clk_hz;
int mcg_clk_khz;
int core_clk_khz;
int periph_clk_khz;
int pll_clk_khz;
int uart0_clk_khz;
uint32 uart0_clk_hz;
extern uint32_t SystemCoreClock;



/********************************************************************/
void sysinit (void)
{
        /* Enable all of the port clocks. These have to be enabled to configure
         * pin muxing options, so most code will need all of these on anyway.
         */
        SIM_SCGC5 |= (SIM_SCGC5_PORTA_MASK
                      | SIM_SCGC5_PORTB_MASK
                      | SIM_SCGC5_PORTC_MASK
                      | SIM_SCGC5_PORTD_MASK
                      | SIM_SCGC5_PORTE_MASK );

        // Release hold with ACKISO:  Only has an effect if recovering from VLLS1, VLLS2, or VLLS3
        // if ACKISO is set you must clear ackiso before calling pll_init
        //    or pll init hangs waiting for OSC to initialize
        // if osc enabled in low power modes - enable it first before ack
        // if I/O needs to be maintained without glitches enable outputs and modules first before ack.
        if (PMC_REGSC &  PMC_REGSC_ACKISO_MASK)
        PMC_REGSC |= PMC_REGSC_ACKISO_MASK;

       /* Ramp up the system clock */
       /* Set the system dividers */
       /* NOTE: The PLL init will not configure the system clock dividers,
        * so they must be configured appropriately before calling the PLL
        * init function to ensure that clocks remain in valid ranges.
        */
        SIM_CLKDIV1 = ( 0
                        | SIM_CLKDIV1_OUTDIV1(OUTDIV1_VAL)
                        | SIM_CLKDIV1_OUTDIV4(OUTDIV4_VAL) );

       /* Initialize PLL */
       /* PLL will be the source for MCG CLKOUT so the core, system, and flash clocks are derived from it */
       mcg_clk_hz = pll_set(CLK0_FREQ_HZ,  /* CLKIN0 frequency */
                             LOW_POWER,     /* Set the oscillator for low power mode */
                             CLK0_TYPE,     /* Crystal or canned oscillator clock input */
                             PLL0_PRDIV,    /* PLL predivider value */
                             PLL0_VDIV,     /* PLL multiplier */
                             MCGOUT);       /* Use the output from this PLL as the MCGOUT */


			/* Check the value returned from pll_init() to make sure there wasn't an error */
       if (mcg_clk_hz < 0x100)
         while(1);

       SIM_SOPT2 |= SIM_SOPT2_PLLFLLSEL_MASK; // set PLLFLLSEL to select the PLL for this clock source

       uart0_clk_khz = ((mcg_clk_hz / 2) / 1000); // UART0 clock frequency will equal half the PLL frequency

       SIM_SOPT2 = ((SIM_SOPT2 & ~SIM_SOPT2_UART0SRC_MASK) | SIM_SOPT2_UART0SRC(1));

	/*
         * Use the value obtained from the pll_init function to define variables
	 * for the core clock in kHz and also the peripheral clock. These
	 * variables can be used by other functions that need awareness of the
	 * system frequency.
	 */
    mcg_clk_khz = mcg_clk_hz / 1000;
    core_clk_khz = mcg_clk_khz / (((SIM_CLKDIV1 & SIM_CLKDIV1_OUTDIV1_MASK) >> 28)+ 1);
    periph_clk_khz = core_clk_khz / (((SIM_CLKDIV1 & SIM_CLKDIV1_OUTDIV4_MASK) >> 16)+ 1);
}

uint32_t pll_set(uint32_t crystal_val, uint8_t hgo_val, uint8_t erefs_val, int8_t prdiv_val, int8_t vdiv_val, uint8_t mcgout_select)
{
    //TODO: Implement the MCG state machine
    return 0x1;
}
