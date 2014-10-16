#include "GLES/gl.h"
#include "app.h"
#include "graphics.h"
#include "quad.h"

#ifdef ANDROID_NDK
#include <android/log.h>
#endif


int curScissorX;
int curScissorY;
int curScissorW;
int curScissorH;
int scissorSet;

void graphicsInit(int framebufferWidth, int framebufferHeight){
  curScissorX = -1;
  curScissorY = -1;
  curScissorW = -1;
  curScissorH = -1;
  scissorSet = 0;
  glEnable(GL_TEXTURE_2D);

  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  glClearColor(0,0,0,1);

  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glEnableClientState(GL_VERTEX_ARRAY);
  quadGlobalInit();
  glEnableClientState(GL_VERTEX_ARRAY);
  glViewport(0, 0, framebufferWidth, framebufferHeight);
  glDepthMask(GL_FALSE);
  glDisable(GL_DEPTH_TEST);
}


void beginRenderFrame() {
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  if(scissorSet){
    glScissor(0,0, screenWidth(), screenHeight());
  }
  /*glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);*/
  glClear(GL_COLOR_BUFFER_BIT);
  if(scissorSet){
    glScissor(curScissorX, curScissorY, curScissorW, curScissorH);
  }
  quadBeginFrame();
}


void setScissor(int x, int y, int w, int h){
  scissorSet = 1;
  curScissorX = x;
  curScissorY = y;
  curScissorW = w;
  curScissorH = h;
  glEnable(GL_SCISSOR_TEST);
}
