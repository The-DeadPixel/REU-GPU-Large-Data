**GPU Architecture**
  1. Glolbal Memory - used by both cpu and gpu (analogous to ram in a cpu server)
  2. Streaming Multiprocessors (SMs) - performs the actual computations 
    * each SM has programmable (under control of the  program) cache, called shared memory, and local memory: a large register file, used for storing localprogram variables
 
- At CPU host level, the program is sequential with Grid kernel invocations to the GPU.
    * The host code does a kernel call. In this call it defines grid and thread block dimensions
            kernelName<<<gridDims,threadDims>>> (params)

- Grid and block dimensions are declared using variables of predefined type dim3 –with three fields: x, y and z
      * gridDim contains .x and .y grid dimensions (sizes)
      * blockIdx contains block indices .x and .y in the grid
      * blockDim contains the thread block .x, .y, .z dimensions (sizes)
      * threadIdx contains .x, .y and .z thread block indices 
 
    
    
CUDA Appliction structure: 
  - serial code executes in a host(CPU) while Parallel code executes in GPU threads. 
  
![Slide|512x397|10%](Images/gpu.png)


  
  
  
  
  Dissecting GPU Memory Hierarchy through Microbenchmarking: https://arxiv.org/pdf/1509.02308.pdf
  
