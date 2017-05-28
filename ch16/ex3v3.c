#include <stdio.h>
#include <math.h>

/*

Multiply two matrixes.

For simplicity I'm using two square matrixes of dimensions 2Nx2N.
V1 will just do simple calculations using C only and loops.
Later versions will break up the matrixes into four NxN matrixes each to
see if caching can improve run time using block matrix multiplication.

v3 splits the two matrixes into four equal sized blocks and does
block matrix multiplication.

*/

#define N 2

float matrix1[2*N][2*N];
float matrix2[2*N][2*N];
float result[2*N][2*N];

extern void block_matrix_multiply(long n,float matrix1[][2*N],float matrix2[][2*N],float result[][2*N]);

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


    block_matrix_multiply((2*N),matrix1,matrix2,result);

    print_matrix("matrix1",matrix1);
    print_matrix("matrix2",matrix2);
    print_matrix("result",result);

    return 0;
}

