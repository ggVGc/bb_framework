#ifndef _H_BITMAPDATA_
#define _H_BITMAPDATA_

#include <GLES/gl.h>
#include "rawbitmapdata.h"

typedef struct BitmapData {
  int width;
  int height;
  GLuint glTexHandle;
} BitmapData;
 
void bitmapDataInit(BitmapData* data, RawBitmapData* rawData);

#endif

