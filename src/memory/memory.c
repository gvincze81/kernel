#include "memory.h"

void *memset(void *ptr, int ch, size_t size)
{
    if(!ptr)
        return NULL;

    char *c_ptr = (char*)ptr;

    for (size_t i = 0; i < size; i++)
    {
        c_ptr[i] = (char)ch;
    }
    
    return ptr;
}