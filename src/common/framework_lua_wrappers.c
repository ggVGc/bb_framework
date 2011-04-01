/*#include <stdlib.h>*/
/*#include "lauxlib.h"*/
/*#include "app.h"*/
/*#include "framework/texture.h"*/
/*#include "framework/quad.h"*/
/*#include "framework_lua_wrappers.h"*/
/*#include "framework/bitmap.h"*/
/*#include "framework/resource_loading.h"*/
/*#include "framework/input.h"*/
/*#include "framework/camera.h"*/
/*#include "framework/util.h"*/


/*typedef struct BitmapWrapper*/
/*{*/
    /*Bitmap* b;*/
/*} BitmapWrapper;*/


/*static int bitmap_gc(lua_State* s)*/
/*{*/
  /*Bitmap* b;*/
  /*BitmapWrapper* wrapper = (BitmapWrapper*)lua_touserdata(s, 1);*/
  /*b = wrapper->b;*/
  /*//bitmapDestroy(b);*/
  /*free(b);*/
  /*trace("FREEING BITMAP");*/
  /*return 0;*/
/*}*/

/*int bitmapCreate_lua(lua_State* s)*/
/*{*/
  /*[>unsigned int i;<]*/
    /*BitmapWrapper* wrapper;*/
    /*BitmapData* texture;*/
    /*const char* texFilename;*/
       
    /*texFilename = lua_tostring(s, -1);*/

    /*if( luaL_newmetatable(s, "Framework.Bitmap"))*/
    /*{*/
      /*[>trace("\nRegistered GC\n");<]*/
      /*lua_pushstring(s, "__gc");*/
      /*lua_pushcfunction(s, bitmap_gc);*/
      /*lua_settable(s, -3);*/
    /*}*/

    /*wrapper = (BitmapWrapper*)lua_newuserdata(s, sizeof(BitmapWrapper));*/
    /*luaL_getmetatable(s, "Framework.Bitmap");*/
    /*lua_setmetatable(s, -2);*/

    /*texture = loadImage(texFilename);*/
    /*[>texture = (BitmapData*)malloc(sizeof(BitmapData));<]*/
    /*[>texture->width  =512;<]*/
    /*[>texture->height = 512;<]*/
    /*[>texture->data = (unsigned char*)malloc(texture->width*texture->height*sizeof(unsigned char)*4);<]*/
    /*[>for(i=0;i<texture->width*texture->height;++i)<]*/
    /*[>{<]*/
      /*[>texture->data[i*4] = 0x00;<]*/
      /*[>texture->data[i*4+1] = 0xFF;<]*/
      /*[>texture->data[i*4+2] = 0x00;<]*/
      /*[>texture->data[i*4+3] = 0xFF;<]*/
    /*[>}<]*/
    /*wrapper->b = bitmapCreate(texture->width, texture->height, texture);*/
    /*free(texture->data);*/
    /*free(texture);*/


    /*return 1;*/
/*}*/

/*int bitmapDraw_lua(lua_State* s)*/
/*{*/
    /*BitmapWrapper* b;*/
    /*float x, y, sx, sy, rot, pivX, pivY;*/

    /*b = (BitmapWrapper*)lua_touserdata(s, 1);*/
    /*x = (float)lua_tonumber(s, 2);*/
    /*y = (float)lua_tonumber(s, 3);*/
    /*rot = (float)lua_tonumber(s, 4);*/
    /*pivX = (float)lua_tonumber(s, 5);*/
    /*pivY = (float)lua_tonumber(s, 6);*/
    /*sx = (float)lua_tonumber(s, 7);*/
    /*sy = (float)lua_tonumber(s, 8);*/

    /*if (sx == 0)*/
      /*sx = 1;*/
    /*if(sy == 0)*/
      /*sy = 1;*/
    /*bitmapDraw(b->b, x, y, rot, pivX, pivY, sx, sy); */

    /*return 0;*/
/*}*/


/*int trace_lua(lua_State* s)*/
/*{*/
    /*const char* msg;*/
    /*msg = lua_tostring(s, -1);*/
    /*trace(msg);*/
    /*return 0;*/
/*}*/



/*int cursorY_lua(lua_State* s)*/
/*{*/
  /*lua_pushnumber(s, cursorY() );*/
  /*return 1;*/
/*}*/


/*int cursorX_lua(lua_State* s)*/
/*{*/
  /*lua_pushnumber(s, cursorX() );*/
  /*return 1;*/
/*}*/

/*int cursorDown_lua(lua_State* s)*/
/*{*/
  /*lua_pushboolean(s, cursorDown());*/
  /*return 1;*/
/*}*/


/*int screenHeight_lua(lua_State* s)*/
/*{*/
  /*lua_pushnumber(s, screenHeight());*/
  /*return 1;*/
/*}*/
/*int screenWidth_lua(lua_State* s)*/
/*{*/
  /*lua_pushnumber(s, screenWidth());*/
  /*return 1;*/
/*}*/




/*int cameraCreate_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_newuserdata(s, sizeof(Camera));*/
  /*cameraInit(cam, 0, 0, screenWidth(), screenHeight());*/
  /*traceInt(screenHeight());*/
  /*return 1;*/
/*}*/

/*int cameraSetActive_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*cameraSetActive(cam);*/
  /*return 0;*/
/*}*/

/*int cameraSetX_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*cam->posX = lua_tonumber(s, 2);*/
  /*return 0;*/
/*}*/

/*int cameraSetY_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*cam->posY = lua_tonumber(s, 2);*/
  /*return 0;*/
/*}*/

/*int cameraGetX_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*lua_pushnumber(s, cam->posX);*/
  /*return 1;*/
/*}*/

/*int cameraGetY_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*lua_pushnumber(s, cam->posY);*/
  /*return 1;*/
/*}*/


/*int cameraSetWidth_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*cam->width = (float)lua_tonumber(s, 2);*/
  /*return 0;*/
/*}*/
/*int cameraSetHeight_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*cam->height = (float)lua_tonumber(s, 2);*/
  /*return 0;*/
/*}*/


/*int cameraGetWidth_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*lua_pushnumber(s, cam->width);*/
  /*return 1;*/
/*}*/
/*int cameraGetHeight_lua(lua_State* s)*/
/*{*/
  /*Camera* cam = (Camera*)lua_touserdata(s, 1);*/
  /*lua_pushnumber(s, cam->height);*/
  /*return 1;*/
/*}*/


/*[>int quadDraw_lua(lua_State*)<]*/
/*[>{<]*/

  /*[>return 0;<]*/
/*[>}<]*/

