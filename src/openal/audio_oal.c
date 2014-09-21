#include <stdlib.h>
#include <AL/al.h>
#include <AL/alc.h>
#include "framework/audio.h"
#include "framework/resource_loading.h"
#include "framework/util.h"


int alCheckError(const char* msg){
  if(alGetError()!=AL_NO_ERROR){
    trace(msg);
    return 1;
  }
  return 0;
}

static int initialised = 0;
static ALCcontext *context;                                                      
static ALCdevice *device;                                                       

struct Audio_T {
  ALuint source;
  ALuint buffer;
};

int audioGlobalInit(){
  ALfloat ListenerPos[] = { 0.0, 0.0, 0.0 };
  ALfloat ListenerVel[] = { 0.0, 0.0, 0.0 };
  ALfloat ListenerOri[] = { 0.0, 0.0, -1.0,  0.0, 1.0, 0.0 };
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

Audio* audioMake(int *buf, int bufSize, int sampleRate){
  Audio* a;
  ALfloat SourcePos[] = { 0.0, 0.0, 0.0 };
  ALfloat SourceVel[] = { 0.0, 0.0, 0.0 };
  if(!initialised){
    return 0;
  }
  a = (Audio*)malloc(sizeof(Audio));
  alGenBuffers(1, &a->buffer);
  if(alCheckError("Failed OpenAL buffer creation")){return 0;}
  alGenSources(1, &a->source);
  if(alCheckError("Failed OpenAL source creation")){return 0;}

  alBufferData(a->buffer, AL_FORMAT_MONO16, buf, bufSize, sampleRate);

  
  alSourcei (a->source, AL_BUFFER,   a->buffer);
  alSourcef (a->source, AL_PITCH,    1.0f     );
  alSourcef (a->source, AL_GAIN,     1.0f     );
  alSourcefv(a->source, AL_POSITION, SourcePos);
  alSourcefv(a->source, AL_VELOCITY, SourceVel);
  return a;
}

void audioPlay(Audio* a) {
  trace("PLAY");
  alSourcePlay(a->source);
  alCheckError("Failed playing source");
}
void audioSetLooping(Audio* a, int loop) {
  alSourcei (a->source, AL_LOOPING,  loop==0?AL_FALSE:AL_TRUE);
}

void audioStop(Audio* a) {
  alSourceStop(a->source);
}

void audioFree(Audio* a) {
  alDeleteSources(1, a->source);
  alDeleteBuffers(1, a->buffer);
}

void audioCleanup(){
  alcDestroyContext(context);
  alcCloseDevice(device);
}

int audioIsFinished(Audio *a){
  return 0;
}
