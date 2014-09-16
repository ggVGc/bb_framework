#include "GLES/gl.h"
#include "graphics.h"
#include "quad.h"

#ifdef ANDROID_NDK
#include <android/log.h>
#endif


void initRender(int framebufferWidth, int framebufferHeight){
  glEnable(GL_TEXTURE_2D);

  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  glClearColorx((GLfixed)(0.1f * 65536),
      (GLfixed)(0.2f * 65536),
      (GLfixed)(0.3f * 65536), 0x10000);

  glEnableClientState(GL_TEXTURE_COORD_ARRAY);
  glEnableClientState(GL_VERTEX_ARRAY);
  quadGlobalInit();
  textureGlobalInit();
  glEnableClientState(GL_VERTEX_ARRAY);
  glViewport(0, 0, framebufferWidth, framebufferHeight);
}


void beginRenderFrame() {
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
  textureBeginFrame();
  quadBeginFrame();
}
