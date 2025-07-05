#include "kernel.h"

uint16_t *video_mem = 0;

uint16_t terminal_make_char(char ch, char color)
{
    return (color << 8) | ch;
}

void terminal_initialize()
{
    video_mem = (uint16_t*)(VIDEO_MEM);

    for (int i = 0; i < VGA_HEIGHT; i++)
    {
        for(int j = 0; j < VGA_WIDTH; j++)
        {
            video_mem[i * VGA_WIDTH + j] = terminal_make_char(SPACE_CHARACTER, 0);
        }
    }
}

void kernel_main()
{
    terminal_initialize();
}