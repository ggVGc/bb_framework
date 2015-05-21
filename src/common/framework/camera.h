#ifndef CAMERA_H_D4FVIPNE
#define CAMERA_H_D4FVIPNE




typedef struct Camera {
  float posX;
  float posY;
  int width;
  int height;
} Camera;
void cameraInit(Camera *cam,float x,float y,int width,int height);
void cameraSetActive(Camera *cam);
#endif /* end of include guard: CAMERA_H_D4FVIPNE */
