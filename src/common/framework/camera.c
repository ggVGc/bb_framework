#include "GLES/gl.h"
#include "camera.h"
#include "framework/util.h"


void cameraSetActive(Camera* cam) {
  glMatrixMode(GL_PROJECTION);
  glLoadIdentity();
  glScalef(1, -1, 1);
  glOrthof(cam->posX,  cam->posX + cam->width, cam->posY, cam->posY + cam->height,-1, 1);

  glMatrixMode(GL_MODELVIEW);
}

void cameraInit(Camera* cam, float x,float y, int width, int height) {
  printf("Cam: %i, %i, %i, %i", x, y, width, height);
  cam->posX = x;
  cam->posY = y;
  cam->width = width;
  cam->height = height;
}




