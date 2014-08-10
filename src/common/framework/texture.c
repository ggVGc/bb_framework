#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <GLES/gl.h>
#include "texture.h"


static GLuint lastHandle;
static int noLastHandle;


void textureGlobalInit(){
  noLastHandle = 1;
  lastHandle = (GLuint)-1;
}


void textureInit(Texture* tex, BitmapData* data, Rect sourceRect) {
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


void textureApply(Texture *tex){
  if(noLastHandle || tex->data->glTexHandle != lastHandle){
    /*trace("BINDING NEW TEX");*/
    glBindTexture(GL_TEXTURE_2D, tex->data->glTexHandle);
    lastHandle = tex->data->glTexHandle;
  }
  glTexCoordPointer(2, GL_FLOAT, 0, tex->uvCoords);
  noLastHandle = 0;
}

