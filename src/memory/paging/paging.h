#ifndef PAGING_H
#define PAGING_H

#include <stdint.h>
#include <stddef.h>

#define PAGING_CACHE_DISABLED   0b00010000
#define PAGING_WRITETHROUGH     0b00001000
#define PAGING_ACCESS_FROM_ALL  0b00000100
#define PAGING_IS_WRITABLE      0b00000010
#define PAGING_IS_PRESENT       0b00000001

#define PAGING_TOTAL_ENTRIES_PER_TABLE 1024
#define PHYSICAL_PAGE_SIZE 4096

typedef uint32_t PAGE_TRANSLATION_TABLE_ENTRY;

struct paging_4gb_chunk
{
    uint32_t *directory;
};

/*
* Allocates and initializes a full paging structure
*/
struct paging_4gb_chunk *paging_new_4gb(uint8_t flags);

#endif