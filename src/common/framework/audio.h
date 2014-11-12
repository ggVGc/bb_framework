#ifndef _H_AUDIO_
#define _H_AUDIO_

typedef struct PlatformAudio_T PlatformAudio;
typedef struct Audio{
  PlatformAudio *pa;
  int muted;
} Audio;

int audioGlobalInit();
int audioGlobalPlatformInit();

Audio* audioAlloc();
int audioInit(Audio *a, short *buf, int samplesPerChannel, int sampleRate, int channels);
Audio* audioLoad(const char* path);
Audio* audioModLoad(const char* path);
int audioLoadInto(Audio *a, const char* path);
void audioPlay(Audio*);
void audioSetLooping(Audio*, int);
void audioStop(Audio*);
void audioSetPaused(Audio *a, int paused);
void audioFree(Audio*);
void audioOnFrame();
void audioCleanup();
void audioPlatformCleanup();
void audioSetAllPaused(int paused);
void audioSetAllMuted(int muted);
int audioIsPlaying(Audio *a);

PlatformAudio *audioPlatformAlloc();
int audioPlatformInit(PlatformAudio *a, short *buf, int samplesPerChannel, int sampleRate, int channels);
void audioPlatformFree(PlatformAudio *);
void audioPlatformPlay(PlatformAudio*);
void audioPlatformSetPaused(PlatformAudio *a, int paused);

// Because I am lazy..
// TODO: Dynamically resize, to support infinite sounds.
#define MAX_SOUNDS 512
Audio* soundInstances[MAX_SOUNDS];


#endif




