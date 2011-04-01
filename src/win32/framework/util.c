
#include <stdio.h>

void trace(const char* msg)
{
  if(msg != 0)
    printf("%s\n", msg);
  else
    printf("%s\n", "null");
}

void traceInt(int v)
{
  printf("%i\n", v);
}

