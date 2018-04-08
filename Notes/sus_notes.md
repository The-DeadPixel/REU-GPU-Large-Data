GPU Architecture
  1. Glolbal Memory - used by both cpu and gpu (analogous to ram in a cpu server)
  2. Streaming Multiprocessors (SMs) - performs the actual computations 
    * each SM has its own control units, registers, execution pipelines, caches
    
CUDA Appliction structure: 
  - serial code executes in a host(CPU) while Parallel code executes in GPU threads. 
  
  ![Slide](REU-GPU-Large-Data/Notes/Images/gpu.png "Description goes here")
  
  
  
  
  
  
  Dissecting GPU Memory Hierarchy through Microbenchmarking: https://arxiv.org/pdf/1509.02308.pdf
  
