BITS 32

global _start

%define CODE_SEG 0x08
%define DATA_SEG 0x10

_start:
    mov eax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; Enable the A20 line
    in al, 0x92
    or al, 2
    out 0x92, al
    ; End

    jmp $