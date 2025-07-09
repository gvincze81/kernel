#include "idt.h"
#include "config.h"
#include "kernel.h"

#include "memory/memory.h"
#include "io/io.h"

struct idt_desc idt_descriptors[TOTAL_INTERRUPTS];
struct idtr_desc idtr_descriptor;

void idt_load(struct idtr_desc *ptr);
void int21h();
void no_interrupt();

void no_interrupt_handler()
{
    outb(0x20, 0x20);
}

void int21h_handler()
{
    print("Keyboard pressed\n");
    outb(0x20, 0x20);
}

void idt_set(uint16_t interrupt_no, void *address)
{
    struct idt_desc *desc = &idt_descriptors[interrupt_no];
    desc->offset_1 = (uint32_t)address & 0xFFFF;
    desc->selector = CODE_SELECTOR;
    desc->zero = 0x00;
    desc->attributes = 0b11101110;
    desc->offset_2 = (uint32_t)address >> 16;
}

void idt_init()
{
    memset(idt_descriptors, 0, sizeof(idt_descriptors));
    idtr_descriptor.limit = sizeof(idt_descriptors) - 1;
    idtr_descriptor.base = (uint32_t)idt_descriptors;

    for (int i = 0; i < TOTAL_INTERRUPTS; i++)
    {
        idt_set(i, no_interrupt);
    }

    idt_set(0x21, int21h);

    // Load the IDT
    idt_load(&idtr_descriptor);
}