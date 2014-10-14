#include <android/log.h>

void trace(const char* msg) {
  /*int i;*/
  /*int len = strlen(msg);*/
  /*if(len<1000){*/
    __android_log_print(ANDROID_LOG_INFO, "trace", "%s", msg);
  /*}else{*/

  /*}*/
}

void traceInt(int v) {
  __android_log_print(ANDROID_LOG_INFO, "trace","%d", v);
}

void traceNoNL(const char *v) {
  trace(v);
}
