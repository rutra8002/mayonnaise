#ifndef PROCESS_H
#define PROCESS_H

typedef void (*process_entry_t)(void*);

void process_system_init(void);
int process_create(const char* name, process_entry_t entry, void* ctx);
void scheduler_loop(void);

#endif
