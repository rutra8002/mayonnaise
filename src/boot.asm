bits 16
org 0x7c00

boot_main:
    xor ax, ax
    mov ds, ax                ; Align DS with the boot code segment

    mov si, hello             ; SI addresses the message buffer
.process_bytes:
    lodsb                     ; Load next byte from DS:SI into AL, advance SI
    test al, al               ; A zero byte marks the end of the buffer
    jz .idle_forever
    mov ah, 0x0e              ; BIOS teletype output (int 10h, fn 0Eh)
    int 0x10
    jmp .process_bytes

.idle_forever:
    jmp .idle_forever         ; Fall back to a stable idle state

hello: db 'Hello, World!', 0

times 510-($-$$) db 0        ; Pad to 510 bytes so we can add the boot flag
dw 0xaa55                    ; magic number