#include <android/log.h>
#include <stdarg.h>

void trace(const char* msg) {
  /*int i;*/
  /*int len = strlen(msg);*/
  /*if(len<1000){*/
    __android_log_print(ANDROID_LOG_INFO, "trace", "%s", msg);
  /*}else{*/

  /*}*/
}

void traceFmt(const char* fmt, ...) {
  va_list argptr;
  va_start(argptr,fmt);
  __android_log_print(ANDROID_LOG_INFO, "trace", fmt, argptr);
  va_end(argptr);
}

void traceInt(int v) {
  __android_log_print(ANDROID_LOG_INFO, "trace","%d", v);
}

void traceNoNL(const char *v) {
  trace(v);
}
