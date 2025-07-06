#include "kernel.h"

#include <stdint.h>
#include <stddef.h>

uint16_t *video_mem = 0;

uint16_t terminal_make_char(char ch, char color)
{
    return (color << 8) | ch;
}

void terminal_putchar(uint32_t row, uint32_t col, char ch, char color)
{
    video_mem[row * VGA_WIDTH + col] = terminal_make_char(ch, color);
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
    terminal_putchar(0, 0, 'X', 4);
}