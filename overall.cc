// g++ -O3 -o overall overall.cc -march=native -Wall -Wextra
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>
#include <err.h>
#include <sys/time.h>

#include "support/clhash.c"
#include "support/cfarmhash.c"
#include "support/MurmurHash3.cpp"

#define RDTSC_START(cycles)                                                    \
  do {                                                                         \
    register unsigned cyc_high, cyc_low;                                       \
    __asm volatile("cpuid\n\t"                                                 \
                   "rdtsc\n\t"                                                 \
                   "mov %%edx, %0\n\t"                                         \
                   "mov %%eax, %1\n\t"                                         \
                   : "=r"(cyc_high), "=r"(cyc_low)::"%rax", "%rbx", "%rcx",    \
                     "%rdx");                                                  \
    (cycles) = ((uint64_t)cyc_high << 32) | cyc_low;                           \
  } while (0)

#define RDTSC_FINAL(cycles)                                                    \
  do {                                                                         \
    register unsigned cyc_high, cyc_low;                                       \
    __asm volatile("rdtscp\n\t"                                                \
                   "mov %%edx, %0\n\t"                                         \
                   "mov %%eax, %1\n\t"                                         \
                   "cpuid\n\t"                                                 \
                   : "=r"(cyc_high), "=r"(cyc_low)::"%rax", "%rbx", "%rcx",    \
                     "%rdx");                                                  \
    (cycles) = ((uint64_t)cyc_high << 32) | cyc_low;                           \
  } while (0)

#define CLOBBER_MEMORY __asm volatile("" ::: /* pretend to clobber */ "memory")

#define BEST_TIME(test, answer, repeat, size, verbose)                         \
  do {                                                                         \
    if (verbose)                                                               \
      printf("%s: ", #test);                                                   \
    fflush(NULL);                                                              \
    uint64_t cycles_start, cycles_final, cycles_diff;                          \
    uint64_t min_diff = (uint64_t)-1;                                          \
    int wrong_answer = 0;                                                      \
    for (int i = 0; i < repeat; i++) {                                         \
      CLOBBER_MEMORY;                                                          \
      RDTSC_START(cycles_start);                                               \
      if (test != answer)                                                      \
        wrong_answer = 1;                                                      \
      RDTSC_FINAL(cycles_final);                                               \
      cycles_diff = (cycles_final - cycles_start);                             \
      if (cycles_diff < min_diff)                                              \
        min_diff = cycles_diff;                                                \
    }                                                                          \
    uint64_t S = (uint64_t)size;                                               \
    float cycle_per_op = (min_diff) / (float)S;                                \
    if (verbose)                                                               \
      printf(" %.2f cycles per input byte", cycle_per_op);                     \
    if (!verbose)                                                              \
      printf(" %.2f ", cycle_per_op);                                          \
    if (wrong_answer)                                                          \
      printf(" [ERROR]");                                                      \
    if (verbose)                                                               \
      printf("\n");                                                            \
    fflush(NULL);                                                              \
  } while (0)

uint64_t murmur64(const char *input, int len) {
  static uint64_t out[2];
  MurmurHash3_x64_128(input, len, 0, out);
  return out[0];
}

int main() {
  printf("# numberofbytes clashbytesperinput murmurbytesperinput "
         "farmhashbytesperinput \n");
  for (int N = 8; N <= 1024; N++) {
    printf("%d   ", N);
    char *input = (char *)malloc(N); // input data
    for (int i = 0; i < N; i++) {
      input[i] = (char)i; // could be randomized
    }
    void *clhashrandom = get_random_key_for_clhash(
        UINT64_C(0x23a23cf5033c3c81), UINT64_C(0xb3816f6a2c68e530));
    uint64_t clhashexpected = clhash(clhashrandom, input, N);
    uint64_t murmurexpected = murmur64(input, N);
    uint64_t farmexpected = cfarmhash(input, N);
    const int repeat = 5;
    const bool verbose = false;
    BEST_TIME(clhash(clhashrandom, input, N), clhashexpected, repeat, N,
              verbose);
    BEST_TIME(murmur64(input, N), murmurexpected, repeat, N, verbose);
    BEST_TIME(cfarmhash(input, N), farmexpected, repeat, N, verbose);
    printf("\n");
    free(input);
    free(clhashrandom);
  }
  printf("# We report the number of cycles per input bytes for inputs over various sizes \n");

}
