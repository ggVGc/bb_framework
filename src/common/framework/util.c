#include <stdio.h>
#include <stdarg.h>

void trace(const char* msg) {
  if(msg != 0)
    printf("%s\n", msg);
  else
    printf("%s\n", "null");
}

void traceNoNL(const char* msg) {
  if(msg != 0)
    printf("%s", msg);
  else
    printf("%s", "null");
}

void traceInt(int v) {
  printf("%i\n", v);
}

void traceFmt(const char* fmt, ...) {

char dest[1024 * 16];
    va_list argptr;
    va_start(argptr, fmt);
    vsprintf(dest, fmt, argptr);
    va_end(argptr);
    printf("%s", dest);

}

