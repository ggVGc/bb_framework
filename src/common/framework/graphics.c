#include "GLES/gl.h"
#include "graphics.h"
#include "camera.h"
#ifdef ANDROID_NDK
#include <android/log.h>
#endif


void initRender(void)
{
  glEnable(GL_TEXTURE_2D);

  glEnable(GL_BLEND);
  glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);

  glClearColorx((GLfixed)(0.1f * 65536),
      (GLfixed)(0.2f * 65536),
      (GLfixed)(0.3f * 65536), 0x10000);
}

void beginRenderFrame(unsigned int width, unsigned int height)
{
  glMatrixMode(GL_MODELVIEW);
  glLoadIdentity();

  glViewport(0, 0, width, height);

  glClear(GL_DEPTH_BUFFER_BIT | GL_COLOR_BUFFER_BIT);
}
