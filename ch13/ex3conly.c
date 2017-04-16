#include <stdio.h>

/*

Chapter 13 Exercise 3

Big positive integer structure to compute 50!.

Writing this first in C then rewrite some functions in assembly later.

This is 64 bit C so a long is 64 bits which is a qword in assembly.

*/

struct bigposint
{
	long numqwords; /* number of qwords in array that are in use */
	long qwords[4]; /* 50! fits in 4 qwords so use array for 4 longs */
};

void
set_bigposint(struct bigposint *bigptr,long value)
{
	bigptr->numqwords = 1;
	bigptr->qwords[0] = value;
}

void
add_bigposit(struct bigposint *targetptr,struct bigposint *sourceptr)
{
long maxi,x,extra,tentothe18,i;

tentothe18 = 1000000000000000000;

if ((targetptr->numqwords) > (sourceptr->numqwords))
    maxi = targetptr->numqwords;
else
    maxi = sourceptr->numqwords;

for (i=1;i<=maxi;i++)
{
	x = targetptr->qwords[i-1]+sourceptr->qwords[i-1];
	if (i < 4)
	{
		extra = x/tentothe18;
		if (extra > 0)
		{
			x = x - (extra * tentothe18);
			targetptr->qwords[i] = targetptr->qwords[i] + extra;
			if ((i+1) > maxi)
			{
			    targetptr->numqwords = i+1;
			}
	    }
    }
    targetptr->qwords[i-1] = x;
}

}

void
mult_bigposit(struct bigposint *bigptr,long small)
{
	struct bigposint curval;
	long i;
	set_bigposint(&curval,0);
	add_bigposit(&curval,bigptr); /* set curval to bigptr value */
	for (i=1;i < small;i++) /* add small-1 times */
		add_bigposit(bigptr,&curval);
}

void
bigposint_to_string(struct bigposint *bigptr,char *buffer)
{
int charswritten,bufferlocation,i;

bufferlocation = 0;

for (i=0;i<(bigptr->numqwords);i++)
{
	charswritten=sprintf(buffer+bufferlocation,"%s",bigptr->qwords[i]);
	bufferlocation = bufferlocation + charswritten - 1;
}

}

main()
{
struct bigposint big;
char output[80];
long i;

set_bigposint(&big,50); /* start at 50 for 50! */

/* loop through rest of numbers < 50 for 50! */

for (i=49;i>0;i--)
	mult_bigposit(&big,i);

bigposint_to_string(&big,output);

printf("50! = %s\n",output);
}

