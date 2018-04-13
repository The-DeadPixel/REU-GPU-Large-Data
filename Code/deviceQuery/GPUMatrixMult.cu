#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <stdlib.h>

#include <sys/time.h>     //measuring performance data

_global__
void kernel_syr2k(int N, int M, double *C, double *A, double *B){
}



// Function to form upper triangular marix
void upper(int matrix[][N]){
    int i, j;
    for (i=0; i<N; i++)    {
        for (j=0; j<N; j++)    {
            if (i>j)   {
                matrix[i][j] = 0;
            }
            matrix[i][j] = matrix[i][j];
        }
    }
}



// This function multiplies mat1[][] and mat2[][],
// and stores the result in res[][]
void multiply(float mat1[][N], float mat2[][N], float res[][N])
{
    int i, j, k;
    for (i = 0; i < N; i++)
    {
        for (j = i; j < N; j++)
        {
            res[i][j] = 0.0;
            for (k = 0; k < N; k++)
                res[i][j] += mat1[i][k]*mat2[k][j];
        }
    }
}

void init_matricies(int N){
   
  double* mat1;
  double* mat2;
  double* ret;
  cudaMallocManaged(&mat1, N*N * sizeof(float));		//cuda allocation of unified Memory  
  cudaMallocManaged(&mat2, N*N * sizeof(float));
  cudaMallocManaged(&ret, N * sizeof(float)); 
  
  upper(mat1); // sets the matrix to its upper bound
  upper(mat2); // sets the matrix to its upper bound

}


int main(int argc, char** argv)
{
    int N = 3;  // THIS IS WHERE YOU DEFINE THE SIZE OF THE MATRIX (it can only be square right now)
    //performance measurment 
    struct timeval t_start;
    struct timeval t_end;
    double etime;
    
    init_matricies(N);
    
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






int main(int argc, char** argv)
{
   
}
