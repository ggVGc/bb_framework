#include <stdlib.h>
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"
#include "xmp.h"



Audio* audioLoad(const char* path){
  const int bufSize = 1000*1000*50;
  const int sampleRate = 44100;
  int sz, success;
  int* tmpBuf;
  unsigned char *data = loadBytes(path, &sz);
  xmp_context c;
  struct xmp_frame_info mi;
  if(!data){
    trace("Invalid music file path");
    return 0;
  }
  c = xmp_create_context();
  success = xmp_load_module_from_memory(c, data, sz);
  if(success != 0){
    trace("XM load fail");
    return 0;
  }

  xmp_start_player(c, sampleRate, XMP_FORMAT_MONO);
  tmpBuf = (int*)malloc(sizeof(int)*bufSize);
  success = xmp_play_buffer(c, tmpBuf, bufSize, 0);

  if(success!=0){
    trace("Failed XM playback");
    return 0;
  }

  xmp_end_player(c);
  xmp_release_module(c);        /* unload module */
  xmp_free_context(c);          /* destroy the player context */

  Audio *a = audioMake(tmpBuf, bufSize, sampleRate);
  free(tmpBuf);
  audioSetLooping(a, 0);
  return a;
}
