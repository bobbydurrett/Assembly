#include <stdint.h>
#include <stdio.h>

/* from https://en.wikipedia.org/wiki/Adler-32 */

const int MOD_ADLER = 65521;

main()
{
    long a = 1, b = 0;
    char buffer[1024];
    int index;
    long checksum;

    while (fgets(buffer,1024,stdin) == buffer)
        {
            /* process one buffer */
            int index = 0;
            while (buffer[index] != '\0')
                {
                    a = (a + buffer[index]) % MOD_ADLER;
                    b = (b + a) % MOD_ADLER;
                    index++;
                }
        }

    checksum = (b << 16) | a;

    printf("Adler-32 checksum of stdin = %ld\n",checksum);
}

