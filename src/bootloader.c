/**
 * USB Bootloader
 * Kevin Cuzner
 *
 * The code for this section will appear in .bootloader* and .text. Any section
 * attributes should be placed on the declaration of the function, not the
 * definition so that I can easily figure out what is where.
 */

#include "arm_cm0p.h"
#include "usb_types.h"

#define VTOR_REG          0xE000ED08
#define VTOR_SET(ADDR)    *((uint32_t**)VTOR_REG) = ADDR

#define AIRCR_REG       0xE000ED0C
#define AIRCR           *((uint32_t*)AIRCR_REG)
#define AIRCR_VAL(V)    (0x05FA0000 | V)
#define AIRCR_SYSRESETREQ_MASK  0x4

#define USB_N_ENDPOINTS 0
#define ENDP0_SIZE 64

/*
 * Linker-provided values as addresses
 */
extern uint32_t _start_bootloader_flash;
extern uint32_t _start_bootloader;
extern uint32_t _bootloader_size; //NOTE: This points to a location corresponding to the value of _bootloader_size, so the address is the value

/*
 * External crt0 symbols (also from bootstrap_crt0)
 */
extern uint32_t __interrupt_vector_table;
extern uint32_t __bootloader_interrupt_vector_table;

/**
 * Main method for the bootloader
 */
static void __attribute__ ((section(".bootloader"))) bootloader_main(void);

/**
 * Transmits data via endpoint 0
 */
static void __attribute__ ((section(".bootloader"))) bootloader_usb_endp0_transmit(const void* data, uint8_t length);

/**
 * Initializes the USB driver
 */
static void __attribute__ ((section(".bootloader"))) bootloader_usb_init(void);

/**
 * Handles USB endpoint 0 tokens
 */
static void __attribute__ ((section(".bootloader"))) bootloader_usb_endp0_handler(uint8_t stat);


/**
 * Bootloader USB IRQ Handler
 */
void __attribute__ ((section(".bootloader"))) bootloader_USB_IRQHandler(void);

/**
 * Endpoint 0 receive buffers
 */
__attribute__ ((section(".bootloader.data")))
static uint8_t endp0_rx[2][ENDP0_SIZE];;

/**
 * Buffer descriptor table for the bootloader
 * This must be aligned to a 512 byte boundary
 */
__attribute__ ((section(".bootloader.data"), aligned(512), used))
static bdt_t bdt_table[(USB_N_ENDPOINTS + 1) * 4];

void bootloader_run(void)
{
    //Start by copying the bootloader and its data into RAM
    //NOTE: This possibly destroys all .data and .bss
    uint32_t* src = &_start_bootloader_flash;
    uint32_t* dest = &_start_bootloader;
    uint32_t len = (uint32_t)(&_bootloader_size);

    while (len)
    {
        *dest = *src;
        len--;
    }

    //Deactivate all interrupts
    NVIC_ICER = NVIC_ICER_CLRENA_MASK;

    //Set the interrupt vector table accordingly for the bootloader
    VTOR_SET(&__bootloader_interrupt_vector_table);

    //Run the bootloader
    bootloader_main();

    //RAM is now dirty, but the stack should be ok
    //TODO: This should really be done in assembly to avoid dirty RAM bugs

    //When the bootloader is finished, reset the interrupt vector table
    VTOR_SET(&__interrupt_vector_table);

    //Initiate a soft reset
    AIRCR = AIRCR_VAL(AIRCR_SYSRESETREQ_MASK);

    //Loop forever until the reset
    while(1) { }
}

void bootloader_Reset_Handler(void) __attribute__((alias("bootloader_main")));
static void bootloader_main(void)
{
    //initialize the USB module
    bootloader_usb_init();
}

__attribute__ ((section(".bootloader.data")))
static uint8_t endp0_odd, endp0_data = 0;
static void bootloader_usb_endp0_transmit(const void* data, uint8_t length)
{
    bdt_table[BDT_INDEX(0, TX, endp0_odd)].addr = (void *)data;
    bdt_table[BDT_INDEX(0, TX, endp0_odd)].desc = BDT_DESC(length, endp0_data);
    //toggle the odd and data bits
    endp0_odd ^= 1;
    endp0_data ^= 1;
}

