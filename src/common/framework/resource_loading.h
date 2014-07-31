#ifndef _H_RESOURCE_LOADING
#define _H_RESOURCE_LOADING

#include "rawbitmapdata.h"


//void loadAPK(const char* path);
void setResourcePath(const char* path, int useZip);
void resourcesCleanUp(void);


unsigned char* loadBytes(const char* path, int* sz);
char* loadText(const char* path);
RawBitmapData* loadImage(const char* filePath);

#endif
