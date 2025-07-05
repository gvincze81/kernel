#include "kernel.h"

uint16_t terminal_make_char(char ch, char color)
{
    return (color << 8) | ch;
}

void kernel_main()
{
    uint16_t *video_mem = (uint16_t*)(VIDEO_MEM);
    video_mem[0] = terminal_make_char('A', 4);
}