#include <stdlib.h>
#include <math.h>
#include <vorbis/vorbisfile.h>
#include <assert.h>
#include <string.h>
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"
//#include "xmp.h"
//

#define SHORT_SAMPLE_LIMIT (1024*512)

static int globalMute = 0;

int audioGlobalInit(){
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    soundInstances[i] = NULL;
  }

  globalMute = 0;
  return audioGlobalPlatformInit();
}


int audioLoadInto(Audio *a, const char* path, int loop){
  int sz;
  char* buf;
  int i;
  int soundIndex = -1;

  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] == NULL){
      soundIndex = i;
      break;
    }
  }

  if(soundIndex < 0){
    trace("WARNING: Max sound instances reached");
    return 0;
  }
  buf = (char*)loadBytes(path, &sz);
  if(!buf){
    trace("Failed audio file load");
    return 0;
  }

  if(audioInit(a, buf, sz, loop)){
    soundInstances[soundIndex] = a;
  }
  return 1;
}

Audio* audioLoad(const char *path, int loop){
  Audio *a = audioAlloc();
  // Always return this, because we don't want application go crash just because audio failed loading
  // Need to add other way to let user know audio load failed
  audioLoadInto(a, path, loop);
  return a;
}

void audioFree(Audio *a){
  int i;
  audioStop(a);
  audioPlatformFree(a->pa);
  free(a->pa);
  decoderOgg_free(&a->decoder);
  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] == a){
      free(soundInstances[i]);
      soundInstances[i] = NULL;
      break;
    }
  }
}

void audioCleanup(){
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] != NULL){
      traceNoNL("Killing audio instance: ");
      traceInt(i);
      audioFree(soundInstances[i]);
    }
  }
  audioPlatformCleanup();
}

void audioSetAllPaused(int paused){
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    if(soundInstances[i] != NULL){
      audioSetPaused(soundInstances[i], paused);
    }
  }
}

Audio* audioModLoad(const char *path){
  /*
     const int bugSizeInc = 1024*500;
     const int bufSize = 50*1024*1024;
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

     xmp_start_player(c, sampleRate, 0);
     tmpBuf = (int*)malloc(sizeof(int)*bufSize);
     success = xmp_play_buffer(c, tmpBuf, bufSize, 0);

     if(success!=0){
     trace("Failed mod pl/ayback");
     return 0;
     }

     xmp_end_player(c);
     xmp_release_module(c);
     xmp_free_context(c);

     Audio *a = audioAlloc();
     audioInit(a, tmpBuf, bufSize, sampleRate, 2);
     free(tmpBuf);
     audioSetLooping(a, 0);

     return a;
     */
  return 0;
}

Audio* audioAlloc(){
  Audio *a = malloc(sizeof(Audio));
  a->pa = audioPlatformAlloc();
  return a;
}


int audioInit(Audio *a, char *buf, int sz, int loop){
  decoderOgg_init(&a->decoder, buf, sz);
  a->muted = 0;
  return audioPlatformInit(a, loop);
}

void audioSetAllMuted(int muted){
  Audio *a;
  int i;
  globalMute = muted;
  for(i=0;i<MAX_SOUNDS;++i){
    a = soundInstances[i];
    if(a){
      audioSetPaused(a, globalMute);
    }
    /*
       if(a && a->player_vol){
       (*a->player_vol)->SetVolumeLevel( a->player_vol, (SLmillibel)(gain_to_attenuation( vol ) * 100) );
       }
       */
  }
}

void audioPlay(Audio* a) {
  audioStop(a);
  if(globalMute || a->muted){
    return;
  }
  audioPlatformPlay(a);
}


void audioSetPaused(Audio *a, int paused){
  if(paused || (!globalMute && !a->muted)){
    audioPlatformSetPaused(a->pa, paused);
  }
}

void audioOnFrame(){
  Audio *a;
  int i;
  for(i=0;i<MAX_SOUNDS;++i){
    a = soundInstances[i];
    if(a && a->pa){
      audioInstanceOnFrame(a);
    }
  }
}


int audioIsShort(Audio *a){
  return DecoderOgg_calcStreamSize(&a->decoder) <= SHORT_SAMPLE_LIMIT;
}
