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
bigposint_to_string(struct bigposint *bigptr,char *buffer)
{
int charswritten,bufferlocation;
long i;

bufferlocation = 0;

for (i=(bigptr->numqwords)-1;i>=0;i--)
{

	if (i == ((bigptr->numqwords)-1))
	    charswritten=sprintf(buffer+bufferlocation,"%ld",bigptr->qwords[i]);
	else
	    charswritten=sprintf(buffer+bufferlocation,"%018ld",bigptr->qwords[i]);

	bufferlocation = bufferlocation + charswritten;
}

}

void
print_bigposint(char *prefix,struct bigposint *bigptr)
{
	char output[10000];
    bigposint_to_string(bigptr,output);
    printf("%s%s\n",prefix,output);
}

void
set_bigposint(struct bigposint *bigptr,long value)
{
	bigptr->numqwords = 1;
	bigptr->qwords[0] = value;
	bigptr->qwords[1] = 0;
	bigptr->qwords[2] = 0;
	bigptr->qwords[3] = 0;
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

main()
{
struct bigposint big;
char output[10000];
long i;

set_bigposint(&big,50); /* start at 50 for 50! */

/* loop through rest of numbers < 50 for 50! */

for (i=49;i>0;i--)
{
	mult_bigposit(&big,i);
}

print_bigposint("50! = ",&big);

}

