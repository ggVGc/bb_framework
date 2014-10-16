%module _c_framework


%{
#include "framework/matrix2.h"
#include "framework/camera.h"
#include "framework/quad.h"
#include "framework/texture.h"
#include "framework/resource_loading.h"
#include "framework/display_object.h"
#include "framework/bitmapdata.h"
#include "framework/rawbitmapdata.h"
#include "framework/input.h"
#include "framework/audio.h"
#include "app.h"

void DisplayObject_setTex(DisplayObject *d, Texture *t){
  d->tex = t;
}
void DisplayObject_setParent(DisplayObject *d, DisplayObject *p){
  d->parent = p;
}
%}


#include "framework/display_object.h"
#include "framework/bitmapdata.h"
#include "framework/texture.h"
#include "framework/camera.h"
#include "framework/quad.h"
#include "framework/rawbitmapdata.h"
#include "framework/input.h"
#include "framework/audio.h"
#include "framework/facebook.h"
#include "framework/ads.h"
#include "framework/iap.h"
#include "framework/profiler.h"


%extend BitmapData{
  ~BitmapData(){
    bitmapDataCleanup(self);
    free(self);
  }
}


int screenWidth(void);
int screenHeight(void);
int isAppBroken(void);
void setAppBroken(int);
int getScreenRefreshRate();

void setScissor(int x, int y, int w, int h);

// Use these to avoid memory leaks
void DisplayObject_setTex(DisplayObject *d, Texture *t);
void DisplayObject_setParent(DisplayObject *d, DisplayObject *p);
//////

unsigned char* loadBytes(const char* path, int* sz);
void dataStoreCommit(const char* dataString);


%native(dataStoreReload) int _wrap_dataStoreReload(lua_State*L);
%{
static int _wrap_dataStoreReload(lua_State* L) {
  int SWIG_arg = 0;
  char *result = 0 ;
  
  SWIG_check_num_args("dataStoreReload",0,0)
  result = (char *)dataStoreReload();
  lua_pushstring(L,(const char *)result); SWIG_arg++;
  free(result);
  return SWIG_arg;
  
  if(0) SWIG_fail;
  
fail:
  lua_error(L);
  return SWIG_arg;
}
%}


%native(loadImage) int _wrap_loadImage(lua_State*L);
%{
int _wrap_loadImage(lua_State* L) {
  int SWIG_arg = 0;
  char *arg1 = (char *) 0 ;
  RawBitmapData *result = 0 ;
  
  SWIG_check_num_args("loadImage",1,1)
  if(!SWIG_lua_isnilstring(L,1)) SWIG_fail_arg("loadImage",1,"char const *");
  arg1 = (char *)lua_tostring(L, 1);
  result = (RawBitmapData *)loadImage((char const *)arg1);
  SWIG_NewPointerObj(L,result,SWIGTYPE_p_RawBitmapData,1); SWIG_arg++; 
  return SWIG_arg;
  
  if(0) SWIG_fail;
  
fail:
  lua_error(L);
  return SWIG_arg;
}
%}

%native(loadText) int _wrap_loadText(lua_State*L);
%{
int _wrap_loadText(lua_State*L) 
{
  int SWIG_arg = 0;
  char *arg1 = (char *) 0 ;
  char *result = 0 ;
  
  SWIG_check_num_args("loadText",1,1)
  if(!SWIG_lua_isnilstring(L,1)) SWIG_fail_arg("loadText",1,"char const *");
  arg1 = (char *)lua_tostring(L, 1);
  result = (char *)loadText((char const *)arg1);
  lua_pushstring(L,(const char *)result); SWIG_arg++;
  free(result);
  return SWIG_arg;
  
  if(0) SWIG_fail;
  
fail:
  lua_error(L);
  return SWIG_arg;
}
%}
