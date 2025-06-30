ORG 0x7C00
BITS 16

_start:
    jmp short start
    nop

; BIOS PARAMETER BLOCK
times 30 db 0

start:
    jmp 0x00:setup

setup:
    cli
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov si, message
    call print

    jmp $

print:
    mov bx, 0
.loop:
    lodsb
    cmp al, 0
    je .done
    call print_char
    jmp .loop

.done:
    ret

print_char:
    mov ah, 0x0e
    int 0x10
    ret

message: db 'alpha beta', 0

times 510 - ($ - $$) db 0
dw 0xAA55