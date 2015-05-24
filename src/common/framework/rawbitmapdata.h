#ifndef H_RAWBITMAPDATA_H
#define H_RAWBITMAPDATA_H
typedef struct RawBitmapData {
    unsigned char* data; // RGBA
    unsigned int width;
    unsigned int height;

} RawBitmapData;

void rawBitmapDataCleanup(RawBitmapData* rawData);

#endif
