#include "video.h"

#define VGA_MEMORY ((volatile uint16_t*)0xB8000)

static uint16_t vga_entry(char c, uint8_t attr) {
    return ((uint16_t)attr << 8) | (uint8_t)c;
}

void video_clear(uint8_t attr) {
    uint16_t blank = vga_entry(' ', attr);
    for (int row = 0; row < VGA_ROWS; ++row) {
        for (int col = 0; col < VGA_COLS; ++col) {
            VGA_MEMORY[row * VGA_COLS + col] = blank;
        }
    }
}

static void reverse_buffer(char* buffer, int length) {
    for (int i = 0; i < length / 2; ++i) {
        char tmp = buffer[i];
        buffer[i] = buffer[length - 1 - i];
        buffer[length - 1 - i] = tmp;
    }
}

void video_write_text(int row, int col, const char* text, uint8_t attr) {
    if (!text || row < 0 || row >= VGA_ROWS || col < 0 || col >= VGA_COLS) {
        return;
    }

    int offset = row * VGA_COLS + col;
    for (int i = 0; text[i] != '\0' && offset + i < VGA_ROWS * VGA_COLS; ++i) {
        VGA_MEMORY[offset + i] = vga_entry(text[i], attr);
    }
}

void video_write_number(int row, int col, uint32_t value, uint8_t attr) {
    char digits[12];
    int index = 0;

    do {
        digits[index++] = '0' + (value % 10);
        value /= 10;
    } while (value > 0 && index < (int)sizeof(digits) - 1);

    digits[index] = '\0';
    reverse_buffer(digits, index);

    video_write_text(row, col, "          ", attr);
    video_write_text(row, col, digits, attr);
}
