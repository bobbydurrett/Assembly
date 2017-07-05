#include <stdio.h>
#include <stdlib.h>
/*

This is chapter 18 exercise 1.
The book says to change the Sobel Filter code to do an arbitrary convolution on an image.
I'm not completely clear about what that means but I'm going to use this C version to define
what I'm writing and then write assembly versions to try to go faster.

My idea is to take a two dimensional array of unsigned characters - bytes - as an image.
Then I have a 3 by 3 array of unsigned characters as the convolution.

The program will multiply the 9 integers in the 3x3 array by the 9 integers surrounding each pixel
(each entry in the image array) and put the result in an output array of the same size as the image.

I'm just going to skip the edge pixels and leave the output 0 on the edges.

#define IMAGE_SIZE 1000
#define ITERATIONS 500

real    0m16.409s
user    0m16.398s
sys     0m0.002s

*/

#define IMAGE_SIZE 1000
#define ITERATIONS 500

unsigned char image[IMAGE_SIZE][IMAGE_SIZE];
unsigned char convoluted_image[IMAGE_SIZE][IMAGE_SIZE];
signed char convolution[3][3];

void
apply_convolution(unsigned char image[][IMAGE_SIZE],unsigned char convoluted_image[][IMAGE_SIZE],signed char convolution[][3],long image_size)
{
	long i,j,k,m,temp;

	for (i=1;i<(image_size-1);i++)
	    for (j=1;j<(image_size-1);j++)
	    {
			temp=0;
	        for (k=0;k<3;k++)
	            for (m=0;m<3;m++)
	            {
					temp += (image[i+k-1][j+m-1])*(convolution[k][m]);
				}
			if (temp > 255)
			    temp = 255;
			if (temp < 0)
				temp = 0;
			convoluted_image[i][j]=temp;
		}
}

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

	printf("image\n");
	printf("%d %d %d %d\n",image[0][0],image[1][0],image[2][0],image[3][0]);
	printf("%d %d %d %d\n",image[0][1],image[1][1],image[2][1],image[3][1]);
	printf("%d %d %d %d\n",image[0][2],image[1][2],image[2][2],image[3][2]);
	printf("%d %d %d %d\n",image[0][3],image[1][3],image[2][3],image[3][3]);

	printf("convolution\n");
	printf("%d %d %d\n",convolution[0][0],convolution[1][0],convolution[2][0]);
	printf("%d %d %d\n",convolution[0][1],convolution[1][1],convolution[2][1]);
	printf("%d %d %d\n",convolution[0][2],convolution[1][2],convolution[2][2]);

    printf("convoluted_image\n");
	printf("%d %d %d %d\n",convoluted_image[0][0],convoluted_image[1][0],convoluted_image[2][0],convoluted_image[3][0]);
	printf("%d %d %d %d\n",convoluted_image[0][1],convoluted_image[1][1],convoluted_image[2][1],convoluted_image[3][1]);
	printf("%d %d %d %d\n",convoluted_image[0][2],convoluted_image[1][2],convoluted_image[2][2],convoluted_image[3][2]);
	printf("%d %d %d %d\n",convoluted_image[0][3],convoluted_image[1][3],convoluted_image[2][3],convoluted_image[3][3]);
}

