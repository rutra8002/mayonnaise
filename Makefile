# Variables
ASM = nasm
SRC_DIR = src
BUILD_DIR = build
SRC = $(SRC_DIR)/boot.asm
IMG = $(BUILD_DIR)/boot.img
QEMU = qemu-system-x86_64

# Targets
.PHONY: all run clean

all: $(IMG)

$(IMG): $(SRC) | $(BUILD_DIR)
	$(ASM) -f bin $(SRC) -o $(IMG)

$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

run: $(IMG)
	$(QEMU) -drive format=raw,file=$(IMG)

clean:
	rm -rf $(BUILD_DIR)
