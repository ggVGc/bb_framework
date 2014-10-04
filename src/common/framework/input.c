#include <stdlib.h>
#include <stdio.h>
#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>
#include "app.h"
#include "framework/input.h"
#include "util.h"

void setCursorPos(int index, int newX, int newY) {
  int t = lua_gettop(luaVM);
  lua_getglobal(luaVM, "framework");
  lua_getfield(luaVM, -1, "Input");
  lua_getfield(luaVM, -1, "setCursorPos");
  lua_pushinteger(luaVM, index);
  lua_pushinteger(luaVM, newX);
  lua_pushinteger(luaVM, newY);
  callLuaFunc(3,0);
  lua_pop(luaVM, lua_gettop(luaVM)-t);

}
void setCursorDownState(int index, int isDown) {
  int t = lua_gettop(luaVM);
  lua_getglobal(luaVM, "framework");
  lua_getfield(luaVM, -1, "Input");
  lua_getfield(luaVM, -1, "setCursorDownState");
  lua_pushinteger(luaVM, index);
  lua_pushboolean(luaVM, isDown);
  callLuaFunc(2,0);
  lua_pop(luaVM, lua_gettop(luaVM)-t);
}



void setKeyPressed(int keyCode){
  lua_getglobal(luaVM, "framework");
  lua_getfield(luaVM, -1, "Input");
  lua_getfield(luaVM, -1, "setKeyPressed");
  lua_pushinteger(luaVM, keyCode);
  callLuaFunc(1,0);
}
void setKeyReleased(int keyCode){
  lua_getglobal(luaVM, "framework");
  lua_getfield(luaVM, -1, "Input");
  lua_getfield(luaVM, -1, "setKeyReleased");
  lua_pushinteger(luaVM, keyCode);
  callLuaFunc(1,0);
}
