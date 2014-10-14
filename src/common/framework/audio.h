#ifndef _H_AUDIO_
#define _H_AUDIO_

typedef struct Audio_T Audio;

int audioGlobalInit();
int audioGlobalPlatformInit();

Audio* audioLoad(const char* path);
void audioPlay(Audio*);
void audioSetLooping(Audio*, int);
void audioStop(Audio*);
void audioSetPaused(Audio *a, int paused);
void audioFree(Audio*);
void audioPlatformFree(Audio*);

void audioOnFrame();

void audioCleanup();
void audioPlatformCleanup();

void audioSetAllPaused(int paused);

void audioSetMuted(int muted);

int audioIsPlaying(Audio *a);

Audio* audioMake(int *buf, int bufSize, int sampleRate, int channels);

#define MAX_SOUNDS 512

Audio* soundInstances[MAX_SOUNDS];


#endif




