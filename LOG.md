# Kinetis KL2 Development Board
### Kevin Cuzner

This log is meant to help me remember the process I had to go through so that
in the future I can optimize it without forgetting any steps.
    
## Parts So Far

MKL26Z32VFM4-ND IC MCU ARM 32KB FLASH 32QFN $2.72
609-4616-1-ND CONN USB MICRO B RECPT SMT R/A $0.46

    
## Monologue

### 10/22/2014

I started out wanting to use the teensy 3.1 in bare metal because I was
interested in getting to truely know the ARM architecture. I found that I didn't
understand it well enough to really get in to it, so I began looking around to
see how ARM development is done. I knew only that JTAG could be used to program
a chip.

I discovered (via edaboard question and lots of google) that the M-series of
arm cores have the SWD (serial wire debug) interface which is better for
flashing an initial bootloader. I then located a bootloader tutorial (see
bookmarks) and it struck me that I could accomplish the goal of programming
a bare-metal arm controller. I would use another microcontroller (perhaps an
AVR operating the V-usb library) as a bridge to the SWD and I would write a
program that would load a hex file and program it to the uC via the USB->SWD
bridge.

I then searched for the cheapest ARM controller I could find that has USB
because I wanted to make a USB bootloader. I located the MKL26Z32VFM4 and was
further encouraged to use it when I saw it was of the Kinetis series (the same
that the teensy uses) and so I feel more comfortable that I could work with it.

The family fact datasheet states that the KL2x series is compatible with the
K20 series of Kinetis MCUs. I have placed all relevant datasheets I could find
in the ref folder so that I don't lose them.

I was distracted with the clock setup because I was thinking about what crystal
to purchase. Upon reset, the device is using an internal reference clock
(referred to as FEI (FLL Engaged Internal) mode). Page 456 gives an example of
moving from FEI to PEE (PLL Engaged External) via the state diagram given in
Fig 24-14. From this exercise I learned that I need to choose an external
crystal sufficient to engage the PLL eventually. It is very different to
initialize this chip compared to AVRs (where the clock source is a burned in
fuse) and must happen every time the chip is brought out of reset. Ch 24 talks
about the clock generator, Ch 25 talks about the oscillator specifics.

