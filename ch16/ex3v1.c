#include <stdio.h>
#include <math.h>

/*

Multiply two matrixes.

For simplicity I'm using two square matrixes of dimensions 2Nx2N.
V1 will just do simple calculations using C only and loops.
Later versions will break up the matrixes into four NxN matrixes each to
see if caching can improve run time using block matrix multiplication.

time with N=1000

real    0m43.602s
user    0m43.566s
sys     0m0.006s

time with N=500

real    0m5.855s
user    0m5.847s
sys     0m0.004s

time with N=250

real    0m0.575s
user    0m0.574s
sys     0m0.001s

*/

#define N 250

float matrix1[2*N][2*N];
float matrix2[2*N][2*N];
float result[2*N][2*N];

void
matrix_multiply(long n,float matrix1[][2*N],float matrix2[][2*N],float result[][2*N])
{
long i,j,k;

for (i=0;i<n;i++)
    for (j=0;j<n;j++)
    {
        result[i][j] = 0;
        for (k=0;k<n;k++)
        {
            result[i][j] += (matrix1[i][k]*matrix2[k][j]);
		}
	}

}

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

