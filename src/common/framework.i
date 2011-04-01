%module _c_framework


%{
#include "framework/camera.h"
#include "framework/quad.h"
#include "framework/texture.h"
#include "framework/resource_loading.h"
#include "framework/rawbitmapdata.h"
#include "framework/input.h"
#include "framework/streaming_audio.h"
#include "app.h"
%}


#include "framework/camera.h"
#include "framework/quad.h"
#include "framework/texture.h"
#include "framework/rawbitmapdata.h"
#include "framework/input.h"
#include "framework/streaming_audio.h"


%extend Camera{
  static void Foo(){}
}

int screenWidth(void);
int screenHeight(void);
int isAppBroken(void);

char* loadAscii(const char* path, int* sz);
RawBitmapData* loadImage(const char* filePath);
