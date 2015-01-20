/**
 * USB Bootloader
 * Kevin Cuzner
 */

int j = 4;

static void bootloader_run(void);
static void bootloader_test(void);

void bootloader_init(void)
{
    bootloader_run();
}

int __attribute__((section(".bootloader.data"))) bootloaderData = 4;

static void __attribute__ ((section(".bootloader"))) bootloader_run(void)
{
    bootloader_test();
    bootloader_test();
}

static void __attribute__ ((section(".bootloader"))) bootloader_test(void)
{
    j++;
}
