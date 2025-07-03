ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

%define PROTECTION_ENABLE 1o

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

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, PROTECTION_ENABLE
    mov cr0, eax
    ; Processor is in protected mode from this point
    jmp CODE_SEG:load_32 ; File offset 0x67

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

BITS 32

load_32:
    mov eax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    jmp $

times 510 - ($ - $$) db 0

dw 0xAA55