
#include <sys/time.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"

#include "helper_threads_lua/helper.h"
#include "framework/resource_loading.h"
#include "framework/audio.h"


typedef struct AsyncAssetLoader_loadAudio_udata {
  char *path;
  Audio *audio;
} AsyncAssetLoader_loadAudio_udata;

static int AsyncAssetLoader_loadAudio_prepare (lua_State *L, void **udata) {
  AsyncAssetLoader_loadAudio_udata *td = (AsyncAssetLoader_loadAudio_udata *)malloc (sizeof (AsyncAssetLoader_loadAudio_udata));
  if (!td){
    luaL_error (L, "can't alloc udata");
  }

  td->path = strdup(luaL_checkstring(L, 1));
  *udata = td;
  return 0;
}

static int AsyncAssetLoader_loadAudio_work (void *udata) {
  AsyncAssetLoader_loadAudio_udata *td = (AsyncAssetLoader_loadAudio_udata *)udata;
  const char *ext = strchr(td->path, '.');
  if(ext && strcmp(ext, ".ogg")==0){
    // load ogg
    td->audio = audioLoad(td->path);
  }else{
    // load mod format
    td->audio = audioModLoad(td->path);
  }
  free(td->path);
  return 0;
}

static int AsyncAssetLoader_loadAudio_update (lua_State *L, void *udata) {
  AsyncAssetLoader_loadAudio_udata *td = (AsyncAssetLoader_loadAudio_udata *)udata;
  if(td->audio){
    audioPushSWIGPtr(L, td->audio);
    return 1;
  }
  return 0;
}

static const task_ops AsyncAssetLoader_loadAudio_ops = {
  AsyncAssetLoader_loadAudio_prepare,
  AsyncAssetLoader_loadAudio_work,
  AsyncAssetLoader_loadAudio_update
};



typedef struct AsyncAssetLoader_loadImage_udata {
  const char *path;
  RawBitmapData *bmData;
} AsyncAssetLoader_loadImage_udata;

static int AsyncAssetLoader_loadImage_prepare (lua_State *L, void **udata) {
  AsyncAssetLoader_loadImage_udata *td = (AsyncAssetLoader_loadImage_udata *)malloc (sizeof (AsyncAssetLoader_loadImage_udata));
  if (!td){
    luaL_error (L, "can't alloc udata");
  }

  td->path = strdup(luaL_checkstring(L, 1));
  *udata = td;
  return 0;
}

static int AsyncAssetLoader_loadImage_work (void *udata) {
  AsyncAssetLoader_loadImage_udata *td = (AsyncAssetLoader_loadImage_udata *)udata;
  td->bmData = loadImage(td->path);
  free(td->path);
  return 0;
}

static int AsyncAssetLoader_loadImage_update (lua_State *L, void *udata) {
  AsyncAssetLoader_loadImage_udata *td = (AsyncAssetLoader_loadImage_udata *)udata;
  if(td->bmData){
    rawBitmapDataPushSWIGPtr(L, td->bmData);
    return 1;
  }
  return 0;
}

static const task_ops AsyncAssetLoader_loadImage_ops = {
  AsyncAssetLoader_loadImage_prepare,
  AsyncAssetLoader_loadImage_work,
  AsyncAssetLoader_loadImage_update
};

static const task_reg AsyncAssetLoader_reg[] = {
  {"loadImage", &AsyncAssetLoader_loadImage_ops},
  {"loadAudio", &AsyncAssetLoader_loadAudio_ops},
  {NULL}
};



int luaopen_AsyncAssetLoader(lua_State *L);
int luaopen_AsyncAssetLoader(lua_State *L) {

  helper_init (L);

    lua_getglobal(L, "_c_framework");
	lua_pushliteral (L, "AsyncAssetLoader");
    lua_newtable(L);
	lua_settable (L, -3);
    lua_pushliteral(L, "AsyncAssetLoader");
    lua_gettable(L, -2);
    tasklib (L, NULL, AsyncAssetLoader_reg);
    lua_pop(L, 1);

  return 1;
}
