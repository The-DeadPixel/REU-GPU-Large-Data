/*
 *  file name: TilingMatrixV2.c
 *  NOTE: 
 *       squareMatrixMult is much more efficent than the regular multiplier
 *       currently compiling with: nvcc TilingMatrix.cu -o tileTest
 *       Device Standards for: GeForce GTX 1060 6GB
 *          total global mem size: 6078 MBytes (6373572608 bytes)
 *          total shared mem per block: 49.152 KBytes (49152 bytes)
 *       nvcc TilingMatrix.cu -lcublas -o tileTest
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
            &a GPU device pointer to a m X m matrix (A)
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
/**************************************************************
 function name: storeC
 description: copies the final answers of tileC back to the corresponding indices of of Matrix C
 
 parameters:
            &tilec          pointer to pre-allocated (tileLength X tileLength) matrix
            &matrixc        pointer to large (m X m)matrix B 
            int tileLength  predefined length of tile
            int i           caller outer loop value (helps define starting ROW index for tile)
            int j           caller inner loop value (helps define starting COLUMN for tile)
 
 ****************************************************************/
void storeC (float *tileC, float *matrixC, int tileLength, int i, int j){
    //pointer declarations
    float **tilePtr = &tileC;
    float **matrixPtr = &matrixC;
    
    for(int Ti = 0; i < tileLength; i++){
       for(int Tj = 0; j < tileLength; j++){
           matrixPtr[Ti + (tileLength*i)][Tj + (tileLength*j)] = tilePtr[i][j];
       }
    }
    
}
/**************************************************************
 function name: fillA
 description: populates TileA with elements of matrix A that correspond to the to the correct starting indices and boundries of the tile.
 
 parameters:
            &tileA          pointer to pre-allocated tileLength X tileLength matrix
            &matrixA        pointer to large matrix A 
            int tileLength  predefined length of tile
            int i           caller outer loop value (helps define starting ROW index for tile)
            int j           caller inner loop value (helps define starting COLUMN for tile)
 
 ****************************************************************/
void fillA(float *tileA, float *matrixA, int tileLength, int i, int j, int                      numTiles){
    //pointer declarations
    float *tilePtr = tileA;     
    float *matrixPtr = matrixA;
    
    for(int Ti = (tileLength*i); Ti < (tileLength*i)+tileLength; Ti++){
        for(int Tj = (tileLength*j); Tj < (tileLength*j) + tileLength; Tj++ ){
            tilePtr[(Ti * tileLength) + Tj] = matrixPtr[(Ti *numTiles *tileLength) + Tj]; 
            printf("[%0.1f] ", tilePtr[(Ti * tileLength) + Tj]);
        }
        printf("\n");
    }
    printf("\n");
    
    
}

/**************************************************************
 function name: fillB
 description: populates TileB with elements of matrix B that correspond to the to the correct starting indices and boundries of the
 tile.
 
 parameters:
            &tileB          pointer to pre-allocated (tileLength X tileLength) matrix
            &matrixB        pointer to large (m X m)matrix B 
            int tileLength  predefined length of tile
            int i           caller outer loop value (helps define starting COLUMN index for tile)
            int j           caller inner loop value (helps define starting ROW for tile)
 
 ****************************************************************/
void fillB(float *tileB, float *matrixB, int tileLength, int i, int j, int numTiles){
    //pointer declarations
    float *tilePtr = tileB;
    float *matrixPtr = matrixB;
    
    for(int Ti = (tileLength*j); Ti < (tileLength*i)+tileLength; Ti++){
        for(int Tj = (tileLength*i); Tj < (tileLength*j) + tileLength; Tj++ ){
            tilePtr[Ti * tileLength + Tj] = matrixPtr[Ti * numTiles* tileLength + Tj]; 
            printf("[%0.1f]", tilePtr[Ti * tileLength + Tj]);
        }
        printf("\n");
    }
    printf("\n");
}

