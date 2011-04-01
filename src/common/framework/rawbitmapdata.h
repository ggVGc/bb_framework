#ifndef _H_RAWBITMAPDATA_H_
#define _H_RAWBITMAPDATA_H_
typedef struct RawBitmapData
{
    unsigned char* data; // RGBA
    unsigned int width;
    unsigned int height;

} RawBitmapData;

void rawBitmapDataCleanup(RawBitmapData* rawData);

#endif
