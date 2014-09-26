#include <android/log.h>

void trace(const char* msg)
{
  __android_log_print(ANDROID_LOG_INFO, "trace", "%s", msg);
}
void traceInt(int v)
{
  __android_log_print(ANDROID_LOG_INFO, "trace","%d", v);
}
void traceNoNL(const char *v)
{
  __android_log_print(ANDROID_LOG_INFO, "trace","%s", v);
}
