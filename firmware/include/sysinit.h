/*
 * File:        sysinit.h
 * Purpose:     Kinetis L Family Configuration
 *              Initializes clock, abort button, clock output, and UART to a default state
 *
 * Notes:
 *
 */

/********************************************************************/

// function prototypes
void sysinit (void);

uint32_t pll_set(uint32_t crystal_val, uint8_t hgo_val, uint8_t erefs_val, int8_t prdiv_val, int8_t vdiv_val, uint8_t mcgout_select);
/********************************************************************/
