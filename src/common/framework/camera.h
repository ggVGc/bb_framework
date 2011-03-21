#ifndef _H_CAMERA_H_
#define _H_CAMERA_H_

typedef struct Camera {
  float posX;
  float posY;
  int width;
  int height;
} Camera;


void cameraSetActive(Camera*);
void cameraInit(Camera*, float x, float y, int width, int height);

#endif
