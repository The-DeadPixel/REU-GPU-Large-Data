
To set the environment variable in Bash terminals, use the following commands:
    export PATH=/usr/local/cuda-7.5/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/cuda-7.5/lib64:$LD_LIBRARY_PATH
    
To compile: hello_world example:  nvcc HelloWorld.cu -o hello


TMM testing Prog: [Corentin's test code](https://github.com/cferr/tmm_tests.git)

  You have to source the Intel C++ compiler variables prior to compiling the test suite (updated) :
  
              source /s/parsons/l/sys/intel/bin/iccvars.sh intel64
 
 Then, some additional details:
   * You have to modify the makefile so that your own sources are compiled as well. Othewise, only main.c is compiled and your code is not, and you will most likely get linker errors.
   * You will have to modify a line in the makefile that compiles main.c by adding: -L/usr/local/cuda/lib64 -lcudart
   * Modify one of the two functions only in main.c depending on which representation you chose for the matrices (A, B, C).          Those are already allocated for you, you can directly work with them. If you were in doubt, the formula to compute is C = A * B.
   * The test suite is written with a somewhat naive algorithm and does a TMM as well on the same matrices as the one your   program is supposed to run. Thus, don't run it with too big problem sizes.


