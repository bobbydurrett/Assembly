#include <stdio.h>
#include <math.h>

/*

Multiply N by 4 matrix times 4 element vector.

real    0m11.340s
user    0m11.223s
sys     0m0.110s

with N=100000000

*/

#define N 10

float matrix[N][4];
float vector[4];
float mv[N];

void
calc_mv(long n,float matrix[][4],float vector[],float mv[])
{
long i;

for (i=0;i<n;i++)
    mv[i]=matrix[i][0]*vector[0]+matrix[i][1]*vector[1]+matrix[i][2]*vector[2]+matrix[i][3]*vector[3];
}

main()
{
	long i;

/* simple fast initialization */

	for (i=0;i<N;i++)
	    matrix[i][0]=matrix[i][1]=matrix[i][2]=matrix[i][3]=i;

	vector[0]=vector[1]=vector[2]=vector[3]=5.0;

    for (i=0;i<20;i++)
	    calc_mv(N,matrix,vector,mv);

	for (i=0;i<N;i++)
        printf("mv[%ld]=%f\n",i,mv[i]);

}

