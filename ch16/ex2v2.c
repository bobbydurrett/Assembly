#include <stdio.h>
#include <math.h>

/*

Multiply N by 4 matrix times 4 element vector.

real    0m3.831s
user    0m3.709s
sys     0m0.115s

with N=100000000

*/

#define N 100000000

float matrix[N][4];
float vector[4];
float mv[N];

extern void calc_mv(long n,float matrix[][4],float vector[],float mv[]);

main()
{
	long i;

/* simple fast initialization */

	for (i=0;i<N;i++)
	    matrix[i][0]=matrix[i][1]=matrix[i][2]=matrix[i][3]=i;

	vector[0]=vector[1]=vector[2]=vector[3]=5.0;

    for (i=0;i<20;i++)
	    calc_mv(N,matrix,vector,mv);

/*	for (i=0;i<N;i++)
        printf("mv[%ld]=%f\n",i,mv[i]); */

}

