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



