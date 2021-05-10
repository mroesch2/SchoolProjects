#include <cmath>
#include <ctime>
#include <cstdlib>
#include <cstdio>

#include "BinarySearchTree.h"
using CSC1310::BinarySearchTree;
#include "BinaryTreeIterator.h"
using CSC1310::BinaryTreeIterator;
#include "ListArray.h"
using CSC1310::ListArray;
#include "ListArrayIterator.h"
using CSC1310::ListArrayIterator;

#include "Permutation.h"
using CSC1310::Permutation;
#include "Random.h"
using CSC1310::Random;

#include <pthread.h>
#include "CD.h"

#include <iostream>
using namespace std;
//Tried buffer:1, producer:1, consumer:1
//Took 2 s
//Tried buffer:10, producer:3, consumer:3
//Took 7s
//Tried buffer:100, producer:5, consumer:5
//Took 3s
//Tried buffer:100, producer:1, consumer:2
//Tested multiple times 6s 7s 6s
//Tried buffer:100, producer:10, consumer:20
//Took 2s
//Tried buffer:100, producer:20, consumer:10
//Took 3s

int BUFFER_SIZE = 100;
int NUM_PRODUCERS = 20;
int NUM_CONSUMERS = 10;
int NUM_TREES = 10000;
int ERROR_RATE = 0;

CD*** buffer;
int buffer_count = 0;
int producer_index = 0;
int consumer_index = 0;

int num_trees_p = 0;
int num_trees_c = 0;

pthread_cond_t empty, full;
pthread_mutex_t mutex;


void put(CD** cds_array)
{
	buffer[producer_index] = cds_array;
	producer_index = (producer_index + 1) % BUFFER_SIZE;
	buffer_count++;  //buffer fills up
}

CD** get()
{
	CD** cds_array = buffer[consumer_index];
	consumer_index = (consumer_index + 1) % BUFFER_SIZE;
	buffer_count--;  //buffer empties out
	return cds_array;
}

void deleteCDs(ListArray<CD>* list)
{
   ListArrayIterator<CD>* iter = list->iterator();

   while(iter->hasNext())
   {
      CD* cd = iter->next();
      delete cd;
   }

   delete iter;
}

CD** producer_seq(ListArray<CD>* cds, Random* rand)
{
	    int num_items = cds->size();
	
		Permutation* p = new Permutation(num_items, num_items, rand);
		p->basicInit();
		CD** permute_cds = new CD*[num_items];
		int count = 0;
		while(p->hasNext())
		{
			int i = p->next();
			permute_cds[count] = cds->get(i);
			count++;
		}
		delete p;

		BinarySearchTree<CD>* bst = new BinarySearchTree<CD>(&CD::compare_items, &CD::compare_keys);
		for (int i = 0; i < num_items; i++)
		{
			CD* cd = permute_cds[i];
			bst->insert(cd);
		}
		delete[] permute_cds;
  
		//create a complete binary search tree
		BinarySearchTree<CD>* complete_bst = bst->minimizeComplete();
		CD** cds_array = new CD*[num_items];
		BinaryTreeIterator<CD>* complete_iter = complete_bst->iterator();

		//intentionally inserting an error
		int traversal_error = rand->getRandomInt(1, NUM_TREES);
		if (traversal_error >= ERROR_RATE)
		{
			complete_iter->setLevelorder();
		}
		else
		{
			//wrong traversal, consumer should detect a height error
			//still will be sorted, however
			complete_iter->setPostorder();
		}
		count = 0;
		while(complete_iter->hasNext())
		{
			cds_array[count] = complete_iter->next();
			count++;
		}
		delete bst;
		delete complete_iter;
		delete complete_bst;
		
		return cds_array;
}

void consumer_seq(CD** cds_array, int num_items, int expected_height)
{
		BinarySearchTree<CD>* bst = new BinarySearchTree<CD>(&CD::compare_items, &CD::compare_keys);
		for (int i = 0; i < num_items; i++)
		{
			CD* cd = cds_array[i];
			bst->insert(cd);
		}
   
		BinaryTreeIterator<CD>* bst_iter = bst->iterator();
		CD* first = bst_iter->next();
		bool sorted = true;
		while(bst_iter->hasNext())
		{
			CD* second = bst_iter->next();
			if (CD::compare_items(first, second) >= 0)
			{
				sorted = false;
				break;
			}
			first = second;
		}
		delete bst_iter;
   
		int h = bst->getHeight();
		bool bal = bst->isBalanced();
   
		if (!sorted || h != expected_height || !bal)
		{
			cout << "invalid complete binary tree" << endl;
		}
		else
		{
			//cout << "valid complete binary tree" << endl;
		}

		delete bst;
		delete[] cds_array;
}

