#ifndef _H_BITMAP_
#define _H_BITMAP_

#include "GLES/gl.h"
#include "bitmapdata.h"

typedef struct Bitmap_T Bitmap;


Bitmap* bitmapAlloc(void);
void bitmapDestroy(Bitmap*);

void bitmapInit(Bitmap* b, int width, int height, BitmapData* textureData);
Bitmap* bitmapCreate(int halfWidth, int halfHeight, BitmapData* textureData);

void bitmapDraw(Bitmap* b, float x, float y, float rot, float pivX, float pivY, float scaleX, float scaleY);
#endif
