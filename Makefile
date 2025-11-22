# Variables
ASM = nasm
CC = gcc
LD = ld
SRC_DIR = src
BUILD_DIR = build
BOOT_SRC = $(SRC_DIR)/boot.asm
C_SOURCES = $(wildcard $(SRC_DIR)/*.c)
BOOT_BIN = $(BUILD_DIR)/boot.bin
KERNEL_OBJS = $(patsubst $(SRC_DIR)/%.c,$(BUILD_DIR)/%.o,$(C_SOURCES))
KERNEL_BIN = $(BUILD_DIR)/kernel.bin
OS_IMAGE = $(BUILD_DIR)/os-image.bin
OS_ISO = $(BUILD_DIR)/os-image.iso
QEMU = qemu-system-x86_64

# Flags
CFLAGS = -ffreestanding -m32 -g -c -fno-pie -fno-stack-protector
LDFLAGS = -m elf_i386 -Ttext 0x1000 --oformat binary

# Targets
.PHONY: all run clean

all: $(OS_ISO)

$(OS_ISO): $(OS_IMAGE)
	mkdir -p $(BUILD_DIR)/iso
	cp $(OS_IMAGE) $(BUILD_DIR)/iso/
	genisoimage -o $@ -b os-image.bin -c boot.cat $(BUILD_DIR)/iso/

$(OS_IMAGE): $(BOOT_BIN) $(KERNEL_BIN)
	cat $^ /dev/zero | dd bs=512 count=2880 > $@

$(BOOT_BIN): $(BOOT_SRC) | $(BUILD_DIR)
	$(ASM) -f bin $< -o $@

$(KERNEL_BIN): $(KERNEL_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: $(SRC_DIR)/%.c | $(BUILD_DIR)
	$(CC) $(CFLAGS) $< -o $@

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

run: $(OS_ISO)
	$(QEMU) -cdrom $(OS_ISO)

clean:
	rm -rf $(BUILD_DIR)
