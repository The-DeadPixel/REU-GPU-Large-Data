/*
 *  file name: TilingMatrix.cu
 *  NOTE: 
 *       squareMatrixMult is much more efficent than the regular multiplier
 *       currently compiling with: nvcc TilingMatrix.cu -o tileTest
 *       Device Standards for: GeForce GTX 1060 6GB
 *          total global mem size: 6078 MBytes (6373572608 bytes)
 *          total shared mem per block: 49.152 KBytes (49152 bytes)
 */

#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <math.h>
#include <assert.h>
#include <sys/time.h>
#include <stdlib.h>

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
function name: matrixMult
description: dot product of two matrix (not only square)
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
__global__ void matrixMult(float *a, float *b, float *c, int m, int n, int k)
{ 
    int row = blockIdx.y * blockDim.y + threadIdx.y; 
    int col = blockIdx.x * blockDim.x + threadIdx.x;
    float  sum = 0;
    if( col < k && row < m) {
        for(int i = 0; i < n; i++) 
            sum += a[row * n + i] * b[i * k + col];
        c[row * k + col] = sum;
    }
} 

/**********************************************************************
function name: squareMatrixMult
description: dot product of two matrix (not only square) in GPU
parameters: 
            &a GPU device pointer to a n X n matrix (A)
            &b GPU device pointer to a n X n matrix (B)
            &c GPU device output purpose pointer to a n X n matrix (C) 
            to store the result
Note:
    grid and block should be configured as:
        dim3 dim_grid((n - 1) / BLOCK_SIZE + 1, (n - 1) / BLOCK_SIZE + 1, 1);
        dim3 dim_block(BLOCK_SIZE, BLOCK_SIZE, 1);
    SQUARE IS MUCH MORE EFFICENT THAN REGULAR
return: none
**********************************************************************/
__global__ void squareMatrixMult(float *d_a, float *d_b, float *d_result, int n) 
{
    __shared__ float tile_a[BLOCK_SIZE][BLOCK_SIZE];
    __shared__ float tile_b[BLOCK_SIZE][BLOCK_SIZE];

    int row = blockIdx.y * BLOCK_SIZE + threadIdx.y;
    int col = blockIdx.x * BLOCK_SIZE + threadIdx.x;
    float tmp = 0;
    int idx;

    for (int sub = 0; sub < gridDim.x; ++sub) {
        idx = row * n + sub * BLOCK_SIZE + threadIdx.x;
        if(idx >= n*n) {
            // n may not divisible by BLOCK_SIZE
            tile_a[threadIdx.y][threadIdx.x] = 0;
        }
        else {
            tile_a[threadIdx.y][threadIdx.x] = d_a[idx];
        }

        idx = (sub * BLOCK_SIZE + threadIdx.y) * n + col;
        if(idx >= n*n) {
            tile_b[threadIdx.y][threadIdx.x] = 0;
        }  
        else {
            tile_b[threadIdx.y][threadIdx.x] = d_b[idx];
        }
        __syncthreads();

        for (int k = threadIdx.x/n; k < BLOCK_SIZE; ++k)  {
            tmp += tile_a[threadIdx.y][k] * tile_b[k][threadIdx.x];
        }
        __syncthreads();
    }
    if(row < n && col < n) {
        d_result[row * n + col] = tmp;
    }
}

/**********************************************************************
function name: main
description: test and compare
parameters: 
            none
return: none
**********************************************************************/

