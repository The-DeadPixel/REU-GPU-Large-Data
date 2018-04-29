/*
 *  file name: TilingMatrixV2.c
 *  NOTE: 
 *       squareMatrixMult is much more efficent than the regular multiplier
 *       currently compiling with: nvcc TilingMatrix.cu -o tileTest
 *       Device Standards for: GeForce GTX 1060 6GB
 *          total global mem size: 6078 MBytes (6373572608 bytes)
 *          total shared mem per block: 49.152 KBytes (49152 bytes)
 *       nvcc TilingMatrixV2.c -lcublas -o TilingMatrixTest
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <assert.h>
#include <sys/time.h>
#include <cuda_runtime.h>
#include "cublas_v2.h"
#include <sys/time.h>     //measuring performance data

 #define BLOCK_SIZE 32

/**********************************************************************
function name: matrixTriUpper
description: sets a matrix to an upper bound triangle matrix
parameters: 
            &a GPU device pointer to a m X n matrix (A)
Note:
    
return: none
**********************************************************************/
__global__ void matrixTriUpper(float *a, int m, int n) {
    //setting matricies to their upper bound 
    for(int i = 0; i < m; ++i) {
        for(int j = 0; j < n; ++j) {
            if(i>j)
                a[i*n + j] = 0;
            a[i*n + j] = a[i*n + j];
        }
    }
}

/**********************************************************************
function name: cublasMatrixMult
description: dot product of two matricies using cublas function: cublasSgemm
parameters: 
            &a GPU device pointer to a m X n matrix (A)
            &b GPU device pointer to a n X k matrix (B)
            &c GPU device output purpose pointer to a m X k matrix (C) 
            to store the result
Note:
    grid and block should be configured as:
        dim3 dimGrid((k + BLOCK_SIZE - 1) / BLOCK_SIZE, (m + BLOCK_SIZE - 1) / BLOCK_SIZE);
        dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    further sppedup can be obtained by using shared memory to decrease global memory access times
return: none
**********************************************************************/
// __global__ void cublasMatrixMult(float *a, float *b, float *c, int m, int n, int k) {
//     // Set status variables
//     cudaError_t cudaStat; // cudaMalloc status
//      cublasStatus_t stat; // CUBLAS functions statusx
//     cublasHandle_t handle; // CUBLAS context
//     
//     // matracies on the device
//     float *d_a; // d_a - a on the device
//     float *d_b; // d_b - b on the device
//     float *d_c; // d_c - c on the device
//     cudaStat = cudaMalloc((void**)&d_a,m*k*sizeof(*a)); // device memory alloc for a
//     cudaStat = cudaMalloc((void**)&d_b,k*n*sizeof(*b)); // device memory alloc for b
//     cudaStat = cudaMalloc((void**)&d_c,m*n*sizeof(*c)); // device memory alloc for c
//     //cudaGetErrorString((cudaError_t) cudaStat);
//     if(cudaStat != cudaSuccess)
//         printf("Cuda Error: %s\n", cudaGetErrorString(cudaStat));
//     
//     stat = cublasCreate(&handle); // initialize CUBLAS context
//     // copy matrices from the host to the device
//     stat = cublasSetMatrix(m,k,sizeof(*a),a,m,d_a,m); //a -> d_a
//     stat = cublasSetMatrix(k,n,sizeof(*b),b,k,d_b,k); //b -> d_b
//     stat = cublasSetMatrix(m,n,sizeof(*c),c,m,d_c,m); //c -> d_c
// //     if(stat != CUBLAS_STATUS_SUCCESS)
// //         printf("Cublas Error: %s\n", cublasGetErrorString(stat));
//     
//     float al =1.0f; // al=1
//     float bet =1.0f; // bet=1
//     // matrix-matrix multiplication: d_c=al*d_a*d_b+bet*d_c
//     // d_a -mxk matrix, d_b -kxn matrix, d_c -mxn matrix;
//     // al, bet -scalars
//     stat = cublasSgemm(handle,CUBLAS_OP_N,CUBLAS_OP_N,m,n,k,&al,d_a,m,d_b,k,&bet,d_c,m);
//     stat = cublasGetMatrix(m,n,sizeof(*c),d_c,m,c,m); // cp d_c -> c
// //     if(stat != CUBLAS_STATUS_SUCCESS)
// //         printf("Cublas Error: %s\n", cublasGetErrorString(stat));
//     
//     // free device memory
//     cudaFree(d_a);
//     cudaFree(d_b);
//     cudaFree(d_c);
//     cublasDestroy(handle); // destroy CUBLAS context
// }

