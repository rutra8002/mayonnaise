#include <stdint.h>
#include "video.h"
#include "process.h"

typedef struct {
    const char* label;
    int row;
    uint32_t counter;
    uint8_t color;
    uint32_t delay_cycles;
} counter_ctx_t;

static void busy_delay(uint32_t cycles);
static void launch_demo_processes(void);
static int string_length(const char* str);
static void counter_process(void* ctx);

void main() {
    video_clear(VGA_ATTR_DEFAULT);
    video_write_text(0, 0, "Simple scheduler online", VGA_ATTR_DEFAULT);

    process_system_init();
    launch_demo_processes();
    scheduler_loop();
}

static int string_length(const char* text) {
    int len = 0;
    if (!text) {
        return 0;
    }
    while (text[len] != '\0') {
        ++len;
    }
    return len;
}

static void busy_delay(uint32_t cycles) {
    volatile uint32_t i;
    for (i = 0; i < cycles; ++i) {
        __asm__ __volatile__("nop");
    }
}

static void counter_process(void* ctx) {
    counter_ctx_t* state = (counter_ctx_t*)ctx;
    int col = 0;

    video_write_text(state->row, col, state->label, state->color);
    col += string_length(state->label);
    video_write_text(state->row, col, ": ", state->color);
    col += 2;
    video_write_number(state->row, col, state->counter++, state->color);

    busy_delay(state->delay_cycles);
}

static void launch_demo_processes(void) {
    static counter_ctx_t proc_a = {"Process A", 2, 0, 0x0A, 120000};
    static counter_ctx_t proc_b = {"Process B", 4, 0, 0x0C, 180000};
    static counter_ctx_t proc_c = {"Process C", 6, 0, 0x0E, 240000};

    process_create(proc_a.label, counter_process, &proc_a);
    process_create(proc_b.label, counter_process, &proc_b);
    process_create(proc_c.label, counter_process, &proc_c);
}
