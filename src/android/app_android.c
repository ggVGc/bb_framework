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
#include "framework/iap.h"
#include "framework/profiler.h"


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
Java_com_spacekomodo_berrybounce_GLRenderer_nativeOnCursorMove( JNIEnv*  env, jobject this, jint index, jint x, jint y) {
  setCursorPos(index, x, y);
}

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeOnCursorUp( JNIEnv*  env, jobject this, jint index) {
  setCursorDownState(index, 0);
}

    void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeOnCursorDown( JNIEnv*  env, jobject this, jint index) {
  setCursorDownState(index, 1);
}




void startProfiler(){
  /*
  trace("starting profiler");
  monstartup("jumpz_framework.so");
  */
}

void stopProfiler(){
  /*
  trace("stopping profiler");
  setenv("CPUPROFILE", "/data/data/com.spacekomodo.berrybounce/files/gmon.out", 1);
  moncleanup();
  trace("Cleaned up profiler");
  */
}

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeInit( JNIEnv*  env, jobject this, jstring apkPath_ ) {
  trace("nativeInit");
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
  trace("Cleaned up app");
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
  trace("interstitialClosed");
  adInterstitialClosed();
}

  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialDisplayed( JNIEnv*  env, jobject this) {
  trace("interstitialDisplayed");
  adInterstitialDisplayed(1);
}

  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialFailedDisplay( JNIEnv*  env, jobject this) {
  trace("interstitialFailedDisplay");
  adInterstitialDisplayed(0);
}


void
Java_com_spacekomodo_berrybounce_IAP_onPurchaseComplete( JNIEnv*  env, jobject this, jint success) {
  trace("onPurchaseComplete");
  onPurchaseComplete(success);
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
  trace("adShowInterstitial");
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
  trace("facebookPost");
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

int facebookIsShareAvailable(){
  trace("facebookIsShareAvailable");
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "facebookIsShareAvailable", "()I");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  return (*curEnv)->CallIntMethod(curEnv, curThis, mid);
}


void dataStoreGlobalInit(){
}

void dataStoreCommit(const char* dataString){
  trace("dataStoreCommit");
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
  (*curEnv)->DeleteLocalRef(curEnv, s);
}

const char* dataStoreReload(){
  trace("dataStoreReload");
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
  (*curEnv)->DeleteLocalRef(curEnv, s);
  return ret;
}


int userOwnsProduct(const char *id){
  trace("userOwnsProduct");
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return 0;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "userOwnsProduct", "(Ljava/lang/String;)I");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return 0;
  }
  
  jstring s = (*curEnv)->NewStringUTF(curEnv, id);
  int ret = (int)(*curEnv)->CallIntMethod(curEnv, curThis, mid, s);
  (*curEnv)->DeleteLocalRef(curEnv, s);

  return ret;
}

void purchaseProduct(const char *id){
  trace("purchaseProduct");
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "purchaseProduct", "(Ljava/lang/String;)V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  
  jstring s = (*curEnv)->NewStringUTF(curEnv, id);
  (*curEnv)->CallObjectMethod(curEnv, curThis, mid, s);
  (*curEnv)->DeleteLocalRef(curEnv, s);
}

const char* getProductPrice(const char *id){
  trace("getProductPrice");
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "getProductPrice", "(Ljava/lang/String;)Ljava/lang/String;");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  
  jstring s = (*curEnv)->NewStringUTF(curEnv, id);
  jstring fRet = (*curEnv)->CallObjectMethod(curEnv, curThis, mid, s);
  const char *ret = (*curEnv)->GetStringUTFChars(curEnv, fRet, NULL);
  (*curEnv)->DeleteLocalRef(curEnv, s);
  (*curEnv)->DeleteLocalRef(curEnv, fRet);
  return ret;
}

void adSetBannersEnabled(int enable){
  trace("adSetBannersEnabled");
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "setBannersEnabled", "(I)V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  
  (*curEnv)->CallVoidMethod(curEnv, curThis, mid, enable);
}
