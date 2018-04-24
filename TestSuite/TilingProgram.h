int kernalWrap(long, float*, float*, float* );


__global__ void squareMatrixMult(float *d_a, float *d_b, float *d_result, int n);
__global__ void matrixMult(float *a, float *b, float *c, int m, int n, int k); 
__global__ void matrixTriUpper(float *a, int m, int n);

