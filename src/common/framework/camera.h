/* This file was automatically generated.  Do not edit! */
typedef struct Camera Camera;
void cameraInit(Camera *cam,float x,float y,int width,int height);
void cameraSetActive(Camera *cam);
struct Camera {
  float posX;
  float posY;
  int width;
  int height;
};
#define INTERFACE 0
