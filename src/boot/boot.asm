ORG 0x7c00
BITS 16

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

jmp short start
nop

start:
    jmp 0:step2

step2:
    cli ; Clear Interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov fs, ax
    mov gs, ax
    mov sp, 0x7C00
    sti

.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32
    
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
    db 0b11001111 ; Granularity = 1, Default size = 1, L = 0, AVL = 0, Limit 19-16
    db 0x00 ; Base 31-24

gdt_data:
    dw 0xFFFF ; Segment limit 15-0
    dw 0x00 ; Segment base 15-0
    db 0x00 ; Segment base 23-16
    db 0x92 ; Present bit: 1, DPL = 0, S bit: user segment(1),
            ;Type field: code segment(1), non-conforming(0), readable(1), not accessed(0)
    db 0b11001111 ; Granularity = 1, Default size = 1, L = 0, AVL = 0, Limit 19-16
    db 0x00 ; Base 31-24
gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start
 
 [BITS 32]
 load32:
    mov eax, 1
    mov ecx, 100
    mov edi, 0x0100000


    call ata_lba_read
    jmp CODE_SEG:0x0100000

ata_lba_read:
    mov ebx, eax, ; Backup the LBA
    ; Send the highest 8 bits of the lba to hard disk controller
    shr eax, 24
    or eax, 0xE0 ; Select the  master drive
    mov dx, 0x1F6
    out dx, al
    ; Finished sending the highest 8 bits of the lba

    ; Send the total sectors to read
    mov eax, ecx
    mov dx, 0x1F2
    out dx, al
    ; Finished sending the total sectors to read

    ; Send more bits of the LBA
    mov eax, ebx ; Restore the backup LBA
    mov dx, 0x1F3
    out dx, al
    ; Finished sending more bits of the LBA

    ; Send more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx ; Restore the backup LBA
    shr eax, 8
    out dx, al
    ; Finished sending more bits of the LBA

    ; Send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx ; Restore the backup LBA
    shr eax, 16
    out dx, al
    ; Finished sending upper 16 bits of the LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al

    ; Read all sectors into memory
.next_sector:
    push ecx

%define TEST_RESULT 0x08
; Checking if we need to read
.try_again:
    mov dx, 0x1f7
    in al, dx
    test al, TEST_RESULT
    jz .try_again

; We need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw
    pop ecx
    loop .next_sector
    ; End of reading sectors into memory
    ret

times 510-($ - $$) db 0
dw 0xAA55
