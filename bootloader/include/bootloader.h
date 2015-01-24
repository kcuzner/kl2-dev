/**
 * KL26 Bootloader
 * Kevin Cuzner
 */

#ifndef _BOOTLOADER_H_
#define _BOOTLOADER_H_

/**
 * Runs the bootloader
 *
 * This function has considerable side-effects. After calling this function, the
 * bootloader will be loaded into RAM and executed. After it finishes execution
 * a processor reset will be performed. This function never returns control to
 * the caller.
 */
void bootloader_run(void);

#endif // _BOOTLOADER_H_
