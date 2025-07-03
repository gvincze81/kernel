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

    jmp $

; GDT

gdt_start:
gdt_null:
    dd 0x00
    dd 0x00

; Code segment descriptor
gdt_code:
    dw 0xFFFF ; Segment limit 15-0
    dw 0x00 ; Segment base 15-0
    db 0x00 ; Segment base 23-16
    db 0x9A ; Present bit: 1, DPL = 0, S bit: user segment(1),
            ;Type field: code segment(1), non-conforming(0), readable(1), not accessed(0)
    db 0b1100111 ; Granularity = 1, Default size = 1, L = 0, AVL = 0, Limit 19-16
    db 0x00 ; Base 31-24

gdt_data:
    dw 0xFFFF ; Segment limit 15-0
    dw 0x00 ; Segment base 15-0
    db 0x00 ; Segment base 23-16
    db 0x92 ; Present bit: 1, DPL = 0, S bit: user segment(1),
            ;Type field: code segment(1), non-conforming(0), readable(1), not accessed(0)
    db 0b1100111 ; Granularity = 1, Default size = 1, L = 0, AVL = 0, Limit 19-16
    db 0x00 ; Base 31-24
gdt_end:

gdt_descriptor:
    dw gdt_end - 1 - gdt_start
    dd gdt_start

; End

times 510 - ($ - $$) db 0

dw 0xAA55