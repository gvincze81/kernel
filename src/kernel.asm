BITS 32

global _start

extern kernel_main

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

    ; Remap the master PIC
    mov al, 0b00010001
    out 0x20, al ; Put PIC into init mode

    mov al, 0x20 ; Interupt 0x20 is where PIC should be remapped
    out 0x21, al

    mov al, 0b00000001
    out 0x21, al
    ; End

    sti

    call kernel_main

    jmp $

times 512-($ - $$) db 0