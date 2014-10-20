
#include <sys/time.h>
#include <stdlib.h>
#include <string.h>

#include "lua.h"
#include "lauxlib.h"

#include "helper_threads_lua/helper.h"
#include "framework/resource_loading.h"
#include "framework/audio.h"


typedef struct AsyncAssetLoader_loadAudio_udata {
  const char *path;
  Audio *audio;
} AsyncAssetLoader_loadAudio_udata;

static int AsyncAssetLoader_loadAudio_prepare (lua_State *L, void **udata) {
  printf("%s", "Preparing audio load");
  AsyncAssetLoader_loadAudio_udata *td = (AsyncAssetLoader_loadAudio_udata *)malloc (sizeof (AsyncAssetLoader_loadAudio_udata));
  if (!td){
    luaL_error (L, "can't alloc udata");
  }

  td->path = strdup(luaL_checkstring(L, 1));
  *udata = td;
  return 0;
}

static int AsyncAssetLoader_loadAudio_work (void *udata) {
  printf("Audio load work\n");
  AsyncAssetLoader_loadAudio_udata *td = (AsyncAssetLoader_loadAudio_udata *)udata;
  td->audio = audioLoad(td->path);
  return 0;
}

static int AsyncAssetLoader_loadAudio_update (lua_State *L, void *udata) {
  printf("Audio load update\n");
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



static const task_reg AsyncAssetLoader_loadAudio_reg[] = {
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
    tasklib (L, NULL, AsyncAssetLoader_loadAudio_reg);
    lua_pop(L, 1);

  return 1;
}
