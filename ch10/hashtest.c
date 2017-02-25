#include <stdio.h>

long multipliers[] = {
    123456789,
    234567891,
    345678912,
    456789123,
    567891234,
    678912345,
    789123456,
    891234567
};

int collisions[99991];

int counts[1000];

int hash ( unsigned char *s )
{
    unsigned long h = 0;
    int i = 0;

    while ( s[i] ) {
        h = h + s[i] * multipliers[i%8];
        i++;
    }
    return h % 99991;
}

void get_collisions ()
{
   int i;
   int h;
   unsigned char s[80];
/* initialize collisions for -1 for no entries hashed
   0 means one entry hashed
   > 0 is number of collisions */
   for (i=0; i < 99991; i++) {
       collisions[i] = -1;
   }
/* read text getting hash values */

   while (scanf("%79s",s)==1) {
       h = hash(s);
       collisions[h]++;
   }
}

void print_counts ()
{
   int i;
   int k;

   for (i=0; i < 1000; i++) {
       counts[i] = 0;
   }

   for (i=0; i < 99991; i++) {
       k = collisions[i];
       if (k > 999) k = 999;
       if (k < 0) k = 0;
       counts[k]++;
   }

   for (i=0; i < 1000; i++) {
       if ( counts[i] > 0 ) {
           printf("There were %d entries with %d collisions.\n",counts[i],i);
       }
   }
}

main()
{
    get_collisions();
    print_counts();
}

