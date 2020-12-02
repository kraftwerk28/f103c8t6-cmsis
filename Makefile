TARGET_CPU = cortex-m3
TARGET_DEVICE = STM32F10X_MD

CC = arm-none-eabi-gcc
OC = arm-none-eabi-objcopy
LD = arm-none-eabi-ld

BUILD_DIR = build
ELF = $(BUILD_DIR)/main.elf
BIN = $(BUILD_DIR)/main.bin
LDSCRIPT = init.ld
LIBPATH = STM32F10x_StdPeriph_Lib_V3.5.0/Libraries
DEBUG := 1

CFLAGS = \
	-std=gnu99 \
	-fsingle-precision-constant -fdata-sections -ffunction-sections \
	-Wno-implicit-function-declaration -Wdouble-promotion \
	-mcpu=$(TARGET_CPU) \
	-mthumb -mthumb-interwork \
	-mlittle-endian

ifeq ($(DEBUG), 1)
	CFLAGS += -g
else
	CFLAGS += -O2
endif

ASFLAGS = \
	-mcpu=$(TARGET_CPU) \
	-mthumb

LDFLAGS = \
	-T $(LDSCRIPT) \
	-Wl,--gc-sections \
	--specs=nosys.specs \
	--specs=nano.specs

INCFLAGS = \
	-I inc \
	-I $(LIBPATH)/CMSIS/CM3/DeviceSupport/ST/STM32F10x \
	-I $(LIBPATH)/CMSIS/CM3/CoreSupport \
	-I $(LIBPATH)/STM32F10x_StdPeriph_Driver/inc

SRCS := $(wildcard $(LIBPATH)/STM32F10x_StdPeriph_Driver/src/*.c)
SRCS += $(wildcard $(LIBPATH)/CMSIS/CM3/DeviceSupport/ST/STM32F10x/*.c)
SRCS += $(wildcard src/*.c)
SRCS += $(LIBPATH)/CMSIS/CM3/DeviceSupport/ST/STM32F10x/startup/TrueSTUDIO/startup_stm32f10x_md.s

OBJS := $(notdir $(basename $(SRCS)))
OBJS := $(addsuffix .o, $(OBJS))
OBJS := $(addprefix $(BUILD_DIR)/, $(OBJS))

VPATH = $(dir $(SRCS))

DEFS = \
	-D USE_STDPERIPH_DRIVER \
	-D USE_FULL_ASSERT \
	-D $(TARGET_DEVICE)

all: prepare $(BIN)

check:
	@echo $(OBJS) | tr ' ' '\n'

prepare:
	@mkdir -p $(BUILD_DIR)

$(BUILD_DIR)/%.o: %.c
	@echo $(notdir $<)
	@$(CC) -c $(CFLAGS) $(INCFLAGS) $(DEFS) -o $@ $<

$(BUILD_DIR)/%.o: %.s
	@echo $(notdir $<)
	@$(CC) -c $(ASFLAGS) $(INCFLAGS) -o $@ $<

$(ELF): $(OBJS)
	@$(CC) $(LDFLAGS) -o $(ELF) $(OBJS)

$(BIN): $(ELF)
	@$(OC) -O binary $(ELF) $(BIN)

.PHONY: clean flash erase gdb

clean:
	@rm -rf $(BUILD_DIR)

flash: all
	st-flash --reset write $(BIN) 0x08000000

erase:
	st-flash erase

dgb: $(ELF)
	arm-none-eabi-gdb $(ELF)
