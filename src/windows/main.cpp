#include <windows.h>
#include <TCHAR.h>
#include "GLContextControl.h"
#include <app.h>

extern "C"
{
#include "framework/input.h"
#include "framework/resource_loading.h"
#include "framework\bitmap.h"
#include "framework\graphics.h"
}
#define WINDOW_WIDTH	480
#define WINDOW_HEIGHT	320



  static long
_getTime(void)
{
  SYSTEMTIME st;
  GetSystemTime(&st);
  return (long)(st.wSecond*1000 + st.wMilliseconds);
  //struct timeval  now;

  //gettimeofday(&now, NULL);
  //return (long)(now.tv_sec*1000 + now.tv_usec/1000);
}

LRESULT onMouseDown(Window* , WPARAM, LPARAM lp, void*)
{
  setCursorPos(LOWORD(lp), HIWORD(lp));
  setCursorDownState(1);
  return TRUE;
}

LRESULT onMouseUp(Window* , WPARAM, LPARAM, void*)
{
  setCursorDownState(0);
  return TRUE;
}

LRESULT onMouseMove(Window* , WPARAM, LPARAM lp, void*)
{
  setCursorPos(LOWORD(lp), HIWORD(lp));
  return TRUE;
}



int main(int , char** )
{
    //while(1)
    {
    //loadAPK("../../../../bin/FrameworkTest-debug.apk");
    //loadAPK("../../../../assets.zip");
    loadAPK("assets.zip");

  Window w = Window();
  w.Create(_T("Jumpz"), 0, 270, WINDOW_WIDTH + 20, WINDOW_HEIGHT+40);

  GlContextControl glc =  GlContextControl();
  if(!glc.Create(_T("GLESContext"), 0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, w.GetHandle()))
    return -1;

  glc.AssignMessageHandler(WM_LBUTTONDOWN, onMouseDown);
  glc.AssignMessageHandler(WM_LBUTTONUP, onMouseUp);
  glc.AssignMessageHandler(WM_MOUSEMOVE, onMouseMove);

  glc.SetActive();
  appInit();


  //initRender();

  //BitmapData* d = loadImage("");
  //Bitmap* b = bitmapCreate(100, 100, d);


  long lastTime = 0;


  while(w.Exists())
  {
    while(w.HandleMessage());

    long curTime = _getTime();
    long delta = curTime-lastTime;
    lastTime = curTime;
    // this means window was resized, and timing has messed up.
    if(delta < 0)
      continue;

    appRender(delta, WINDOW_WIDTH, WINDOW_HEIGHT);

    //beginRenderFrame(WINDOW_WIDTH, WINDOW_HEIGHT);
    //bitmapDraw(b, 10, 10);

    glc.EndDraw();



  }

  appDeinit();
  //bitmapDestroy(b);
  //free(b);
  resourcesCleanUp();

    }
  return 0;
}
