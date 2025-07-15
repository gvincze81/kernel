#include "heap.h"
#include "config.h"
#include "status.h"
#include "memory/memory.h"

#include <stdbool.h>

static int heap_validate_table(void *ptr, void *end, struct heap_table *table)
{
    int res = 0;

    size_t table_size = (size_t)(end - ptr);
    size_t total_blocks = table_size / HEAP_BLOCK_SIZE;
    if(table->total != total_blocks)
    {
        res = -EINVARG;
        goto out;
    }

out:
    return res;
}

static int heap_validate_alignment(void *ptr)
{
    return (unsigned int)ptr % HEAP_BLOCK_SIZE == 0;
}

int heap_create(struct heap *heap, void *ptr, void *end, struct heap_table *table)
{
    int res = 0;

    if(!heap_validate_alignment(ptr) || !heap_validate_alignment(end))
    {
        res = -EINVARG;
        goto out;
    }

    memset(heap, 0, sizeof(heap));
    heap->saddr = ptr;
    heap->table = table;

    res = heap_validate_table(ptr, end, table);
    if(res < 0)
        goto out;

    size_t table_total = sizeof(HEAP_BLOCK_TABLE_ENTRY) * table->total;
    memset(table->entries, HEAP_BLOCK_TABLE_ENTRY_FREE, table_total);

out:
    return res;
}

#if IMPLEMENTATION == 0
static uint32_t heap_align_value_to_upper(uint32_t val)
{
    if(val % HEAP_BLOCK_SIZE == 0)
        return val;

    val = val - (val % HEAP_BLOCK_SIZE);
    val += HEAP_BLOCK_SIZE;

    return val;
}
#else
static uint32_t heap_align_value_to_upper(uint32_t val)
{
    if(!val)
        return 0;

    val -= 1;
    val += HEAP_BLOCK_SIZE - ((val) % HEAP_BLOCK_SIZE);

    return val;
}
#endif

static int heap_get_entry_type(HEAP_BLOCK_TABLE_ENTRY entry)
{
    return entry & 0x0F;
}

#if IMPLEMENTATION == 0
int heap_get_start_block(struct heap *heap, uint32_t total_blocks)
{
    struct heap_table *table = heap->table;
    uint32_t bc = 0;
    uint32_t bs = -1;

    for(size_t i = 0; i < table->total; i++)
    {
        if(heap_get_entry_type(table->entries[i]) != HEAP_BLOCK_TABLE_ENTRY_FREE)
        {
            bc = 0;
            bs = -1;
            continue;
        }

        if(bs == -1)
            bs = i;

        bc++;
        if(bc == total_blocks)
            break;
    }

    if(bs == -1)
        return -ENOMEM;

    return bs;
}
#else
static bool heap_block_is_free(HEAP_BLOCK_TABLE_ENTRY entry)
{
    return !(entry & 0x0F);
}

int heap_get_start_block(struct heap *heap, uint32_t total_blocks)
{
    struct heap_table *table = heap->table;
    for(int i = 0; i < table->total - total_blocks + 1; i++)
    {
        if(heap_block_is_free(table->entries[i]))
        {
            int all_passed = 1;
            for(int j = i + 1; j < i + total_blocks; j++)
            {
                if(!heap_block_is_free(table->entries[i]))
                {
                    all_passed = 0;
                    break;
                }
            }
            if(all_passed)
                return i;
        }
    }
    return -1;
}
#endif

void* heap_block_to_address(struct heap *heap, uint32_t block)
{
    return heap->saddr + block * HEAP_BLOCK_SIZE;
}

#if IMPLEMENTATION == 0
void heap_mark_blocks_taken(struct heap *heap, uint32_t start_block, uint32_t total_blocks)
{
    uint32_t end_block = (start_block + total_blocks) - 1;
    HEAP_BLOCK_TABLE_ENTRY entry = HEAP_BLOCK_TABLE_ENTRY_TAKEN | HEAP_BLOCK_IS_FIRST;

    if(total_blocks > 1)
        entry |= HEAP_BLOCK_HAS_NEXT;

    for(uint32_t i = start_block; i <= end_block; i++)
    {
        heap->table->entries[i] = entry;
        entry = HEAP_BLOCK_TABLE_ENTRY_TAKEN;

        if(i != end_block)
            entry |= HEAP_BLOCK_HAS_NEXT;
    }
}
#else
void heap_mark_blocks_taken(struct heap *heap, uint32_t start_block, uint32_t total_blocks)
{
    if(!total_blocks)
        return;

    uint32_t end = start_block + total_blocks - 1;
    HEAP_BLOCK_TABLE_ENTRY *entries = heap->table->entries;

    entries[start_block] = HEAP_BLOCK_IS_FIRST | HEAP_BLOCK_TABLE_ENTRY_TAKEN;

    for(size_t i = start_block; i < end; i++)
    {
        entries[i] |= HEAP_BLOCK_HAS_NEXT;
        entries[i] |= HEAP_BLOCK_TABLE_ENTRY_TAKEN;
    }

    entries[end] |= HEAP_BLOCK_TABLE_ENTRY_TAKEN;
}
#endif

static void *heap_malloc_blocks(struct heap *heap, uint32_t total_blocks)
{
    void *address = NULL;

    size_t start_block = heap_get_start_block(heap, total_blocks);
    if(start_block < 0)
        goto out;

    address = heap_block_to_address(heap, start_block);

    // Mark the blocks taken
    heap_mark_blocks_taken(heap, start_block, total_blocks);

out:
    return address;
}

void *heap_malloc(struct heap *heap, size_t size)
{
    size_t aligned_size = heap_align_value_to_upper(size);
    uint32_t total_blocks = aligned_size / HEAP_BLOCK_SIZE;
    if(total_blocks){}

    return heap_malloc_blocks(heap, total_blocks);
}

static uint32_t heap_address_to_block(struct heap *heap, void *ptr)
{
    return (ptr - heap->saddr) / HEAP_BLOCK_SIZE;
}

void heap_mark_blocks_free(struct heap *heap, uint32_t starting_block)
{
    struct heap_table *table = heap->table;
    for(size_t i = starting_block; i < table->total; i++)
    {
        HEAP_BLOCK_TABLE_ENTRY block = table->entries[i];
        table->entries[i] = HEAP_BLOCK_TABLE_ENTRY_FREE;
        if(!(block & HEAP_BLOCK_HAS_NEXT))
            break;
    }
}

void heap_free(struct heap *heap, void *ptr)
{
    heap_mark_blocks_free(heap, heap_address_to_block(heap, ptr));
}