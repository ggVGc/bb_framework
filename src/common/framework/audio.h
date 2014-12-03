#ifndef _H_AUDIO_
#define _H_AUDIO_

#include "decoder_ogg.h"


#define SHORT_SAMPLE_LIMIT (1024*512)

typedef struct PlatformAudio_T PlatformAudio;
typedef struct Audio{
  PlatformAudio *pa;
  DecoderOgg_State decoder;
  int muted;
} Audio;

int audioGlobalInit();
int audioGlobalPlatformInit();

Audio* audioAlloc();
int audioInit(Audio *a, char *buf, int sz, int loop, long introSilenceMs );
Audio* audioLoad(const char* path, int loop, long introSilenceMs);
Audio* audioModLoad(const char* path);
int audioLoadInto(Audio *a, const char* path, int loop, long introSilenceMs);
void audioPlay(Audio*);
//void audioSetLooping(Audio*, int);
void audioStop(Audio*);
void audioSetPaused(Audio *a, int paused);
void audioFree(Audio*);
void audioOnFrame();
void audioCleanup();
void audioPlatformCleanup();
void audioSetAllPaused(int paused);
void audioSetAllMuted(int muted);
int audioIsPlaying(Audio *a);

void audioInstanceOnFrame(Audio *a);

PlatformAudio *audioPlatformAlloc();
int audioPlatformInit(Audio *a, int loop);
void audioPlatformFree(PlatformAudio *);
void audioPlatformPlay(Audio*);
void audioPlatformSetPaused(PlatformAudio *a, int paused);


// Because I am lazy..
// TODO: Dynamically resize, to support infinite sounds.
#define MAX_SOUNDS 512
static Audio* soundInstances[MAX_SOUNDS];


int audioIsShort(Audio *a);


#endif




