// C program to multiply 2 triangular square matricies
// gcc -Wall GPUMatrixMult.c -o GPUMaMult
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <stdlib.h>
#include <sys/time.h>

#define N 3  // THIS IS WHERE YOU DEFINE THE SIZE OF THE MATRIX (it can only be square right now)

// Function to form upper triangular marix
void upper(int matrix[][N])
{
    int i, j;
    
    for (i=0; i<N; i++)
    {
        for (j=0; j<N; j++)
        {
            if (i>j)
            {
                matrix[i][j] = 0;
            }
            matrix[i][j] = matrix[i][j];
        }
    }
}

// This function multiplies mat1[][] and mat2[][],
// and stores the result in res[][]
void multiply(int mat1[][N], int mat2[][N], int res[][N])
{
    int i, j, k;
    for (i = 0; i < N; i++)
    {
        for (j = i; j < N; j++)
        {
            res[i][j] = 0;
            for (k = 0; k < N; k++)
                res[i][j] += mat1[i][k]*mat2[k][j];
        }
    }
}

int main(int argc, char** argv)
{
    int mat1[N][N] = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    int mat2[N][N] = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
    int res[N][N];
    
    upper(mat1); // sets the matrix to its upper bound
    upper(mat2); // sets the matrix to its upper bound
    
    int i,j;
    multiply(mat1, mat2, res); // multiplies the 2 matricies 
    
    // print matrix 1
    printf("mat1 matrix is \n");
    for (i = 0; i < N; i++)
    {
        for (j = 0; j < N; j++)
           printf("%d ", mat1[i][j]);
        printf("\n");
    }
    // print matrix 2
    printf("mat2 matrix is \n");
    for (i = 0; i < N; i++)
    {
        for (j = 0; j < N; j++)
           printf("%d ", mat2[i][j]);
        printf("\n");
    }
    // print result matrix
    printf("Result matrix is \n");
    for (i = 0; i < N; i++)
    {
        for (j = 0; j < N; j++)
           printf("%d ", res[i][j]);
        printf("\n");
    }
    
    return 0;
}
