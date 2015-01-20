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
OBJ += $(addprefix $(OBJDIR)/,$(notdir $(ASM:.S=.o)))

all:: $(BINDIR)/$(PROJECT).hex

Build: $(BINDIR)/$(PROJECT).hex

list: $(BINDIR)/$(PROJECT).elf
	$(OBJDUMP) -D $(BINDIR)/$(PROJECT).elf > $(BINDIR)/$(PROJECT).lst

size: $(BINDIR)/$(PROJECT).elf
	$(SIZE) $(BINDIR)/$(PROJECT).elf

$(BINDIR)/$(PROJECT).hex: $(BINDIR)/$(PROJECT).elf
	$(OBJCOPY) -R .stack -O ihex $(BINDIR)/$(PROJECT).elf $(BINDIR)/$(PROJECT).hex

$(BINDIR)/$(PROJECT).elf: $(LSCRIPT) $(OBJ)
	@mkdir -p $(dir $@)
	$(CC) $(OBJ) $(LDFLAGS) -o $(BINDIR)/$(PROJECT).elf


cleanBuild: clean

clean:
	$(RM) $(BINDIR)
	$(RM) $(OBJDIR)

# Compilation
$(OBJDIR)/%.o: $(SRCDIR)/%.c
	@mkdir -p $(dir $@)
	$(CC) $(GCFLAGS) -c $< -o $@

$(OBJDIR)/%.o: $(SRCDIR)/%.S
	@mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<
