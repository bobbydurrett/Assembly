#include <stdio.h>
#include <stdlib.h>
/*

This is chapter 18 exercise 1.

v2 is an assembly version of v1 which is all C

I'm not going to try to use the SIMD instructions for
this one just simple assembly.

*/

#define IMAGE_SIZE 4
#define ITERATIONS 1

unsigned char image[IMAGE_SIZE][IMAGE_SIZE];
unsigned char convoluted_image[IMAGE_SIZE][IMAGE_SIZE];
signed char convolution[3][3];

extern void apply_convolution(unsigned char image[][IMAGE_SIZE],unsigned char convoluted_image[][IMAGE_SIZE],signed char convolution[][3],long image_size);

main()
{
	long i,j;

	for (i=0;i<IMAGE_SIZE;i++)
	    for (j=0;j<IMAGE_SIZE;j++)
		image[i][j]=(i*j)%256;

	for (i=0;i<3;i++)
	    for (j=0;j<3;j++)
	        convolution[i][j]=i-1;

	for (i=0;i<ITERATIONS;i++)
		apply_convolution(image,convoluted_image,convolution,IMAGE_SIZE);

	printf("image 1-3,1-3\n");
	printf("%d %d %d\n",image[1][1],image[2][1],image[3][1]);
	printf("%d %d %d\n",image[1][2],image[2][1],image[3][2]);
	printf("%d %d %d\n",image[1][3],image[2][1],image[3][3]);
	printf("convolution\n");
	printf("%d %d %d\n",convolution[0][0],convolution[1][0],convolution[2][0]);
	printf("%d %d %d\n",convolution[0][1],convolution[1][1],convolution[2][1]);
	printf("%d %d %d\n",convolution[0][2],convolution[1][2],convolution[2][2]);

    printf("convoluted_image[2][2] = %d\n",convoluted_image[2][2]);
}

