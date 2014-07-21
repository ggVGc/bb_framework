#include "framework/resource_loading.h"
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <float.h>
#include <assert.h>

#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include "framework/util.h"
#include "framework/input.h"
#include "app.h"
#include "framework_lua_wrappers.h"
#include "framework/graphics.h"

#ifdef ANDROID_NDK
#include <android/log.h>
#endif

#define BREAK_ON_FIRST_ERROR 1


#define RegLuaFuncGlobal(fname) lua_pushcfunction(vm, fname##_lua); lua_setglobal(vm, #fname);

extern int luaopen__c_framework(lua_State*);

static lua_State* vm = 0;
static int appBroken = 0;
static int didInit = 0;

int loadstringWithName(lua_State *L, const char *s, const char* name) {
  return luaL_loadbuffer(L, s, strlen(s), name);
}

#define doStringWithName(L, s, name) \
	(loadstringWithName(L, s, name) || lua_pcall(L, 0, LUA_MULTRET, 0))


void print_lua(lua_State* s){
  const char* msg;
  msg = lua_tostring(s, -1);
  trace("APP OUTPUT:");
  trace(msg);
}

int dofile(const char* filePath){
  int ret;
  char* file = loadBytes(filePath, 0);
  if(!file){
    // yeye, overflow, who cares
    char msg[2048];
    sprintf(msg, "Failed loading: %s", filePath);
    trace(msg);
	return -1;
  }
  ret = doStringWithName(vm, file, filePath);
  free(file);
  return ret;
}

/*
int dofile_lua(lua_State* s) {
  const char* filePath;
  if( BREAK_ON_FIRST_ERROR && appBroken)
    return 0;
  filePath = lua_tostring(s, -1);
  if(strncmp("framework", filePath, 9)){
    traceNoNL("DoFile: ");
    trace(filePath);
  }
  if(dofile(filePath)!=0) {
    const char* msg = lua_tostring(vm, -1);
    trace(msg);
    appBroken = 1;
  }
  return 0;
}

*/

/*
int loadfile_lua(lua_State* s) {
  char* str;
  const char* filePath;

  if( BREAK_ON_FIRST_ERROR && appBroken)
    return 0;

  filePath = lua_tostring(s, -1);
  traceNoNL("LoadFile: ");
  trace(filePath);

  str = loadBytes(filePath, 0);

  lua_pushstring(s, str);
  free(str);

  return 1;
}

*/

/*
int require_lua(lua_State* s)
{
    s = s; // eliminate warning
    trace("ERROR: REQUIRE IS NOT IMPLEMENTED. Use dofile instead.");
    appBroken = 1;
    return 0;
}

*/

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

int callFunc(int nParams, int nRet) {
  int result = 0;
  int size0 = lua_gettop(vm);
  int error_index = lua_gettop(vm) - nParams;

  lua_pushcfunction(vm, luaErrorHandler);
  lua_insert(vm, error_index);

  result = lua_pcall(vm, nParams, nRet, error_index);
  if( result != 0) {
    const char* msg = lua_tostring(vm, -1);
    trace("\n");
    trace(msg);
    trace("\n------- END STACK TRACE ----------");
  } 

  lua_remove(vm, error_index);

  if((lua_gettop(vm) + (int)nParams -(int)nRet + 1) != size0) {
    result = -1;
    trace("Stack size changed!");
  }

  return result;
}


#define RegLuaFunc(fname) \
  lua_pushstring(vm, #fname); \
  lua_pushcfunction(vm, fname##_lua); \
  lua_settable(vm, -3);



void appInit(const char* resourcePath, int useAssetZip) {
  trace("---- APP INIT ----");
  inputInit();
  setResourcePath(resourcePath, useAssetZip);

  appBroken = 0;
  vm = 0;
  didInit = 0;


  vm = luaL_newstate();
  luaL_openlibs(vm);
  luaopen__c_framework(vm);

  /*
  RegLuaFuncGlobal(require);
  */
  RegLuaFuncGlobal(print);

  if(dofile("framework/entry_point.lua")!=0) {
    const char* msg = lua_tostring(vm, -1);
	trace("Failed running entry point");
	if(msg){
	  trace(msg);
	}
    appBroken = 1;
  }
  else {
    initRender();
  }
}


void appDeinit(void) {
  trace("---- APP CLEANUP ---");

  if(vm) {
    lua_close(vm);
    resourcesCleanUp();
    vm = 0;
  }
  else{
    trace("Called deinit while not initialised");
  }
}


int appRender(long tick, int width, int height) {
	int ret;
	
	if(!vm){
    return 0;
  }

  // suppress warning
  tick = tick;

  setScreenWidth(width);
  setScreenHeight(height);

  beginRenderFrame(width, height);
  lua_getglobal(vm, "framework");

  if (didInit == 0 && appBroken==0){
    didInit = 1;
    lua_pushstring(vm, "init");
    lua_gettable(vm, -2);
    if(callFunc(0,0) != 0){
      appBroken = 1;
      return 0;
    }
    trace("Init finished");
  }

  if(appBroken != 0){
    lua_settop(vm, 0);
    return 0;
  }else{
    lua_pushstring(vm, "doFrame");
    lua_gettable(vm, -2);
    lua_pushnumber(vm, tick);
    if(callFunc(1,1) != 0) {
      appBroken = 1;
      return 0;
    }
    ret = lua_tonumber(vm, -1);
    lua_pop(vm, 1);
    if(ret != 0){
      lua_settop(vm, 0);
      return ret;
    }
  }

  lua_pop(vm, 1);
  lua_gc(vm, LUA_GCSTEP, 1);
  return 0;
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


