#include <stdio.h>
#include <math.h>

/*

Multiply two matrixes.

For simplicity I'm using two square matrixes of dimensions 2Nx2N.
V1 will just do simple calculations using C only and loops.
Later versions will break up the matrixes into four NxN matrixes each to
see if caching can improve run time using block matrix multiplication.

v2 is using assembly for the matrix_multiply routine without splitting
the matrix into blocks.

With N=1000

real    0m28.028s
user    0m28.005s
sys     0m0.006s

N=500

real    0m3.707s
user    0m3.703s
sys     0m0.001s

N=250

real    0m0.387s
user    0m0.386s
sys     0m0.001s

*/

#define N 250

float matrix1[2*N][2*N];
float matrix2[2*N][2*N];
float result[2*N][2*N];

extern void matrix_multiply(long n,float matrix1[][2*N],float matrix2[][2*N],float result[][2*N]);

void
print_matrix(char *name,float matrix[][2*N])
{
	long i,j;
	printf("%s\n",name);
    for (i=0;i<(2*N);i++)
    {
		for (j=0;j<(2*N);j++)
		    printf("%f ",matrix[i][j]);
		printf("\n");
    }
}

main()
{
	long i,j;

/* simple fast initialization */

	for (i=0;i<(2*N);i++)
	    for (j=0;j<(2*N);j++)
			matrix1[i][j]=matrix2[i][j]=i+j;


    matrix_multiply((2*N),matrix1,matrix2,result);

/*    print_matrix("matrix1",matrix1);
    print_matrix("matrix2",matrix2);
    print_matrix("result",result); */

    return 0;
}

