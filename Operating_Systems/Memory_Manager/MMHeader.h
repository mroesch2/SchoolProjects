#ifndef MMHEADER_H
#define MMHEADER_H

#include <sys/mman.h>
#include <iostream>

using namespace std;

const int CONST_MAGIC = 1234567;

typedef struct __mmalloc_t
{
	int size;
	int magic;
} mmalloc_t;

typedef struct __mmfree_t
{
	int size;
	struct __mmfree_t* next;
} mmfree_t;

mmfree_t* head;

void* mem_manager_malloc(int size);
void mem_manager_free(void* ptr);
//traverse the free space list starting from the head, printing out info (for debugging)
void traverse_free_list(); 
void init_mem(int free_space_size);


//called by malloc
//find a free space chunk large enough for the requested allocation
//obtain some memory from that chunk
mmfree_t* locate_split(int size);

//called by free
//locate the freed memory insert position so free space nodes are sorted by address
mmfree_t* find_sorted_location(void* chunk);



void init_mem(int free_space_size)
{
	// reference chapter 17 page 6 for debugging 
	// mmap() returns a pointer to a chunk of free space
	head = (mmfree_t*) mmap(NULL, free_space_size, PROT_READ|PROT_WRITE, MAP_ANON|MAP_PRIVATE, -1, 0);
	head->size = free_space_size - sizeof(mmfree_t);
	head->next = nullptr;

}


void* mem_manager_malloc(int size) 
{
	// look for free space 
	mmfree_t* bfc = locate_split(size);	

	mmfree_t* prev = head;
	while (prev->next != nullptr) 
	{
		if(prev->next == bfc) 
			break;
		prev = prev->next;
	}

	if(bfc->size > size + sizeof(mmalloc_t))
	{
		mmfree_t* new_chunk = (mmfree_t*) ((void*) (bfc) + sizeof(mmalloc_t) + size);
		new_chunk->size = bfc->size - sizeof(mmalloc_t) - size;
		new_chunk->next = bfc->next;
		if(bfc == head)
			head = new_chunk;
		else
			prev->next = new_chunk;
	}
	else
	{
		if(bfc != head)
			prev->next = bfc->next;
		else
			head = bfc->next;
	
	}

	mmalloc_t* header = (mmalloc_t*) bfc;
	header->size = size;
	header->magic = CONST_MAGIC;

	return (void*) (header) + sizeof(mmalloc_t);
}

void mem_manager_free(void* ptr) 
{
	mmfree_t* location = find_sorted_location(ptr);

	if(location == ptr - sizeof(mmalloc_t) && (void*) location + location->size == location->next)
	{
		mmfree_t* n_2 = head->next->next;
		head->size = head->size + head->next->size;
		head->next = n_2;
	}
	else
	{
		if(location->next->next != nullptr && (void*) location->next + location->next->size == location->next->next)
		{
			mmfree_t* n_3 = location->next->next->next;
			location->next->size = location->next->size + location->next->next->size;
			location->next->next = n_3;
		}

		if((void*) location + location->size == location->next)
		{
			mmfree_t* n_2 = location->next->next;
			location->size = location->size + location->next->size;
			location->next = n_2;
		}
	}
}

void traverse_free_list()
{
	if(!head) return;
	mmfree_t*ptr = head;

	while(true)
	{
		cout << endl;
		cout << "curr: " << ptr << endl;
		cout << "size: " << ptr->size << endl;
        ptr = ptr->next;
		if(ptr == nullptr) 
            return;
	}
}


mmfree_t* locate_split(int size) 
{
	mmfree_t* split = nullptr;
	mmfree_t* curr = head;

	int alloc_size = size + sizeof(mmalloc_t);
	do
	{
		if(curr->size == alloc_size || (curr->size >= alloc_size + sizeof(mmfree_t) && (split == nullptr || split->size > curr->size))) 
			split = curr;
		curr = curr->next;
	}while(curr != nullptr);
	return split;
}

mmfree_t* find_sorted_location(void* chunk) 
{
	mmfree_t* location = head;
	mmalloc_t* chunkHead = (mmalloc_t*) ((void*) (chunk) - sizeof(mmalloc_t));

	if(chunkHead < (void*) (head))
	{
		mmfree_t* temp = location;
		head = (mmfree_t*) chunkHead;
		head->size = chunkHead->size + sizeof(mmalloc_t);
		head->next = temp;
		return head;
	}

	while (location->next != nullptr && location->next < (mmfree_t*) chunkHead)
		location = location->next;

	mmfree_t* temp = location->next;
	location->next = (mmfree_t*) chunkHead;
	location->next->size = chunkHead->size + sizeof(mmalloc_t);
	location->next->next = temp;

	return location;
}

#endif