static void bootloader_usb_init(void)
{
    uint32_t i;

    //reset the buffer descriptors
    for (i = 0; i < (USB_N_ENDPOINTS + 1) * 4; i++)
    {
        bdt_table[i].desc = 0;
        bdt_table[i].addr = 0;
    }

    //1: Select clock source
    SIM_SOPT2 |= SIM_SOPT2_USBSRC_MASK | SIM_SOPT2_PLLFLLSEL_MASK; //we use MCGPLLCLK (fixed divide by 2)

    //2: Gate USB clock
    SIM_SCGC4 |= SIM_SCGC4_USBOTG_MASK;

    //3: Software USB module reset
    USB0_USBTRC0 |= USB_USBTRC0_USBRESET_MASK;
    while (USB0_USBTRC0 & USB_USBTRC0_USBRESET_MASK);

    //4: Set BDT base registers
    USB0_BDTPAGE1 = ((uint32_t)bdt_table) >> 8;  //bits 15-9
    USB0_BDTPAGE2 = ((uint32_t)bdt_table) >> 16; //bits 23-16
    USB0_BDTPAGE3 = ((uint32_t)bdt_table) >> 24; //bits 31-24

    //5: Clear all ISR flags and enable weak pull downs
    USB0_ISTAT = 0xFF;
    USB0_ERRSTAT = 0xFF;
    USB0_OTGISTAT = 0xFF;
    USB0_USBTRC0 |= 0x40; //a hint was given that this is an undocumented interrupt bit

    //6: Enable USB reset interrupt
    USB0_CTL = USB_CTL_USBENSOFEN_MASK;
    USB0_USBCTRL = 0;

    USB0_INTEN |= USB_INTEN_USBRSTEN_MASK;
    //NVIC_SET_PRIORITY(IRQ(INT_USB0), 112);
    NVIC_ENABLE_IRQ(IRQ(INT_USB0));

    //7: Enable pull-up resistor on D+ (Full speed, 12Mbit/s)
    USB0_CONTROL = USB_CONTROL_DPPULLUPNONOTG_MASK;
}

static void bootloader_usb_endp0_handler(uint8_t stat)
{

}

void bootloader_USB_IRQHandler(void)
{
    uint8_t status;
    uint8_t stat, endpoint;

    status = USB0_ISTAT;

    if (status & USB_ISTAT_USBRST_MASK)
    {
        //handle USB reset

        //initialize endpoint 0 ping-pong buffers
        USB0_CTL |= USB_CTL_ODDRST_MASK;
        endp0_odd = 0;
        bdt_table[BDT_INDEX(0, RX, EVEN)].desc = BDT_DESC(ENDP0_SIZE, 0);
        bdt_table[BDT_INDEX(0, RX, EVEN)].addr = endp0_rx[0];
        bdt_table[BDT_INDEX(0, RX, ODD)].desc = BDT_DESC(ENDP0_SIZE, 0);
        bdt_table[BDT_INDEX(0, RX, ODD)].addr = endp0_rx[1];
        bdt_table[BDT_INDEX(0, TX, EVEN)].desc = 0;
        bdt_table[BDT_INDEX(0, TX, ODD)].desc = 0;

        //initialize endpoint0 to 0x0d (41.5.23)
        //transmit, recieve, and handshake
        USB0_ENDPT0 = USB_ENDPT_EPRXEN_MASK | USB_ENDPT_EPTXEN_MASK | USB_ENDPT_EPHSHK_MASK;

        //clear all interrupts...this is a reset
        USB0_ERRSTAT = 0xff;
        USB0_ISTAT = 0xff;

        //after reset, we are address 0, per USB spec
        USB0_ADDR = 0;

        //all necessary interrupts are now active
        USB0_ERREN = 0xFF;
        USB0_INTEN = USB_INTEN_USBRSTEN_MASK | USB_INTEN_ERROREN_MASK |
            USB_INTEN_SOFTOKEN_MASK | USB_INTEN_TOKDNEEN_MASK |
            USB_INTEN_SLEEPEN_MASK | USB_INTEN_STALLEN_MASK;

        return;
    }
    if (status & USB_ISTAT_ERROR_MASK)
    {
        //handle error
        USB0_ERRSTAT = USB0_ERRSTAT;
        USB0_ISTAT = USB_ISTAT_ERROR_MASK;
    }
    if (status & USB_ISTAT_SOFTOK_MASK)
    {
        //handle start of frame token
        USB0_ISTAT = USB_ISTAT_SOFTOK_MASK;
    }
    if (status & USB_ISTAT_TOKDNE_MASK)
    {
        //handle completion of current token being processed
        stat = USB0_STAT;
        endpoint = stat >> 4;
        switch (endpoint & 0xf)
        {
        case 0:
            bootloader_usb_endp0_handler(stat);
            break;
        default:
            break;
        }

        USB0_ISTAT = USB_ISTAT_TOKDNE_MASK;
    }
    if (status & USB_ISTAT_SLEEP_MASK)
    {
        //handle USB sleep
        USB0_ISTAT = USB_ISTAT_SLEEP_MASK;
    }
    if (status & USB_ISTAT_STALL_MASK)
    {
        //handle usb stall
        USB0_ISTAT = USB_ISTAT_STALL_MASK;
    }
}
