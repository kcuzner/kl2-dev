/**
 * Main file for the KL2-dev board
 */

#include "arm_cm0p.h"
#include "bootloader.h"

int main(void)
{
    bootloader_run();

    while(1) {}
    return 0;
}