//Function takes in one parameter which is a pointer to args
//Can't pass args when calling in main
void* producer_par(void* p_args)
{
    long* args = (long*) p_args;
    ListArray<CD>* cds = (ListArray<CD> *) args[0];
    Random* rand = (Random *) args[1];

    //while (num_trees_p <= (NUM_TREES + NUM_CONSUMERS - 1)) DOESNT WORK
    /*Pulled logic from Fig 30.7 in book and well as Wiki explination
    of how producer and consumer work becasue fig 30.14 in the book
    still uses for loop*/ 

    //Loop until consumer stops it
	while (true)
    {
        CD** cd_array = producer_seq(cds, rand);
        pthread_mutex_lock(&mutex);

        while (buffer_count == BUFFER_SIZE)
            pthread_cond_wait(&empty, &mutex);

        if (num_trees_p >= NUM_TREES + NUM_CONSUMERS)
        {
            pthread_cond_broadcast(&full);
            pthread_mutex_unlock(&mutex);
            break;
        }
        else if (num_trees_p >= NUM_TREES)
            put(NULL);
        else
            put(cd_array);

        num_trees_p++;
        pthread_cond_broadcast(&full);
        pthread_mutex_unlock(&mutex);
    }
}

void* consumer_par(void* c_args)
{
    int* args = (int*) c_args;
    int num_items = args[0];
    int expected_height = args[1];

    //while (num_trees_c <= (NUM_TREES + NUM_PRODUCERS- 1))
    while (true)
    {
        pthread_mutex_lock(&mutex);
        
        while (buffer_count == 0)
            pthread_cond_wait(&full, &mutex);

        CD** cd_array = get();

        if (cd_array == NULL)
        {
            pthread_cond_broadcast(&empty);
            pthread_mutex_unlock(&mutex);
            break;
        }

        num_trees_c++;
        pthread_cond_broadcast(&empty);
        pthread_mutex_unlock(&mutex);
	    consumer_seq(cd_array, num_items, expected_height);
    }
}

int main()
{
	buffer = new CD**[BUFFER_SIZE];
	
	time_t start, end;
	Random* rand = Random::getRandom();
	   
   //the unsorted ListArray of cds
   ListArray<CD>* cds = CD::readCDs("cds.txt");
   int num_items = cds->size();
   cout << num_items << endl;
   cout << "based on the number of items, the min height should be: " << endl;
   int expected_height = ceil(log2(num_items + 1));
   cout << expected_height << endl;
   cout << endl;
   
   long* producer_args = new long[2];
   producer_args[0] = (long) cds;
   producer_args[1] = (long) rand;
   long** temp_p = &producer_args;
   
   int* consumer_args = new int[2];
   consumer_args[0] = num_items;
   consumer_args[1] = expected_height;
   int** temp_c = &consumer_args;
  
   //CODE FOR SEQUENTIAL. Commented out because we don't need it.   
   /*start = time(NULL);

	for (int i = 1; i <= NUM_TREES; i++)
	{
	    CD** cd_array = producer_seq(cds, rand);
		consumer_seq(cd_array, num_items, expected_height);
	}
   
    end = time(NULL);
   printf("sequential: %ds\n\n", (int)(end - start)); */

   
   // Start of parallel 
   pthread_t producers[NUM_PRODUCERS];
   pthread_t consumers[NUM_CONSUMERS];

   start = time(NULL);

    //initialize producer threads
    for (int i = 0; i < NUM_PRODUCERS; i++)
        pthread_create(&producers[i], NULL, producer_par, *temp_p);

   //initialize consumer threads
    for (int i = 0; i < NUM_CONSUMERS; i++)
        pthread_create(&consumers[i], NULL, consumer_par, *temp_c);

	//Join threads for producers
    for (int i = 0; i < NUM_PRODUCERS; i++)
        pthread_join(producers[i], NULL);

	//join threads for consumers
    for (int i = 0; i < NUM_CONSUMERS; i++)
        pthread_join(consumers[i], NULL);

   end = time(NULL);
   
  
   printf("parallel: %ds\n\n", (int)(end - start));
   

   delete[] producer_args;
   delete[] consumer_args;
   deleteCDs(cds);
   delete cds;

   return 0;
}