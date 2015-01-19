#
# KL2x ARM Development Board Makefile
# Kevin Cuzner
#

PROJECT = kl2-dev

# Structure
BINDIR = bin
INCDIR = include
OBJDIR = obj
SRCDIR = src

# Target CPU
CPU = cortex-m0plus

# Sources
SRC = $(wildcard $(SRCDIR)/*.c)
ASM = $(wildcard $(SRCDIR)/*.S)

# Includes
INCLUDE = -I$(INCDIR)

# Linker Script
LSCRIPT = kl2-dev.ld

# C Flags
GCFLAGS  = -Wall -fno-common -mthumb -mcpu=$(CPU)
GCFLAGS += $(INCLUDE)
LDFLAGS += -nostartfiles -T$(LSCRIPT) -mthumb -mcpu=$(CPU)
ASFLAGS += -mcpu=$(CPU)

# Tools
CC = arm-none-eabi-gcc
AS = arm-none-eabi-as
AR = arm-none-eabi-ar
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size
OBJDUMP = arm-none-eabi-objdump

RM = rm -rf

## Build process

OBJ := $(addprefix $(OBJDIR)/,$(notdir $(SRC:.c=.o)))
OBJ += $(addprefix $(OBJDIR)/,$(notdir $(ASM:.s=.o)))

all:: $(BINDIR)/$(PROJECT).hex

Build: $(BINDIR)/$(PROJECT).hex

depend: .depend

.depend: $(SRC)
	@$(RM) ./.depend
	$(CC) $(GCFLAGS) -MM $^ -MF  ./.depend

include .depend

$(BINDIR)/$(PROJECT).hex: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -R .stack -O ihex $(BINDIR)/$(PROJECT).elf $(BINDIR)/$(PROJECT).hex

$(BINDIR)/$(PROJECT).elf: $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) $(OBJ) $(LDFLAGS) -o $(BINDIR)/$(PROJECT).elf


cleanBuild: clean

clean:
	$(RM) ./.depend
	$(RM) $(BINDIR)
	$(RM) $(OBJDIR)

# Compilation
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(GCFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.s
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<
