#include <jni.h>
#include <sys/time.h>
#include <time.h>
#include <android/log.h>
#include <stdint.h>
#include "framework/resource_loading.h"
#include "app.h"
#include "framework/input.h"
#include "framework/facebook.h"
#include "framework/data_store.h"


static int lastTime = 0;
static int didInit = 0;
static const char *apkPath;

  static long
_getTime(void) {
  struct timeval  now;
  gettimeofday(&now, NULL);
  return (long)(now.tv_sec*1000 + now.tv_usec/1000);
}

  void
Java_com_spacekomodo_berrybounce_GLView_nativeOnCursorMove( JNIEnv*  env, jobject this, jint x, jint y) {
  setCursorPos(x, y);
}

  void
Java_com_spacekomodo_berrybounce_GLView_nativeOnCursorUp( JNIEnv*  env) {
  setCursorDownState(0);
}

    void
Java_com_spacekomodo_berrybounce_GLView_nativeOnCursorDown( JNIEnv*  env) {
  setCursorDownState(1);
}

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeInit( JNIEnv*  env, jobject this, jstring apkPath_ ) {
  apkPath = (*env)->GetStringUTFChars(env, apkPath_, NULL); // Let's leak some memory..
  lastTime = _getTime();
  didInit = 0;
}

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeResize( JNIEnv*  env, jobject  this, jint w, jint h ) {
  if(didInit != 1){
    setScreenWidth(w);
    setScreenHeight(h);
    appInit(w, h, apkPath, 1);
    didInit = 1;
  }
  __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "resize w=%d h=%d", w, h);
}

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeOnStop( JNIEnv*  env ) {
  resourcesCleanUp();
  appDeinit();
}


static jobject curThis;
static JNIEnv* curEnv;

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeRender( JNIEnv*  env, jobject this) {
  curEnv = env;
  curThis = this;
  long curTime = _getTime();
  appRender(curTime - lastTime);
  lastTime = curTime;
}


  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialClosed( JNIEnv*  env, jobject this) {
  adInterstitialClosed();
}

  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialDisplayed( JNIEnv*  env, jobject this) {
  adInterstitialDisplayed(1);
}

  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialFailedDisplay( JNIEnv*  env, jobject this) {
  adInterstitialDisplayed(0);
}


void adPrepareInterstitial(){
  /*
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "prepareInterstitial", "()V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  (*curEnv)->CallVoidMethod(curEnv, curThis, mid);
  */
}

void adShowInterstitial(){
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "showInterstitial", "()V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  (*curEnv)->CallVoidMethod(curEnv, curThis, mid);
}

void facebookPost(){
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "facebookPost", "()V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  (*curEnv)->CallVoidMethod(curEnv, curThis, mid);
}

void dataStoreGlobalInit(){
}

void dataStoreCommit(const char* dataString){
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "dataStoreCommit", "(Ljava/lang/String;)V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  jstring s = (*curEnv)->NewStringUTF(curEnv, dataString);
  (*curEnv)->CallVoidMethod(curEnv, curThis, mid, s);
  /*(*curEnv)->DeleteLocalRef(curEnv, s);*/

}

const char* dataStoreReload(){
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "dataStoreReload", "()Ljava/lang/String;");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  jstring s = (*curEnv)->CallObjectMethod(curEnv, curThis, mid);
  const char *ret = (*curEnv)->GetStringUTFChars(curEnv, s, NULL);
  /*(*curEnv)->DeleteLocalRef(curEnv, s);*/
  return ret;
}
