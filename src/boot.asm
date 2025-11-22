[bits 16]
[org 0x7c00]

KERNEL_OFFSET equ 0x1000

start:
    xor ax, ax            ; Clear AX
    mov ds, ax            ; Set DS = 0
    mov es, ax            ; Set ES = 0
    
    mov [boot_drive], dl ; BIOS sets DL to boot drive number

    mov bp, 0x9000       ; Set up the stack
    mov sp, bp

    call load_kernel     ; Load the kernel from disk
    call switch_to_pm    ; Switch to 32-bit protected mode

    jmp $                ; Should not be reached

; --- Disk Loading Routine ---
load_kernel:
    mov bx, KERNEL_OFFSET ; Read from disk and store in 0x1000
    mov dh, 50            ; Load 50 sectors (plenty of space)
    mov dl, [boot_drive]
    mov ah, 0x02          ; BIOS read sector function
    mov al, dh            ; Read DH sectors
    mov ch, 0x00          ; Cylinder 0
    mov dh, 0x00          ; Head 0
    mov cl, 0x02          ; Start reading from second sector (after boot sector)
    int 0x13
    jc disk_error         ; Jump if error (carry flag set)
    ret

disk_error:
    mov ah, 0x0e
    mov al, 'E'
    int 0x10
    jmp $

; --- GDT ---
gdt_start:
    dd 0x0                ; null descriptor
    dd 0x0

gdt_code:                 ; code descriptor
    dw 0xffff             ; limit low
    dw 0x0                ; base low
    db 0x0                ; base middle
    db 10011010b          ; access
    db 11001111b          ; granularity
    db 0x0                ; base high

gdt_data:                 ; data descriptor
    dw 0xffff             ; limit low
    dw 0x0                ; base low
    db 0x0                ; base middle
    db 10010010b          ; access
    db 11001111b          ; granularity
    db 0x0                ; base high

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start - 1
    dd gdt_start

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

; --- Switch to Protected Mode ---
switch_to_pm:
    cli                   ; Disable interrupts
    lgdt [gdt_descriptor] ; Load GDT
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax          ; Switch to protected mode
    jmp CODE_SEG:init_pm  ; Far jump to flush pipeline

[bits 32]
init_pm:
    mov ax, DATA_SEG      ; Update segment registers
    mov ds, ax
    mov ss, ax
    mov es, ax
    mov fs, ax
    mov gs, ax

    mov ebp, 0x90000      ; Update stack position
    mov esp, ebp

    call KERNEL_OFFSET    ; Jump to C kernel
    jmp $

boot_drive db 0

times 510-($-$$) db 0
dw 0xaa55
