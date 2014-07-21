

#include <jni.h>
#include <sys/time.h>
#include <time.h>
#include <android/log.h>
#include <stdint.h>
#include "framework/resource_loading.h"
#include "app.h"
#include "framework/input.h"


static int  sWindowWidth = -1;
static int  sWindowHeight = -1;
static int lastTime = 0;

  static long
_getTime(void)
{
  struct timeval  now;

  gettimeofday(&now, NULL);
  return (long)(now.tv_sec*1000 + now.tv_usec/1000);
}



  void
Java_com_jumpz_frameworktest_GLView_nativeOnCursorMove( JNIEnv*  env, jobject thiz, jint x, jint y)
{
  setCursorPos(x, y);
}

  void
Java_com_jumpz_frameworktest_GLView_nativeOnCursorUp( JNIEnv*  env, jobject thiz)
{
  setCursorDownState(0);
}

    void
Java_com_jumpz_frameworktest_GLView_nativeOnCursorDown( JNIEnv*  env, jobject thiz)
{
  setCursorDownState(1);
}


  void
Java_com_jumpz_frameworktest_GLRenderer_nativeInit( JNIEnv*  env, jobject thiz, jstring apkPath )
{
  const char* path;

  lastTime = _getTime();

  path = (*env)->GetStringUTFChars(env, apkPath, NULL);
  /*loadAPK(path);*/
  appInit(path, 1);
  (*env)->ReleaseStringUTFChars(env, apkPath, path);
}

  void
Java_com_jumpz_frameworktest_GLRenderer_nativeResize( JNIEnv*  env, jobject  thiz, jint w, jint h )
{
  sWindowWidth  = w;
  sWindowHeight = h;
  __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "resize w=%d h=%d", w, h);
}

  void
Java_com_jumpz_frameworktest_GLRenderer_nativeOnStop( JNIEnv*  env )
{
  resourcesCleanUp();
  appDeinit();
}


  void
Java_com_jumpz_frameworktest_GLRenderer_nativeRender( JNIEnv*  env )
{

  long curTime = _getTime();
  
  appRender(curTime - lastTime, sWindowWidth, sWindowHeight);
  lastTime = curTime;

}
