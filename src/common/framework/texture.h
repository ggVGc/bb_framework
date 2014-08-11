#ifndef _H_TEXTURE_H_
#define _H_TEXTURE_H_

#include <GLES/gl.h>
#include "rect.h"
#include "bitmapdata.h"

typedef struct{
  int width;
  int height;
  GLfloat uvCoords[12];
  BitmapData* data;
} Texture;


void textureGlobalInit();
void textureBeginFrame();

void textureInit(Texture *tex, BitmapData *data, Rect sourceRect);
void textureApply(Texture *tex);


#endif
