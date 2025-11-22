#ifndef VIDEO_H
#define VIDEO_H

#include <stdint.h>

#define VGA_COLS 80
#define VGA_ROWS 25
#define VGA_ATTR_DEFAULT 0x07

void video_clear(uint8_t attr);
void video_write_text(int row, int col, const char* text, uint8_t attr);
void video_write_number(int row, int col, uint32_t value, uint8_t attr);

#endif
