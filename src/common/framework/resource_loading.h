#ifndef _H_RESOURCE_LOADING
#define _H_RESOURCE_LOADING

#include "rawbitmapdata.h"


void setResourcePath(const char* path);
int loadBytesIntoBuffer(const char *inPath, unsigned char *data, int bufferSize);
unsigned char* loadBytes(const char* path, int* sz);
char* loadText(const char* path);
RawBitmapData* loadImage(const char* filePath);

#endif