The specific pins that the osc is connected on appear to be ones denoted by
EXTAL (external clk/osc input). According to the subfamily datasheet, this is
the pin called PTA18 (pin 17 on 32QFN, configured in default/alt0 as EXTAL0. The
XTAL pin is the output. This is PTA19 (pin 18 on 32QFN), configured in default/
alt0 as XTAL0. The crystal is connected across these two pins, with the
(internal?) loading capacitors and possibly a feedback resistor (Rf). The OSC
says that in high-frequency, low-power mode, this resistor is internal. It also
says the loading capacitors can be configured by the OSC0_CR[SCxP] bits.
Capacitances are configured by adding 2, 4, 8, and 16pF to the oscillator load.
In summary: Crystal goes between PTA18 & PTA19, the crystal capacitance is
configured internally when in low-power mode, and the feedback resistor is also
internal. The crystal frequencies supported in this mode are from 3-32Mhz. Using
the internal capacitors is optional, so perhaps it would be best to include pads
for them.

Upon further reading, it seems I must use the high power mode for using the PLL.
Therefore, I will include pads for both the capacitors and the feedback resistor
even though I don't know what values they need to be yet. I asked a stack
exchange question.

The users guide with general tips and tricks says to place a guard ring anchored
at the nearby VSS pin around the crystal and all of the resistors/caps that are
included. We will do this.

### 01/19/2015

The boards have been ordered and are on their way back from the fab. I started
looking more deeply into the software to determine what exactly needs to be
done and over the past couple days I have discovered:

 * The family reference manual. For the future, I need to remember that there
   is a difference between a "datasheet" and "reference manual". The reference
   manual is the several thousand page document that I really want. The
   datasheet is the per-part summary of the electrical and timing
   characteristics.
 * The chip I have chosen and bought (MKL26Z32VFM4) does not have an EzPort and
   will need to be programmed via JTAG or SWD
 * The McHck is very similar to this and uses a bus pirate for programming. I
   will need to purchase a bus pirate.
 * The bus pirate will be very slow for programming this, so I need to write a
   USB bootloader so that it can reprogram itself.

I also managed to locate a header file (FINALLY!!!) inside of a Freescale
Freedom development kit example. I am keeping it in this repo so I don't lose
it. It has been such a hassle to find the software stuff for this...next time
I do this I am going to choose the part, find the REFERENCE MANUAL, find the
headers, and then continue. This could have turned into a waste of money had I
failed to locate any of those.

### 02/02/2015

In order to connect to the device to program the initial bootloader, I have been
reading copious documentation on how exactly to do this thing. The KL26 only
supports the SWD interface, which is fine. I am creating a rudimentary SWD-USB
bridge and some control software so I can issue commands over USB.

A decent reference for the SWD protocol:
http://markdingst.blogspot.com/2014/03/programming-internal-sram-over-swd.html

A good reference is in the ARM SW-DP documentation as well.

The SWD has two main functions: DP (debug port), and AP (access port). The APnDP
bit in any read/write is used to control which one is being accessed. The AP has
a way to select which exact AP is being used via the SELECT register in the DP.
The KL26 provides two AP's: The AHB-AP at SELECT\[31:24\] = 0x00 and the MDM-AP
at SELECT\[31:24\] = 0x01.

 * The AHB-AP is used to actually access the internal memory of the device and
   the documentation is part of the CoreSight documentation which I have added
   to the repo. This seems to be a standard AP.

 * The MDM-AP is the KL26 way to request things such as debug halts, system
   resets, and other things. The documentation for this module is found in
   section 9.3 of the reference manual. This is a nonstandard AP.

Each AP has a number of banks which provide sets of 4 registers used for
interacting with the AP. The bank currently selected is done by some other
bits in the DP SELECT register.

It looks like my quest for programming the device needs to follow steps that
are something like this:

 1. Build an SWD-USB bridge which can execute any SWD command and talk to the
    device. Alternately, buy a programmer.
 2. Write a USB-based bootloader with associated host software that can
    understand intel hex files and compile it with two linker scripts: one that
    locates the program starting at 0x20000000 (inside RAM) and 0x00000000
    (start of flash). The program should know where it lives and prevent writing
    to that location.
 3. Use the SWD to write the RAM version of the bootloader to the internal
    SRAM, set up the IVT to point to 0x20000000, and execute the program from
    that location (set PC to address pointed to by 0x20000004 and run).
 4. With the device running the RAM bootloader, upload the flash bootloader
    using the bootloader host software
 5. Voila! Initial programming complete.

Yesterday, I started hooking up my USB-SWD bridge (built on the Teensy) to the
device. I had two problems:

 1. The device did not respond. I believe my SWD implementation was transmitting
    the JTAG->SWD transition word backwards. It also might have been doing
    reads wrong. However, I'm not even sure if the SWD transition word is needed
    since the device only supports SWD.
 2. When running the system with RESET_b floating, I observed some interesting
    behavior caputured here: http://i.stack.imgur.com/62qti.png. I initially
    thought it was stuck in some sort of boot loop. I read further (not sure
    where) that the watchdog timer might be causing the device to reset. This
    does match with my observed behavior since it starts un-resetting and then
    suddenly drops into reset again. The watchdog timer is enabled by default
    and on the K20 it needed to be turned off or changed within the first 256
    clock cycles to avoid a reset. I need to measure the width of the un-reset
    pulse to make sure, but that could be my problem. The width of the pulse
    didn't change, but the period of the signal varied between 29Khz and 31Khz,
    making for a very jittery image.

### 12/12/2016

Finally some success!! I have managed to finally program one of the KL26 devices
using openocd and the raspberrypi-native interface. Ideally I would have liked
to get the Teensy functioning as an interface, but this seems to work. I suspect
that any low-level openocd interface could be used to program this thing.

