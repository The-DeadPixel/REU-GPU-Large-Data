CFLAGS= -O3 -std=c99 -fp-model precise
LIBRARIES=
CC=icc
OBJS-LIB = TMM.o
all: test_tmm

debug: CFLAGS =-DDEBUG -g -Wall -Wextra -std=c99
debug: all

test_tmm : main.c
	$(CC) main.c -o test_tmm $(CFLAGS) $(LIBRARIES) -L. -ltmm

run: test_tmm
	LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH ./test_tmm

clean:
	rm -f test_tmm
