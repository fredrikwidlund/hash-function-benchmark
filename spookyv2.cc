#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <err.h>
#include <sys/time.h>

#include "SpookyV2.h"

uint64_t ntime()
{
  struct timeval tv;

  (void) gettimeofday(&tv, NULL);
  return ((uint64_t) tv.tv_sec * 1000000000) + ((uint64_t) tv.tv_usec * 1000);
}

int main(int argc, char **argv)
{
  unsigned int begin = strtol(argv[1], NULL, 0);
  unsigned int end = strtol(argv[2], NULL, 0);
  unsigned int inc = strtol(argv[3], NULL, 0);
  uint64_t i, t1, t2, h = 0, n = 10000000, h1, h2;
  float t;
  size_t len;
  char *in = (char *) malloc(end);

  for (i = 0; i < end; i ++)
    in[i] = rand() % 255 + 1;
  
  for (len = begin; len < end; len += inc)
    {
      t1 = ntime();
      for (i = 0; i < n; i ++)
        {
          h1 = 0;
          h2 = 0;
          SpookyHash::Hash128(in, len, &h1, &h2);
          h ^= h2;
        }
      t2 = ntime();
      if (h != 0)
        err(1, "invalid result");
      
      t = (float) (t2 - t1) / 1000000000;
      
      printf("size %ld, Mops %.0f, throughput %.0f MB/s\n", len, (float) n / t / 1000000, (float) (len * n) / t / 1000000);
    }
  
  free(in);
}
