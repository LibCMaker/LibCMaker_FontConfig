// See TestLargeFiles.cmake for the origin of this file

#include <sys/types.h>

int main(int argc, char **argv)
{
  /* Cause a compile-time error if off_t is smaller than 64 bits */
#define LARGE_OFF_T (((off_t) 1 << 62) - 1 + ((off_t) 1 << 62))
  int off_t_is_large[ (LARGE_OFF_T % 2147483629 == 721 && LARGE_OFF_T % 2147483647 == 1) ? 1 : -1 ];
  return 0;
}