/**********************************************************************
function name: matrixCpy
description: Iterates through large (m X m) matricies A and B, continually creating smaller (tileLength * tileLength) matricies Ta and Tb that will be used by device to produce matrix C containing computed answers of MM of matrices A and B.  
parameters: 
            &a              GPU device pointer to a m X m matrix (A)
            &b              GPU device pointer to a m X m matrix (B)
            &c              GPU device output purpose pointer to a m X m matrix (C) 
            int tileLength  predefined max length of tile
            int m           # of tiles that divide the length of matrices A & B
        
return: none
TODO implement kernel calls of cuBlas and TMM, implement another function or code that tranfers results of C tile to matrix C. FIGURE OUT WHY fillA and fillB piss off the compiler
**********************************************************************/
void matrixCpy(float *a, float *b, float *c, int tileLength, int m ) {
   // device and host TILE memory declaration
   float *Ta,*Tb,*Tc, *d_a, *d_b, *d_c;
   cublasHandle_t handle;
   for(int i = 0; i < m; i++){
        
       //host and device tile allocation of C
        Tc = (float*) malloc(tileLength*tileLength* sizeof(float)); // host tile memory for c
        cudaMalloc((void**)&d_c,tileLength*tileLength*sizeof(*c)); // device memory alloc for c
       //memcpy of tile C for host to device (POSSIBLE AREA FOR TIMING)
        cudaMemcpy(d_c, Tc, tileLength*tileLength*sizeof(float), cudaMemcpyHostToDevice);
        
        for(int j = 0; j < m; j++){
            

            //Host memory alocation
            Ta = (float*) malloc(tileLength*tileLength* sizeof(float)); // host tile memory alloc for a
            Tb = (float*) malloc(tileLength*tileLength* sizeof(float)); // host tile memory alloc for b
            //Device memory allocation 
            cudaMalloc((void**)&d_a,tileLength*tileLength*sizeof(*a)); // device memory alloc for a
            cudaMalloc((void**)&d_b,tileLength*tileLength*sizeof(*b)); // device memory alloc for b
            
            
            //Fill tileA & tileB with elements from matrix A (COMPILER IS SAYING THESE ARE UNDEFINED WTF) (POSSIBLE AREA FOR TIMING)
            printf("Tile A iteration: %d\n", j);
            fillA(Ta, a, tileLength, i, j, m);
            printf("Tile B iteration: %d\n", j);
            fillB(Tb, b, tileLength, i, j, m);
            //memcpy TileA and TileB froim host to device
//             cudaMemcpy(d_a, Ta, tileLength*tileLength*sizeof(float), cudaMemcpyHostToDevice);
//             cudaMemcpy(d_b, Tb, tileLength*tileLength*sizeof(float), cudaMemcpyHostToDevice);
//             //Conditional that checks for the indices that dictate an UPPER TRIANGULAR MATRIX, calls correct kenrel
//             if(i == j){
//                 //TMM Kernel goes here
//             }
//             else{
//                 
//             // Cublas MM Kernel call goes here
//             }
               cublasSgemm(handle,CUBLAS_OP_N,CUBLAS_OP_N,tileLength,tileLength,tileLength,&al,d_a,tileLength,d_b,tileLength,&bet,d_c,tileLength);
//             //Free device and host memory for next iteration
               
//             cudaFree(d_a);
//             cudaFree(d_b);
               cublasDestroy(handle);
//             free(Ta);
//             free(Tb);
        }
//         //memcpy c results back to host
//         cudaMemcpy(Tc, d_c, tileLength*tileLength*sizeof(float), cudaMemcpyDeviceToHost);
//         //Free device and host memory of C related arrays
//         cudaFree(d_c);
//         free(Tc);
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
//     srand(3333);
    int val = 1;
    // random initialize matrix A [mxk]
    for (int i = 0; i < m; ++i) {
        for (int j = 0; j < n; ++j) {
            a[i * n + j] =val++;
        }
    }
    val = 1;
    // random initialize matrix B [kxn]
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < k; ++j) {
            b[i * k + j] = val++;
        }
    }
    
//     // on host set the two matracies to triangles
//     unsigned int grid_rows = (m + BLOCK_SIZE - 1) / BLOCK_SIZE;
//     unsigned int grid_cols = (k + BLOCK_SIZE - 1) / BLOCK_SIZE;
//     dim3 dimGrid(grid_cols, grid_rows);
//     dim3 dimBlock(BLOCK_SIZE, BLOCK_SIZE);
    
    printf("Calculating...\n\n");
    // Launch kernel
    matrixCpy(a,b,c,2,2);
//     matrixTriUpper<<<dimGrid, dimBlock>>>(a, m, n);
//     matrixTriUpper<<<dimGrid, dimBlock>>>(b, n, k);
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
    
    
    return 0;
}