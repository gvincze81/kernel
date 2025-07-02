ORG 0x7C00
BITS 16

%macro print_char 1
    mov ah, 0x0e
    mov al, %1
    mov bx, 0
    int 0x10
%endmacro

_start:
    jmp short start
    nop

; BIOS PARAMETER BLOCK
times 30 db 0

start:
    jmp 0x00:setup

handle_zero:
    iret

handle_one:
    iret

setup:
    cli
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7C00
    sti

    mov bx, 0
    mov word [bx], handle_zero
    mov word [bx+2], 0

    mov word [bx+4], handle_one
    mov word [bx+6], 0

    jmp $

result:
times 510 - ($ - $$) db 0

dw 0xAA55