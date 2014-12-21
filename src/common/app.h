#ifndef APP_H_INCLUDED
#define APP_H_INCLUDED


#ifdef __cplusplus
extern "C" {
#endif

#include <lua.h>

// The simple framework expects the application code to define these functions.
extern void appInit(int wasSuspended, int framebufferWidth, int framebufferHeight, const char* assetPath);
extern void appDeinit(void);
extern void appSetPaused(int paused, int pauseAudio);
extern void appSuspend(void);
void appGraphicsReload(int framebufferWidth, int framebufferHeight);
void appUnloadTextures();

extern int appRender(double tick);

extern int screenWidth(void);
extern int screenHeight(void);
extern void setScreenWidth(int);
extern void setScreenHeight(int);

extern int isAppBroken(void);
extern void setAppBroken(int isBroken);

extern int getScreenRefreshRate();

lua_State* luaVM;
int callLuaFunc(int nParams, int nRet);


#ifdef __cplusplus
}
#endif


#endif // !APP_H_INCLUDED
