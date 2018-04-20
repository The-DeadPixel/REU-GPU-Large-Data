#CFLAGS= -O3 -std=c99 -fp-model precise
#LIBRARIES=
#CC=icc
#OBJS-LIB = TMM.o

C_SRCS = main.c
C_OBJS = main.o TilingProgram.o
#C Headers
OBJS = ${C_OBJS}
EXEC = test_tmm
DEP = tmm_check.h

#compiler and loader commands and flags
GCC = gcc
GCC_FLAGS = -std=gnu99 -g -Wall -c -I.
LD_FLAGS = -g -I. -lcudart
OPTIONS := -O3 --ptxas-options -v --gpu-architecture=sm_61 --compiler-bindir /usr/local/gcc-4.6.3/bin/gcc


all: $(EXEC)

debug: CFLAGS =-DDEBUG -g -Wall -Wextra -std=c99
debug: all

test_tmm : $(OBJS)
        $(GCC) -o $(EXEC) $(LD_FLAGS) $(LIBRARIES) $(OBJS) -L -ltmm -L/usr/local/cuda/lib64 -lcudart

TilingProgram.o: TilingProgram.cu
        nvcc $< -c -o $@ $(OPTIONS) -lcudart

main.o: main.c $(DEP)
        $(GCC) $(LD_FLAGS) -c main.c

run: test_tmm
	LD_LIBRARY_PATH=.:$$LD_LIBRARY_PATH ./test_tmm

clean:
      	rm -f test_tmm

