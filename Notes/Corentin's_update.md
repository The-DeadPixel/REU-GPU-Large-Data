
I sent you an email with information on how to run the test suite. I mae
a mistake in the line you have to type: the corect line is

source /s/parsons/l/sys/intel/bin/iccvars.sh intel64

Then, some additional precisions:
- You have to modify the makefile so that your own sources are compiled
as well. Othewise, only main.c is compiled and your code is not, and you
will most likely get linker errors.
- If you are using CUDA, you will need to follow the CUDA FAQ available
on the CS Department's website to get the correct environment.
You will have to modify a line in the makefile that compiles main.c by
adding: -L/usr/local/cuda/lib64 -lcudart
- Modify one of the two functions only in main.c depending on which
representation you chose for the matrices (A, B, C). Those are already
allocated for you, you can directly work with them. If you were in
doubt, the formula to compute is C = A * B.
- The test suite is written with a somewhat naive algorithm and does a
TMM as well on the same matrices as the one your program is supposed to
run. Thus, don't run it with too big problem sizes.

If you encounter issues with the test suite or if it's not giving you
relevant information, feel free to contact me by e-mail or by dropping
by my office, 335 desk 8.
