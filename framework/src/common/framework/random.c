#include <stdlib.h>
#include "random.h"


void randomSeed(int s)
{
  srand(s);
}

int randomRandom(void)
{
  return rand();
}
