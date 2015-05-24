#ifndef H_BITMAPDATA
#define H_BITMAPDATA

#include <GLES/gl.h>
#include "rawbitmapdata.h"

typedef struct BitmapData {
  int width;
  int height;
  GLuint glTexHandle;
} BitmapData;
 
void bitmapDataInit(BitmapData* data, RawBitmapData* rawData);
void bitmapDataCleanup(BitmapData *data);

#endif

