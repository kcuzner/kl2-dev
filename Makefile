# Makefile for the STM32F103C8 blink program
#
# Kevin Cuzner
#

# Flashing
OCDFLAGS = -f openocd.cfg

# Tools
OCD = openocd
install:
	$(OCD) $(OCDFLAGS)
