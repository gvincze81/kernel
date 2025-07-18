#include "paging.h"
#include "memory/heap/kheap.h"

struct paging_4gb_chunk *paging_new_4gb(uint8_t flags)
{
    uint32_t *directory_entry = kzalloc(PAGING_TOTAL_ENTRIES_PER_TABLE * sizeof(PAGE_TRANSLATION_TABLE_ENTRY));

    for(size_t i = 0; i < PAGING_TOTAL_ENTRIES_PER_TABLE; i++)
    {
        PAGE_TRANSLATION_TABLE_ENTRY *table_entry = kzalloc(PAGING_TOTAL_ENTRIES_PER_TABLE * sizeof(PAGE_TRANSLATION_TABLE_ENTRY));

        for(size_t j = 0; j < PAGING_TOTAL_ENTRIES_PER_TABLE; j++)
        {
            table_entry[j] = (i * PAGING_TOTAL_ENTRIES_PER_TABLE + j) * PHYSICAL_PAGE_SIZE;
            table_entry[j] |= flags;
        }

        directory_entry[i] = (uint32_t)table_entry | flags | PAGING_IS_WRITABLE;
    }

    struct paging_4gb_chunk *chunk_4gb = kzalloc(sizeof(struct paging_4gb_chunk));
    chunk_4gb->directory = directory_entry;

    return chunk_4gb;
}