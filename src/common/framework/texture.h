#ifndef H_TEXTURE_H
#define H_TEXTURE_H

#include <GLES/gl.h>
#include "rect.h"

struct BitmapData;

struct Texture{
  int width;
  int height;
  float uvCoords[12];
  struct BitmapData* data;
};

typedef struct Texture Texture;


void textureInit(Texture *tex, struct BitmapData *data, Rekt sourceRect);


#endif
