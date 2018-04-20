#ifndef _TMM_CHECK_H
#define _TMM_CHECK_H


enum matrix_disposition {
	DISPOSITION_LINEAR,
	DISPOSITION_2D
};

typedef struct tmm_check {
	long N;
	enum matrix_disposition disposition;
	void (*TMMlin)(long, float*, float*, float*);    // if linear
	void (*TMM2D)(long, float**, float**, float**);  // if 2D
} tmm_check;

int check_TMM(tmm_check checker_function);

#endif
