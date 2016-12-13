/**
 * Main file for the KL2-dev board
 */

#include "arm_cm0p.h"
#include "bootloader.h"

int main(void)
{
    SIM_SCGC5 |= SIM_SCGC5_PORTD_MASK;
    PORTD_PCR7 = PORT_PCR_MUX(1);
    GPIOD_PDDR = 1 << 7;

    while(1) {
        GPIOD_PTOR = 1 << 7;
    }
    return 0;
}
