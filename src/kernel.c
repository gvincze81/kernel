#include "kernel.h"

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

void kernel_main()
{
    terminal_initialize();
}