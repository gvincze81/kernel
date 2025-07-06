#ifndef IDT_H
#define IDT_H

#include <stdint.h>

struct idt_desc
{
    uint16_t offset_1; // Offset bits 15-0
    uint16_t selector; // Selects the code segment
    uint8_t zero;
    uint8_t attributes; // Present bit, DPL, type field
    uint16_t offset_2; // Offset bits 31-16
} __attribute__((packed));

struct idtr_desc
{
    uint16_t limit; // Size of descriptor table - 1
    uint32_t base;
} __attribute__((packed));

#endif