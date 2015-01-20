/**
 * ARM Cortex-M0+ Common Code
 * Kevin Cuzner
 *
 * Basically anything that deals with talking to the processor and not computing
 * things on it should end up here one way or another
 */

#include "arm_cm0p.h"

#define IP_NUM(N)   (N >> 2)
#define IP_M(N)     (N & 0x3)

void nvic_set_priority(uint8_t irq, uint8_t priority)
{
    NVIC_IP(IP_NUM(irq)) &= 0xFFFFFF00 << (IP_M(irq) * 8);
    NVIC_IP(IP_NUM(irq)) |= (priority & 0xFF) << (IP_M(irq) * 8);
}
