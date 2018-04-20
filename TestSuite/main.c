#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include "tmm_check.h"


/* This is the prototype for the function you have to pass to be called.
 *
 * Two options are available to you:
 *
 * 1) Using 2D matrices
 *
 * A, B and C are created as double-dimension arrays (float**)
 * where:
 * - A[i] is a pointer to a float* array (line i of matrix A)
 * - A[i][j] is the value of A(i,j)
 * - i = 0 to N-1, j = 0 to N-1
 * - A and B are UPPER triangular (you SHOULD write down what it means
 *   in terms of domains : which (i,j)s are valid ?)
 *
 * If you're using GPU, you should consider using linear disposition.
 *
 * 2) Using flattened matrices (linear disposition)
 *
 * A, B and C are created as single-dimension arrays (float*)
 * where:
 * - A[i] is A(0,0)
 * - The value of A(i,j) is accessed through A[i * N + j]
 * - i = 0 to N-1, j = 0 to N-1
 * - A and B are UPPER triangular (you SHOULD write down what it means
 *   in terms of domains : which (i,j)s are valid ?)
 *
 * The following TMM functions have the prototypes called by the checker.
 * Do NOT change them. Call your own TMM function from there.
 *
 * Remember to set in main():
 * c.disposition = DISPOSITION_LINEAR or DISPOSITION_2D depending on your
 * implementation.
 *
 * In order to run the program, you have to run:
 *
 * LD_LIBRARY_PATH=. ./test_tmm
 *
 * A convenience command is provided for you: you can run "make run" as well.
 *
 * */
void TMM2D(long N, float** A, float** B, float** C)
{

	struct timeval time;
	double elapsed_time;

	gettimeofday(&time, NULL);
	elapsed_time = (((double) time.tv_sec) + ((double) time.tv_usec)/1000000);

	// Call your own TMM here //

	gettimeofday(&time, NULL);
	elapsed_time = (((double) time.tv_sec) + ((double) time.tv_usec)/1000000) - elapsed_time;

	// timing information
	printf("Execution time : %lf sec.\n", elapsed_time);
}

void TMMlin(long N, float* A, float* B, float* C)
{

	struct timeval time;
	double elapsed_time;

	gettimeofday(&time, NULL);
	elapsed_time = (((double) time.tv_sec) + ((double) time.tv_usec)/1000000);

	// Call your own TMM here //

	gettimeofday(&time, NULL);
	elapsed_time = (((double) time.tv_sec) + ((double) time.tv_usec)/1000000) - elapsed_time;

	// timing information
	printf("Execution time : %lf sec.\n", elapsed_time);
}


int main(void)
{
	tmm_check c;
	c.N = 100; // Set the size you want to test against here

	// set according to your disposition

	// c.disposition = DISPOSITION_LINEAR;
	// c.disposition = DISPOSITION_2D;

	c.TMM2D = &TMM2D;
	c.TMMlin = &TMMlin;

	int ret = check_TMM(c);
	if(ret)
		printf("Check TMM FAILED!\n");
	else
		printf("Check TMM SUCCEEDED!\n");

	return ret;

}
