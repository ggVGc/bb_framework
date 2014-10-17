#include "framework/resource_loading.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <assert.h>
/*#include <pthread.h>*/



#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "framework/util.h"
#include "framework/input.h"
#include "framework/audio.h"
#include "app.h"
#include "framework/graphics.h"
#include "framework/quad.h"
#include "framework/data_store.h"


#ifdef ANDROID_NDK
#include <android/log.h>
#endif



#define RegLuaFuncGlobal(fname) lua_pushcfunction(luaVM, fname##_lua); lua_setglobal(luaVM, #fname);

extern int luaopen__c_framework(lua_State*);

static int appBroken = 0;
static int didInit = 0;
static int wasSuspended = 0;
/*pthread_mutex_t vmMutex;*/

int loadstringWithName(lua_State *L, const char *s, const char* name) {
  return luaL_loadbuffer(L, s, strlen(s), name);
}

#define doStringWithName(L, s, name) \
	(loadstringWithName(L, s, name) || lua_pcall(L, 0, LUA_MULTRET, 0))


int print_lua(lua_State* s){
  /*int i;*/
  /*int t = lua_gettop(s);*/
  /*while(lua_gettop(s)){*/
    if(lua_isboolean(s, -1)){
      trace(lua_toboolean(s,-1)?"true\t":"false\t");
    }else if(lua_isnil(s, -1)){
      trace("nil");
    }else{
      trace(lua_tostring(s, -1));
      /*traceNoNL("\t");*/
    }
    /*lua_pop(s, 1);*/
  /*}*/
  /*trace("");*/
  return 0;
}

int dofile(const char* filePath){
  int ret;
  char* file = loadText(filePath);
  if(!file){
    // yeye, overflow, who cares
    char msg[2048];
    sprintf(msg, "Failed loading: %s", filePath);
    trace(msg);
	return -1;
  }
  ret = doStringWithName(luaVM, file, filePath);
  free(file);
  return ret;
}

  int luaErrorHandler(lua_State *L) {
  trace("\n------- STACK TRACE ----------");
  /*
  lua_getfield(L, LUA_GLOBALSINDEX, "debug");
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return 1;
  }
  lua_getfield(L, -1, "traceback");
  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 2);
    return 1;
  }
  lua_pushvalue(L, 1);
  lua_pushinteger(L, 2);
  lua_call(L, 2, 1);
  */

  return 1;
}

int callLuaFunc(int nParams, int nRet) {
  int result = 0;
  int size0 = lua_gettop(luaVM);
  int error_index = lua_gettop(luaVM) - nParams;

  lua_pushcfunction(luaVM, luaErrorHandler);
  lua_insert(luaVM, error_index);

  result = lua_pcall(luaVM, nParams, nRet, error_index);
  if( result != 0) {
    const char* msg = lua_tostring(luaVM, -1);
    trace("\n");
    trace(msg);
    trace("\n------- END STACK TRACE ----------");
  } 

  lua_remove(luaVM, error_index);

  if((lua_gettop(luaVM) + (int)nParams -(int)nRet + 1) != size0) {
    result = -1;
    trace("Stack size changed!");
  }


  if(result != 0){
    appBroken = 1;
  }

  return result;
}


