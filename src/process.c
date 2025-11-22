#include "process.h"

#define MAX_PROCESSES 8

typedef enum {
    PROC_UNUSED = 0,
    PROC_READY,
    PROC_RUNNING
} process_state_t;

typedef struct {
    int pid;
    process_state_t state;
    process_entry_t entry;
    void* ctx;
    const char* name;
} process_t;

static process_t process_table[MAX_PROCESSES];
static int next_pid = 1;

void process_system_init(void) {
    for (int i = 0; i < MAX_PROCESSES; ++i) {
        process_table[i].pid = 0;
        process_table[i].state = PROC_UNUSED;
        process_table[i].entry = 0;
        process_table[i].ctx = 0;
        process_table[i].name = 0;
    }
}

int process_create(const char* name, process_entry_t entry, void* ctx) {
    for (int i = 0; i < MAX_PROCESSES; ++i) {
        if (process_table[i].state == PROC_UNUSED) {
            process_table[i].pid = next_pid++;
            process_table[i].state = PROC_READY;
            process_table[i].entry = entry;
            process_table[i].ctx = ctx;
            process_table[i].name = name;
            return process_table[i].pid;
        }
    }
    return -1;
}

void scheduler_loop(void) {
    int index = 0;

    while (1) {
        process_t* proc = &process_table[index];
        if (proc->state == PROC_READY && proc->entry) {
            proc->state = PROC_RUNNING;
            proc->entry(proc->ctx);
            proc->state = PROC_READY;
        }

        index = (index + 1) % MAX_PROCESSES;
    }
}
