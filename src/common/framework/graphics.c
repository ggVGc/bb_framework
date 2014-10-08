#include "GLES/gl.h"
#include "graphics.h"
#include "quad.h"

#ifdef ANDROID_NDK
#include <android/log.h>
#endif


void graphicsInit(int framebufferWidth, int framebufferHeight){
  glEnable(GL_TEXTURE_2D);

  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  glClearColor(0,0,0,1);

  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glEnableClientState(GL_VERTEX_ARRAY);
  quadGlobalInit();
  glEnableClientState(GL_VERTEX_ARRAY);
  glViewport(0, 0, framebufferWidth, framebufferHeight);
}


void beginRenderFrame() {
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
  quadBeginFrame();
}