#define RegLuaFunc(fname) \
  lua_pushstring(luaVM, #fname); \
  lua_pushcfunction(luaVM, fname##_lua); \
  lua_settable(luaVM, -3);



void appInit(int appWasSuspended, int framebufferWidth, int framebufferHeight, const char* resourcePath, int useAssetZip) {
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
  setResourcePath(resourcePath, useAssetZip);

  appBroken = 0;
  luaVM = 0;
  didInit = 0;
  wasSuspended = appWasSuspended;

  luaVM = luaL_newstate();
  luaL_openlibs(luaVM);
  luaopen__c_framework(luaVM);

  RegLuaFuncGlobal(print);

  if(dofile("framework/entry_point.lua")!=0) {
    const char* msg = lua_tostring(luaVM, -1);
	trace("Failed running entry point");
	if(msg){
	  trace(msg);
	}
    setAppBroken(1);
  }
  else {
    graphicsInit(framebufferWidth, framebufferHeight);
  }
  /*pthread_mutex_unlock(&vmMutex);*/
}


void appDeinit(void) {
  trace("---- APP CLEANUP ---");

  /*pthread_mutex_lock(&vmMutex);*/
  if(luaVM) {
    lua_close(luaVM);
    luaVM = 0;
    audioCleanup();
  }else{
    trace("WARNING: Called deinit while not initialised");
  }
  /*pthread_mutex_unlock(&vmMutex);*/
}


int doFrameBody(long tick){
  if (didInit == 0 && appBroken==0){
    didInit = 1;
    if(lua_isnil(luaVM, -1)){
      trace("ERROR: Could not find global framework object");
      appBroken = 1;
      return 0;
    }
    lua_getfield(luaVM, -1, "init");
    if(lua_isnil(luaVM, -1)){
      trace("ERROR: framework.init does not exist");
      appBroken = 1;
      return 0;
    }
    lua_pushboolean(luaVM, wasSuspended);
    if(callLuaFunc(1,0) != 0){
      return 0;
    }
    trace("Init finished");
  }

  if(appBroken != 0){
    return 0;
  }else{
    int ret;
    lua_pushstring(luaVM, "doFrame");
    lua_gettable(luaVM, -2);
    lua_pushnumber(luaVM, tick);
    if(callLuaFunc(1,1) != 0) {
      return 0;
    }
    ret = lua_tonumber(luaVM, -1);
    lua_pop(luaVM, 1);
    if(ret != 0){
      return ret;
    }
  }
  return 0;
}


int appRender(long tick) {
  int ret;
  if(appBroken!=0 || !luaVM){
    return 0;
  }

  /*pthread_mutex_lock(&vmMutex);*/

  audioOnFrame();
  beginRenderFrame();
  lua_getglobal(luaVM, "framework");

  ret = doFrameBody(tick);
  /*pthread_mutex_unlock(&vmMutex);*/
  quadEndFrame();
  lua_settop(luaVM, 0);
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
  screenW = w;
}

void setScreenHeight(int h){
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
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "Ads");
    lua_getfield(luaVM, -1, "interstitialCloseCallback");
    callLuaFunc(0,0);
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called adInterstitialClosed when not initialized");
  }
}
void adInterstitialDisplayed(int success){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "Ads");
    lua_getfield(luaVM, -1, "interstitialDisplayCallback");
    lua_pushboolean(luaVM, success);
    callLuaFunc(1,0);
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called adInterstitialDisplayed when not initialized");
  }
}

void onPurchaseComplete(int success){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "IAP");
    lua_getfield(luaVM, -1, "onPurchaseComplete");
    lua_pushinteger(luaVM, success);
    callLuaFunc(1,0);
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called onPurchaseComplete when not initialized");
  }
}

void appSetPaused(int paused){
  if(didInit){
    audioSetAllPaused(paused);
    /*
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "setPaused");
    lua_pushboolean(luaVM, paused);
    callLuaFunc(1,0);
    */
  }else{
    trace("Warning: Called appSetPaused when not initialized");
  }
}

void appSuspend(){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "suspend");
    callLuaFunc(0,0);
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called appSuspend when not initialized");
  }
}

void appGraphicsReload(int framebufferWidth, int framebufferHeight){
  if(didInit){
    /*pthread_mutex_lock(&vmMutex);*/
    graphicsInit(framebufferWidth, framebufferHeight);
    lua_getglobal(luaVM, "framework");
    lua_getfield(luaVM, -1, "reloadTextures");
    callLuaFunc(0,0);
    /*pthread_mutex_unlock(&vmMutex);*/
  }else{
    trace("Warning: Called appGraphicsReload when not initialized");
  }
}

