#if INTERFACE
#include <lua.h>
#include "framework/camera.h"
#endif

#include "app.h"
#include "framework/resource_loading.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <assert.h>
/*#include <pthread.h>*/
#include <lauxlib.h>
#include "framework/util.h"
#include "framework/input.h"
#include "framework/audio.h"
#include "app.h"
#include "framework/graphics.h"
#include "framework/quad.h"
#include "framework/data_store.h"






static int appBroken = 0;
/*static int appPaused = 0;*/
static int didInit = 0;
static int wasSuspended = 0;
/*pthread_mutex_t vmMutex;*/

#define PRINTBUF_SIZE 4096
static char printBuf[PRINTBUF_SIZE];


void appInit(int appWasSuspended, int framebufferWidth, int framebufferHeight, const char* resourcePath) {
  trace("---- APP INIT ----");

  /*
  pthread_mutex_init(&vmMutex, 0);
  pthread_mutex_lock(&vmMutex);
  */

  traceNoNL("W:");
  traceInt(framebufferWidth);
  traceNoNL("H:");
  traceInt(framebufferHeight);

  audioGlobalInit();
  dataStoreGlobalInit();
  setResourcePath(resourcePath);

  appBroken = 0;
  /*appPaused = 0;*/
  didInit = 0;
  wasSuspended = appWasSuspended;

  graphicsInit(framebufferWidth, framebufferHeight);

  /*pthread_mutex_unlock(&vmMutex);*/
}


void appDeinit(void) {
  trace("---- APP CLEANUP ---");
  audioCleanup();
}


static int doFrameBody(double tick){
  if (didInit == 0 && appBroken==0){
    didInit = 1;
    nimInit(wasSuspended);
    trace("Init finished");
  }

  if(appBroken != 0){
    return 0;
  }else{
    int ret=nimDoFrame(tick);
    if(ret != 0){
      return ret;
    }
    return ret;
  }
  return 0;
}

int appRender(double tick) {
  int ret;
  if(appBroken!=0 ){
    return 0;
  }

  audioOnFrame();
  beginRenderFrame();
  ret = doFrameBody(tick);
  quadEndFrame();
  return ret;
}

static int screenW = 0;
static int screenH = 0;

int screenWidth(void){
  return screenW;
}

int screenHeight(void){
  return screenH;
}

void setScreenWidth(int w){
  printf("Setting screenW: %d\n", w);
  screenW = w;
}

void setScreenHeight(int h){
  printf("Setting screenH: %d\n", h);
  screenH = h;
}

int isAppBroken(void){
  return appBroken;
}

void setAppBroken(int isBroken){
  trace("SETTING APP BROKEN");
  appBroken = 1;
}

void adInterstitialClosed(){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    appSetPaused(0, 0);
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "Ads");
    lua_getfield(luaVM, -1, "interstitialCloseCallback");
    */
    /*callLuaFunc(0,0);*/
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called adInterstitialClosed when not initialized");
  }
}
void adInterstitialDisplayed(int success){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "Ads");
    lua_getfield(luaVM, -1, "interstitialDisplayCallback");
    lua_pushboolean(luaVM, success);
    */
    /*callLuaFunc(1,0);*/
    if(success){
      appSetPaused(1, 0);
    }
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called adInterstitialDisplayed when not initialized");
  }
}

void onPurchaseComplete(int success){
  if(didInit){
    appSetPaused(0,0);
    /*pthread_mutex_lock(&vmMutex);*/
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "IAP");
    lua_getfield(luaVM, -1, "onPurchaseComplete");
    lua_pushinteger(luaVM, success);
    */
    /*callLuaFunc(1,0);*/
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called onPurchaseComplete when not initialized");
  }
}

void appSetPaused(int paused, int pauseAudio){
  trace("Setting app paused");
  traceInt(paused);
  if(didInit){
    /*appPaused = paused;*/
    if(paused == pauseAudio){
      audioSetAllPaused(pauseAudio);
    }
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "setPaused");
    lua_pushboolean(luaVM, paused);
    */
    /*callLuaFunc(1,0);*/
  }else{
    trace("Warning: Called appSetPaused when not initialized");
  }
}

void appSuspend(){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "suspend");
    */
    /*callLuaFunc(0,0);*/
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called appSuspend when not initialized");
  }
}

void appGraphicsReload(int framebufferWidth, int framebufferHeight){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    graphicsInit(framebufferWidth, framebufferHeight);
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "reloadTextures");
    */
    /*callLuaFunc(0,0);*/
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called appGraphicsReload when not initialized");
  }
}

void appUnloadTextures(){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "unloadTextures");
    */
    /*callLuaFunc(0,0);*/
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called unloadTextures when not initialized");
  }
}