int main(int argc, char** argv) {
    int printAllMat = 1; // debug flag for printing all of the maticies
    // Set sizes of the matrixes
    int m=15;
    int n=15;
    int k=15;
    
    /* Fixed seed for illustration */
    srand(3333);

    // Allocate memory in host RAM
    float *copyA, *copyB, *copyC;
    cudaMallocHost((void **) &copyA, sizeof(float)*m*n); // copied matrix is m x n
    cudaMallocHost((void **) &copyB, sizeof(float)*n*k); // copied matrix is n x k
    cudaMallocHost((void **) &copyC, sizeof(float)*m*k); // copied matrix is m x k
    
    // float x = (float)rand()/(float)(RAND_MAX/a);
    // random initialize matrix A
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            copyA[i * n + j] =((float)rand()/(float)(RAND_MAX)) * 1024;
        }
    }

    // random initialize matrix B
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < k; ++j) {
            copyB[i * k + j] = ((float)rand()/(float)(RAND_MAX)) * 1024;
        }
    }
    
    // Allocate memory space on the device 
    float *matA, *matB, *matC;
    cudaMalloc((void **) &matA, sizeof(float)*m*n); // matrix is m x n
    cudaMalloc((void **) &matB, sizeof(float)*n*k); // matrix is n x k
    cudaMalloc((void **) &matC, sizeof(float)*m*k); // matrix is m x k
    
    // copy matrix A and B from host to device memory
    cudaMemcpy(matA, copyA, sizeof(float)*m*n, cudaMemcpyHostToDevice);
    cudaMemcpy(matB, copyB, sizeof(float)*n*k, cudaMemcpyHostToDevice);
    
    printf("size of matA %dX%d: %zu bytes\n", m,n,(sizeof(float)*m*n));
    printf("size of matB %dX%d: %zu bytes\n", n,k,(sizeof(float)*n*k));
    printf("size of matC %dX%d: %zu bytes\n", m,k,(sizeof(float)*m*k));
    printf("total bytes allocated to mem: %zu bytes ", ((sizeof(float)*m*n) + (sizeof(float)*n*k)+ (sizeof(float)*m*k)));
    printf("(~%zu MBytes)\n\n", (((sizeof(float)*m*n) + (sizeof(float)*n*k)+ (sizeof(float)*m*k)) / 1000000)); // get megabytes of the allocated arrays

    unsigned int grid_rows = (m + BLOCK_SIZE - 1) / BLOCK_SIZE;
    unsigned int grid_cols = (k + BLOCK_SIZE - 1) / BLOCK_SIZE;
    dim3 dimGrid(grid_cols, grid_rows);
    dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    
    printf("Calculating...\n\n");
    // Launch kernel, check if it is a square
    if(m == n && n == k) {
        matrixTriUpper<<<dimGrid, dimBlock>>>(matA, m, n);
        matrixTriUpper<<<dimGrid, dimBlock>>>(matB, n, k);
        squareMatrixMult<<<dimGrid, dimBlock>>>(matA, matB, matC, n); // square, thus only need 1 param to define size
    }
    else { // not a square, thus it needs param to define all sizes
        matrixMult<<<dimGrid, dimBlock>>>(matA, matB, matC, m, n, k);
    }
    
    // Transefr results from device to host 
    cudaMemcpy(copyC, matC, sizeof(float)*m*k, cudaMemcpyDeviceToHost);
    cudaDeviceSynchronize(); //possibly
    //cudaThreadSynchronize();
    
    //prints the matricies
    // printf("[%d][%d]:%d, ", i, j, copyC[i*k + j]); //Another possible way to print the matrix
    //if the debug flag is on it will print the first two product arrays as well
    int i,j;
    if(printAllMat == 1) {
        // print matrix A
        printf("matA matrix: \n");
        for (i = 0; i < m; i++) {
            for (j = 0; j < n; j++) {
                //printf("[%d][%d]:%d, ", i, j, copyA[i*k + j]);
                printf(" %f ", copyA[i*k + j]);
            }
            printf("\n");
        }
        // print matrix B
        printf("\nmatB matrix: \n");
        for (i = 0; i < n; i++) {
            for (j = 0; j < k; j++) {
                //printf("[%d][%d]:%d, ", i, j, copyB[i*k + j]);
                printf(" %f ", copyB[i*k + j]);
            }
            printf("\n");
        }
    }
    
    // print result matrix
    printf("\nResult matrix: \n");
    for (i = 0; i < m; i++) {
        for (j = 0; j < k; j++) {
                //printf("[%d][%d]:%d, ", i, j, copyC[i*k + j]);
                printf(" %f ", copyC[i*k + j]);
            }
        printf("\n");
    }
    
    // free memory
    cudaFree(matA);
    cudaFree(matB);
    cudaFree(matC);
    cudaFreeHost(copyA);
    cudaFreeHost(copyB);
    cudaFreeHost(copyC);
    return 0;
}
