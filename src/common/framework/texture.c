#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <GLES/gl.h>
#include "bitmapdata.h"
#include "texture.h"



void textureInit(Texture* tex, BitmapData* data, Rekt sourceRect) {
  float x = sourceRect.x;
  float y = sourceRect.y;
  float w = sourceRect.w;
  float h = sourceRect.h;
  float right = x + w;
  float top =  y + h; 
  GLfloat texCoords[12] = {
    x, top,
    right, top,
    x,  y,
    right, top,
    right,  y,
    x,  y,
  };

  tex->data = data;

  tex->width = w*data->width;
  tex->height = h*data->height;

  memcpy(tex->uvCoords, texCoords, sizeof(GLfloat)*12);
}

