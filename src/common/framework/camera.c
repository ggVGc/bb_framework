#include "GLES/gl.h"
#include "camera.h"
#include "framework/util.h"
void cameraSetActive(Camera* cam)
{
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glOrthof(cam->posX,  cam->posX + cam->width, cam->posY, cam->posY + cam->height, -1, 1);
  /*float hw = cam->width/2.0;*/
  /*float hh = cam->height/2.0;*/
  /*glOrthof(cam->posX - hw,  cam->posX + hw, cam->posY - hh, cam->posY + hh, -1, 1);*/
  glMatrixMode(GL_MODELVIEW);
}

void cameraInit(Camera* cam, float x,float y, int width, int height)
{
  cam->posX = x;
  cam->posY = y;
  cam->width = width;
  cam->height = height;
}




