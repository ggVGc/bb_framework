#ifndef _H_TEXTURE_H_
#define _H_TEXTURE_H_

#include <GLES/gl.h>
#include "rect.h"

struct BitmapData;

struct Texture{
  int width;
  int height;
  GLfloat uvCoords[12];
  struct BitmapData* data;
};

typedef struct Texture Texture;


void textureInit(Texture *tex, struct BitmapData *data, Rekt sourceRect);


#endif
