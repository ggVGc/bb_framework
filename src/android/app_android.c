#include <jni.h>
#include <sys/time.h>
#include <time.h>
#include <android/log.h>
#include <stdint.h>
#include <string.h>
#include "framework/resource_loading.h"
#include "app.h"
#include "framework/input.h"
#include "framework/facebook.h"
#include "framework/data_store.h"
#include "framework/iap.h"
#include "framework/profiler.h"


static time_t lastTime = 0;
static int didInit = 0;
static const char *apkPath;
JavaVM  *jvm;
static int shouldInit = 0;
static int initW = 0;
static int initH = 0;
static int initWasSuspended = 0;


  static time_t
_getTime(void) {
  struct timeval  now;
  gettimeofday(&now, NULL);
  return now.tv_sec*1000 + now.tv_usec/1000;
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
Java_com_spacekomodo_berrybounce_MainActivity_preInit(JNIEnv*  env, jobject this, jstring apkPath_ ) {
  trace("Android: preInit");
  (*env)->GetJavaVM(env, &jvm);
  apkPath = (*env)->GetStringUTFChars(env, apkPath_, NULL); // Let's leak some memory..
  if(!PHYSFS_init(NULL)){
    trace("PhysFs: Init failed");
    traceInt(PHYSFS_getLastErrorCode());
    trace(PHYSFS_getLastError());
  }
}

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeInit( JNIEnv*  env, jobject this) {
  trace("Android: nativeInit");
  (*env)->GetJavaVM(env, &jvm);
  lastTime = _getTime();
  didInit = 0;
  shouldInit = 0;
}


  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeResize( JNIEnv*  env, jobject  this, jint w, jint h, jint wasSuspended) {
  __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "resize w=%d h=%d", w, h);
  if(didInit != 1){
    initW = w;
    initH = h;
    initWasSuspended = wasSuspended;
    shouldInit = 1;
  }
}


  void
Java_com_spacekomodo_berrybounce_GLRenderer_appGraphicsReload( JNIEnv*  env, jobject  this, jint w, jint h, jint wasSuspended) {
  trace("Android: appGraphicsReload");
  appGraphicsReload(w, h);
}

  void
Java_com_spacekomodo_berrybounce_GLView_appSetPaused( JNIEnv*  env, jobject this, jint paused, jint pauseAudio) {
  trace("Android: appSetPaused");
  appSetPaused(paused, pauseAudio);
}


  void
Java_com_spacekomodo_berrybounce_GLView_appSuspend( JNIEnv*  env ) {
  trace("Android: appSuspend");
  appSuspend();
}

  void
Java_com_spacekomodo_berrybounce_GLView_nativeOnStop( JNIEnv*  env ) {
  trace("Android: Cleaning up");
  appDeinit();
  trace("Android: Cleaned up");
}


static jobject curThis;
static JNIEnv* curEnv;
/*static JavaVM *jvm;*/

  void
Java_com_spacekomodo_berrybounce_GLRenderer_nativeRender( JNIEnv*  env, jobject this) {
  curEnv = env;
  curThis = this;
  if(shouldInit){
    trace("Android: appInit");
    setScreenWidth(initW);
    setScreenHeight(initH);
    appInit(initWasSuspended, initW, initH, apkPath);
    didInit = 1;
    shouldInit = 0;
  }
  /*(*curEnv)->GetJavaVM(curEnv, &jvm);*/
  time_t curTime = _getTime();
  appRender(curTime - lastTime);
  lastTime = curTime;
}


static int screenRefreshRate = 60;

int getScreenRefreshRate(){
  return screenRefreshRate;
}

void
Java_com_spacekomodo_berrybounce_MainActivity_setScreenRefreshRate( JNIEnv*  env, jobject this, jint rate) {
  if(rate >= 30&&rate<=120){
    screenRefreshRate = rate;
  }
}

  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialClosed( JNIEnv*  env, jobject this) {
  trace("Android: interstitialClosed");
  adInterstitialClosed();
}

  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialDisplayed( JNIEnv*  env, jobject this) {
  trace("Android: interstitialDisplayed");
  adInterstitialDisplayed(1);
}

  void
Java_com_spacekomodo_berrybounce_MainActivity_interstitialFailedDisplay( JNIEnv*  env, jobject this) {
  trace("Android: interstitialFailedDisplay");
  adInterstitialDisplayed(0);
}


void
Java_com_spacekomodo_berrybounce_IAP_onPurchaseComplete( JNIEnv*  env, jobject this, jint success) {
  trace("Android: onPurchaseComplete");
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
  trace("Android: adShowInterstitial");
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

void facebookPost(int score){
  trace("Android: facebookPost");
  jclass cls = (*curEnv)->GetObjectClass(curEnv, curThis);
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*curEnv)->GetMethodID(curEnv, cls, "facebookPost", "(I)V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  (*curEnv)->CallVoidMethod(curEnv, curThis, mid, score);
}

int facebookIsShareAvailable(){
  trace("Android: facebookIsShareAvailable");
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
  trace("Android: dataStoreCommit");
  JNIEnv *env;
  (*jvm)->AttachCurrentThread(jvm, &env, 0);
  jclass cls = (*env)->FindClass(env, "com/spacekomodo/berrybounce/GLRenderer");
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*env)->GetStaticMethodID(env, cls, "dataStoreCommit", "(Ljava/lang/String;)V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  jstring s = (*env)->NewStringUTF(env, dataString);
  __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "DATA_LEN: %d", strlen(dataString));
  /*__android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "DATA: %s", dataString);*/
  (*env)->CallStaticVoidMethod(env, cls, mid, s);
  (*env)->DeleteLocalRef(env, s);
}

const char* dataStoreReload(){
  trace("Android: dataStoreReload");
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
  trace("Android: userOwnsProduct");
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
  trace("Android: purchaseProduct");
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
  trace("Android: getProductPrice");
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
  trace("Android: adSetBannersEnabled");
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


int iapCanRestorePurchases(void){
  return 0;
}
void iapRestorePurchases(void){
}

int iapAvailable(){
  return 1;
}

void giftizCompleteMission(void){
  trace("Android: giftizCompleteMission");
  JNIEnv *env;
  (*jvm)->AttachCurrentThread(jvm, &env, 0);
  jclass cls = (*env)->FindClass(env, "com/spacekomodo/berrybounce/MainActivity");
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*env)->GetStaticMethodID(env, cls, "giftizCompleteMission", "()V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  (*env)->CallStaticVoidMethod(env, cls, mid);
}


void giftizSetButtonVisible(int visible){
  trace("Android: giftizSetButtonVisible");
  JNIEnv *env;
  (*jvm)->AttachCurrentThread(jvm, &env, 0);
  jclass cls = (*env)->FindClass(env, "com/spacekomodo/berrybounce/MainActivity");
  if(cls ==0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding class");
    return;
  }
  jmethodID mid = (*env)->GetStaticMethodID(env, cls, "giftizSetButtonVisible", "(I)V");
  if (mid == 0){
    __android_log_print(ANDROID_LOG_INFO, "FrameworkTest", "failed finding method id");
    return;
  }
  (*env)->CallStaticVoidMethod(env, cls, mid, visible);
}