/**********************************************************************
function name: matrixCpy
description: Breaks up 2 matracies into smaller chunks, and Device to be multiplied
parameters: 
            &a GPU device pointer to a m X n matrix (A)
            &b GPU device pointer to a n X k matrix (B)
            &c GPU device output purpose pointer to a m X k matrix (C) 
            to store the result
return: none
**********************************************************************/
void matrixCpy(float *a, float *b, float *c, int m, int n, int k) {
    // Need to allocate all of C fo the continued computation.
    cudaMalloc((void**)&d_c,m*n*sizeof(*c)); // device memory alloc for c
    //begin breaking up matrix A & B and mallocing them for device
    for(int i=0; i < n; ++i) {
        float = *d_a; // d_a - block of a on the device
        cudaMalloc((void*)&d_a,i*n*sizeof(*a));
        for(int j=0; j < n; ++j) {
            
        }
    }
}

/**********************************************************************
function name: cublasGetErrorString
description: gets the cublas string error codes for printing
parameters: 
            error a cublas error status enum
return: char pointer (string)
TODO: Fix the return type
**********************************************************************/
const char* cublasGetErrorString(cublasStatus_t status)
{
    switch(status)
    {
        case CUBLAS_STATUS_SUCCESS: return "CUBLAS_STATUS_SUCCESS";
        case CUBLAS_STATUS_NOT_INITIALIZED: return "CUBLAS_STATUS_NOT_INITIALIZED";
        case CUBLAS_STATUS_ALLOC_FAILED: return "CUBLAS_STATUS_ALLOC_FAILED";
        case CUBLAS_STATUS_INVALID_VALUE: return "CUBLAS_STATUS_INVALID_VALUE"; 
        case CUBLAS_STATUS_ARCH_MISMATCH: return "CUBLAS_STATUS_ARCH_MISMATCH"; 
        case CUBLAS_STATUS_MAPPING_ERROR: return "CUBLAS_STATUS_MAPPING_ERROR";
        case CUBLAS_STATUS_EXECUTION_FAILED: return "CUBLAS_STATUS_EXECUTION_FAILED"; 
        case CUBLAS_STATUS_INTERNAL_ERROR: return "CUBLAS_STATUS_INTERNAL_ERROR"; 
    }
    return "unknown error";
}


/**********************************************************************
function name: main
description: test and compare
parameters: 
            none
return: none
**********************************************************************/
int main(int argc, char** argv) {
    int m=4;// a - mxk matrix
    int n=4;// b - kxn matrix
    int k=4;// c - mxn matrix
    // Set status variables
    
    // Allocate memory in host RAM
    float *a; // mxk matrix a on the host
    float *b; // kxn matrix b on the host
    float *c; // mxn matrix c on the host
    a = (float*) malloc(m*k* sizeof(float)); // host memory for a
    b = (float*) malloc(k*n* sizeof(float)); // host memory for b
    c = (float*) malloc(m*n* sizeof(float)); // host memory for c
    
    /* Assign Random Variables to the matrecies */
    srand(3333);
    // random initialize matrix A [mxk]
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            a[i * n + j] =((float)rand()/(float)(RAND_MAX))*1024;
        }
    }

    // random initialize matrix B [kxn]
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < k; ++j) {
            b[i * k + j] = ((float)rand()/(float)(RAND_MAX))*1024;
        }
    }
    
    // on host set the two matracies to triangles
    unsigned int grid_rows = (m + BLOCK_SIZE - 1) / BLOCK_SIZE;
    unsigned int grid_cols = (k + BLOCK_SIZE - 1) / BLOCK_SIZE;
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    
    printf("Calculating...\n\n");
    // Launch kernel
    matrixTriUpper<<<dimGrid, dimBlock>>>(a, m, n);
    matrixTriUpper<<<dimGrid, dimBlock>>>(b, n, k);
//     cublasMatrixMult<<<dimGrid, dimBlock>>>(a,b,c,m,n,k);
    
    int i,j;
    // print matrix A
    printf("matA matrix: \n");
    for (i = 0; i < m; i++) {
        for (j = 0; j < n; j++) {
            //printf("[%d][%d]:%d, ", i, j, a[i*k + j]);
            printf(" %f ", a[i*k + j]);
        }
        printf("\n");
    }
    // print matrix B
    printf("\nmatB matrix: \n");
    for (i = 0; i < n; i++) {
        for (j = 0; j < k; j++) {
            //printf("[%d][%d]:%d, ", i, j, b[i*k + j]);
            printf(" %f ", b[i*k + j]);
        }
        printf("\n");
    }
    // print result matrix
    printf("\nResult matrix: \n");
    for (i = 0; i < m; i++) {
        for (j = 0; j < k; j++) {
                //printf("[%d][%d]:%d, ", i, j, c[i*k + j]);
                printf(" %f ", c[i*k + j]);
            }
        printf("\n");
    }
    
    // free memory
    cudaFree(a);
    cudaFree(a);
    cudaFree(a);
    return 0;
}
