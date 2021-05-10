#ifndef MATRIX_H
#define MATRIX_H

#include <stdlib.h>
#include <stdio.h>
#include "MMHeader.h"

typedef struct __matrix
{
	int num_rows;
	int num_cols;
	double* elements;
} matrix;

//FUNCTION DONE
matrix* matrix_malloc(int num_rows, int num_cols);

//FUNCTION DONE
void matrix_free(matrix* mat);

//FUNCTION DONE
void set_element(matrix* mat, int row, int col, double val);

//FUNCTION DONE
double get_element(matrix* mat, int row, int col);

//FUNCTION DONE
matrix* multiply(matrix* left, matrix* right);

//FUCTION DONE
void display(matrix* mat);




//left cols has to be the same as right rows for matrix multiplication
matrix* multiply(matrix* left, matrix* right)
{
	int left_rows = left->num_rows;
	int left_cols = left->num_cols;
	int right_rows = right->num_rows;
	int right_cols = right->num_cols;
	matrix* result = matrix_malloc(left_rows, right_cols);
	
	for (int i = 1; i <= left_rows; i++)
	{
		for (int j = 1; j <= right_cols; j++)
		{
			double val = 0;
			for (int k = 1; k <= left_cols; k++)
			{
				double element_left = get_element(left, i, k);
				double element_right = get_element(right, k, j);
				double mul = element_left * element_right;
				val += mul;
			}
			set_element(result, i, j, val);
		}
	}
	
	return result;
}


matrix* matrix_malloc(int num_rows, int num_cols)
{
    // instead of malloc use your own malloc which is mem_manager_malloc
    matrix *mat = (matrix *) mem_manager_malloc(sizeof(matrix));

    mat->num_rows = num_rows;
    mat->num_cols = num_cols;


    mat->elements = (double *) mem_manager_malloc(num_rows*num_cols*sizeof(double));

    for (int i=0; i<num_rows*num_cols; i++)
        mat->elements[i]=0;
        
    return mat;
}

void matrix_free(matrix* mat)
{
    // use mem_manager_free to free memory 

    mem_manager_free(mat->elements);
    mem_manager_free(mat);
}


void set_element(matrix* mat, int row, int col, double val)
{
    mat->elements[(col-1) * mat->num_rows + (row-1)] = val;

}



double get_element(matrix* mat, int row, int col)
{
    double element;
    
    element = mat->elements[(col-1) * mat->num_rows + (row-1)];

    return element;
}




void display(matrix* mat)
{
    for (int i = 1; i <= mat->num_rows; i++)
    {
        printf("\n");
        for (int j = 1; j <= mat->num_cols; j++)
        {
            double c = get_element(mat, i, j);
            printf("%f ", c);
        }
    }
} 

#endif