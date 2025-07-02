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

; main code
    mov ah, 0x0e
    mov al, 'X'
    mov bx, 0
    int 0x10
; end

    jmp $

times 510 - ($ - $$) db 0

dw 0xAA55