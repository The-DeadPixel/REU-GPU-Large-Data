#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <sys/time.h>
#include <stdlib.h>

#include <sys/time.h>     //measuring performance data

//_global__
//void kernel_syr2k(int N, int M, double *C, double *A, double *B){
//}

void matrix_math(int N){
   
  double* mat1;
  double* mat2;
  double* ret;
  cudaMallocManaged(&mat1, N*N * sizeof(float));		//cuda allocation of unified Memory  
  cudaMallocManaged(&mat2, N*N * sizeof(float));
  cudaMallocManaged(&ret, N * sizeof(float)); 
  
  //setting matricies to their upper bound 
  int i, j;
  for (i=0; i<N; i++)    {
    for (j=0; j<N; j++)    {
      if (i>j)   {
        mat1[i][j] = 0;
        mat2[i][j] = 0;
      }
      mat1[i][j] = mat1[i][j];
      mat2[i][j] = mat2[i][j];
    }
  }
 
 //multiplying matricies 
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


int main(int argc, char** argv)
{
    int N = 3;  // THIS IS WHERE YOU DEFINE THE SIZE OF THE MATRIX (it can only be square right now)
  
    //performance measurment 
    struct timeval t_start;
    struct timeval t_end;
    double etime;
    /////
  
    matrix_math(N);      
    
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





