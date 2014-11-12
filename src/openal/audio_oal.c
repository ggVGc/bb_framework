#include <stdlib.h>
#if defined(__APPLE__)||defined(ANDROID_NDK)
#include <OpenAL/al.h>
#include <OpenAL/alc.h>
#else
#include <AL/al.h>
#include <AL/alc.h>
#endif
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"


int hasError = 0;
int alCheckError(const char* msg){
  int err;
  if(hasError){
    return 1;
  }
  err = alGetError();
  if(err !=AL_NO_ERROR){
    trace(msg);
    traceNoNL("Error code: ");
    traceInt(err);
    hasError = 1;
    return 1;
  }
  return 0;
}

static int initialised = 0;
static ALCcontext *context;                                                      
static ALCdevice *device;                                                       

struct PlatformAudio_T {
  ALuint source;
  ALuint buffer;
};


PlatformAudio* audioPlatformAlloc(){
  return (PlatformAudio*)malloc(sizeof(PlatformAudio));
}


int audioGlobalPlatformInit(){
  ALfloat ListenerPos[] = { 0.0, 0.0, 0.0 };
  ALfloat ListenerVel[] = { 0.0, 0.0, 0.0 };
  ALfloat ListenerOri[] = { 0.0, 0.0, -1.0,  0.0, 1.0, 0.0 };
  hasError = 0;
  initialised = 0;
  device = alcOpenDevice(NULL);                                              
  if(!device){
    trace("Failed creating OpenAL device");
    return 1;
  }
  context = alcCreateContext(device, NULL);                                   
  if(!context){
    trace("Failed creating OpenAL context");
    return 1;
  }
  alcMakeContextCurrent(context);
  if(alCheckError("Could not make OpenAL context current")){return 1;}

  alListenerfv(AL_POSITION,    ListenerPos);
  alListenerfv(AL_VELOCITY,    ListenerVel);
  alListenerfv(AL_ORIENTATION, ListenerOri);

  initialised = 1;
  trace("loaded OpenAL");
  return 0;
}

int audioPlatformInit(PlatformAudio *a, short *buf, int sampleCount, int sampleRate, int channels){
  unsigned int bufSize = sampleCount*channels*sizeof(short);
  ALfloat SourcePos[] = { 0.0, 0.0, 0.0 };
  ALfloat SourceVel[] = { 0.0, 0.0, 0.0 };
  if(!initialised){
    return 0;
  }
  alGenBuffers(1, &a->buffer);
  if(alCheckError("Failed OpenAL buffer creation")){return 0;}
  alGenSources(1, &a->source);
  if(alCheckError("Failed OpenAL source creation")){return 0;}

  alBufferData(a->buffer, channels==2?AL_FORMAT_STEREO16:AL_FORMAT_MONO16, buf, bufSize, sampleRate); 
  if(alCheckError("Failed OpenAL setting buffer data")){return 0;}
  
  alSourcei (a->source, AL_BUFFER,   a->buffer);
  alSourcef (a->source, AL_PITCH,    1.0f     );
  alSourcef (a->source, AL_GAIN,     1.0f     );
  alSourcefv(a->source, AL_POSITION, SourcePos);
  alSourcefv(a->source, AL_VELOCITY, SourceVel);
  return 1;
}

void audioPlatformPlay(PlatformAudio* a) {
  if(!initialised){
    return;
  }
  alSourcePlay(a->source);
  alCheckError("Failed playing source");
}
void audioSetLooping(Audio* a, int loop) {
  alSourcei (a->pa->source, AL_LOOPING,  loop==0?AL_FALSE:AL_TRUE);
}

void audioStop(Audio* a) {
  alSourceStop(a->pa->source);
}

void audioPlatformFree(PlatformAudio* a) {
  alDeleteSources(1, &a->source);
  alDeleteBuffers(1, &a->buffer);
}

void audioPlatformCleanup(){
  alcDestroyContext(context);
  alcCloseDevice(device);
}


void audioOnFrame(){
}

void audioPlatformSetPaused(PlatformAudio *a, int paused){
  int state;
  if(!initialised){
    return;
  }
  alGetSourcei(a->source, AL_SOURCE_STATE, &state);
  if(paused && state == AL_PLAYING){
    alSourcePause(a->source);
  }else if(!paused && state == AL_PAUSED){
    alSourcePlay(a->source);
  }
}


int audioIsPlaying(Audio *a){
  int state;
  alGetSourcei(a->pa->source, AL_SOURCE_STATE, &state);
  return state==AL_PLAYING?1:0;
}

