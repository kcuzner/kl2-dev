/**
 * USB Bootloader
 * Kevin Cuzner
 *
 * The code for this section will appear in .bootloader* and .text. Any section
 * attributes should be placed on the declaration of the function, not the
 * definition so that I can easily figure out what is where.
 * The one exception is bootloader_run which needs to live in .bootstrap so that
 * it can act as a bridge between .text and .bootloader
 */

#include "arm_cm0p.h"
#include "usb_types.h"

#define VTOR_REG          0xE000ED08
#define VTOR_SET(ADDR)    *((uint32_t**)VTOR_REG) = ADDR

#define AIRCR_REG       0xE000ED0C
#define AIRCR           *((uint32_t*)AIRCR_REG)
#define AIRCR_VAL(V)    (0x05FA0000 | V)
#define AIRCR_SYSRESETREQ_MASK  0x4

/**
 * Main method for the bootloader
 */
static void bootloader_main(void);

static void bootloader_main(void)
{
}

