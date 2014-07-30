#include "bitmapdata.h"
#include "util.h"



void bitmapDataInit(BitmapData* data, RawBitmapData* rawData)
{
  data->width = rawData->width;
  data->height = rawData->height;

  glGenTextures(1, &(data->glTexHandle));
  glBindTexture(GL_TEXTURE_2D, data->glTexHandle);
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MIN_FILTER,GL_LINEAR); 
  glTexParameteri(GL_TEXTURE_2D,GL_TEXTURE_MAG_FILTER,GL_LINEAR);

  glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri( GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

  /*char buf[2048];*/
  /*sprintf(buf, "%i, %i, %i", rawData->width, rawData->height, sizeof(rawData->data));*/
  /*trace(buf);*/

  glTexImage2D(
      GL_TEXTURE_2D, 0, GL_RGBA, rawData->width, rawData->height,
      0, GL_RGBA, GL_UNSIGNED_BYTE, rawData->data);

  glBindTexture(GL_TEXTURE_2D, 0);
}




