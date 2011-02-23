#ifndef _H_FRAMEWORK_LUA_WRAPPERS_
#define _H_FRAMEWORK_LUA_WRAPPERS_

#include "lua.h"




int bitmapCreate_lua(lua_State*);
int bitmapDraw_lua(lua_State*);
int trace_lua(lua_State*);

int cursorX_lua(lua_State*);
int cursorY_lua(lua_State*);
int cursorDown_lua(lua_State*);


int screenHeight_lua(lua_State*);
int screenWidth_lua(lua_State*);

int cameraCreate_lua(lua_State*);
int cameraSetActive_lua(lua_State*);
int cameraSetX_lua(lua_State*);
int cameraSetY_lua(lua_State*);
int cameraGetX_lua(lua_State*);
int cameraGetY_lua(lua_State*);
int cameraSetWidth_lua(lua_State*);
int cameraSetHeight_lua(lua_State*);
int cameraGetWidth_lua(lua_State*);
int cameraGetHeight_lua(lua_State*);


int quadDraw_lua(lua_State*);



#endif
