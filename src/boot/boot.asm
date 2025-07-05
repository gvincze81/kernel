ORG 0x7C00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

%define PROTECTION_ENABLE 1o
%define KERNEL_EFFECTIVE_ADDRESS 0x100000

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
    jmp CODE_SEG:load_32

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

[BITS 32]

; Load kernel to memory
load_32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x100000
    call ata_lba_read
    jmp CODE_SEG:KERNEL_EFFECTIVE_ADDRESS

ata_lba_read:
    mov ebx, eax ; Backup the LBA
    ; Send highest 8 bits to hard disk controller
    shr eax, 24
    or eax, 0xE0 ; Selects the master drive
    mov dx, 0x01F6
    out dx, al
    ; Finished sending highest 8 bits

    ; Send number of total sectors
    mov eax, ecx
    mov dx, 0x01F2
    out dx, al
    ; End

    ; Send bottom 8 bits
    mov eax, ebx ; Restore original value of LBA
    mov dx, 0x01F3
    out dx, al
    ; End

    ; Send more bits
    mov dx, 0x01F4
    mov eax, ebx
    shr eax, 8
    out dx, al
    ; End

    ; Send 8 bits at index 2(third from bottom)
    mov dx, 0x01F5
    mov eax, ebx
    shr eax, 16
    out dx, al
    ; End

    mov dx, 0x01F7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx

%define TEST_BIT 8
; Checking if we need to read
.try_again:

    mov dx, 0x01F7
    in al, dx
    test al, TEST_BIT
    je .try_again

; We need to read 256 sectors at a time
    mov ecx, 256
    mov dx, 0x01F0
    rep insw
    pop ecx
    loop .next_sector
    ; Finished reading all sectors
    ret

times 510 - ($ - $$) db 0

dw 0xAA55