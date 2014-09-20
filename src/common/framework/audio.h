#ifndef _H_AUDIO_
#define _H_AUDIO_

typedef struct Audio_T Audio;

int audioGlobalInit();

Audio* audioLoad(const char* path);
void audioPlay(Audio*);
void audioSetLooping(Audio*, int);
void audioStop(Audio*);
void audioFree(Audio*);

void audioCleanup();

int audioIsFinished(Audio *a);

Audio* audioMake(int *buf, int bufSize, int sampleRate);

#endif




