#include <stdlib.h>
#include "Matrix.h"


int main(int argc, char **argv)
{
    init_mem(4096);
    traverse_free_list();

    matrix** mat_array = (matrix**) mem_manager_malloc(10*sizeof(matrix*));
    traverse_free_list();
    for(int i = 1; i<= 10; i++)
    {
        matrix* mat = matrix_malloc(3,3);
        for(int j=1; j<=3 ; j++)
        {
            for(int k = 1; k<= 3; k++)
            {
                set_element(mat,j,k,j*k);
            }

        }
        mat_array[i-1] = mat;
    }
    for(int i=1; i<=10; i++)
    {
        matrix* mat=mat_array[i-1];
        display(mat);
        cout << endl; 
    }

    traverse_free_list();
    matrix_free(mat_array[5]);

    traverse_free_list();
    matrix_free(mat_array[3]);

    traverse_free_list();
    matrix_free(mat_array[7]);
    traverse_free_list();

    matrix* mat_1 = matrix_malloc(3,5);
    set_element(mat_1, 1, 1, 3.9);
    set_element(mat_1, 1, 2, 16.2);
    set_element(mat_1, 1, 3, -7.8);
    set_element(mat_1, 1, 3, -7.8);
    set_element(mat_1, 1, 4, 16.2);
    set_element(mat_1, 1, 5, -7.8);
    set_element(mat_1, 2, 1, 2.4);
    set_element(mat_1, 2, 2, -0.9);
    set_element(mat_1, 2, 3, 8.3);
    set_element(mat_1, 2, 4, 6.2);
    set_element(mat_1, 2, 5, -0.8);
    set_element(mat_1, 3, 1, 2.4);
    set_element(mat_1, 3, 2, -0.9);
    set_element(mat_1, 3, 3, 5.1);
    set_element(mat_1, 3, 4, 16.2);
    set_element(mat_1, 3, 5, -7.8);
    display(mat_1);
    traverse_free_list();

    void* temp = mem_manager_malloc(64);
    traverse_free_list();
    matrix_free(mat_array[2]);

    traverse_free_list();
    matrix_free(mat_array[9]);

    traverse_free_list();
    matrix_free(mat_array[0]);

    matrix* mat_2 = matrix_malloc(5,3);
    set_element(mat_2, 1, 1, 4.0);
    set_element(mat_2, 1, 2, -6.35);
    set_element(mat_2, 1, 3, -4.3);
    set_element(mat_2, 2, 1, -11.1);
    set_element(mat_2, 2, 2, 3.0);
    set_element(mat_2, 2, 3, 4.1);
    set_element(mat_2, 3, 1, 19.6);
    set_element(mat_2, 3, 2, 5.6);
    set_element(mat_2, 3, 3, 19.5);
    set_element(mat_2, 4, 1, -17.6);
    set_element(mat_2, 4, 2, 8.8);
    set_element(mat_2, 4, 3, 19.2);
    set_element(mat_2, 5, 1, -11.1);
    set_element(mat_2, 5, 2, -3.5);
    set_element(mat_2, 5, 3, 15.01);
    display(mat_2);
    traverse_free_list();

    matrix_free(mat_array[4]);

    traverse_free_list();
    matrix_free(mat_array[6]);

    traverse_free_list();
    matrix_free(mat_array[8]);

    matrix* mult = multiply(mat_1, mat_2);
    display(mult);
    traverse_free_list();

    matrix_free(mat_array[1]);
    mem_manager_free(mat_array);

    matrix_free(mat_1);
    traverse_free_list();

    matrix_free(mat_2);
    traverse_free_list();


    return 0;

}