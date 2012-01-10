#include "bitmapdata.h"



void bitmapDataInit(BitmapData* data, RawBitmapData* rawData)
{
  data->width = rawData->width;
  data->height = rawData->height;

  glGenTextures(1, &(data->glTexHandle));
  glBindTexture(GL_TEXTURE_2D, data->glTexHandle);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);

  glTexImage2D(
      GL_TEXTURE_2D, 0, GL_RGBA, rawData->width, rawData->height,
      0, GL_RGBA, GL_UNSIGNED_BYTE, rawData->data);

  glBindTexture(GL_TEXTURE_2D, 0);
}




