#include "kernel.h"
#include "idt/idt.h"
#include "memory/heap/kheap.h"

#include <stdint.h>
#include <stddef.h>

uint16_t *video_mem = 0;
uint16_t terminal_row = 0;
uint16_t terminal_col = 0;

uint16_t terminal_make_char(char ch, char color)
{
    return (color << 8) | ch;
}

void terminal_putchar(uint32_t row, uint32_t col, char ch, char color)
{
    video_mem[row * VGA_WIDTH + col] = terminal_make_char(ch, color);
}

void terminal_writechar(char ch, char color)
{
    if(ch == '\n')
    {
        terminal_col = 0;
        terminal_row += 1;
        return;
    }

    terminal_putchar(terminal_row, terminal_col, ch, color);
    terminal_col += 1;

    if(terminal_col >= VGA_WIDTH)
    {
        terminal_col = 0;
        terminal_row += 1;
    }
}

void terminal_initialize()
{
    video_mem = (uint16_t*)(VIDEO_MEM);

    for (int i = 0; i < VGA_HEIGHT; i++)
    {
        for(int j = 0; j < VGA_WIDTH; j++)
        {
            terminal_putchar(i, j, ' ', 0);
        }
    }
}

size_t strlen(const char *str)
{
    size_t len = 0;

    while(str[len])
    {
        len++;
    }

    return len;
}

void print(const char *str)
{
    size_t len = strlen(str);

    for (size_t i = 0; i < len; i++)
    {
        terminal_writechar(str[i], 15);
    }
}

void kernel_main()
{
    terminal_initialize();
    print("alpha beta\ngamma\n");

    // Initialize the HEAP
    kheap_init();

    // Initialize the IDT
    idt_init();
}