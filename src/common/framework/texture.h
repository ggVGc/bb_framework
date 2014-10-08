#ifndef _H_TEXTURE_H_
#define _H_TEXTURE_H_

#include <GLES/gl.h>
#include "rect.h"
#include "bitmapdata.h"

struct Texture{
  int width;
  int height;
  GLfloat uvCoords[12];
  BitmapData* data;
};

typedef struct Texture Texture;



void textureInit(Texture *tex, BitmapData *data, Rect sourceRect);

BitmapData *textureGetBmData(Texture *t);


#endif
