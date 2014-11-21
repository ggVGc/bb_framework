#include <stdlib.h>
#include <string.h>
#include "lua.h"
#include "lauxlib.h"
#include "helper_threads_lua/helper.h"
#include "framework/resource_loading.h"
#include "framework/audio.h"


void audioPushSWIGPtr(lua_State *L, Audio *a);
void rawBitmapDataPushSWIGPtr(lua_State *L, RawBitmapData *bmData);

typedef struct loadAudioData {
  char *path;
  Audio *audio;
  int loop;
} loadAudioData;

static int loadAudioPrepare (lua_State *L, void **udata) {
  loadAudioData *td = (loadAudioData *)malloc (sizeof (loadAudioData));
  if (!td){
    luaL_error (L, "can't alloc udata");
  }
  td->path = strdup(luaL_checkstring(L, 1));
  td->loop = lua_toboolean(L, 2);
  *udata = td;
  return 0;
}

static int loadAudioWork (void *udata) {
  loadAudioData *td = (loadAudioData *)udata;
  const char *ext = strchr(td->path, '.');
  if(ext && strcmp(ext, ".ogg")==0){
    // load ogg
    td->audio = audioLoad(td->path, td->loop);
  }else{
    // load mod format
    td->audio = audioModLoad(td->path);
  }
  free(td->path);
  return 0;
}

static int loadAudioUpdate (lua_State *L, void *udata) {
  loadAudioData *td = (loadAudioData *)udata;
  if(td->audio){
    audioPushSWIGPtr(L, td->audio);
    free(td);
    return 1;
  }
  free(td);
  return 0;
}

static const task_ops AsyncAssetLoader_loadAudio_ops = {
  loadAudioPrepare,
  loadAudioWork,
  loadAudioUpdate
};

typedef struct loadImageData {
  char *path;
  RawBitmapData *bmData;
} loadImageData;

static int loadImagePrepare (lua_State *L, void **udata) {
  loadImageData *td = (loadImageData *)malloc (sizeof (loadImageData));
  if (!td){
    luaL_error (L, "can't alloc udata");
  }

  td->path = strdup(luaL_checkstring(L, 1));
  *udata = td;
  return 0;
}

static int loadImageWork (void *udata) {
  loadImageData *td = (loadImageData *)udata;
  td->bmData = loadImage(td->path);
  free(td->path);
  return 0;
}

static int loadImageUpdate (lua_State *L, void *udata) {
  loadImageData *td = (loadImageData *)udata;
  if(td->bmData){
    rawBitmapDataPushSWIGPtr(L, td->bmData);
    free(td);
    return 1;
  }
  free(td);
  return 0;
}

static const task_ops AsyncAssetLoader_loadImage_ops = {
  loadImagePrepare,
  loadImageWork,
  loadImageUpdate
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
