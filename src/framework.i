%module _c_framework


%{
#include "framework/matrix2.h"
#include "framework/graphics.h"
#include "framework/camera.h"
#include "framework/quad.h"
#include "framework/texture.h"
#include "framework/resource_loading.h"
#include "framework/display_object.h"
#include "framework/bitmapdata.h"
#include "framework/rawbitmapdata.h"
#include "framework/data_store.h"
#include "framework/profiler.h"
#include "framework/facebook.h"
#include "framework/ads.h"
#include "framework/iap.h"
#include "framework/input.h"
#include "framework/audio.h"
#include "app.h"
#include "chipmunk/chipmunk.h"

void DisplayObject_setTex(DisplayObject *d, Texture *t){
  d->tex = t;
}
void DisplayObject_setParent(DisplayObject *d, DisplayObject *p){
  d->parent = p;
}
%}


#include "common/framework/display_object.h"
#include "common/framework/bitmapdata.h"
#include "common/framework/texture.h"
#include "common/framework/camera.h"
#include "common/framework/quad.h"
#include "common/framework/rawbitmapdata.h"
#include "common/framework/input.h"
#include "common/framework/audio.h"
#include "common/framework/facebook.h"
#include "common/framework/ads.h"
#include "common/framework/iap.h"
/*#include "common/framework/profiler.h"*/

#define CP_PRIVATE(__symbol__)

#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpVect.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpBB.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpSpatialIndex.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpBody.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpShape.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpPolyShape.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpArbiter.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/cpSpace.h"
#include "deps/common/chipmunk-6.2.1/include/chipmunk/constraints/cpConstraint.h"

void cpInitChipmunk(void);
void cpEnableSegmentToSegmentCollisions(void);
cpFloat cpMomentForCircle(cpFloat m, cpFloat r1, cpFloat r2, cpVect offset);
cpFloat cpAreaForCircle(cpFloat r1, cpFloat r2);
cpFloat cpMomentForSegment(cpFloat m, cpVect a, cpVect b);
cpFloat cpAreaForSegment(cpVect a, cpVect b, cpFloat r);
cpFloat cpMomentForPoly(cpFloat m, int numVerts, const cpVect *verts, cpVect offset);
cpFloat cpAreaForPoly(const int numVerts, const cpVect *verts);
cpVect cpCentroidForPoly(const int numVerts, const cpVect *verts);
void cpRecenterPoly(const int numVerts, cpVect *verts);
cpFloat cpMomentForBox(cpFloat m, cpFloat width, cpFloat height);
cpFloat cpMomentForBox2(cpFloat m, cpBB box);
int cpConvexHull(int count, cpVect *verts, cpVect *result, int *first, cpFloat tol);



void giftizCompleteMission(void);
void giftizSetButtonVisible(int visible);

%{
void audioPushSWIGPtr(lua_State *L, Audio *a){
  SWIG_NewPointerObj(L,a,SWIGTYPE_p_Audio,0);
}
%}

%{
void rawBitmapDataPushSWIGPtr(lua_State *L, RawBitmapData *bmData){
  SWIG_NewPointerObj(L,bmData,SWIGTYPE_p_RawBitmapData,1);
}
%}

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
unsigned char* loadBytes(const char* path, int* sz);
void setScissor(int x, int y, int w, int h);
void dataStoreCommit(const char* dataString);

// Use these to avoid memory leaks
void DisplayObject_setTex(DisplayObject *d, Texture *t);
void DisplayObject_setParent(DisplayObject *d, DisplayObject *p);
//////


%native(loadByteString) int _wrap_loadByteString(lua_State* L);
%{
static int _wrap_loadByteString(lua_State* L) {
  int sz;
  const char *path = lua_tostring(L, -1);
  char* result = loadBytes(path, &sz);
  if(result){
    lua_pushlstring(L, result, sz);
    free(result);
  }else{
    lua_pushnil(L);
  }
  return 1;
}
%}

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
