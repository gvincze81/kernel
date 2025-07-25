#include "kheap.h"
#include "heap.h"
#include "config.h"
#include "kernel.h"

#include <stdint.h>

struct heap kernel_heap;
struct heap_table kernel_heap_table;

void kheap_init()
{
    uint32_t total_table_entries = HEAP_SIZE_BYTES / HEAP_BLOCK_SIZE;

    kernel_heap_table.entries = (HEAP_BLOCK_TABLE_ENTRY*)HEAP_TABLE_ADDRESS; // Temporary
    kernel_heap_table.total = total_table_entries;

    void *end = (void*)(HEAP_ADDRESS + HEAP_SIZE_BYTES);

    int res = heap_create(&kernel_heap, (void*)HEAP_ADDRESS, end, &kernel_heap_table);
    if(res < 0)
    {
        print("Failed to create heap");
    }
}

void *kmalloc(size_t size)
{
    return heap_malloc(&kernel_heap, size);
}

void kfree(void *ptr)
{
    heap_free(&kernel_heap, ptr);
}