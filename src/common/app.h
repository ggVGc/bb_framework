/* This file was automatically generated.  Do not edit! */
#include <lua.h>
#include "framework/camera.h"
void appUnloadTextures();
void appGraphicsReload(int framebufferWidth,int framebufferHeight);
void appSuspend();
void onPurchaseComplete(int success);
void adInterstitialDisplayed(int success);
void appSetPaused(int paused,int pauseAudio);
void adInterstitialClosed();
void setAppBroken(int isBroken);
int isAppBroken(void);
void setScreenHeight(int h);
void setScreenWidth(int w);
int screenHeight(void);
int screenWidth(void);
int appRender(double tick);
void appDeinit(void);
void dataStoreGlobalInit();
void appInit(int appWasSuspended,int framebufferWidth,int framebufferHeight,const char *resourcePath);
int callLuaFunc(int nParams,int nRet);
extern lua_State *luaVM;
#define INTERFACE 0
